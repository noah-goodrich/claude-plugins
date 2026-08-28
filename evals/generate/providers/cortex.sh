#!/usr/bin/env bash
# cortex.sh — Snowflake Cortex Code CLI provider for the eval generator.
#
#   cortex.sh model                   print the model id recorded in frontmatter
#   cortex.sh preflight               exit 0 if usable, 2 with a reason naming what is missing
#   cortex.sh generate <prompt-file>  write the completion text to stdout
#
# Two things make this provider different from the HTTP ones.
#
# 1. The CLI does not report which model answered, so CORTEX_MODEL must be set explicitly. Guessing
#    an id would put a false claim in the provenance frontmatter, which is the one thing this corpus
#    exists to avoid.
# 2. Cortex authenticates against Snowflake and may want a browser. It is driven here with stdin
#    closed and under a wall-clock timeout, so an interactive prompt fails fast and loudly instead
#    of hanging a batch run. The plan allows the provider count to drop to two; it does not allow a
#    silent stall.
#
# preflight makes no network call, so it proves the CLI and the model id are present and nothing
# more. Snowflake auth is only proven when a document is actually generated.

set -uo pipefail

CORTEX_BIN="${CORTEX_BIN:-cortex}"
MODEL="${CORTEX_MODEL:-}"
TIMEOUT="${CORTEX_TIMEOUT:-300}"

TMPD=""
cleanup() { [ -n "$TMPD" ] && rm -rf "$TMPD"; return 0; }
trap cleanup EXIT

warn() { printf '%s\n' "$*" >&2; }

cmd_model() { printf '%s\n' "$MODEL"; }

cmd_preflight() {
    if ! command -v "$CORTEX_BIN" >/dev/null 2>&1; then
        warn "the '$CORTEX_BIN' CLI is not on PATH"
        return 2
    fi
    if [ -z "$MODEL" ]; then
        warn "CORTEX_MODEL is not set — the cortex CLI does not report which model answered, so the exact model id has to be supplied for provenance"
        return 2
    fi
    printf 'cortex CLI present, model %s (Snowflake auth is only proven at generate time)\n' "$MODEL"
    return 0
}

# Portable wall-clock timeout: macOS ships no timeout(1). Leaves $TMPD/timedout behind when it fires.
run_with_timeout() {
    local secs="$1"; shift
    local pid killer rc

    "$@" </dev/null >"$TMPD/raw.txt" 2>"$TMPD/err.txt" &
    pid=$!
    ( sleep "$secs"; : > "$TMPD/timedout"; kill -TERM "$pid" 2>/dev/null ) &
    killer=$!

    wait "$pid"
    rc=$?
    kill -TERM "$killer" 2>/dev/null
    wait "$killer" 2>/dev/null
    return "$rc"
}

cmd_generate() {
    local prompt_file="${1:-}" prompt rc text
    [ -n "$prompt_file" ] || { warn "cortex: generate needs a prompt file"; return 2; }
    [ -f "$prompt_file" ] || { warn "cortex: no such prompt file: $prompt_file"; return 2; }
    cmd_preflight >/dev/null || return 2

    umask 077
    TMPD="$(mktemp -d "${TMPDIR:-/tmp}/evals-cortex.XXXXXX")" || return 1
    mkdir -p "$TMPD/work"
    prompt="$(cat "$prompt_file")"

    # An empty --setting-sources and a scratch working directory keep project rules, skills, and
    # repository context out of the prompt. This document has to be plain model prose.
    run_with_timeout "$TIMEOUT" "$CORTEX_BIN" \
        --workdir "$TMPD/work" \
        --setting-sources "" \
        --no-mcp \
        --no-auto-update \
        --model "$MODEL" \
        --print "$prompt"
    rc=$?

    if [ -e "$TMPD/timedout" ]; then
        warn "cortex: no completion within ${TIMEOUT}s — it is most likely waiting on interactive Snowflake auth"
        warn "  authenticate first (cortex connections list), or drop cortex from this run"
        sed 's/^/  /' "$TMPD/err.txt" | head -20 >&2
        return 1
    fi
    if [ "$rc" -ne 0 ]; then
        warn "cortex: the CLI exited $rc"
        sed 's/^/  /' "$TMPD/err.txt" | head -20 >&2
        return 1
    fi

    # --print still emits terminal control sequences and progress carriage returns. Strip them and
    # trim surrounding blank lines; anything past that is the CLI's own framing and is left alone
    # for a human to inspect before the document is trusted.
    text="$(
        tr -d '\r' < "$TMPD/raw.txt" \
            | sed -e 's/'$'\x1b''\[[0-9;?]*[a-zA-Z]//g' \
            | awk 'BEGIN { started = 0 }
                   { lines[NR] = $0; if ($0 ~ /[^[:space:]]/) last = NR }
                   END { for (i = 1; i <= last; i++) {
                             if (!started && lines[i] !~ /[^[:space:]]/) continue
                             started = 1
                             print lines[i]
                         } }'
    )"

    if [ -z "$text" ]; then
        warn "cortex: the CLI produced no usable output"
        sed 's/^/  /' "$TMPD/err.txt" | head -20 >&2
        return 1
    fi

    printf '%s\n' "$text"
    return 0
}

case "${1:-}" in
    model)     cmd_model ;;
    preflight) cmd_preflight ;;
    generate)  shift; cmd_generate "$@" ;;
    *)
        warn "usage: cortex.sh {model|preflight|generate <prompt-file>}"
        exit 2 ;;
esac
