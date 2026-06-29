#!/usr/bin/env bats
# token-spend-log.bats — smoke tests for token-cost/hooks/token-spend-log.sh
#
# Focus: deterministic, hermetic behaviours.
#   1. Guard — exits 0 when jq is missing OR transcript is absent/invalid
#   2. Output shape — valid JSONL line appended to log for a synthetic transcript
#   3. Schema contract — required top-level keys present and correctly typed
#   4. Multi-model — per-model breakdown captured when transcript mixes models
#   5. Subagent dir — agent_count incremented when subagent transcripts exist
#   6. Cost floor — est_cost_usd is a non-negative number
#   7. Empty transcript — no crash, exits 0, nothing written
#   8-9. Project attribution (Desktop / worktree)
#  10. by_type — per-agent-type breakdown populated from meta.json siblings
#  11. by_type — unknown fallback when meta.json is absent
#  12. schema version bumped to 2
#   7. Empty transcript — no crash, exits 0, nothing written

HOOK="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/token-spend-log.sh"
FIXTURES="$(dirname "$BATS_TEST_FILENAME")/fixtures"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

setup() {
    export BATS_TMPDIR="${BATS_TMPDIR:-/tmp}"
    export TOKEN_SPEND_LOG="$BATS_TMPDIR/test-spend.jsonl"
    rm -f "$TOKEN_SPEND_LOG"
    mkdir -p "$BATS_TMPDIR/transcripts"
}

# Build a minimal transcript JSONL file with N assistant messages.
# Usage: _mk_transcript <path> <model> <input> <output> [<cache_creation>] [<cache_read>]
_mk_transcript() {
    local path="$1" model="$2" inp="$3" out="$4" cc="${5:-0}" cr="${6:-0}"
    printf '{"message":{"role":"assistant","model":"%s","content":"hello","usage":{"input_tokens":%d,"output_tokens":%d,"cache_creation_input_tokens":%d,"cache_read_input_tokens":%d}}}\n' \
        "$model" "$inp" "$out" "$cc" "$cr" > "$path"
}

# ---------------------------------------------------------------------------
# 1. Guard cases
# ---------------------------------------------------------------------------

@test "guard: exits 0 when transcript_path is absent from input" {
    run bash "$HOOK" <<< '{"session_id":"s1","cwd":"/tmp"}'
    [ "$status" -eq 0 ]
}

@test "guard: exits 0 when transcript file does not exist on disk" {
    run bash "$HOOK" <<< '{"session_id":"s1","cwd":"/tmp","transcript_path":"/nonexistent/path.jsonl"}'
    [ "$status" -eq 0 ]
}

@test "guard: exits 0 on empty stdin" {
    run bash "$HOOK" < /dev/null
    [ "$status" -eq 0 ]
}

@test "guard: nothing written to log when transcript missing" {
    bash "$HOOK" <<< '{"session_id":"s1","cwd":"/tmp"}' 2>/dev/null || true
    [ ! -f "$TOKEN_SPEND_LOG" ]
}

# ---------------------------------------------------------------------------
# 2. Output shape — well-formed JSONL for a synthetic transcript
# ---------------------------------------------------------------------------

@test "output: appends exactly one line to log" {
    local t="$BATS_TMPDIR/transcripts/single.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 1000 500

    bash "$HOOK" <<< "{\"session_id\":\"sess-1\",\"cwd\":\"/tmp/proj\",\"transcript_path\":\"$t\"}" 2>/dev/null
    [ -f "$TOKEN_SPEND_LOG" ]
    count=$(wc -l < "$TOKEN_SPEND_LOG" | tr -d ' ')
    [ "$count" -eq 1 ]
}

@test "output: line is valid JSON" {
    local t="$BATS_TMPDIR/transcripts/valid.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 1000 500

    bash "$HOOK" <<< "{\"session_id\":\"sess-1\",\"cwd\":\"/tmp/proj\",\"transcript_path\":\"$t\"}" 2>/dev/null
    jq . "$TOKEN_SPEND_LOG" > /dev/null
}

@test "output: second run appends (does not overwrite) existing log" {
    local t="$BATS_TMPDIR/transcripts/append.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp\",\"transcript_path\":\"$t\"}" 2>/dev/null
    bash "$HOOK" <<< "{\"session_id\":\"s2\",\"cwd\":\"/tmp\",\"transcript_path\":\"$t\"}" 2>/dev/null

    count=$(wc -l < "$TOKEN_SPEND_LOG" | tr -d ' ')
    [ "$count" -eq 2 ]
}

