#!/usr/bin/env bash
# /pr-description chain-position eval. Both cases grade THIS repository's skill
# (noah-content-tools/skills/pr-description/SKILL.md), which is why they live here.
#
# Evals:
#   E4  manifest path: /pr-description in a repository carrying .borg/programs/*.json renders
#       chain position FROM THE MANIFEST (program name), not the fallback
#   E5  fallback path: /pr-description in a manifest-less repository writes the literal
#       "No manifest declared." — proves the conditional discriminates; without E5, E4 could
#       pass vacuously against a skill that printed the program name unconditionally
#
# RELOCATED FROM borg-collective 2026-09-03, from evals/s4-k3/run.sh, where that harness's own
# comment had already recorded why they could not stay: "E4/E5 grade /pr-description, WHICH THIS
# REPOSITORY DOES NOT OWN — nothing under skills/ matches it; it is a claude-plugins skill. So a
# red here can mean a defect in a surface that is not in this tree, and the case cannot be
# repaired from inside this repo." A gate belongs in the tree that owns the surface it grades,
# for the same reason borg_core/recon/cli.py owns the recon retirement gate rather than its zsh
# caller: the artifact that implements the command owns the invariant.
#
# NO CASE MAY REQUIRE A REPOSITORY THAT IS NOT IN THIS TREE, and that is the second half of why
# they moved. In their previous form E4 required a stillpoint checkout plus a fetchable
# `origin/write-freeze-design` branch plus a specific manifest file, and E5 required a troth
# checkout; both SKIPped otherwise. Measured 2026-09-03: neither repository was present, so the
# entire model sweep was absent on the machine of record and `make eval-live` exited non-zero on
# its own model floor. Across three machines (personal, ontra, stillpoint) "is that repository
# cloned here" is a property of the laptop, never of the case.
#
# NEITHER CASE WAS EVER ABOUT THOSE REPOSITORIES. E4 asserts the skill reads *a* manifest; E5
# asserts it says so when there is *none*. The borg harness had already reached this conclusion
# for E5 in a comment — "E5's input is 'a repository with no manifest', which an ephemeral
# `git init` under a tmpdir satisfies exactly as well as troth does — this case has no business
# naming a real repository. NOT substituted here, deliberately: the substitution can only be
# verified against the real `/pr-description`, which lives in claude-plugins" — and named the
# substitution as the first thing to do when the cases moved. This is that move, so both fixtures
# are now SYNTHESIZED: `git init` under $OUT, with E4's manifest copied from a committed fixture.
# The verification the borg comment said was impossible from that tree is possible from this one.
#
# Usage: evals/pr-description/run.sh [--skip-model]
#   --skip-model   skip the cases that need a headless model run (both of them)
#
# EVERY CASE HERE IS A MODEL CASE, which changes the floor arithmetic and is stated rather than
# discovered. The borg harness carries a GLOBAL execution floor because its E2a runs on every
# machine, so "nothing executed" there always means something broke. Here `--skip-model` requests
# nothing, and a run that was asked for nothing and did nothing has not failed — SKIPs never gate
# a mode nobody asked for. So this harness has ONE execution floor, the model-mode floor, and
# under `--skip-model` it says plainly that it has no offline cases and exits 0. A global floor
# would be a permanent red under the flag its own usage line documents, which decision (3) of the
# borg plan's AC6 forbids: a floor nothing can satisfy is not a gate.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="${PLUGINS_EVAL_REPO:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# Guard before the `rm -rf` below: a mis-derived or mis-overridden REPO must not be able to point
# the cleanup at an arbitrary directory. `build-plugins.sh` is the marker because it is TRACKED
# and sits at the root — it knows nothing about where this harness lives, so moving the harness
# cannot break the guard.
if [ ! -f "$REPO/build-plugins.sh" ]; then
    echo "ERROR: REPO does not look like the claude-plugins checkout: $REPO" >&2
    exit 2
fi

OUT="$REPO/evals/pr-description/out"

SKIP_MODEL=0
while [ $# -gt 0 ]; do
    case "$1" in
        --skip-model) SKIP_MODEL=1 ;;
        -h|--help)    echo "usage: evals/pr-description/run.sh [--skip-model]"; exit 0 ;;
        *)            echo "unknown flag: $1" >&2; exit 2 ;;
    esac
    shift
done

# Recreated, not merely ensured: both cases write a body into $OUT and then grep it, so a stale
# artifact from a previous run is a false PASS for a case that produced nothing this time.
rm -rf "$OUT"
mkdir -p "$OUT"

