#!/usr/bin/env bash
# run-tests.sh — regression suite for the design-doc template validator.
#
# Four layers:
#   1. DEFECT FIXTURES   — documents the validator must reject (exit 1), each
#                          asserting the specific ERROR that drives the verdict.
#   2. ADVISORY FIXTURES — documents that PASS (exit 0) while printing an
#                          ADVISORY. Advisories never change the exit code.
#   3. REAL DIRECTIVES   — verbatim copies of the three 2026-08-20 directives.
#                          Two live in a sibling repo, so CI can only see them
#                          here. All three must exit 0.
#   4. USAGE             — argument and path errors exit 2, distinct from a
#                          validation failure.
#
# Usage:  bash run-tests.sh        (exit 0 = all pass, non-zero = count of failures)
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$(cd "$HERE/.." && pwd)"
V="$SKILL/scripts/validate.sh"
FX="$HERE/fixtures"

fails=0
ok()  { printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fails=$((fails + 1)); }
run() { OUT="$("$V" "$@" 2>&1)"; RC=$?; }

first_line() { printf '%s' "$OUT" | head -1; }
count()      { printf '%s' "$OUT" | grep -cE "$1"; }
want_rc()    { [ "$RC" -eq "$1" ] && ok "$2" || bad "$2 — want rc=$1, got rc=$RC :: $OUT"; }
want_grep()  { printf '%s' "$OUT" | grep -qF "$1" && ok "$2" || bad "$2 — missing '$1' :: $OUT"; }

want_one_error() {
    local n
    n="$(count '^ERROR:')"
    [ "$n" -eq 1 ] && ok "$1 reports exactly one error" || bad "$1 reported $n errors, want 1"
}

# $1 = fixture path, $2 = expected rc, $3 = pattern that must appear, $4 = label
expect() {
    run "$1"
    if [ "$RC" -eq "$2" ] && printf '%s' "$OUT" | grep -qF "$3"; then
        ok "$4"
    else
        bad "$4 — want rc=$2 + '$3'; got rc=$RC :: $(first_line)"
    fi
}

if [ -x "$V" ]; then
    ok "validate.sh is executable"
else
    bad "validate.sh is not executable — run: chmod +x $V"
fi

# ---------------------------------------------------------------------------
echo "== 1. DEFECT FIXTURES — the validator must reject these (rc=1) =="

expect "$FX/missing-tldr.md"             1 "ERROR: no tl;dr."            "missing-tldr -> rc=1, names the missing tl;dr"
expect "$FX/tldr-as-heading.md"          1 "ERROR: tl;dr is a heading"   "tldr-as-heading -> rc=1, distinguishes heading from lead line"
expect "$FX/tldr-buried.md"              1 "ERROR: tl;dr is buried"      "tldr-buried -> rc=1, prose above the tl;dr is not a lead line"
expect "$FX/missing-required-section.md" 1 "'## Non-Goals'"              "missing-required-section -> rc=1, names Non-Goals"
expect "$FX/no-outcome.md"               1 "ERROR: no outcome section."  "no-outcome -> rc=1, demands Goals or Acceptance criteria"
expect "$FX/fenced-heading.md"           1 "'## Non-Goals'"              "fenced-heading -> rc=1, a heading inside a code fence earns no credit"

# A buried tl;dr is a different defect from a missing one, and the author needs
# both line numbers to fix it: where the tl;dr is, and what displaced it.
run "$FX/tldr-buried.md"
want_grep 'tl;dr is buried (line 8)'     "tldr-buried -> error names the tl;dr's current line"
want_grep 'opens the document at line 5' "tldr-buried -> error names the line that displaced it"
want_grep 'Move the'                     "tldr-buried -> error says what to do about it"
want_one_error tldr-buried

# Every rejection ends in a FAIL line the reader can act on.
for f in missing-tldr tldr-as-heading tldr-buried missing-required-section no-outcome fenced-heading; do
    run "$FX/$f.md"
    printf '%s' "$OUT" | grep -qE '^FAIL: .*error\(s\)' \
        && ok "$f prints a FAIL verdict line" \
        || bad "$f printed no FAIL verdict line :: $(first_line)"