# ---------------------------------------------------------------------------
# 3. Schema contract — required keys
# ---------------------------------------------------------------------------

@test "schema: record has schema=2" {
    local t="$BATS_TMPDIR/transcripts/schema.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 1000 500

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.schema' "$TOKEN_SPEND_LOG")
    [ "$val" = "2" ]
}

@test "schema: record has ts field" {
    local t="$BATS_TMPDIR/transcripts/ts.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 1000 500

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.ts' "$TOKEN_SPEND_LOG")
    [ -n "$val" ] && [ "$val" != "null" ]
}

@test "schema: record stores session_id" {
    local t="$BATS_TMPDIR/transcripts/sid.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 1000 500

    bash "$HOOK" <<< "{\"session_id\":\"my-session-id\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.session_id' "$TOKEN_SPEND_LOG")
    [ "$val" = "my-session-id" ]
}

@test "schema: record stores project derived from cwd basename" {
    local t="$BATS_TMPDIR/transcripts/proj.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/home/user/my-project\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.project' "$TOKEN_SPEND_LOG")
    [ "$val" = "my-project" ]
}

@test "schema: record has main.by_model object" {
    local t="$BATS_TMPDIR/transcripts/main-bm.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 1000 500

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.main.by_model | type' "$TOKEN_SPEND_LOG")
    [ "$val" = "object" ]
}

@test "schema: record has subagents.agent_count as a number" {
    local t="$BATS_TMPDIR/transcripts/agents.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 1000 500

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.subagents.agent_count | type' "$TOKEN_SPEND_LOG")
    [ "$val" = "number" ]
}

@test "schema: est_cost_usd is a number" {
    local t="$BATS_TMPDIR/transcripts/cost.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 1000 500

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.est_cost_usd | type' "$TOKEN_SPEND_LOG")
    [ "$val" = "number" ]
}

# ---------------------------------------------------------------------------
# 4. Per-model breakdown captured
# ---------------------------------------------------------------------------

@test "per-model: sonnet model key present in main.by_model" {
    local t="$BATS_TMPDIR/transcripts/sonnet.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 2000 800

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    count=$(jq -r '.main.by_model | keys | length' "$TOKEN_SPEND_LOG")
    [ "$count" -ge 1 ]
}

@test "per-model: input_tokens accumulated correctly" {
    local t="$BATS_TMPDIR/transcripts/tokens.jsonl"
    _mk_transcript "$t" "claude-opus-4-5" 3000 1000

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    # Get the first model's input token count
    inp=$(jq -r '.main.by_model | to_entries[0].value.input' "$TOKEN_SPEND_LOG")
    [ "$inp" -eq 3000 ]
}

# ---------------------------------------------------------------------------
# 5. Subagent directory
# ---------------------------------------------------------------------------

@test "subagents: agent_count=0 when no subagent dir" {
    local t="$BATS_TMPDIR/transcripts/no-sub.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.subagents.agent_count' "$TOKEN_SPEND_LOG")
    [ "$val" -eq 0 ]
}

@test "subagents: agent_count reflects files in subagents dir" {
    local t="$BATS_TMPDIR/transcripts/with-sub.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    local subdir="${t%.jsonl}/subagents"
    mkdir -p "$subdir"
    _mk_transcript "$subdir/agent-1.jsonl" "claude-haiku-3-5" 200 100
    _mk_transcript "$subdir/agent-2.jsonl" "claude-haiku-3-5" 300 150

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.subagents.agent_count' "$TOKEN_SPEND_LOG")
    [ "$val" -eq 2 ]
}

@test "subagents: by_model populated from subagent transcripts" {
    local t="$BATS_TMPDIR/transcripts/sub-bm.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    local subdir="${t%.jsonl}/subagents"
    mkdir -p "$subdir"
    _mk_transcript "$subdir/agent-1.jsonl" "claude-haiku-3-5" 100 50

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    sub_keys=$(jq -r '.subagents.by_model | keys | length' "$TOKEN_SPEND_LOG")
    [ "$sub_keys" -ge 1 ]
}

# ---------------------------------------------------------------------------
# 6. Cost floor
# ---------------------------------------------------------------------------

