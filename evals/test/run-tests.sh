#!/usr/bin/env bash
# run-tests.sh — regression suite for the ai-scoring evaluation set.
#
# Six layers:
#   0. FIXTURE SANITY  — the fixtures themselves are what they claim to be, checked without
#                        the harness so a fixture regression is never mistaken for a harness bug.
#   1. OFFLINE         — evals/harness/ makes no network calls (AC6).
#   2. PROVENANCE      — a document missing provider or prompt fails the loader by name (AC1).
#   3. CONTAMINATION   — rubric-term density per class, with the 1.0-per-100-words gate (AC3).
#   4. INTERVALS       — Wilson bounds on hand-verifiable inputs, and no bare rate in the report (AC5).
#   5. SPLIT + SEAL    — determinism from the seed, and single-use held-out enforcement (AC4).
#
# The suite runs the harness inside a MIRRORED fixture repo: a throwaway tree that reproduces the
# real repo's relative paths (evals/harness, evals/corpus/negative-generic, evals/corpus/negative-voiced,
# noah-writing-voice/validation/...) and is populated from evals/test/fixtures instead of from the real
# corpus. The shared contract fixes those paths but does not define a corpus-override flag, so mirroring
# is the only way to point the harness at fixtures without inventing interface the harness may not have.
# EVALS_ROOT and EVALS_CORPUS_ROOT are exported as well; a harness that honours them gets the same answer.
#
# A handful of assertions are about the SHIPPED corpus rather than the fixtures — word-count overlap and
# provenance. Those have three outcomes, and the difference matters:
#
#   PASS/FAIL  the assertion ran.
#   PENDING    it cannot run yet because evals/corpus holds no generated documents. That is the normal
#              state of a fresh checkout, so it is printed loudly and does NOT fail the run.
#   SKIP       it could not run for any other reason (a missing harness, a missing tool). Still fatal.
#
# Usage:  bash run-tests.sh
#         exit 0 = every executable assertion passed (pending assertions are fine)
#         exit 1 = something was skipped
#         exit N = N assertions failed
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVALS="$(cd "$HERE/.." && pwd)"
REPO="$(cd "$EVALS/.." && pwd)"
HARNESS="$EVALS/harness"
FIX="$HERE/fixtures"
PY="${PYTHON:-python3}"

CORPUS_REL="noah-writing-voice/validation/2026-05-23-corpus"
ART_REL="$CORPUS_REL/articles"
SCRIPTS_REL="$CORPUS_REL/scripts"
SKILL_REL="noah-writing-voice/skills/ai-scoring"
AISCORE="$REPO/$SCRIPTS_REL/ai_score.py"

# The canonical generated-corpus layout. evals/generate/generate.sh writes
# evals/corpus/negative-<class>/<provider>-<model>-<id>.md and the harness reads evals/corpus
# recursively, so these three paths are the contract. The mirrored fixture tree reproduces them
# exactly, which is the only way a fixture run and a production run can see the same shape.
EVAL_CORPUS_REL="evals/corpus"
MANIFEST_REL="$EVAL_CORPUS_REL/manifest.json"
GENERIC_REL="$EVAL_CORPUS_REL/negative-generic"
VOICED_REL="$EVAL_CORPUS_REL/negative-voiced"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/eval-tests.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

fails=0
skips=0
pendings=0
asserts=0
ok()   { asserts=$((asserts+1)); printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
bad()  { asserts=$((asserts+1)); fails=$((fails+1));  printf '  \033[31mFAIL\033[0m  %s\n' "$1"; }
skip() { asserts=$((asserts+1)); skips=$((skips+1));  printf '  \033[33mSKIP\033[0m  %s\n' "$1"; }

# pend — an assertion that cannot run until the corpus is generated. That is the expected state of
# a fresh checkout, so it is reported loudly and does not fail the run. Anything else that could not
# run is a skip, and a skip is still fatal.
pend() {
    asserts=$((asserts+1)); pendings=$((pendings+1))
    printf '%s\n' "$1" >> "$TMP/pending.txt"
    printf '  \033[36mPENDING\033[0m  %s\n' "$1"
}

HARNESS_PRESENT=1
for f in corpus.py stats.py split.py evaluate.py; do
    [[ -f "$HARNESS/$f" ]] || HARNESS_PRESENT=0
done

# ---------------------------------------------------------------------------
# Helpers

# density <dir> — "<aggregate> <worst-document>" rubric-term hits per 100 words over every .md in
# <dir>. Uses ai_score.py's term lists rather than the harness's, so a fixture regression is caught
# here without depending on the code under test.
density() {
    "$PY" - "$AISCORE" "$1" <<'PY'
import importlib.util, re, sys
from pathlib import Path

spec = importlib.util.spec_from_file_location("ai_score", sys.argv[1])
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

literal = list(mod.GENERIC_TRANSITIONS) + list(mod.BANNED_WORDS)
total_words = total_hits = 0
worst = 0.0
for path in sorted(Path(sys.argv[2]).glob("*.md")):
    body = mod.get_body(path.read_text())
    words = len(re.findall(r"\b\w+\b", body))
    hits = 0
    for term in literal:
        hits += len(re.findall(r"\b" + re.escape(term) + r"\b", body, re.IGNORECASE))
    for hedge in mod.HEDGE_PHRASES:
        hits += len(re.findall(hedge, body, re.IGNORECASE))
    total_words += words
    total_hits += hits
    if words:
        worst = max(worst, hits * 100.0 / words)
agg = total_hits * 100.0 / total_words if total_words else 0.0
print("%.2f %.2f" % (agg, worst))
PY
}

# class_densities <report-text-file> — the mean and max density the harness printed per class.
class_densities() {
    awk '/^[ \t]+(human|generic|voiced)[ \t]+n=/ {
        for (i = 1; i <= NF; i++) if ($i == "mean" || $i == "max") print $(i + 1)
    }' "$1"
}

