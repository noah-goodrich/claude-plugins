#!/usr/bin/env bash
# scholarly-adapter.sh — Optional, first-party scholarly-source adapter for deep-research.
#
# WHAT THIS IS
#   A THIN, FIRST-PARTY HTTP client (curl + jq only) that calls a KEYLESS scholarly API
#   and emits standard deep-research source cards plus a fetch-time abstract SNAPSHOT.
#   It is the Directive 06 — Scholarly-Source Adapter — answer to the audit's
#   no-web-scale-corpus gap (audit.md:201-206, recommendation #10 audit.md:453-456):
#   add a free academic backend whose results flow into the SAME inspectable card
#   pipeline, NOT an attempt to out-index Elicit.
#
# WHY FIRST-PARTY (no third-party MCP)
#   deep-research is a trust-first methodology. A third-party MCP would inject unaudited
#   code into the pipeline. This adapter is ~one screen of bash/curl/jq you can read in
#   full — zero supply-chain surface. Per the council, prefer a first-party HTTP adapter.
#
# BACKENDS (keyless; OpenAlex is the DEFAULT, Semantic Scholar the documented FALLBACK)
#   openalex  (default) — 250M+ works, CC0, keyless, no global throttle. The proof-point
#                         that open+transparent beats paid+black-box (it materially
#                         defeated paid Scopus — Sorbonne deregistration, Dec 2023).
#   semanticscholar     — 200M+ papers, keyless BUT globally throttled, so it CANNOT be
#                         the default. Use for AI/ML/CS queries where its corpus is
#                         strongest and you accept the rate limit. Pass `--backend
#                         semanticscholar`.
#
# OPTIONAL — NOT A HARD DEPENDENCY
#   The deep-research pipeline runs UNCHANGED with no scholarly backend configured. This
#   script is invoked only when an academic/clinical (OpenAlex) or AI/ML/CS (Semantic
#   Scholar) Phase 2 query is routed to it. No secret is required to run the base
#   pipeline; no secret is required to run this adapter either (both backends are
#   keyless). The only soft requirements are curl and jq, which deep-research already
#   needs for the gate.
#
# BACKEND-AGNOSTIC CARD SCHEMA (load-bearing — no new lock-in)
#   Pulled results flow into the STANDARD source-card template
#   (skills/research/references/source-card-template.md). There are NO
#   backend-specific fields on the card: the card carries Full citation, URL, Date
#   accessed, Evidence level, Key Findings, a `## Verified Quote(s)` heading with one
#   verbatim abstract quote + Access status, and an Inclusion Decision with a Perspective
#   category. A reader cannot tell OpenAlex from Semantic Scholar from the card — that is
#   deliberate: the open-corpus advantage must never become a new lock-in, so the corpus
#   stays swappable.
#
# THE SNAPSHOT (consistent with the Directive 01 ground-ledger contract)
#   For every carded work the adapter writes the abstract text AS PULLED to
#   `<out>/snapshots/<card-id>.txt`. That snapshot is the ground truth the Directive 01
#   verifier (or its Phase 3.5 verifier subagent) checks the card's `## Verified Quote(s)`
#   blockquote against — the quote on the card MUST appear character-for-character in the
#   snapshot. This mirrors the ground-ledger record `{ card_id, claim_quote_hash,
#   access_status, ... }`: the snapshot is the materialized claim_quote source for an
#   adapter-pulled card, so a fabricated or drifted quote fails the same way a bad web
#   card does. `--verify` re-runs that check locally without any model call.
#
# USAGE
#   scholarly-adapter.sh search   "<query>" [--backend openalex|semanticscholar]
#                                 [--limit N] [--topic <area>] [--out <dir>]
#                                 [--perspective <enum>] [--mailto <email>]
#   scholarly-adapter.sh verify   <out-dir>        # local, no-model quote-vs-snapshot check
#   scholarly-adapter.sh selftest                  # offline jq-only abstract round-trip
#
#   search  — query the backend, write one card per result to <out>/sources/ and one
#             abstract snapshot per result to <out>/snapshots/. Default <out> is
#             docs/research/sources' parent, i.e. ./docs/research . Default backend
#             openalex, default limit 5, min results to be useful is 3.
#   verify  — for each adapter-emitted card under <out>/sources/, confirm its Verified
#             Quote blockquote appears verbatim in the matching <out>/snapshots/ file.
#   selftest — offline check that the abstract_inverted_index reconstruction is correct.
#
# EXIT CODES
#   0  success (search wrote >=1 card; verify found all quotes; selftest passed)
#   1  a snapshot-vs-card quote mismatch (verify), or selftest failure
#   2  usage error, missing curl/jq, network failure, or zero results
#
# BOUNDARIES (violating any is a bug)
#   - No secret, no API key, no auth header. Both backends are keyless by design.
#   - Read-only HTTP GET only. The adapter never writes to any remote.
#   - No backend-specific fields on the card. Schema stays swappable.
#   - Atomic writes only (tmp + mv). No partial cards on failure.

