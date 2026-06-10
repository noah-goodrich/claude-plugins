#!/usr/bin/env bash
# backfill-spend.sh — ONE-TIME backfill of ~/.claude/token-spend.jsonl from the
# existing durable session transcripts, so historical spend is captured (not just
# future sessions). Idempotent: skips sessions already present in the log.
#
# Reuses token-spend-log.sh per session (identical record format), passing the
# session's real end-timestamp via TOKEN_SPEND_TS. Set EXCLUDE_SESSION to skip the
# live session (its SessionEnd hook will record it when it ends).
#
# Usage:
#   token-cost/scripts/backfill-spend.sh
#   EXCLUDE_SESSION=<live-session-id> TOKEN_SPEND_LOG=/tmp/test.jsonl ./backfill-spend.sh

set -uo pipefail

LOG="${TOKEN_SPEND_LOG:-$HOME/.claude/token-spend.jsonl}"
EXCLUDE_SESSION="${EXCLUDE_SESSION:-}"
PROJECTS="${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../hooks/token-spend-log.sh"

command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 1; }
[ -f "$HOOK" ] || { echo "hook not found: $HOOK" >&2; exit 1; }
[ -d "$PROJECTS" ] || { echo "no projects dir: $PROJECTS" >&2; exit 1; }
mkdir -p "$(dirname "$LOG")"; touch "$LOG"

added=0
# Only top-level <project>/<session-id>.jsonl are sessions; subagent transcripts
# live deeper (under <session-id>/subagents/) and are excluded by -maxdepth 2.
while IFS= read -r tr; do
    sid="${tr##*/}"; sid="${sid%.jsonl}"
    [ "$sid" = "$EXCLUDE_SESSION" ] && continue
    grep -q "\"session_id\":\"$sid\"" "$LOG" 2>/dev/null && continue
    ts=$(jq -rs '[.[].timestamp // empty] | last // ""' "$tr" 2>/dev/null)
    cwd=$(jq -rs '[.[].cwd // empty] | last // ""' "$tr" 2>/dev/null)
    payload=$(jq -nc --arg s "$sid" --arg t "$tr" --arg c "$cwd" \
        '{session_id:$s, transcript_path:$t, cwd:$c, reason:"backfill"}')
    printf '%s' "$payload" | TOKEN_SPEND_TS="$ts" TOKEN_SPEND_LOG="$LOG" bash "$HOOK" && added=$((added + 1))
done < <(find "$PROJECTS" -maxdepth 2 -name '*.jsonl' -type f)

echo "backfill: added $added new session record(s) to $LOG"