done

# A defect fixture must never be rejected for a reason it was not built to test.
run "$FX/missing-required-section.md"
want_one_error missing-required-section

# ---------------------------------------------------------------------------
echo "== 2. ADVISORY FIXTURES — pass (rc=0) while printing an ADVISORY =="

expect "$FX/both-outcomes.md" 0 "ADVISORY: both '## Goals'" \
    "both-outcomes -> rc=0 with an advisory, not an error"
expect "$FX/trailing-after-decisions.md" 0 "'## Decisions requested'" \
    "trailing-after-decisions -> rc=0 with an ordering advisory"

for f in both-outcomes trailing-after-decisions; do
    run "$FX/$f.md"
    printf '%s' "$OUT" | grep -qE '^ERROR:' \
        && bad "$f emitted an ERROR; advisories must never escalate" \
        || ok "$f emits no ERROR"
    printf '%s' "$OUT" | grep -qE '^PASS: ' \
        && ok "$f still prints a PASS verdict line" \
        || bad "$f printed no PASS verdict line :: $(first_line)"
done

# The ordering advisory must name the section that displaced the decision block.
run "$FX/trailing-after-decisions.md"
want_grep "'## Rollout notes'" "ordering advisory names the trailing section"

# ---------------------------------------------------------------------------
echo "== 3. CLEAN FIXTURES — a compliant document is silent =="

# tldr-after-status-line.md is the shape the lead-line rule must never reject:
# an H1 title and italic metadata lines, then the tl;dr.
for f in pass-minimal tldr-after-status-line; do
    expect "$FX/$f.md" 0 "PASS:" "$f -> rc=0"
    # expect() ran the fixture; $OUT still holds that run.
    [ "$(count '^(ERROR|ADVISORY):')" -eq 0 ] \
        && ok "$f prints no findings at all" \
        || bad "$f printed findings :: $OUT"
done

# ---------------------------------------------------------------------------
echo "== 4. REAL DIRECTIVES — the three 2026-08-20 documents must all pass =="

REAL="$FX/real"
for f in "$REAL"/*.md; do
    name="${f##*/}"
    run "$f"
    want_rc 0 "real/$name -> rc=0"
done

# communication-program.md carries "Ship definition" after "Decisions requested".
# That is the exact case the advisory exists for: it must pass, and it must say so.
run "$REAL/2026-08-20-communication-program.md"
want_grep "ADVISORY: '## Ship definition'" "communication-program -> ordering advisory fires on 'Ship definition'"
want_rc 0 "communication-program -> advisory did not change the exit code"

# The two implementation-level directives carry Acceptance criteria and no
# Decisions requested, so they must be entirely finding-free.
for name in 2026-08-20-comms-delivery-surfaces 2026-08-20-design-doc-and-brevity-skills; do
    run "$REAL/$name.md"
    [ "$(count '^(ERROR|ADVISORY):')" -eq 0 ] \
        && ok "real/$name is finding-free" \
        || bad "real/$name printed findings :: $OUT"
done

# ---------------------------------------------------------------------------
echo "== 5. USAGE — argument errors exit 2, never 1 =="

run
want_rc 2 "no argument -> rc=2"
want_grep 'usage: validate.sh' "no argument -> prints usage"

run "$FX/does-not-exist.md"
want_rc 2 "missing file -> rc=2 (not a validation failure)"

run "$FX/pass-minimal.md" "$FX/both-outcomes.md"
want_rc 2 "two arguments -> rc=2"

# A path with a space must validate normally, not word-split.
TMP="$(mktemp -d "${TMPDIR:-/tmp}/design-doc-tests.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/sp dir"
cp "$FX/pass-minimal.md" "$TMP/sp dir/doc.md"
run "$TMP/sp dir/doc.md"
want_rc 0 "spaced path validates normally"

# ---------------------------------------------------------------------------
echo
if [ "$fails" -eq 0 ]; then
    printf '\033[32mALL TESTS PASSED\033[0m\n'
else
    printf '\033[31m%s TEST(S) FAILED\033[0m\n' "$fails"
fi
exit "$fails"
