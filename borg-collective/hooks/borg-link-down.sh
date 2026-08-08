#!/usr/bin/env bash
# Built by scripts/build-plugin.sh — self-contained, no external source deps.
command -v borg >/dev/null 2>&1 || exit 0

# borg-link-down.sh — Claude Code / Cortex Code SessionStart hook
# "Link down" from the collective: download state INTO the session when it begins.
#
# Consolidates all SessionStart context injection:
# - Registry update: status=active, session_id
# - Git context: branch, uncommitted changes, recent commits
# - Docker container status
# - Plan-mode nudge (if no PROJECT_PLAN.md)
# - Uncommitted-changes reminder from previous session
# - Latest checkpoint from .borg/checkpoints/ (written by /borg-link-up)
# - Cairn knowledge (if available)
#
# Registered as a SessionStart hook in ~/.claude/settings.json

set -euo pipefail

# Ensure dotfiles bin (cairn client), Homebrew, pipx user bins, and common
# system paths are available when this hook runs in Claude Code's stripped
# PATH environment. Order mirrors a healthy interactive zsh PATH so brew
# binaries shadow system equivalents (e.g. brew jq before /usr/bin/jq).
PATH="${HOME}/.config/dotfiles/zsh/bin:${HOME}/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin${PATH:+:$PATH}"
export PATH

BORG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/borg"
BORG_REGISTRY="$BORG_DIR/registry.json"

# BORG_NO_SESSION_HOOKS=1 opts an internal/synthetic session (e.g. the headless
# `claude -p "/usage"` probe spawned by bin/borg-usage-watch) out of all
# SessionStart context injection. Mirrors BORG_NO_SPEND_RECORD's opt-out for the
# SessionEnd token-spend hook. Fail-safe: unset/anything-but-1 is a no-op.
[[ "${BORG_NO_SESSION_HOOKS:-}" == "1" ]] && exit 0

INPUT=$(cat /dev/stdin 2>/dev/null || true)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""' 2>/dev/null || echo "")
CWD=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null || echo "")

# Empty CWD, or CWD="/" (e.g. a launchd timer with no WorkingDirectory set):
# "/" can never be a real borg project, so treat it the same as empty and
# bail before any project-resolution or cairn call is attempted.
[[ -z "$CWD" || "$CWD" == "/" ]] && exit 0

# shellcheck source=../lib/borg-hooks.sh
# ── Inlined helpers (borg-hooks.sh + reaper.sh) — no external source deps ────
#!/usr/bin/env bash
# lib/borg-hooks.sh — shared helpers for borg hook scripts (bash)

# Sync source file to destination using mtime comparison (copy strategy, no symlinks).
# Removes a stale symlink at dst before comparing. No-ops when dst is already current.
# Usage: _borg_sync_file <src> <dst>
# Returns: 0 always (errors suppressed — hook-safe).
_borg_sync_file() {
    local src="$1" dst="$2"
    [[ -f "$src" ]] || return 0
    [[ -L "$dst" ]] && rm -f "$dst"
    if [[ ! -f "$dst" ]] || [[ "$src" -nt "$dst" ]]; then
        cp "$src" "$dst" 2>/dev/null || true
    fi
}

# Resolve project name by walking up from CWD looking for a .borg-project marker.
# drone up writes this file so container sessions (where CWD is /development/...)
# can be mapped back to the correct registry key.
# Falls back to basename of the directory, which works for host sessions.
_borg_find_project() {
    local dir="$1"
    while [[ "$dir" != "/" && -n "$dir" ]]; do
        if [[ -f "$dir/.borg-project" ]]; then
            cat "$dir/.borg-project"
            return 0
        fi
        dir="${dir%/*}"
    done
    basename "$1"
}

# Append per-environment extension CLAUDE.md to ~/.claude/CLAUDE.md.
# Idempotent: strips and re-appends the extension block on each call so
# borg-link-down.sh can call it after every CLAUDE.md re-sync without duplicating.
_borg_apply_claude_extensions() {
    local dst="$HOME/.claude/CLAUDE.md"
    local ext_claude="${XDG_CONFIG_HOME:-$HOME/.config}/borg/extensions/CLAUDE.md"
    local marker="<!-- borg-extensions -->"

    [[ -f "$ext_claude" && -f "$dst" ]] || return 0

    # Strip any existing extension block (marker to EOF)
    if grep -q "$marker" "$dst" 2>/dev/null; then
        local tmp="$dst.ext.$$"
        awk -v m="$marker" '$0 == m {exit} {print}' "$dst" > "$tmp" && mv "$tmp" "$dst"
    fi

    # Append fresh extension block
    { printf '\n%s\n' "$marker"; cat "$ext_claude"; } >> "$dst"
}

# True when the current process is inside a container. Matches bash-guard's detection
# (Docker marker plus podman/buildah's /run/.containerenv) so all hooks classify origin
# consistently across runtimes.
_borg_is_container() {
    [[ -f /.dockerenv || -f /run/.containerenv ]]
}

