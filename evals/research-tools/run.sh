#!/usr/bin/env bash
# research-tools skill-behavior evals. Grades THIS repository's research-tools plugin, which is why they live here.
#
#   usage: evals/research-tools/run.sh MODE [options]
#
#   MODES (combine freely; with none, --skip-model is assumed)
#     --skip-model   offline tier only: harness self-tests plus the static epub contract. No model, no network, CI-safe.
#     --triggers     does the skill FIRE? Runs triggers.jsonl through `claude -p` and records every Skill call.
#     --modes        does the skill DECLARE the right mode at Phase 0? Runs modes.jsonl.
#     --behavior     B1 (no epub requested) and B2 (epub requested): the expensive part, rapid tier, real web calls.
#     --summary      print the markdown results tables computed from out/ (spends nothing)
#     --dry-run      with a live mode: print every claude command and the planned spend, run nothing
#
#   OPTIONS
#     --split train|heldout|all   which trigger split to run (default all). A description rewrite is scored on train
#                                 only; heldout is looked at once, at the end, and never used to edit anything.
#     --reps N                    repetitions per query (default 2). Rep 1 of every query completes before rep 2 starts,
#                                 so a spend-cap stop leaves a balanced sample.
#     --only ID[,ID...]           restrict to these query ids (or B1/B2)
#     --plugin-dir PATH           the research-tools copy UNDER TEST (default: <this checkout>/research-tools)
#     --jobs N                    parallel claude processes (default 4)
#     --resume                    keep out/<mode>/ and skip runs that already have a verdict (default: start clean)
#
# ENVIRONMENT
#     EVAL_MAX_BUDGET_USD   per-call cap for trigger and mode runs (default 0.50)
#     EVAL_BEHAVIOR_BUDGET_USD  per-call cap for B1/B2 (default 4.00)
#     EVAL_TOTAL_BUDGET_USD total cap across everything recorded in out/spend.tsv (default 12.00). A run that could
#                           take the total past it is not started.
#     EVAL_MODEL            --model value; default is whatever claude defaults to, and the init event records it.
#
# WHAT THE EXIT CODE MEANS. --skip-model: 0 unless an offline check failed. Live modes: 0 when the harness ran; a model
# FAILURE (a miss, a B1 FAIL) is a finding, printed and summarised, not a harness error. An ERROR is a run whose variant
# could not be verified or whose claude process produced no result: it is excluded from every rate and counted
# separately, never a pass. A live run that asked for the model and executed none of it exits 1 (the model floor).
#
# VARIANT VERIFICATION. Every run disables the installed research-tools@noah-local copy through --settings and loads the
# copy under test through --plugin-dir. The init event's plugin list must then hold exactly ONE research-tools whose
# path is the one under test; anything else is an ERROR. Without this a run can silently grade the installed copy
# while claiming to grade the branch.
#
# SAFETY. Bash is never allowed: guard-tools.sh is a PreToolUse hook that denies every Bash call (the attempt stays
# visible in the transcript, which is the B2 signal) and confines Write/Edit to the run's fixture directory. pandoc
# therefore cannot run and nothing can land in ~/Documents. Permissions are passed by flags only.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="${PLUGINS_EVAL_REPO:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
if [ ! -f "$REPO/build-plugins.sh" ]; then
    echo "ERROR: REPO does not look like the claude-plugins checkout: $REPO" >&2
    exit 2
fi

OUT="$SCRIPT_DIR/out"
TRIGGERS="$SCRIPT_DIR/triggers.jsonl"
MODES="$SCRIPT_DIR/modes.jsonl"

DO_OFFLINE=0; DO_TRIGGERS=0; DO_MODES=0; DO_BEHAVIOR=0; DO_SUMMARY=0; DRY=0; RESUME=0
SPLIT=all; REPS=2; ONLY=""; JOBS=4; TAG=""; DO_RESCORE=0
PLUGIN="$REPO/research-tools"
CAP="${EVAL_MAX_BUDGET_USD:-0.50}"
BCAP="${EVAL_BEHAVIOR_BUDGET_USD:-4.00}"
TOTAL="${EVAL_TOTAL_BUDGET_USD:-12.00}"

while [ $# -gt 0 ]; do
    case "$1" in
        --skip-model) DO_OFFLINE=1 ;;
        --triggers)   DO_TRIGGERS=1 ;;
        --modes)      DO_MODES=1 ;;
        --behavior)   DO_BEHAVIOR=1 ;;
        --summary)    DO_SUMMARY=1 ;;
        --dry-run)    DRY=1 ;;
        --resume)     RESUME=1 ;;
        --split)      SPLIT="${2:-}"; shift ;;
        --reps)       REPS="${2:-}"; shift ;;
        --tag)        TAG="${2:-}"; shift ;;
        --rescore)    DO_RESCORE=1 ;;
        --only)       ONLY="$(printf '%s' "${2:-}" | tr ',' ' ')"; shift ;;
        --plugin-dir) PLUGIN="${2:-}"; shift ;;
        --jobs)       JOBS="${2:-}"; shift ;;
        -h|--help)    sed -n '2,45p' "$0"; exit 0 ;;
        *)            echo "unknown flag: $1" >&2; exit 2 ;;
    esac
    shift
done
case "$SPLIT" in train|heldout|all) ;; *) echo "--split must be train, heldout or all" >&2; exit 2 ;; esac
case "$REPS$JOBS" in *[!0-9]*|"") echo "--reps and --jobs must be integers" >&2; exit 2 ;; esac
if [ $((DO_TRIGGERS+DO_MODES+DO_BEHAVIOR+DO_SUMMARY)) -eq 0 ]; then DO_OFFLINE=1; fi

