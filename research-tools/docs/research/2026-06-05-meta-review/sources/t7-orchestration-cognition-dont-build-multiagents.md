# Source: Cognition — "Don't Build Multi-Agents"

**Full citation:** Cognition AI (Walden Yan). "Don't Build Multi-Agents." cognition.ai/blog. 2025.
**URL:** https://cognition.ai/blog/dont-build-multi-agents
**Date accessed:** 2026-06-06
**Evidence level:** 7 (Expert Opinion / Thought Leadership — practitioner principles, not formal study)
**Research topic area:** Contrarian case against multi-agent orchestration

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 8/10 | Cognition builds Devin, a production coding agent; deep hands-on agent-architecture credibility. |
| 2 | Evidence Quality | 4/10 | Argument-by-illustration (Flappy Bird scenario); principles asserted, not benchmarked. |
| 3 | Currency | 10/10 | 2025 essay on a fast-moving topic; directly current. |
| 4 | Intent | 5/10 | Thought leadership that also markets Cognition's single-agent product philosophy. |
| 5 | Bias & Objectivity | 6/10 | Clear single-agent thesis; concedes read-tasks parallelize, but mostly one-directional. Scored harder — I partly agree. |
| 6 | Logic & Coherence | 8/10 | Two principles → fragility conclusion is a tight, well-reasoned chain. Scored harder (agree). |
| 7 | Corroboration | 7/10 | Echoed by Wang et al. 2024 (single agent matches discussion) and HN practitioners. |
| 8 | Intellectual Honesty | 6/10 | Frames as "2025 tech" caveat; but presents fragility as near-certain. Scored harder (agree). |
| 9 | Specificity | 6/10 | Concrete Flappy Bird example and two named principles; no metrics. |
| 10 | Relevance | 10/10 | Directly answers "is multi-agent hype?" — the contrarian anchor of the track. |

**Composite score:** 6.85

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- Two architecture principles: "Share context, and share full agent traces, not just individual
  messages" and "Actions carry implicit decisions, and conflicting decisions carry bad results."
- Parallel subagents fail because decision-making is dispersed and context isn't shared thoroughly,
  producing mutually inconsistent outputs (the Flappy Bird Mario-graphics example).
- Single-threaded linear agents are the recommended default for 2025 because "the context is
  continuous."
- This is a principled argument, not a measured study — it is the strongest articulation of the
  contrarian case but rests on reasoning + anecdote, not benchmarks.

## Verified Quote(s)

**Location reference:** Principles stated in the article body (the two bolded principle lines);
thesis sentence in the section explaining why multi-agent systems are fragile.

> "Share context, and share full agent traces, not just individual messages"

> "Actions carry implicit decisions, and conflicting decisions carry bad results"

> "The decision-making ends up being too dispersed and context isn't able to be shared thoroughly
> enough between the agents."

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** This is the named contrarian source the track requires. Its principles are the
sharpest framing of why naive multi-agent parallelization fails, and they reconcile cleanly with
the academic critiques and the practitioner evidence.

**Redundancy check:** Unique — no other source frames the failure mode as a context/decision-sharing
violation with named principles. Not superseded.

**Perspective category:** Contrarian