# Fire a macOS user notification. Uses osascript, which posts via Apple-signed
# System Events and renders reliably on macOS 26. Replaced terminal-notifier 2.0.0,
# which was ad-hoc signed and silently dropped by Notification Center.
# Click-to-focus is not available here — tmux bell + `Ctrl+Space >` covers switching.
# Usage: _borg_osa_notify <title> <subtitle> <message>
_borg_osa_notify() {
    local title="$1" subtitle="$2" message="$3"
    # Escape backslash first, then double quote, for AppleScript string literal context.
    title="${title//\\/\\\\}";       title="${title//\"/\\\"}"
    subtitle="${subtitle//\\/\\\\}"; subtitle="${subtitle//\"/\\\"}"
    message="${message//\\/\\\\}";   message="${message//\"/\\\"}"
    local script="display notification \"$message\" with title \"$title\""
    [[ -n "$subtitle" ]] && script+=" subtitle \"$subtitle\""
    script+=" sound name \"Glass\""
    osascript -e "$script" 2>/dev/null || true
}

# Strip raw ASCII control characters that break jq parsing.
# Tab (0x09), LF (0x0A), CR (0x0D) are kept; jq escapes them in string values.
# Use as a pipe filter: `... | _borg_strip_ctl` or wrap a value: `_borg_strip_ctl <<<"$x"`
_borg_strip_ctl() {
    tr -d '\000-\010\013\014\016-\037'
}

# Classify the session by its working directory.
# Returns the literal string "orchestrator" when $1 exactly matches
# $BORG_ORCHESTRATOR_ROOT (default $HOME/dev), "project" otherwise. Exact
# match only — descendant directories of the workspace root are project
# sessions. Trailing slashes on both sides are trimmed before comparison.
# Side-effect free; safe to call from any hook.
# Usage: _borg_session_mode <cwd>
_borg_session_mode() {
    local cwd="$1"
    local root="${BORG_ORCHESTRATOR_ROOT:-$HOME/dev}"
    # Trim any trailing slashes so "/Users/noah/dev/" matches "/Users/noah/dev"
    while [[ "$cwd" == */ && "$cwd" != "/" ]]; do cwd="${cwd%/}"; done
    while [[ "$root" == */ && "$root" != "/" ]]; do root="${root%/}"; done
    if [[ "$cwd" == "$root" ]]; then
        printf 'orchestrator\n'
    else
        printf 'project\n'
    fi
}

# ─── Per-project state helpers ───────────────────────────────────────────────
# Volatile session state (status, last_activity, claude_session_id,
# has_uncommitted_changes, waiting_reason, notify_origin) lives in
# <project_dir>/.borg/state.json. This keeps the shared registry as a pure
# discovery index — only stable identity fields (path, source, tmux_window,
# summary, pinned, archived) remain there.

# Canonical path to a project's state file.
# Usage: _borg_state_file <project_dir>
_borg_state_file() {
    printf '%s/.borg/state.json\n' "${1:?_borg_state_file: dir required}"
}

# Read state.json; emit '{}' when the file does not exist yet.
# Usage: _borg_state_read <project_dir>
_borg_state_read() {
    local sf
    sf=$(_borg_state_file "$1")
    if [[ -f "$sf" ]]; then
        cat "$sf"
    else
        printf '{}\n'
    fi
}

# Return the canonical project directory for state.json. Prefers the registry's
# registered path for the project (so host-path state.json is used even from a
# container session). Falls back to CWD when the registry path is absent or the
# directory doesn't exist on disk.
# Reads $BORG_REGISTRY from the calling hook's environment.
# Usage: PROJ_DIR=$(_borg_resolve_proj_dir "$PROJECT" "$CWD")
_borg_resolve_proj_dir() {
    local project="$1" cwd="$2" rp
    if [[ -f "$BORG_REGISTRY" ]]; then
        rp=$(jq -r --arg p "$project" '.projects[$p].path // ""' "$BORG_REGISTRY" 2>/dev/null || true)
        [[ -n "$rp" && "$rp" != "null" && -d "$rp" ]] && { printf '%s\n' "$rp"; return; }
    fi
    printf '%s\n' "$cwd"
}

# Atomic write — strip control chars, reject empty result, tmp+mv.
# Usage: _borg_state_write <project_dir> <json>
_borg_state_write() {
    local dir="$1" json="$2"
    local sf
    sf=$(_borg_state_file "$dir")
    mkdir -p "${sf%/*}"
    local tmp="${sf}.tmp.$$"
    printf '%s' "$json" | tr -d '\000-\010\013\014\016-\037' > "$tmp"
    [[ -s "$tmp" ]] || { rm -f "$tmp"; return 1; }
    mv "$tmp" "$sf"
}

# Reaper predicate: sourced from lib/reaper.sh (single home shared with registry.zsh).
#
# This file is sourced by BOTH bash hooks and the zsh binaries bin/borg-notifyd and
# bin/borg-cortex-watch. zsh has no BASH_SOURCE, so a bare "${BASH_SOURCE[0]}" expanded to
# nothing there, sourced "/reaper.sh", and killed both agents with exit 127 on every fire --
# while `launchctl list` reported them registered. zsh sets $0 to the sourced file's path, and
# bash sets BASH_SOURCE[0], so the ":-" default covers both (verified under `set -u` in each).