PASS=0; FAIL=0
ok()  { echo "  PASS  $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

# ── offline tier ─────────────────────────────────────────────────────────────────────────────────────────────────
offline_tier() {
    echo "== offline: triggers.jsonl schema and pre-registered shape =="
    command -v jq >/dev/null 2>&1 || { bad "jq is required"; return; }
    local n
    n="$(jq -s 'length' "$TRIGGERS" 2>/dev/null || echo -1)"
    [ "$n" -eq 40 ] && ok "40 trigger queries" || bad "expected 40 trigger queries, found $n"

    if jq -s -e 'all(.[]; (keys|sort) == ["expect","id","near_miss","note","prompt","split"]
                          and (.id|type=="string") and (.prompt|type=="string" and length>0)
                          and (.expect|IN("fire","no-fire")) and (.near_miss|type=="boolean")
                          and (.split|IN("train","heldout")) and (.note|type=="string"))' "$TRIGGERS" >/dev/null 2>&1; then
        ok "every trigger row has exactly the schema fields with legal values"
    else bad "a trigger row breaks the schema"; fi

    [ "$(jq -s '[.[].id]|length - (unique|length)' "$TRIGGERS")" -eq 0 ] && ok "trigger ids are unique" || bad "duplicate trigger ids"
    [ "$(jq -s '[.[]|select(.expect=="fire")]|length' "$TRIGGERS")" -eq 16 ] && ok "16 fire queries" || bad "fire count is not 16"
    [ "$(jq -s '[.[]|select(.expect=="no-fire")]|length' "$TRIGGERS")" -eq 24 ] && ok "24 no-fire queries" || bad "no-fire count is not 24"
    [ "$(jq -s '[.[]|select(.near_miss)]|length * 100 / length|floor' "$TRIGGERS")" -ge 40 ] \
        && ok "near-misses are at least 40 percent of the set" || bad "near-miss share is under 40 percent"
    [ "$(jq -s '[.[]|select(.expect=="no-fire" and .near_miss)]|length' "$TRIGGERS")" -ge 16 ] \
        && ok "at least 16 no-fire near-misses" || bad "fewer than 16 no-fire near-misses"
    [ "$(jq -s '[.[]|select(.split=="train")]|length' "$TRIGGERS")" -eq 24 ] \
        && [ "$(jq -s '[.[]|select(.split=="heldout")]|length' "$TRIGGERS")" -eq 16 ] \
        && ok "split sizes are 24 train / 16 heldout" || bad "split sizes are not 24 / 16"
    # Stratified: inside every (expect, near_miss) cell the train count is floor or ceil of 60 percent of the cell.
    if jq -s -e 'group_by([.expect,.near_miss])
                 | all(.[]; (length) as $c | ([.[]|select(.split=="train")]|length) as $t
                            | ($t >= ($c*0.6|floor)) and ($t <= ($c*0.6|ceil)))' "$TRIGGERS" >/dev/null; then
        ok "split is stratified by expect and near_miss (train is 60 percent of every cell, rounded)"
    else bad "split is not stratified within an (expect, near_miss) cell"; fi
    [ "$(jq -s '[.[]|select(.prompt|test("/research"))]|length' "$TRIGGERS")" -eq 0 ] \
        && ok "no prompt uses the literal /research" || bad "a prompt uses the literal /research"
    if jq -s -e '([.[]|select(.expect=="fire" and (.note|test("evidence")))]|length>=1)
                 and ([.[]|select(.expect=="fire" and (.note|test("decision")))]|length>=1)
                 and ([.[]|select(.expect=="fire" and (.note|test("hybrid")))]|length>=1)' "$TRIGGERS" >/dev/null 2>&1; then
        ok "fire queries cover evidence, decision-design and hybrid phrasings"
    else bad "fire queries do not cover all three phrasing families"; fi

    echo "== offline: modes.jsonl =="
    [ "$(jq -s 'length' "$MODES")" -eq 12 ] && ok "12 mode prompts" || bad "mode prompt count is not 12"
    if jq -s -e '(map(.id)|unique|length)==12 and all(.[]; (keys|sort)==["expect_mode","id","note","prompt","split"] and (.split|IN("train","heldout")))
                 and ([.[]|select(.expect_mode=="evidence")]|length)==4 and ([.[]|select(.split=="train")]|length)==6 and ([.[]|select(.split=="heldout")]|length)==6
                 and ([.[]|select(.expect_mode=="decision-design")]|length)==4 and ([.[]|select(.split=="train")]|length)==6 and ([.[]|select(.split=="heldout")]|length)==6
                 and ([.[]|select(.expect_mode=="hybrid")]|length)==4 and ([.[]|select(.split=="train")]|length)==6 and ([.[]|select(.split=="heldout")]|length)==6' "$MODES" >/dev/null 2>&1; then
        ok "modes: unique ids, schema, 2 evidence / 2 decision-design / 2 hybrid"
    else bad "modes.jsonl breaks its schema or its 2/2/2 balance"; fi

    echo "== offline: harness files =="
    [ -x "$SCRIPT_DIR/guard-tools.sh" ] && ok "guard-tools.sh is executable" || bad "guard-tools.sh is not executable"
    if [ -x "$SCRIPT_DIR/guard-tools.sh" ]; then
        local g
        g="$(printf '{"tool_name":"Bash","cwd":"/x","tool_input":{"command":"pandoc a.md -o a.epub"}}' | "$SCRIPT_DIR/guard-tools.sh")"
        case "$g" in *'"permissionDecision":"deny"'*) ok "guard denies Bash" ;; *) bad "guard did not deny Bash" ;; esac
        g="$(printf '{"tool_name":"Write","cwd":"/x/fx","tool_input":{"file_path":"/Users/someone/Documents/a.md"}}' | "$SCRIPT_DIR/guard-tools.sh")"
        case "$g" in *'"permissionDecision":"deny"'*) ok "guard denies a Write outside the fixture" ;; *) bad "guard allowed an outside Write" ;; esac
        g="$(printf '{"tool_name":"Write","cwd":"/x/fx","tool_input":{"file_path":"/x/fx/docs/research/a/analysis.md"}}' | "$SCRIPT_DIR/guard-tools.sh")"
        [ -z "$g" ] && ok "guard allows a Write inside the fixture" || bad "guard denied an inside Write"
    fi

    echo "== offline: static contract, no skill text produces an epub without a user request =="
    # Every line that mentions epub or pandoc under research-tools/skills must carry a user-request qualifier in its
    # section heading or within three lines either side. A bare imperative ("generate the epub") has none of them and fails.
    local qual='only|unless|if the user|when the user|if they|requested|on request|asks|asked|do not|don.t|never|no epub|if an epub|if one is made|when one is made|default'
    local file lineno bare=0 hits=0 win
    while IFS=: read -r file lineno _; do
        hits=$((hits+1))
        win="$(awk -v n="$lineno" 'NR<=n && /^#/ {h=$0} END{print h}' "$file")
