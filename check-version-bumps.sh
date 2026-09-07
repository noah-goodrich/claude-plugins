#!/usr/bin/env bash
# check-version-bumps.sh — fail when a plugin's content changed but its version did not.
#
# WHY THIS EXISTS
#   `claude plugin update` compares version STRINGS. It never looks at content. So a plugin whose
#   files changed under an unchanged version number is served stale from the install cache forever,
#   and the updater cheerfully reports "already at the latest version".
#
#   On 2026-09-07 three plugins were in exactly that state at once:
#     borg-collective  0.8.9   — cached at a six-week-old commit
#     token-cost       0.1.34  — cached hook missing the BORG_NO_SPEND_RECORD guard, so every
#                                borg-usage-watch poll kept writing junk records to the ledger
#     code-governance  0.1.0   — registered at a cache path that did not exist
#   Versions in plugin.json are bumped by hand and nothing derived them, so nothing caught it.
#
# WHAT IT CHECKS
#   For each plugin in .claude-plugin/marketplace.json: if any tracked file under <plugin>/ differs
#   from the base ref, then <plugin>/.claude-plugin/plugin.json's "version" must ALSO differ from
#   the base ref. Equal content is fine; changed content with a frozen version is the failure.
#
#   The version need only CHANGE. Ordering is not enforced: plugin.json carries no ordering
#   contract, and a rollback is a legitimate change this guard has no business rejecting.
#
# WHAT THIS IS NOT
#   This DETECTS drift at PR time; it does not prevent it. It cannot see a version that went stale
#   in a source repo before the generated copy was committed here — for borg-collective that
#   happens one hop upstream, in ~/dev/borg-collective, and is guarded there by build-plugin.sh
#   refusing to emit changed content under an unchanged VERSION. Prevention belongs at generation
#   time; this is the backstop for the hand-authored plugins that have no build step.
#
# USAGE
#   ./check-version-bumps.sh [base-ref]      # default base ref: origin/main
#
# EXIT
#   0 = every changed plugin bumped its version (or nothing changed)
#   1 = at least one plugin changed content without bumping
#   2 = the check could not be performed (bad base ref, missing jq, not a git repo)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

BASE_REF="${1:-origin/main}"

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required" >&2; exit 2; }
git rev-parse --git-dir >/dev/null 2>&1 || { echo "ERROR: not a git repository" >&2; exit 2; }

# Resolve the comparison point. Prefer the merge base so a stale branch is judged on what IT
# changed, not on everything main gained meanwhile — otherwise every plugin main touched would be
# reported against a branch that never went near it.
if ! base_sha="$(git merge-base "$BASE_REF" HEAD 2>/dev/null)"; then
    if ! base_sha="$(git rev-parse --verify "$BASE_REF" 2>/dev/null)"; then
        echo "ERROR: cannot resolve base ref: $BASE_REF" >&2
        echo "  In CI, fetch enough history for a merge base (actions/checkout fetch-depth: 0)." >&2
        exit 2
    fi
    echo "NOTE: no merge base with $BASE_REF; comparing against it directly." >&2
fi

# Read the plugin list portably: macOS ships bash 3.2, which has no `mapfile`, and this script is
# meant to run locally (where the drift actually bites) as well as on ubuntu CI.
plugins=()
while IFS= read -r name; do
    [[ -n "$name" ]] && plugins+=("$name")
done < <(jq -r '.plugins[].name' .claude-plugin/marketplace.json)

failed=0
checked=0

for plugin in "${plugins[@]}"; do
    manifest="$plugin/.claude-plugin/plugin.json"

    # A missing directory or manifest is NOT this script's failure to report. build-plugins.sh's
    # verify_marketplace() already asserts that invariant in both directions, and the `marketplace`
    # CI job runs it on every PR. Duplicating it here would fail two jobs for one cause and leave
    # two error formats to keep in step. Skip and let the owner of that check own it.
    [[ -d "$plugin" && -f "$manifest" ]] || continue

    # Files under this plugin that differ from the base. A plugin absent from the base ref is new,
    # and a new plugin has nothing to bump against, so treat it as clean.
    changed="$(git diff --name-only "$base_sha" -- "$plugin/" || true)"
    if [[ -z "$changed" ]]; then
        continue
    fi
    checked=$((checked + 1))

    now_version="$(jq -r '.version // empty' "$manifest")"
    if [[ -z "$now_version" ]]; then
        echo "ERROR: $plugin — plugin.json has no \"version\""
        failed=1
        continue
    fi

    if ! base_manifest="$(git show "$base_sha:$manifest" 2>/dev/null)"; then
        echo "OK:    $plugin $now_version (new plugin — nothing to bump against)"
        continue
    fi
    base_version="$(printf '%s' "$base_manifest" | jq -r '.version // empty')"

    if [[ "$now_version" != "$base_version" ]]; then
        echo "OK:    $plugin $base_version -> $now_version"
        continue
    fi

    # Content changed, version frozen. This is the drift that ships stale plugins.
    echo "ERROR: $plugin — content changed but version is still $now_version"
    printf '%s\n' "$changed" | head -5 | sed 's/^/         /'
    n=$(printf '%s\n' "$changed" | wc -l | tr -d ' ')
    [[ "$n" -gt 5 ]] && echo "         ... and $((n - 5)) more"
    echo "         Fix: bump \"version\" in $manifest"
    # No per-plugin branch here on purpose. An earlier draft hardcoded borg-collective's name and a
    # path on one developer's laptop; that is wrong in CI, wrong on any other checkout, and needs a
    # copy-pasted twin for the next generated plugin. State the generated case generically instead.
    echo "         If this plugin is generated from another repo, bump the version THERE and"
    echo "         re-run that repo's build script — editing this copy is overwritten next build."
    failed=1
done

echo
if [[ "$failed" -ne 0 ]]; then
    echo "FAILED: a plugin changed without a version bump."
    echo "Without the bump, 'claude plugin update' reports 'already at the latest version' and"
    echo "every install keeps serving the cached copy. Bump the version(s) above."
    exit 1
fi

if [[ "$checked" -eq 0 ]]; then
    echo "OK: no plugin content changed against ${BASE_REF}."
else
    echo "OK: all $checked changed plugin(s) bumped their version."
fi
