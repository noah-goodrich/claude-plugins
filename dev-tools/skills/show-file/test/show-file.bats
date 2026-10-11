#!/usr/bin/env bats
# show-file targets the CALLER's window (via $TMUX_PANE), never the window being viewed.
# Everything runs on a throwaway tmux server (-L); the default server is never touched.

SCRIPT="${BATS_TEST_DIRNAME}/../show-file.sh"

setup() {
    command -v tmux >/dev/null 2>&1 || skip "tmux not installed"
    SOCK_NAME="show-file-test-$$-${BATS_TEST_NUMBER}"
    STATE_DIR="$(mktemp -d)"
    FILE="${STATE_DIR}/sample.txt"
    echo "hello" > "$FILE"
    tmux -L "$SOCK_NAME" -f /dev/null new-session -d -s t -x 200 -y 50
    tmux -L "$SOCK_NAME" new-window -d -t t:1
    tmux -L "$SOCK_NAME" select-window -t t:1
    CALLER_PANE="$(tmux -L "$SOCK_NAME" display-message -p -t t:0 '#{pane_id}')"
    TMUX_VALUE="$(tmux -L "$SOCK_NAME" display-message -p '#{socket_path},#{pid},0')"
}

teardown() {
    [[ -n "${SOCK_NAME:-}" ]] && tmux -L "$SOCK_NAME" kill-server 2>/dev/null || true
    [[ -n "${STATE_DIR:-}" ]] && rm -rf "$STATE_DIR"
    return 0
}

run_show_file() {
    TMUX="$TMUX_VALUE" TMUX_PANE="$CALLER_PANE" SHOW_FILE_STATE_DIR="$STATE_DIR" \
        bash "$SCRIPT" "$FILE"
}

pane_count() {
    tmux -L "$SOCK_NAME" list-panes -t "t:$1" -F '#{pane_id}' | wc -l | tr -d ' '
}

@test "viewer pane lands in the caller's window, not the viewed one" {
    [ "$(tmux -L "$SOCK_NAME" display-message -p '#{window_index}')" = "1" ]
    run run_show_file
    [ "$status" -eq 0 ]
    [ "$(pane_count 0)" = "2" ]
    [ "$(pane_count 1)" = "1" ]
}

@test "second call reuses the viewer pane" {
    run run_show_file
    [ "$status" -eq 0 ]
    run run_show_file
    [ "$status" -eq 0 ]
    [ "$(pane_count 0)" = "2" ]
    [ "$(pane_count 1)" = "1" ]
}

@test "marker is keyed per caller window" {
    run run_show_file
    [ "$status" -eq 0 ]
    window_id="$(tmux -L "$SOCK_NAME" display-message -p -t "$CALLER_PANE" '#{window_id}')"
    [ -f "${STATE_DIR}/.claude-show-pane.${window_id#@}" ]
}

@test "a cached pane living in another window is not reused" {
    other_pane="$(tmux -L "$SOCK_NAME" display-message -p -t t:1 '#{pane_id}')"
    window_id="$(tmux -L "$SOCK_NAME" display-message -p -t "$CALLER_PANE" '#{window_id}')"
    echo "$other_pane" > "${STATE_DIR}/.claude-show-pane.${window_id#@}"
    run run_show_file
    [ "$status" -eq 0 ]
    [ "$(pane_count 0)" = "2" ]
    [ "$(pane_count 1)" = "1" ]
}

@test "unset TMUX_PANE is an error, not an implicit-target fallback" {
    run env -u TMUX_PANE TMUX="$TMUX_VALUE" SHOW_FILE_STATE_DIR="$STATE_DIR" bash "$SCRIPT" "$FILE"
    [ "$status" -eq 1 ]
    [[ "$output" == *"TMUX_PANE"* ]]
    [ "$(pane_count 0)" = "1" ]
    [ "$(pane_count 1)" = "1" ]
}
