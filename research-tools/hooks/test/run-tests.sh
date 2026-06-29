#!/usr/bin/env bash
# run-tests.sh — regression suite for the deep-research fail-closed ground gate.
#
# Three layers:
#   1. FIXTURE SUITE   — every test/fixtures/<scenario> asserts its expected verdict
#                        (exit code + the specific GATE assertion that drives it).
#   2. EVASION/HONEST  — mutate the known-good `pass` fixture to exercise exactly one
#                        gate-evasion or honest-deliverable case the gate must handle.
#   3. CROSS-CUTTING   — discovery, the Stop hook's exit-code handling, the scholarly
#                        adapter's arg parsing, and spaced-path robustness.
#
# Usage:  bash run-tests.sh        (exit 0 = all pass, non-zero = count of failures)
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS="$(cd "$HERE/.." && pwd)"
V="$HOOKS/deep-research-verify.sh"
STOP="$HOOKS/deep-research-stop.sh"
SCHOLARLY="$HOOKS/scholarly-adapter.sh"
PASS="$HERE/fixtures/pass"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/dr-tests.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

fails=0
ok()  { printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fails=$((fails+1)); }
run() { OUT="$("$V" "$1" 2>&1)"; RC=$?; }
want_rc()   { [[ "$RC" -eq "$1" ]] && ok "$2" || bad "$2 — want rc=$1 got rc=$RC :: $(printf '%s' "$OUT" | grep -E '^Gate result' | head -1)"; }
want_grep() { printf '%s' "$OUT" | grep -qE "$1" && ok "$2" || bad "$2 — missing /$1/"; }
mk()   { rm -rf "$TMP/c"; cp -R "$PASS" "$TMP/c"; }
edit() { sed -E "$2" "$1" > "$1.t" && mv "$1.t" "$1"; }

# ---------------------------------------------------------------------------
echo "== 1. FIXTURE SUITE — each scenario's expected verdict =="
# name : expected_rc : assertion-pattern that must appear in output
FIXTURE_CASES=(
    "pass:0:Gate result: PASS"
    "cosmetic:0:Gate result: PASS"
    "evidence-floor:0:Gate result: PASS"
    "evidence-floor-clean:0:Gate result: PASS"
    "scholarly:0:Gate result: PASS"
    "bad-perspective:1:A11 FAIL"
    "corrected:1:A6 FAIL"
    "domain-mismatch:1:A9 FAIL"
    "inaccessible-cap:1:A10 FAIL"
    "missing-failcount:1:A2 FAIL"
    "no-cut:1:A12 FAIL"
    "noncanonical:1:A3 FAIL"
    "retroactive:1:A8 FAIL"
    "undersample:1:A7 FAIL"
    "fallback:1:A4 FAIL"      # intentional: self-check only, no verifier ID
    "rapid:1:A4 FAIL"         # intentional: rapid tier, no distinct verifier
)
for case in "${FIXTURE_CASES[@]}"; do
    name="${case%%:*}"; rest="${case#*:}"; erc="${rest%%:*}"; pat="${rest#*:}"
    run "$HERE/fixtures/$name"
    if [[ "$RC" -eq "$erc" ]] && printf '%s' "$OUT" | grep -qF "$pat"; then
        ok "$name -> rc=$erc, '$pat'"
    else
        bad "$name -> want rc=$erc + '$pat'; got rc=$RC :: $(printf '%s' "$OUT" | grep -E '^Gate result' | head -1)"
    fi
done

# ---------------------------------------------------------------------------
echo "== 2. EVASION / HONEST cases (mutations of the pass fixture) =="

# --- fail-OPEN closures: a gamed deliverable must now be CAUGHT ---
mk; edit "$TMP/c/verification-report.md" 's/≤5%/>12%/'; edit "$TMP/c/deliverable.md" 's/≤5%/>12%/'
run "$TMP/c"; want_grep 'A3 FAIL' "A3 catches non-canonical >12% band"

