#!/usr/bin/env bash
# Built by scripts/build-plugin.sh — self-contained, no external source deps.
command -v borg >/dev/null 2>&1 || exit 0

# borg-plan-promote.sh — PreToolUse hook: auto-promote in-session plan to PROJECT_PLAN.md
#
# Fires on Edit, Write, NotebookEdit tool calls. When Claude Code exits plan mode
# (ExitPlanMode) and the user proceeds to implementation, this hook captures the plan
# and writes it to docs/plans/PROJECT_PLAN.md before the first file edit — silently,
# without blocking.
#
# Gates:
#   1. Project-mode only (not orchestrator).
#   2. Edit target must be inside the repo working tree.
#   3. cwd must be a git repo (used to find repo root).
#   4. No existing PROJECT_PLAN.md at either canonical location.
#   5. Session JSONL must contain an ExitPlanMode tool call since the most recent
#      non-meta user message (i.e. the current user turn).
#
# Always exits 0 — never blocks. On any unexpected failure, logs a debug line to
# ~/.config/borg/plan-promote-debug.log and exits 0.
#
# Registered as a PreToolUse hook in ~/.claude/settings.json.

set -euo pipefail

PATH="${HOME}/.config/dotfiles/zsh/bin:${HOME}/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin${PATH:+:$PATH}"
export PATH

BORG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/borg"
DEBUG_LOG="$BORG_DIR/plan-promote-debug.log"

_debug() {
    mkdir -p "$BORG_DIR" 2>/dev/null || true
    printf '%s [borg-plan-promote] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >> "$DEBUG_LOG" 2>/dev/null || true
}

INPUT=$(cat /dev/stdin 2>/dev/null || true)
[[ -z "$INPUT" ]] && exit 0

command -v jq >/dev/null 2>&1 || exit 0

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null || true)
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""' 2>/dev/null || true)
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""' 2>/dev/null || true)

[[ -z "$CWD" || -z "$SESSION_ID" ]] && exit 0

# ── Gate 1: project-mode only ────────────────────────────────────────────────

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

# Snapshot of live tmux window names (one per line). Empty when tmux is down.
# Honors BORG_TMUX_SESSION (default "borg"), matching lib/tmux.zsh.
_borg_live_windows() {
    local session="${BORG_TMUX_SESSION:-borg}"
    command -v tmux >/dev/null 2>&1 || return 0
    tmux has-session -t "$session" 2>/dev/null || return 0
    tmux list-windows -t "$session" -F '#W' 2>/dev/null || true
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
#
# NOTE: _borg_should_reap uses `date -j -f` without `-u`, so the computed age is
# off by the host's UTC offset. This is a known bug tracked in:
#   docs/plans/directives/2026-06-06-reaper-utc-timezone-offset.md
# Do not "fix" it here — the directive has the acceptance criteria.

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
    epoch_ts=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last" +%s 2>/dev/null \
        || date -d "$last" +%s 2>/dev/null) || return 0
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
    mtime=$(stat -f %m "$wt" 2>/dev/null || stat --format=%Y "$wt" 2>/dev/null) || return 1
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
[[ "$MODE" == "orchestrator" ]] && exit 0

# ── Gate 2: edit target inside repo working tree ──────────────────────────────

_target_path=""
case "$TOOL_NAME" in
    Edit|Write)
        _target_path=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null || true)
        ;;
    NotebookEdit)
        _target_path=$(printf '%s' "$INPUT" | jq -r '.tool_input.notebook_path // ""' 2>/dev/null || true)
        ;;
    *)
        exit 0
        ;;
esac

[[ -z "$_target_path" ]] && exit 0

# Skip edits targeting .claude/ dirs or global config (outside project)
case "$_target_path" in
    "${HOME}/.claude/"*|"${XDG_CONFIG_HOME:-$HOME/.config}/"*)
        exit 0
        ;;
esac

# ── Gate 3: cwd must be a git repo ───────────────────────────────────────────

REPO_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || true)
[[ -z "$REPO_ROOT" ]] && exit 0

