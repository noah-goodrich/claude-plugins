# Source: Deep Research Agents — A Systematic Examination and Roadmap

**Full citation:** Huang, Yuxuan, et al. "Deep Research Agents: A Systematic Examination And Roadmap."
arXiv:2506.18096. 2025.
**URL:** https://arxiv.org/html/2506.18096v2
**Date accessed:** 2026-06-06
**Evidence level:** 4 (Expert synthesis / survey of the field — closest to a structured-review of architectures)
**Research topic area:** Architecture taxonomy (single vs multi-agent, static vs dynamic, retrieval modes)

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 7/10 | Academic survey team; arXiv preprint; synthesizes the field rather than original measurement. |
| 2 | Evidence Quality | 6/10 | Survey/taxonomy, not primary measurement; quality depends on cited works. |
| 3 | Currency | 9/10 | June 2025; classifies OpenAI DR, Gemini DR, Perplexity, Grok by current design. |
| 4 | Intent | 9/10 | Pure academic field-mapping; no product. |
| 5 | Bias & Objectivity | 8/10 | Even-handed taxonomy; describes tradeoffs of each approach. |
| 6 | Logic & Coherence | 8/10 | Clean orthogonal axes (static/dynamic x single/multi-agent); planning-strategy taxonomy. |
| 7 | Corroboration | 8/10 | Architecture claims align with Anthropic's first-party write-up and vendor docs. |
| 8 | Intellectual Honesty | 8/10 | Devotes a section to open challenges and benchmark misalignment. |
| 9 | Specificity | 7/10 | Names systems and maps them to categories; less specific on per-system numbers. |
| 10 | Relevance | 9/10 | The best single architecture-taxonomy source covering all commercial systems at once. |

**Composite score:** 7.45

## Bias Guard Check

- [ ] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [x] Neutral / no strong reaction

## Key Findings

- Provides the field's architecture taxonomy: static (predefined pipeline) vs dynamic (adaptive planning)
  workflows, crossed with single-agent vs multi-agent execution.
- Planning-strategy taxonomy distinguishes OpenAI DR (Intent-to-Planning: clarify intent first) from Gemini DR
  (Unified Intent-Planning: generate plan then confirm with user).
- Retrieval splits into API-based (low-latency structured: Gemini, Grok, Perplexity) vs browser-based
  (human-like navigation: Manus, AutoAgent).
- Identifies seven open challenges including Fact Checking, Asynchronous Parallel Execution, and Benchmark
  Misalignment ("misalignment between evaluation metrics and practical objectives").
- Confirms OpenAI DR is single-agent; multi-agent designs (Anthropic-style) are a distinct branch.

## Verified Quote(s)

**Location reference:** Section 3.3 "Architecture and Workflow" (3.3.1, 3.3.3); Section 6 "Challenge and Future
Directions" / Abstract.

> "Static workflows rely on manually predefined task pipelines, decomposing research processes into sequential
> subtasks"

> "Dynamic workflows support adaptive task planning, allowing agents to dynamically reconfigure task structures
> based on iterative feedback"

> "Current benchmarks exhibit restricted access to external knowledge, sequential execution inefficiencies, and
> misalignment between evaluation metrics and practical objectives"

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** Supplies the cross-system architecture taxonomy and the API-vs-browser retrieval distinction;
independent academic corroboration of vendor architecture claims.

**Redundancy check:** Adds the unifying taxonomy that no single vendor source provides; complements rather than
duplicates the Anthropic and vendor primaries.

**Perspective category:** Academic
