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

**Composite score:** [calculated weighted average]

## Bias Guard Check

- [ ] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

[3-5 bullet points summarizing the most important claims or insights from this source.
Each bullet should be a discrete, citable finding — not a vague summary.]

## Inclusion Decision

**Decision:** [Core / Supporting / Excluded]
**Rationale:** [Which factors from the inclusion-decision-matrix drove this decision.
If an override was applied, document it here.]

**Redundancy check:** [Does this add something not already covered by a stronger source?
If yes, what? If no, which source supersedes it?]

**Perspective category:** [EXACTLY ONE of: `Academic` / `Institutional` / `Practitioner` /
`Boots-on-the-ground` / `Contrarian`. No other values. Do not invent hybrid labels
("Tier-1 journalism," "Industry-benchmark," "Internal," "Practitioner/Boots-on-the-ground,"
etc.) — if the source spans two categories, pick the primary one and note the secondary
in the Rationale field above. Any value outside this enum is non-compliant.]
```

---

## Filing Convention

- **Filename:** `[topic-area]-[short-slug].md` (e.g., `budgeting-methods-ynab-philosophy.md`)
- **Location:** `[project]/docs/research/sources/`
- **One card per source** — even if a source spans multiple topic areas, file it under its
  primary topic and cross-reference in the findings