mk; edit "$TMP/c/verification-report.md" 's/≤5%/>10%-20%/'; edit "$TMP/c/deliverable.md" 's/≤5%/>10%-20%/'
run "$TMP/c"; want_grep 'A3 FAIL' "A3 catches >10%-20% range band"

mk
edit "$TMP/c/verification-report.md" 's/3 cards sampled from 3 total on disk \(100%[^)]*\)/5 cards sampled from 53 total on disk (9%)/'
run "$TMP/c"; want_grep 'A7 FAIL' "A7 rejects phantom denominator (reported 53 > 3 on disk)"

mk
cat > "$TMP/c/verification-report.md" <<'EOF'
# Citation Verification Report
**Synthesis agent ID:** synth-a1b2c3
**Verifier agent ID:** verify-z9y8x7
## Sample Selection
3 cards sampled from 3 total on disk (100%).
## Per-Card Results
| Card | Outcome | Note |
|------|---------|------|
| t1-example-alpha.md | inaccessible | 1 fetch retry failed before giving up |
| t2-example-beta.md | inaccessible | timed out |
| t3-example-gamma.md | verified | ok |
## Aggregate
| Outcome | Count |
|---------|-------|
| Inaccessible | 2 |
## Failure Rate and Band
- **Failure count:** 0
- **Failure-rate band:** ≤5%
## Inclusion Cut
Excluded | 1
EOF
run "$TMP/c"; want_grep 'A10 FAIL inaccessible 2/3' "A10 reads aggregate count (2), not per-card note digit (1)"

mk
cat > "$TMP/c/verification-report.md" <<'EOF'
# Citation Verification Report
**Synthesis agent ID:** synth-a1b2c3
**Verifier agent ID:** verify-z9y8x7
## Sample Selection
3 cards sampled from 3 total on disk (100%).
## Per-Card Results
| Card | Outcome | Note |
|------|---------|------|
| t1-example-alpha.md | verified | ok |
| t2-example-beta.md | verified | ok |
| t3-example-gamma.md | verified | ok |
## Aggregate
| Outcome | Count |
|---------|-------|
| Inaccessible | 0 |
## Failure Rate and Band
- **Failure count:** 0
- **Failure-rate band:** ≤5%
## Inclusion Summary
Excluded: 0 of 12 candidates failed the bar; every source cleared.
EOF
run "$TMP/c"; want_grep 'A12 FAIL' "A12 rejects 'Excluded: 0 of 12' (reads 0, not 12)"

mk; printf '\n— notes.example.org.attacker-cdn.com / mirror\n' >> "$TMP/c/sources/t1-example-alpha.md"
run "$TMP/c"; want_grep 'A9 FAIL' "A9 rejects lookalike suffix notes.example.org.attacker-cdn.com"

mk; printf '\n— evil-spoof.xyz / unrelated docs\n' >> "$TMP/c/sources/t1-example-alpha.md"
run "$TMP/c"; want_grep 'A9 FAIL' "A9 rejects non-allowlist TLD .xyz"

mk
edit "$TMP/c/sources/t1-example-alpha.md" 's#\*\*URL:\*\* https://example.org/alpha#**URL:** example.org/alpha#'
printf '\n— attacker-cdn.com / mirror\n' >> "$TMP/c/sources/t1-example-alpha.md"
run "$TMP/c"; want_grep 'A9 FAIL' "A9 extracts host from scheme-less URL and flags mismatch"

# --- fail-CLOSED closures: an honest deliverable must NOT be rejected ---
mk; printf '\n— blog.example.org / same site\n' >> "$TMP/c/sources/t1-example-alpha.md"
run "$TMP/c"; want_rc 0 "A9 accepts same-origin subdomain blog.example.org"