# Normalize REPO_ROOT through realpath (resolves macOS /var → /private/var symlinks and
# other symlink chains). The CWD directory always exists so realpath can resolve it fully.
# We don't normalize the target path because it may not exist yet (about to be written).
# Instead we check if the target starts with CWD (raw) or REPO_ROOT (raw or resolved).
if command -v realpath >/dev/null 2>&1; then
    REPO_ROOT=$(realpath "$REPO_ROOT" 2>/dev/null || printf '%s' "$REPO_ROOT")
    _norm_cwd=$(realpath "$CWD" 2>/dev/null || printf '%s' "$CWD")
else
    _norm_cwd="$CWD"
fi

# Target must be under the repo root (matched against normalized OR raw CWD prefix to
# handle macOS symlink differences between what the hook input reports vs git's view).
_target_in_repo=0
case "$_target_path" in
    "${REPO_ROOT}/"*|"${REPO_ROOT}") _target_in_repo=1 ;;
    "${_norm_cwd}/"*|"${_norm_cwd}") _target_in_repo=1 ;;
    "${CWD}/"*|"${CWD}") _target_in_repo=1 ;;
esac
[[ "$_target_in_repo" -eq 0 ]] && exit 0

# ── Gate 4: no existing PROJECT_PLAN.md ──────────────────────────────────────

PLAN_PRIMARY="${REPO_ROOT}/docs/plans/PROJECT_PLAN.md"
PLAN_FALLBACK="${REPO_ROOT}/PROJECT_PLAN.md"

if [[ -f "$PLAN_PRIMARY" || -f "$PLAN_FALLBACK" ]]; then
    exit 0
fi

# ── Gate 5: find ExitPlanMode since last real user turn in session JSONL ─────

# Construct session JSONL path: encode CWD by replacing all / with -
_encoded_cwd="${CWD//\//-}"
JSONL_PATH="${HOME}/.claude/projects/${_encoded_cwd}/${SESSION_ID}.jsonl"

if [[ ! -f "$JSONL_PATH" ]]; then
    _debug "JSONL not found at $JSONL_PATH — skipping"
    exit 0
fi

# Use python3 (always available on macOS) to parse JSONL safely.
# We scan from the END of the file, working backward:
#   - First ExitPlanMode we encounter is our candidate.
#   - If we hit a non-meta user message before finding ExitPlanMode, stop
#     (plan was from a prior turn — don't re-promote).
#
# The python script is written as a here-string to a temp variable and run via
# python3 -c to avoid bash heredoc-inside-$() parsing issues with || operators.
_py_script='
import sys, json
path = sys.argv[1]
try:
    fh = open(path)
    lines = fh.readlines()
    fh.close()
except Exception:
    sys.exit(0)
plan = None
for line in reversed(lines):
    line = line.strip()
    if not line:
        continue
    try:
        obj = json.loads(line)
    except Exception:
        continue
    t = obj.get("type", "")
    if t == "user" and not obj.get("isMeta", False):
        break
    if t == "assistant":
        content = obj.get("message", {}).get("content", [])
        for item in content:
            if isinstance(item, dict) and item.get("name") == "ExitPlanMode":
                plan = item.get("input", {}).get("plan", "")
                break
        if plan is not None:
            break
if plan:
    sys.stdout.write(plan)
'

PLAN_TEXT=""
if command -v python3 >/dev/null 2>&1; then
    PLAN_TEXT=$(python3 -c "$_py_script" "$JSONL_PATH" 2>/dev/null) || PLAN_TEXT=""
fi

[[ -z "$PLAN_TEXT" ]] && exit 0

# ── Promote plan to docs/plans/PROJECT_PLAN.md ───────────────────────────────

PROMO_TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DOCS_PLANS_DIR="${REPO_ROOT}/docs/plans"

mkdir -p "$DOCS_PLANS_DIR" 2>/dev/null || {
    _debug "Failed to create $DOCS_PLANS_DIR"
    exit 0
}

{
    printf '<!-- auto-promoted from session plan by borg-plan-promote.sh at %s -->\n\n' "$PROMO_TS"
    printf '%s\n' "$PLAN_TEXT"
} > "$PLAN_PRIMARY" 2>/dev/null || {
    _debug "Failed to write $PLAN_PRIMARY"
    exit 0
}

printf '[borg] auto-promoted in-session plan to docs/plans/PROJECT_PLAN.md\n' >&2

exit 0
