# Source: Huang et al. — "Large Language Models Cannot Self-Correct Reasoning Yet"

**Full citation:** Huang, Jie; Chen, Xinyun; Mishra, Swaroop; Zheng, Huaixiu Steven; Yu, Adams Wei;
Song, Xinying; Zhou, Denny. "Large Language Models Cannot Self-Correct Reasoning Yet." ICLR 2024
(arXiv:2310.01798). 2023/2024.
**URL:** https://arxiv.org/abs/2310.01798
**Date accessed:** 2026-06-06
**Evidence level:** 5 (Empirical methods study with controlled experiments; ICLR 2024; Google DeepMind)
**Research topic area:** Self-refine / self-correction — the critical limit

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 9/10 | Google DeepMind authors (Denny Zhou et al.); ICLR 2024. |
| 2 | Evidence Quality | 8/10 | Controlled experiments isolating intrinsic vs oracle-guided self-correction. |
| 3 | Currency | 9/10 | 2023/2024; the reference critique still cited heavily in 2026. |
| 4 | Intent | 9/10 | Academic inquiry; corrects an over-hyped capability claim. |
| 5 | Bias & Objectivity | 8/10 | Carefully scopes "intrinsic, no external feedback"; concedes external-feedback case works. Scored harder — I agree. |
| 6 | Logic & Coherence | 9/10 | The intrinsic-vs-extrinsic distinction is the crux and is cleanly argued. Scored harder. |
| 7 | Corroboration | 8/10 | Corroborated by Reflexion (works WITH external test feedback) and later "self-correction illusion" work. |
| 8 | Intellectual Honesty | 9/10 | "Yet" in the title; explicit about the boundary condition where it fails. |
| 9 | Specificity | 7/10 | Names tasks and the degradation effect; abstract light on exact deltas. |
| 10 | Relevance | 10/10 | Directly governs whether generator-critic / self-refine loops are real or hype. |

**Composite score:** 8.45

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- LLMs struggle to self-correct reasoning without external feedback; performance can DEGRADE after an
  intrinsic self-correction pass.
- The critical caveat: self-correction works when there is an external signal (oracle label, tools,
  code execution, human feedback). The failure is specific to "intrinsic" (model-only) correction.
- This reconciles the Self-Refine vs Reflexion gap: gains are real when the critic has ground truth
  to check against, illusory when the model grades itself blind.
- Load-bearing for pipeline design: a generator-critic loop needs an EXTERNAL verifier (tests,
  retrieval, a fresh-context judge), not just the same model second-guessing itself.

## Verified Quote(s)

**Location reference:** Abstract.

> "LLMs struggle to self-correct their responses without external feedback, and at times, their
> performance even degrades after self-correction."

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** This is the boundary condition that separates which generator-critic / self-refine
patterns replicate (external feedback) from which are hype (intrinsic). It anchors a major contested
zone with Self-Refine.

**Redundancy check:** Unique — the definitive intrinsic-vs-extrinsic delineation. Not superseded.

**Perspective category:** Academic
