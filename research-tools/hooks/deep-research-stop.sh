#!/usr/bin/env bash
# deep-research-stop.sh — Stop hook that runs the fail-closed ground gate.
#
# Directive 01 — Fail-Closed Ground Gate (research-tools).
#
# Behavior:
#   - Invokes deep-research-verify.sh against a deliverable registered for THIS session
#     via the docs/research/.gate-armed marker (written by the methodology skill at the
#     start of Phase 3 / when it creates the deliverable directory), or against a dir
#     passed through DEEP_RESEARCH_DIR (tests / manual runs).
#   - On NON-ZERO verifier exit: injects a BLOCKING message
#       "NOT fact-checked — verification gate failed: <reason>"
#     and refuses to let the deliverable be presented as PASS. The block is surfaced
#     to Claude via stderr + the Stop-hook block protocol (JSON decision=block).
#   - On ZERO verifier exit: permits presentation and prints the honest badge.
#   - Armed-but-no-registered-deliverable: exits 0 with a NON-BLOCKING advisory. This
#     covers (a) the workflow/harness modality that produces no card deliverable, (b) a
#     session whose cwd carries stale pre-gate deliverables it never touched, and (c) a
#     rapid-tier run that produces no verification report. NEVER auto-discovers the
#     newest docs/research/ dir and hard-blocks on it.
#
# Session scoping — the transcript arms, the marker targets:
#   The transcript grep fires on ANY deep-research Skill invocation, including the
#   workflow/harness modality that returns a JSON report and writes NO docs/research/
#   card deliverable. Without an explicit registered path the stop hook would fall back
#   to auto-discover — latching the newest pre-existing deliverable and hard-blocking on
#   it even though the current session never touched it. The .gate-armed marker is
#   written only by the methodology skill, only when it creates an on-disk deliverable,
#   and contains the exact path the verifier should target. That makes the gate
#   modality-specific (no workflow blocks). Session scoping comes from TRANSCRIPT_ARMED,
#   NOT from the marker — see the scope guard below for why.
#
# This hook is the enforcement arm. The verifier is no-model and deterministic; this
# hook only composes its machine-readable status lines into a user-facing verdict.
#
# Stop-hook input is JSON on stdin (session_id, cwd, transcript_path, ...). We only
# need cwd to know where to run the gate.

set -euo pipefail

# Resolve the verifier next to this hook. CLAUDE_PLUGIN_ROOT is set by Claude Code for
# plugin hooks; fall back to this script's own directory for direct/test invocation.
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY="${CLAUDE_PLUGIN_ROOT:-$HOOK_DIR/..}/hooks/deep-research-verify.sh"
[[ -x "$VERIFY" ]] || VERIFY="$HOOK_DIR/deep-research-verify.sh"

INPUT="$(cat /dev/stdin 2>/dev/null || true)"
CWD=""
TRANSCRIPT=""
STOP_HOOK_ACTIVE=""
if command -v jq >/dev/null 2>&1; then
    CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // ""' 2>/dev/null || true)"
    TRANSCRIPT="$(printf '%s' "$INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || true)"
    STOP_HOOK_ACTIVE="$(printf '%s' "$INPUT" | jq -r 'if .stop_hook_active == true then "1" else "" end' 2>/dev/null || true)"
fi
[[ -n "$CWD" ]] || CWD="$PWD"

# LOOP GUARD. `stop_hook_active` is true when this Stop hook is firing *because* a previous
# Stop hook blocked. Blocking again cannot add information — the model already received the
# reason — so re-blocking only spins until the harness trips its consecutive-block cap and
# overrides us, which is a worse outcome than one clean block: the operator sees a harness
# error instead of the gate verdict. Block once, then stand down.
if [[ -n "$STOP_HOOK_ACTIVE" ]]; then
    printf 'deep-research ground gate: already reported this turn (stop_hook_active) — standing down\n' >&2
    exit 0
fi

# Did THIS session actually run the evidence-mode research skill? The reliable, automatic,
# and specific signal is a `Skill` tool_use entry in the Stop hook's own transcript whose
# skill field is the unified research front door (`research`) or its evidence-mode alias
# (`deep-research`) — in plugin-namespaced (`research-tools:research`) or bare form. This is
# the literal JSON the harness logs for a Skill invocation; it does NOT match a mere prose
# mention of "deep research" (the same transcript carries both, so a naive word grep would
# false-positive). decision-design runs also match `research` but produce no .gate-armed
# marker, so they hit the non-blocking advisory branch below — never a hard block.
# Absent / empty / unreadable transcript -> NOT armed (stay dormant, never block).
TRANSCRIPT_ARMED=""
if [[ -n "$TRANSCRIPT" && -r "$TRANSCRIPT" ]]; then
    if grep -Eq '"name":"Skill","input":\{"skill":"(research-tools:)?(deep-research|research)"' "$TRANSCRIPT"; then
        TRANSCRIPT_ARMED="1"
    fi
fi

# Honor an explicit target dir for testing / manual runs. Always engages, unchanged.
TARGET="${DEEP_RESEARCH_DIR:-}"

