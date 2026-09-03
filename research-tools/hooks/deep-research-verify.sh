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
# THE FALSIFIABLE ASSERTIONS (fail non-zero on ANY):
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
# DIRECTIVE 02 — CARD-INTEGRITY HARDENING + REAL CUTS (added below, A7-A12):
#   A7  the verification SAMPLE is >=30% of total cards (rounded up, min 3; all
#       cards if <10 total). Fails personalization's 9% sample.
#   A8  a card scored `inaccessible` in the report whose card file LACKS the
#       canonical `Access status:` enum is a laundered FAILURE — enum-missing means
#       `failed`, never `inaccessible`. AND the report carries no retroactive
#       reclassification note (a `cached/partial` flag set after synthesis to lower
#       the rate is forbidden). NO git/mtime provenance is read — the check is the
#       absence-of-retroactive-note plus the enum-missing-equals-failed rule.
#   A9  a card whose Verified Quote attribution names a domain OTHER than the card's
#       own URL host is automatic `failed`, regardless of access status. Inline-code
#       spans and <...> placeholders on the attribution line are NOT attributions and
#       are stripped before host extraction.
#   A10 inaccessible exclusions are capped at ~30% of the sample. Above the cap, the
#       deliverable must be stamped `low-confidence` (not `passed`).
#   A11 every source card's `Perspective category:` value, WHEN PRESENT, is exactly
#       one of  Academic / Institutional / Practitioner / Boots-on-the-ground /
#       Contrarian. A bespoke or hybrid value (e.g. "Academic/Institutional",
#       "Technical Documentation") fails. Absence is not nitted here (A5 already
#       governs card-shape minimums); a PRESENT non-enum value is the deviation.
#   A12 §6 / the report names >=1 EXCLUDED source OR explicitly names the
#       lowest-scoring source that CLEARED the bar — every run must make a real cut
#       or own the marginal keep.
#
# DIRECTIVE 03 — EVIDENCE-FLOOR + CONFIRMATION-SKEW (added below, W1-W2 + the §2
# evidence-floor classifier prose; NON-BLOCKING WARNINGS, never hard fails):
#   W1  NO-PRIMARY-EVIDENCE banner. When the §6 evidence-level distribution table
#       reports Level 1 (systematic review / meta-analysis) AND Level 2 (RCT) both at
#       0 — i.e. no primary experimental evidence was collected — the verifier asserts
#       the VERBATIM banner string
#           NO PRIMARY EVIDENCE — all findings are literature-derived predictions
#       as a non-blocking WARNING. If the deliverable already carries that exact string
#       in §2, the warning is satisfied (the banner is present); if it does not, the
#       warning flags that it MUST be added to §2. Either way this NEVER increments
#       FAILS and NEVER changes the exit code. Fails eating-out (0%) and agent-teams (0%).
#   W2  CONFIRMATION-SKEW gate. The §6 Bias-Guard Summary reports an "Agreed with
#       source" count and a "Disagreed with source" count. A skew of >3:1
#       (agree > 3 * disagree, including the all-agree/zero-disagree case) triggers a
#       non-blocking WARNING that the run MUST add (a) a falsification query to the
#       Phase 2 search plan and (b) a "steel-man the contrarian" subsection in Phase 4.
#       The verifier additionally checks whether those two remediations are already
#       present (a `falsif`-bearing line in the search log / §2 plan, and a literal
#       `steel-man` contrarian subsection) and footnotes whichever is missing. Reported
#       as a footnote/warning FIRST, not a hard block (audit.md:429-432). Fails
#       eating-out (27:3) and agent-teams (10:2).
#
# ANTI-GAMING NOTE (testability classifier honor-system escape hatch)
#   The Phase 2 evidence-floor classifier is itself an honor-system gate: a tired agent
#   can declare every question "untestable" to dodge the direct-observation preference.
#   Per the council's absorbed dissent, declaring a question UNTESTABLE requires a
#   one-line justification in §2 — the escape hatch leaves a paper trail. This is
#   enforced as METHODOLOGY PROSE in deep-research/SKILL.md Phase 2, not as a verifier
#   assertion (the verifier cannot read intent); W1's banner is the machine backstop.
#
# PROMOTION PATH (documented, NOT done here)
#   W1/W2 are WARNINGS, not blocks. They become blocking only AFTER (a) the Directive 01
#   gate has fired in production AND (b) the banner/skew warnings have run clean on >=2
#   real deliverables. Until then they are advisory: non-zero `WARN:` lines + a
#   `Warnings:` tally that DO NOT affect the exit code. Because each warning is written
#   to the ground-ledger-shaped record (the same per-deliverable record the A* assertions
#   read), promotion to blocking is a one-line change (move the warning's verdict into
#   FAILS) with NO rewrite of the detection logic.
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
#   0   all hard assertions pass (gate PASS) — Directive 03 WARNINGS DO NOT affect this
#   1   one or more hard assertions failed (gate FAIL)
#   2   usage / could-not-locate-a-deliverable error
#
#   Directive 03 warnings (W1/W2) are advisory only: they emit WARN: lines and a
#   Warnings: tally but NEVER change the exit code. A clean deliverable with warnings
#   still exits 0; a deliverable that fails a hard assertion still exits 1 regardless of
#   whether warnings fired.
#
# STATUS LINES (machine-readable; the Stop hook parses these)
#   GATE: <assertion-id> <PASS|FAIL> <human reason>
#   WARN: <warning-id> <human reason>     (Directive 03; advisory, non-blocking)
#   Warnings: <N>                          (count of advisory warnings raised)
#   Gate result: PASS        (emitted ONLY on full hard-pass, with the honest badge)
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
    # Flat-file layout FIRST: docs/research/ itself holds the report/deliverable directly,
    # with cards under docs/research/sources/. This MUST be checked before enumerating
    # subdirs — otherwise the sources/ card directory is itself picked as "the deliverable"
    # and verification-report.md is sought inside sources/, a spurious A1 failure.
    if [[ -f "$base/verification-report.md" ]] || ls "$base"/*.md >/dev/null 2>&1; then
        printf '%s\n' "$base"
        return 0
    fi
    # Otherwise: a per-run subdirectory under docs/research/. NEVER treat a bare `sources`
    # card directory as a deliverable root.
    local newest=""
    local newest_mtime=0
    local d
    while IFS= read -r d; do
        [[ "$(basename "$d")" == "sources" ]] && continue
        [[ -d "$d/sources" ]] || ls "$d"/*.md >/dev/null 2>&1 || continue
        local m
        m=$(stat -c %Y "$d" 2>/dev/null || stat -f %m "$d" 2>/dev/null || echo 0)
        if [[ "$m" -gt "$newest_mtime" ]]; then
            newest_mtime="$m"
            newest="$d"
        fi
    done < <(find "$base" -mindepth 1 -maxdepth 1 -type d)
    [[ -n "$newest" ]] && printf '%s\n' "$newest" && return 0
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
    sz=$(stat -c %s "$f" 2>/dev/null || stat -f %z "$f" 2>/dev/null || echo 0)
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
        sz=$(stat -c %s "$f" 2>/dev/null || stat -f %z "$f" 2>/dev/null || echo 0)
        if [[ "$sz" -gt "$_largest" ]]; then
            _largest="$sz"
            DELIVERABLE_DOC="$f"
        fi
    done
fi

# ---------------------------------------------------------------------------
# Failure accumulator (hard gate) + warning accumulator (Directive 03, advisory).
# WARNS is deliberately SEPARATE from FAILS: warnings never feed the verdict. The
# WARN_LEDGER strings are the ground-ledger-shaped warning records — keyed by warning
# id so a later directive can promote any one of them into FAILS without re-deriving it.
# ---------------------------------------------------------------------------
FAILS=0
FIRST_REASON=""
WARNS=0
WARN_LEDGER=""   # "<id>=<verdict>; " advisory records; load-bearing for promotion

fail() {
    # fail <assertion-id> <reason>
    local id="$1"; shift
    local reason="$*"
    printf 'GATE: %s FAIL %s\n' "$id" "$reason"
    FAILS=$((FAILS + 1))
    [[ -z "$FIRST_REASON" ]] && FIRST_REASON="$reason"
    # Always return 0: fail() is frequently the last statement in an if-branch, and
    # under `set -e` a non-zero return there (when FIRST_REASON is already set) would
    # abort the run before later assertions execute. The accumulator carries verdict.
    return 0
}

pass() {
    # pass <assertion-id> <note>
    local id="$1"; shift
    printf 'GATE: %s PASS %s\n' "$id" "$*"
}

warn() {
    # warn <warning-id> <reason>  — Directive 03 advisory. NEVER touches FAILS.
    # Writes one ground-ledger-shaped warning record (id=raised) so the warning can be
    # promoted to a hard fail later without re-deriving the condition.
    local id="$1"; shift
    printf 'WARN: %s %s\n' "$id" "$*"
    WARNS=$((WARNS + 1))
    WARN_LEDGER="${WARN_LEDGER}${id}=raised; "
    return 0
}

okwarn() {
    # okwarn <warning-id> <note>  — the advisory condition did NOT trigger. Records the
    # clear verdict in the ledger (id=clear) for the promotion-path "ran clean" tally.
    local id="$1"; shift
    printf 'WARN: %s clear — %s\n' "$id" "$*"
    WARN_LEDGER="${WARN_LEDGER}${id}=clear; "
    return 0
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
# The A5 loop is the single pass over every card. It is the materialization point of
# the in-memory ground ledger: as it walks each card it records the facts A8 (cards
# WITHOUT the canonical enum), A9 (quote-attribution domain != card URL host), and A11
# (present-but-non-enum perspective category) reason about. Those three assertions read
# the accumulators below — they do not re-walk the directory.
CARD_COUNT=0           # total card files on disk (= M, the ledger cardinality for A7)
NOENUM_CARDS=""        # space-joined basenames of cards lacking the Access status: enum
BADDOMAIN_CARDS=""     # "<card> (<quote-domain> != <url-host>); " accumulator for A9
BADPERSP_CARDS=""      # "<card> (<value>); " accumulator for A11
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

        # --- Ledger record fields for A8/A9/A11, captured in this same pass. ---
        CARD_COUNT=$((CARD_COUNT + 1))

        # A8 field: record the card if it lacks the canonical Access status: enum.
        # NEWLINE-joined (not space-joined): card basenames are matched as whole lines in
        # A8 via grep -Fxq, so a space-bearing basename never word-splits and a card id
        # that is a substring of another id never collides.
        [[ "$has_access" -eq 0 ]] && NOENUM_CARDS="${NOENUM_CARDS}${cname}"$'\n'

        # A9 field: card URL host vs quote-attribution domain. The card declares its
        # source URL on a `**URL:** <url>` line; the attribution is any host-shaped
        # token that appears on an attribution line near the quote (a line beginning
        # with an em/en/hyphen dash, or a `— Source:`-style credit). We compare bare
        # registrable hosts (strip scheme, www., path). A domain on the attribution
        # that is NOT a substring-or-superstring of the URL host is a mismatch.
        # Card URL host. The scheme is OPTIONAL: a `**URL:** example.org/x` shorthand (no
        # https://) must still yield a host — otherwise the cross-domain check is skipped
        # for that card and a spoofed attribution passes. Strip the label, markdown bold,
        # leading space, any trailing description, then scheme/www./path, leaving the host.
        url_line=$(grep -Ei '^[[:space:]]*\**[[:space:]]*url[[:space:]]*\**[[:space:]]*:' "$card" | head -n1 || true)
        url_host=$(printf '%s' "$url_line" \
            | sed -E 's#^[^:]*:[[:space:]]*##' \
            | tr -d '*' \
            | sed -E 's#^[[:space:]]+##' \
            | sed -E 's#[[:space:]].*$##' \
            | sed -E 's#^https?://##I' \
            | sed -E 's#^www\.##I' \
            | sed -E 's#[/?#].*$##' \
            | tr 'A-Z' 'a-z' \
            || true)
        if [[ -n "$url_host" ]]; then
            # Pull a candidate attribution host from a dash-led attribution/credit line
            # (NOT the blockquote, which starts with `>`). The host pattern is STRUCTURAL —
            # `label(.label)*.tld` with any 2+-char alpha TLD — NOT a closed TLD allowlist,
            # so a `.xyz` / `.de` / `.tv` misattribution cannot escape. reveal-s11 shape:
            #   — Lavivienpost.net / Stable Diffusion Art ecosystem documentation
            # Strip inline-code spans and <...> placeholders FIRST. An attribution is
            # prose; a backticked identifier or an angle-bracketed placeholder is not. A
            # dotted SQL placeholder such as `<db.schema.agent_name>` otherwise matches the
            # structural host pattern (`db.schema.agent`, TLD `agent`) and fails a card whose
            # quote is correctly attributed — which pushes the author toward editing a
            # verbatim quote to appease the linter, destroying the very property A9 protects.
            # Narrowing, not accretion: no new gate, strictly fewer false positives.
            # Accepted residual hole: a real misattribution hidden inside backticks or angle
            # brackets on a dash-led line now escapes A9. Judged strictly better than a gate
            # that cannot be satisfied without corrupting evidence.
            attr_domain=$(grep -E '^[[:space:]]*([-–—]|\*\*?(source|attribut|credit))' "$card" \
                | sed -E 's/`[^`]*`//g' \
                | sed -E 's/<[^>]*>//g' \
                | grep -Eio '[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*\.[a-z]{2,}' \
                | sed -E 's#^www\.##I' \
                | tr 'A-Z' 'a-z' \
                | head -n1 \
                || true)
            if [[ -n "$attr_domain" && "$attr_domain" != "$url_host" ]]; then
                # Same-origin iff equal OR a true subdomain relationship (dot-suffix). This
                # is a SUFFIX test, never a substring test: `notes.example.org.attacker.com`
                # is NOT same-origin as `example.org` — it does not end with `.example.org`.
                same_origin=0
                case "$attr_domain" in *."$url_host") same_origin=1 ;; esac
                case "$url_host" in *."$attr_domain") same_origin=1 ;; esac
                if [[ "$same_origin" -eq 0 ]]; then
                    BADDOMAIN_CARDS="${BADDOMAIN_CARDS}${cname} (${attr_domain} != ${url_host}); "
                fi
            fi
        fi

        # A11 field: perspective category value, when the field is PRESENT. Strip the
        # label, markdown emphasis, backticks, and any parenthetical secondary-note;
        # then test the leading value against the five-value enum. Absence => skip
        # (A5 governs card-shape minimums; a present non-enum value is the deviation).
        persp_raw=$(grep -Eio '^[[:space:]]*\**[[:space:]]*perspective[[:space:]]+category[[:space:]]*\**[[:space:]]*:[^(]*' "$card" \
            | head -n1 \
            | sed -E 's/.*:[[:space:]]*//' \
            | tr -d '*`' \
            | sed -E 's/^[[:space:]]+//' \
            | sed -E 's/[[:space:]]+$//' \
            || true)
        if [[ -n "$persp_raw" ]]; then
            persp_norm=$(printf '%s' "$persp_raw" | tr 'A-Z' 'a-z')
            case "$persp_norm" in
                academic|institutional|practitioner|boots-on-the-ground|contrarian) : ;;
                *) BADPERSP_CARDS="${BADPERSP_CARDS}${cname} ($(printf '%s' "$persp_raw" | tr -s '[:space:]' ' ')); " ;;
            esac
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
# ASSERTION 9 — a quote attributed to a domain OTHER than the card URL host is an
# automatic FAILURE, regardless of access status (resolves audit.md:227-234, the
# reveal-s11 Lavivienpost.net-vs-stable-diffusion-art.com defect).
# Ground-ledger framing: a record whose claim_quote is credited to a domain that is
# not the card's own source host cannot be `verified` — the quote did not come from
# the source the card claims. Evaluated from the A5-pass accumulator BADDOMAIN_CARDS.
# ===========================================================================
if [[ -n "$BADDOMAIN_CARDS" ]]; then
    fail A9 "quote attributed to a domain other than the card URL: ${BADDOMAIN_CARDS%; }"
else
    pass A9 "no card credits its quote to a domain other than its own URL host"
fi

# ===========================================================================
# ASSERTION 11 — the `Perspective category:` value, WHEN PRESENT, is exactly one of
# the five enum values (Academic / Institutional / Practitioner / Boots-on-the-ground
# / Contrarian). A bespoke or hybrid value fails (resolves the reveal portrait
# "Academic/Institutional" and "Technical Documentation / Commercial Product Analysis
# / Regulatory" defect, audit.md:169-172). Absence is NOT nitted (A5 governs card
# minimums); a present non-enum value is the deviation. Evaluated from BADPERSP_CARDS.
# ===========================================================================
if [[ -n "$BADPERSP_CARDS" ]]; then
    fail A11 "non-enum Perspective category value(s): ${BADPERSP_CARDS%; }"
else
    pass A11 "every present Perspective category value is one of the five enum values"
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
    fail A7 "cannot read sample size: verification-report.md absent"
    fail A8 "cannot read per-card outcomes: verification-report.md absent"
    fail A10 "cannot read inaccessible count: verification-report.md absent"
    fail A12 "cannot read inclusion/exclusion cut: verification-report.md absent"
else
    # -------------------------------------------------------------------
    # The text we scan for §6 numbers: prefer the deliverable doc's §6, but the
    # report restates the same three numbers, so union both bodies. This keeps the
    # gate robust to whether the numbers live in §6 or only in the report.
    # -------------------------------------------------------------------
    # A bash ARRAY, not a space-joined string: a deliverable/report path containing a
    # space (routine on macOS — ~/Library/Mobile Documents, "My Project/") must not
    # word-split into nonexistent filenames and zero out every report-derived assertion.
    SCAN_FILES=("$REPORT")
    [[ -n "$DELIVERABLE_DOC" && -f "$DELIVERABLE_DOC" ]] && SCAN_FILES+=("$DELIVERABLE_DOC")

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
    if grep -Eiq '[0-9]+[^0-9]{0,40}(of|out of|from)[^0-9]{0,12}[0-9]+' "${SCAN_FILES[@]}" \
       && grep -Eq '[0-9]+(\.[0-9]+)?[[:space:]]*%' "${SCAN_FILES[@]}"; then
        has_sample=1
    fi

    # Failure count: a "Failed" tally line/row, e.g. "| Failed | 0 |" or "Failed: 0"
    # or "Failure count: 1". Zero is a valid count.
    if grep -Eiq 'fail(ed|ure)?[[:space:]]*(count)?[[:space:]]*[:|][[:space:]]*\**[[:space:]]*[0-9]+' "${SCAN_FILES[@]}"; then
        has_failcount=1
    fi

    # Band string present at all (canonicality is A3): any of the three legal bands,
    # tolerant of <= vs ≤ and -/–/— in the middle band. The middle-band grep uses sed
    # to normalise en/em-dashes to ASCII hyphen before grep so it works in POSIX/C
    # locale (multi-byte chars inside [...] are unreliable without UTF-8 locale).
    if grep -Eq '(≤|<=)[[:space:]]*5[[:space:]]*%' "${SCAN_FILES[@]}" \
       || cat "${SCAN_FILES[@]}" | sed 's/–/-/g; s/—/-/g' | grep -Eq '>[[:space:]]*5[[:space:]]*%[[:space:]]*[-][[:space:]]*10[[:space:]]*%' \
       || grep -Eq '>[[:space:]]*10[[:space:]]*%' "${SCAN_FILES[@]}" \
       || grep -Eiq 'band[[:space:]]*[:|]' "${SCAN_FILES[@]}"; then
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
    # Read the band ONLY from the band-declaration line(s) — a `Failure-rate band:` /
    # `band:` line — NOT the whole-file union. An unanchored scan fails OPEN (a recited
    # rubric "the three bands: ≤5%, >5%-10%, >10%" makes any bogus band look canonical)
    # AND fails CLOSED (an unrelated "≤20% of respondents" in prose hard-fails a compliant
    # deliverable). Every band token on those lines is canonicalized and checked; a single
    # non-canonical token (≤20%, >8%, >12%, >10%-20%) fails — its canonical siblings on a
    # rubric line cannot rescue it.
    band_lines=$(grep -hEi 'failure[- ]?rate[- ]?band|(^|[^a-z])band[[:space:]]*\**[[:space:]]*[:|]' "${SCAN_FILES[@]}" || true)
    canonical_band=0
    noncanonical=""
    while IFS= read -r tok; do
        [[ -n "$tok" ]] || continue
        # Normalize: drop whitespace, ≤ -> <=, any dash glyph -> '-'.
        norm=$(printf '%s' "$tok" | tr -d '[:space:]' | sed -e 's/≤/<=/g' -e 's/–/-/g' -e 's/—/-/g')
        case "$norm" in
            '<=5%'|'>5%-10%'|'>10%') canonical_band=1 ;;
            *) [[ -z "$noncanonical" ]] && noncanonical="$tok" ;;
        esac
    done < <(printf '%s\n' "$band_lines" \
             | sed 's/–/-/g; s/—/-/g' \
             | grep -Eo '(≤|<=|>)[[:space:]]*[0-9]+[[:space:]]*%([[:space:]]*[-][[:space:]]*[0-9]+[[:space:]]*%)?' || true)
    if [[ -n "$noncanonical" ]]; then
        fail A3 "non-canonical band present: '$(printf '%s' "$noncanonical" | tr -s '[:space:]' ' ')'"
    elif [[ "$canonical_band" -eq 1 ]]; then
        pass A3 "band string is canonical"
    else
        fail A3 "no canonical band (<=5% / >5%-10% / >10%) found on a band-declaration line"
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
    # Find any line that both shows a correction VERB and records the `verified` outcome.
    # `correct(ed)?` matched the bare nouns "correct"/"correction", and stage 2's loose
    # `verif` matched "unverified"/"verification", so an honest note ("Quote verified; no
    # correction needed") or a protocol restatement ("a corrected card counts as failed,
    # never verified") hard-failed the gate. Stage 1 is now verb-only; stage 2 anchors on
    # the word `verified`; stage 3 drops negated/methodology phrasing.
    corrected_recount=$(grep -Ein \
        '(corrected|correcting|fixed|repaired|re-?paraphrased|synthesi[sz]ed paraphrase|extra word|rewrit(e|ten|ing))' "$REPORT" \
        | grep -Ei '(^|[^a-z])verified([^a-z]|$)' \
        | grep -Eiv '(^|[^a-z])(no|not|never|without)([^.]{0,40})(corrected|correction|verified)|counted as[[:space:]]+failed' \
        || true)
    if [[ -n "$corrected_recount" ]]; then
        firstline=$(printf '%s' "$corrected_recount" | head -n1 | cut -c1-120)
        fail A6 "corrected-then-recounted card scored verified: $firstline"
    else
        pass A6 "no corrected-then-verified card in outcome table"
    fi

    # ===================================================================
    # ASSERTION 7 — the verification SAMPLE is >=30% of total cards (rounded up,
    # min 3; all cards if <10 total). Fails personalization's 9% (5/53) sample.
    # Ground-ledger framing: the ledger must sample enough records to be defensible.
    #
    # M (total) is the GROUND-TRUTH card count on disk (CARD_COUNT, from the A5 pass) —
    # not a self-reported number that could embed a date or a typo. If no cards were
    # found on disk, fall back to the M declared on a `sampl`-bearing line.
    # N (sampled) is read from a `sampl`-bearing line as the FIRST integer that is a
    # plausible sample count (a "N ... (of|from|out of|/) ... M" or "N ... sampled"
    # shape), with the year-like 19xx/20xx tokens stripped so a report date cannot be
    # mistaken for a count. The required sample is:
    #   M < 10  -> all M     else -> ceil(0.30 * M), floored at 3
    # ===================================================================
    # The sample-declaration line: the first line that mentions sampling and carries a
    # "N ... <connector> ... M" or "N / M" pair. Strip 4-digit year tokens first.
    # Strip percent literals FIRST (so "95% ... from 12" cannot read 95 as the count), then
    # 4-digit year tokens. The year strip uses an explicit non-digit boundary, NOT \b:
    # GNU \b is a silent no-op on BSD/macOS sed, so the original date defense did nothing
    # on the maintainer's own machine and a report date could be read as the sample count.
    sample_line=$(grep -hEi 'sampl' "${SCAN_FILES[@]}" \
        | sed -E 's/[0-9]+(\.[0-9]+)?[[:space:]]*%//g' \
        | sed -E 's/(^|[^0-9])(19|20)[0-9]{2}([^0-9]|$)/\1\3/g' \
        | grep -Eio '[0-9]+[^0-9]{0,40}(of|out of|from|/)[^0-9]{0,12}[0-9]+' \
        | head -n1 || true)
    sample_n=$(printf '%s' "$sample_line" | grep -Eo '[0-9]+' | head -n1 || true)
    sample_m_reported=$(printf '%s' "$sample_line" | grep -Eo '[0-9]+' | sed -n '2p' || true)
    # M (total) is the GROUND-TRUTH card count on disk; the reported total is trusted only
    # when no cards are on disk. A report claiming a LARGER universe than exists on disk is
    # computing its fraction against a PHANTOM denominator (personalization's "5 of 53" with
    # 1 card on disk), and N can never exceed M — reject both rather than green-light a
    # degenerate N/M that passes the >=30% floor.
    if [[ "$CARD_COUNT" -gt 0 ]]; then
        sample_m="$CARD_COUNT"
    else
        sample_m="$sample_m_reported"
    fi
    if [[ -z "$sample_n" || -z "$sample_m" || "$sample_m" -le 0 ]]; then
        fail A7 "cannot read sample N (of M) from report/§6 (got N='${sample_n}', M='${sample_m}')"
    elif [[ "$CARD_COUNT" -gt 0 && -n "$sample_m_reported" && "$sample_m_reported" -gt "$CARD_COUNT" ]]; then
        fail A7 "reported total ($sample_m_reported) exceeds cards on disk ($CARD_COUNT) — sample fraction computed against a phantom denominator"
    elif [[ "$sample_n" -gt "$sample_m" ]]; then
        fail A7 "sample N ($sample_n) exceeds total M ($sample_m) — degenerate/impossible sample"
    else
        if [[ "$sample_m" -lt 10 ]]; then
            required="$sample_m"
        else
            required=$(( (sample_m * 30 + 99) / 100 ))
            [[ "$required" -lt 3 ]] && required=3
        fi
        if [[ "$sample_n" -lt "$required" ]]; then
            fail A7 "sample $sample_n/$sample_m below required ${required} (>=30%, ceil, min 3; all if <10)"
        else
            pass A7 "sample $sample_n/$sample_m meets required ${required} (>=30% / all-if-<10)"
        fi
    fi

    # ===================================================================
    # ASSERTION 8 — a card scored `inaccessible` whose card file LACKS the canonical
    # `Access status:` enum is a laundered FAILURE; AND no retroactive reclassification
    # note is present. This closes the reveal-s11 loophole: s11 carries no enum yet was
    # scored `inaccessible` on a `cached/partial` flag the card never had.
    # NO git/mtime provenance is read (out of scope per Directive 01). The check is:
    #   (a) any card named on an `inaccessible` outcome row that is in NOENUM_CARDS, AND
    #   (b) absence of a retroactive-change note ("reclassified", "retroactively",
    #       "changed ... to cached/partial", "set ... after synthesis", "now counts as
    #       inaccessible") used to lower the rate.
    # Ground-ledger framing: outcome=inaccessible REQUIRES access_status enum present on
    # the record; a missing enum collapses the outcome to `failed`.
    # ===================================================================
    a8_bad=""
    # (a) cards on an `inaccessible` row that have no enum on disk. Match the card NAMED in
    # the row (its `.md` token) against the enum-missing set as a WHOLE line via grep -Fxq —
    # never a substring (`c1-card.md` is a substring of `ic1-card.md`) and never a
    # `for nc in $NOENUM_CARDS` word-split that a spaced basename would break.
    if [[ -n "$NOENUM_CARDS" ]]; then
        while IFS= read -r inacc_line; do
            row_card=$(printf '%s' "$inacc_line" | grep -Eo '[A-Za-z0-9._-]+\.md' | head -n1 || true)
            [[ -n "$row_card" ]] || continue
            if printf '%s\n' "$NOENUM_CARDS" | grep -Fxq "$row_card"; then
                a8_bad="${a8_bad}${row_card} (scored inaccessible but card has no Access status: enum -> failed); "
            fi
        done < <(grep -Ei 'inaccessible' "$REPORT" || true)
    fi
    # (b) a retroactive reclassification note anywhere in the report. The trailing -v drops
    # NEGATED phrasing ("No card was reclassified after synthesis") so honestly DENYING the
    # gaming is not mis-read as committing it.
    retro_note=$(grep -Ein \
        '(retroactive|reclassif|re-classif|changed[^.]{0,40}(to[[:space:]]+)?(cached/partial|inaccessible)|set[^.]{0,40}(after|post)[[:space:]]+synthesis|now counts as[[:space:]]+inaccessible|down(graded|ranked)[^.]{0,30}after)' \
        "$REPORT" \
        | grep -Eiv '(^|[^a-z])(no|not|never|without|zero)([^.]{0,40})(retroactive|reclassif|change|set|down|count)' \
        || true)
    if [[ -n "$a8_bad" ]]; then
        fail A8 "enum-missing card laundered as inaccessible: ${a8_bad%; }"
    elif [[ -n "$retro_note" ]]; then
        firstretro=$(printf '%s' "$retro_note" | head -n1 | cut -c1-120)
        fail A8 "retroactive cached/partial reclassification detected (rate-gaming forbidden): $firstretro"
    else
        pass A8 "no enum-missing-as-inaccessible and no retroactive reclassification note"
    fi

    # ===================================================================
    # ASSERTION 10 — inaccessible exclusions capped at ~30% of the SAMPLE. Above the
    # cap, the deliverable must be stamped `low-confidence` (not passed)
    # (audit.md:152-154). Ground-ledger framing: too many records excluded from the
    # denominator is not a pass — it is an honestly low-confidence result.
    #
    # Read the aggregate Inaccessible count from the report; compare to sample N (A7).
    # cap = ceil(0.30 * N). At or below cap -> PASS. Above cap -> a `low-confidence`
    # stamp must be present in the report/§6, else FAIL.
    # ===================================================================
    # Read the AGGREGATE inaccessible count: a table row whose FIRST cell is `Inaccessible`
    # (optionally bold), or an `Inaccessible: N` line. NOT a per-card outcome row (where
    # `inaccessible` sits in the SECOND cell beside a note that may carry a digit) — the old
    # first-match-on-any-line scan latched a per-card note digit and under-counted, passing
    # an 83%-inaccessible run under the ~30% cap.
    inacc_count=$(grep -hEi \
        -e '^[[:space:]]*\|[[:space:]]*\**[[:space:]]*inaccessible[[:space:]]*\**[[:space:]]*\|[[:space:]]*\**[[:space:]]*[0-9]+' \
        -e '^[[:space:]]*\**[[:space:]]*inaccessible[[:space:]]*\**[[:space:]]*:[[:space:]]*\**[[:space:]]*[0-9]+' \
        "$REPORT" \
        | head -n1 \
        | grep -Eo '[0-9]+' | head -n1 \
        || true)
    [[ -n "$inacc_count" ]] || inacc_count=0
    if [[ -z "$sample_n" || "$sample_n" -le 0 ]]; then
        pass A10 "no readable sample N; inaccessible-cap check deferred to A7"
    else
        cap=$(( (sample_n * 30 + 99) / 100 ))
        if [[ "$inacc_count" -le "$cap" ]]; then
            pass A10 "inaccessible $inacc_count/$sample_n within ~30% cap ($cap)"
        elif grep -Eiq 'low[ -]confidence' "${SCAN_FILES[@]}"; then
            pass A10 "inaccessible $inacc_count/$sample_n above cap ($cap) but deliverable stamped low-confidence"
        else
            fail A10 "inaccessible $inacc_count/$sample_n exceeds ~30% cap ($cap) without a low-confidence stamp"
        fi
    fi

    # ===================================================================
    # ASSERTION 12 — every run must EXCLUDE >=1 source OR explicitly name the
    # lowest-scoring source that CLEARED the bar (audit.md:449-451). A rubric that
    # never rejects is decorative; this forces a real cut or an owned marginal keep.
    # Ground-ledger framing: the inclusion ledger must record at least one cut, or
    # the report must name its weakest survivor.
    #
    # PASS if EITHER:
    #   (a) an exclusion is recorded with a nonzero count ("Excluded | N", "Excluded: N",
    #       N>=1), OR a §6 source-category "Excluded" column carries a nonzero total; OR
    #   (b) a "lowest-scoring source that cleared the bar" / "weakest included" /
    #       "lowest source that cleared" phrasing names the marginal keep.
    # ===================================================================
    excluded_nonzero=0
    # The loop input is a BOUNDED match (grep -Eoi): the only digit run in each match is the
    # count immediately after the `|`/`:` delimiter, so head -n1 reads the count. The old
    # whole-line + tail-n1 read "Excluded: 0 of 12" as 12 and passed a zero-cut run.
    while IFS= read -r exmatch; do
        exnum=$(printf '%s' "$exmatch" | grep -Eo '[0-9]+' | head -n1 || true)
        if [[ -n "$exnum" && "$exnum" -ge 1 ]]; then
            excluded_nonzero=1
            break
        fi
    done < <(grep -hEoi 'exclud(e|ed)[^0-9|]{0,30}[|:][^0-9]{0,8}[0-9]+' "${SCAN_FILES[@]}" || true)
    named_lowest=0
    if grep -Eiq '(lowest[ -]scoring|lowest[^.]{0,30}cleared|weakest[^.]{0,20}(included|kept|survivor)|marginal[ -]keep|lowest[^.]{0,20}that cleared)' "${SCAN_FILES[@]}"; then
        named_lowest=1
    fi
    if [[ "$excluded_nonzero" -eq 1 ]]; then
        pass A12 "run records >=1 excluded source"
    elif [[ "$named_lowest" -eq 1 ]]; then
        pass A12 "run names the lowest-scoring source that cleared the bar"
    else
        fail A12 "§6/report excludes no source and names no lowest-cleared source — no real cut made"
    fi
fi

# ===========================================================================
# DIRECTIVE 03 — NON-BLOCKING WARNINGS (W1, W2).
# These run unconditionally (the evidence-level table and Bias-Guard Summary live in the
# deliverable doc, which can exist even when the report is absent) and NEVER touch FAILS.
# The scan body is the deliverable doc unioned with the report, mirroring SCAN_FILES but
# computed locally so W1/W2 work even on a report-absent run.
# ===========================================================================
WARN_SCAN=()
[[ -n "$DELIVERABLE_DOC" && -f "$DELIVERABLE_DOC" ]] && WARN_SCAN+=("$DELIVERABLE_DOC")
[[ -f "$REPORT" ]] && WARN_SCAN+=("$REPORT")

# The exact verbatim banner string. Asserted character-for-character — this is the
# load-bearing public contract (Directive 03 acceptance criterion).
PRIMARY_BANNER="NO PRIMARY EVIDENCE — all findings are literature-derived predictions"

# ---------------------------------------------------------------------------
# W1 — NO-PRIMARY-EVIDENCE banner.
# Read Level 1 and Level 2 counts from the §6 evidence-level distribution table. The
# table rows are `| 1 | <desc> | <count> |` and `| 2 | <desc> | <count> |`. Primary
# experimental evidence = Level 1 (systematic review / meta-analysis) + Level 2 (RCT).
# Both zero => no primary evidence collected => the banner is required in §2.
#
# The level number alone is NOT a safe anchor: a search-log table earlier in §6 also has
# rows starting `| 1 |`, `| 2 |` (query numbers). We anchor on the canonical DESCRIPTION
# text of the evidence-level rows instead — Level 1 carries "systematic review" /
# "meta-analysis"; Level 2 carries "RCT" / "randomized" — then read that row's last
# integer cell as the count.
# ---------------------------------------------------------------------------
if [[ ${#WARN_SCAN[@]} -eq 0 ]]; then
    okwarn W1 "no deliverable doc to read evidence-level distribution from; banner check deferred"
else
    # Level 1 row: a leading `| 1 |` whose description names a systematic review /
    # meta-analysis. Count = last integer on the row (the count cell). grep -Ei (NOT -EI:
    # capital I is skip-binary, not case-insensitive, so a Title-Cased "Systematic Review"
    # row never matched and the no-primary-evidence backstop silently cleared).
    lvl1=$(grep -Ei '^\|[[:space:]]*1[[:space:]]*\|.*(systematic[[:space:]]+review|meta[ -]?analysis)' "${WARN_SCAN[@]}" \
        | head -n1 \
        | grep -Eo '[0-9]+' | tail -n1 || true)
    # Level 2 row: a leading `| 2 |` whose description names an RCT / randomized trial /
    # strong experiment. Count = last integer on the row.
    lvl2=$(grep -Ei '^\|[[:space:]]*2[[:space:]]*\|.*(RCT|randomi[sz]ed|strong[[:space:]]+experiment)' "${WARN_SCAN[@]}" \
        | head -n1 \
        | grep -Eo '[0-9]+' | tail -n1 || true)
    # Banner already present verbatim in the deliverable?
    banner_present=0
    if grep -Fq "$PRIMARY_BANNER" "${WARN_SCAN[@]}"; then
        banner_present=1
    fi
    if [[ -z "$lvl1" && -z "$lvl2" ]]; then
        # No readable evidence-level distribution table. If the banner is already present,
        # honor it; otherwise this is not a primary-evidence signal we can read — stay clear.
        if [[ "$banner_present" -eq 1 ]]; then
            okwarn W1 "no readable evidence-level table but verbatim NO-PRIMARY-EVIDENCE banner is present"
        else
            okwarn W1 "no readable §6 evidence-level distribution table; primary-evidence floor not assessable"
        fi
    else
        [[ -n "$lvl1" ]] || lvl1=0
        [[ -n "$lvl2" ]] || lvl2=0
        primary=$(( lvl1 + lvl2 ))
        if [[ "$primary" -eq 0 ]]; then
            if [[ "$banner_present" -eq 1 ]]; then
                okwarn W1 "0 primary-evidence cards (L1=$lvl1 + L2=$lvl2) and the verbatim banner is present in §2"
            else
                warn W1 "0 primary-evidence cards (L1=$lvl1 + L2=$lvl2) — §2 MUST carry the verbatim banner: \"${PRIMARY_BANNER}\""
            fi
        else
            okwarn W1 "$primary primary-evidence card(s) collected (L1=$lvl1 + L2=$lvl2); no banner required"
        fi
    fi
fi

# ---------------------------------------------------------------------------
# W2 — CONFIRMATION-SKEW gate.
# Read the "Agreed with source" and "Disagreed with source" counts from the §6
# Bias-Guard Summary. The rows are
#   | Agreed with source — scored harder on dims 5, 6, 8 | <N> |
#   | Disagreed with source — scored more generously on dims 5, 6, 8 | <N> |
# A skew of >3:1 (agree > 3 * disagree, incl. zero-disagree) triggers the warning and
# the verifier footnotes whether the two required remediations are present:
#   (a) a falsification query in the Phase 2 search plan/log (a `falsif`-bearing line)
#   (b) a literal `steel-man` contrarian subsection in Phase 4
# ---------------------------------------------------------------------------
if [[ ${#WARN_SCAN[@]} -eq 0 ]]; then
    okwarn W2 "no deliverable doc to read Bias-Guard Summary from; skew check deferred"
else
    agree=$(grep -Ei '^\|[^|]*agree[d]?[[:space:]]+with[[:space:]]+source' "${WARN_SCAN[@]}" \
        | head -n1 \
        | grep -Eo '[0-9]+' | tail -n1 || true)
    disagree=$(grep -Ei '^\|[^|]*disagree[d]?[[:space:]]+with[[:space:]]+source' "${WARN_SCAN[@]}" \
        | head -n1 \
        | grep -Eo '[0-9]+' | tail -n1 || true)
    if [[ -z "$agree" || -z "$disagree" ]]; then
        okwarn W2 "no readable Bias-Guard Summary agree/disagree counts; confirmation-skew not assessable"
    else
        # >3:1 skew test without floats: agree > 3 * disagree. Covers disagree==0.
        if [[ "$agree" -gt $(( disagree * 3 )) ]]; then
            # Remediation presence checks (footnoted, not blocking).
            has_falsif=0
            if grep -Eiq 'falsif' "${WARN_SCAN[@]}"; then
                has_falsif=1
            fi
            has_steelman=0
            if grep -Eiq 'steel[- ]?man' "${WARN_SCAN[@]}"; then
                has_steelman=1
            fi
            missing=""
            [[ "$has_falsif" -eq 0 ]] && missing="a falsification query in the Phase 2 search plan"
            if [[ "$has_steelman" -eq 0 ]]; then
                [[ -n "$missing" ]] && missing="$missing AND "
                missing="${missing}a \"steel-man the contrarian\" subsection in Phase 4"
            fi
            if [[ -n "$missing" ]]; then
                warn W2 "confirmation skew ${agree}:${disagree} exceeds 3:1 — REQUIRES ${missing} (both missing-or-partial)"
            else
                warn W2 "confirmation skew ${agree}:${disagree} exceeds 3:1 — required falsification query AND steel-man subsection are present, but the skew remains a flagged research-design risk"
            fi
        else
            okwarn W2 "confirmation skew ${agree}:${disagree} within 3:1 — no falsification/steel-man remediation required"
        fi
    fi
fi

# ===========================================================================
# Verdict.
# ===========================================================================
# The advisory warnings tally is surfaced on BOTH paths — warnings are independent of
# the hard verdict and must be visible whether the gate passes or fails. They never
# change the exit code (Directive 03: banner first, block later).
printf 'Warnings: %s\n' "$WARNS"

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