# wcrange <dir> [<dir>...] — "min max" word count across every .md in the given dirs.
wcrange() {
    "$PY" - "$AISCORE" "$@" <<'PY'
import importlib.util, re, sys
from pathlib import Path

spec = importlib.util.spec_from_file_location("ai_score", sys.argv[1])
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

counts = []
for d in sys.argv[2:]:
    for path in sorted(Path(d).glob("*.md")):
        counts.append(len(re.findall(r"\b\w+\b", mod.get_body(path.read_text()))))
print("%d %d" % (min(counts), max(counts)) if counts else "0 0")
PY
}

# fm_fields <file> — space-separated top-level frontmatter keys.
fm_fields() {
    "$PY" - "$1" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
m = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
if not m:
    sys.exit(1)
keys = re.findall(r"^([A-Za-z_][A-Za-z0-9_]*):", m.group(1), re.MULTILINE)
print(" ".join(keys))
PY
}

# corpus_docs <root> — every .md under <root>, recursively, one absolute path per line. Prints
# nothing when <root> does not exist, which is how an ungenerated corpus reads.
corpus_docs() {
    "$PY" - "$1" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
if root.is_dir():
    for path in sorted(root.rglob("*.md")):
        print(path)
PY
}

build_tree() {   # $1 = destination root
    local root="$1"
    rm -rf "$root"
    mkdir -p "$root/evals/harness" "$root/evals/spec" "$root/$EVAL_CORPUS_REL" \
             "$root/$GENERIC_REL" "$root/$VOICED_REL" \
             "$root/$ART_REL" "$root/$SCRIPTS_REL" "$root/$SKILL_REL" \
             "$root/.git/objects" "$root/.git/refs"
    printf 'ref: refs/heads/main\n' > "$root/.git/HEAD"
    cp "$HARNESS"/*.py "$root/evals/harness/" 2>/dev/null
    cp "$AISCORE" "$root/$SCRIPTS_REL/"
    cp "$REPO/$SKILL_REL/SKILL.md" "$root/$SKILL_REL/"
    cp "$FIX/clean/articles/"*.md "$root/$ART_REL/"
    cp "$FIX/clean/generic/"*.md  "$root/$GENERIC_REL/"
    cp "$FIX/clean/voiced/"*.md   "$root/$VOICED_REL/"
    cp "$FIX/clean/topics.json"   "$root/evals/spec/topics.json"
}

hrun() {   # $1 = root, rest = evaluate.py argv
    local root="$1"; shift
    OUT="$(cd "$root" && EVALS_ROOT="$root" EVALS_CORPUS_ROOT="$root/$EVAL_CORPUS_REL" \
        "$PY" "$root/evals/harness/evaluate.py" "$@" 2>&1)"
    RC=$?
}

srun() {   # $1 = root, rest = split.py argv
    local root="$1"; shift
    OUT="$(cd "$root" && EVALS_ROOT="$root" EVALS_CORPUS_ROOT="$root/$EVAL_CORPUS_REL" \
        "$PY" "$root/evals/harness/split.py" "$@" 2>&1)"
    RC=$?
}

mkey() {   # $1 = manifest, $2 = dotted key — prints the value or MISSING
    "$PY" - "$1" "$2" <<'PY'
import json, sys
cur = json.load(open(sys.argv[1]))
for part in sys.argv[2].split("."):
    if not isinstance(cur, dict) or part not in cur:
        print("MISSING"); sys.exit(0)
    cur = cur[part]
print(cur)
PY
}

membership() {   # $1 = manifest — "cal1,cal2|held1,held2" by basename, sorted
    "$PY" - "$1" <<'PY'
import json, os, sys
d = json.load(open(sys.argv[1]))
cal = sorted(os.path.basename(x) for x in d.get("calibration", []))
held = sorted(os.path.basename(x) for x in d.get("held_out", []))
print(",".join(cal) + "|" + ",".join(held))
PY
}

first_held() {   # $1 = manifest, $2 = root — absolute path of the first held-out document
    "$PY" - "$1" "$2" <<'PY'
import json, os, sys
d = json.load(open(sys.argv[1]))
held = d.get("held_out") or []
if not held:
    sys.exit(1)
p = held[0]
for cand in (p, os.path.join(sys.argv[2], p), os.path.join(sys.argv[2], "evals", p)):
    if os.path.isabs(cand) and os.path.exists(cand):
        print(cand); sys.exit(0)
    if os.path.exists(cand):
        print(os.path.abspath(cand)); sys.exit(0)
sys.exit(1)
PY
}

# ---------------------------------------------------------------------------
echo "== 0. FIXTURE SANITY (no harness required) =="

REQUIRED_FIELDS="class provider model generated target_words source_article prompt"
missing_any=""
for f in "$FIX/clean/generic/"*.md "$FIX/clean/voiced/"*.md; do
    got="$(fm_fields "$f")" || { missing_any="$missing_any ${f##*/}:no-frontmatter"; continue; }
    for want in $REQUIRED_FIELDS; do
        case " $got " in
            *" $want "*) ;;
            *) missing_any="$missing_any ${f##*/}:$want" ;;
        esac
    done
