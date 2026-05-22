# Worked Example: Full Pipeline Evaluation

This example walks through evaluating a real source using every step of the deep-research
methodology. Follow this pattern for each source you evaluate.

---

## The Source

**Title:** "The Psychology of Money: Timeless Lessons on Wealth, Greed, and Happiness"
**Author:** Morgan Housel
**Publication:** Harriman House, 2020
**Type:** Book (popular non-fiction)
**Research topic area:** Behavioral finance & money psychology

---

## Step 1: Evidence Classification

**Level 7: Expert opinion / thought leadership**

Housel is a former financial columnist (Motley Fool, Wall Street Journal) and partner at
Collaborative Fund. This book synthesizes behavioral finance research into accessible
narratives but is not itself a research publication. It cites academic studies but presents
Housel's interpretive framework, not new empirical findings.

---

## Step 2: Credibility Scoring

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 7/10 | Experienced financial writer with 15+ year track record. Not an academic or licensed advisor, but deeply read and widely respected in the practitioner community. Verified credentials at Collaborative Fund. |
| 2 | Evidence Quality | 5/10 | Cites real studies (Shiller, Kahneman, Federal Reserve data) but selectively — chosen to support narrative points rather than presented systematically. No original research. |
| 3 | Currency | 7/10 | Published 2020. Core insights are behavioral (timeless bonus +2 applied, capped at 10 → 7+2=9, but underlying data examples are pre-2020, pulling it back to 7). |
| 4 | Intent | 7/10 | Commercial (book sales) but genuinely educational. Housel's blog gave away the same ideas for free for years before the book. The book organizes and polishes, not gates. |
| 5 | Bias & Objectivity | 6/10 | Has a clear worldview (patience + humility > cleverness) but acknowledges edge cases. Doesn't strawman aggressive investing — just argues it's not for most people. Minor blind spot: assumes US context throughout. |
| 6 | Logic & Coherence | 8/10 | Each chapter builds a distinct, well-reasoned argument. Stories illustrate principles clearly. Occasional correlation-as-causation in anecdotes, but the core logic is sound. |
| 7 | Corroboration | 8/10 | Key insights (compounding, tail events, room for error, behavior > intelligence) are widely confirmed by Kahneman, Thaler, Bernstein, and others. |
| 8 | Intellectual Honesty | 8/10 | Explicitly says "no one is crazy" about money — refuses to judge. Acknowledges his own biases. Says "reasonable > rational" which is a genuine epistemic humility move. |
| 9 | Specificity | 6/10 | Uses named historical examples (Ronald Read, Richard Fuscone) with specific dollar amounts. But some claims are general ("most people...") without citing the underlying survey data. |
| 10 | Relevance | 7/10 | Directly addresses how people think about money, which is foundational to designing a household finance tool. Doesn't address budgeting mechanics or couples dynamics specifically. |

### Composite Score Calculation

```
Authority:           7 × 0.25 = 1.75
Evidence Quality:    5 × 0.20 = 1.00
Currency:            7 × 0.10 = 0.70
Intent:              7 × 0.10 = 0.70
Bias & Objectivity:  6 × 0.10 = 0.60
Logic & Coherence:   8 × 0.05 = 0.40
Corroboration:       8 × 0.05 = 0.40
Intellectual Honesty: 8 × 0.05 = 0.40
Specificity:         6 × 0.05 = 0.30
Relevance:           7 × 0.05 = 0.35
                              ------
Composite:                     6.60
```

**Composite score: 6.6**

---

## Step 3: Bias Guard Check

- [ ] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [x] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

*(In this example, the evaluator personally favors more structured, data-driven approaches to
money management, which is the opposite of Housel's "behavior matters more than spreadsheets"
thesis. Per the bias guard, dimensions 5, 6, and 8 were scored MORE generously to compensate
for the temptation to penalize a perspective the evaluator disagrees with.)*

---

## Step 4: Key Findings

1. **Behavior beats intelligence in financial outcomes.** The janitor who saves consistently
   outperforms the finance executive who over-leverages — financial success is more about
   temperament than knowledge.
2. **"Reasonable" is better than "rational."** Mathematically optimal strategies that you can't
   stick to are worse than suboptimal strategies you can sustain. Implications for tool design:
   optimize for adherence, not theoretical efficiency.
3. **Everyone's money experience is fundamentally different.** A person who grew up during
   hyperinflation has a different relationship with money than one who grew up during a boom.
   No single "right" approach exists.
4. **The importance of "room for error."** Financial plans should assume things will go wrong.
   Margin of safety > precision in projections.
5. **Wealth is what you don't see.** Spending to display wealth destroys actual wealth. The
   most financially secure people are often invisible.

---

## Step 5: Inclusion Decision

**Decision: Supporting source**

**Rationale:** Composite score of 6.6 falls in the 5.0–6.9 range. Applying Rule 4 (Moderate
Include): contextual factors favor inclusion on 3 of 5 counts:
- **Relevance:** Yes — directly informs how a household finance tool should think about user
  behavior
- **Actionability:** Yes — finding #2 ("optimize for adherence, not efficiency") is directly
  actionable for product design
- **Unique insight:** Yes — the "reasonable > rational" framework is not articulated this
  clearly in other evaluated sources
- **Redundancy:** Partially redundant with Kahneman and Thaler on behavioral biases, but
  Housel's household-focused framing adds value
- **Contextual fit:** Yes — targets general US audience, matches our demographic

**Redundancy check:** Overlaps with Kahneman ("Thinking Fast and Slow") on cognitive biases
and Thaler ("Nudge") on choice architecture. But Housel's contribution is the accessible,
household-focused synthesis. Kept because the FRAMING is unique even if the underlying insights
are not.

**Perspective category:** Practitioner (financial writer/investor, not academic or institution)

---

## What This Example Demonstrates

1. **A Level 7 source can still be valuable** — evidence level doesn't gate inclusion
2. **The bias guard changes scoring** — the evaluator's disagreement was documented and
   compensated for
3. **"Supporting" is not "weak"** — this source contributes meaningfully to finding #2 and #3
4. **Redundancy is nuanced** — the source overlaps with others on CONTENT but adds unique
   FRAMING
5. **Every decision is traceable** — a skeptic could challenge any score and get a reasoned
   justification