# Scope guard. As a plugin-global Stop hook this fires on EVERY session's Stop, so it
# must NOT block an arbitrary project just because it happens to carry a docs/research/
# tree (ingle, reveal, troth, borg-collective all do). Engagement requires:
#   1. an explicit DEEP_RESEARCH_DIR (tests / manual runs), OR
#   2. the gate being armed BY THIS SESSION, signalled by EITHER of:
#       a. TRANSCRIPT_ARMED (the transcript proves THIS session ran the deep-research skill)
#       b. DEEP_RESEARCH_GATE_ARM env var is set (test/CI override)
# When neither holds the hook exits dormant. An unreadable/absent transcript counts as NOT
# armed — fail-safe dormancy is correct when we cannot confirm arming.
#
# The .gate-armed marker is deliberately NOT an arming signal. It is a plain file in a
# shared repo carrying no session identity, so treating its mere existence as arming let ANY
# session inherit the gate — including one that only `cd`-ed into the repo and never ran the
# skill. That is the cross-session false block the scoping was meant to prevent. Observed
# 2026-09-03: a session reviewing a PR in ~/dev/dbt was blocked nine consecutive times by a
# concurrent research session's marker. The marker answers WHERE to look; the transcript
# answers WHETHER this session is in scope.
if [[ -z "$TARGET" ]]; then
    if [[ -z "$TRANSCRIPT_ARMED" && -z "${DEEP_RESEARCH_GATE_ARM:-}" ]]; then
        exit 0
    fi
    # The gate is armed this session. Resolve the registered deliverable path from the
    # .gate-armed marker. The marker contains the path (absolute or relative-to-cwd) of
    # the docs/research/<deliverable> directory that THIS session created. If the marker
    # is absent (workflow/harness modality, rapid tier, or any run that produced no card
    # deliverable), we CANNOT target a specific this-session deliverable — emit an advisory
    # (exit 2 semantics, NON-blocking) rather than auto-discovering and hard-blocking on a
    # stale or pre-existing deliverable.
    MARKER="$CWD/docs/research/.gate-armed"
    if [[ -f "$MARKER" ]]; then
        REGISTERED_DIR="$(tr -d '[:space:]' < "$MARKER")"
        # Resolve to absolute path: if not already absolute, treat as relative to CWD.
        case "$REGISTERED_DIR" in
            /*) TARGET="$REGISTERED_DIR" ;;
            *)  TARGET="$CWD/$REGISTERED_DIR" ;;
        esac
        if [[ -z "$REGISTERED_DIR" || ! -d "$TARGET" ]]; then
            printf 'deep-research ground gate: not run — .gate-armed marker present but registered dir not found (%s)\n' "${TARGET:-empty}" >&2
            exit 0
        fi
    else
        # Armed but no .gate-armed marker: the skill ran but produced no card deliverable
        # (workflow modality, rapid tier, early-termination, etc.). Never auto-discover.
        printf 'deep-research ground gate: not run — gate armed but no this-session deliverable registered (no .gate-armed marker); stale deliverables not checked\n' >&2
        exit 0
    fi
fi

set +e
GATE_OUTPUT="$("$VERIFY" "$TARGET" 2>&1)"
GATE_RC=$?
set -e

# Extract the first failing reason from the verifier's status lines for the message.
REASON="$(printf '%s\n' "$GATE_OUTPUT" | sed -n 's/^Gate result: FAIL: //p' | head -n1)"
[[ -n "$REASON" ]] || REASON="$(printf '%s\n' "$GATE_OUTPUT" | sed -n 's/^GATE: [^ ]* FAIL //p' | head -n1)"
[[ -n "$REASON" ]] || REASON="verification gate did not pass"

if [[ "$GATE_RC" -eq 0 ]]; then
    # PASS — permit presentation and surface the honest badge.
    BADGE="$(printf '%s\n' "$GATE_OUTPUT" | sed -n 's/^Badge: //p' | head -n1)"
    printf 'deep-research ground gate: PASS — %s\n' "$BADGE"
    exit 0
elif [[ "$GATE_RC" -eq 2 ]]; then
    # Exit 2 is a LOCATE/USAGE error (no deliverable found), NOT a failed hard assertion.
    # Reporting it as "verification gate failed" would block the session on a usage error;
    # surface a distinct, NON-blocking advisory instead and let the session conclude.
    LOCATE_REASON="$(printf '%s\n' "$GATE_OUTPUT" | sed -n 's/^GATE: locate FAIL //p' | head -n1)"
    [[ -n "$LOCATE_REASON" ]] || LOCATE_REASON="could not locate a docs/research deliverable to verify"
    printf 'deep-research ground gate: not run — %s\n' "$LOCATE_REASON" >&2
    exit 0
fi

# Exit 1 (or any other non-zero) — a real hard-assertion failure. Block and refuse PASS.
BLOCK_MSG="NOT fact-checked — verification gate failed: ${REASON}"

# Emit the Stop-hook block protocol so Claude is prevented from concluding the run as
# fact-checked. decision=block feeds `reason` back to the model; we also print the full
# gate output to stderr for the operator.
printf '%s\n' "$GATE_OUTPUT" >&2
printf '%s\n' "$BLOCK_MSG" >&2

if command -v jq >/dev/null 2>&1; then
    jq -n --arg reason "$BLOCK_MSG" '{decision: "block", reason: $reason}'
else
    printf '{"decision":"block","reason":"%s"}\n' "$BLOCK_MSG"
fi

# Non-zero exit also signals failure to harnesses that key on exit codes.
exit 2