set -euo pipefail

UA_MAILTO="${SCHOLARLY_MAILTO:-research-tools@example.com}"

die() { printf 'scholarly-adapter: %s\n' "$*" >&2; exit 2; }

need() { command -v "$1" >/dev/null 2>&1 || die "missing required tool: $1"; }

# ---------------------------------------------------------------------------
# slugify <text> — lowercase, alnum+dash, trimmed, capped — for card filenames.
# ---------------------------------------------------------------------------
slugify() {
    printf '%s' "$1" \
        | tr 'A-Z' 'a-z' \
        | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' \
        | cut -c1-48
}

# ---------------------------------------------------------------------------
# atomic_write <dest> — read stdin, write to a tmp sibling, mv into place.
# ---------------------------------------------------------------------------
atomic_write() {
    local dest="$1"
    local dir
    dir="$(dirname "$dest")"
    mkdir -p "$dir"
    local tmp
    tmp="$(mktemp "$dir/.scholarly.XXXXXX")"
    cat >"$tmp"
    mv -f "$tmp" "$dest"
}

# ===========================================================================
# OpenAlex backend (DEFAULT). Keyless. Abstracts arrive as an inverted index
# (token -> [positions]); we reconstruct linear text with jq. Returns a JSONL
# stream of normalized records on stdout: one compact JSON object per work with
# the backend-agnostic fields the card needs.
# ===========================================================================
backend_openalex() {
    local query="$1" limit="$2"
    local enc
    enc="$(printf '%s' "$query" | jq -sRr @uri)"
    local url="https://api.openalex.org/works?search=${enc}&per-page=${limit}&mailto=${UA_MAILTO}"
    local raw
    raw="$(curl -sS --fail --max-time 30 "$url" 2>/dev/null)" || return 1
    printf '%s' "$raw" | jq -c '
        .results[]
        | {
            backend: "openalex",
            ext_id: .id,
            title: (.title // "Untitled"),
            doi: (.doi // null),
            oa_pdf: (.open_access.oa_url // null),
            year: (.publication_year // null),
            venue: (.primary_location.source.display_name // null),
            authors: ([.authorships[]?.author.display_name] | .[0:4] | join("; ")),
            abstract: (
                if .abstract_inverted_index == null then null
                else (
                    [ .abstract_inverted_index
                      | to_entries
                      | map(.key as $w | .value[] | {pos: ., word: $w})
                      | .[] ]
                    | sort_by(.pos)
                    | map(.word)
                    | join(" ")
                )
                end
            )
          }
    '
}

# ===========================================================================
# Semantic Scholar backend (FALLBACK — keyless but globally throttled, so NOT
# default). Same normalized JSONL record shape. A 429/empty response is the
# expected throttled outcome and surfaces as "zero results" to the caller.
# ===========================================================================
backend_semanticscholar() {
    local query="$1" limit="$2"
    local enc
    enc="$(printf '%s' "$query" | jq -sRr @uri)"
    local fields="title,abstract,externalIds,openAccessPdf,year,venue,authors"
    local url="https://api.semanticscholar.org/graph/v1/paper/search?query=${enc}&limit=${limit}&fields=${fields}"
    local raw
    raw="$(curl -sS --fail --max-time 30 "$url" 2>/dev/null)" || return 1
    printf '%s' "$raw" | jq -c '
        (.data // [])[]
        | {
            backend: "semanticscholar",
            ext_id: ("https://www.semanticscholar.org/paper/" + (.paperId // "")),
            title: (.title // "Untitled"),
            doi: (if .externalIds.DOI then ("https://doi.org/" + .externalIds.DOI) else null end),
            oa_pdf: (.openAccessPdf.url // null),
            year: (.year // null),
            venue: (.venue // null),
            authors: ([.authors[]?.name] | .[0:4] | join("; ")),
            abstract: (.abstract // null)
          }
    '
}

# ---------------------------------------------------------------------------
# card_url <record-json> — pick the card's `URL:` host source: prefer the DOI
# (stable, resolvable), else the OA PDF, else the backend landing page (ext_id).
# This is the host the Directive 01 A9 domain check pins the quote attribution to.
# ---------------------------------------------------------------------------
card_url() {
    printf '%s' "$1" | jq -r '.doi // .oa_pdf // .ext_id'
}

# ---------------------------------------------------------------------------
# first_sentence <abstract> — the verbatim quote for the card. We take the first
# sentence (up to the first period-space) so the quote is a real verbatim span the
# verifier can find in the snapshot character-for-character. If no sentence break,
# take the first 240 chars on a word boundary.
# ---------------------------------------------------------------------------
first_sentence() {
    local abs="$1"
    local s
    s="$(printf '%s' "$abs" | sed -E 's/([.!?]) .*/\1/' | head -c 400)"
    if [[ "$s" == "$abs" || ${#s} -gt 280 ]]; then
        s="$(printf '%s' "$abs" | cut -c1-240 | sed -E 's/ [^ ]*$//')"
    fi
    printf '%s' "$s"
}

# ===========================================================================
# emit_card — render one backend-agnostic source card + write its abstract
# snapshot. Args: <record-json> <out-dir> <topic> <perspective> <idx>
# ===========================================================================
emit_card() {
    local rec="$1" out="$2" topic="$3" persp="$4" idx="$5"
    local title doi oa year venue authors abstract url backend
    title="$(printf '%s' "$rec" | jq -r '.title')"
    doi="$(printf '%s' "$rec" | jq -r '.doi // ""')"
    oa="$(printf '%s' "$rec" | jq -r '.oa_pdf // ""')"
    year="$(printf '%s' "$rec" | jq -r '.year // ""')"
    venue="$(printf '%s' "$rec" | jq -r '.venue // ""')"
    authors="$(printf '%s' "$rec" | jq -r '.authors // ""')"
    abstract="$(printf '%s' "$rec" | jq -r '.abstract // ""')"
    backend="$(printf '%s' "$rec" | jq -r '.backend')"
    url="$(card_url "$rec")"

    [[ -n "$abstract" ]] || return 1

    local slug card_id
    slug="$(slugify "$title")"
    card_id="$(printf '%s%02d-%s' "${topic}-" "$idx" "$slug" | sed -E 's/^-+//; s/--+/-/g')"

    # Snapshot the abstract AS PULLED — the ground truth the verifier checks the
    # card's Verified Quote against. Written first so the card never points at a
    # missing snapshot.
    printf '%s\n' "$abstract" | atomic_write "$out/snapshots/${card_id}.txt"

    local quote
    quote="$(first_sentence "$abstract")"

    local cite
    cite="$authors"
    [[ -n "$cite" && -n "$year" ]] && cite="$cite ($year)."
    [[ -z "$cite" && -n "$year" ]] && cite="($year)."
    cite="$cite \"$title.\""
    [[ -n "$venue" ]] && cite="$cite $venue."
    [[ -n "$doi" ]] && cite="$cite $doi"

    local date_accessed
    date_accessed="$(date +%Y-%m-%d)"

    {
        printf '# Source: %s\n\n' "$title"
        printf '**Full citation:** %s\n' "$cite"
        printf '**URL:** %s\n' "$url"
        [[ -n "$oa" ]] && printf '**Open-access PDF:** %s\n' "$oa"
        printf '**Date accessed:** %s\n' "$date_accessed"
        printf '**Evidence level:** 4\n'
        printf '**Research topic area:** %s\n\n' "$topic"
        printf '## Key Findings\n\n'
        printf -- '- Peer-reviewed work pulled via the scholarly adapter; abstract snapshotted at fetch time.\n'
        printf -- '- Scored from the abstract only; promote the evidence level after reading the full text.\n\n'
        printf '## Verified Quote(s)\n\n'
        printf '**Location reference:** Abstract (snapshot: snapshots/%s.txt)\n\n' "$card_id"
        printf '> "%s"\n\n' "$quote"
        printf '**Access status:** cached/partial\n\n'
        printf '## Inclusion Decision\n\n'
        printf '**Decision:** Supporting\n'
        printf '**Rationale:** Abstract-level scholarly source pulled via the adapter; '
        printf 'confirm relevance and promote to Core after full-text review.\n\n'
        printf '**Redundancy check:** Compare against other pulled abstracts on the same topic before inclusion.\n\n'
        printf '**Perspective category:** %s\n' "$persp"
    } | atomic_write "$out/sources/${card_id}.md"

    printf '%s\n' "$card_id"
    return 0
}

# ===========================================================================
# cmd_search
# ===========================================================================
cmd_search() {
    local query="" backend="openalex" limit="5" topic="scholarly" out="" persp="Academic"
    [[ $# -gt 0 ]] || die "search requires a <query>"
    query="$1"; shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            # Each value-taking flag requires a following value. Without the arity guard a
            # trailing value-less flag dereferences an unset $2 under `set -u` and aborts
            # with a raw "$2: unbound variable" (exit 1), bypassing die()'s usage exit 2.
            --backend) [[ $# -ge 2 ]] || die "$1 requires a value"; backend="$2"; shift 2 ;;
            --limit) [[ $# -ge 2 ]] || die "$1 requires a value"; limit="$2"; shift 2 ;;
            --topic) [[ $# -ge 2 ]] || die "$1 requires a value"; topic="$2"; shift 2 ;;
            --out) [[ $# -ge 2 ]] || die "$1 requires a value"; out="$2"; shift 2 ;;
            --perspective) [[ $# -ge 2 ]] || die "$1 requires a value"; persp="$2"; shift 2 ;;
            --mailto) [[ $# -ge 2 ]] || die "$1 requires a value"; UA_MAILTO="$2"; shift 2 ;;
            *) die "unknown search flag: $1" ;;
        esac
    done
    [[ -n "$out" ]] || out="$PWD/docs/research"
    case "$backend" in
        openalex|semanticscholar) : ;;
        *) die "unknown backend '$backend' (use openalex or semanticscholar)" ;;
    esac

    need curl
    need jq

    local records
    if [[ "$backend" == "openalex" ]]; then
        records="$(backend_openalex "$query" "$limit")" || die "OpenAlex request failed (network?)"
    else
        records="$(backend_semanticscholar "$query" "$limit")" || die "Semantic Scholar request failed (throttled? it is keyless-but-rate-limited — that is why OpenAlex is the default)"
    fi

    [[ -n "$records" ]] || die "zero results from $backend for query: $query"

    local idx=0 written=0 card_id
    while IFS= read -r rec; do
        [[ -n "$rec" ]] || continue
        idx=$((idx + 1))
        if card_id="$(emit_card "$rec" "$out" "$topic" "$persp" "$idx")"; then
            written=$((written + 1))
            printf 'carded: sources/%s.md  (snapshot snapshots/%s.txt)\n' "$card_id" "$card_id"
        fi
    done <<<"$records"

    printf 'scholarly-adapter: backend=%s query=%q -> %d card(s) under %s\n' \
        "$backend" "$query" "$written" "$out"
    [[ "$written" -ge 1 ]] || exit 2
}

# ===========================================================================
# cmd_verify — local, no-model snapshot-vs-card quote check. For each card under
# <out>/sources/ that names a `snapshots/<id>.txt` location, confirm the Verified
# Quote blockquote appears verbatim in that snapshot. This is the adapter's own
# self-consistency check; the Directive 01 gate enforces the same contract on the
# carded deliverable as a whole.
# ===========================================================================
cmd_verify() {
    local out="${1:-$PWD/docs/research}"
    local sources="$out/sources"
    local snaps="$out/snapshots"
    [[ -d "$sources" ]] || die "no sources/ under $out"
    need jq
    local checked=0 ok=0 bad=0 card cname id snap quote
    for card in "$sources"/*.md; do
        [[ -e "$card" ]] || continue
        grep -q 'snapshots/' "$card" || continue
        cname="$(basename "$card" .md)"
        id="$cname"
        snap="$snaps/${id}.txt"
        [[ -f "$snap" ]] || { printf 'verify: %s -> MISSING snapshot %s\n' "$cname" "$snap" >&2; bad=$((bad + 1)); continue; }
        quote="$(grep -E '^> "' "$card" | head -n1 | sed -E 's/^> "//; s/"$//')"
        [[ -n "$quote" ]] || { printf 'verify: %s -> no Verified Quote blockquote\n' "$cname" >&2; bad=$((bad + 1)); continue; }
        checked=$((checked + 1))
        if grep -Fq "$quote" "$snap"; then
            ok=$((ok + 1))
            printf 'verify: %s -> quote present in snapshot\n' "$cname"
        else
            bad=$((bad + 1))
            printf 'verify: %s -> QUOTE NOT IN SNAPSHOT (drift/fabrication)\n' "$cname" >&2
        fi
    done
    printf 'scholarly-adapter verify: %d checked, %d ok, %d bad\n' "$checked" "$ok" "$bad"
    [[ "$bad" -eq 0 ]] || exit 1
}

# ===========================================================================
# cmd_selftest — offline jq-only abstract round-trip. Builds a known inverted
# index, reconstructs it, and asserts the linear text matches. No network.
# ===========================================================================
cmd_selftest() {
    need jq
    local fixture out
    fixture='{"abstract_inverted_index":{"The":[0],"quick":[1],"brown":[2],"fox":[3]}}'
    out="$(printf '%s' "$fixture" | jq -r '
        [ .abstract_inverted_index
          | to_entries
          | map(.key as $w | .value[] | {pos: ., word: $w})
          | .[] ]
        | sort_by(.pos) | map(.word) | join(" ")
    ')"
    if [[ "$out" == "The quick brown fox" ]]; then
        printf 'selftest: PASS (inverted-index reconstruction correct)\n'
        exit 0
    fi
    printf 'selftest: FAIL (got: %s)\n' "$out" >&2
    exit 1
}

# ===========================================================================
# Dispatch.
# ===========================================================================
[[ $# -gt 0 ]] || die "usage: scholarly-adapter.sh {search|verify|selftest} ..."
sub="$1"; shift
case "$sub" in
    search) cmd_search "$@" ;;
    verify) cmd_verify "$@" ;;
    selftest) cmd_selftest "$@" ;;
    -h|--help|help) sed -n '1,80p' "$0" ;;
    *) die "unknown subcommand '$sub' (search|verify|selftest)" ;;
esac
