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
# FIVE CASES, each in the firing direction AND the direction that proves it discriminates. A guard
# asserted only firing is satisfied just as well by an artifact that always fails:
#   1  --skip-model     requests nothing, runs nothing, exits 0 and SAYS SO
#   2  model floor      FIRES at rc 1 when the sweep is requested and `claude` is hidden...
#   3  model floor      ...and the cases SKIP rather than FAIL in that same run (absent input is
#                       not a defect, and conflating them is what the floor must not do)
#   4  checkout guard   a REPO with no tracked root marker is refused BY NAME and a canary planted
#                       where $OUT would be SURVIVES; a REPO that does carry the marker gets past
#   5  fixture builder  a manifest fixture carries .borg/programs and leaves HEAD off main with a
#                       non-empty main..HEAD; a manifest-less fixture carries no .borg at all

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
    bad "checkout guard (rc=$rc, canary present: $([ -f "$foreign/evals/pr-description/out/canary" ] && echo yes || echo NO)) $out"
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

echo "RESULT: $PASS ok, $FAIL fail"
[ "$FAIL" -eq 0 ]
