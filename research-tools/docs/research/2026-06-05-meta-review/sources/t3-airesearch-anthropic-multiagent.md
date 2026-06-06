# Source: Anthropic — How we built our multi-agent research system

**Full citation:** Anthropic Engineering. "How we built our multi-agent research system." anthropic.com/engineering.
2025.
**URL:** https://www.anthropic.com/engineering/multi-agent-research-system
**Date accessed:** 2026-06-06
**Evidence level:** 5 (Practitioner case study with data — first-party engineering write-up with internal eval numbers)
**Research topic area:** Architecture (orchestrator-worker) + measured limitations of multi-agent research

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 9/10 | The team that built and ships the production Research feature; deepest possible domain access. |
| 2 | Evidence Quality | 6/10 | Internal eval numbers only; methodology not externally reproducible (Level 5 case study). |
| 3 | Currency | 10/10 | 2025 publication describing a then-current production system. |
| 4 | Intent | 5/10 | Education + recruiting + product positioning; promotional incentive present. |
| 5 | Bias & Objectivity | 7/10 | Unusually candid about failure modes for a vendor blog; still self-favoring on the 90.2% headline. Scored harder (I agree multi-agent helps). |
| 6 | Logic & Coherence | 8/10 | Token-usage-explains-variance argument is internally consistent and well-reasoned. |
| 7 | Corroboration | 7/10 | Orchestrator-worker pattern corroborated by arXiv 2506.18096 survey; token-cost premium widely cited. |
| 8 | Intellectual Honesty | 8/10 | Explicitly names domains where multi-agent is a bad fit and lists concrete early failures. |
| 9 | Specificity | 9/10 | Named models, exact percentages, concrete failure anecdotes (50 subagents, SEO content farms). |
| 10 | Relevance | 10/10 | Directly the canonical primary source for multi-agent deep-research architecture. |

**Composite score:** 7.85

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- Production Research uses an orchestrator-worker pattern: a lead agent (Claude Opus 4) plans and spawns
  specialized subagents (Claude Sonnet 4) that search in parallel and return filtered findings.
- The multi-agent configuration beat single-agent Claude Opus 4 by 90.2% on Anthropic's internal research eval;
  token usage alone explains ~80% of performance variance.
- Multi-agent systems use ~15x more tokens than chat (vs ~4x for single agents) — the core cost/economics caveat.
- Stated unfit domains: tasks needing all agents to share context or with many inter-agent dependencies.
- Concrete early failure modes: spawning 50 subagents for simple queries, endless search for nonexistent sources,
  duplicated work, and a bias toward SEO-optimized content farms over authoritative sources.

## Verified Quote(s)

**Location reference:** Section "Architecture overview for Research" (sentence 1); "Benefits of a multi-agent
system" (performance and token paragraphs).

> "Our Research system uses a multi-agent architecture with an orchestrator-worker pattern, where a lead agent
> coordinates the process while delegating to specialized subagents that operate in parallel."

> "a multi-agent system with Claude Opus 4 as the lead agent and Claude Sonnet 4 subagents outperformed
> single-agent Claude Opus 4 by 90.2% on our internal research eval."

> "agents typically use about 4× more tokens than chat interactions, and multi-agent systems use about 15× more
> tokens than chats."

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** Primary, first-party architecture source; supplies two of the track's load-bearing claims
(orchestrator-worker pattern; 15x token premium). Authority and specificity are top-tier.

**Redundancy check:** Adds the only first-party multi-agent architecture account with internal eval numbers; not
superseded by any survey.

**Perspective category:** Practitioner
