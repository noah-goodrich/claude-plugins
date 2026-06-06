# Source: "Understanding When Tree of Thoughts Succeeds: Larger Models Excel in Generation, Not Discrimination"

**Full citation:** (MaiNLP / tot-eval authors). "Understanding When Tree of Thoughts Succeeds:
Larger Models Excel in Generation, Not Discrimination." arXiv:2410.17820. October 2024.
**URL:** https://arxiv.org/abs/2410.17820
**Date accessed:** 2026-06-06
**Evidence level:** 5 (Empirical ablation study isolating generator vs discriminator roles)
**Research topic area:** Tree-of-thought / search — when deliberate search actually helps

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 7/10 | Academic group with public eval repo (mainlp/tot-eval); arXiv preprint, not yet a top-venue cite. |
| 2 | Evidence Quality | 7/10 | Clean component ablation across model scales; preprint not fully peer-reviewed. |
| 3 | Currency | 9/10 | Oct 2024; current critical take on ToT. |
| 4 | Intent | 9/10 | Academic; releases evaluation code. |
| 5 | Bias & Objectivity | 8/10 | Reports that ToT DOES often beat baselines before showing where it doesn't. Scored harder (agree). |
| 6 | Logic & Coherence | 8/10 | Generator-vs-discriminator isolation is a strong causal design. |
| 7 | Corroboration | 6/10 | Discrimination-bottleneck framing echoes broader "verification is the hard part" results; fewer direct replications. |
| 8 | Intellectual Honesty | 8/10 | Explicit that ToT can surpass simpler methods AND that gains are inconsistent across models. |
| 9 | Specificity | 7/10 | Names the generator/discriminator scaling deltas; abstract light on raw task numbers. |
| 10 | Relevance | 9/10 | Directly answers whether ToT-style search is a real win or conditional. |

**Composite score:** 7.55

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- ToT often beats IO and Chain-of-Thought, but "does not consistently outperform such simpler methods
  across all models" — the gain is conditional, not universal.
- The generator, not the discriminator, drives ToT's success: scaling the generator helps a lot;
  scaling the discriminator (with fixed generator) yields only marginal gains.
- Models across scales have COMPARABLE discrimination ability but differ in generation — so search
  helps mainly when a model can generate good candidate steps, and the verifier is rarely the
  binding constraint people assume.
- Implication: ToT/GoT search is worth it on hard combinatorial/search tasks (e.g., Game-of-24 type),
  but on typical knowledge work it often doesn't beat plain CoT — a hype-vs-real boundary.

## Verified Quote(s)

**Location reference:** Abstract.

> "ToT does not consistently outperform such simpler methods across all models, leaving large
> knowledge gaps on the conditions under which ToT is most beneficial."

> "the generator plays a more critical role than the discriminator in driving the success of ToT."

> "models across different scales exhibit comparable discrimination capabilities, yet differ
> significantly in their generative performance for ToT."

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** The key qualifier on Tree-of-Thoughts. Pairs with Yao et al.'s headline (74% on
Game-of-24) to separate ToT's real domain from the over-generalized hype.

**Redundancy check:** Unique — only source isolating generator vs discriminator as the ToT lever.

**Perspective category:** Academic
