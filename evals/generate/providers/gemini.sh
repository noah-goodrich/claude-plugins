#!/usr/bin/env bash
# gemini.sh — Google Gemini provider for the eval generator (provider id: google).
#
#   gemini.sh model                   print the model id recorded in frontmatter
#   gemini.sh preflight               exit 0 if usable, 2 with a reason naming what is missing
#   gemini.sh generate <prompt-file>  write the completion text to stdout
#
# preflight makes no network call — the dry run calls it, and the dry run must not touch the wire.
# The key is never printed and never appears in a command line: it goes into a mode-600 curl config
# file that is deleted on exit.

set -uo pipefail

MODEL="${GEMINI_MODEL:-gemini-3.7-flash}"
API_BASE="${GEMINI_API_BASE:-https://generativelanguage.googleapis.com/v1beta}"
MAX_TOKENS="${GEMINI_MAX_TOKENS:-32768}"
HTTP_TIMEOUT="${GEMINI_HTTP_TIMEOUT:-900}"

TMPD=""
cleanup() { [ -n "$TMPD" ] && rm -rf "$TMPD"; return 0; }
trap cleanup EXIT

warn() { printf '%s\n' "$*" >&2; }

cmd_model() { printf '%s\n' "$MODEL"; }

cmd_preflight() {
    local tool
    if [ -z "${GOOGLE_API_KEY:-}" ]; then
        warn "GOOGLE_API_KEY is not set"
        return 2
    fi
    for tool in curl jq; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            warn "required tool '$tool' is not on PATH"
            return 2
        fi
    done
    printf 'GOOGLE_API_KEY set, model %s\n' "$MODEL"
    return 0
}

cmd_generate() {
    local prompt_file="${1:-}" url payload cfg resp code rc finish blocked text
    [ -n "$prompt_file" ] || { warn "gemini: generate needs a prompt file"; return 2; }
    [ -f "$prompt_file" ] || { warn "gemini: no such prompt file: $prompt_file"; return 2; }
    cmd_preflight >/dev/null || return 2

    umask 077
    TMPD="$(mktemp -d "${TMPDIR:-/tmp}/evals-gemini.XXXXXX")" || return 1
    payload="$TMPD/payload.json"
    cfg="$TMPD/curl.cfg"
    resp="$TMPD/resp.json"
    url="$API_BASE/models/$MODEL:generateContent"

    # No thinking or safety overrides: the defaults are what an ordinary caller gets, and an
    # ordinary caller is what this class is meant to represent.
    jq -n \
        --argjson max_tokens "$MAX_TOKENS" \
        --rawfile prompt "$prompt_file" \
        '{contents: [{role: "user", parts: [{text: $prompt}]}],
          generationConfig: {maxOutputTokens: $max_tokens}}' \
        > "$payload"
    rc=$?
    if [ "$rc" -ne 0 ]; then
        warn "gemini: could not build the request payload (jq exit $rc)"
        return 1
    fi

    {
        printf 'url = "%s"\n' "$url"
        printf 'header = "x-goog-api-key: %s"\n' "$GOOGLE_API_KEY"
        printf 'header = "content-type: application/json"\n'
    } > "$cfg"

    # --max-time is per attempt and curl resets it on every retry, so --retry 2 alone
    # allows 3 x HTTP_TIMEOUT of wall clock per document. --retry-max-time caps the whole
    # window instead. Setting it to one attempt's budget is deliberate: a fast failure
    # (429, 5xx) still retries inside the window, while a timeout does not — a timed-out
    # request was already generated and billed server-side, so retrying it pays twice.
    # --http1.1 for the same reason as anthropic.sh: a long non-streaming request over
    # HTTP/2 dies with `curl: (16) Error in the HTTP2 framing layer`, and exit 16 is not
    # a transient code so --retry never fires. Gemini 3.7 Flash is also a thinking model,
    # so it has the same silent-connection profile even though it was not the provider
    # the failure was measured on.
    code="$(curl -sS --config "$cfg" --http1.1 \
        --max-time "$HTTP_TIMEOUT" --retry 2 --retry-delay 5 --retry-max-time "$HTTP_TIMEOUT" \
        --data-binary "@$payload" -o "$resp" -w '%{http_code}')"
    rc=$?
    if [ "$rc" -ne 0 ]; then
        warn "gemini: the request to $url failed (curl exit $rc)"
        return 1
    fi

    if [ "$code" != "200" ]; then
        warn "gemini: HTTP $code from $url"
        jq -r '.error.message? // empty' "$resp" 2>/dev/null | sed 's/^/  /' >&2
        return 1
    fi

    blocked="$(jq -r '.promptFeedback.blockReason? // ""' "$resp")"
    if [ -n "$blocked" ]; then
        warn "gemini: the prompt was blocked (blockReason: $blocked)"
        return 1
    fi

    finish="$(jq -r '.candidates[0].finishReason? // ""' "$resp")"
    case "$finish" in
        ""|STOP) ;;
        MAX_TOKENS)
            warn "gemini: hit maxOutputTokens ($MAX_TOKENS) — a truncated article is not usable evidence"
            warn "  raise GEMINI_MAX_TOKENS and regenerate this document"
            return 1 ;;
        *)
            warn "gemini: the candidate stopped early (finishReason: $finish)"
            return 1 ;;
    esac

    # Gemini 3 returns reasoning as parts flagged thought:true. Those are not article text.
    text="$(jq -r '[.candidates[0].content.parts[]? | select(.thought != true) | .text? // empty] | join("")' "$resp")"
    if [ -z "$text" ]; then
        warn "gemini: the response carried no text part (finishReason: ${finish:-none})"
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
        warn "usage: gemini.sh {model|preflight|generate <prompt-file>}"
        exit 2 ;;
esac
