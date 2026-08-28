#!/usr/bin/env bash
# generate.sh — build the ai-scoring negative corpus with recorded provenance.
#
# Dry run is the default. Writing requires --execute, because generation costs real API spend and a
# generated corpus is evidence: silent regeneration would destroy the provenance it exists to carry.
#
# Usage:  bash evals/generate/generate.sh [--dry-run|--execute] [options]

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"

PROMPTS="$HERE/prompts.md"
PROVIDER_DIR="$HERE/providers"
TOPICS="$ROOT/evals/spec/topics.json"
CORPUS="$ROOT/evals/corpus"
VOICE_SKILL="$ROOT/noah-writing-voice/skills/noah-voice/SKILL.md"
VOICE_RULES="$ROOT/noah-writing-voice/skills/noah-voice/references/voice-rules.md"

ALL_PROVIDERS="anthropic google cortex"
ALL_CLASSES="generic voiced"

# The voiced class models the deployed path — Claude drafting with noah-voice loaded — so it is
# Anthropic-only by construction, not by accident.
VOICED_PROVIDER="anthropic"

MODE="dry-run"
SEL_PROVIDER="all"
SEL_CLASS="all"
LIMIT=0
FORCE=0

umask 077
TMP="$(mktemp -d "${TMPDIR:-/tmp}/evals-generate.XXXXXX")" || exit 2
trap 'rm -rf "$TMP"' EXIT

TAB=$'\t'

# ---------------------------------------------------------------------------
# plumbing

warn() { printf '%s\n' "$*" >&2; }

die_usage() {
    warn "generate.sh: $*"
    warn "run 'bash evals/generate/generate.sh --help' for usage"
    exit 2
}

die_config() {
    warn "generate.sh: $*"
    exit 2
}

usage() {
    cat <<'EOF'
generate.sh — build the ai-scoring negative corpus with recorded provenance.

  bash evals/generate/generate.sh [options]

Options
  --dry-run             Print the plan and exit 0 without any network call. This is the DEFAULT.
  --execute             Actually call the providers and write documents.
  --provider VALUE      anthropic | google | cortex | all   (default: all)
  --class VALUE         generic | voiced | all              (default: all)
  --limit N             Use only the first N source articles from the topics file.
  --force               Overwrite documents that already exist. Off by default: a generated
                        corpus is evidence, and silent regeneration destroys provenance.
  --topics PATH         Read targets from PATH instead of evals/spec/topics.json (testing).
  --help                This text.

Environment
  ANTHROPIC_SDK_KEY     Required for --provider anthropic (and for every voiced document).
  GOOGLE_API_KEY        Required for --provider google.
  CORTEX_MODEL          Required for --provider cortex: the CLI does not report which model
                        answered, so the exact model id has to be supplied for the frontmatter.
  ANTHROPIC_MODEL       Override the Anthropic model id.
  GEMINI_MODEL          Override the Google model id.

Exit codes
  0  success (a dry run always exits 0)
  1  one or more documents failed to generate
  2  usage error, missing input file, or a missing key/CLI under --execute
EOF
}

# Replace every literal occurrence of a placeholder with the contents of a file. Doing this in awk
# with index() rather than sed keeps arbitrary characters in the replacement (slashes, ampersands,
# backslashes) from being reinterpreted.
subst_file() {
    local placeholder="$1" input="$2" replacement="$3"
    awk -v ph="$placeholder" -v rf="$replacement" '
        BEGIN {
            rep = ""
            first = 1
            while ((getline l < rf) > 0) {
                rep = first ? l : rep "\n" l
                first = 0
            }
        }
        {
            line = $0
            out = ""
            while ((p = index(line, ph)) > 0) {
                out = out substr(line, 1, p - 1) rep
                line = substr(line, p + length(ph))
            }
            print out line
        }
    ' "$input"
}