# Snapshot of live tmux window names (one per line). Empty when tmux is down.
# Honors BORG_TMUX_SESSION (default "borg"), matching lib/tmux.zsh.
_borg_live_windows() {
    local session="${BORG_TMUX_SESSION:-borg}"
    command -v tmux >/dev/null 2>&1 || return 0
    tmux has-session -t "$session" 2>/dev/null || return 0
    tmux list-windows -t "$session" -F '#W' 2>/dev/null || true
}

# ─── cairn health surfacing ──────────────────────────────────────────────────
# Source of truth: `cairn health` -> {"status":"ok"|..., "db":"reachable"|..., "version":"..."}.
# "Recording" freshness is approximated by the mtime of $BORG_DIR/.cairn-last-write, a marker
# touched by borg-link-up.sh immediately after any successful `cairn record ...` call (there is
# no last-write endpoint in the cairn CLI as of 0.5.3 — this file IS the minimal addition noted
# in the task brief). Fail-OPEN contract: this function must never hang (bounded by `timeout`,
# default 3s) or exit non-zero — every branch prints exactly one line and returns 0.
#
# Usage: _borg_cairn_health_line
_borg_cairn_health_line() {
    local timeout_secs="${BORG_CAIRN_HEALTH_TIMEOUT:-3}"
    local compose_hint="${BORG_CAIRN_COMPOSE:-$HOME/dev/cairn/compose.yml}"
    local dir="${BORG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/borg}"

    if ! command -v cairn >/dev/null 2>&1; then
        printf 'cairn: DEGRADED — not in PATH · run: borg setup\n'
        return 0
    fi

    local raw status db
    if command -v timeout >/dev/null 2>&1; then
        raw=$(timeout "$timeout_secs" cairn health 2>/dev/null) || raw=""
    else
        raw=$(cairn health 2>/dev/null) || raw=""
    fi
    status=$(printf '%s' "$raw" | jq -r '.status // ""' 2>/dev/null || printf '')
    db=$(printf '%s' "$raw" | jq -r '.db // ""' 2>/dev/null || printf '')

    if [[ "$status" != "ok" ]]; then
        printf 'cairn: DEGRADED — db %s · run: docker compose -f %s up -d\n' \
            "${db:-unreachable}" "$compose_hint"
        return 0
    fi

    local marker="$dir/.cairn-last-write" age="never"
    if [[ -f "$marker" ]]; then
        age=$(_borg_cairn_age_from_epoch "$(_borg_file_mtime_epoch "$marker")")
    fi
    printf 'cairn: healthy · recording (last write %s)\n' "$age"
    return 0
}

# Cross-platform mtime -> epoch (BSD `stat -f` on macOS, GNU `stat -c` elsewhere).
# Prints 0 on any failure (missing file, unsupported stat dialect).
_borg_file_mtime_epoch() {
    local m
    m=$(stat -f %m "$1" 2>/dev/null)
    case "$m" in
        ''|*[!0-9]*) m=$(stat -c %Y "$1" 2>/dev/null) ;;
    esac
    case "$m" in
        ''|*[!0-9]*) m=0 ;;
    esac
    printf '%s' "$m"
}

# Humanize an epoch-seconds age relative to now. "never" when epoch <= 0.
_borg_cairn_age_from_epoch() {
    local epoch="$1"
    [[ "$epoch" =~ ^[0-9]+$ ]] || { printf 'never'; return; }
    (( epoch <= 0 )) && { printf 'never'; return; }
    local now delta
    now=$(date -u +%s)
    delta=$(( now - epoch ))
    (( delta < 0 ))     && { printf 'just now'; return; }
    (( delta < 60 ))    && { printf '%ds ago' "$delta"; return; }
    (( delta < 3600 ))  && { printf '%dm ago' $(( delta / 60 )); return; }
    (( delta < 86400 )) && { printf '%dh ago' $(( delta / 3600 )); return; }
    printf '%dd ago' $(( delta / 86400 ))
}

# ── Inlined: reaper.sh ──────────────────────────────────────────────────────
#!/usr/bin/env sh
# shellcheck shell=bash  # lint as bash: both bash (hooks) and zsh source this file
# lib/reaper.sh — shared reaper predicate for borg hooks and the zsh CLI.
#
# Sourceable from both bash (hooks) and zsh (lib/registry.zsh). Provides:
#   BORG_REAP_STALE_HOURS — staleness threshold in hours (default 12)
#   _borg_should_reap <status> <last_activity_iso> <has_live_window: 1|0>
#   _borg_worktree_is_stale <repo_path> <worktree_path>
#   _borg_reap_worktrees <repo_path>

BORG_REAP_STALE_HOURS="${BORG_REAP_STALE_HOURS:-12}"

