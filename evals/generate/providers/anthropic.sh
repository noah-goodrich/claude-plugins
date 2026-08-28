#!/usr/bin/env bash
# anthropic.sh — Anthropic Messages API provider for the eval generator.
#
#   anthropic.sh model                   print the model id recorded in frontmatter
#   anthropic.sh preflight               exit 0 if usable, 2 with a reason naming what is missing
#   anthropic.sh generate <prompt-file>  write the completion text to stdout
#
# preflight makes no network call — the dry run calls it, and the dry run must not touch the wire.
# The key is never printed and never appears in a command line: it goes into a mode-600 curl config
# file that is deleted on exit.

set -uo pipefail

MODEL="${ANTHROPIC_MODEL:-claude-opus-5}"
API_URL="${ANTHROPIC_API_URL:-https://api.anthropic.com/v1/messages}"
API_VERSION="${ANTHROPIC_API_VERSION:-2023-06-01}"
MAX_TOKENS="${ANTHROPIC_MAX_TOKENS:-16000}"
HTTP_TIMEOUT="${ANTHROPIC_HTTP_TIMEOUT:-900}"

TMPD=""
cleanup() { [ -n "$TMPD" ] && rm -rf "$TMPD"; return 0; }
trap cleanup EXIT

warn() { printf '%s\n' "$*" >&2; }

cmd_model() { printf '%s\n' "$MODEL"; }

cmd_preflight() {
    local tool
    if [ -z "${ANTHROPIC_SDK_KEY:-}" ]; then
        warn "ANTHROPIC_SDK_KEY is not set"
        return 2
    fi
    for tool in curl jq; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            warn "required tool '$tool' is not on PATH"
            return 2
        fi
    done
    printf 'ANTHROPIC_SDK_KEY set, model %s\n' "$MODEL"
    return 0
}

cmd_generate() {
    local prompt_file="${1:-}" payload cfg resp code rc stop text
    [ -n "$prompt_file" ] || { warn "anthropic: generate needs a prompt file"; return 2; }
    [ -f "$prompt_file" ] || { warn "anthropic: no such prompt file: $prompt_file"; return 2; }
    cmd_preflight >/dev/null || return 2

    umask 077
    TMPD="$(mktemp -d "${TMPDIR:-/tmp}/evals-anthropic.XXXXXX")" || return 1
    payload="$TMPD/payload.json"
    cfg="$TMPD/curl.cfg"
    resp="$TMPD/resp.json"

    # The thinking parameter is deliberately unset. Whatever the model does by default is what the
    # deployed path does by default, and that is the population this corpus has to represent.
    jq -n \
        --arg model "$MODEL" \
        --argjson max_tokens "$MAX_TOKENS" \
        --rawfile prompt "$prompt_file" \
        '{model: $model, max_tokens: $max_tokens, messages: [{role: "user", content: $prompt}]}' \
        > "$payload"
    rc=$?
    if [ "$rc" -ne 0 ]; then
        warn "anthropic: could not build the request payload (jq exit $rc)"
        return 1
    fi

    {
        printf 'url = "%s"\n' "$API_URL"
        printf 'header = "x-api-key: %s"\n' "$ANTHROPIC_SDK_KEY"
        printf 'header = "anthropic-version: %s"\n' "$API_VERSION"
        printf 'header = "content-type: application/json"\n'
    } > "$cfg"

    # --max-time is per attempt and curl resets it on every retry, so --retry 2 alone
    # allows 3 x HTTP_TIMEOUT of wall clock per document. --retry-max-time caps the whole
    # window instead. Setting it to one attempt's budget is deliberate: a fast failure
    # (429, 5xx) still retries inside the window, while a timeout does not — a timed-out
    # request was already generated and billed server-side, so retrying it pays twice.
    code="$(curl -sS --config "$cfg" \
        --max-time "$HTTP_TIMEOUT" --retry 2 --retry-delay 5 --retry-max-time "$HTTP_TIMEOUT" \
        --data-binary "@$payload" -o "$resp" -w '%{http_code}')"
    rc=$?
    if [ "$rc" -ne 0 ]; then
        warn "anthropic: the request to $API_URL failed (curl exit $rc)"
        return 1
    fi

    if [ "$code" != "200" ]; then
        warn "anthropic: HTTP $code from $API_URL"
        jq -r '.error.message? // empty' "$resp" 2>/dev/null | sed 's/^/  /' >&2
        return 1
    fi

    stop="$(jq -r '.stop_reason // ""' "$resp")"
    case "$stop" in
        refusal)
            warn "anthropic: the model declined this request (stop_reason: refusal)"
            jq -r '.stop_details.category? // empty' "$resp" | sed 's/^/  category: /' >&2
            return 1 ;;
        max_tokens)
            warn "anthropic: hit max_tokens ($MAX_TOKENS) — a truncated article is not usable evidence"
            warn "  raise ANTHROPIC_MAX_TOKENS and regenerate this document"
            return 1 ;;
    esac

    text="$(jq -r '[.content[]? | select(.type == "text") | .text] | join("")' "$resp")"
    if [ -z "$text" ]; then
        warn "anthropic: the response carried no text block (stop_reason: ${stop:-none})"
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
        warn "usage: anthropic.sh {model|preflight|generate <prompt-file>}"
        exit 2 ;;
esac