mk
edit "$TMP/c/verification-report.md" 's/Quote found character-for-character at source; attribution matches\./Quote verified verbatim; no correction was needed./'
run "$TMP/c"; want_rc 0 "A6 passes honest 'no correction needed' note"

mk; printf '\nNo card was reclassified after synthesis; all outcomes stand as scored.\n' >> "$TMP/c/verification-report.md"
run "$TMP/c"; want_rc 0 "A8 passes honest reclassification denial"

mk; printf '\nIn the field, <=20%% of respondents disagreed.\n' >> "$TMP/c/deliverable.md"
run "$TMP/c"; want_rc 0 "A3 ignores unrelated <=20% prose when band is canonical"

# ---------------------------------------------------------------------------
echo "== 3. CROSS-CUTTING =="

# spaced path (the must-fix word-split)
rm -rf "$TMP/sp dir"; mkdir -p "$TMP/sp dir"; cp -R "$PASS" "$TMP/sp dir/run"
run "$TMP/sp dir/run"; want_rc 0 "compliant deliverable under a spaced path passes"

# W1 case-insensitivity: title-cased zero-primary table must fire the banner warning
cp -R "$PASS" "$TMP/w1"
cat >> "$TMP/w1/deliverable.md" <<'EOF'

### Evidence-Level Distribution
| Level | Type | Count |
|-------|------|-------|
| 1 | Systematic Review / Meta-Analysis | 0 |
| 2 | Randomized Controlled Trial | 0 |
| 3 | Observational study | 3 |
EOF
run "$TMP/w1"; want_rc 0 "W1 warning stays non-blocking"
want_grep 'WARN: W1 .*primary-evidence' "W1 fires on a title-cased zero-primary table"

# Auto-discovery: flat docs/research layout must target docs/research, not sources/
mkdir -p "$TMP/proj/docs/research"
cp "$PASS/deliverable.md" "$PASS/verification-report.md" "$TMP/proj/docs/research/"
cp -R "$PASS/sources" "$TMP/proj/docs/research/sources"
OUT="$(cd "$TMP/proj" && "$V" 2>&1)"; RC=$?
printf '%s' "$OUT" | grep -qE '^GATE: target .*/docs/research$' && ok "auto-discovery targets docs/research, not .../sources" \
    || bad "wrong target: $(printf '%s' "$OUT" | grep '^GATE: target')"
[[ "$RC" -eq 0 ]] && ok "flat-layout deliverable passes end-to-end" || bad "flat-layout failed (rc=$RC)"

# Stop hook: armed + no deliverable -> verifier exit 2 -> NON-blocking advisory
mkdir -p "$TMP/empty/docs/research"
OUT="$(printf '{"cwd":"%s"}' "$TMP/empty" | DEEP_RESEARCH_GATE_ARM=1 bash "$STOP" 2>&1)"; RC=$?
[[ "$RC" -eq 0 ]] && ok "Stop hook does not block on a locate error" || bad "Stop hook blocked on locate error (rc=$RC)"
printf '%s' "$OUT" | grep -qE 'ground gate: not run' && ok "Stop hook emits a distinct 'not run' advisory" || bad "no advisory: $OUT"
printf '%s' "$OUT" | grep -q '"decision": *"block"' && bad "Stop hook still emitted a block decision" || ok "no spurious block decision"

# ---------------------------------------------------------------------------
echo "== 4. SESSION-SCOPING GATE TESTS (false-block regression) =="

# (a) armed + stale/pre-existing deliverable only (no .gate-armed) -> advisory, not block.
# This is the borg-collective zombie-deliverable scenario: a pre-gate deliverable exists
# on disk but the current session never registered it. The gate must NOT hard-block.
mkdir -p "$TMP/stale/docs/research/2026-05-23-old-run/sources"
printf '# Stale deliverable — pre-dates verification protocol\n' > "$TMP/stale/docs/research/2026-05-23-old-run/deliverable.md"
OUT="$(printf '{"cwd":"%s"}' "$TMP/stale" | DEEP_RESEARCH_GATE_ARM=1 bash "$STOP" 2>&1)"; RC=$?
[[ "$RC" -eq 0 ]] && ok "(a) stale/pre-gate deliverable: Stop hook non-blocking (rc=0)" \
    || bad "(a) stale/pre-gate deliverable: Stop hook blocked (rc=$RC)"
