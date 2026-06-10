# Source: Hacker News discussion — "Don't Build Multi-Agents"

**Full citation:** Hacker News community thread on Cognition's "Don't Build Multi-Agents."
news.ycombinator.com, item 45096962. 2025.
**URL:** https://news.ycombinator.com/item?id=45096962
**Date accessed:** 2026-06-06
**Evidence level:** 8 (Anecdotal / practitioner first-person accounts in a public forum)
**Research topic area:** Boots-on-the-ground experience with single- vs multi-agent in production

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 3/10 | Pseudonymous practitioners; can't verify credentials, but evidently hands-on builders. |
| 2 | Evidence Quality | 3/10 | Anecdotal single-case reports; no measurement. |
| 3 | Currency | 10/10 | 2025 thread on the current debate. |
| 4 | Intent | 8/10 | Peer discussion; no product to sell, sharing lived experience. |
| 5 | Bias & Objectivity | 7/10 | Thread contains both pro- and anti-multi-agent voices; genuinely mixed. Scored generously — diverges from my lean. |
| 6 | Logic & Coherence | 6/10 | Individual comments reason from one project each; sound but narrow. |
| 7 | Corroboration | 7/10 | The "subagents protect context for read/review" point matches Anthropic and the recipe-finder case. |
| 8 | Intellectual Honesty | 7/10 | Commenters hedge ("a win here," "for this case") rather than overclaim. |
| 9 | Specificity | 6/10 | Concrete use cases (recipe finder, SMS formatter, reviewer agents); no metrics. |
| 10 | Relevance | 8/10 | Real-world reconciliation of when multi-agent helps vs hurts. |

**Composite score:** 4.90

## Bias Guard Check

- [ ] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [x] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

(The thread is more pro-subagent than my lean toward the contrarian case, so I scored its objectivity
and honesty more generously.)

## Key Findings

- Practitioners converge on a use-pattern split: subagents help by ISOLATING context for read/search
  and review tasks; they hurt when delegating write/build work (matches Cognition + Anthropic).
- A concrete win: a recipe-finder where a search subagent kept noisy results out of the main agent's
  context, improving the main agent's downstream formatting ("More context is not always better!").
- The "fresh context reviewer" pattern — a subagent whose context isn't poisoned by the caller's
  prior decisions — is cited as a genuine, repeatable benefit for critical feedback.
- Counter-voice: agents are "really unreliable employees... a waste of time to delegate to them,"
  favoring tight human supervision over autonomous delegation.

## Verified Quote(s)

**Location reference:** Top-level comments in the thread (commenters colonCapitalDee, adastra22,
worik).

> "Using this sub-agent to prevent information from entering the context dramatically improved the
> quality of responses. More context is not always better!" (colonCapitalDee)

> "The subagent trials and deliberations don't poison the caller's context [this is a win here]"
> (adastra22)

> "Agents are like really unreliable employees...it's a waste of time to delegate to them." (worik)

**Access status:** cached/partial (HN page returned 403 on direct WebFetch; quotes captured via the
fetch tool's earlier successful read of the rendered comments and not re-verifiable in-place at audit
time)

## Inclusion Decision

**Decision:** Supporting
**Rationale:** The required boots-on-the-ground voice. Low credibility individually, but it
triangulates the institutional/academic claims into a practical heuristic (isolate-for-read,
single-thread-for-write) and supplies a genuine counter-voice.

**Redundancy check:** Adds lived nuance not in the formal sources — the context-isolation benefit and
the "unreliable employee" skepticism. Not superseded.

**Perspective category:** Boots-on-the-ground
