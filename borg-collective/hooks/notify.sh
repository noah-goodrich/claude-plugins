#!/usr/bin/env bash
# notify.sh — alert when Claude finishes a turn and needs input.
#
# macOS-only: posts a Notification Center notification via osascript and
# sends a tmux visual bell (when running inside tmux). Inside a container
# this is a no-op — the host can't reach the desktop and the borg CLI's
# notify daemon isn't part of this plugin.

set -euo pipefail

# Inside a container the host's Notification Center isn't reachable.
[[ -f /.dockerenv ]] && exit 0

# Inlined from borg-collective lib/borg-hooks.sh — keeps this hook
# self-contained so the plugin works without the CLI installed.
_osa_notify() {
    local title="$1" subtitle="$2" message="$3"
    title="${title//\\/\\\\}";       title="${title//\"/\\\"}"
    subtitle="${subtitle//\\/\\\\}"; subtitle="${subtitle//\"/\\\"}"
    message="${message//\\/\\\\}";   message="${message//\"/\\\"}"
    local script="display notification \"$message\" with title \"$title\""
    [[ -n "$subtitle" ]] && script+=" subtitle \"$subtitle\""
    script+=" sound name \"Glass\""
    osascript -e "$script" 2>/dev/null || true
}

# osascript is macOS-only; bail silently elsewhere so the hook is portable.
command -v osascript >/dev/null 2>&1 || exit 0

INPUT=$(cat /dev/stdin 2>/dev/null || true)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null || true)
PROJECT=$(basename "${CWD:-$(pwd)}")

WINDOW="" PANE_TTY=""
if [[ -n "${TMUX:-}" && -n "${TMUX_PANE:-}" ]]; then
    WINDOW=$(tmux display-message -t "$TMUX_PANE" -p "#{window_name}" 2>/dev/null || true)
    PANE_TTY=$(tmux display-message -t "$TMUX_PANE" -p "#{pane_tty}" 2>/dev/null || true)
fi
SUBTITLE="${WINDOW:+$WINDOW — }$PROJECT"

_osa_notify "Claude Code" "$SUBTITLE" "Ready for input"

# tmux visual bell — write directly to the pane's TTY so tmux sees it.
[[ -n "$PANE_TTY" ]] && printf '\a' > "$PANE_TTY"

exit 0
