#!/usr/bin/env bash
# validate.sh — enforce the design-doc template on a markdown file.
#
# Usage:  validate.sh <file.md>
#
# Exit codes:
#   0  pass (advisories may still print)
#   1  validation failure
#   2  usage error
#
# Advisories never change the exit code. A gate whose first act is rejecting a
# document its author considers finished is a gate its author turns off.
set -uo pipefail

ERRORS=0
ADVISORIES=0

# Everything prints to stdout so findings stay in document order for a reader
# and for the test suite. The exit code is the machine-readable verdict.
err() { printf 'ERROR: %s\n' "$1"; ERRORS=$((ERRORS + 1)); }
adv() { printf 'ADVISORY: %s\n' "$1"; ADVISORIES=$((ADVISORIES + 1)); }

if [ "$#" -ne 1 ]; then
    printf 'usage: validate.sh <file.md>\n' >&2
    printf 'Pass exactly one path to the design doc you want checked.\n' >&2
    exit 2
fi

FILE="$1"

if [ ! -f "$FILE" ] || [ ! -r "$FILE" ]; then
    printf 'usage: validate.sh <file.md>\n' >&2
    printf 'Not a readable file: %s. Check the path and try again.\n' "$FILE" >&2
    exit 2
fi

# --- heading table -----------------------------------------------------------
# Fenced blocks are skipped so a ``` example containing "## Problem" cannot
# satisfy a requirement. The lookup key is the title lowercased; the title keeps
# its original case because findings quote it back to the author.
HEAD_LINES=()
HEAD_TITLES=()
HEAD_KEYS=()

while IFS=$'\t' read -r hline hkey htitle; do
    [ -n "$hline" ] || continue
    HEAD_LINES+=("$hline")
    HEAD_TITLES+=("$htitle")
    HEAD_KEYS+=("$hkey")