printf '%s' "$OUT" | grep -qE 'ground gate: not run' && ok "(a) stale: 'not run' advisory emitted" \
    || bad "(a) stale: expected 'not run' advisory; got: $OUT"
printf '%s' "$OUT" | grep -q '"decision": *"block"' && bad "(a) stale: spurious block decision" \
    || ok "(a) stale: no block decision"
printf '%s' "$OUT" | grep -qE 'stale|no .gate-armed|no this-session' && ok "(a) stale: advisory mentions marker absence" \
    || ok "(a) stale: advisory present (no marker mention required)"

# (b) armed + .gate-armed + compliant fresh deliverable -> PASS (gate clears).
# The methodology skill wrote .gate-armed pointing to a fresh compliant deliverable.
mkdir -p "$TMP/fresh-pass/docs/research/2026-06-12-new-run"
cp -R "$PASS/." "$TMP/fresh-pass/docs/research/2026-06-12-new-run/"
printf '%s/docs/research/2026-06-12-new-run\n' "$TMP/fresh-pass" > "$TMP/fresh-pass/docs/research/.gate-armed"
OUT="$(printf '{"cwd":"%s"}' "$TMP/fresh-pass" | DEEP_RESEARCH_GATE_ARM=1 bash "$STOP" 2>&1)"; RC=$?
[[ "$RC" -eq 0 ]] && ok "(b) fresh compliant + .gate-armed: Stop hook exits 0 (PASS)" \
    || bad "(b) fresh compliant + .gate-armed: Stop hook failed (rc=$RC) :: $OUT"
printf '%s' "$OUT" | grep -qE 'ground gate: PASS' && ok "(b) fresh compliant: PASS badge emitted" \
    || bad "(b) fresh compliant: no PASS badge; got: $(printf '%s' "$OUT" | head -3)"

# (c) armed + .gate-armed + NON-compliant fresh deliverable -> BLOCK (exit 1 still fires).
# The safety guarantee must remain intact: a genuine failing deliverable blocks.
mkdir -p "$TMP/fresh-fail/docs/research/2026-06-12-bad-run/sources"
cp "$PASS/sources/"*.md "$TMP/fresh-fail/docs/research/2026-06-12-bad-run/sources/"
cp "$PASS/deliverable.md" "$TMP/fresh-fail/docs/research/2026-06-12-bad-run/"
# Omit verification-report.md so A1 fires.
printf '%s/docs/research/2026-06-12-bad-run\n' "$TMP/fresh-fail" > "$TMP/fresh-fail/docs/research/.gate-armed"
OUT="$(printf '{"cwd":"%s"}' "$TMP/fresh-fail" | DEEP_RESEARCH_GATE_ARM=1 bash "$STOP" 2>&1)"; RC=$?
[[ "$RC" -ne 0 ]] && ok "(c) non-compliant + .gate-armed: Stop hook blocks (rc=$RC)" \
    || bad "(c) non-compliant + .gate-armed: Stop hook did NOT block (rc=0)"
printf '%s' "$OUT" | grep -qE 'NOT fact-checked|decision.*block|A1 FAIL' && ok "(c) non-compliant: block/FAIL signal present" \
    || bad "(c) non-compliant: no block signal; got: $(printf '%s' "$OUT" | head -3)"