$(sed -n "$((lineno>3?lineno-3:1)),$((lineno+3))p" "$file")"
        if ! printf '%s' "$win" | grep -qiE "$qual"; then
            echo "    unqualified epub/pandoc mention: ${file#"$REPO"/}:$lineno"
            bare=$((bare+1))
        fi
    done < <(grep -rniE 'epub|pandoc' "$PLUGIN/skills" --include='*.md' | awk -F: '{print $1":"$2":x"}')
    if [ "$hits" -eq 0 ]; then bad "contract: no epub or pandoc mention found at all, so the check proves nothing"
    elif [ "$bare" -eq 0 ]; then ok "contract: all $hits epub/pandoc mentions carry a user-request qualifier"
    else bad "contract: $bare of $hits epub/pandoc mentions have no user-request qualifier"; fi
    if grep -rniE 'always (make|generate|produce|create) (an? )?epub|then (make|generate|produce) (an? )?epub' "$PLUGIN/skills" --include='*.md' >/dev/null; then
        bad "contract: a skill file tells the model to always produce an epub"
    else ok "contract: no skill file says to always produce an epub"; fi

    echo "== offline: KNOWN text contradictions (reported, not fixed; they are not failures) =="
    local rds="$PLUGIN/skills/reading-deliverable-standard.md" sk="$PLUGIN/skills/research/SKILL.md"
    local tpl="$PLUGIN/skills/research/references/research-document-template.md"
    if grep -qi 'not gated on them' "$rds" && grep -qE 'score *(≥|>=) *75' "$rds"; then
        echo "  KNOWN reading-deliverable-standard.md: is ai-scoring 75 a gate?"
        grep -nE 'not gated on them' "$rds" | sed 's/^/    says no  :/' | cut -c1-110
        grep -nE 'score *(≥|>=) *75' "$rds" | sed 's/^/    says yes :/' | cut -c1-110
    else echo "  (ai-scoring gate contradiction no longer present)"; fi
    if grep -qE 'Score: [0-9]+\.[0-9]' "$tpl" && grep -qi 'band word, not a decimal' "$sk"; then
        echo "  KNOWN research-document-template.md decimal score vs research/SKILL.md band word"
        grep -nE 'Score: [0-9]+\.[0-9]' "$tpl" | sed 's/^/    template :/' | cut -c1-110
        grep -ni 'band word, not a decimal' "$sk" | sed 's/^/    SKILL.md :/' | cut -c1-110
    else echo "  (score decimal vs band contradiction no longer present)"; fi

    echo "RESULT: $PASS pass, $FAIL fail (offline tier; no model was run)"
    if [ "$FAIL" -eq 0 ]; then echo "offline tier: no failures"; fi
}

# ── shared live plumbing ─────────────────────────────────────────────────────────────────────────────────────────
alias_of='def alias: if test("deep-research") then "deep-research" elif test("design-doc") then "design-doc"
          elif test("strategic-brief") then "strategic-brief" elif test("cortex") then "cortex-router"
          elif test("research-tools:research$") or . == "research" then "research" else sub("^[^:]*:";"") end;'

PLUGIN_REAL=""
SETTINGS_JSON=""
live_setup() {
    command -v claude >/dev/null 2>&1 || { echo "claude is not on PATH; the live run cannot start" >&2; exit 2; }
    command -v jq >/dev/null 2>&1 || { echo "jq is not on PATH" >&2; exit 2; }
    [ -f "$PLUGIN/.claude-plugin/plugin.json" ] || { echo "ERROR: $PLUGIN is not a plugin directory" >&2; exit 2; }
    PLUGIN_REAL="$(cd "$PLUGIN" && pwd -P)"
    SETTINGS_JSON="$(jq -nc --arg g "bash $SCRIPT_DIR/guard-tools.sh" \
        '{enabledPlugins:{"research-tools@noah-local":false},
          hooks:{PreToolUse:[{matcher:"Bash|Write|Edit|MultiEdit|NotebookEdit",hooks:[{type:"command",command:$g}]}]}}')"
    mkdir -p "$OUT"
    touch "$OUT/spend.tsv"
}

spent_total() { awk -F'\t' '{s+=$4} END{printf "%.4f", s+0}' "$OUT/spend.tsv"; }

TIMEOUT=()
command -v gtimeout >/dev/null 2>&1 && TIMEOUT=(gtimeout)
command -v timeout >/dev/null 2>&1 && TIMEOUT=(timeout)