done
[[ -z "$missing_any" ]] && ok "every clean negative carries all 7 contract frontmatter fields" \
    || bad "clean negatives missing fields:$missing_any"

got="$(fm_fields "$FIX/missing-provider/fixture-no-provider.md")"
case " $got " in *" provider "*) bad "missing-provider fixture still declares provider";; *) ok "missing-provider fixture omits exactly 'provider'";; esac
case " $got " in *" prompt "*) ok "missing-provider fixture keeps 'prompt' (isolates one field)";; *) bad "missing-provider fixture also lost prompt";; esac

got="$(fm_fields "$FIX/missing-prompt/fixture-no-prompt.md")"
case " $got " in *" prompt "*) bad "missing-prompt fixture still declares prompt";; *) ok "missing-prompt fixture omits exactly 'prompt'";; esac
case " $got " in *" provider "*) ok "missing-prompt fixture keeps 'provider' (isolates one field)";; *) bad "missing-prompt fixture also lost provider";; esac

for pair in "articles:human" "generic:generic" "voiced:voiced"; do
    dir="${pair%%:*}"; label="${pair#*:}"
    read -r dagg dmax <<<"$(density "$FIX/clean/$dir")"
    if awk -v a="$dagg" -v m="$dmax" 'BEGIN { exit !(a <= 0.55 && m <= 0.55) }'; then
        ok "clean fixture class '$label' density $dagg (worst document $dmax) is inside the real-writing band 0.00-0.55"
    else
        bad "clean fixture class '$label' density $dagg (worst document $dmax) is outside 0.00-0.55"
    fi
done

# The band is 5.0-12.0, not the retired fixtures' measured 7.14-8.33. The assertion is that these
# fixtures are unmistakably stuffed — an order of magnitude past real writing's 0.00-0.55 — not that
# they reproduce a historical measurement to two decimal places.
read -r dagg dmax <<<"$(density "$FIX/contaminated")"
if awk -v a="$dagg" 'BEGIN { exit !(a >= 5.0 && a <= 12.0) }'; then
    ok "contaminated fixture density $dagg is inside the stuffed band 5.0-12.0, far above real writing's 0.00-0.55"
else
    bad "contaminated fixture density $dagg is outside the stuffed band 5.0-12.0 and no longer models the failure"
fi

read -r hmin hmax <<<"$(wcrange "$FIX/clean/articles")"
read -r nmin nmax <<<"$(wcrange "$FIX/clean/generic" "$FIX/clean/voiced")"
if [[ "$hmin" -le "$nmax" && "$nmin" -le "$hmax" ]]; then
    ok "fixture word counts overlap: human [$hmin,$hmax] vs negative [$nmin,$nmax]"
else
    bad "fixture word counts separate the classes: human [$hmin,$hmax] vs negative [$nmin,$nmax]"
fi

# AC1's distribution claim is about the shipped corpus, not the fixtures. Check it when the corpus
# exists; say so plainly when it does not, rather than passing on fixture evidence.
REAL_GEN="$REPO/$GENERIC_REL"
REAL_VOI="$REPO/$VOICED_REL"

# A half-generated corpus must never read as "not started". The harness decides class membership from
# each document's class: field, so agreeing with it here means asking it, not globbing directories.
REAL_ANY=0
if compgen -G "$REPO/$EVAL_CORPUS_REL/**/*.md" > /dev/null 2>&1 ||
    [[ -n "$(find "$REPO/$EVAL_CORPUS_REL" -name '*.md' -type f 2>/dev/null | head -1)" ]]; then
    REAL_ANY=1
fi

if [[ "$REAL_ANY" -eq 1 ]]; then
    hrun "$REPO" --contamination
    if [[ "$RC" -eq 0 ]]; then
        ok "shipped corpus passes the harness contamination gate"
    else
        bad "shipped corpus FAILS the harness contamination gate (rc=$RC) :: $(printf '%s' "$OUT" | grep -m1 '^RESULT:')"
    fi
fi