# ── Session staleness predicate ───────────────────────────────────────────────

# Predicate: should this project's active/waiting status be reaped to idle?
# Args: <status> <last_activity_iso> <has_live_window: 1|0>
# Returns 0 (reap) when status is active/waiting AND no live window AND
# last_activity is missing or older than BORG_REAP_STALE_HOURS. Returns 1 (keep).
_borg_should_reap() {
    local st="$1" last="$2" live="${3:-0}"
    if [ "$st" != "active" ] && [ "$st" != "waiting" ]; then
        return 1
    fi
    if [ "$live" = "1" ]; then
        return 1
    fi
    local threshold="${BORG_REAP_STALE_HOURS:-12}"
    if [ -z "$last" ] || [ "$last" = "null" ]; then
        return 0
    fi
    local epoch_ts epoch_now age_h
    epoch_ts=$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$last" +%s 2>/dev/null \
        || TZ=UTC date -d "$last" +%s 2>/dev/null) || return 0
    epoch_now=$(date +%s)
    age_h=$(( (epoch_now - epoch_ts) / 3600 ))
    [ "$age_h" -ge "$threshold" ]
}

# ── Nanoprobe worktree reaper ─────────────────────────────────────────────────
#
# Borg-managed worktrees live at:
#   /Users/noah/.local/state/borg/worktrees/<repo-basename>/<slug>
#
# A worktree is considered stale when its branch has been merged into the repo's
# default branch OR when the worktree directory's mtime is older than
# BORG_REAP_STALE_HOURS. Only worktrees under the borg state dir are ever
# touched — non-borg worktrees are completely ignored.

BORG_WORKTREE_STATE_DIR="${BORG_WORKTREE_STATE_DIR:-/Users/noah/.local/state/borg/worktrees}"

# Predicate: is this worktree stale?
# Args: <repo_path> <worktree_path>
# Returns 0 (stale) when the branch has been merged into the default branch (i.e.
# the branch has unique commits AND all of them are now reachable from the default
# branch), OR when the worktree directory mtime is older than BORG_REAP_STALE_HOURS.
# Returns 1 (keep) for fresh or unmerged worktrees.
_borg_worktree_is_stale() {
    local repo="$1" wt="$2"
    [ -d "$wt" ] || return 0

    local wt_branch
    wt_branch=$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1

    local default_branch
    default_branch=$(git -C "$repo" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
        | sed 's|refs/remotes/origin/||')
    if [ -z "$default_branch" ]; then
        default_branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null) || default_branch="main"
    fi

    local wt_sha default_sha
    wt_sha=$(git -C "$repo" rev-parse "$wt_branch" 2>/dev/null) || true
    default_sha=$(git -C "$repo" rev-parse "$default_branch" 2>/dev/null) || true

    if [ -n "$wt_sha" ] && [ -n "$default_sha" ] && [ "$wt_sha" != "$default_sha" ]; then
        if git -C "$repo" merge-base --is-ancestor "$wt_branch" "$default_branch" 2>/dev/null; then
            return 0
        fi
    fi

    local threshold="${BORG_REAP_STALE_HOURS:-12}"
    local mtime now age_h
    mtime=$(stat -c %Y "$wt" 2>/dev/null || stat -f %m "$wt" 2>/dev/null)
    case "$mtime" in ''|*[!0-9]*) return 1;; esac
    now=$(date +%s)
    age_h=$(( (now - mtime) / 3600 ))
    [ "$age_h" -ge "$threshold" ]
}

# Remove stale borg-managed worktrees for a given repo.
# Args: <repo_path>
# Prints one line per removed worktree to stdout: "<worktree_path>\t<reason>"
# Never touches worktrees outside BORG_WORKTREE_STATE_DIR.
# Never removes a worktree with uncommitted changes (git status --porcelain non-empty).
# Safe to call even when the state dir or repo subdir does not exist.
_borg_reap_worktrees() {
    local repo="$1"
    local repo_name
    repo_name="${repo##*/}"
    local wt_base="${BORG_WORKTREE_STATE_DIR}/${repo_name}"

    [ -d "$wt_base" ] || return 0

    local wt reason
    for wt in "$wt_base"/*/; do
        [ -d "$wt" ] || continue

        if git -C "$wt" status --porcelain 2>/dev/null | grep -q .; then
            continue
        fi

        if _borg_worktree_is_stale "$repo" "$wt"; then
            local wt_branch
            wt_branch=$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

            local default_branch
            default_branch=$(git -C "$repo" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
                | sed 's|refs/remotes/origin/||')
            if [ -z "$default_branch" ]; then
                default_branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null) || default_branch="main"
            fi

            local wt_sha default_sha
            wt_sha=$(git -C "$repo" rev-parse "$wt_branch" 2>/dev/null) || true
            default_sha=$(git -C "$repo" rev-parse "$default_branch" 2>/dev/null) || true

            if [ -n "$wt_sha" ] && [ -n "$default_sha" ] && [ "$wt_sha" != "$default_sha" ] && \
                    git -C "$repo" merge-base --is-ancestor "$wt_branch" "$default_branch" 2>/dev/null; then
                reason="branch merged"
            else
                reason="stale (>${BORG_REAP_STALE_HOURS:-12}h)"
            fi

            if git -C "$repo" worktree remove --force "$wt" 2>/dev/null; then
                printf '%s\t%s\n' "$wt" "$reason"
            fi
        fi
    done

    git -C "$repo" worktree prune 2>/dev/null || true

    if [ -d "$wt_base" ]; then
        set -- "$wt_base"/*/
        [ -e "$1" ] || rmdir "$wt_base" 2>/dev/null || true
    fi
}
# ── End inlined helpers ─────────────────────────────────────────────────────


