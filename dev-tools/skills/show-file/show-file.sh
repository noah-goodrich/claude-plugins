#!/usr/bin/env bash
# show-file: Display a file in a dedicated tmux pane to the right.
# Markdown/MDX -> rendered with glow (pager). Everything else -> nvim (read-only).
#
# TARGETING: Claude Code's Bash tool has no controlling tty, so a tmux command without -t ignores
# $TMUX_PANE and targets whichever window the user is currently VIEWING, not the window the calling
# session lives in. Every tmux call here therefore carries an explicit -t (or -a for listing), and
# the viewer pane is tracked per caller window.
set -euo pipefail

FILE="${1:?Usage: show-file <filepath>}"
[[ -f "$FILE" ]] || { echo "error: $FILE not found" >&2; exit 1; }

if [[ -z "${TMUX_PANE:-}" ]]; then
    echo "error: TMUX_PANE is not set; show-file must run inside a tmux pane (no implicit-target fallback)" >&2
    exit 1
fi

WINDOW_ID=$(tmux display-message -p -t "$TMUX_PANE" '#{window_id}')
MARKER="${SHOW_FILE_STATE_DIR:-/tmp}/.claude-show-pane.${WINDOW_ID#@}"

# Reuse the cached pane only if it is alive AND in the caller's window.
PANE_ID=""
if [[ -f "$MARKER" ]]; then
    PANE_ID=$(cat "$MARKER")
    tmux list-panes -a -F '#{pane_id} #{window_id}' | grep -qFx "${PANE_ID} ${WINDOW_ID}" || PANE_ID=""
fi

if [[ -z "$PANE_ID" ]]; then
    PANE_ID=$(tmux split-window -t "$TMUX_PANE" -h -d -P -F '#{pane_id}' -l 45%)
    echo "$PANE_ID" > "$MARKER"
fi

# Clear previous content: q exits glow pager, :q! exits nvim, C-c catches the rest
tmux send-keys -t "$PANE_ID" q 2>/dev/null || true
sleep 0.05
tmux send-keys -t "$PANE_ID" ":q!" Enter 2>/dev/null || true
sleep 0.05
tmux send-keys -t "$PANE_ID" C-c 2>/dev/null || true
tmux send-keys -t "$PANE_ID" " clear" Enter
sleep 0.1

EXT="${FILE##*.}"
if [[ "$EXT" == "md" || "$EXT" == "mdx" ]]; then
    tmux send-keys -t "$PANE_ID" " glow -p '$FILE'" Enter
else
    tmux send-keys -t "$PANE_ID" " nvim -R '$FILE'" Enter
fi