@test "cost: est_cost_usd is non-negative" {
    local t="$BATS_TMPDIR/transcripts/nonneg.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 1000 500

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.est_cost_usd' "$TOKEN_SPEND_LOG")
    # val must be >= 0 — use -r to strip JSON string quotes
    result=$(jq -rn --argjson v "$val" 'if $v >= 0 then "ok" else "fail" end')
    [ "$result" = "ok" ]
}

@test "cost: positive tokens produce positive cost" {
    local t="$BATS_TMPDIR/transcripts/positive.jsonl"
    _mk_transcript "$t" "claude-opus-4-5" 100000 50000

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.est_cost_usd' "$TOKEN_SPEND_LOG")
    result=$(jq -rn --argjson v "$val" 'if $v > 0 then "ok" else "fail" end')
    [ "$result" = "ok" ]
}

# ---------------------------------------------------------------------------
# 7. Empty transcript — no crash
# ---------------------------------------------------------------------------

@test "empty transcript: exits 0" {
    local t="$BATS_TMPDIR/transcripts/empty.jsonl"
    printf '' > "$t"

    run bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}"
    [ "$status" -eq 0 ]
}

@test "empty transcript: log line still written with zero token counts" {
    local t="$BATS_TMPDIR/transcripts/empty2.jsonl"
    printf '' > "$t"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    [ -f "$TOKEN_SPEND_LOG" ]
    jq . "$TOKEN_SPEND_LOG" > /dev/null
}

@test "TOKEN_SPEND_TS override: record uses provided timestamp" {
    local t="$BATS_TMPDIR/transcripts/ts-override.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 100 50
    export TOKEN_SPEND_TS="2025-01-15T10:00:00Z"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.ts' "$TOKEN_SPEND_LOG")
    [ "$val" = "2025-01-15T10:00:00Z" ]
    unset TOKEN_SPEND_TS
}

# ---------------------------------------------------------------------------
# 8. Claude Desktop project attribution
# ---------------------------------------------------------------------------

@test "desktop: cwd under local-agent-mode-sessions yields project=claude-desktop" {
    local t="$BATS_TMPDIR/transcripts/desktop.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    local desktop_cwd="/Users/x/Library/Application Support/Claude/local-agent-mode-sessions/abc-uuid/def/outputs"
    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$desktop_cwd\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.project' "$TOKEN_SPEND_LOG")
    [ "$val" = "claude-desktop" ]
}

@test "desktop: normal cwd still yields project from basename" {
    local t="$BATS_TMPDIR/transcripts/normal-proj.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/home/user/my-project\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.project' "$TOKEN_SPEND_LOG")
    [ "$val" = "my-project" ]
}

# ---------------------------------------------------------------------------
# 9. Claude Code worktree project attribution
# ---------------------------------------------------------------------------

@test "worktree: cwd under .claude/worktrees yields parent project name" {
    local t="$BATS_TMPDIR/transcripts/worktree.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/Users/x/dev/my-project/.claude/worktrees/abc-slug\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.project' "$TOKEN_SPEND_LOG")
    [ "$val" = "my-project" ]
}

@test "worktree: normal cwd still yields project from basename (regression guard)" {
    local t="$BATS_TMPDIR/transcripts/worktree-normal.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/Users/x/dev/some-project\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.project' "$TOKEN_SPEND_LOG")
    [ "$val" = "some-project" ]
}

# ---------------------------------------------------------------------------
# 10. by_type — per-agent-type breakdown from meta.json
# ---------------------------------------------------------------------------

# Helper: write a meta.json sibling for a given agent jsonl path.
_mk_meta() {
    local agent_path="$1" agent_type="$2"
    printf '{"agentType":"%s","description":"test agent","toolUseId":"toolu_test"}\n' \
        "$agent_type" > "${agent_path%.jsonl}.meta.json"
}

@test "by_type: subagents.by_type is an object" {
    local t="$BATS_TMPDIR/transcripts/bt-shape.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    local subdir="${t%.jsonl}/subagents"
    mkdir -p "$subdir"
    _mk_transcript "$subdir/agent-1.jsonl" "claude-haiku-3-5" 100 50
    _mk_meta       "$subdir/agent-1.jsonl" "borg-grunt"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.subagents.by_type | type' "$TOKEN_SPEND_LOG")
    [ "$val" = "object" ]
}

