#!/usr/bin/env bash
# Oracle for evals/pr-description/run.sh's guards. NEEDS NO MODEL, so it runs in CI on the same
# leg as the rest of this repository's tests while the cases it guards do not.
#
# WHY THIS FILE EXISTS AT ALL. run.sh is model-only: every case in it calls `claude`, so no CI job
# can run it and its only forcing function is someone remembering. That is precisely the shape
# that let borg-collective's `make eval-live` report SUCCESS at exit 0 on a machine with no
# `claude` installed, the entire model sweep absent — a green run of nothing. The repair there was
# a mode floor, and then the discovery that the floor ITSELF had no oracle and could be deleted
# with every gate staying green. So the floor lands with its pair or it lands unobserved, and the
# pair has to be runnable where the floor is not.
#
# EIGHT CASES, each in the firing direction AND the direction that proves it discriminates. A guard
# asserted only firing is satisfied just as well by an artifact that always fails:
#   1  --skip-model     requests nothing, runs nothing, exits 0 and SAYS SO
#   2  model floor      FIRES at rc 1 when the sweep is requested and `claude` is hidden...
#   3  model floor      ...and the cases SKIP rather than FAIL in that same run (absent input is
#                       not a defect, and conflating them is what the floor must not do)
#   4  checkout guard   a REPO with no tracked root marker is refused BY NAME and a canary planted
#                       where $OUT would be SURVIVES; a REPO that does carry the marker gets past
#   5  fixture builder  a manifest fixture carries .borg/programs and leaves HEAD off main with a
#                       non-empty main..HEAD; a manifest-less fixture carries no .borg at all
#   6  model floor      ...and HOLDS when a stub `claude` lets one case execute, so the floor is
#                       proved CONDITIONAL and not merely present. Drives the model path
#                       behaviourally, so the empty-array expansion is actually executed -- as does
#                       case 7, which was inserted after this note first called case 6 the ONLY one.
#   7  claude rc        a non-zero `claude` SKIPs both cases NAMING the rc and FAILs neither, so a
#                       broken CLI is never reported as a broken skill
#   8  guarded array    every ${TIMEOUT[@]} expansion is guarded -- inherited from borg's case 13,
#                       whose subject moved here with the cases that expand an optional prefix

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN="$SCRIPT_DIR/run.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0; FAIL=0
ok()  { echo "  ok   $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL $1"; FAIL=$((FAIL+1)); }

# A positively-named allowlist: only the binaries run.sh actually calls, symlinked in. NOT
# `PATH=/usr/bin:/bin`, which assumes `claude` lives outside those directories — true on a laptop
# with a ~/.local/bin install, false on any image that puts it in /usr/bin. Deriving the allowlist
# from what the script needs is the only form that hides a binary without guessing where it isn't,
# and it must include `bash` and `dirname` because the shebang and SCRIPT_DIR need them.
ALLOW="$TMP/allow/bin"
mkdir -p "$ALLOW"
for b in bash dirname git grep mkdir rm cp printf cat sed mktemp; do
    src="$(command -v "$b" 2>/dev/null)" && ln -sf "$src" "$ALLOW/$b"
done

echo "== 1: --skip-model requests nothing and says so =="
out="$(bash "$RUN" --skip-model 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q "no offline cases"; then
    ok "--skip-model exits 0 naming why it verified nothing"
else
    bad "--skip-model (rc=$rc) $out"
fi

echo "== 2/3: the model floor fires, and its cases skip rather than fail =="
out="$(env PATH="$ALLOW" bash "$RUN" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -q "the model sweep was requested but no model case executed"; then
    ok "model floor fires at rc 1 with the reason named"
else
    bad "model floor did not fire (rc=$rc) $out"
fi
if printf '%s' "$out" | grep -q "SKIP  E4" && printf '%s' "$out" | grep -q "SKIP  E5" \
   && ! printf '%s' "$out" | grep -q "FAIL  E"; then
    ok "an absent claude SKIPs both cases and FAILs neither"
else
    bad "absent claude was reported as a case failure: $out"
fi

echo "== 4: the checkout guard refuses a foreign REPO before the rm -rf =="
# The canary goes exactly where $OUT would be. A literal elsewhere would pass while proving
# nothing — the negative half has to sit in the deletion's path.
foreign="$TMP/foreign"
mkdir -p "$foreign/evals/pr-description/out"
printf 'canary\n' > "$foreign/evals/pr-description/out/canary"
out="$(PLUGINS_EVAL_REPO="$foreign" bash "$RUN" --skip-model 2>&1)"; rc=$?
if [ "$rc" -eq 2 ] && printf '%s' "$out" | grep -q "does not look like the claude-plugins checkout" \
   && [ -f "$foreign/evals/pr-description/out/canary" ]; then
    ok "a foreign REPO is refused by name and the canary survives"
else
    canary_state=NO
    [ -f "$foreign/evals/pr-description/out/canary" ] && canary_state=yes
    bad "checkout guard (rc=$rc, canary present: $canary_state) $out"