if compgen -G "$REAL_GEN/*.md" > /dev/null && compgen -G "$REAL_VOI/*.md" > /dev/null; then
    read -r rhmin rhmax <<<"$(wcrange "$REPO/$ART_REL")"
    read -r rnmin rnmax <<<"$(wcrange "$REAL_GEN" "$REAL_VOI")"
    if [[ "$rhmin" -le "$rnmax" && "$rnmin" -le "$rhmax" ]]; then
        ok "shipped corpus word counts overlap: human [$rhmin,$rhmax] vs negative [$rnmin,$rnmax]"
    else
        bad "shipped corpus word counts separate the classes: human [$rhmin,$rhmax] vs negative [$rnmin,$rnmax]"
    fi
elif [[ "$REAL_ANY" -eq 1 ]]; then
    bad "shipped corpus is half generated — documents exist under $EVAL_CORPUS_REL but one class is empty"
else
    pend "shipped-corpus word-count overlap — $GENERIC_REL and $VOICED_REL hold no documents yet"
fi

# ---------------------------------------------------------------------------
echo "== 1. OFFLINE — the harness never touches the network =="

if [[ "$HARNESS_PRESENT" -eq 0 ]]; then
    skip "harness sources contain no network primitives — evals/harness/*.py not on disk"
else
    hits="$(grep -nE '\b(urllib|urlopen|https?|httpx|requests|socket|curl|aiohttp)\b' "$HARNESS"/*.py || true)"
    [[ -z "$hits" ]] && ok "no harness source references urllib/http/requests/socket/curl" \
        || bad "harness references a network primitive: $(printf '%s' "$hits" | head -3 | tr '\n' ' ')"
fi

# ---------------------------------------------------------------------------
echo "== 2. PROVENANCE — a document without provenance is not evidence =="

if [[ "$HARNESS_PRESENT" -eq 0 ]]; then
    skip "loader names the file and 'provider' — harness not on disk"
    skip "loader names the file and 'prompt' — harness not on disk"
    skip "a fully-provenanced corpus loads without error — harness not on disk"
else
    build_tree "$TMP/prov-a"
    cp "$FIX/missing-provider/fixture-no-provider.md" "$TMP/prov-a/$GENERIC_REL/"
    hrun "$TMP/prov-a" --contamination
    if [[ "$RC" -ne 0 ]] \
        && printf '%s' "$OUT" | grep -qF 'fixture-no-provider.md' \
        && printf '%s' "$OUT" | grep -qi 'provider'; then
        ok "missing provider -> non-zero exit, message names the file and the field"
    else
        bad "missing provider -> rc=$RC, want non-zero naming fixture-no-provider.md + provider :: $(printf '%s' "$OUT" | head -2 | tr '\n' ' ')"
    fi

    build_tree "$TMP/prov-b"
    cp "$FIX/missing-prompt/fixture-no-prompt.md" "$TMP/prov-b/$VOICED_REL/"
    hrun "$TMP/prov-b" --contamination
    if [[ "$RC" -ne 0 ]] \
        && printf '%s' "$OUT" | grep -qF 'fixture-no-prompt.md' \
        && printf '%s' "$OUT" | grep -qi 'prompt'; then
        ok "missing prompt -> non-zero exit, message names the file and the field"
    else
        bad "missing prompt -> rc=$RC, want non-zero naming fixture-no-prompt.md + prompt :: $(printf '%s' "$OUT" | head -2 | tr '\n' ' ')"
    fi

    build_tree "$TMP/prov-ok"
    hrun "$TMP/prov-ok" --contamination
    [[ "$RC" -eq 0 ]] && ok "fully-provenanced corpus loads clean (rc=0)" \
        || bad "clean corpus rejected (rc=$RC) :: $(printf '%s' "$OUT" | head -3 | tr '\n' ' ')"
fi

# The assertions above prove the loader REJECTS a broken document. They say nothing about the
# documents that actually ship, because they run against throwaway fixtures. These two run against
# the real evals/corpus, so a generated file with mangled frontmatter cannot reach main unchecked.
REAL_DOCS="$TMP/real-docs.txt"
corpus_docs "$REPO/$EVAL_CORPUS_REL" > "$REAL_DOCS"
REAL_N="$(awk 'END { print NR + 0 }' "$REAL_DOCS")"

if [[ "$REAL_N" -eq 0 ]]; then
    pend "shipped corpus carries the 7 contract provenance fields — $EVAL_CORPUS_REL holds no documents yet"
    pend "shipped corpus loads through corpus.load_generated_document — $EVAL_CORPUS_REL holds no documents yet"
