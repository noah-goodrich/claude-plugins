#!/usr/bin/env bash
# show-file: Display a file in a dedicated tmux pane to the right.
# Markdown/MDX -> rendered with glow (pager). Everything else -> nvim (read-only).
set -euo pipefail

FILE="${1:?Usage: show-file <filepath>}"
[[ -f "$FILE" ]] || { echo "error: $FILE not found" >&2; exit 1; }

MARKER="/tmp/.claude-show-pane"

PANE_ID=""
if [[ -f "$MARKER" ]]; then
    PANE_ID=$(cat "$MARKER")
    tmux list-panes -F '#{pane_id}' | grep -q "^${PANE_ID}$" || PANE_ID=""
fi

if [[ -z "$PANE_ID" ]]; then
    PANE_ID=$(tmux split-window -h -d -P -F '#{pane_id}' -l 45%)
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
