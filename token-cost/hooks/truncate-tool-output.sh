#!/usr/bin/env bash
# truncate-tool-output.sh — OPT-IN PostToolUse hook (token-cost plugin, Lever 1 / C3).
#
# Caps the model-visible output of large Bash/Read tool calls to curb the
# dominant cost lever: cache reads of an ever-growing context. When a tool's
# output exceeds the line threshold, the model-visible result is replaced (via
# the PostToolUse `hookSpecificOutput.updatedToolOutput` field) with the head +
# tail of the output plus a marker stating how many lines were cut and how to
# retrieve the rest. Output AT OR UNDER the threshold is left BYTE-UNCHANGED
# (the hook emits nothing).
#
# SAFETY (this hook can never break a tool result — worst case it does nothing):
#   - Opt-in: inert unless TRUNCATE_TOOL_OUTPUT=1. Not registered in the plugin's
#     default hooks.json; enable it explicitly in settings.json (see README).
#   - Fail-safe: any missing dep, parse error, unknown tool_response shape, or
#     non-numeric count → exit 0 with NO output, leaving the result untouched.
#
# Reads the PostToolUse payload on stdin (tool_name, tool_input, tool_response).
# ALWAYS exits 0.
#
# Tunables (env):
#   TRUNCATE_TOOL_OUTPUT            "1" to enable (default: disabled → exit 0)
#   TRUNCATE_TOOL_OUTPUT_MAX_LINES  line threshold over which output is cut (default 200)
#   TRUNCATE_TOOL_OUTPUT_HEAD       head lines kept (default 120)
#   TRUNCATE_TOOL_OUTPUT_TAIL       tail lines kept (default 40)

# Opt-in gate — inert unless explicitly enabled.
[ "${TRUNCATE_TOOL_OUTPUT:-0}" = "1" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

MAX=${TRUNCATE_TOOL_OUTPUT_MAX_LINES:-200}
HEAD=${TRUNCATE_TOOL_OUTPUT_HEAD:-120}
TAIL=${TRUNCATE_TOOL_OUTPUT_TAIL:-40}

INPUT=$(cat 2>/dev/null || true)
[ -n "$INPUT" ] || exit 0

# Only act on the two high-volume output tools.
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
case "$TOOL" in
    Bash | Read) ;;
    *) exit 0 ;;
esac

# Extract the textual output from tool_response (string, or common object fields).
# Unknown/empty shape → pass through untouched.
OUTPUT=$(printf '%s' "$INPUT" | jq -r '
    (.tool_response // empty)
    | if   type == "string" then .
      elif type == "object" then (.stdout // .output // .content // .text // empty)
      else empty end' 2>/dev/null)
[ -n "$OUTPUT" ] || exit 0

# Count lines; bail (unchanged) on non-numeric or at/under threshold.
NLINES=$(printf '%s\n' "$OUTPUT" | wc -l | tr -d ' ')
[ "$NLINES" -gt "$MAX" ] 2>/dev/null || exit 0

OMITTED=$((NLINES - HEAD - TAIL))
[ "$OMITTED" -gt 0 ] 2>/dev/null || exit 0

HEAD_TXT=$(printf '%s\n' "$OUTPUT" | head -n "$HEAD")
TAIL_TXT=$(printf '%s\n' "$OUTPUT" | tail -n "$TAIL")
MARKER="… [truncated by token-cost: ${OMITTED} of ${NLINES} lines omitted; showing first ${HEAD} + last ${TAIL}. Re-run a narrower command (grep / head -n / sed -n 'A,Bp') or Read a specific line range to see the rest.] …"
NEW=$(printf '%s\n%s\n%s\n' "$HEAD_TXT" "$MARKER" "$TAIL_TXT")

# Emit the replacement. jq builds valid JSON and handles all escaping.
jq -n --arg out "$NEW" \
    '{hookSpecificOutput: {hookEventName: "PostToolUse", updatedToolOutput: $out}}' 2>/dev/null || exit 0
exit 0
