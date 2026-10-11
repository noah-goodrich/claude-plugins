#!/usr/bin/env bash
# Asserts repo-review spawns the Haiku scout, not the Opus-inheriting built-in Explore agent.
set -u
SKILL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/SKILL.md"
fail=0
check() { if ! grep -Eq -- "$2" "$SKILL"; then echo "FAIL: $1"; fail=1; else echo "ok: $1"; fi; }
if grep -Eq "Explore subagent" "$SKILL"; then echo "FAIL: still launches Explore subagents"; fail=1; else echo "ok: no Explore subagents"; fi
check "uses borg-collective:borg-scout" "subagent_type.*borg-collective:borg-scout"
check "notes borg-collective dependency" "[Rr]equires.*borg-collective|borg-collective.*(plugin|dependency)"
check "has fallback sentence" "[Ii]f borg-collective is not installed"
exit "$fail"