else
    real_missing=""
    while IFS= read -r f; do
        [[ -n "$f" ]] || continue
        got="$(fm_fields "$f")" || { real_missing="$real_missing ${f##*/}:no-frontmatter"; continue; }
        for want in $REQUIRED_FIELDS; do
            case " $got " in
                *" $want "*) ;;
                *) real_missing="$real_missing ${f##*/}:$want" ;;
            esac
        done
    done < "$REAL_DOCS"
    [[ -z "$real_missing" ]] \
        && ok "all $REAL_N shipped document(s) carry the 7 contract provenance fields" \
        || bad "shipped document(s) missing provenance fields:$real_missing"

    if [[ "$HARNESS_PRESENT" -eq 0 ]]; then
        skip "shipped corpus loads through corpus.load_generated_document — harness not on disk"
    else
        # corpus.py defines a dataclass, so the module has to be in sys.modules before exec_module
        # or @dataclass cannot resolve its own module. Without that the loader raises at import,
        # prints nothing on stdout, and this assertion passes for the wrong reason.
        REJECTS="$("$PY" - "$HARNESS/corpus.py" "$REPO/$EVAL_CORPUS_REL" 2>&1 <<'PY'
import importlib.util, sys
from pathlib import Path

spec = importlib.util.spec_from_file_location("corpus", sys.argv[1])
mod = importlib.util.module_from_spec(spec)
sys.modules["corpus"] = mod
spec.loader.exec_module(mod)

rejected = []
for path in sorted(Path(sys.argv[2]).rglob("*.md")):
    try:
        mod.load_generated_document(path)
    except Exception as exc:
        rejected.append("%s: %s" % (path.name, " ".join(str(exc).split())))
print("\n".join(rejected[:4]))
PY
)"
        LOAD_RC=$?
        if [[ "$LOAD_RC" -ne 0 ]]; then
            bad "shipped-corpus loader check could not run (rc=$LOAD_RC) :: $(printf '%s' "$REJECTS" | tail -2 | tr '\n' ' ')"
        elif [[ -z "$REJECTS" ]]; then
            ok "all $REAL_N shipped document(s) load through corpus.load_generated_document"
        else
            bad "shipped document rejected by the loader -> $(printf '%s' "$REJECTS" | head -2 | tr '\n' ' ')"
        fi
    fi
fi

# ---------------------------------------------------------------------------
echo "== 3. CONTAMINATION — negatives must not be written out of the answer key =="

if [[ "$HARNESS_PRESENT" -eq 0 ]]; then
    skip "clean corpus: --contamination exits 0 and reports per class — harness not on disk"
    skip "clean corpus: every reported density lands in 0.00-0.55 — harness not on disk"
    skip "stuffed corpus: --contamination exits 1 — harness not on disk"
    skip "stuffed corpus: reported density exceeds the 1.0 ceiling — harness not on disk"
else
    build_tree "$TMP/clean"
    hrun "$TMP/clean" --contamination
    CLEAN_OUT="$OUT"
    [[ "$RC" -eq 0 ]] && ok "clean corpus: --contamination exits 0" \
        || bad "clean corpus: --contamination exits $RC :: $(printf '%s' "$OUT" | head -3 | tr '\n' ' ')"

    named=1
    for cls in human generic voiced; do
        printf '%s' "$CLEAN_OUT" | grep -qi "$cls" || named=0
    done
    [[ "$named" -eq 1 ]] && ok "clean corpus: report names all three classes (human, generic, voiced)" \
        || bad "clean corpus: a class is absent from the contamination report :: $(printf '%s' "$CLEAN_OUT" | head -6 | tr '\n' ' ')"

    printf '%s\n' "$CLEAN_OUT" > "$TMP/clean-contam.txt"
    vals="$(class_densities "$TMP/clean-contam.txt")"
    over="$(printf '%s\n' "$vals" | awk '$1 > 0.55 { print; exit }')"
    if [[ -z "$vals" ]]; then
        bad "clean corpus: no per-class density line found in the contamination report"
    elif [[ -z "$over" ]]; then
        ok "clean corpus: every per-class density stays inside 0.00-0.55 ($(printf '%s' "$vals" | tr '\n' ' '))"
    else
        bad "clean corpus: reported a density of $over, above the real-writing band"
    fi

    build_tree "$TMP/dirty"
    cp "$FIX/contaminated/fixture-stuffed-01.md" "$TMP/dirty/$GENERIC_REL/"
    cp "$FIX/contaminated/fixture-stuffed-02.md" "$TMP/dirty/$GENERIC_REL/"
    cp "$FIX/contaminated/fixture-stuffed-03.md" "$TMP/dirty/$VOICED_REL/"
    hrun "$TMP/dirty" --contamination
    [[ "$RC" -eq 1 ]] && ok "stuffed corpus: --contamination exits 1 (gate failure)" \
        || bad "stuffed corpus: --contamination exits $RC, want 1 :: $(printf '%s' "$OUT" | head -3 | tr '\n' ' ')"

    printf '%s\n' "$OUT" > "$TMP/dirty-contam.txt"
    big="$(class_densities "$TMP/dirty-contam.txt" | awk '$1 > 1.0 { print; exit }')"
    [[ -n "$big" ]] && ok "stuffed corpus: a per-class density of $big is reported above the 1.0 ceiling" \
        || bad "stuffed corpus: no per-class density above 1.0 :: $(printf '%s' "$OUT" | head -8 | tr '\n' ' ')"
fi

# ---------------------------------------------------------------------------
echo "== 4. INTERVALS — no rate is reported without one =="

