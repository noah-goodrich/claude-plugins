#!/usr/bin/env bash
# PreToolUse guard for the live research-tools eval, registered through --settings (never a user settings file).
#
# WHY A HOOK AND NOT ONLY AN ALLOWLIST. A deny here is a tool_use that REACHES the transcript and is then refused, so the
# B2 case can observe "the skill tried to run pandoc" while nothing runs. With Bash removed from the tool list the
# attempt could never be observed, and with Bash merely un-allowed a global allow rule in the user's own settings could
# still let a command through. A hook deny outranks both.
#
#   Bash                      denied always (pandoc must never run; nothing may land in ~/Documents)
#   Write / Edit / MultiEdit  denied unless the target path is inside the run's working directory (the fixture)
#
# Reads the hook JSON on stdin. Needs jq; without it everything is denied (fail closed).

in="$(cat)"
deny() {
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$1"
    exit 0
}
command -v jq >/dev/null 2>&1 || deny "eval guard: jq missing, failing closed"

tool="$(printf '%s' "$in" | jq -r '.tool_name // ""')"
case "$tool" in
    Bash) deny "eval guard: Bash is disabled in this eval" ;;
    Write|Edit|MultiEdit|NotebookEdit)
        cwd="$(printf '%s' "$in" | jq -r '.cwd // ""')"
        fp="$(printf '%s' "$in" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""')"
        [ -n "$cwd" ] && [ -n "$fp" ] || deny "eval guard: no path, failing closed"
        case "$fp" in /*) ;; *) fp="$cwd/$fp" ;; esac
        case "$fp" in
            *..*) deny "eval guard: path escapes the fixture" ;;
            "$cwd"/*) ;;
            *) deny "eval guard: writes are limited to the fixture directory" ;;
        esac
        ;;
esac
exit 0