subst_value() {
    local placeholder="$1" input="$2" value="$3"
    local vf="$TMP/value.txt"
    printf '%s' "$value" > "$vf"
    subst_file "$placeholder" "$input" "$vf"
}

extract_template() {
    awk -v name="$1" '
        $0 == "<!-- BEGIN TEMPLATE " name " -->" { inblk = 1; next }
        $0 == "<!-- END TEMPLATE " name " -->"   { inblk = 0; next }
        inblk && substr($0, 1, 3) == "```"       { next }
        inblk                                    { print }
    ' "$PROMPTS"
}

slugify() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' \
        | sed -e 's/--*/-/g' -e 's/^-//' -e 's/-$//'
}

provider_script() {
    case "$1" in
        anthropic) printf '%s' "$PROVIDER_DIR/anthropic.sh" ;;
        google)    printf '%s' "$PROVIDER_DIR/gemini.sh" ;;
        cortex)    printf '%s' "$PROVIDER_DIR/cortex.sh" ;;
        *)         return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# arguments

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run)  MODE="dry-run" ;;
        --execute)  MODE="execute" ;;
        --force)    FORCE=1 ;;
        --help|-h)  usage; exit 0 ;;
        --provider)
            [ $# -ge 2 ] || die_usage "--provider needs a value"
            SEL_PROVIDER="$2"; shift ;;
        --class)
            [ $# -ge 2 ] || die_usage "--class needs a value"
            SEL_CLASS="$2"; shift ;;
        --limit)
            [ $# -ge 2 ] || die_usage "--limit needs a value"
            LIMIT="$2"; shift ;;
        --topics)
            [ $# -ge 2 ] || die_usage "--topics needs a value"
            TOPICS="$2"; shift ;;
        *) die_usage "unknown argument '$1'" ;;
    esac
    shift
done

case "$SEL_PROVIDER" in
    all) PROVIDERS="$ALL_PROVIDERS" ;;
    anthropic|google|cortex) PROVIDERS="$SEL_PROVIDER" ;;
    *) die_usage "--provider must be one of: anthropic, google, cortex, all (got '$SEL_PROVIDER')" ;;
esac

case "$SEL_CLASS" in
    all) CLASSES="$ALL_CLASSES" ;;
    generic|voiced) CLASSES="$SEL_CLASS" ;;
    *) die_usage "--class must be one of: generic, voiced, all (got '$SEL_CLASS')" ;;
esac

case "$LIMIT" in
    ''|*[!0-9]*) die_usage "--limit must be a non-negative integer (got '$LIMIT')" ;;
esac

for tool in jq awk; do
    command -v "$tool" >/dev/null 2>&1 || die_config "required tool '$tool' is not on PATH"
done

# ---------------------------------------------------------------------------
# inputs

[ -f "$PROMPTS" ] || die_config "prompt templates not found at $PROMPTS"

if [ ! -f "$TOPICS" ]; then
    warn "generate.sh: topics file not found at $TOPICS"
    warn ""
    warn "It is written by the spec agent and is a JSON array, one entry per human article:"
    warn '  [{"id":"ai-efficiency-trap","source_article":"ai-efficiency-trap.md",'
    warn '    "title":"...","topic":"one neutral sentence","target_words":1080}]'
    warn ""
    warn "Point at another copy with --topics PATH."
    exit 2
fi

jq -e 'type == "array" and length > 0' "$TOPICS" >/dev/null 2>&1 \
    || die_config "$TOPICS is not a non-empty JSON array"

jq -e 'all(.[]; has("id") and has("source_article") and has("title") and has("topic") and has("target_words"))' \
    "$TOPICS" >/dev/null 2>&1 \
    || die_config "$TOPICS: every entry needs id, source_article, title, topic, target_words"

if printf '%s\n' "$CLASSES" | grep -q voiced; then
    for f in "$VOICE_SKILL" "$VOICE_RULES"; do
        [ -f "$f" ] || die_config "the voiced class needs the noah-voice rules, missing: $f"
    done