if [[ "$HARNESS_PRESENT" -eq 0 ]]; then
    skip "Wilson 0/10 = [0.0000, ~0.2775] — harness not on disk"
    skip "Wilson 5/10 = [0.2366, 0.7634] — harness not on disk"
    skip "Wilson 10/10 upper bound clamps at 1.0 — harness not on disk"
    skip "--report emits no bare percentage — harness not on disk"
    skip "--report states the sample size a tighter interval would need — harness not on disk"
    skip "an absent negative class is refused and named — harness not on disk"
    skip "--report refuses when split documents vanish — harness not on disk"
else
    WOUT="$("$PY" - "$HARNESS/stats.py" <<'PY'
import importlib.util, sys

spec = importlib.util.spec_from_file_location("stats", sys.argv[1])
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

fn = None
for name in ("wilson", "wilson_interval", "wilson_score_interval", "wilson_ci", "ci", "interval"):
    cand = getattr(mod, name, None)
    if callable(cand):
        fn = cand
        break
if fn is None:
    for name, cand in vars(mod).items():
        if callable(cand) and "wilson" in name.lower():
            fn = cand
            break
if fn is None:
    print("NO_WILSON_FN")
    sys.exit(0)


def bounds(k, n):
    r = fn(k, n)
    if isinstance(r, dict):
        vals = [float(v) for v in r.values() if isinstance(v, (int, float))]
    else:
        vals = [float(v) for v in r]
    return min(vals), max(vals)


for k, n in ((0, 10), (5, 10), (10, 10)):
    lo, hi = bounds(k, n)
    print("%d %d %.6f %.6f" % (k, n, lo, hi))
PY
)"
    if printf '%s' "$WOUT" | grep -q 'NO_WILSON_FN'; then
        bad "stats.py exposes no Wilson interval function"
        bad "stats.py Wilson 5/10 — not callable"
        bad "stats.py Wilson 10/10 — not callable"
    else
        check_w() {   # $1 k, $2 n, $3 want_lo, $4 want_hi, $5 label
            local line lo hi
            line="$(printf '%s\n' "$WOUT" | awk -v k="$1" -v n="$2" '$1==k && $2==n { print $3, $4 }')"
            if [[ -z "$line" ]]; then bad "$5 — stats.py returned nothing for ($1,$2)"; return; fi
            read -r lo hi <<<"$line"
            if awk -v lo="$lo" -v hi="$hi" -v wl="$3" -v wh="$4" \
                'BEGIN { exit !((lo-wl < 0.0005 && wl-lo < 0.0005) && (hi-wh < 0.0005 && wh-hi < 0.0005)) }'; then
                ok "$5 (got [$lo, $hi])"
            else
                bad "$5 — got [$lo, $hi], want [$3, $4]"
            fi
        }
        check_w 0  10 0.000000 0.277533 "Wilson 95% for 0/10 is [0.0000, 0.2775]"
        check_w 5  10 0.236593 0.763407 "Wilson 95% for 5/10 is [0.2366, 0.7634]"
        check_w 10 10 0.722467 1.000000 "Wilson 95% for 10/10 clamps the upper bound at 1.0"
    fi

    build_tree "$TMP/report"
    srun "$TMP/report" --seed 42
    hrun "$TMP/report" --report
    REPORT_RC="$RC"
    printf '%s\n' "$OUT" > "$TMP/report.txt"
    if [[ "$REPORT_RC" -ne 0 ]]; then
        bad "--report exits $REPORT_RC on a clean corpus :: $(printf '%s' "$OUT" | head -3 | tr '\n' ' ')"
        bad "--report bare-rate scan — report did not run"
        bad "--report required-sample-size statement — report did not run"
    else
        ok "--report exits 0 on a clean, fully-provenanced corpus"
        BARE="$("$PY" - "$TMP/report.txt" <<'PY'
import re, sys

INTERVAL = re.compile(r"[\[\(][^\]\)]*\d[^\]\)]*[,–—-][^\]\)]*\d[^\]\)]*[\]\)]")
offenders = []
for i, line in enumerate(open(sys.argv[1]), 1):
    probe = re.sub(r"95\s*%", "", line)
    has_pct = re.search(r"\d+(?:\.\d+)?\s*%", probe)
    has_dec_rate = re.search(r"\brate\b", line, re.IGNORECASE) and re.search(r"\d+\.\d+", probe)
    if not (has_pct or has_dec_rate):
        continue
    if INTERVAL.search(line) or re.search(r"\bCI\b", line) or "±" in line:
        continue
    offenders.append("%d: %s" % (i, line.rstrip()))