fi
# The holding direction: a REPO that DOES carry the marker gets past the guard, and the same
# canary is then deleted. Without this half the guard would be credited for refusing everything.
marked="$TMP/marked"
mkdir -p "$marked/evals/pr-description/out"
cp "$RUN" "$marked/evals/pr-description/run.sh"
printf '#\n' > "$marked/build-plugins.sh"
printf 'canary\n' > "$marked/evals/pr-description/out/canary"
PLUGINS_EVAL_REPO="$marked" bash "$RUN" --skip-model >/dev/null 2>&1
if [ ! -f "$marked/evals/pr-description/out/canary" ]; then
    ok "a marked REPO gets past the guard and the out dir is recreated"
else
    bad "a marked REPO did not get past the guard — the canary was not deleted"
fi

echo "== 5: the fixture builder produces both shapes =="
# Sourced rather than reimplemented: a copy of make_fixture_repo here could drift from the one the
# cases use, and then this case would be checking its own duplicate.
# shellcheck disable=SC1090
eval "$(sed -n '/^make_fixture_repo()/,/^}/p' "$RUN")"
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid
export GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid GIT_CONFIG_NOSYSTEM=1
with="$TMP/fx-with"; without="$TMP/fx-without"
make_fixture_repo "$with" "$SCRIPT_DIR/fixtures/programs/ingle-t1-cutover.json" >/dev/null 2>&1
make_fixture_repo "$without" >/dev/null 2>&1
branch="$(git -C "$with" rev-parse --abbrev-ref HEAD)"
ahead="$(git -C "$with" rev-list --count main..HEAD)"
if [ -f "$with/.borg/programs/ingle-t1-cutover.json" ] && [ "$branch" != "main" ] && [ "$ahead" -ge 1 ]; then
    ok "the manifest fixture declares a program and leaves main..HEAD non-empty (branch=$branch, ahead=$ahead)"
else
    bad "manifest fixture (branch=$branch, ahead=$ahead)"
fi
if [ ! -d "$without/.borg" ] && [ "$(git -C "$without" rev-list --count main..HEAD)" -ge 1 ]; then
    ok "the manifest-less fixture carries no .borg at all"
else
    bad "manifest-less fixture has a .borg directory it should not"
fi

echo "== 6: the model floor HOLDS when a model case can execute =="
# THE DISCRIMINATING HALF, AND IT WAS MISSING. Case 2 proves the floor FIRES; nothing proved it is
# CONDITIONAL. Mutate run.sh's `[ "$MODEL_RAN" -eq 0 ]` to `-ge 0` (or drop the two
# `MODEL_RAN=$((MODEL_RAN+1))` lines, the realistic refactor regression) and cases 1-5 all stayed
# green: case 1 exits above the floor under --skip-model, cases 2 and 3 read the same already-firing
# run, cases 4 and 5 never reach it. The harness would then exit 1 on EVERY invocation -- including
# one where E4 and E5 both PASS -- which is the "floor nothing can satisfy is a permanent red, not a
# gate" state borg's AC6 decision (3) forbids, and its stated reason would contradict its own
# printed evidence.
#
# borg-collective's tests/eval_floor.bats HAD this case ("the model-mode floor holds when a model
# case can execute") and it was deleted when E4/E5 relocated here, without being carried over --
# the same omission the guarded-array case (7 below) was spared. This is the inheritance.
#
# A STUB `claude`, NOT THE REAL ONE: the point is to drive the floor's holding branch, not to spend
# money or require credentials, so CI can run it. The stub prints what E5 asserts, so E5 passes,
# MODEL_RAN reaches 1, and the floor must NOT fire. E4 legitimately fails against a stub that knows
# nothing about manifests, which is why the assertion is on the FLOOR's absence and on rc, not on a
# clean run.
#
# It also drives the model path BEHAVIOURALLY, which the guarded-array case (now 8) cannot: that one
# is a static grep, so the `${TIMEOUT[@]+"${TIMEOUT[@]}"}` empty-array expansion -- the thing that
# crashed on bash 3.2 -- has to be reached by a case that actually invokes the model path. This case
# and case 7 both do. THE NUMBER 8 IS WHY THIS SENTENCE NAMES THE CASE AND NOT ONLY ITS INDEX: when
# case 7 was inserted the guarded-array case shifted from 7 to 8 and this comment still said 7,
# which is the renumber drift this file's borg counterpart was corrected for twice.
STUB="$TMP/stub/bin"
mkdir -p "$STUB"
for b in bash dirname git grep mkdir rm cp printf cat sed head tr mktemp; do
    src="$(command -v "$b" 2>/dev/null)" && ln -sf "$src" "$STUB/$b"
