#!/usr/bin/env bats
# borg-link-down.bats — smoke tests for borg-collective/hooks/borg-link-down.sh
#
# Focus: deterministic, hermetic behaviours that don't require a live borg.
# External commands are stubbed with PATH-prepended fakes in the per-test setup.
#
# Test categories:
#   1. Guard — exits 0 immediately when borg is not installed
#   2. Empty input — exits 0 when stdin is empty / CWD is missing
#   3. Orchestrator mode — exits 0 without touching registry when CWD == workspace root
#   4. Project mode — writes state.json with status=active; emits valid JSON output

HOOK="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/borg-link-down.sh"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Create a minimal fake command that just exits 0 (or prints a canned value).
_fake() {
    local name="$1" body="${2:-exit 0}"
    local bin="$BATS_TMPDIR/fakes/bin"
    mkdir -p "$bin"
    printf '#!/usr/bin/env bash\n%s\n' "$body" > "$bin/$name"
    chmod +x "$bin/$name"
}

# Prepend the fakes bin to PATH for the duration of one test.
_use_fakes() {
    export PATH="$BATS_TMPDIR/fakes/bin:$PATH"
}

setup() {
    export BATS_TMPDIR="${BATS_TMPDIR:-/tmp}"
    rm -rf "$BATS_TMPDIR/fakes"
    mkdir -p "$BATS_TMPDIR/fakes/bin"

    # Canonical fake for borg (present, no-op)
    _fake borg "exit 0"

    # jq: real jq on CI; if missing, stub enough for the guard check only.
    # We rely on real jq being available (bats job installs it).

    export TOKEN_SPEND_LOG="$BATS_TMPDIR/spend.jsonl"
    export BORG_ORCHESTRATOR_ROOT="$BATS_TMPDIR/orchestrator-root"
    export BORG_DIR="$BATS_TMPDIR/borg"
    export HOME="$BATS_TMPDIR/home"
    mkdir -p "$HOME/.claude" "$HOME/.config/borg" "$BORG_DIR"
    export BORG_REGISTRY="$BORG_DIR/registry.json"
}

# ---------------------------------------------------------------------------
# 1. Guard: borg absent → exits 0 immediately, no writes
# ---------------------------------------------------------------------------

@test "guard: exits 0 when borg is not in PATH" {
    # Remove borg from fakes so PATH lookup fails
    rm -f "$BATS_TMPDIR/fakes/bin/borg"
    _use_fakes

    run bash "$HOOK" <<< '{}'
    [ "$status" -eq 0 ]
}

@test "guard: produces no output when borg absent" {
    rm -f "$BATS_TMPDIR/fakes/bin/borg"
    _use_fakes

    run bash "$HOOK" <<< '{}'
    [ -z "$output" ]
}

# ---------------------------------------------------------------------------
# 2. Empty / minimal input
# ---------------------------------------------------------------------------

@test "empty stdin: exits 0 with borg present but no CWD" {
    _use_fakes

    run bash "$HOOK" <<< '{}'
    [ "$status" -eq 0 ]
}

@test "null CWD in JSON: exits 0 without error" {
    _use_fakes

    run bash "$HOOK" <<< '{"session_id":"s1","cwd":""}'
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 3. Orchestrator mode — CWD matches BORG_ORCHESTRATOR_ROOT
# ---------------------------------------------------------------------------

@test "orchestrator mode: exits 0" {
    _use_fakes
    mkdir -p "$BATS_TMPDIR/orchestrator-root"
    # Minimal registry so the overview branch doesn't crash
    printf '{"projects":{}}' > "$BORG_REGISTRY"

    run bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$BATS_TMPDIR/orchestrator-root\"}"
    [ "$status" -eq 0 ]
}

@test "orchestrator mode: output is valid JSON with hookSpecificOutput" {
    _use_fakes
    mkdir -p "$BATS_TMPDIR/orchestrator-root"
    printf '{"projects":{}}' > "$BORG_REGISTRY"

    run bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$BATS_TMPDIR/orchestrator-root\"}"
    [ "$status" -eq 0 ]
    # Must produce valid JSON
    printf '%s' "$output" | jq . > /dev/null
    # Must include hookSpecificOutput key
    key=$(printf '%s' "$output" | jq -r 'keys[0]')
    [ "$key" = "hookSpecificOutput" ]
}

@test "orchestrator mode: does not create state.json" {
    _use_fakes
    mkdir -p "$BATS_TMPDIR/orchestrator-root"
    printf '{"projects":{}}' > "$BORG_REGISTRY"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$BATS_TMPDIR/orchestrator-root\"}" > /dev/null
    [ ! -f "$BATS_TMPDIR/orchestrator-root/.borg/state.json" ]
}

# ---------------------------------------------------------------------------
# 4. Project mode — writes state and emits context JSON
# ---------------------------------------------------------------------------

@test "project mode: exits 0 for a simple project CWD" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject"
    mkdir -p "$proj"
    printf '{"projects":{}}' > "$BORG_REGISTRY"

    run bash "$HOOK" <<< "{\"session_id\":\"s42\",\"cwd\":\"$proj\"}"
    [ "$status" -eq 0 ]
}