print("\n".join(offenders[:4]))
PY
)"
        [[ -z "$BARE" ]] && ok "--report: every reported rate carries an interval" \
            || bad "--report: bare rate with no interval -> $(printf '%s' "$BARE" | head -2 | tr '\n' ' ')"

        if printf '%s' "$OUT" | tr '\n' ' ' | grep -qiE '(needs?|requires?|reaching)[^.]{0,160}(n *= *[0-9]+|[0-9]+ +(more +)?documents?|[0-9]+ +samples?)'; then
            ok "--report states how many documents a tighter interval would need"
        else
            bad "--report never states the sample size a tighter interval would need"
        fi
    fi

    # AC2. --contamination is the gate CI runs, so it must not green-light a corpus that is
    # missing an entire negative class. corpus.require_classes() already raises the right error;
    # the contamination command needs to call it.
    build_tree "$TMP/noclass"
    rm -rf "$TMP/noclass/$VOICED_REL"
    hrun "$TMP/noclass" --contamination
    if [[ "$RC" -ne 0 ]] && printf '%s' "$OUT" | grep -qi 'voiced'; then
        ok "--contamination refuses (rc=$RC) and names the absent 'voiced' class"
    else
        bad "--contamination passed (rc=$RC) a corpus with no voiced documents :: $(printf '%s' "$OUT" | grep -i voiced | head -1)"
    fi

    build_tree "$TMP/noclass2"
    srun "$TMP/noclass2" --seed 42
    rm -rf "$TMP/noclass2/$VOICED_REL"
    hrun "$TMP/noclass2" --report
    if [[ "$RC" -ne 0 ]] && printf '%s' "$OUT" | grep -qi 'voiced'; then
        ok "--report refuses (rc=$RC) when the voiced documents it split over are gone"
    else
        bad "--report with voiced removed -> rc=$RC, want non-zero naming voiced :: $(printf '%s' "$OUT" | head -2 | tr '\n' ' ')"
    fi
fi

# ---------------------------------------------------------------------------
echo "== 5. SPLIT DETERMINISM AND SEAL ENFORCEMENT =="

if [[ "$HARNESS_PRESENT" -eq 0 ]]; then
    skip "split.py writes the contract manifest shape — harness not on disk"
    skip "same seed twice gives identical membership — harness not on disk"
    skip "calibration and held_out partition the corpus — harness not on disk"
    skip "a different seed gives different membership — harness not on disk"
    skip "first --held-out run succeeds and burns the seal — harness not on disk"
    skip "second --held-out run without --break-seal exits non-zero — harness not on disk"
    skip "--break-seal permits the second run — harness not on disk"
    skip "editing a held-out document invalidates the seal hash — harness not on disk"
    skip "evaluate.py rejects an unknown flag with exit 2 — harness not on disk"
    skip "split.py rejects an unknown flag with exit 2 — harness not on disk"
else
    build_tree "$TMP/s1"
    srun "$TMP/s1" --seed 42
    M1="$TMP/s1/$MANIFEST_REL"
    if [[ "$RC" -eq 0 && -f "$M1" ]]; then
        shape_ok=1
        for key in seed calibration held_out seal.sha256 seal.uses seal.sealed; do
            [[ "$(mkey "$M1" "$key")" == "MISSING" ]] && shape_ok=0
        done
        [[ "$(mkey "$M1" seed)" == "42" ]] || shape_ok=0
        [[ "$shape_ok" -eq 1 ]] && ok "split.py --seed 42 writes $MANIFEST_REL with seed, both lists, and a seal" \
            || bad "manifest is missing a contract key or records the wrong seed"
    else
        bad "split.py --seed 42 -> rc=$RC, manifest at $MANIFEST_REL not written :: $(printf '%s' "$OUT" | head -2 | tr '\n' ' ')"
    fi

    if [[ -f "$M1" ]]; then
        MEM42A="$(membership "$M1")"
        build_tree "$TMP/s2"; srun "$TMP/s2" --seed 42
        MEM42B="$(membership "$TMP/s2/$MANIFEST_REL")"
        [[ "$MEM42A" == "$MEM42B" ]] && ok "seed 42 twice gives identical calibration/held-out membership" \
            || bad "seed 42 is not deterministic: '$MEM42A' vs '$MEM42B'"

        PART="$("$PY" - "$M1" "$TMP/s1" <<'PY'
import json, os, sys
from pathlib import Path

d = json.load(open(sys.argv[1]))
cal = set(os.path.basename(x) for x in d.get("calibration", []))
held = set(os.path.basename(x) for x in d.get("held_out", []))
if cal & held:
    print("OVERLAP " + ",".join(sorted(cal & held)))
elif not cal or not held:
    print("EMPTY-SIDE")
else:
    print("OK %d %d" % (len(cal), len(held)))