done
cat > "$STUB/claude" <<'STUBEOF'
#!/bin/sh
echo "## Chain position"
echo
echo "No manifest declared."
STUBEOF
chmod +x "$STUB/claude"
out="$(env PATH="$STUB" bash "$RUN" 2>&1)"; rc=$?
# THE rc IS ASSERTED, NOT MERELY INTERPOLATED. The first draft of this case printed `(rc=$rc)` into
# its own success message and asserted nothing about it, which left the harness OUTERMOST gate --
# the closing `[ "$FAIL" -eq 0 ]` -- observed by nothing: delete that line and this file stayed at
# 9 ok / 0 fail while a genuine E4 regression exited 0 to `make eval`, to a human, and to any
# wrapper reading the status. E4 legitimately FAILs against a stub that knows nothing about
# manifests, so rc 1 is the expected value here and is what proves the gate is wired. borg
# tests/eval_floor.bats asserted the same thing on a bad-only run before these cases moved.
if ! printf '%s' "$out" | grep -q "the model sweep was requested but no model case executed" \
   && printf '%s' "$out" | grep -q "E5 fallback line present" \
   && [ "$rc" -eq 1 ]; then
    ok "the floor stays silent when a case executed, and a FAIL still sets rc (rc=$rc)"
else
    bad "the floor fired despite a case executing, or rc was not 1 (rc=$rc): $out"
fi

echo "== 7: a non-zero claude is an absent input, not a case failure =="
# THE rc ARM HAD NO ORACLE. Reverting `[ "$claude_rc" -ne 0 ]` to the pre-fix straight-to-grep
# behaviour left this file at 9 ok / 0 fail: cases 2 and 3 hide `claude` entirely, so
# `command -v claude` returns first and the arm is never reached, and case 6 stub exits 0. Nothing
# drove a non-zero-rc `claude` at all -- so the fix for "a broken CLI is reported as a broken
# skill" was itself unobserved, which is the defect class this whole file exists to close.
FAILSTUB="$TMP/failstub/bin"
mkdir -p "$FAILSTUB"
for b in bash dirname git grep mkdir rm cp printf cat sed head tr mktemp; do
    src="$(command -v "$b" 2>/dev/null)" && ln -sf "$src" "$FAILSTUB/$b"
done
printf '#!/bin/sh\necho "Invalid API key -- not logged in" >&2\nexit 42\n' > "$FAILSTUB/claude"
chmod +x "$FAILSTUB/claude"
out="$(env PATH="$FAILSTUB" bash "$RUN" 2>&1)"; rc=$?
# Three clauses: both cases SKIP, neither FAILs, and the rc is NAMED so the author is told which
# failure they actually have. The floor still firing is correct and deliberate -- the sweep was
# requested and no case executed -- so rc is not asserted as 0 here.
if printf '%s' "$out" | grep -q "SKIP  E4 chain position: claude exited 42" \
   && printf '%s' "$out" | grep -q "SKIP  E5 fallback: claude exited 42" \
   && ! printf '%s' "$out" | grep -q "FAIL  E"; then
    ok "a non-zero claude SKIPs both cases by rc and FAILs neither (rc=$rc)"
else
    bad "a broken CLI was reported as a case failure (rc=$rc): $out"
fi

echo "== 8: the optional prefix array is never expanded bare =="
# INHERITED FROM borg-collective's tests/eval_floor.bats 2026-09-03, where it was case 13 and where
# its subject no longer exists: `${TIMEOUT[@]}` left that tree with E4/E5, and this is the harness
# that still expands an optional prefix. On bash < 4.4 -- macOS ships 3.2 -- expanding an EMPTY
# array under `set -u` is an unbound-variable error, so the bare form kills the script BEFORE its
# `>` redirect opens, the following grep reads a file that was never written, and the case reports
# FAIL for a crash rather than for what it asserts. That exact bug shipped once.
#
# ARITHMETIC, NOT PATTERN SURGERY. The guarded form contains the bare form as its own default
# value, and the comment above it quotes both spellings in prose, so a naive grep for the bare
# shape matches the guard and its own documentation. Instead: every legitimate mention in CODE is
# either the guard's test (`[@]+`) or the inner expansion that immediately follows it, so a correct
# file has exactly TWICE as many `TIMEOUT[@]` occurrences as `TIMEOUT[@]+` ones. A bare expansion
# adds one to the left side only. Counted over CODE lines, comments stripped, so the prose above
# cannot move either number.
code="$(grep -v '^[[:space:]]*#' "$RUN")"
total="$(printf '%s' "$code" | grep -o 'TIMEOUT\[@\]' | wc -l | tr -d ' ')"
guarded="$(printf '%s' "$code" | grep -o 'TIMEOUT\[@\]+' | wc -l | tr -d ' ')"
if [ "$guarded" -ge 1 ] && [ "$total" -eq $((guarded * 2)) ]; then
    ok "every TIMEOUT expansion is guarded (${total} mentions, ${guarded} guards)"
else
    bad "an unguarded TIMEOUT expansion (${total} mentions, ${guarded} guards; want total == 2*guards)"
fi

echo "RESULT: $PASS ok, $FAIL fail"
[ "$FAIL" -eq 0 ]
