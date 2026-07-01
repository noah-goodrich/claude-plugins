#!/usr/bin/env bats
# truncate-tool-output.bats — smoke tests for token-cost/hooks/truncate-tool-output.sh
#
# Focus: deterministic, hermetic behaviours of the OPT-IN truncation hook.
#   1. Opt-in gate — does nothing (empty output) unless TRUNCATE_TOOL_OUTPUT=1
#   2. Over threshold — large Bash output is replaced with head+tail+marker
#   3. Under threshold — small output is left byte-unchanged (no hook output)
#   4. Tool filter — only Bash/Read are touched
#   5. Shape — both string and {stdout:...} tool_response shapes handled
#   6. Fail-safe — malformed / empty stdin exits 0 with no output
#   7. Marker — replacement names the omitted-line count + retrieval hint

HOOK="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/truncate-tool-output.sh"

# N lines of synthetic text ("line 1\nline 2\n...").
_lines() { seq 1 "$1" | sed 's/^/line /'; }

# PostToolUse payload with an object tool_response ({stdout: <text>}).
_obj_input() { _lines "$2" | jq -Rs --arg t "$1" '{tool_name:$t, tool_response:{stdout:.}}'; }

# PostToolUse payload with a bare-string tool_response.
_str_input() { _lines "$2" | jq -Rs --arg t "$1" '{tool_name:$t, tool_response:.}'; }

# ---------------------------------------------------------------------------
# 1. Opt-in gate
# ---------------------------------------------------------------------------

@test "opt-in: disabled (env unset) → exits 0, no output even for 500 lines" {
    run bash "$HOOK" <<< "$(_obj_input Bash 500)"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "opt-in: TRUNCATE_TOOL_OUTPUT=0 → no output" {
    run env TRUNCATE_TOOL_OUTPUT=0 bash "$HOOK" <<< "$(_obj_input Bash 500)"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# ---------------------------------------------------------------------------
# 2. Over threshold → truncated
# ---------------------------------------------------------------------------

@test "over threshold: 500-line Bash output is replaced + valid JSON + marker" {
    run env TRUNCATE_TOOL_OUTPUT=1 bash "$HOOK" <<< "$(_obj_input Bash 500)"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "PostToolUse"' >/dev/null
    echo "$output" | jq -e '.hookSpecificOutput.updatedToolOutput | type == "string"' >/dev/null
    echo "$output" | grep -q "truncated by token-cost"
}

@test "over threshold: replacement is materially shorter than the original" {
    run env TRUNCATE_TOOL_OUTPUT=1 bash "$HOOK" <<< "$(_obj_input Bash 500)"
    nl="$(echo "$output" | jq -r '.hookSpecificOutput.updatedToolOutput' | wc -l | tr -d ' ')"
    # default head(120)+tail(40)+marker(1) ≈ 161 lines, well under the 500 original
    [ "$nl" -lt 200 ]
    [ "$nl" -gt 100 ]
}

@test "over threshold: head and tail content are both preserved" {
    run env TRUNCATE_TOOL_OUTPUT=1 bash "$HOOK" <<< "$(_obj_input Bash 500)"
    body="$(echo "$output" | jq -r '.hookSpecificOutput.updatedToolOutput')"
    echo "$body" | grep -q "^line 1$"
    echo "$body" | grep -q "^line 500$"
    echo "$body" | grep -qv "^line 300$"   # a middle line is gone
}

# ---------------------------------------------------------------------------
# 3. Under threshold → unchanged
# ---------------------------------------------------------------------------

@test "under threshold: 50-line output → no hook output (byte-unchanged)" {
    run env TRUNCATE_TOOL_OUTPUT=1 bash "$HOOK" <<< "$(_obj_input Bash 50)"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# ---------------------------------------------------------------------------
# 4. Tool filter
# ---------------------------------------------------------------------------

@test "tool filter: non-Bash/Read tool is never touched" {
    run env TRUNCATE_TOOL_OUTPUT=1 bash "$HOOK" <<< "$(_obj_input Edit 500)"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "tool filter: Read with large output IS truncated" {
    run env TRUNCATE_TOOL_OUTPUT=1 bash "$HOOK" <<< "$(_str_input Read 500)"
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.updatedToolOutput' >/dev/null
    echo "$output" | grep -q "truncated by token-cost"
}

# ---------------------------------------------------------------------------
# 5. tool_response shape
# ---------------------------------------------------------------------------

@test "shape: bare-string tool_response is handled" {
    run env TRUNCATE_TOOL_OUTPUT=1 bash "$HOOK" <<< "$(_str_input Bash 500)"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "truncated by token-cost"
}

# ---------------------------------------------------------------------------
# 6. Fail-safe
# ---------------------------------------------------------------------------

@test "fail-safe: malformed JSON → exit 0, no output" {
    run env TRUNCATE_TOOL_OUTPUT=1 bash "$HOOK" <<< 'not json {{{'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "fail-safe: empty stdin → exit 0, no output" {
    run env TRUNCATE_TOOL_OUTPUT=1 bash "$HOOK" < /dev/null
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "fail-safe: object tool_response with no recognizable text field → no output" {
    run env TRUNCATE_TOOL_OUTPUT=1 bash "$HOOK" <<< '{"tool_name":"Bash","tool_response":{"exitCode":0}}'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# ---------------------------------------------------------------------------
# 7. Marker content
# ---------------------------------------------------------------------------

@test "marker: states an omitted-line count and a retrieval hint" {
    run env TRUNCATE_TOOL_OUTPUT=1 bash "$HOOK" <<< "$(_obj_input Bash 500)"
    body="$(echo "$output" | jq -r '.hookSpecificOutput.updatedToolOutput')"
    echo "$body" | grep -qE "[0-9]+ of [0-9]+ lines omitted"
    echo "$body" | grep -q "Re-run a narrower command"
}