PY
)"
        case "$PART" in
            OK*) ok "calibration and held_out are disjoint and both non-empty ($PART)" ;;
            *)   bad "split partition is wrong: $PART" ;;
        esac

        DIFF_SEED=""
        for s in 7 99 12345; do
            build_tree "$TMP/s-$s"; srun "$TMP/s-$s" --seed "$s"
            if [[ -f "$TMP/s-$s/$MANIFEST_REL" ]] && [[ "$(membership "$TMP/s-$s/$MANIFEST_REL")" != "$MEM42A" ]]; then
                DIFF_SEED="$s"; break
            fi
        done
        [[ -n "$DIFF_SEED" ]] && ok "seed $DIFF_SEED produces a different split from seed 42" \
            || bad "seeds 7, 99 and 12345 all reproduce the seed-42 split — the seed is not wired in"
    else
        bad "seed determinism — no manifest to compare"
        bad "split partition — no manifest to inspect"
        bad "seed sensitivity — no manifest to compare"
    fi

    build_tree "$TMP/seal"
    srun "$TMP/seal" --seed 42
    SM="$TMP/seal/$MANIFEST_REL"
    hrun "$TMP/seal" --held-out
    if [[ "$RC" -eq 0 ]]; then
        uses="$(mkey "$SM" seal.uses)"
        if [[ "$uses" != "MISSING" && "$uses" -ge 1 ]]; then
            ok "first --held-out run succeeds and increments seal.uses to $uses"
        else
            bad "first --held-out run succeeded but seal.uses is '$uses' — the seal was not burned"
        fi
    else
        bad "first --held-out run on a fresh seal -> rc=$RC, want 0 :: $(printf '%s' "$OUT" | head -2 | tr '\n' ' ')"
    fi

    hrun "$TMP/seal" --held-out
    if [[ "$RC" -ne 0 ]] && printf '%s' "$OUT" | grep -qiE 'seal|break-seal|already|uses'; then
        ok "second --held-out run without --break-seal exits $RC and states the reason"
    else
        bad "second --held-out run -> rc=$RC with no stated reason :: $(printf '%s' "$OUT" | head -2 | tr '\n' ' ')"
    fi

    hrun "$TMP/seal" --held-out --break-seal
    [[ "$RC" -eq 0 ]] && ok "--break-seal permits the second held-out run (rc=0)" \
        || bad "--break-seal still refused (rc=$RC) :: $(printf '%s' "$OUT" | head -2 | tr '\n' ' ')"

    build_tree "$TMP/tamper"
    srun "$TMP/tamper" --seed 42
    TM="$TMP/tamper/$MANIFEST_REL"
    VICTIM="$(first_held "$TM" "$TMP/tamper" 2>/dev/null)"
    if [[ -n "$VICTIM" && -f "$VICTIM" ]]; then
        printf '\nAn edit made after the split was sealed.\n' >> "$VICTIM"
        hrun "$TMP/tamper" --held-out
        if [[ "$RC" -ne 0 ]] && printf '%s' "$OUT" | grep -qiE 'hash|seal|integrity|tamper|changed|modif'; then
            ok "editing a held-out document breaks the seal hash and the harness fails loudly (rc=$RC)"
        else
            bad "edited held-out document -> rc=$RC with no integrity complaint :: $(printf '%s' "$OUT" | head -2 | tr '\n' ' ')"
        fi
    else
        bad "seal hash test — could not resolve a held-out document path from the manifest"
    fi

    hrun "$TMP/clean" --not-a-real-flag
    [[ "$RC" -eq 2 ]] && ok "evaluate.py rejects an unknown flag with exit 2 (usage error)" \
        || bad "evaluate.py --not-a-real-flag -> rc=$RC, want 2"

    srun "$TMP/clean" --not-a-real-flag
    [[ "$RC" -eq 2 ]] && ok "split.py rejects an unknown flag with exit 2 (usage error)" \
        || bad "split.py --not-a-real-flag -> rc=$RC, want 2"
fi

# ---------------------------------------------------------------------------
echo
printf 'assertions: %d   failed: %d   pending: %d   skipped: %d\n' "$asserts" "$fails" "$pendings" "$skips"

# Pending is not a failure state. It is the corpus not existing yet, printed loudly so nobody reads
# a green run as evidence that the shipped documents were checked.
if [[ "$pendings" -gt 0 ]]; then
    printf '\n\033[36m%d ASSERTION(S) PENDING\033[0m — waiting on a generated corpus, not a defect:\n' "$pendings"
    while IFS= read -r line; do
        printf '  \033[36mPENDING\033[0m  %s\n' "$line"
    done < "$TMP/pending.txt"
    printf '  Run  bash evals/generate/generate.sh --execute  to generate the corpus and these will run.\n'
fi

if [[ "$HARNESS_PRESENT" -eq 0 ]]; then
    printf '\n\033[33mHARNESS NOT PRESENT\033[0m — evals/harness/{corpus,stats,split,evaluate}.py missing; %d assertions skipped\n' "$skips"
fi

if [[ "$fails" -eq 0 && "$skips" -eq 0 ]]; then
    if [[ "$pendings" -eq 0 ]]; then
        printf '\n\033[32mALL TESTS PASSED\033[0m\n'
    else
        printf '\n\033[32mALL EXECUTABLE TESTS PASSED\033[0m — %d assertion(s) pending a generated corpus\n' "$pendings"
    fi
    exit 0
fi
if [[ "$fails" -eq 0 ]]; then
    printf '\n\033[33m%d ASSERTION(S) SKIPPED\033[0m — could not run for a reason other than a missing corpus\n' "$skips"
    exit 1
fi
printf '\n\033[31m%d TEST(S) FAILED\033[0m\n' "$fails"
exit "$fails"