@test "project mode: state.json written with status=active" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject2"
    mkdir -p "$proj"
    printf '{"projects":{}}' > "$BORG_REGISTRY"

    bash "$HOOK" <<< "{\"session_id\":\"s42\",\"cwd\":\"$proj\"}" > /dev/null
    [ -f "$proj/.borg/state.json" ]
    status_val=$(jq -r '.status' "$proj/.borg/state.json")
    [ "$status_val" = "active" ]
}

@test "project mode: state.json contains last_activity timestamp" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject3"
    mkdir -p "$proj"
    printf '{"projects":{}}' > "$BORG_REGISTRY"

    bash "$HOOK" <<< "{\"session_id\":\"s42\",\"cwd\":\"$proj\"}" > /dev/null
    last=$(jq -r '.last_activity' "$proj/.borg/state.json")
    [ -n "$last" ] && [ "$last" != "null" ]
}

@test "project mode: state.json records the session_id" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject4"
    mkdir -p "$proj"
    printf '{"projects":{}}' > "$BORG_REGISTRY"

    bash "$HOOK" <<< "{\"session_id\":\"sess-xyz\",\"cwd\":\"$proj\"}" > /dev/null
    sid=$(jq -r '.claude_session_id' "$proj/.borg/state.json")
    [ "$sid" = "sess-xyz" ]
}

@test "project mode: output (if any) is valid JSON" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject5"
    mkdir -p "$proj"
    printf '{"projects":{}}' > "$BORG_REGISTRY"

    run bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}"
    [ "$status" -eq 0 ]
    # Output may be empty (no context parts) or valid JSON — both are acceptable
    if [ -n "$output" ]; then
        printf '%s' "$output" | jq . > /dev/null
    fi
}

@test "project mode: plan-mode nudge included when no PROJECT_PLAN.md" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject6"
    mkdir -p "$proj"
    printf '{"projects":{}}' > "$BORG_REGISTRY"

    run bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}"
    [ "$status" -eq 0 ]
    # Output must mention borg-plan nudge (plan workflow requirement text)
    printf '%s' "$output" | grep -q "borg-plan"
}

@test "project mode: no plan-mode nudge when PROJECT_PLAN.md exists" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject7"
    mkdir -p "$proj"
    printf 'stub plan' > "$proj/PROJECT_PLAN.md"
    printf '{"projects":{}}' > "$BORG_REGISTRY"

    run bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}"
    [ "$status" -eq 0 ]
    # Should NOT contain the borg-plan nudge
    if [ -n "$output" ]; then
        result=$(printf '%s' "$output" | jq -r '.hookSpecificOutput.additionalContext // ""')
        if printf '%s' "$result" | grep -q "borg-plan"; then
            printf 'FAIL: plan-mode nudge present despite PROJECT_PLAN.md\n' >&2
            return 1
        fi
    fi
}

@test "project mode: uncommitted reminder appears when state.json has has_uncommitted_changes=true" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject8"
    mkdir -p "$proj/.borg"
    printf '{"status":"idle","has_uncommitted_changes":true}' > "$proj/.borg/state.json"
    printf '{"projects":{}}' > "$BORG_REGISTRY"

    run bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}"
    [ "$status" -eq 0 ]
    ctx=$(printf '%s' "$output" | jq -r '.hookSpecificOutput.additionalContext // ""')
    printf '%s' "$ctx" | grep -qi "uncommitted"
}