@test "by_type: agent type key present when meta.json exists" {
    local t="$BATS_TMPDIR/transcripts/bt-key.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    local subdir="${t%.jsonl}/subagents"
    mkdir -p "$subdir"
    _mk_transcript "$subdir/agent-1.jsonl" "claude-haiku-3-5" 200 80
    _mk_meta       "$subdir/agent-1.jsonl" "borg-nanoprobe"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    has=$(jq -r '.subagents.by_type | has("borg-nanoprobe")' "$TOKEN_SPEND_LOG")
    [ "$has" = "true" ]
}

@test "by_type: token counts accumulate correctly for a type" {
    local t="$BATS_TMPDIR/transcripts/bt-accum.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    local subdir="${t%.jsonl}/subagents"
    mkdir -p "$subdir"
    _mk_transcript "$subdir/agent-1.jsonl" "claude-haiku-3-5" 300 100
    _mk_meta       "$subdir/agent-1.jsonl" "borg-grunt"
    _mk_transcript "$subdir/agent-2.jsonl" "claude-haiku-3-5" 200 80
    _mk_meta       "$subdir/agent-2.jsonl" "borg-grunt"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    inp=$(jq -r '.subagents.by_type["borg-grunt"].input' "$TOKEN_SPEND_LOG")
    [ "$inp" -eq 500 ]
}

@test "by_type: multiple types are tracked separately" {
    local t="$BATS_TMPDIR/transcripts/bt-multi.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    local subdir="${t%.jsonl}/subagents"
    mkdir -p "$subdir"
    _mk_transcript "$subdir/agent-1.jsonl" "claude-haiku-3-5" 100 40
    _mk_meta       "$subdir/agent-1.jsonl" "borg-grunt"
    _mk_transcript "$subdir/agent-2.jsonl" "claude-sonnet-4-5" 800 300
    _mk_meta       "$subdir/agent-2.jsonl" "borg-nanoprobe"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    type_count=$(jq -r '.subagents.by_type | keys | length' "$TOKEN_SPEND_LOG")
    [ "$type_count" -eq 2 ]
}

@test "by_type: missing meta.json falls back to unknown bucket" {
    local t="$BATS_TMPDIR/transcripts/bt-nometa.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    local subdir="${t%.jsonl}/subagents"
    mkdir -p "$subdir"
    _mk_transcript "$subdir/agent-1.jsonl" "claude-haiku-3-5" 150 60
    # deliberately do NOT create a meta.json

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    has=$(jq -r '.subagents.by_type | has("unknown")' "$TOKEN_SPEND_LOG")
    [ "$has" = "true" ]
}

@test "by_type: empty object when no subagents exist" {
    local t="$BATS_TMPDIR/transcripts/bt-empty.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.subagents.by_type | type' "$TOKEN_SPEND_LOG")
    [ "$val" = "object" ]
    cnt=$(jq -r '.subagents.by_type | keys | length' "$TOKEN_SPEND_LOG")
    [ "$cnt" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 12. Back-compat: existing fields still present (regression guard for schema 2)
# ---------------------------------------------------------------------------

@test "back-compat: subagents.by_model still present in schema 2" {
    local t="$BATS_TMPDIR/transcripts/bc-bm.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    local subdir="${t%.jsonl}/subagents"
    mkdir -p "$subdir"
    _mk_transcript "$subdir/agent-1.jsonl" "claude-haiku-3-5" 100 40
    _mk_meta       "$subdir/agent-1.jsonl" "borg-grunt"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.subagents.by_model | type' "$TOKEN_SPEND_LOG")
    [ "$val" = "object" ]
}

@test "back-compat: subagents.agent_count still present in schema 2" {
    local t="$BATS_TMPDIR/transcripts/bc-ac.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    local subdir="${t%.jsonl}/subagents"
    mkdir -p "$subdir"
    _mk_transcript "$subdir/agent-1.jsonl" "claude-haiku-3-5" 100 40
    _mk_meta       "$subdir/agent-1.jsonl" "borg-scout"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.subagents.agent_count | type' "$TOKEN_SPEND_LOG")
    [ "$val" = "number" ]
}

@test "back-compat: subagents.est_cost_usd still present in schema 2" {
    local t="$BATS_TMPDIR/transcripts/bc-cost.jsonl"
    _mk_transcript "$t" "claude-sonnet-4-5" 500 200

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"/tmp/p\",\"transcript_path\":\"$t\"}" 2>/dev/null
    val=$(jq -r '.subagents.est_cost_usd | type' "$TOKEN_SPEND_LOG")
    [ "$val" = "number" ]
}
