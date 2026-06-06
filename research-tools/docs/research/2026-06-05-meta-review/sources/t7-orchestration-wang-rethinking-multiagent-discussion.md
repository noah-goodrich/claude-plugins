# Source: Wang et al. — "Rethinking the Bounds of LLM Reasoning: Are Multi-Agent Discussions the Key?"

**Full citation:** Wang, Qineng; Wang, Zihao; Su, Ying; Tong, Hanghang; Song, Yangqiu. "Rethinking
the Bounds of LLM Reasoning: Are Multi-Agent Discussions the Key?" ACL 2024 (arXiv:2402.18272). 2024.
**URL:** https://arxiv.org/abs/2402.18272
**Date accessed:** 2026-06-06
**Evidence level:** 5 (Empirical methods study with systematic comparison; peer-reviewed at ACL)
**Research topic area:** Critical re-evaluation of multi-agent debate vs single-agent baselines

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 8/10 | UIUC/HKUST researchers; ACL 2024 acceptance. |
| 2 | Evidence Quality | 8/10 | Systematic head-to-head across tasks and backbones; proposes its own framework to be fair. |
| 3 | Currency | 9/10 | 2024; directly current to the debate. |
| 4 | Intent | 9/10 | Academic inquiry explicitly testing a popular claim; no product to sell. |
| 5 | Bias & Objectivity | 8/10 | Disconfirming-result paper; reports the narrow case where multi-agent DOES win (no demos). Scored harder — I agree. |
| 6 | Logic & Coherence | 8/10 | Clean ablation logic isolating prompt strength as the confound. Scored harder. |
| 7 | Corroboration | 8/10 | Aligns with Cognition's thesis and the self-consistency-beats-debate findings. |
| 8 | Intellectual Honesty | 9/10 | Names the exact condition (no demonstrations) where multi-agent helps; doesn't overclaim. |
| 9 | Specificity | 7/10 | Specific finding and condition; abstract light on raw numbers. |
| 10 | Relevance | 10/10 | The cleanest academic refutation of "you need multi-agent." Core to the track. |

**Composite score:** 8.10

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- A single-agent LLM with strong prompts achieves almost the same performance as the best multi-agent
  discussion method across a wide range of reasoning tasks and backbone models.
- Multi-agent discussion beats a single agent ONLY when there is no demonstration (no few-shot
  examples) in the prompt — i.e., the gain is largely a substitute for good prompting.
- Reframes "the bounds of LLM reasoning": the ceiling is set by the base model + prompt, not by
  adding agents.
- Strong triangulation partner for Cognition (contrarian) and the self-consistency baseline.

## Verified Quote(s)

**Location reference:** Abstract.

> "a single-agent LLM with strong prompts can achieve almost the same performance as the best
> existing discussion approach on a wide range of reasoning tasks and backbone LLMs."

> "We observe that the multi-agent discussion performs better than a single agent only when there is
> no demonstration in the prompt."

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** This is the load-bearing academic counterweight to Du et al. and Anthropic. It
provides the precise condition under which multi-agent is or isn't worth it.

**Redundancy check:** Unique — it isolates "strong prompt vs add agents" in a way no other source
does. Not superseded.

**Perspective category:** Academic
