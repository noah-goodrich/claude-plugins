#!/usr/bin/env bash
# notify.sh — alert when Claude finishes a turn and needs input
set -euo pipefail

# Inside a container the host's Notification Center isn't reachable; borg-notify.sh
# writes status=waiting to the bind-mounted registry and borg-notifyd pops on the host.
[[ -f /.dockerenv ]] && exit 0

# Usage: _borg_osa_notify <title> <subtitle> <message>
_borg_osa_notify() {
    local title="$1" subtitle="$2" message="$3"
    title="${title//\\/\\\\}";       title="${title//\"/\\\"}"
    subtitle="${subtitle//\\/\\\\}"; subtitle="${subtitle//\"/\\\"}"
    message="${message//\\/\\\\}";   message="${message//\"/\\\"}"
    local script="display notification \"$message\" with title \"$title\""
    [[ -n "$subtitle" ]] && script+=" subtitle \"$subtitle\""
    script+=" sound name \"Glass\""
    osascript -e "$script" 2>/dev/null || true
}

INPUT=$(cat /dev/stdin 2>/dev/null || true)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null || true)
PROJECT=$(basename "${CWD:-$(pwd)}")

WINDOW="" PANE_TTY=""
if [[ -n "${TMUX:-}" && -n "${TMUX_PANE:-}" ]]; then
    WINDOW=$(tmux display-message -t "$TMUX_PANE" -p "#{window_name}" 2>/dev/null || true)
    PANE_TTY=$(tmux display-message -t "$TMUX_PANE" -p "#{pane_tty}" 2>/dev/null || true)
fi
SUBTITLE="${WINDOW:+$WINDOW — }$PROJECT"

_borg_osa_notify "Claude Code" "$SUBTITLE" "Ready for input"

# tmux visual bell — write directly to the pane's TTY so tmux sees it
[[ -n "$PANE_TTY" ]] && printf '\a' > "$PANE_TTY"

exit 0
