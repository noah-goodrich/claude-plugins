# Source: PaperQA2 — Language Agents Achieve Superhuman Synthesis of Scientific Knowledge

**Full citation:** Skarlinski, Michael D., et al. (FutureHouse). "Language agents achieve superhuman synthesis
of scientific knowledge." arXiv:2409.13740. 2024.
**URL:** https://arxiv.org/html/2409.13740v2
**Date accessed:** 2026-06-06
**Evidence level:** 3 (Benchmark study with statistical comparison vs human experts on LitQA2)
**Research topic area:** Architecture (RAG + citation traversal) + strengths/limitations of academic research agents

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 8/10 | FutureHouse research lab (Andrew White et al.); arXiv preprint, strong ML+science credentials. |
| 2 | Evidence Quality | 8/10 | Statistical test vs human annotators on LitQA2; reported with confidence intervals. |
| 3 | Currency | 8/10 | Sept 2024; slightly older than the 2025 commercial-system cohort but methodologically current. |
| 4 | Intent | 5/10 | First-party announcement of own system; "superhuman" framing has promotional incentive. |
| 5 | Bias & Objectivity | 6/10 | "Superhuman" headline; partially mitigated by candid limitations. Scored harder (agree it's impressive). |
| 6 | Logic & Coherence | 8/10 | Precision/accuracy claims map cleanly to reported stats; distinguishes precision from accuracy. |
| 7 | Corroboration | 6/10 | RAG-QA Arena SOTA claim self-corroborated; independent benchmarking thinner than commercial systems. |
| 8 | Intellectual Honesty | 8/10 | Acknowledges ContraCrow overconfidence, model-size sensitivity, infra dependency in open version. |
| 9 | Specificity | 9/10 | Exact precision (85.2%), accuracy (66.0%), human baselines, t-statistics, named tools. |
| 10 | Relevance | 9/10 | Directly addresses open/academic deep-research agent architecture and its limits. |

**Composite score:** 7.55

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- PaperQA2 is a RAG agent with four tools: Paper Search (Semantic Scholar), Gather Evidence (dense retrieval +
  reranking + contextual summarization), Generate Answer, and Citation Traversal (walks references + citers).
- On LitQA2 it achieved 85.2% precision (vs human 73.8%) — "superhuman precision" — but 66.0% accuracy, which did
  NOT differ significantly from humans (67.7%). The superhuman claim is precision-only, not accuracy.
- "Superhuman" is bounded: it matches, not exceeds, experts on accuracy; smaller models degrade results below
  using no model at all for summarization.
- ContraCrow (contradiction detection) overconfidence drove disagreement with human annotators (60.4% agreement
  vs 75.5% human-human).
- The open-source version lacks GROBID parsing, non-local full-text search, and citation traversal without
  institutional infrastructure — a reproducibility caveat.

## Verified Quote(s)

**Location reference:** Section 2 (Results / LitQA2); Section 5 (ContraCrow); Section 8.1 (open-source limits).

> "PaperQA2 thus achieved superhuman precision on this task (t(8.6)=3.49,p=0.0036) and did not differ
> significantly from humans in accuracy"

> "Smaller models (GPT-3.5-Turbo (RCS), Llama3 (70B)) decrease overall accuracy when used for RCS, relative to
> not using a model at all."

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** Best primary source for open/academic research-agent architecture; the precision-vs-accuracy
distinction is a load-bearing nuance against over-reading "superhuman" headlines.

**Redundancy check:** Unique architecture (citation-graph traversal RAG) not covered by commercial sources;
complements Undermind/Elicit ground evidence.

**Perspective category:** Practitioner

(Secondary note: borders Academic; primary category is Practitioner — a lab announcing its own deployed system.)
