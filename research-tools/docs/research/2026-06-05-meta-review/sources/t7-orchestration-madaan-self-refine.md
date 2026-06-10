# Source: Madaan et al. — "Self-Refine: Iterative Refinement with Self-Feedback"

**Full citation:** Madaan, Aman; Tandon, Niket; Gupta, Prakhar; et al. "Self-Refine: Iterative
Refinement with Self-Feedback." NeurIPS 2023 (arXiv:2303.17651). 2023.
**URL:** https://arxiv.org/abs/2303.17651
**Date accessed:** 2026-06-06
**Evidence level:** 5 (Empirical methods study with multi-task benchmark data; NeurIPS 2023)
**Research topic area:** Generator-critic / self-refine — the pro-self-improvement claim

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 8/10 | CMU/Allen AI/Google authors; NeurIPS 2023; widely cited. |
| 2 | Evidence Quality | 6/10 | 7-task evaluation with GPT-3.5/4, but gains are on generation/preference tasks more than hard reasoning. |
| 3 | Currency | 8/10 | 2023; foundational but pre-dates the self-correction critiques. |
| 4 | Intent | 9/10 | Academic method paper; open-source. |
| 5 | Bias & Objectivity | 5/10 | Headline "~20% across tasks" understates that reasoning tasks benefit least. Scored harder — I'm wary. |
| 6 | Logic & Coherence | 7/10 | Mechanism is clean, but aggregating dissimilar tasks into one "~20%" inflates the impression. |
| 7 | Corroboration | 5/10 | Partly contradicted by Huang et al. on reasoning; corroborated only for tasks with checkable feedback. |
| 8 | Intellectual Honesty | 6/10 | Reports per-task numbers but the marketing framing leans optimistic. |
| 9 | Specificity | 8/10 | Concrete per-task deltas (e.g., code optimization 22.0→28.8). |
| 10 | Relevance | 9/10 | Direct on generator-critic loops; central to the self-refine debate. |

**Composite score:** 6.95

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

(I find self-refine intuitively appealing, so I scored its honesty/bias harder.)

## Key Findings

- Self-Refine: one model generates, critiques its own output, then refines — iteratively, with no
  extra training.
- Reported ~20% average improvement across 7 diverse tasks (GPT-3.5/ChatGPT/GPT-4); e.g., code
  optimization 22.0 → 28.8 after three iterations.
- The strongest gains are on open-ended generation and preference-flavored tasks; hard multi-step
  reasoning benefits least — the exact zone where Huang et al. show intrinsic correction fails.
- Contested: the "~20%" headline is real for some tasks but does NOT establish that self-critique
  fixes reasoning errors without external feedback.

## Verified Quote(s)

**Location reference:** Abstract / project page (selfrefine.info); the per-task example figures.

> "Self-Refine: Iterative Refinement with Self-Feedback"

> Reported result (project page, results section): outputs generated with Self-Refine improve "by
> ~20% across all evaluated tasks" with the code-optimization task moving from 22.0 to 28.8 after
> three iterations.

**Access status:** cached/partial (abstract + project-page summary verified; per-task table values
quoted from the project page summary rather than re-fetched PDF table)

## Inclusion Decision

**Decision:** Core
**Rationale:** Needed as the pro-self-refine anchor that Huang et al. constrains. Together they form
the track's clearest "replicated-vs-hype" contrast for generator-critic loops.

**Redundancy check:** Unique as the origin self-refine claim; Reflexion supersedes it for the
external-feedback variant.

**Perspective category:** Academic