fi

TOPIC_TSV="$TMP/topics.tsv"
if [ "$LIMIT" -gt 0 ]; then
    jq -r --argjson n "$LIMIT" \
        '.[0:$n][] | [.id, .source_article, .title, .topic, (.target_words|tostring)] | @tsv' \
        "$TOPICS" > "$TOPIC_TSV"
else
    jq -r '.[] | [.id, .source_article, .title, .topic, (.target_words|tostring)] | @tsv' \
        "$TOPICS" > "$TOPIC_TSV"
fi
TOPIC_COUNT="$(wc -l < "$TOPIC_TSV" | tr -d ' ')"
[ "$TOPIC_COUNT" -gt 0 ] || die_config "no topics selected (--limit $LIMIT)"

for cls in $CLASSES; do
    extract_template "$cls" > "$TMP/template.$cls"
    [ -s "$TMP/template.$cls" ] || die_config "no '$cls' template found in $PROMPTS"
done

# ---------------------------------------------------------------------------
# rendering

render_prompt() {
    local cls="$1" title="$2" topic="$3" words="$4" out="$5"
    local a="$TMP/render.a" b="$TMP/render.b"

    subst_value '{{TITLE}}' "$TMP/template.$cls" "$title" > "$a"
    subst_value '{{TOPIC}}' "$a" "$topic" > "$b"
    subst_value '{{TARGET_WORDS}}' "$b" "$words" > "$a"

    if [ "$cls" = "voiced" ]; then
        subst_file '{{VOICE_SKILL}}' "$a" "$VOICE_SKILL" > "$b"
        subst_file '{{VOICE_RULES}}' "$b" "$VOICE_RULES" > "$a"
    fi

    mv "$a" "$out"
}

# ---------------------------------------------------------------------------
# plan
#
# columns: provider class model id source_article target_words out_path action prompt_file prompt_chars

PLAN="$TMP/plan.tsv"
: > "$PLAN"
NOTES="$TMP/notes.txt"
: > "$NOTES"
READY="$TMP/ready"
mkdir -p "$READY"

# Readiness is resolved before the plan so the plan can say which documents are actually reachable.
# Provider preflight never touches the network, so this stays true to the dry-run contract.
for provider in $PROVIDERS; do
    script="$(provider_script "$provider")" || die_usage "unknown provider '$provider'"
    [ -x "$script" ] || die_config "provider script is missing or not executable: $script"
    if msg="$("$script" preflight 2>&1)"; then
        printf 'ready\t%s\n' "$msg" > "$READY/$provider"
    else
        printf 'blocked\t%s\n' "$msg" > "$READY/$provider"
    fi
done

for provider in $PROVIDERS; do
    script="$(provider_script "$provider")"
    state="$(cut -f1 < "$READY/$provider")"
    model="$("$script" model)"
    [ -n "$model" ] || model="unknown-model"
    model_slug="$(slugify "$model")"

    for cls in $CLASSES; do
        if [ "$cls" = "voiced" ] && [ "$provider" != "$VOICED_PROVIDER" ]; then
            printf 'voiced/%s not planned: the voiced class is %s-only by construction, because it models the deployed path\n' \
                "$provider" "$VOICED_PROVIDER" >> "$NOTES"
            continue
        fi

        while IFS="$TAB" read -r id source_article title topic words; do
            [ -n "$id" ] || continue
            pfile="$TMP/prompt.$cls.$id"
            [ -f "$pfile" ] || render_prompt "$cls" "$title" "$topic" "$words" "$pfile"
            pchars="$(wc -c < "$pfile" | tr -d ' ')"

            out="$CORPUS/negative-$cls/$provider-$model_slug-$id.md"
            if [ "$state" != "ready" ]; then
                action="blocked"
            elif [ -e "$out" ] && [ "$FORCE" -eq 0 ]; then
                action="skip-exists"
            elif [ -e "$out" ]; then
                action="overwrite"
            else
                action="write"
            fi

            printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
                "$provider" "$cls" "$model" "$id" "$source_article" "$words" \
                "$out" "$action" "$pfile" "$pchars" >> "$PLAN"
        done < "$TOPIC_TSV"
    done
