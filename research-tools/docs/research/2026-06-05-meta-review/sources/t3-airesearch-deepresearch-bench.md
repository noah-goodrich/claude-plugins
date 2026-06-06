# Source: DeepResearch Bench — A Comprehensive Benchmark for Deep Research Agents

**Full citation:** Du, Mingxuan, et al. "DeepResearch Bench: A Comprehensive Benchmark for Deep Research
Agents." arXiv:2506.11763. June 2025. (Leaderboard: deepresearch-bench.github.io)
**URL:** https://deepresearch-bench.github.io/
**Date accessed:** 2026-06-06
**Evidence level:** 3 (Large-scale benchmark / structured evaluation across 100 expert tasks)
**Research topic area:** Benchmark results — report quality (RACE), citation accuracy + effective citations (FACT)

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 7/10 | arXiv preprint with a public leaderboard; methodology disclosed but not yet peer-reviewed. |
| 2 | Evidence Quality | 8/10 | 100 PhD-level tasks across 22 fields, two formal frameworks (RACE/FACT), reference-based scoring. |
| 3 | Currency | 9/10 | June 2025; covers Gemini 2.5 Pro DR, OpenAI DR, Perplexity DR, Claude 3.7. |
| 4 | Intent | 8/10 | Academic benchmark; public leaderboard for field advancement. |
| 5 | Bias & Objectivity | 7/10 | LLM-as-judge / reference-based scoring carries judge bias; methodology transparent. |
| 6 | Logic & Coherence | 8/10 | Clear separation of report quality vs retrieval; metrics map to distinct capabilities. |
| 7 | Corroboration | 6/10 | Citation-accuracy figures partly CONTESTED by DeepTRACE (see Redundancy/contested zone). |
| 8 | Intellectual Honesty | 7/10 | Notes distinct dimensions capture distinct capabilities; LLM-judge limits under-discussed. |
| 9 | Specificity | 9/10 | Exact RACE scores, effective-citation counts (111.21), citation accuracy (90.24%) per system. |
| 10 | Relevance | 10/10 | The canonical head-to-head benchmark for commercial deep-research systems. |

**Composite score:** 7.75

## Bias Guard Check

- [ ] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [x] Neutral / no strong reaction

## Key Findings

- 100 PhD-level tasks across 22 fields (50 Chinese, 50 English); evaluated via RACE (report quality) and FACT
  (citation/retrieval) frameworks.
- Gemini-2.5-Pro Deep Research led RACE overall (48.88), then OpenAI DR (46.98), Perplexity DR (42.25).
- Gemini DR had the most effective citations (111.21 avg); Perplexity DR had the highest citation accuracy
  (90.24%) on this benchmark — directly contested by DeepTRACE's 97.5%-unsupported finding.
- OpenAI DR scored highest on instruction-following (49.27).
- Different systems win on different axes: no single system dominates report quality AND citation fidelity.

## Verified Quote(s)

**Location reference:** Leaderboard landing page (methodology summary) and arXiv:2506.11763 abstract.

> "DeepResearch Bench, a benchmark consisting of 100 PhD-level research tasks, each meticulously crafted by
> domain experts across 22 distinct fields."

> "Gemini-2.5-Pro Deep Research achieved an exceptional 111.21 average effective citations, demonstrating
> superior information gathering capabilities."

> "RACE (Reference-based Adaptive Criteria-driven Evaluation) evaluates the qualitative merits of the final
> research report, while FACT (Framework for Factual Abundance and Citation Trustworthiness) assesses the
> agent's proficiency in data retrieval and the accuracy of its citations."

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** The reference benchmark for cross-system comparison; supplies the headline leaderboard and the
key contested data point (Perplexity citation accuracy) that sets up institutional-vs-ground tension.

**Redundancy check:** Unique benchmark. Its Perplexity citation-accuracy figure (90.24%) is in direct tension
with DeepTRACE — flagged as a contested zone rather than reconciled.

**Perspective category:** Academic
