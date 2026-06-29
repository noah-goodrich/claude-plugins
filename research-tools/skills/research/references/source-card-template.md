# Source Evaluation Card Template

Use this template for every source evaluated during research. One card per source. Store
completed cards in the project's `sources/` directory.

---

```markdown
# Source: [Short title or identifier]

**Full citation:** [Author(s). "Title." Publication/URL. Date.]
**URL:** [if applicable]
**Date accessed:** [YYYY-MM-DD]
**Evidence level:** [1-9, per evidence-hierarchy.md]
**Research topic area:** [Which topic area from the research topic map this addresses]

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | /10 | [1-2 sentences] |
| 2 | Evidence Quality | /10 | [1-2 sentences] |
| 3 | Currency | /10 | [1-2 sentences; note timeless bonus if applied] |
| 4 | Intent | /10 | [1-2 sentences] |
| 5 | Bias & Objectivity | /10 | [1-2 sentences] |
| 6 | Logic & Coherence | /10 | [1-2 sentences] |
| 7 | Corroboration | /10 | [1-2 sentences; name corroborating sources] |
| 8 | Intellectual Honesty | /10 | [1-2 sentences] |
| 9 | Specificity | /10 | [1-2 sentences] |
| 10 | Relevance | /10 | [1-2 sentences] |

**Score band:** [EXACTLY ONE of: `keep` / `borderline` / `reject`, per
source-evaluation-rubric.md. Do NOT report a 2-decimal composite — the band is the
disposition. You may note the intermediate weighted average in a justification, but the
card's verdict is the band word. Every run must cut ≥1 source or name the lowest source
that cleared the bar — see the rubric's real-cut rule.]

## Bias Guard Check

- [ ] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

[3-5 bullet points summarizing the most important claims or insights from this source.
Each bullet should be a discrete, citable finding — not a vague summary.]

## Verified Quote(s)

[Use this LITERAL heading: `## Verified Quote(s)` — plural, with parentheses. A singular
`## Verified Quote` is non-compliant and the executable gate (Assertion 5) fails the
manifest on it (the reveal s11 card used the singular form and slipped a bad quote
through). At least ONE verbatim quote from the source — copied exactly, not paraphrased —
that serves as the textual evidence for the strongest claim this card makes in Key
Findings. The reader (and the Phase 3.5 verification subagent) must be able to take this
quote and search for it character-for-character in the source. If the source is long,
prefer two or three short quotes over one paraphrastic block. **Attribution must match the
card URL host:** if you credit the quote to a domain other than this card's `URL:` host,
the gate (Assertion 9) marks the card an automatic `failed` — the quote did not come from
the source the card claims.]

**Location reference:** [The exact pointer a verifier needs to find this in the source.
Use the most precise unit the source supports — page number for books/PDFs, section
heading for web articles, timestamp `MM:SS` for video/audio, paragraph offset (e.g.,
"paragraph 7 under heading X") for unpaginated web text. Vague locators like "somewhere
in the conclusion" are non-compliant.]

> [Quote 1, verbatim, in blockquote form. Preserve original punctuation, capitalization,
> and any italics/bolding as `*emphasis*` / `**emphasis**`. If you elide text inside the
> quote, use bracketed ellipses `[...]` so it is clear material was omitted.]

> [Quote 2, if applicable. One blockquote per quote.]

**Access status:** [EXACTLY ONE of: `live` / `cached/partial` / `inaccessible`.
- `live` — URL was fetched successfully at evaluation time and the quote was verified
  in-place.
- `cached/partial` — source could not be fully re-fetched (paywall, takedown, dead link,
  geo-block); the quote is what was visible at the original access time. The Phase 3.5
  verifier will mark this source `inaccessible` rather than `failed`.
- `inaccessible` — only the title/abstract was ever available; the card is built on
  metadata + secondary description. Strongly consider exclusion in Phase 4.]

## Inclusion Decision

**Decision:** [Core / Supporting / Excluded]
**Rationale:** [Which factors from the inclusion-decision-matrix drove this decision.
If an override was applied, document it here.]

**Redundancy check:** [Does this add something not already covered by a stronger source?
If yes, what? If no, which source supersedes it?]

**Perspective category:** [EXACTLY ONE of: `Academic` / `Institutional` / `Practitioner` /
`Boots-on-the-ground` / `Contrarian`. No other values. Do not invent hybrid labels
("Tier-1 journalism," "Industry-benchmark," "Internal," "Academic/Institutional,"
"Practitioner/Boots-on-the-ground," etc.) — if the source spans two categories, pick the
primary one and note the secondary in the Rationale field above. Any value outside this
enum is non-compliant, and the executable gate (Assertion 11) fails the manifest on any
present non-enum value — a slash-joined hybrid like "Academic/Institutional" is exactly
the deviation it catches.]
```

---

## Filing Convention

- **Filename:** `[topic-area]-[short-slug].md` (e.g., `budgeting-methods-ynab-philosophy.md`)
- **Location:** `[project]/docs/research/sources/`
- **One card per source** — even if a source spans multiple topic areas, file it under its
  primary topic and cross-reference in the findings

## Scholarly-Adapter Cards (Directive 06 — backend-agnostic)

The optional scholarly adapter (`hooks/scholarly-adapter.sh`, OpenAlex default / Semantic
Scholar fallback) emits cards using THIS template — there are NO backend-specific fields. An
adapter card carries the same Full citation, URL, Date accessed, Evidence level, Key Findings,
`## Verified Quote(s)` heading + Access status, and Inclusion Decision + Perspective category
as any hand-authored card. A reader cannot tell which backend pulled it; that is deliberate, so
the corpus stays swappable and the open-corpus advantage never becomes new lock-in. The only
adapter-specific convention is operational, not schematic: the card's `## Verified Quote(s)`
blockquote is a VERBATIM span of the abstract the adapter snapshotted at fetch time to
`docs/research/snapshots/<card-id>.txt`, and the Location reference points at that snapshot.
The Phase 3.5 verifier and the executable ground gate check the quote against the snapshot
exactly as they check a web card's quote against its live page (the Directive 01 ground-ledger
contract). The DOI is the card's `URL:` host so the Assertion 9 domain check passes; the
open-access PDF link, when present, is noted on an `**Open-access PDF:**` line.