done

if [ -s "$PLAN" ]; then PLANNED=1; else PLANNED=0; fi

readiness() {
    local provider state note
    for provider in $PROVIDERS; do
        state="$(cut -f1 < "$READY/$provider")"
        note="$(cut -f2- < "$READY/$provider")"
        if [ "$state" = "ready" ]; then
            printf '    %-10s READY    %s\n' "$provider" "$note"
        else
            printf '    %-10s BLOCKED  %s\n' "$provider" "$note"
        fi
    done
}

print_plan() {
    local limit_txt force_txt
    if [ "$LIMIT" -gt 0 ]; then limit_txt="$LIMIT"; else limit_txt="none"; fi
    if [ "$FORCE" -eq 1 ]; then force_txt="yes"; else force_txt="no"; fi

    printf 'generate.sh — DRY RUN (no network calls, nothing written)\n\n'
    printf '  topics      %s (%s articles)\n' "$TOPICS" "$TOPIC_COUNT"
    printf '  prompts     %s\n' "$PROMPTS"
    printf '  corpus      %s\n' "$CORPUS"
    printf '  selection   provider=%s  class=%s  limit=%s  force=%s\n\n' \
        "$SEL_PROVIDER" "$SEL_CLASS" "$limit_txt" "$force_txt"

    if [ "$PLANNED" -eq 0 ]; then
        printf '  nothing selected.\n\n'
    else
        awk -F'\t' '
            {
                key = $1 "\t" $2 "\t" $3
                if (!(key in seen)) { order[++n] = key; seen[key] = 1 }
                docs[key]++
                words[key] += $6
                intok[key] += int($10 / 4)
                outtok[key] += int($6 * 1.4)
                if ($8 == "skip-exists") skips++
                if ($8 == "blocked") blocked++
            }
            END {
                printf "  %-10s %-8s %-24s %5s %7s %11s %11s\n", \
                    "provider", "class", "model", "docs", "words", "in-tokens", "out-tokens"
                printf "  %-10s %-8s %-24s %5s %7s %11s %11s\n", \
                    "---------", "-------", "-----------------------", "----", "------", \
                    "----------", "----------"
                for (i = 1; i <= n; i++) {
                    split(order[i], p, "\t")
                    printf "  %-10s %-8s %-24s %5d %7d %11d %11d\n", \
                        p[1], p[2], p[3], docs[order[i]], words[order[i]], \
                        intok[order[i]], outtok[order[i]]
                    td += docs[order[i]]; tw += words[order[i]]
                    ti += intok[order[i]]; to += outtok[order[i]]
                }
                printf "  %-10s %-8s %-24s %5d %7d %11d %11d\n", "TOTAL", "", "", td, tw, ti, to
                printf "\n"
                printf "  Token counts are estimates — input from prompt characters / 4, output from\n"
                printf "  target words * 1.4. They size the run; they do not price it.\n"
                if (skips > 0)
                    printf "\n  %d document(s) already exist and would be skipped (--force to regenerate).\n", skips
                if (blocked > 0)
                    printf "\n  %d document(s) are counted above but unreachable: their provider is BLOCKED.\n", blocked
            }
        ' "$PLAN"

        printf '\n  documents\n'
        awk -F'\t' -v root="$ROOT/" '
            {
                path = $7
                if (index(path, root) == 1) path = substr(path, length(root) + 1)
                printf "    %-12s %s\n", $8, path
            }
        ' "$PLAN"
        printf '\n'
    fi

    if [ -s "$NOTES" ]; then
        printf '  notes\n'
        sed 's/^/    /' "$NOTES"
        printf '\n'
    fi

    printf '  readiness\n'
    readiness
    printf '\n'
    printf '  A BLOCKED provider exits 2 under --execute, before anything is written.\n'
    printf '  Re-run with --execute to generate. Nothing was written and no network call was made.\n'
}

