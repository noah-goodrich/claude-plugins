#!/usr/bin/env bash
# deep-research-stop.sh — Stop hook that runs the fail-closed ground gate.
#
# Directive 01 — Fail-Closed Ground Gate (research-tools).
#
# Behavior:
#   - Invokes deep-research-verify.sh against the current project's most-recent
#     docs/research/ deliverable (or a dir passed through DEEP_RESEARCH_DIR).
#   - On NON-ZERO verifier exit: injects a BLOCKING message
#       "NOT fact-checked — verification gate failed: <reason>"
#     and refuses to let the deliverable be presented as PASS. The block is surfaced
#     to Claude via stderr + the Stop-hook block protocol (JSON decision=block).
#   - On ZERO verifier exit: permits presentation and prints the honest badge.
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
if command -v jq >/dev/null 2>&1; then
    CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // ""' 2>/dev/null || true)"
fi
[[ -n "$CWD" ]] || CWD="$PWD"

# Honor an explicit target dir for testing; otherwise the verifier auto-discovers
# the most-recent deliverable relative to the project cwd.
TARGET="${DEEP_RESEARCH_DIR:-}"

# Only engage the gate when this project actually has a deep-research deliverable.
# A project with no docs/research/ should not be blocked by an unrelated Stop.
if [[ -z "$TARGET" && ! -d "$CWD/docs/research" ]]; then
    exit 0
fi

set +e
if [[ -n "$TARGET" ]]; then
    GATE_OUTPUT="$("$VERIFY" "$TARGET" 2>&1)"
else
    GATE_OUTPUT="$(cd "$CWD" && "$VERIFY" 2>&1)"
fi
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
fi

# FAIL — inject a blocking message and refuse PASS.
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
