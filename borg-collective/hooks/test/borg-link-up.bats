#!/usr/bin/env bats
# borg-link-up.bats — smoke tests for borg-collective/hooks/borg-link-up.sh
#
# Focus: deterministic, hermetic behaviours that don't require a live borg/cairn.
# External commands are stubbed with PATH-prepended fakes in the per-test setup.
#
# Test categories:
#   1. Guard — exits 0 immediately when borg is not installed
#   2. Empty/missing input — exits 0 gracefully
#   3. Orchestrator mode — exits 0 without touching any project state
#   4. Project mode — writes state.json with status=idle, dirty flag, session_id
#   5. Cairn absent — no-op on cairn, still exits 0

HOOK="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/borg-link-up.sh"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_fake() {
    local name="$1" body="${2:-exit 0}"
    local bin="$BATS_TMPDIR/fakes/bin"
    mkdir -p "$bin"
    printf '#!/usr/bin/env bash\n%s\n' "$body" > "$bin/$name"
    chmod +x "$bin/$name"
}

_use_fakes() {
    export PATH="$BATS_TMPDIR/fakes/bin:$PATH"
}

setup() {
    export BATS_TMPDIR="${BATS_TMPDIR:-/tmp}"
    rm -rf "$BATS_TMPDIR/fakes"
    mkdir -p "$BATS_TMPDIR/fakes/bin"

    _fake borg "exit 0"

    export BORG_ORCHESTRATOR_ROOT="$BATS_TMPDIR/orchestrator-root"
    export BORG_DIR="$BATS_TMPDIR/borg"
    export BORG_REGISTRY="$BORG_DIR/registry.json"
    export HOME="$BATS_TMPDIR/home"
    mkdir -p "$HOME/.claude" "$HOME/.config/borg" "$BORG_DIR"
    # No registry file by default — hooks fall back to CWD-based project resolution
}

# ---------------------------------------------------------------------------
# 1. Guard: borg absent → exits 0 immediately
# ---------------------------------------------------------------------------

@test "guard: exits 0 when borg is not in PATH" {
    rm -f "$BATS_TMPDIR/fakes/bin/borg"
    _use_fakes

    run bash "$HOOK" <<< '{}'
    [ "$status" -eq 0 ]
}

@test "guard: no output when borg absent" {
    rm -f "$BATS_TMPDIR/fakes/bin/borg"
    _use_fakes

    run bash "$HOOK" <<< '{}'
    [ -z "$output" ]
}

# ---------------------------------------------------------------------------
# 2. Empty / missing CWD
# ---------------------------------------------------------------------------

@test "empty CWD: exits 0" {
    _use_fakes
    run bash "$HOOK" <<< '{"session_id":"s1","cwd":""}'
    [ "$status" -eq 0 ]
}

@test "no stdin at all: exits 0" {
    _use_fakes
    run bash "$HOOK" < /dev/null
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 3. Orchestrator mode — exits without touching project state
# ---------------------------------------------------------------------------

@test "orchestrator mode: exits 0" {
    _use_fakes
    mkdir -p "$BATS_TMPDIR/orchestrator-root"

    run bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$BATS_TMPDIR/orchestrator-root\"}"
    [ "$status" -eq 0 ]
}

@test "orchestrator mode: does not create state.json" {
    _use_fakes
    mkdir -p "$BATS_TMPDIR/orchestrator-root"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$BATS_TMPDIR/orchestrator-root\"}" > /dev/null
    [ ! -f "$BATS_TMPDIR/orchestrator-root/.borg/state.json" ]
}

# ---------------------------------------------------------------------------
# 4. Project mode
# ---------------------------------------------------------------------------

@test "project mode: exits 0" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject"
    mkdir -p "$proj"

    run bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}"
    [ "$status" -eq 0 ]
}

@test "project mode: state.json written with status=idle" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject2"
    mkdir -p "$proj"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}" 2>/dev/null
    [ -f "$proj/.borg/state.json" ]
    val=$(jq -r '.status' "$proj/.borg/state.json")
    [ "$val" = "idle" ]
}

@test "project mode: state.json contains last_activity" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject3"
    mkdir -p "$proj"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}" 2>/dev/null
    val=$(jq -r '.last_activity' "$proj/.borg/state.json")
    [ -n "$val" ] && [ "$val" != "null" ]
}

@test "project mode: session_id stored in state.json" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject4"
    mkdir -p "$proj"

    bash "$HOOK" <<< "{\"session_id\":\"sess-abc\",\"cwd\":\"$proj\"}" 2>/dev/null
    val=$(jq -r '.claude_session_id' "$proj/.borg/state.json")
    [ "$val" = "sess-abc" ]
}

@test "project mode: has_uncommitted_changes=false when no git repo" {
    _use_fakes
    local proj="$BATS_TMPDIR/myproject5"
    mkdir -p "$proj"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}" 2>/dev/null
    val=$(jq -r '.has_uncommitted_changes' "$proj/.borg/state.json")
    [ "$val" = "false" ]
}

@test "project mode: has_uncommitted_changes=false on clean git repo" {
    _use_fakes
    local proj="$BATS_TMPDIR/clean-repo"
    mkdir -p "$proj"
    git -C "$proj" init -q
    git -C "$proj" commit --allow-empty -m "init" -q

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}" 2>/dev/null
    val=$(jq -r '.has_uncommitted_changes' "$proj/.borg/state.json")
    [ "$val" = "false" ]
}

@test "project mode: has_uncommitted_changes=true on dirty git repo" {
    _use_fakes
    local proj="$BATS_TMPDIR/dirty-repo"
    mkdir -p "$proj"
    git -C "$proj" init -q
    git -C "$proj" commit --allow-empty -m "init" -q
    printf 'change\n' > "$proj/file.txt"
    git -C "$proj" add "$proj/file.txt"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}" 2>/dev/null
    val=$(jq -r '.has_uncommitted_changes' "$proj/.borg/state.json")
    [ "$val" = "true" ]
}

# ---------------------------------------------------------------------------
# 5. Cairn absent — must not crash
# ---------------------------------------------------------------------------

@test "cairn absent: exits 0 without crashing" {
    _use_fakes
    # Ensure cairn is not in PATH
    local proj="$BATS_TMPDIR/no-cairn-proj"
    mkdir -p "$proj"

    run bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}"
    [ "$status" -eq 0 ]
}

@test "cairn absent: state.json still written correctly" {
    _use_fakes
    local proj="$BATS_TMPDIR/no-cairn-proj2"
    mkdir -p "$proj"

    bash "$HOOK" <<< "{\"session_id\":\"s1\",\"cwd\":\"$proj\"}" 2>/dev/null
    [ -f "$proj/.borg/state.json" ]
    val=$(jq -r '.status' "$proj/.borg/state.json")
    [ "$val" = "idle" ]
}