# The claude argv for one run, in ARGV. Args: <kind> <prompt> <budget>
build_argv() {
    local kind="$1" prompt="$2" budget="$3" tools allowed turns
    case "$kind" in
        triggers) tools="Skill,Read"; allowed="Skill Read"; turns=3 ;;
        modes)    tools="Skill,Read"; allowed="Skill Read"; turns=5 ;;
        behavior) tools="Skill,Read,Write,WebSearch,WebFetch,Agent,Bash"; allowed="Skill Read Write WebSearch WebFetch Agent"; turns=60 ;;
    esac
    ARGV=(-p "$prompt" --output-format stream-json --verbose --no-session-persistence
          --plugin-dir "$PLUGIN_REAL" --settings "$SETTINGS_JSON"
          --permission-mode dontAsk --tools "$tools" --allowedTools $allowed
          --max-turns "$turns" --max-budget-usd "$budget")
    [ -n "${EVAL_MODEL:-}" ] && ARGV+=(--model "$EVAL_MODEL")
    return 0
}

make_fixture() {
    local d="$1"
    mkdir -p "$d/src" "$d/docs" "$d/tests"
    printf '# Fixture app\n\nA small throwaway web service used by the research-tools eval.\n' > "$d/README.md"
    printf '# Notes\n\n- Orders are validated in src/auth.py before checkout.\n- Config lives in config.json.\n- Tests are flaky when the clock moves.\n' > "$d/docs/notes.md"
    printf 'def login(user, password):\n    return user == "admin" and password == "x"\n' > "$d/src/auth.py"
    printf 'import json\n\ndef load(path):\n    return json.load(open(path))\n' > "$d/src/config.py"
    printf 'def main():\n    foo = 1\n    return foo\n' > "$d/main.py"
    printf '{"debug":true,"port":8080}\n' > "$d/config.json"
    printf 'def test_checkout():\n    assert True\n' > "$d/tests/test_checkout.py"
    git -C "$d" init --quiet --initial-branch=main
    git -C "$d" add -A
    GIT_AUTHOR_NAME=eval GIT_AUTHOR_EMAIL=eval@example.invalid GIT_COMMITTER_NAME=eval GIT_COMMITTER_EMAIL=eval@example.invalid \
        git -C "$d" commit --quiet -m "fixture"
}