MODE=$(_borg_session_mode "$CWD")

# ── Orchestrator-mode branch ─────────────────────────────────────────────────
# When CWD is the workspace root (default $HOME/dev), render a scannable
# cross-project overview AS additionalContext. Write nothing to the registry —
# the orchestrator session is not a project session.
_orch_humanize_age() {
    local ts="$1"
    [[ -z "$ts" ]] && { printf 'never'; return; }
    local epoch_now epoch_ts delta
    epoch_now=$(date -u +%s)
    # macOS BSD date and GNU date both accept ISO-8601 with -j -f / -d respectively.
    epoch_ts=$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$ts" +%s 2>/dev/null \
        || date -u -d "$ts" +%s 2>/dev/null || echo "$epoch_now")
    delta=$(( epoch_now - epoch_ts ))
    (( delta < 60 ))    && { printf '%ds ago' "$delta"; return; }
    (( delta < 3600 ))  && { printf '%dm ago' $(( delta / 60 )); return; }
    (( delta < 86400 )) && { printf '%dh ago' $(( delta / 3600 )); return; }
    printf '%dd ago' $(( delta / 86400 ))
}

_orch_next_hint() {
    local proj_path="$1"
    [[ -z "$proj_path" || ! -d "$proj_path" ]] && { printf '(idle)'; return; }
    local cp next_line dir_file dname
    cp=$(find "$proj_path/.borg/checkpoints" -maxdepth 1 -name "*.md" 2>/dev/null \
        | sort -r | head -1 || true)
    if [[ -n "$cp" && -f "$cp" ]]; then
        next_line=$(awk '
            /^## .*[Nn]ext [Ss]ession/ { found=1; next }
            found && /^## / { exit }
            found && /^[^[:space:]#]/ { print; exit }
        ' "$cp" 2>/dev/null | head -c 160 || true)
        if [[ -n "$next_line" ]]; then
            printf 'next: %s' "$next_line"
            return
        fi
    fi
    dir_file=$(find "$proj_path/docs/plans/directives" -maxdepth 1 -name "*.md" 2>/dev/null \
        | sort -r | head -1 || true)
    if [[ -n "$dir_file" ]]; then
        dname="${dir_file##*/}"
        printf 'directive: %s' "${dname%.md}"
        return
    fi
    printf '(idle)'
}

if [[ "$MODE" == "orchestrator" ]]; then
    OVERVIEW=""
    OVERVIEW+="$(_borg_cairn_health_line)"$'\n\n'
    if [[ -f "$BORG_REGISTRY" ]]; then
        # Read registry for identity fields, then overlay state.json for each project.
        # Build TSV: name, status, last_activity, path — sorted by last_activity desc.
        _raw_tsv=$(jq -r '
            .projects // {} | to_entries
            | map(select(.value.archived // false | not))
            | .[]
            | [.key, (.value.path // "")]
            | @tsv
        ' "$BORG_REGISTRY" 2>/dev/null || true)

        _projects_tsv=""
        while IFS=$'\t' read -r _name _path; do
            [[ -z "$_name" ]] && continue
            _status="idle"
            _last=""
            if [[ -n "$_path" && -f "$_path/.borg/state.json" ]]; then
                _status=$(jq -r '.status // "idle"' "$_path/.borg/state.json" 2>/dev/null || echo "idle")
                _last=$(jq -r '.last_activity // ""' "$_path/.borg/state.json" 2>/dev/null || echo "")
            fi
            _projects_tsv+=$(printf '%s\t%s\t%s\t%s' "$_name" "$_status" "$_last" "$_path")$'\n'
        done <<< "$_raw_tsv"

        # Sort by last_activity desc (ISO timestamps sort lexicographically)
        _projects_tsv=$(printf '%s' "$_projects_tsv" | sort -t$'\t' -k3 -r 2>/dev/null || printf '%s' "$_projects_tsv")

        _proj_count=$(printf '%s' "$_projects_tsv" | grep -c . 2>/dev/null || echo 0)
        OVERVIEW+="Orchestrator session — workspace overview (${_proj_count} projects)"$'\n\n'
        if [[ -n "$_projects_tsv" ]]; then
            while IFS=$'\t' read -r _name _status _last _path; do
                [[ -z "$_name" ]] && continue
                _age=$(_orch_humanize_age "$_last")
                _hint=$(_orch_next_hint "$_path")
                OVERVIEW+="  • ${_name} [${_status}] — ${_age} — ${_hint}"$'\n'
            done <<< "$_projects_tsv"
        else
            OVERVIEW+="  (no projects registered — run 'borg add <path>' or 'borg scan')"$'\n'
        fi
    else
        OVERVIEW="Orchestrator session — registry not initialized. Run 'borg setup'."
    fi

    jq -n --arg ctx "$OVERVIEW" '{
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": $ctx
        }
    }'
    exit 0
fi

# ── Project-mode (existing behavior) ─────────────────────────────────────────

PROJECT=$(_borg_find_project "$CWD")
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

PROJ_DIR=$(_borg_resolve_proj_dir "$PROJECT" "$CWD")

# ── 0. CLAUDE.md integrity check ─────────────────────────────────────────────
# Skip inside containers — ~/.claude is bind-mounted from the host, and applying
# container-path extensions would pollute the host's CLAUDE.md with /home/dev/... paths.
if [[ ! -f /.dockerenv ]]; then
    _borg_sync_file \
        "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/claude/code/CLAUDE.md" \
        "$HOME/.claude/CLAUDE.md"
    _borg_apply_claude_extensions
fi

# ── 1. State update ──────────────────────────────────────────────────────────
# Write status=active, last_activity, and claude_session_id to the per-project
# state.json (not the shared registry).

_cur_state=$(_borg_state_read "$PROJ_DIR")
_new_state=$(printf '%s' "$_cur_state" | jq \
    --arg sid "$SESSION_ID" \
    --arg now "$NOW" \
    '.status = "active" | .last_activity = $now |
     (if $sid != "" then .claude_session_id = $sid else . end)')
_borg_state_write "$PROJ_DIR" "$_new_state" || true

# ── 1b. Per-project skill overlay ────────────────────────────────────────────
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
PROJECT_SKILLS_DIR="$CWD/.borg/skills"
if [[ -d "$PROJECT_SKILLS_DIR" ]]; then
    mkdir -p "$CLAUDE_SKILLS_DIR"
    for _skill_dir in "$PROJECT_SKILLS_DIR"/*/; do
        [[ -d "$_skill_dir" ]] || continue
        _skill_name="${_skill_dir%/}"
        _skill_name="${_skill_name##*/}"
        ln -sfn "$_skill_dir" "$CLAUDE_SKILLS_DIR/$_skill_name" 2>/dev/null || true
    done
fi

# ── 2. Build context ─────────────────────────────────────────────────────────

CONTEXT_PARTS=()

# Cairn health callout — one line, always first, never blocks (fail-open helper).
CONTEXT_PARTS+=("$(_borg_cairn_health_line)")

# Git context (branch, status, recent commits)
if git -C "$CWD" rev-parse --is-inside-work-tree &>/dev/null; then
    git_ctx=""
    branch=$(git -C "$CWD" branch --show-current 2>/dev/null || echo "detached")
    git_ctx+="Git branch: $branch"$'\n'

    status=$(git -C "$CWD" status --short 2>/dev/null | head -20 || true)
    if [[ -n "$status" ]]; then
        git_ctx+="Uncommitted changes:"$'\n'"$status"$'\n'
    fi

    recent=$(git -C "$CWD" log --oneline -5 2>/dev/null || true)
    if [[ -n "$recent" ]]; then
        git_ctx+="Recent commits:"$'\n'"$recent"$'\n'
    fi

    CONTEXT_PARTS+=("$git_ctx")
fi

# Docker container status
container=$(docker ps --filter "label=dev.role=app" --format '{{.Names}}' 2>/dev/null | head -1 || true)
if [[ -n "$container" ]]; then
    CONTEXT_PARTS+=("Devcontainer running: $container")
fi

# Plan-mode nudge: fire when no PROJECT_PLAN.md exists
if [[ -n "$CWD" && ! -f "$CWD/PROJECT_PLAN.md" ]]; then
    CONTEXT_PARTS+=("WORKFLOW REQUIREMENT — NO PROJECT_PLAN.md FOUND

Before writing any code this session:
1. Switch to Opus: /model opus
2. Enter Plan Mode: Shift+Tab
3. Run /borg-plan to establish objectives and acceptance criteria
4. Confirm the plan (creates PROJECT_PLAN.md in the project root)
5. Exit Plan Mode: Shift+Tab
6. Switch to Sonnet: /model sonnet
7. Only then begin implementation

If this is exploratory/investigative work with no deliverable, state that explicitly
and you may proceed without /borg-plan.")
fi

# Capacity warning — count active/waiting by scanning per-project state.json files.
# Reaper-aware: a stale active/waiting session (no live tmux window AND no recent
# activity) is treated as idle and excluded, matching the CLI capacity count.
if [[ -f "$BORG_REGISTRY" ]]; then
    _max_active=$(grep -m1 '^BORG_MAX_ACTIVE=' "$BORG_DIR/config.zsh" 2>/dev/null \
        | sed 's/BORG_MAX_ACTIVE=//' | tr -d '"' || echo "3")
    [[ "$_max_active" =~ ^[0-9]+$ ]] || _max_active=3
    _live_windows=$(_borg_live_windows)
    _active_count=0
    # Sentinel ("-") for empty columns — bash `read` with a whitespace IFS (tab is
    # whitespace) collapses consecutive separators, shifting fields. Keep every
    # column populated, then map sentinels back below.
    while IFS=$'\t' read -r _rname _rpath _rwin; do
        [[ -z "$_rpath" || "$_rpath" == "-" || "$_rpath" == "null" ]] && continue
        _sf="$_rpath/.borg/state.json"
        [[ -f "$_sf" ]] || continue
        _s=$(jq -r '.status // "idle"' "$_sf" 2>/dev/null || true)
        [[ "$_s" == "active" || "$_s" == "waiting" ]] || continue
        _last=$(jq -r '.last_activity // ""' "$_sf" 2>/dev/null || true)
        [[ "$_rwin" == "-" || -z "$_rwin" || "$_rwin" == "null" ]] && _rwin="$_rname"
        _live=0
        if [[ -n "$_live_windows" ]] && printf '%s\n' "$_live_windows" | grep -qx "$_rwin"; then
            _live=1
        fi
        _borg_should_reap "$_s" "$_last" "$_live" && continue
        _active_count=$(( _active_count + 1 ))
    done < <(jq -r '.projects | to_entries[]
        | [.key,
           (if (.value.path // "") == "" then "-" else .value.path end),
           (if (.value.tmux_window // "") == "" then "-" else .value.tmux_window end)]
        | @tsv' "$BORG_REGISTRY" 2>/dev/null || true)
    if (( _active_count > _max_active )); then
        CONTEXT_PARTS+=("⚠ CAPACITY WARNING: $_active_count projects active/waiting (limit: $_max_active).
Too many concurrent threads degrades quality and increases context-switching overhead.
Complete or pause a project before starting new work.")
    fi
fi

# Uncommitted-changes reminder from previous session (read from state.json)
UNCOMMITTED_FLAG=$(jq -r '.has_uncommitted_changes // false' \
    "$(_borg_state_file "$PROJ_DIR")" 2>/dev/null || echo "false")
if [[ "$UNCOMMITTED_FLAG" == "true" ]]; then
    CONTEXT_PARTS+=("REMINDER: Last session ended with uncommitted changes in $PROJECT.
Run 'git status' to see what's pending. Consider /simplify and committing before new work.")
fi

# Active directives for this project — inject filename + objective line only (no full bodies)
DIRECTIVES_DIR="$CWD/docs/plans/directives"
if [[ -d "$DIRECTIVES_DIR" ]]; then
    _directive_lines=""
    while IFS= read -r -d '' _dfile; do
        _dname="${_dfile##*/}"
        # Extract the first non-blank line that is a heading or italic text after the H1;
        # prefer the ## Objective section's first content line as the summary.
        _obj=$(awk '
            /^## Objective/ { found=1; next }
            found && /^[^#[:space:]]/ { print; exit }
            found && /^[[:space:]]*$/ { next }
        ' "$_dfile" 2>/dev/null | head -c 200 || true)
        if [[ -z "$_obj" ]]; then
            # Fallback: first non-blank non-heading non-italic-meta line
            _obj=$(grep -m1 '^[^#*[:space:]]' "$_dfile" 2>/dev/null | head -c 200 || true)
        fi
        if [[ -n "$_obj" ]]; then
            _directive_lines+="  - ${_dname}: ${_obj}"$'\n'
        else
            _directive_lines+="  - ${_dname}"$'\n'
        fi
    done < <(find "$DIRECTIVES_DIR" -maxdepth 1 -name "*.md" -print0 2>/dev/null | sort -z)
    if [[ -n "$_directive_lines" ]]; then
        CONTEXT_PARTS+=("Active directives for $PROJECT (check these before starting new work):

${_directive_lines%$'\n'}")
    fi
fi

# Latest checkpoint for this project — written by /borg-link-up
CHECKPOINT_FILE=""
if [[ -d "$CWD/.borg/checkpoints" ]]; then
    CHECKPOINT_FILE=$(find "$CWD/.borg/checkpoints" -maxdepth 1 -name "*.md" 2>/dev/null | sort -r | head -1 || true)
fi
if [[ -n "$CHECKPOINT_FILE" && -f "$CHECKPOINT_FILE" ]]; then
    CHECKPOINT=$(head -c 4000 "$CHECKPOINT_FILE" 2>/dev/null || true)
    if [[ -n "$CHECKPOINT" ]]; then
        CP_BASENAME="${CHECKPOINT_FILE##*/}"
        CONTEXT_PARTS+=("Latest checkpoint for $PROJECT ($CP_BASENAME):

$CHECKPOINT")
    fi
fi

# Cairn knowledge (optional) — with health check and failure surfacing
CAIRN_FAILED_FLAG="${BORG_DIR}/.cairn-write-failed"

if ! command -v cairn >/dev/null 2>&1; then
    CONTEXT_PARTS+=("⚠ CAIRN UNAVAILABLE: cairn not found in PATH.
Cross-session knowledge is not being persisted to the graph. Checkpoints still save locally.
To fix: ensure cairn is installed and in your PATH, then run 'borg setup'.")
else
    # Surface any write failure from the previous session stop
    if [[ -f "$CAIRN_FAILED_FLAG" ]]; then
        _fail_msg=$(cat "$CAIRN_FAILED_FLAG" 2>/dev/null || true)
        CONTEXT_PARTS+=("⚠ CAIRN WRITE FAILED (last session): ${_fail_msg}
The session was NOT committed to the knowledge graph.
Check cairn service health: cairn health")
        rm -f "$CAIRN_FAILED_FLAG"
    fi

    # Attribute the retrieval to this session. cairn's usage ledger has always had a session_id
    # column on call_log, but no caller ever populated it, so it was NULL on 100% of rows and the
    # cost/query join returned zero rows in production. Guarded on non-empty: passing an empty
    # --session-id would log the literal empty string rather than leaving it NULL.
    CAIRN_SEARCH_ARGS=(--project "$PROJECT" --max 5)
    [[ -n "$SESSION_ID" ]] && CAIRN_SEARCH_ARGS+=(--session-id "$SESSION_ID")
    if command -v timeout >/dev/null 2>&1; then
        CAIRN_OUT=$(timeout 5 cairn search "$PROJECT" "${CAIRN_SEARCH_ARGS[@]}" 2>/dev/null || true)
    else
        CAIRN_OUT=$(cairn search "$PROJECT" "${CAIRN_SEARCH_ARGS[@]}" 2>/dev/null || true)
    fi
    # Log hit metrics for the 4-week validation window. Brace-group the redirection so
    # 2>/dev/null is in effect when bash OPENS the log for append: a bare
    # `cmd >> "$dir/f" 2>/dev/null` opens the target before applying the stderr redirect,
    # so a missing $BORG_DIR leaks a "No such file or directory" line to stderr — which a
    # merging consumer (bats `run`) then splices into this hook's JSON stdout, breaking it.
    CAIRN_BYTES=$(printf '%s' "$CAIRN_OUT" | wc -c | tr -d ' ')
    { printf '%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$PROJECT" "$CAIRN_BYTES" \
        >> "${BORG_DIR}/cairn-hits.log"; } 2>/dev/null || true

    if [[ -n "$CAIRN_OUT" ]]; then
        CONTEXT_PARTS+=("Cairn knowledge for $PROJECT:

$CAIRN_OUT")
    else
        CONTEXT_PARTS+=("ℹ Cairn has no data for $PROJECT yet.
Sessions will be committed to cairn after this session ends.")
    fi
fi

# ── 2c. Presence ─────────────────────────────────────────────────────────────
# Publish this session's presence row (open + heartbeat) and query related
# active sessions in the same project. Injects ONE distilled line into
# CONTEXT_PARTS when a related session exists. Strictly silent on every
# failure path — cairn down / unreachable / 404 / timeout is a no-op.
if command -v cairn >/dev/null 2>&1; then
    _p_branch=$(git -C "$CWD" branch --show-current 2>/dev/null || true)
    _p_paths=""
    if git -C "$CWD" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        _p_paths=$(git -C "$CWD" status --porcelain 2>/dev/null \
            | awk '{print $NF}' | paste -sd, - || true)
    fi
    if command -v timeout >/dev/null 2>&1; then
        timeout 5 cairn presence open \
            --session-id "$SESSION_ID" --project "$PROJECT" \
            --branch "$_p_branch" --paths "$_p_paths" \
            >/dev/null 2>&1 || true
    else
        cairn presence open \
            --session-id "$SESSION_ID" --project "$PROJECT" \
            --branch "$_p_branch" --paths "$_p_paths" \
            >/dev/null 2>&1 || true
    fi
    if command -v timeout >/dev/null 2>&1; then
        _p_line=$(timeout 5 cairn presence related \
            --session-id "$SESSION_ID" --project "$PROJECT" \
            --paths "$_p_paths" --format line 2>/dev/null || true)
    else
        _p_line=$(cairn presence related \
            --session-id "$SESSION_ID" --project "$PROJECT" \
            --paths "$_p_paths" --format line 2>/dev/null || true)
    fi
    [[ -n "$_p_line" ]] && CONTEXT_PARTS+=("$_p_line")
fi

# ── 3. Output ─────────────────────────────────────────────────────────────────

if (( ${#CONTEXT_PARTS[@]} > 0 )); then
    FULL_CTX="${CONTEXT_PARTS[0]}"
    for _part in "${CONTEXT_PARTS[@]:1}"; do
        FULL_CTX="${FULL_CTX}

---

${_part}"
    done
    jq -n --arg ctx "$FULL_CTX" '{
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": $ctx
        }
    }'
fi

exit 0
