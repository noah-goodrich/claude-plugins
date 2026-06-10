#!/usr/bin/env bash
# deep-research-verify.sh — Fail-closed ground gate for deep-research deliverables.
#
# WHAT THIS IS
#   A NO-MODEL, deterministic verifier. Zero model calls. It reads on-disk facts an
#   LLM self-check cannot launder into a pass, and exits NON-ZERO on any failure.
#   It converts the honor-system Phase 3.5 verification manifest into a machine
#   assertion. Directive 01 — Fail-Closed Ground Gate (research-tools).
#
# WHAT IT IS NOT
#   It is CONTEXT-BLIND, not MODEL-BLIND. It proves a distinct verifier agent ID was
#   recorded and that a quote heading + access enum exist on the page. It CANNOT prove
#   the verifier's mind was uninfluenced (out-of-band hint-feeding survives). The honest
#   badge says exactly that and no more. See HONEST_BADGE below.
#
# THE SIX FALSIFIABLE ASSERTIONS (fail non-zero on ANY):
#   A1  verification-report.md exists at docs/research/[dir]/verification-report.md.
#   A2  §6 of the deliverable carries three numbers: sample N (of M, with %),
#       failure count, and a failure-rate band string.
#   A3  the band string is canonical — exactly one of  <=5%  /  >5%-10%  /  >10% .
#   A4  the report records a verifier agent/session ID that is PRESENT and != the
#       synthesis agent ID.
#   A5  every source card has the literal `Access status:` enum line AND a
#       `## Verified Quote(s)` heading.
#   A6  a card corrected during verification counts as a FAILURE — the per-card
#       outcome table must not record "corrected then verified" as `verified`.
#
# GROUND-LEDGER-SHAPED INPUT CONTRACT (forward-compat; load-bearing, not a nicety)
#   The verifier models its input as a GROUND LEDGER: a set of per-card grounding
#   records, each shaped like one line of a future `ground.jsonl`:
#
#       { card_id, claim_quote_hash, access_status, verifier_id, outcome, timestamp }
#
#   Today those fields are SOURCED from the existing verification-report.md + the
#   source cards on disk, but the gate reasons about them ONLY through this record
#   shape. This is what lets Directive 04 swap the on-disk report/cards for a real
#   emitted ground.jsonl WITHOUT a rewrite of the assertion logic — the assertions
#   read records, not files. The ledger here is materialized in-memory; the field
#   names above are the contract.
#
# BOUNDARIES (violating any is a bug)
#   - NEVER reject on cosmetic enum-format nits. Spacing/casing variants that are still
#     semantically the literal enum PASS. Rejection is hard-capped to the six integrity
#     facts. When in doubt, PASS.
#   - The badge is the only sanctioned "pass" string. It must NEVER claim "blind",
#     "true", or "cannot lie".
#
# USAGE
#   deep-research-verify.sh [RESEARCH_DIR]
#     RESEARCH_DIR  optional. A docs/research/<deliverable> directory. If omitted, the
#                   most recent docs/research/ deliverable under $PWD is discovered.
#
# EXIT CODES
#   0   all six assertions pass (gate PASS)
#   1   one or more assertions failed (gate FAIL)
#   2   usage / could-not-locate-a-deliverable error
#
# STATUS LINES (machine-readable; the Stop hook parses these)
#   GATE: <assertion-id> <PASS|FAIL> <human reason>
#   Gate result: PASS        (emitted ONLY on full pass, with the honest badge)
#   Gate result: FAIL: <first failing reason>

set -euo pipefail

# ---------------------------------------------------------------------------
# The honest badge. This exact string is the ONLY sanctioned pass certification.
# It is deliberately modest: context-blind, not model-blind.
# ---------------------------------------------------------------------------
HONEST_BADGE="a distinct verifier agent ran and the files prove it"

# ---------------------------------------------------------------------------
# Locate the deliverable directory.
# ---------------------------------------------------------------------------
RESEARCH_DIR="${1:-}"

