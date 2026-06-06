# Source: Wang et al. — "Self-Consistency Improves Chain of Thought Reasoning in Language Models"

**Full citation:** Wang, Xuezhi; Wei, Jason; Schuurmans, Dale; Le, Quoc; Chi, Ed; Narang, Sharan;
Chowdhery, Aakanksha; Zhou, Denny. "Self-Consistency Improves Chain of Thought Reasoning in Language
Models." ICLR 2023 (arXiv:2203.11171). 2022/2023.
**URL:** https://arxiv.org/abs/2203.11171
**Date accessed:** 2026-06-06
**Evidence level:** 5 (Empirical methods study with broad benchmark gains; ICLR 2023; Google Brain)
**Research topic area:** Self-consistency / ensembling — the best-replicated cheap win

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 9/10 | Google Brain (Jason Wei, Denny Zhou, Quoc Le); ICLR 2023; canonical. |
| 2 | Evidence Quality | 8/10 | Large multi-benchmark eval with consistent, sizable, and widely reproduced gains. |
| 3 | Currency | 7/10 | 2022/2023; older, but the method is a stable, still-used baseline. |
| 4 | Intent | 9/10 | Academic method paper; no commercial angle. |
| 5 | Bias & Objectivity | 8/10 | Straightforward decoding-strategy result; no overreach. Scored harder — I agree it works. |
| 6 | Logic & Coherence | 9/10 | Marginalize-over-paths logic is clean and well-motivated. Scored harder. |
| 7 | Corroboration | 9/10 | Among the most reproduced LLM reasoning results; the baseline that debate fails to beat. |
| 8 | Intellectual Honesty | 8/10 | Reports gains by benchmark; scope (reasoning with a discrete answer) is clear. |
| 9 | Specificity | 9/10 | Exact deltas: GSM8K +17.9%, SVAMP +11.0%, AQuA +12.2%, StrategyQA +6.4%, ARC +3.9%. |
| 10 | Relevance | 9/10 | The benchmark that reframes "debate" as ensembling; central to the track. |

**Composite score:** 8.45

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- Self-consistency samples multiple chain-of-thought paths and takes the majority answer instead of
  greedy decoding.
- Large, consistent gains: GSM8K +17.9%, SVAMP +11.0%, AQuA +12.2%, StrategyQA +6.4%, ARC-challenge
  +3.9% — among the most reproduced results in LLM reasoning.
- It is the baseline that multi-agent debate frequently fails to beat once compute is matched —
  meaning much of "debate's" benefit is really this cheap ensemble effect.
- Load-bearing: sampling+vote is the highest-confidence, lowest-complexity reasoning improvement; any
  pipeline should adopt it before reaching for multi-agent machinery.

## Verified Quote(s)

**Location reference:** Abstract (final sentence listing benchmark deltas).

> "self-consistency boosts the performance of chain-of-thought prompting with a striking margin on a
> range of popular arithmetic and commonsense reasoning benchmarks, including GSM8K (+17.9%), SVAMP
> (+11.0%), AQuA (+12.2%), StrategyQA (+6.4%) and ARC-challenge (+3.9%)."

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** The strongest replicated, cheap reasoning win and the benchmark against which debate
is judged. Essential to the consensus-zone finding.

**Redundancy check:** Unique — it is the reference baseline, not superseded by anything in the track.

**Perspective category:** Academic
