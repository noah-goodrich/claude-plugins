# Source: Zheng et al. — "Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena"

**Full citation:** Zheng, Lianmin; Chiang, Wei-Lin; Sheng, Ying; et al. "Judging LLM-as-a-Judge with
MT-Bench and Chatbot Arena." NeurIPS 2023 Datasets & Benchmarks (arXiv:2306.05685). 2023.
**URL:** https://arxiv.org/abs/2306.05685
**Date accessed:** 2026-06-06
**Evidence level:** 3 (Large-scale observational/crowdsourced human-preference study + benchmark)
**Research topic area:** LLM-as-judge reliability — does the critic/judge approximate humans?

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 9/10 | LMSYS/UC Berkeley team; authors of Chatbot Arena; NeurIPS 2023. |
| 2 | Evidence Quality | 8/10 | Two benchmarks incl. large crowdsourced human-preference data; strong design. |
| 3 | Currency | 7/10 | 2023; judges have improved since, but the bias taxonomy still holds. |
| 4 | Intent | 9/10 | Academic; open benchmarks released for the field. |
| 5 | Bias & Objectivity | 8/10 | Explicitly enumerates judge biases AND reports the 80% agreement — balanced. Scored harder (agree). |
| 6 | Logic & Coherence | 8/10 | "Same level of agreement as between humans" is a fair, well-bounded claim. Scored harder. |
| 7 | Corroboration | 8/10 | Bias taxonomy corroborated by 2024 "Justice or Prejudice?" and self-preference-bias studies. |
| 8 | Intellectual Honesty | 8/10 | Names position, verbosity, self-enhancement biases and limited reasoning ability up front. |
| 9 | Specificity | 8/10 | Concrete ">80% agreement," named bias types, two benchmarks. |
| 10 | Relevance | 9/10 | Governs whether an LLM judge / critic / aggregator in the pipeline can be trusted. |

**Composite score:** 8.30

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- Strong LLM judges (GPT-4) match human preferences at >80% agreement — the same agreement level
  humans have with each other — making LLM-as-judge a scalable proxy for human eval.
- But the SAME paper documents systematic judge biases: position bias, verbosity bias, and
  self-enhancement bias, plus limited reasoning ability.
- Implication for pipelines: an LLM judge/critic is useful but must be debiased (swap positions,
  control for length, avoid self-grading) — never used naively.
- Contested with the self-preference-bias literature on how much these biases corrupt rankings in
  adversarial vs benign settings.

## Verified Quote(s)

**Location reference:** Abstract.

> "strong LLM judges like GPT-4 can match both controlled and crowdsourced human preferences well,
> achieving over 80% agreement, the same level of agreement between humans."

> "We examine the usage and limitations of LLM-as-a-judge, including position, verbosity, and
> self-enhancement biases, as well as limited reasoning ability"

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** The canonical evidence that LLM-as-judge is good-but-biased — exactly the calibration
a generator-critic or debate-aggregator pipeline needs.

**Redundancy check:** Unique as the origin agreement-rate + bias-taxonomy source; bias-specific
papers refine it rather than replace it.

**Perspective category:** Academic