if [ "$MODE" = "dry-run" ]; then
    print_plan
    exit 0
fi

# ---------------------------------------------------------------------------
# execute

[ "$PLANNED" -eq 1 ] || die_config "nothing selected to generate"

for provider in $PROVIDERS; do
    awk -F'\t' -v p="$provider" '$1 == p { found = 1 } END { exit !found }' "$PLAN" || continue
    if [ "$(cut -f1 < "$READY/$provider")" != "ready" ]; then
        warn "generate.sh: provider '$provider' is not usable: $(cut -f2- < "$READY/$provider")"
        warn "generate.sh: nothing was written"
        exit 2
    fi
done

TODAY="$(date +%Y-%m-%d)"
written=0
skipped=0
failed=0

while IFS="$TAB" read -r provider cls model id source_article words out action pfile pchars; do
    if [ "$action" = "skip-exists" ]; then
        printf 'skip   %s (exists; --force to regenerate)\n' "$out"
        skipped=$((skipped + 1))
        continue
    fi

    script="$(provider_script "$provider")"
    body="$TMP/body.$provider.$cls.$id"
    printf 'gen    %-10s %-8s %-28s %6s chars in ... ' "$provider" "$cls" "$id" "$pchars"

    if ! "$script" generate "$pfile" > "$body" 2>"$TMP/err"; then
        printf 'FAILED\n'
        sed 's/^/       /' "$TMP/err" >&2
        failed=$((failed + 1))
        continue
    fi
    if [ ! -s "$body" ]; then
        printf 'FAILED (empty completion)\n'
        failed=$((failed + 1))
        continue
    fi

    # The completion is already paid for by this point, so a write that fails has to be
    # reported as a failure. Under `set -uo pipefail` without -e an unchecked mkdir or
    # redirect falls through to the success path, and the run claims a document it does
    # not have — the one lie a corpus that exists to carry provenance cannot afford.
    if ! mkdir -p "${out%/*}"; then
        printf 'FAILED (cannot create %s)\n' "${out%/*}"
        failed=$((failed + 1))
        continue
    fi
    if ! {
        printf -- '---\n'
        printf 'class: %s\n' "$cls"
        printf 'provider: %s\n' "$provider"
        printf 'model: %s\n' "$model"
        printf 'generated: %s\n' "$TODAY"
        printf 'target_words: %s\n' "$words"
        printf 'source_article: %s\n' "$source_article"
        printf 'prompt: |\n'
        awk '{ if (length($0) > 0) printf "  %s\n", $0; else printf "\n" }' "$pfile"
        printf -- '---\n\n'
        cat "$body"
        if [ "$(tail -c 1 "$body" | od -An -tx1 | tr -d ' \n')" != "0a" ]; then printf '\n'; fi
    } > "$out"; then
        rm -f "$out"
        printf 'FAILED (write error)\n'
        failed=$((failed + 1))
        continue
    fi
    # This check, not the one above, is what actually catches a permission failure:
    # bash reports the redirect error on stderr but the group still exits 0, so the
    # guard above never fires. Verified against a mode-555 corpus directory. Keep both
    # — the group check covers a failing command inside the block, this one covers the
    # redirect itself and any write that truncates.
    if [ ! -s "$out" ]; then
        rm -f "$out"
        printf 'FAILED (document missing or empty after write)\n'
        failed=$((failed + 1))
        continue
    fi

    printf 'ok (%s words)\n' "$(wc -w < "$body" | tr -d ' ')"
    written=$((written + 1))
done < "$PLAN"

printf '\n%d written, %d skipped, %d failed\n' "$written" "$skipped" "$failed"
[ "$failed" -eq 0 ] || exit 1
exit 0