done <<EOF
$(awk '
    /^[[:space:]]*(```|~~~)/ { fence = !fence; next }
    fence { next }
    /^##[[:space:]]/ {
        t = $0
        sub(/^##[[:space:]]+/, "", t)
        sub(/[[:space:]]*#+[[:space:]]*$/, "", t)
        sub(/[[:space:]]+$/, "", t)
        printf "%d\t%s\t%s\n", NR, tolower(t), t
    }
' "$FILE")
EOF

HEAD_COUNT=${#HEAD_KEYS[@]}

key_index() {
    local want="$1" i=0
    while [ "$i" -lt "$HEAD_COUNT" ]; do
        [ "${HEAD_KEYS[$i]}" = "$want" ] && { printf '%d' "$i"; return; }
        i=$((i + 1))
    done
    printf '%d' -1
}

# --- 1. tl;dr lead line ------------------------------------------------------
# The tl;dr is the bold LEAD line: the first content in the document, never a
# heading of its own. Only blank lines, the `# ` title, and an italic
# metadata/status line may precede it. A tl;dr a reader has to scroll past prose
# to reach is not the thing they triage from, so burying it is an error.
FIRST_HEADING_LINE="${HEAD_LINES[0]:-0}"

IFS=$'\t' read -r LEAD_LINE LEAD_IS_TLDR TLDR_LINE LEAD_TEXT <<EOF
$(awk -v stop="$FIRST_HEADING_LINE" '
    stop > 0 && NR >= stop { exit }
    /^[[:space:]]*$/ { next }
    tolower($0) ~ /^[[:space:]]*\*\*[[:space:]]*tl;?dr[^*]*\*\*/ {
        if (!tldr) { tldr = NR }
        if (!lead) { lead = NR; is_tldr = 1 }
        next
    }
    /^[[:space:]]*#[[:space:]]+[^#]/ { next }
    /^[[:space:]]*\*[^*].*\*[[:space:]]*$/ { next }
    /^[[:space:]]*_[^_].*_[[:space:]]*$/ { next }
    { if (!lead) { lead = NR; text = length($0) > 48 ? substr($0, 1, 48) "..." : $0 } }
    END { printf "%d\t%d\t%d\t%s\n", lead + 0, is_tldr + 0, tldr + 0, text }
' "$FILE")
EOF

if [ "${LEAD_IS_TLDR:-0}" -ne 1 ]; then
    TLDR_HEAD_IDX="$(key_index 'tl;dr')"
    [ "$TLDR_HEAD_IDX" -lt 0 ] && TLDR_HEAD_IDX="$(key_index 'tldr')"
    if [ "$TLDR_HEAD_IDX" -ge 0 ]; then
        err "tl;dr is a heading (line ${HEAD_LINES[$TLDR_HEAD_IDX]}), not a lead line. Delete the heading and put \
'**tl;dr** — <one sentence of problem, one of solution>' above the first '## ' heading."
    elif [ "${TLDR_LINE:-0}" -gt 0 ]; then
        err "tl;dr is buried (line $TLDR_LINE): '$LEAD_TEXT' opens the document at line $LEAD_LINE. Move the \
'**tl;dr**' line above it, directly under the title and status line, and move that opening text down into \
'## Problem' or '## Solution'. Only blank lines, the '# ' title, and an italic status line may come first."
    else
        err "no tl;dr. Add '**tl;dr** — <one sentence of problem, one of solution>' as a bold lead line under the \
title and status line, above the first '## ' heading."
    fi
fi

# --- 2. always-required sections ---------------------------------------------
# lookup key | heading as the author must write it | what belongs under it
REQUIRED=(
    "problem|## Problem|state the measured facts that make this worth doing, not the solution"
    "solution|## Solution|describe what you will build, concretely enough to argue with"
    "non-goals|## Non-Goals|write falsifiable boundary statements, one per thing you are choosing not to do"
    "alternatives considered|## Alternatives Considered|list each rejected option with the trade-off that killed it"
)
for req in "${REQUIRED[@]}"; do
    IFS='|' read -r key display hint <<<"$req"
    [ "$(key_index "$key")" -ge 0 ] && continue
    err "missing required section '$display'. Add it: $hint."
done

# --- 3. outcome section ------------------------------------------------------
# Program-level documents carry Goals; implementation-level ones carry Acceptance
# criteria. One is required. Both is legal, but usually means the document has
# not decided which level it is written at.
GOALS_IDX="$(key_index 'goals')"
ACC_IDX="$(key_index 'acceptance criteria')"

if [ "$GOALS_IDX" -lt 0 ] && [ "$ACC_IDX" -lt 0 ]; then
    err "no outcome section. Add '## Goals' for a program-level document (what is true for the reader once this \
lands) or '## Acceptance criteria' for an implementation-level one (checkable statements, each with how it is \
verified)."
elif [ "$GOALS_IDX" -ge 0 ] && [ "$ACC_IDX" -ge 0 ]; then
    adv "both '## Goals' (line ${HEAD_LINES[$GOALS_IDX]}) and '## Acceptance criteria' (line \
${HEAD_LINES[$ACC_IDX]}) are present. Keep the one that matches the document's level and fold the other into it, \
unless both are load-bearing."
fi

# --- 4. Decisions requested comes last ---------------------------------------
# Conditional section: required only when the document asks for a decision. When
# it is present, anything after it pushes the actionable block out of the
# terminal's landing region.
DR_IDX="$(key_index 'decisions requested')"
if [ "$DR_IDX" -ge 0 ] && [ "$DR_IDX" -lt "$((HEAD_COUNT - 1))" ]; then
    NEXT_IDX=$((DR_IDX + 1))
    TRAILING=$((HEAD_COUNT - NEXT_IDX))
    SUFFIX=''
    if [ "$TRAILING" -gt 1 ]; then
        SUFFIX=" ($TRAILING sections follow it)"
    fi
    adv "'## ${HEAD_TITLES[$NEXT_IDX]}' (line ${HEAD_LINES[$NEXT_IDX]}) comes after '## Decisions requested' (line \
${HEAD_LINES[$DR_IDX]})$SUFFIX. Move '## Decisions requested' to the end so the block you need answered is the last \
thing on screen."
fi

# --- verdict -----------------------------------------------------------------
if [ "$ERRORS" -gt 0 ]; then
    printf 'FAIL: %s - %d error(s), %d advisory(ies). Fix the errors above and re-run.\n' \
        "$FILE" "$ERRORS" "$ADVISORIES"
    exit 1
fi

printf 'PASS: %s - 0 errors, %d advisory(ies).\n' "$FILE" "$ADVISORIES"
exit 0