# Reduce a stream to analysis.json. Args: <stream> <out>
analyze_stream() {
    jq -s --arg plugin "$PLUGIN_REAL" "$alias_of"'
      (map(select(.type=="system" and .subtype=="init"))|first) as $init
      | (map(select(.type=="result"))|last) as $res
      | [ .[] | select(.type=="assistant") | (.message.content|if type=="array" then . else [] end)[] ] as $blocks
      | [ $blocks[] | select(.type=="tool_use") ] as $tu
      | ([ $blocks[] | select(.type=="text") | .text ] | join("\n")) as $text
      | ([ $init.plugins[]? | select(.name=="research-tools") ]) as $copies
      | ($text | [match("(?im)^[ >*_`]*mode[*_`]*:[ *_`]*(evidence|decision[- ]design|hybrid)";"g")] | first | .captures[0].string // null) as $m0
      | ($text | [match("(?i)mode[^a-zA-Z]{0,30}(evidence|decision[- ]design|hybrid)";"g")] | first | .captures[0].string // null) as $m1
      | ($text | [match("\\*\\*(evidence|decision-design|hybrid)\\*\\*";"gi")] | first | .captures[0].string // null) as $m2
      | ($text | [match("(evidence|decision[- ]design|hybrid)[ -]mode";"gi")] | first | .captures[0].string // null) as $m3
      | {
          have_init: ($init != null),
          have_result: ($res != null),
          model: ($init.model // null),
          copies: ($copies | map(.path)),
          variant_ok: (($copies|length) == 1 and ($copies[0].path == $plugin)),
          subtype: ($res.subtype // null),
          is_error: ($res.is_error // false),
          result_text: ($res.result // ""),
          cost: ($res.total_cost_usd // 0),
          turns: ($res.num_turns // 0),
          tokens: (($res.usage.input_tokens // 0) + ($res.usage.output_tokens // 0)
                   + ($res.usage.cache_creation_input_tokens // 0) + ($res.usage.cache_read_input_tokens // 0)),
          skills: [ $tu[] | select(.name=="Skill") | (.input.skill // .input.name // "") ],
          tool_names: [ $tu[].name ],
          bash_calls: [ $tu[] | select(.name=="Bash") | (.input.command // "") ],
          other_inputs: [ $tu[] | select(.name!="Bash" and .name!="Write" and .name!="Edit" and .name!="Read")
                          | (.input|tojson) ],
          epub_paths: [ $tu[] | select(.name=="Write" or .name=="Edit") | (.input.file_path // "") | select(test("\\.epub$";"i")) ],
          text_last: ($text | .[-400:]),
          declared_line: ($m0 != null),
          epub_text: ($text | test("pandoc|epub";"i")),
          declared: (((((($m0 // $m1) // $m2) // $m3) // "undeclared") | ascii_downcase) | sub(" ";"-"))
        }
      | .fired = (.skills | map(alias) | any(. == "research"))
      | .others = (.skills | map(alias) | map(select(. != "research")) | unique)
    ' "$1" > "$2" 2>/dev/null
}

# Run one claude call and write verdict.json. Args: <kind> <id> <rep> <prompt> <cwd> <dir> <budget> <jqmeta>
run_one() {
    local kind="$1" id="$2" rep="$3" prompt="$4" fx="$5" dir="$6" budget="$7" meta="$8" tmo=300
    [ "$kind" = behavior ] && tmo=1500
    mkdir -p "$dir"
    printf '%s' "$prompt" > "$dir/prompt.txt"
    build_argv "$kind" "$prompt" "$budget"
    ( cd "$fx" && ${TIMEOUT[@]+"${TIMEOUT[@]}" "$tmo"} claude "${ARGV[@]}" > "$dir/stream.jsonl" 2> "$dir/stderr.txt" )
    echo "$? " > "$dir/rc.txt"
    analyze_stream "$dir/stream.jsonl" "$dir/analysis.json"
    [ -s "$dir/analysis.json" ] || echo '{"have_init":false,"have_result":false,"variant_ok":false,"cost":0}' > "$dir/analysis.json"
    local status=ok err=""
    if ! jq -e '.have_init' "$dir/analysis.json" >/dev/null; then status=error; err="no init event"
    elif ! jq -e '.variant_ok' "$dir/analysis.json" >/dev/null; then
        status=error; err="variant not verified: copies loaded = $(jq -c '.copies' "$dir/analysis.json")"
    elif ! jq -e '.have_result' "$dir/analysis.json" >/dev/null; then status=error; err="no result event"
    elif jq -e '.is_error and (.subtype == "success")' "$dir/analysis.json" >/dev/null; then
        status=error; err="claude reported an error: $(jq -r '.result_text' "$dir/analysis.json" | head -c 160 | tr '\n' ' ')"
    fi
    jq -c --arg kind "$kind" --arg id "$id" --argjson rep "$rep" --arg status "$status" --arg err "$err" --arg tag "$TAG" --argjson meta "$meta" \
        '. + $meta + {kind:$kind, id:$id, rep:$rep, status:$status, error:$err, tag:$tag}' "$dir/analysis.json" > "$dir/verdict.json"
    printf '%s\t%s\t%s\t%s\n' "$kind" "$id" "$rep" "$(jq -r '.cost' "$dir/analysis.json")" >> "$OUT/spend.tsv"
}

# Task list for a kind, one tab-separated line per run: id rep prompt meta-json
trigger_tasks() {
    local rep
    for rep in $(seq 1 "$REPS"); do
        # Interleaved fire / no-fire / near-miss so a spend-cap stop mid-rep leaves a balanced sample, not all F then no N.
        jq -rs --arg split "$SPLIT" --argjson rep "$rep" --arg only "$ONLY" \
            '[.[] | select(($split=="all" or .split==$split) and ($only=="" or (.id as $q | $only|split(" ")|any(. == $q))))]
             | group_by([.expect,.near_miss]) | map(to_entries | map({k:.key, v:.value})) | flatten | sort_by(.k) | .[].v
             | [.id, $rep, .prompt, ({split,expect,near_miss}|tojson)] | @tsv' "$TRIGGERS"
    done
}
mode_tasks() {
    local rep
    for rep in $(seq 1 "$REPS"); do
        jq -r --arg split "$SPLIT" --argjson rep "$rep" --arg only "$ONLY" \
            'select(($split=="all" or .split==$split) and ($only=="" or (.id as $q | $only|split(" ")|any(. == $q)))) | [.id, $rep, .prompt, ({expect_mode,split}|tojson)] | @tsv' "$MODES"
    done
}
B_COMMON="Rapid tier, scope confirmed, proceed without asking me anything. I confirm the Phase 0 mode (evidence) and the Phase 1.2 research design in this message, so do not ask me to validate them. Question: does drinking a glass of water before a meal reduce how much adults eat at that meal? Keep it tiny: at most 3 sources. Write the finished deliverable into this repository under docs/research/ and stop."
behavior_tasks() {
    local want="${ONLY:-B1 B2}"
    case " $want " in *" B1 "*) printf 'B1\t1\t/research-tools:research %s\t{"case":"B1"}\n' "$B_COMMON" ;; esac
    case " $want " in *" B2 "*) printf 'B2\t1\t/research-tools:research %s I also want an epub of the finished report.\t{"case":"B2"}\n' "$B_COMMON" ;; esac
}

# Behavior grading, run after the call. Writes behavior.json beside verdict.json. Args: <dir> <fixture> <case>
grade_behavior() {
    local dir="$1" fx="$2" c="$3" reasons=() verdict=FAIL a="$dir/analysis.json"
    local asked=0 doc first epubs pandoc_call=0
    jq -e '(.bash_calls|map(select(test("pandoc|\\.epub";"i")))|length) > 0
           or (.other_inputs|map(select(test("pandoc|\\.epub";"i")))|length) > 0
           or (.epub_paths|length) > 0' "$a" >/dev/null && pandoc_call=1
    epubs="$(find "$fx" -name '*.epub' 2>/dev/null | wc -l | tr -d ' ')"
    doc="$(find "$fx/docs/research" -mindepth 2 -maxdepth 2 -name analysis.md 2>/dev/null | grep -E '/[0-9]{4}-[0-9]{2}-[0-9]{2}-[^/]+/analysis\.md$' | head -1)"
    if jq -e '.subtype == "error_max_budget_usd"' "$a" >/dev/null; then reasons+=("budget cap hit before completion"); fi
    if jq -e '.subtype == "error_max_turns"' "$a" >/dev/null; then reasons+=("turn cap hit before completion"); fi
    if [ -z "$doc" ] && jq -r '.text_last' "$a" | tr -d '\n*_ ' | grep -qE '\?$'; then asked=1; fi

    if [ "$c" = B1 ]; then
        if [ -z "$doc" ]; then reasons+=("no docs/research/<date>-<slug>/analysis.md")
        else
            first="$(head -1 "$doc")"
            printf '%s' "$first" | grep -qE '^Generated: [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*$' \
                || reasons+=("first line is not Generated: YYYY-MM-DD ($(printf '%s' "$first" | head -c 60))")
        fi
        [ -n "$(find "$fx" -name '.gate-armed' 2>/dev/null)" ] && reasons+=(".gate-armed exists in a rapid-tier run")
        [ "$pandoc_call" -eq 1 ] && reasons+=("an epub or pandoc tool call was attempted although no epub was requested")
        [ "$epubs" -gt 0 ] && reasons+=("an .epub file exists")
        if [ "${#reasons[@]}" -eq 0 ]; then verdict=PASS; fi
        if [ "$asked" -eq 1 ] && [ "${#reasons[@]}" -gt 0 ]; then reasons=("asked despite pre-confirmation" "${reasons[@]}"); fi
    else
        if [ "$pandoc_call" -eq 1 ]; then verdict=PASS; reasons+=("attempted pandoc or epub tool call observed")
        elif jq -e '.epub_text' "$a" >/dev/null; then verdict="PASS-weak"; reasons+=("no tool call, but the transcript states an epub or pandoc step")
        else
            reasons+=("no pandoc attempt and no epub step in the transcript")
            [ "$asked" -eq 1 ] && reasons=("asked despite pre-confirmation" "${reasons[@]}")
        fi
    fi
    local evidence
    evidence="analysis.md=$([ -n "$doc" ] && echo "${doc#"$fx"/}" || echo none); pandoc_attempt=$pandoc_call; epub_files=$epubs; gate_armed=$([ -n "$(find "$fx" -name '.gate-armed' 2>/dev/null)" ] && echo yes || echo no); bash_calls=$(jq '.bash_calls|length' "$a"); web_calls=$(jq '[.tool_names[]|select(.=="WebSearch" or .=="WebFetch")]|length' "$a"); turns=$(jq '.turns' "$a")"
    jq -nc --arg case "$c" --arg verdict "$verdict" --arg reasons "$(IFS=';'; echo "${reasons[*]:-}")" --arg evidence "$evidence" \
        '{case:$case, verdict:$verdict, reasons:$reasons, evidence:$evidence}' > "$dir/behavior.json"
}

# Run a kind's task list with a spend cap. Args: <kind>
run_kind() {
    local kind="$1" tasks budget fx dir id rep prompt meta inflight=0 n=0 stopped=0
    case "$kind" in
        triggers) tasks="$(trigger_tasks)"; budget="$CAP" ;;
        modes)    tasks="$(mode_tasks)";    budget="$CAP" ;;
        behavior) tasks="$(behavior_tasks)"; budget="$BCAP" ;;
    esac
    local count
    count="$(printf '%s\n' "$tasks" | grep -c .)"
    if [ "$DRY" -eq 1 ]; then
        echo "== dry-run $kind: $count runs, per-call cap \$$budget, worst case \$$(awk -v n="$count" -v b="$budget" 'BEGIN{printf "%.2f", n*b}')"
        printf '%s\n' "$tasks" | while IFS=$'\t' read -r id rep prompt meta; do
            [ -n "$id" ] || continue
            build_argv "$kind" "$prompt" "$budget"
            printf '  [%s rep %s] cd <fixture> && claude' "$id" "$rep"; printf ' %q' "${ARGV[@]}"; echo
        done
        return 0
    fi
    [ "$count" -gt 0 ] || { echo "no $kind runs selected" >&2; return 0; }
    [ "$RESUME" -eq 1 ] || { [ -d "$OUT/$kind${TAG:+-$TAG}" ] && rm -rf "$OUT/$kind${TAG:+-$TAG}"; }
    mkdir -p "$OUT/$kind${TAG:+-$TAG}"
    echo "== $kind: $count runs, per-call cap \$$budget, total cap \$$TOTAL (recorded so far \$$(spent_total))"
    while IFS=$'\t' read -r id rep prompt meta; do
        [ -n "$id" ] || continue
        dir="$OUT/$kind${TAG:+-$TAG}/$id-r$rep"; fx="$dir/fx"
        if [ "$RESUME" -eq 1 ] && [ -s "$dir/verdict.json" ]; then continue; fi
        # Wait for in-flight runs before judging the cap, so the check sees their real cost.
        if awk -v s="$(spent_total)" -v i="$inflight" -v b="$budget" -v t="$TOTAL" 'BEGIN{exit !(s+(i+1)*b>t)}'; then
            wait; inflight=0
            if awk -v s="$(spent_total)" -v b="$budget" -v t="$TOTAL" 'BEGIN{exit !(s+b>t)}'; then
                echo "STOP: the next run could take spend past \$$TOTAL (recorded \$$(spent_total)); $kind is incomplete" >&2
                stopped=1; break
            fi
        fi
        rm -rf "$dir"; mkdir -p "$dir"; make_fixture "$fx"
        (
            run_one "$kind" "$id" "$rep" "$prompt" "$fx" "$dir" "$budget" "$meta"
            if [ "$kind" = behavior ]; then
                grade_behavior "$dir" "$fx" "$id"
                jq -c --slurpfile b "$dir/behavior.json" '. + {behavior:$b[0]}' "$dir/verdict.json" > "$dir/verdict.tmp" && mv "$dir/verdict.tmp" "$dir/verdict.json"
            fi
            echo "   $kind $id r$rep: $(jq -r '"\(.status) fired=\(.fired | tostring) declared=\(.declared // "-") skills=\(.skills // [] | join(",")) cost=$\(.cost)"' "$dir/verdict.json")"
        ) &
        inflight=$((inflight+1)); n=$((n+1))
        if [ "$inflight" -ge "$JOBS" ]; then wait; inflight=0; fi
    done <<< "$tasks"
    wait
    echo "$kind: started $n runs; recorded spend now \$$(spent_total)"
    [ "$stopped" -eq 0 ] || return 4
    return 0
}

# ── summary ──────────────────────────────────────────────────────────────────────────────────────────────────────
# Wilson score interval, z = 1.96. Prints: K/N = P (95% CI L to H). Always an interval, never a bare rate.
wilson() {
    awk -v k="$1" -v n="$2" 'BEGIN{
        if (n == 0) { printf "0/0 (no runs)"; exit }
        z=1.96; p=k/n; d=1+z*z/n; c=(p+z*z/(2*n))/d; h=z*sqrt(p*(1-p)/n+z*z/(4*n*n))/d
        lo=c-h; hi=c+h; if (lo<0) lo=0; if (hi>1) hi=1
        printf "%d/%d = %.1f%% (Wilson 95%% CI %.1f%% to %.1f%%)", k, n, 100*p, 100*lo, 100*hi }'
}
meanci() {
    awk -v s="$1" -v q="$2" -v n="$3" 'BEGIN{
        if (n < 2) { printf "n/a (n=%d)", n; exit }
        m=s/n; v=(q-n*m*m)/(n-1); if (v<0) v=0; printf "%.0f (95%% CI +/- %.0f)", m, 1.96*sqrt(v/n) }'
}

summary() {
    command -v jq >/dev/null 2>&1 || { echo "jq missing" >&2; exit 2; }
    local files
    files="$(find "$OUT" -name verdict.json 2>/dev/null | sort)"
    [ -n "$files" ] || { echo "no verdicts under $OUT" >&2; exit 1; }
    local all
    all="$(printf '%s\n' "$files" | xargs cat | jq -s '.')"
    echo "## Spend and run counts"
    echo
    local spent runs errs
    spent="$(printf '%s' "$all" | jq '[.[].cost]|add // 0')"
    echo "- Total spend (sum of result total_cost_usd over $(printf '%s' "$all" | jq 'length') recorded runs): \$$spent"
    for k in triggers modes behavior; do
        runs="$(printf '%s' "$all" | jq --arg k "$k" '[.[]|select(.kind==$k)]|length')"
        errs="$(printf '%s' "$all" | jq --arg k "$k" '[.[]|select(.kind==$k and .status=="error")]|length')"
        echo "- $k: $runs runs, $errs errors (errors are excluded from every rate)"
    done
    echo "- Models seen: $(printf '%s' "$all" | jq -r '[.[].model // empty]|unique|join(", ")')"
    echo "- Variant under test, verified on every non-error run from the init event: $(printf '%s' "$all" | jq -r '[.[]|select(.status=="ok")|.copies[0]]|unique|join(", ")')"
    local e
    e="$(printf '%s' "$all" | jq -r '.[]|select(.status=="error")|"  - \(.kind) \(.id) r\(.rep): \(.error)"')"
    [ -n "$e" ] && { echo "- Error runs:"; echo "$e"; }

    local split n correct fn fired nfn nfired nmn nmfired
    echo
    echo "## Trigger accuracy (research-tools:research fires on the right queries)"
    for split in train heldout all; do
        read -r n correct fn fired nfn nfired nmn nmfired < <(printf '%s' "$all" | jq -r --arg s "$split" '
            [.[]|select(.kind=="triggers" and .status=="ok" and ($s=="all" or .split==$s))] as $r
            | [ ($r|length), ($r|map(select((.expect=="fire") == .fired))|length),
                ($r|map(select(.expect=="fire"))|length), ($r|map(select(.expect=="fire" and .fired))|length),
                ($r|map(select(.expect=="no-fire"))|length), ($r|map(select(.expect=="no-fire" and .fired))|length),
                ($r|map(select(.expect=="no-fire" and .near_miss))|length), ($r|map(select(.expect=="no-fire" and .near_miss and .fired))|length)
              ] | @tsv')
        echo
        echo "### split: $split"
        echo "- Accuracy: $(wilson "$correct" "$n")"
        echo "- Fire recall (fired when it should): $(wilson "$fired" "$fn")"
        echo "- Misses (did not fire when it should): $((fn-fired)) of $fn runs"
        echo "- False-fire rate (fired when it should not): $(wilson "$nfired" "$nfn")"
        echo "- False-fire rate on near-misses only: $(wilson "$nmfired" "$nmn")"
        local tk tq tm
        read -r tk tq tm < <(printf '%s' "$all" | jq -r --arg s "$split" '
            [.[]|select(.kind=="triggers" and .status=="ok" and ($s=="all" or .split==$s))] as $r
            | [ ($r|map(.tokens)|add // 0), ($r|map(.tokens*.tokens)|add // 0), ($r|map(.cost)|add // 0) ] | @tsv')
        echo "- Tokens per run, reported separately from accuracy: mean $(meanci "$tk" "$tq" "$n"); mean cost \$$(awk -v c="$tm" -v n="$n" 'BEGIN{printf "%.3f", n?c/n:0}')"
    done

    echo
    echo "### Competing skills (all trigger runs, all splits)"
    printf '%s' "$all" | jq -r "$alias_of"'
        [.[]|select(.kind=="triggers" and .status=="ok")] as $r
        | ( $r | map(select(.expect=="fire" and (.fired|not))) ) as $miss
        | ( $r | map(select(.expect=="no-fire" and .fired)) ) as $ff
        | "- Misses: \($miss|length) runs. Skill that fired instead, by name: \($miss | map(.others[]) | group_by(.) | map("\(.[0]) x\(length)") | join(", ") | if .=="" then "none recorded" else . end). Misses where no skill fired: \($miss|map(select(.skills|length==0))|length)",
          "- False fires: \($ff|length) runs. Other skills that also fired in them: \($ff | map(.others[]) | group_by(.) | map("\(.[0]) x\(length)") | join(", ") | if .=="" then "none" else . end)",
          "- Other skills fired on any trigger run, by name and run count: \($r | map(.others[]) | group_by(.) | map("\(.[0]) x\(length)") | join(", ") | if .=="" then "none" else . end)"'

    echo
    echo "### Per query (all splits; fired = runs where research-tools:research fired)"
    echo
    echo "| id | split | expect | nm | fired | other skills |"
    echo "|---|---|---|---|---|---|"
    printf '%s' "$all" | jq -r '[.[]|select(.kind=="triggers" and .status=="ok")] | group_by(.id)[]
        | "| \(.[0].id) | \(.[0].split) | \(.[0].expect) | \(.[0].near_miss) | \(map(select(.fired))|length)/\(length) | \(map(.others[])|unique|join(", ")) |"'

    echo
    echo "## Mode declaration (Phase 0): declared and routed, scored separately"
    echo
    echo "declared = the run states a mode at all. routed = the declared mode is the expected one (undeclared counts as not routed). Mode: line first, regex fallback."
    local tg sp decl rout rdecl lines
    for tg in $(printf '%s' "$all" | jq -r '[.[]|select(.kind=="modes")|.tag // ""]|unique|.[]'); do
        for sp in train heldout; do
            read -r n decl rout rdecl lines < <(printf '%s' "$all" | jq -r --arg t "$tg" --arg s "$sp" '
                [.[]|select(.kind=="modes" and .status=="ok" and ((.tag // "")==$t) and .split==$s)] as $r
                | [ ($r|length), ($r|map(select(.declared!="undeclared"))|length),
                    ($r|map(select(.declared==.expect_mode))|length),
                    ($r|map(select(.declared!="undeclared" and .declared==.expect_mode))|length),
                    ($r|map(select(.declared_line))|length) ] | @tsv')
            [ "$n" -gt 0 ] || continue
            echo
            echo "### variant: ${tg:-untagged}, split: $sp ($n runs)"
            echo "- Declared rate: $(wilson "$decl" "$n")"
            echo "- Routed accuracy (of all runs): $(wilson "$rout" "$n")"
            echo "- Routed among declared runs: $(wilson "$rdecl" "$decl")"
            echo "- Runs with the fixed Mode: line: $lines of $n"
        done
    done
    echo
    echo "| variant | id | expected | declared per run |"
    echo "|---|---|---|---|"
    printf '%s' "$all" | jq -r '[.[]|select(.kind=="modes" and .status=="ok")] | group_by([(.tag // ""),.id])[]
        | "| \(.[0].tag // "-") | \(.[0].id) | \(.[0].expect_mode) | \(map(.declared)|join(", ")) |"'

    echo
    echo "## Behavior (rapid tier)"
    echo
    printf '%s' "$all" | jq -r '.[]|select(.kind=="behavior")
        | "- \(.id): \(if .status=="error" then "ERROR " + .error else .behavior.verdict end). Evidence: \(.behavior.evidence // "n/a"). Reasons: \(.behavior.reasons // "n/a"). Cost $\(.cost), \(.turns) turns, stop \(.subtype)."'
}

# Re-run the CURRENT detector over recorded mode streams, so old and new runs are scored identically. Spends nothing.
# Keeps status and the recorded variant verification; takes tag from the directory name and split from modes.jsonl.
rescore() {
    local v d base tag id
    for v in "$OUT"/modes*/*/verdict.json; do
        [ -s "$v" ] || continue
        d="${v%/verdict.json}"; base="${d%/*}"; base="${base##*/}"; id="${d##*/}"; id="${id%-r*}"
        tag=""; case "$base" in modes-*) tag="${base#modes-}" ;; esac
        analyze_stream "$d/stream.jsonl" "$d/rescore.json"
        [ -s "$d/rescore.json" ] || { echo "rescore failed: $d" >&2; continue; }
        jq -c --slurpfile a "$d/rescore.json" --arg tag "$tag" --argjson split "$(jq -c --arg id "$id" 'select(.id==$id)|.split' "$MODES")" \
            '. + ($a[0]|del(.variant_ok,.copies,.model,.cost,.turns,.tokens)) + {tag:$tag, split:$split}' "$v" > "$d/verdict.tmp" && mv "$d/verdict.tmp" "$v"
    done
    echo "rescored with the current detector"
}

# ── dispatch ─────────────────────────────────────────────────────────────────────────────────────────────────────
RC=0
if [ "$DO_OFFLINE" -eq 1 ]; then
    offline_tier
    [ "$FAIL" -eq 0 ] || RC=1
fi
if [ "$DO_RESCORE" -eq 1 ]; then live_setup; rescore; exit $?; fi
if [ "$DO_SUMMARY" -eq 1 ]; then summary; exit $?; fi
if [ $((DO_TRIGGERS+DO_MODES+DO_BEHAVIOR)) -gt 0 ]; then
    live_setup
    if [ "$DRY" -eq 1 ]; then
        echo "plugin under test: $PLUGIN_REAL"
        echo "total cap \$$TOTAL, already recorded \$$(spent_total)"
    fi
    [ "$DO_TRIGGERS" -eq 1 ] && { run_kind triggers || RC=$?; }
    [ "$DO_MODES" -eq 1 ] && { run_kind modes || RC=$?; }
    [ "$DO_BEHAVIOR" -eq 1 ] && { run_kind behavior || RC=$?; }
    if [ "$DRY" -eq 1 ]; then
        t=0; m=0; b=0
        [ "$DO_TRIGGERS" -eq 1 ] && t="$(trigger_tasks | grep -c .)"
        [ "$DO_MODES" -eq 1 ] && m="$(mode_tasks | grep -c .)"
        [ "$DO_BEHAVIOR" -eq 1 ] && b="$(behavior_tasks | grep -c .)"
        echo "PLANNED SPEND: worst case \$$(awk -v t="$t" -v m="$m" -v b="$b" -v c="$CAP" -v bc="$BCAP" 'BEGIN{printf "%.2f", (t+m)*c+b*bc}') (per-call caps x runs);" \
             "rough expectation \$$(awk -v t="$t" -v m="$m" -v b="$b" 'BEGIN{printf "%.2f", t*0.12+m*0.25+b*1.5}') (guess, to be replaced by measured cost); total cap \$$TOTAL"
    else
        ran_ok="$(grep -rl --include=verdict.json '"status":"ok"' "$OUT" 2>/dev/null | wc -l | tr -d ' ')"
        if [ "$ran_ok" -eq 0 ]; then
            echo "the model run was requested but no run completed with a verified variant" >&2
            RC=1
        fi
    fi
fi
exit "$RC"
