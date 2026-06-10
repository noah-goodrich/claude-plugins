#!/usr/bin/env bash
# token-spend-log.sh — SessionEnd hook (token-cost plugin).
#
# Appends ONE record per session to ~/.claude/token-spend.jsonl (append-only,
# durable across sessions). DATA COLLECTION ONLY — no analysis/consumption here.
#
# Stores a per-MODEL token breakdown for the main loop and for subagents, kept
# separate. Per-model is required because a single session mixes models (main on
# Opus; subagents on Sonnet/Haiku), and model-tier routing will widen that. The
# raw per-model counts make cost recomputable at ANY future pricing. A cache-aware
# est_cost_usd is included as the headline number to sum across sessions.
#
# Reads the SessionEnd payload on stdin (session_id, transcript_path, cwd, reason).
# ALWAYS exits 0 — must never disrupt session teardown. Override the log path with
# TOKEN_SPEND_LOG. History is reconstructable from the durable transcripts if a
# SessionEnd is ever missed (crash), so a backfill is possible later.

LOG="${TOKEN_SPEND_LOG:-$HOME/.claude/token-spend.jsonl}"

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null || true)
TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // ""' 2>/dev/null)
[ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ] || exit 0

SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)
REASON=$(printf '%s' "$INPUT" | jq -r '.reason // ""' 2>/dev/null)

# Per-model usage breakdown across assistant messages in the given file(s):
#   { "<model>": {input, output, cache_creation, cache_read}, ... }
_bymodel() {
    jq -cs '[.[] | select(.message.usage? != null)
              | {m:(.message.model // "unknown"), u:.message.usage}]
        | group_by(.m)
        | map({(.[0].m): {
            input:(map(.u.input_tokens//0)|add // 0),
            output:(map(.u.output_tokens//0)|add // 0),
            cache_creation:(map(.u.cache_creation_input_tokens//0)|add // 0),
            cache_read:(map(.u.cache_read_input_tokens//0)|add // 0)}})
        | add // {}
        | with_entries(select((.value | .input + .output + .cache_creation + .cache_read) > 0))' "$@" 2>/dev/null
}

# Cache-aware cost (USD) of a per-model breakdown. Rates per million tokens.
_costof() {
    jq -n --argjson bm "$1" '
        def rate(m): (m|ascii_downcase) as $m
          | if   ($m|test("opus"))   then {i:15,   o:75,   w:18.75, r:1.50}
            elif ($m|test("sonnet")) then {i:3,    o:15,   w:3.75,  r:0.30}
            elif ($m|test("haiku"))  then {i:0.25, o:1.25, w:0.31,  r:0.025}
            else {i:15, o:75, w:18.75, r:1.50} end;
        ([ $bm | to_entries[] | .value as $u | rate(.key) as $r
           | $u.input*$r.i + $u.output*$r.o + $u.cache_creation*$r.w + $u.cache_read*$r.r ]
         | add // 0) / 1000000' 2>/dev/null
}

MAIN_BM=$(_bymodel "$TRANSCRIPT"); [ -n "$MAIN_BM" ] || MAIN_BM='{}'

# Subagent transcripts (direct + workflow) live under <transcript>/subagents/.
SUBDIR="${TRANSCRIPT%.jsonl}/subagents"
AGENT_COUNT=0
SUB_BM='{}'
if [ -d "$SUBDIR" ]; then
    sub_files=()
    while IFS= read -r f; do sub_files+=("$f"); done < <(find "$SUBDIR" -name 'agent-*.jsonl' 2>/dev/null)
    AGENT_COUNT=${#sub_files[@]}
    if [ "$AGENT_COUNT" -gt 0 ]; then
        b=$(_bymodel "${sub_files[@]}"); [ -n "$b" ] && SUB_BM="$b"
    fi
fi

MAIN_COST=$(_costof "$MAIN_BM"); [ -n "$MAIN_COST" ] || MAIN_COST=0
SUB_COST=$(_costof "$SUB_BM"); [ -n "$SUB_COST" ] || SUB_COST=0
COST=$(jq -n --argjson a "$MAIN_COST" --argjson b "$SUB_COST" '(($a + $b) * 100 | round) / 100' 2>/dev/null)
[ -n "$COST" ] || COST=0

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PROJECT="${CWD##*/}"

mkdir -p "$(dirname "$LOG")"
jq -nc --arg ts "$TS" --arg sid "$SESSION_ID" --arg proj "$PROJECT" --arg cwd "$CWD" \
    --arg reason "$REASON" --argjson mainbm "$MAIN_BM" --argjson subbm "$SUB_BM" \
    --argjson agents "$AGENT_COUNT" --argjson maincost "$MAIN_COST" --argjson subcost "$SUB_COST" \
    --argjson cost "$COST" \
    '{schema:1, ts:$ts, session_id:$sid, project:$proj, cwd:$cwd, end_reason:$reason,
      main:{by_model:$mainbm, est_cost_usd:(($maincost*100|round)/100)},
      subagents:{by_model:$subbm, agent_count:$agents, est_cost_usd:(($subcost*100|round)/100)},
      est_cost_usd:$cost}' \
    >> "$LOG" 2>/dev/null

exit 0
