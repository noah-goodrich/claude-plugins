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
# ~/.local/state/borg/plan-promote-debug.log and exits 0.
#
# Registered as a PreToolUse hook in ~/.claude/settings.json.

set -euo pipefail

PATH="${HOME}/.config/dotfiles/zsh/bin:${HOME}/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin${PATH:+:$PATH}"
export PATH

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/borg"
DEBUG_LOG="$STATE_DIR/plan-promote-debug.log"

_debug() {
    mkdir -p "$STATE_DIR" 2>/dev/null || true
    # Retention: cap the log at 1 MiB, one previous generation (_borg_rotate_log, lib/borg-hooks.sh).
    { type _borg_rotate_log >/dev/null 2>&1 && _borg_rotate_log "$DEBUG_LOG"; } 2>/dev/null || true
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

# Machine-local operational state root: ${XDG_STATE_HOME:-$HOME/.local/state}/borg (blank == unset).
# Siblings: lib/state-root.zsh and borg_core/paths.py::state_root -- keep all three identical.
_borg_state_root() {
    printf '%s/borg\n' "${XDG_STATE_HOME:-$HOME/.local/state}"
}

# First 12 hex of sha256 over stdin (shasum on macOS, sha256sum elsewhere).
_borg_sha12() {
    { shasum -a 256 2>/dev/null || sha256sum; } | cut -c1-12
}

# Key naming one project DIRECTORY's machine-local state: <repo12>-<path12>, or local-<path12> outside a git
# repo. path12 = sha256 of the PHYSICAL directory path (pwd -P, no trailing slash); repo12 = sha256 of
# `git rev-parse --path-format=absolute --git-common-dir`. Per directory (worktrees of one repo can be in
# different statuses at once), namespaced by repo. Siblings, byte-identical: borg_core/paths.py::
# project_state_key and the other shell copy. Rationale lives in the Python docstring.
# Usage: _borg_project_state_key <dir> [repo]
# The optional 2nd arg (even empty) is the registry entry's `repo` field: it replaces the git fork, and
# empty means outside git (path-only key). Omit it to fork git. Python sibling: project_state_key(dir, repo).
_borg_project_state_key() {
    local _d="${1:?_borg_project_state_key: dir required}" _phys _repo _tail="" _base _anc
    while [ "${#_d}" -gt 1 ] && [ "${_d%/}" != "$_d" ]; do _d="${_d%/}"; done
    # A missing directory still resolves like Python's realpath: physicalise the deepest existing ancestor.
    _anc="$_d"
    while [ -n "$_anc" ] && [ ! -d "$_anc" ]; do
        _base="${_anc##*/}"
        _tail="/$_base$_tail"
        case "$_anc" in
            */*) _anc="${_anc%/*}" ;;
            *) _anc="." ;;
        esac
    done
    _phys="$(cd "${_anc:-/}" 2>/dev/null && pwd -P)" || _phys="$_d"
    [ "$_phys" = "/" ] && _phys=""
    _phys="$_phys$_tail"
    [ -n "$_phys" ] || _phys="/"
    if [ "${2+set}" = set ]; then
        _repo="$2"
    else
        _repo="$(git -C "$_phys" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || _repo=""
    fi
    if [ -n "$_repo" ]; then
        printf '%s-%s\n' "$(printf '%s' "$_repo" | _borg_sha12)" "$(printf '%s' "$_phys" | _borg_sha12)"
    else
        printf 'local-%s\n' "$(printf '%s' "$_phys" | _borg_sha12)"
    fi
}

# <state root>/projects/<key>/state.json for a project directory. Creates nothing.
# Usage: _borg_project_state_file <dir> [repo]    (repo: see _borg_project_state_key)
_borg_project_state_file() {
    printf '%s/projects/%s/state.json\n' "$(_borg_state_root)" "$(_borg_project_state_key "${1:?_borg_project_state_file: dir required}" ${2+"$2"})"
}

# Resolve an operational file for READING: the state root's copy if it exists, else the old
# config-dir location ($BORG_DIR, else ${XDG_CONFIG_HOME:-$HOME/.config}/borg). Expand phase of the
# config -> state-root move: readers accept both before any writer moves. Neither existing prints
# the OLD path, so callers' absent handling is unchanged. Reader-only; writers must not call this.
# Usage: _borg_operational_file <name>     (name may contain a subdir, e.g. recon/last-run)
_borg_operational_file() {
    local _new
    _new="$(_borg_state_root)/${1:?_borg_operational_file: name required}"
    if [ -e "$_new" ]; then
        printf '%s\n' "$_new"
    else
        printf '%s/%s\n' "${BORG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/borg}" "$1"
    fi
}

# Log retention: cap an append-only log at BORG_LOG_CAP_BYTES, keeping ONE previous generation.
# Cap = 1 MiB: roughly 8,000 memory-hits rows or 2,000 agents.jsonl rows -- months of history at
# today's write rates, so a history reader loses nothing it uses, while the worst case per log is
# 2 MiB (file + .1). One generation, not N: the fewest moving parts that still bounds disk.
# Siblings: borg_core/retention.py::rotate_log (Python). Same contract: size >= cap rotates.
# Call it IMMEDIATELY BEFORE the append, so the live file exists again as soon as the write lands
# (tail -n 1 readers such as usage-samples.jsonl never see a missing file after a write).
# Usage: _borg_rotate_log <file> [cap_bytes]
# Returns: 0 always; silent on every path (fail-open -- a hook's stdout is JSON).
# Race: two concurrent writers may both rotate, costing at most the older generation.
_borg_rotate_log() {
    local _f="${1:-}" _cap="${2:-${BORG_LOG_CAP_BYTES:-1048576}}" _size
    { [ -n "$_f" ] && [ -f "$_f" ] && [ ! -L "$_f" ]; } 2>/dev/null || return 0
    case "$_cap" in ''|*[!0-9]*) _cap=1048576 ;; esac
    _size="$(wc -c < "$_f" 2>/dev/null | tr -d ' ')" || return 0
    case "$_size" in ''|*[!0-9]*) return 0 ;; esac
    [ "$_size" -ge "$_cap" ] 2>/dev/null || return 0
    { mv -f "$_f" "$_f.1"; } 2>/dev/null || true
    return 0
}

# Canonical path to a project's state file.
# Usage: _borg_state_file <project_dir>
_borg_state_file() {
    printf '%s/.borg/state.json\n' "${1:?_borg_state_file: dir required}"
}

# The state.json to READ for a project: the per-project state-root copy if it exists, else the legacy
# <dir>/.borg/state.json (also the answer when neither exists, so absent-handling is unchanged). Expand phase of
# AC5: readers accept both before any writer moves. READER-ONLY -- writers use
# _borg_project_state_file. Optional 2nd arg is the registry entry's `repo` field (fast path, no git fork; see
# _borg_project_state_key). Usage: _borg_state_read_path <project_dir> [repo]
_borg_state_read_path() {
    local _new
    _new="$(_borg_project_state_file "$@")"
    if [ -f "$_new" ]; then
        printf '%s\n' "$_new"
    else
        _borg_state_file "$1"
    fi
}

# Read state.json; emit '{}' when the file does not exist yet. Reads new-then-legacy; writes go to
# the new path.
# Usage: _borg_state_read <project_dir> [repo]
_borg_state_read() {
    local sf
    sf=$(_borg_state_read_path "$@")
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

# Set the global _REPO to the registry `repo` of <project> when its entry is registered AT <proj_dir>
# (possibly empty: no repo recorded == the path-only key); leave _REPO UNSET otherwise. Callers expand
# `${_REPO+"$_REPO"}` into the state helpers, so a registered project is keyed exactly as every registry-driven
# reader keys it (borg-link-down's overlay, registry.zsh, borg_core.link) and an unregistered CWD forks git.
# A writer keying differently from the readers would leave a stale shadow. Reads $BORG_REGISTRY.
# Usage: _borg_proj_repo <project> <proj_dir>
_borg_proj_repo() {
    local _r
    unset _REPO
    [[ -f "${BORG_REGISTRY:-}" ]] || return 0
    _r=$(jq -r --arg p "$1" --arg d "$2" \
        '.projects[$p] | select((.path // "") == $d) | "R" + (.repo // "" | if type == "string" then . else "" end)' \
        "$BORG_REGISTRY" 2>/dev/null) || return 0
    [[ -n "$_r" ]] && _REPO="${_r#R}"
    return 0
}

# Atomic write to the per-project state-root path (AC5 step c: the legacy <dir>/.borg/state.json is never
# written) -- strip control chars, reject empty result, tmp+mv. Optional 3rd arg: registry `repo` (see
# _borg_project_state_key); omit it to fork git.
# Usage: _borg_state_write <project_dir> <json> [repo]
_borg_state_write() {
    local dir="$1" json="$2"
    local sf
    sf=$(_borg_project_state_file "$dir" ${3+"$3"})
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

# ── Inlined: reaper.sh ──────────────────────────────────────────────────────
#!/usr/bin/env sh
# shellcheck shell=bash  # lint as bash: both bash (hooks) and zsh source this file
# lib/reaper.sh — shared reaper predicate for borg hooks and the zsh CLI.
#
# Sourceable from both bash (hooks) and zsh (lib/registry.zsh). Provides:
#   BORG_REAP_STALE_HOURS — staleness threshold in hours (default 12)
#   _borg_should_reap <status> <last_activity_iso> <has_live_window: 1|0>
#   _borg_worktree_is_stale <repo_path> <worktree_path>
#   _borg_reap_worktrees <repo_path>   (BORG_REAP_DRY_RUN=1: print, remove nothing; BORG_REAP_GH=1: allow gh)

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
#   ${XDG_STATE_HOME:-$HOME/.local/state}/borg/worktrees/<repo-basename>/<slug>
#
# A worktree is considered stale when its branch has been merged into the repo's
# default branch OR when its last activity (tip commit / index mtime) is older than
# BORG_REAP_STALE_HOURS and it has no unpushed commits. Only worktrees under the borg state dir are ever
# touched — non-borg worktrees are completely ignored.

# DERIVED, NEVER HARDCODED. This default shipped as a literal `/Users/noah/...` on 2026-06-10
# (6501294) and was wrong on the machine it shipped from -- $HOME is /Users/<user> -- so
# `_borg_reap_worktrees` hit its `[ -d "$wt_base" ] || return 0` guard on every repo and the
# hourly LaunchAgent was a no-op for ~3.5 months while 15 real worktrees accumulated under the
# correct path. Nothing in borg.zsh, install.sh or any hook sets this variable: the only
# assignments in the tree are in tests, which is precisely why the suite stayed green. Same class
# as the BORG_REGISTRY and XDG_CONFIG_HOME entries under Learned in CLAUDE.md -- a test that
# supplies the value the production path is supposed to derive proves nothing about production.
#
# The expression is byte-identical to the one install.sh uses for its usage-watch paths and to
# cmd_doctor's `state_dir` in borg.zsh, so the reaper cannot read a directory `borg doctor` does not
# report on. NAMED, NOT PINNED: `docs/plans/directives/2026-08-31-retire-the-line-pin.md` retires
# `file:NNN` from prose repo-wide, and this comment earned the lesson the hard way -- the first
# draft pinned two line numbers, and review found the same pin resolving to 2496 on this branch and
# 2482 on another, both correct for where they were read. Grep the expression instead.
BORG_WORKTREE_STATE_DIR="${BORG_WORKTREE_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/borg/worktrees}"

# The ref a branch is judged against: refs/remotes/origin/<default> when it resolves (the local default
# branch can lag origin by many commits), else the local default branch. Prints the ref name.
# Args: <repo_path>
_borg_default_ref() {
    local repo="$1" db
    db=$(git -C "$repo" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
    if [ -z "$db" ]; then
        db=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null) || db="main"
    fi
    if git -C "$repo" rev-parse --verify -q "refs/remotes/origin/${db}^{commit}" >/dev/null 2>&1; then
        printf 'refs/remotes/origin/%s\n' "$db"
    else
        printf '%s\n' "$db"
    fi
}

# THE "is merged" predicate, shared by the stale check and the reason string so they cannot disagree.
# Args: <repo_path> <branch>
# Returns 0 and prints "ancestor" or "squash" when the branch is merged; returns 1 (prints nothing) otherwise.
#   1. ancestor: the branch tip is reachable from the default ref (merge commits, fast-forwards).
#   2. squash: `git merge-tree --write-tree <default> <branch>` yields exactly the default ref's tree, i.e. the
#      branch adds nothing. This repo squash-merges every PR, so (1) never fires for it. A conflict or a
#      different tree means NOT merged (the safe direction); an old git without --write-tree falls through.
#   3. gh (only when BORG_REAP_GH=1, never from hooks): a merged PR exists for the branch. Any failure = no.
# A branch whose tip equals the default tip is a fresh branch with no work, never "merged".
_borg_branch_merged() {
    local repo="$1" branch="$2" dref br_sha d_sha d_tree m_tree
    dref=$(_borg_default_ref "$repo")
    br_sha=$(git -C "$repo" rev-parse "$branch" 2>/dev/null) || return 1
    d_sha=$(git -C "$repo" rev-parse "$dref" 2>/dev/null) || return 1
    [ -n "$br_sha" ] && [ -n "$d_sha" ] && [ "$br_sha" != "$d_sha" ] || return 1

    if git -C "$repo" merge-base --is-ancestor "$branch" "$dref" 2>/dev/null; then
        printf 'ancestor\n'
        return 0
    fi

    d_tree=$(git -C "$repo" rev-parse "${dref}^{tree}" 2>/dev/null) || d_tree=""
    m_tree=$(git -C "$repo" merge-tree --write-tree "$dref" "$branch" 2>/dev/null | sed -n 1p) || m_tree=""
    if [ -n "$d_tree" ] && [ "$m_tree" = "$d_tree" ]; then
        printf 'squash\n'
        return 0
    fi

    if [ "${BORG_REAP_GH:-}" = "1" ]; then
        local n
        n=$(cd "$repo" 2>/dev/null && gh pr list --state merged --head "$branch" --json number --jq length 2>/dev/null) \
            || n=""
        case "$n" in ''|*[!0-9]*) ;; *) if [ "$n" -ge 1 ]; then printf 'squash\n'; return 0; fi;; esac
    fi
    return 1
}

# Predicate: is this worktree stale?
# Args: <repo_path> <worktree_path>
# Returns 0 (stale) when the branch has been merged into the default branch (i.e.
# the branch has unique commits AND all of them are now reachable from the default
# branch), OR when its last activity (the newer of the branch-tip commit time and the per-worktree
# index mtime) is older than BORG_REAP_STALE_HOURS and the branch has no unpushed commits.
# Returns 1 (keep) for fresh or unmerged worktrees.
_borg_worktree_is_stale() {
    local repo="$1" wt="$2"
    [ -d "$wt" ] || return 0

    local wt_branch
    wt_branch=$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1

    if _borg_branch_merged "$repo" "$wt_branch" >/dev/null; then
        return 0
    fi

    local default_branch
    default_branch=$(_borg_default_ref "$repo")

    # Never reap on age while the branch holds work that exists nowhere else: commits not on
    # its upstream, or (no upstream) commits not on the default branch.
    local ahead
    if git -C "$wt" rev-parse --verify -q '@{u}' >/dev/null 2>&1; then
        ahead=$(git -C "$wt" rev-list --count '@{u}..HEAD' 2>/dev/null) || ahead=1
    else
        ahead=$(git -C "$wt" rev-list --count "${default_branch}..HEAD" 2>/dev/null) || ahead=1
    fi
    case "$ahead" in ''|*[!0-9]*) return 1;; esac
    [ "$ahead" -gt 0 ] && return 1

    # Activity = newest of the branch tip's committer time and the per-worktree index mtime.
    # The worktree directory's own mtime is NOT used: it changes only when direct entries are
    # added or removed, so commits and subdirectory edits never touched it.
    local threshold="${BORG_REAP_STALE_HOURS:-12}"
    local ct idx imtime last now age_h
    ct=$(git -C "$wt" log -1 --format=%ct 2>/dev/null)
    case "$ct" in ''|*[!0-9]*) ct=0;; esac
    idx=$(git -C "$wt" rev-parse --git-path index 2>/dev/null)
    case "$idx" in ''|/*) ;; *) idx="$wt/$idx";; esac
    imtime=$(stat -c %Y "$idx" 2>/dev/null || stat -f %m "$idx" 2>/dev/null)
    case "$imtime" in ''|*[!0-9]*) imtime=0;; esac
    last=$ct
    [ "$imtime" -gt "$last" ] && last=$imtime
    [ "$last" -gt 0 ] || return 1
    now=$(date +%s)
    age_h=$(( (now - last) / 3600 ))
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

    # zsh re-declaring an already-set `local` PRINTS `name=value` to stdout, which would corrupt the
    # path<TAB>reason record stream: declare everything once, here, never inside the loop. zsh also
    # treats an unmatched glob as fatal, so enable nullglob there (a no-op elsewhere).
    local wt reason wt_branch kind
    [ -n "${ZSH_VERSION:-}" ] && setopt localoptions nullglob
    for wt in "$wt_base"/*/; do
        wt="${wt%/}"
        [ -d "$wt" ] || continue

        # --no-optional-locks: a plain status may rewrite the index, bumping the very mtime the
        # staleness check reads, so the reaper own probe would count as activity.
        if git -C "$wt" --no-optional-locks status --porcelain 2>/dev/null | grep -q .; then
            continue
        fi

        if _borg_worktree_is_stale "$repo" "$wt"; then
            wt_branch=$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

            kind=$(_borg_branch_merged "$repo" "$wt_branch") || kind=""
            case "$kind" in
                ancestor) reason="branch merged";;
                squash) reason="branch merged (squash)";;
                *) reason="stale (>${BORG_REAP_STALE_HOURS:-12}h)";;
            esac

            if [ "${BORG_REAP_DRY_RUN:-}" = "1" ]; then
                printf '%s\t%s\n' "$wt" "$reason"
                continue
            fi
            if git -C "$repo" worktree remove --force "$wt" 2>/dev/null; then
                printf '%s\t%s\n' "$wt" "$reason"
            fi
        fi
    done

    [ "${BORG_REAP_DRY_RUN:-}" = "1" ] && return 0
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

# PreToolUse stderr on exit 0 goes to the debug log only (https://code.claude.com/docs/en/hooks,
# "Exit code 0"). `systemMessage` is a universal JSON field shown to the user; deliberately NO
# permissionDecision, so tool flow is untouched. Plain text, one object, only on promotion.
jq -n '{systemMessage: "▸ borg: auto-promoted in-session plan to docs/plans/PROJECT_PLAN.md"}' 2>/dev/null || true

exit 0