PASS=0; FAIL=0; SKIPPED=0
MODEL_RAN=0
ok()   { echo "  PASS  $1"; PASS=$((PASS+1)); }
bad()  { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP  $1"; SKIPPED=$((SKIPPED+1)); }

# A git identity as ENVIRONMENT VARIABLES, not a written .gitconfig. The fixtures below commit,
# and `git commit` with no resolvable identity is rc 128 on a bare Linux runner while macOS
# silently auto-derives one from getpwuid — the platform-premise trap recorded in
# borg-collective's CLAUDE.md. Env vars beat every config layer with no path resolution, so this
# works whether or not HOME is redirected.
export GIT_AUTHOR_NAME="pr-description eval"
export GIT_AUTHOR_EMAIL="eval@example.invalid"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
export GIT_CONFIG_NOSYSTEM=1

# Build a throwaway git repository the skill can be run inside. $1 is the directory; a second
# argument, when given, is a manifest file copied to .borg/programs/. One commit, because
# /pr-description reads `git log main..HEAD` and `git diff main...HEAD` and a repository with no
# commit at all would fail for a reason unrelated to either assertion.
make_fixture_repo() {
    local dir="$1" manifest="${2:-}"
    mkdir -p "$dir"
    git -C "$dir" init --quiet --initial-branch=main
    printf '# fixture\n\nA throwaway repository for the /pr-description eval.\n' > "$dir/README.md"
    git -C "$dir" add README.md
    git -C "$dir" commit --quiet -m "fixture: initial commit"
    if [ -n "$manifest" ]; then
        mkdir -p "$dir/.borg/programs"
        cp "$manifest" "$dir/.borg/programs/"
        git -C "$dir" add .borg
        git -C "$dir" commit --quiet -m "fixture: declare a program manifest"
    fi
    # A BRANCH WITH A COMMIT ON IT, because /pr-description describes a CHANGE: it reads
    # `git log main..HEAD` and `git diff main...HEAD`, and on a fixture whose HEAD *is* main both
    # are empty, so the skill has nothing to describe and either case could go red for a reason
    # neither one asserts. Leaving HEAD on a feature branch is the difference between testing the
    # skill and testing an empty diff.
    git -C "$dir" checkout --quiet -b feat/fixture-change
    printf '\nA line the fixture branch adds, so main..HEAD is not empty.\n' >> "$dir/README.md"
    git -C "$dir" add README.md
    git -C "$dir" commit --quiet -m "fixture: a change worth describing"
}

TIMEOUT=()
command -v gtimeout >/dev/null 2>&1 && TIMEOUT=(gtimeout 420)

if [ "$SKIP_MODEL" -eq 1 ]; then
    echo "== E4/E5 skipped (--skip-model) =="
    echo "RESULT: 0 pass, 0 fail, 0 skip"
    echo "this harness has no offline cases; --skip-model requested nothing and ran nothing" >&2
    exit 0
fi

echo "== E4: /pr-description reads the manifest =="
if ! command -v claude >/dev/null 2>&1; then
    skip "E4 chain position: claude is not on PATH"
else
    E4_DIR="$OUT/fixture-with-manifest"
    make_fixture_repo "$E4_DIR" "$SCRIPT_DIR/fixtures/programs/ingle-t1-cutover.json"
    (cd "$E4_DIR" && ${TIMEOUT[@]+"${TIMEOUT[@]}"} claude -p "/pr-description" \
        > "$OUT/e4-body.md" 2>"$OUT/e4-stderr.txt")
    claude_rc=$?
    if [ "$claude_rc" -ne 0 ]; then
        # A BROKEN CLI IS NOT A BROKEN SKILL, and this arm is the whole difference. `command -v
        # claude` proves the binary is on PATH, not that it can run: not logged in, usage limit
        # reached, network down and model unavailable all exit non-zero, leave a 0-byte body, and
        # would fail every grep below -- so the harness reported `FAIL E4 chain position` and rc 1
        # when the truth was "your CLI is not authenticated", with the reason sitting unread in
        # e4-stderr.txt. That is the exact conflation borg's E2 refuses for the 401 analog. SKIP,
        # not FAIL, and MODEL_RAN is deliberately NOT incremented: the case did not execute, so the
        # model floor below still fires and says the sweep was asked for and did not happen.
        skip "E4 chain position: claude exited $claude_rc -- $(head -c 200 "$OUT/e4-stderr.txt" | tr '\n' ' ')"
    else
        # Three clauses, and the third is the one that makes this a test rather than a smoke check:
        # the program name must appear AND the fallback line must be absent. A skill that emitted
        # both would satisfy a name-only assertion while having failed to discriminate.
        if grep -q "ingle-t1-cutover" "$OUT/e4-body.md" && \
           grep -qi "cutover" "$OUT/e4-body.md" && \
           ! grep -q "No manifest declared" "$OUT/e4-body.md"; then
            ok "E4 chain position rendered from the manifest"
        else
            bad "E4 chain position (see $OUT/e4-body.md)"
        fi
        MODEL_RAN=$((MODEL_RAN+1))
    fi
fi

echo "== E5: fallback path in a manifest-less repository =="
if ! command -v claude >/dev/null 2>&1; then
    skip "E5 fallback: claude is not on PATH"
else
    E5_DIR="$OUT/fixture-no-manifest"
    make_fixture_repo "$E5_DIR"
    (cd "$E5_DIR" && ${TIMEOUT[@]+"${TIMEOUT[@]}"} claude -p "/pr-description" \
        > "$OUT/e5-body.md" 2>"$OUT/e5-stderr.txt")
    claude_rc=$?
    if [ "$claude_rc" -ne 0 ]; then
        skip "E5 fallback: claude exited $claude_rc -- $(head -c 200 "$OUT/e5-stderr.txt" | tr '\n' ' ')"
    else
        if grep -q "No manifest declared" "$OUT/e5-body.md"; then
            ok "E5 fallback line present"
        else
            bad "E5 fallback (see $OUT/e5-body.md)"
        fi
        MODEL_RAN=$((MODEL_RAN+1))
    fi
fi

echo "RESULT: $PASS pass, $FAIL fail, $SKIPPED skip"

# THE MODEL-MODE EXECUTION FLOOR. Reaching here means `--skip-model` was absent, which is a
# REQUEST for the model sweep; a run that asked for that sweep and executed none of it has failed
# at the thing it was asked to do, and must not report success. SKIPs do not gate — `claude`
# absent is a different fact from `claude` wrong — but "every case skipped" and "every case
# passed" printed the same rc 0 before this floor existed, which is the defect the borg plan's
# AC6 decision (5) exists to prevent. Ordered before the FAIL check so the more specific reason
# is the one printed.
if [ "$MODEL_RAN" -eq 0 ]; then
    echo "the model sweep was requested but no model case executed" >&2
    exit 1
fi
[ "$FAIL" -eq 0 ]
