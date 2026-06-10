# Source: Du et al. — "Improving Factuality and Reasoning in Language Models through Multiagent Debate"

**Full citation:** Du, Yilun; Li, Shuang; Torralba, Antonio; Tenenbaum, Joshua B.; Mordatch, Igor.
"Improving Factuality and Reasoning in Language Models through Multiagent Debate." ICML 2024
(arXiv:2305.14325). 2023/2024.
**URL:** https://arxiv.org/abs/2305.14325
**Date accessed:** 2026-06-06
**Evidence level:** 5 (Practitioner/Methods study with empirical benchmark data; peer-reviewed at ICML)
**Research topic area:** Multi-agent debate — the foundational pro-debate claim

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 9/10 | MIT/Google authors (Tenenbaum, Torralba, Mordatch); ICML 2024 acceptance. |
| 2 | Evidence Quality | 7/10 | Multi-benchmark empirical study with public code; not an RCT but rigorous and reproducible. |
| 3 | Currency | 9/10 | 2023 preprint, ICML 2024; still the canonical debate reference. |
| 4 | Intent | 8/10 | Academic method paper; field advancement, minimal commercial interest. |
| 5 | Bias & Objectivity | 6/10 | Presents debate favorably; later work shows gains overstated vs self-consistency. Scored harder — I'm wary of the framing. |
| 6 | Logic & Coherence | 7/10 | Sound, but the headline conflates ensemble effect with "debate." Scored harder. |
| 7 | Corroboration | 6/10 | Replicated as a method, but its mechanism claim is contested by Wang 2024 and the self-consistency comparisons. |
| 8 | Intellectual Honesty | 6/10 | Reports gains but doesn't isolate debate vs majority-voting; later critiqued for this. |
| 9 | Specificity | 7/10 | Named benchmarks and procedure; abstract is light on numbers but the paper has them. |
| 10 | Relevance | 10/10 | The seminal "multi-agent debate works" paper — the claim the whole track interrogates. |

**Composite score:** 7.30

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

(Note: I lean toward the critique that gains are mostly ensemble effect, so I scored the original
paper harder, not more generously.)

## Key Findings

- Proposes multiple LLM instances proposing and debating their responses over multiple rounds to
  converge on a final answer.
- Claims significant gains in mathematical/strategic reasoning and reduced hallucinations/factual
  errors across several tasks.
- The abstract states improvements qualitatively; the mechanism (genuine "debate" vs simple
  ensembling/majority voting) is NOT isolated — this gap is what later critiques exploit.
- This is the origin of the "debate improves reasoning" claim that the track must separate from hype.

## Verified Quote(s)

**Location reference:** Abstract.

> "multiple language model instances propose and debate their individual responses and reasoning
> processes over multiple rounds to arrive at a common final answer"

> "significantly enhances mathematical and strategic reasoning across a number of tasks"

> "improves the factual validity of generated content, reducing fallacious answers and
> hallucinations"

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** Required as the foundational pro-debate source. Must be paired with Wang et al. 2024
and the self-consistency baseline to show what part of the claim survives scrutiny.

**Redundancy check:** Unique as the origin claim; not superseded but materially qualified by later
critiques in this track.

**Perspective category:** Academic