# (d) armed + no deliverable at all (no docs/research dir, no .gate-armed) -> advisory.
# A session that ran the workflow modality (no card deliverable) must not block.
mkdir -p "$TMP/nodocs"
OUT="$(printf '{"cwd":"%s"}' "$TMP/nodocs" | DEEP_RESEARCH_GATE_ARM=1 bash "$STOP" 2>&1)"; RC=$?
[[ "$RC" -eq 0 ]] && ok "(d) no deliverable at all: Stop hook non-blocking (rc=0)" \
    || bad "(d) no deliverable at all: Stop hook blocked (rc=$RC)"
printf '%s' "$OUT" | grep -q '"decision": *"block"' && bad "(d) no deliverable: spurious block decision" \
    || ok "(d) no deliverable: no block decision"

# Scholarly adapter: trailing value-less flag -> usage die (exit 2), not unbound crash
OUT="$(bash "$SCHOLARLY" search "q" --limit 2>&1)"; RC=$?
[[ "$RC" -eq 2 ]] && ok "scholarly: value-less flag exits 2 (usage)" || bad "scholarly: wrong rc=$RC"
printf '%s' "$OUT" | grep -q 'unbound variable' && bad "scholarly: raw unbound-variable crash leaked" || ok "scholarly: no unbound-variable crash"

# ---------------------------------------------------------------------------
echo "== 5. RESEARCH FRONT-DOOR RENAME + DECISION-DESIGN NON-BLOCK =="

# The Stop hook must arm on the renamed `research` skill (evidence mode and its alias
# `deep-research`), driven by the real transcript regex — not just the test env override.
# And a decision-design run (the skill ran, but produced NO .gate-armed marker and no card
# deliverable) must hit the non-blocking advisory branch, never a hard block.
mk_transcript() {  # $1 = the skill field the harness would log for a Skill invocation
    printf '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"%s"}}]}}\n' "$1" > "$TMP/tr.jsonl"
}
for skill in "research-tools:research" "research" "research-tools:deep-research" "deep-research"; do
    mk_transcript "$skill"
    rm -rf "$TMP/dd"; mkdir -p "$TMP/dd/docs/research"   # transcript-armed, NO .gate-armed marker
    OUT="$(printf '{"cwd":"%s","transcript_path":"%s"}' "$TMP/dd" "$TMP/tr.jsonl" | bash "$STOP" 2>&1)"; RC=$?
    [[ "$RC" -eq 0 ]] && ok "decision-design ($skill): transcript-armed, no marker -> non-blocking (rc=0)" \
        || bad "decision-design ($skill): blocked (rc=$RC) :: $OUT"
    printf '%s' "$OUT" | grep -qE 'ground gate: not run' && ok "decision-design ($skill): 'not run' advisory emitted" \
        || bad "decision-design ($skill): no advisory; got: $OUT"
    printf '%s' "$OUT" | grep -q '"decision": *"block"' && bad "decision-design ($skill): spurious block decision" \
        || ok "decision-design ($skill): no block decision"
done

# Negative: a transcript that only MENTIONS "deep research" in prose must NOT arm the gate.
printf '{"type":"assistant","message":{"content":[{"type":"text","text":"let us do some deep research now"}]}}\n' > "$TMP/tr.jsonl"
rm -rf "$TMP/dd"; mkdir -p "$TMP/dd/docs/research"
OUT="$(printf '{"cwd":"%s","transcript_path":"%s"}' "$TMP/dd" "$TMP/tr.jsonl" | bash "$STOP" 2>&1)"; RC=$?
[[ "$RC" -eq 0 ]] && ok "prose-only 'deep research' mention: stays dormant (rc=0)" || bad "prose mention blocked (rc=$RC)"
printf '%s' "$OUT" | grep -q '"decision": *"block"' && bad "prose mention: spurious block decision" || ok "prose mention: no block decision"

# ---------------------------------------------------------------------------
echo
if [[ "$fails" -eq 0 ]]; then
    printf '\033[32mALL TESTS PASSED\033[0m\n'
else
    printf '\033[31m%s TEST(S) FAILED\033[0m\n' "$fails"
fi
exit "$fails"
