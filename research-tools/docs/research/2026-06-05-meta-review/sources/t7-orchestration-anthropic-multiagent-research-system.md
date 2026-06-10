# Source: Anthropic — "How we built our multi-agent research system"

**Full citation:** Anthropic. "How we built our multi-agent research system." anthropic.com/engineering. 2025.
**URL:** https://www.anthropic.com/engineering/multi-agent-research-system
**Date accessed:** 2026-06-06
**Evidence level:** 5 (Practitioner Case Study with Data — internal eval results reported)
**Research topic area:** Institutional case for multi-agent orchestration (orchestrator-worker)

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 9/10 | Anthropic's own engineering team reporting on a shipped production research feature. |
| 2 | Evidence Quality | 5/10 | Internal eval with real numbers, but non-public benchmark, no external replication. |
| 3 | Currency | 10/10 | 2025 engineering post; current. |
| 4 | Intent | 4/10 | Engineering blog that also markets Claude's Research product and the multi-agent approach. |
| 5 | Bias & Objectivity | 6/10 | Notes 15x token cost and failure modes; but vendor showcasing its own win. Scored generously — I am skeptical of the headline. |
| 6 | Logic & Coherence | 8/10 | Clear orchestrator-worker rationale tied to parallelizable read tasks. |
| 7 | Corroboration | 6/10 | Token-scaling claim and read-task parallelism corroborated by HN practitioners; 90.2% is uncorroborated. |
| 8 | Intellectual Honesty | 7/10 | Explicitly states multi-agent is wrong for many tasks and costs 15x tokens. |
| 9 | Specificity | 8/10 | Concrete numbers: 90.2% over single-agent, 15x tokens, 80% variance from token usage. |
| 10 | Relevance | 10/10 | The institutional pro-multi-agent anchor; directly on-question. |

**Composite score:** 7.30

## Bias Guard Check

- [ ] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [x] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- Orchestrator-worker architecture: a lead agent plans, spawns 3–5 parallel specialized subagents,
  and synthesizes with a separate citation pass.
- The multi-agent system (Opus 4 lead + Sonnet 4 subagents) outperformed single-agent Opus 4 by
  90.2% on Anthropic's internal research eval.
- Multi-agent uses ~15x the tokens of chat; token usage alone explains 80% of performance variance.
  Economics only justify multi-agent on high-value, heavily-parallelizable tasks.
- Crucially, this validates multi-agent specifically for READ/breadth tasks (parallel search),
  consistent with — not contradicting — Cognition's warning against parallelizing WRITE tasks.

## Verified Quote(s)

**Location reference:** Results section (the 90.2% figure) and the economics section (token usage).

> "a multi-agent system with Claude Opus 4 as the lead agent and Claude Sonnet 4 subagents
> outperformed single-agent Claude Opus 4 by 90.2% on our internal research eval"

> "multi-agent systems consume 15× more tokens than chats"

> "token usage by itself explains 80% of the variance"

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** The strongest institutional/practitioner data point FOR multi-agent. The 90.2% number
is load-bearing but vendor-internal, so it must be triangulated (and qualified) against the academic
critiques rather than taken at face value.

**Redundancy check:** Unique — only source with concrete production multi-agent eval numbers and the
token-economics decomposition.

**Perspective category:** Institutional