discover_latest_deliverable() {
    # A deliverable dir is any directory under docs/research/ that contains either a
    # sources/ subdir or a markdown analysis file. Pick the most recently modified.
    local base="${PWD}/docs/research"
    [[ -d "$base" ]] || return 1
    local newest=""
    local newest_mtime=0
    local d
    while IFS= read -r d; do
        [[ -d "$d/sources" ]] || ls "$d"/*.md >/dev/null 2>&1 || continue
        local m
        m=$(stat -f %m "$d" 2>/dev/null || stat -c %Y "$d" 2>/dev/null || echo 0)
        if [[ "$m" -gt "$newest_mtime" ]]; then
            newest_mtime="$m"
            newest="$d"
        fi
    done < <(find "$base" -mindepth 1 -maxdepth 1 -type d)
    [[ -n "$newest" ]] && printf '%s\n' "$newest" && return 0
    # Fallback: docs/research itself holds the cards/analysis directly.
    if [[ -d "$base/sources" ]] || ls "$base"/*.md >/dev/null 2>&1; then
        printf '%s\n' "$base"
        return 0
    fi
    return 1
}

if [[ -z "$RESEARCH_DIR" ]]; then
    if ! RESEARCH_DIR=$(discover_latest_deliverable); then
        printf 'GATE: locate FAIL no docs/research deliverable found under %s\n' "$PWD" >&2
        exit 2
    fi
fi

if [[ ! -d "$RESEARCH_DIR" ]]; then
    printf 'GATE: locate FAIL not a directory: %s\n' "$RESEARCH_DIR" >&2
    exit 2
fi

printf 'GATE: target %s\n' "$RESEARCH_DIR"

# ---------------------------------------------------------------------------
# Resolve the deliverable's component files.
#   - verification-report.md  (the report)
#   - the analysis/deliverable .md that carries §6 Methodology
#   - sources/  card directory (may be the deliverable dir, or a sibling
#     docs/research/sources/ when the deliverable is a flat file)
# ---------------------------------------------------------------------------
REPORT="$RESEARCH_DIR/verification-report.md"

SOURCES_DIR=""
if [[ -d "$RESEARCH_DIR/sources" ]]; then
    SOURCES_DIR="$RESEARCH_DIR/sources"
elif [[ -d "$RESEARCH_DIR/../sources" ]]; then
    SOURCES_DIR="$RESEARCH_DIR/../sources"
fi

# The deliverable doc holding §6: largest .md that is not the report itself.
DELIVERABLE_DOC=""
_largest=0
for f in "$RESEARCH_DIR"/*.md; do
    [[ -e "$f" ]] || continue
    [[ "$f" == "$REPORT" ]] && continue
    sz=$(stat -f %z "$f" 2>/dev/null || stat -c %s "$f" 2>/dev/null || echo 0)
    if [[ "$sz" -gt "$_largest" ]]; then
        _largest="$sz"
        DELIVERABLE_DOC="$f"
    fi
done
# Flat-file deliverable: the dir itself is docs/research and the deliverable is a
# top-level *.md (e.g. troth/docs/research/household-finance-research.md).
if [[ -z "$DELIVERABLE_DOC" ]]; then
    for f in "$RESEARCH_DIR"/../*.md; do
        [[ -e "$f" ]] || continue
        sz=$(stat -f %z "$f" 2>/dev/null || stat -c %s "$f" 2>/dev/null || echo 0)
        if [[ "$sz" -gt "$_largest" ]]; then
            _largest="$sz"
            DELIVERABLE_DOC="$f"
        fi
    done
fi

# ---------------------------------------------------------------------------
# Failure accumulator.
# ---------------------------------------------------------------------------
FAILS=0
FIRST_REASON=""

fail() {
    # fail <assertion-id> <reason>
    local id="$1"; shift
    local reason="$*"
    printf 'GATE: %s FAIL %s\n' "$id" "$reason"
    FAILS=$((FAILS + 1))
    [[ -z "$FIRST_REASON" ]] && FIRST_REASON="$reason"
}

pass() {
    # pass <assertion-id> <note>
    local id="$1"; shift
    printf 'GATE: %s PASS %s\n' "$id" "$*"
}

# ===========================================================================
# ASSERTION 1 — verification-report.md exists.
# Ground-ledger framing: the ledger file must exist before any record can be read.
# ===========================================================================
if [[ -f "$REPORT" ]]; then
    pass A1 "verification-report.md present at $REPORT"
else
    fail A1 "verification-report.md absent at $REPORT"
fi

# ===========================================================================
# ASSERTION 5 — every source card carries the literal `Access status:` enum line
# AND a `## Verified Quote(s)` heading.
# Ground-ledger framing: each card record must expose access_status and a verified
# quote anchor. A freeform "Last Fetched / Assessment Confidence" line does NOT
# satisfy the enum. Cosmetic spacing/casing of the enum is tolerated.
# ===========================================================================
if [[ -z "$SOURCES_DIR" || ! -d "$SOURCES_DIR" ]]; then
    fail A5 "no sources/ card directory found for $RESEARCH_DIR"
else
    card_count=0
    bad_cards=""
    for card in "$SOURCES_DIR"/*.md; do
        [[ -e "$card" ]] || continue
        card_count=$((card_count + 1))
        cname=$(basename "$card")
        # Access status enum line: literal `Access status:` label, case-insensitive,
        # tolerant of leading markdown emphasis/spacing. Cosmetic only — the LABEL
        # must be present; we do not nit the value's exact spacing/casing.
        has_access=0
        if grep -Eiq '^[[:space:]]*\**[[:space:]]*access[[:space:]]+status[[:space:]]*:' "$card"; then
            has_access=1
        fi
        # Verified Quote(s) heading: `## Verified Quote(s)`. The literal plural-with-
        # parens form is required by the template (singular `## Verified Quote` does
        # NOT satisfy it — that is the reveal-s11 defect, not a cosmetic nit).
        has_quote=0
        if grep -Eiq '^#{1,6}[[:space:]]+verified[[:space:]]+quote\(s\)[[:space:]]*$' "$card"; then
            has_quote=1
        fi
        if [[ "$has_access" -eq 0 || "$has_quote" -eq 0 ]]; then
            missing=""
            [[ "$has_access" -eq 0 ]] && missing="Access status: enum"
            if [[ "$has_quote" -eq 0 ]]; then
                [[ -n "$missing" ]] && missing="$missing + "
                missing="${missing}## Verified Quote(s) heading"
            fi
            bad_cards="${bad_cards}${cname} (missing ${missing}); "
        fi
    done
    if [[ "$card_count" -eq 0 ]]; then
        fail A5 "sources/ contains no card files"
    elif [[ -n "$bad_cards" ]]; then
        fail A5 "card(s) non-compliant: ${bad_cards%; }"
    else
        pass A5 "$card_count card(s): every card has Access status: enum + ## Verified Quote(s)"
    fi
fi

# ===========================================================================
# Report-derived assertions (A2, A3, A4, A6). All read from the report ledger.
# If the report is absent, these cannot be evaluated from records — A1 already
# failed; we record dependent failures so the operator sees the full picture.
# ===========================================================================
if [[ ! -f "$REPORT" ]]; then
    fail A2 "cannot read §6 numbers: verification-report.md absent"
    fail A3 "cannot read band: verification-report.md absent"
    fail A4 "cannot read verifier ID: verification-report.md absent"
    fail A6 "cannot read per-card outcomes: verification-report.md absent"
else
    # -------------------------------------------------------------------
    # The text we scan for §6 numbers: prefer the deliverable doc's §6, but the
    # report restates the same three numbers, so union both bodies. This keeps the
    # gate robust to whether the numbers live in §6 or only in the report.
    # -------------------------------------------------------------------
    SCAN_FILES="$REPORT"
    [[ -n "$DELIVERABLE_DOC" && -f "$DELIVERABLE_DOC" ]] && SCAN_FILES="$SCAN_FILES $DELIVERABLE_DOC"

    # ===================================================================
    # ASSERTION 2 — three numbers present: sample N (of M, with %), failure count,
    # and a band string.
    # Ground-ledger framing: the ledger header must declare sample cardinality,
    # the failure tally, and the resulting band.
    # ===================================================================
    has_sample=0
    has_failcount=0
    has_band=0

    # Sample N of M with a %: e.g. "19 cards sampled from 62 total (30%)",
    # "4 cards sampled from 8 total (50% ...)", "N sampled out of M total cards, P%".
    if grep -Eiq '[0-9]+[^0-9]{0,40}(of|out of|from)[^0-9]{0,12}[0-9]+' $SCAN_FILES \
       && grep -Eq '[0-9]+(\.[0-9]+)?[[:space:]]*%' $SCAN_FILES; then
        has_sample=1
    fi

    # Failure count: a "Failed" tally line/row, e.g. "| Failed | 0 |" or "Failed: 0"
    # or "Failure count: 1". Zero is a valid count.
    if grep -Eiq 'fail(ed|ure)?[[:space:]]*(count)?[[:space:]]*[:|][[:space:]]*\**[[:space:]]*[0-9]+' $SCAN_FILES; then
        has_failcount=1
    fi

    # Band string present at all (canonicality is A3): any of the three legal bands,
    # tolerant of <= vs ≤ and -/–/— in the middle band.
    if grep -Eq '(≤|<=)[[:space:]]*5[[:space:]]*%' $SCAN_FILES \
       || grep -Eq '>[[:space:]]*5[[:space:]]*%[[:space:]]*[-–—][[:space:]]*10[[:space:]]*%' $SCAN_FILES \
       || grep -Eq '>[[:space:]]*10[[:space:]]*%' $SCAN_FILES \
       || grep -Eiq 'band[[:space:]]*[:|]' $SCAN_FILES; then
        has_band=1
    fi

    miss2=""
    [[ "$has_sample" -eq 0 ]] && miss2="sample N(of M, %)"
    if [[ "$has_failcount" -eq 0 ]]; then
        [[ -n "$miss2" ]] && miss2="$miss2, "
        miss2="${miss2}failure count"
    fi
    if [[ "$has_band" -eq 0 ]]; then
        [[ -n "$miss2" ]] && miss2="$miss2, "
        miss2="${miss2}band string"
    fi
    if [[ -n "$miss2" ]]; then
        fail A2 "§6/report omits: $miss2"
    else
        pass A2 "§6/report carries sample N(of M, %) + failure count + band string"
    fi

    # ===================================================================
    # ASSERTION 3 — the band string is CANONICAL: exactly one of  <=5% / >5%-10% / >10%.
    # A non-canonical band (e.g. "≤20% partial-or-failed at sample size 5") fails.
    # Cosmetic tolerance: <= vs ≤, and -/–/— for the middle dash, and a trailing
    # ✓ or surrounding ** are NOT nits. A different NUMBER (20, 15...) is a real fail.
    # ===================================================================
    canonical_band=0
    # Legal band 1: <=5% (or ≤5%)
    if grep -Eq '(≤|<=)[[:space:]]*5[[:space:]]*%' $SCAN_FILES; then
        canonical_band=1
    fi
    # Legal band 2: >5%-10% (any dash glyph)
    if grep -Eq '>[[:space:]]*5[[:space:]]*%[[:space:]]*[-–—][[:space:]]*10[[:space:]]*%' $SCAN_FILES; then
        canonical_band=1
    fi
    # Legal band 3: >10%
    if grep -Eq '>[[:space:]]*10[[:space:]]*%' $SCAN_FILES; then
        canonical_band=1
    fi
    # Detect an explicitly NON-canonical band: a "band: <num>%" where num is not 5/10,
    # or a "≤<num>%" with num != 5. This catches personalization's "≤20%".
    noncanonical=""
    while IFS= read -r badline; do
        noncanonical="$badline"
        break
    done < <(grep -Eio '(≤|<=)[[:space:]]*[0-9]+[[:space:]]*%' $SCAN_FILES \
             | grep -Eiv '(≤|<=)[[:space:]]*5[[:space:]]*%' || true)
    if [[ "$canonical_band" -eq 1 && -z "$noncanonical" ]]; then
        pass A3 "band string is canonical"
    elif [[ -n "$noncanonical" ]]; then
        fail A3 "non-canonical band present: '$(printf '%s' "$noncanonical" | tr -s '[:space:]' ' ')'"
    else
        fail A3 "no canonical band (<=5% / >5%-10% / >10%) found"
    fi

    # ===================================================================
    # ASSERTION 4 — recorded verifier agent/session ID is PRESENT and != synthesis ID.
    # Ground-ledger framing: every record's verifier_id field must be populated AND
    # distinct from the synthesis agent that authored the cards.
    #
    # We read TWO declared IDs from the report header:
    #   Verifier agent ID / Verifier session ID  -> verifier_id
    #   Synthesis agent ID / Synthesis session ID -> synthesis_id
    # Absent verifier ID => FAIL (the reveal/agent-teams/personalization defect).
    # verifier_id == synthesis_id => FAIL (self-verification).
    # ===================================================================
    # Extract an ID value declared as `[**]<who> agent|session ID:[**] <value>`. The
    # value may be wrapped in markdown emphasis (`**`) or backticks; strip those plus
    # any leading colon/whitespace, then take the first bare token. This tolerates
    # `**Verifier agent ID:** verify-z9y8x7`, `Verifier session ID: \`abc\``, etc.
    extract_id() {
        # extract_id <who-regex>
        grep -Eio "$1"'[[:space:]]*(agent|session)[[:space:]]*id[[:space:]]*:[^[:alnum:]]*[[:alnum:]_.-]+' "$REPORT" \
            | head -n1 \
            | sed -E 's/.*id[[:space:]]*://I' \
            | tr -d '*`' \
            | sed -E 's/^[[:space:]]+//' \
            | awk '{print $1}' \
            || true
    }
    verifier_id=$(extract_id 'verifier')
    synthesis_id=$(extract_id 'synthesis')
    if [[ -z "$verifier_id" ]]; then
        fail A4 "no recorded verifier agent/session ID in report header"
    elif [[ -n "$synthesis_id" && "$verifier_id" == "$synthesis_id" ]]; then
        fail A4 "verifier ID equals synthesis ID ($verifier_id) — not blind"
    else
        pass A4 "distinct verifier ID recorded: $verifier_id"
    fi

    # ===================================================================
    # ASSERTION 6 — a card corrected during verification counts as a FAILURE.
    # correction-then-recount is forbidden: the per-card outcome table must not record
    # "corrected then verified" (or "fixed and verified", "repaired ... verified",
    # "corrected before ... verified") as `verified`.
    # Ground-ledger framing: a record whose outcome is `verified` but whose note shows
    # an in-flight correction is a laundered FAILURE.
    # ===================================================================
    # Find any line that both mentions a correction verb AND records verified.
    corrected_recount=$(grep -Ein \
        '(correct(ed)?|fixed|repaired|re-?paraphrased|synthesi[sz]ed paraphrase|extra word|rewrit(e|ten))' "$REPORT" \
        | grep -Ei 'verif' || true)
    if [[ -n "$corrected_recount" ]]; then
        firstline=$(printf '%s' "$corrected_recount" | head -n1 | cut -c1-120)
        fail A6 "corrected-then-recounted card scored verified: $firstline"
    else
        pass A6 "no corrected-then-verified card in outcome table"
    fi
fi

# ===========================================================================
# Verdict.
# ===========================================================================
if [[ "$FAILS" -eq 0 ]]; then
    # The badge is printed ONLY here, on a full pass. It is context-blind, not
    # model-blind — see header. Never "blind", never "true", never "cannot lie".
    printf 'Badge: %s\n' "$HONEST_BADGE"
    printf 'Gate result: PASS\n'
    exit 0
else
    printf 'Gate result: FAIL: %s\n' "$FIRST_REASON"
    exit 1
fi
