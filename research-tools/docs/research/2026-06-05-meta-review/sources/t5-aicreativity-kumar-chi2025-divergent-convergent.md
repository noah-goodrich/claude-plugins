# Source: Human Creativity in the Age of LLMs — Randomized Experiments on Divergent and Convergent Thinking

**Full citation:** Kumar, Harsh et al. "Human Creativity in the Age of LLMs: Randomized
Experiments on Divergent and Convergent Thinking." *Proceedings of the 2025 CHI Conference on
Human Factors in Computing Systems* (CHI '25). arXiv:2410.03703. DOI: 10.1145/3706598.3714198.
**URL:** https://arxiv.org/html/2410.03703v2 (ACM: https://dl.acm.org/doi/full/10.1145/3706598.3714198)
**Date accessed:** 2026-06-06
**Evidence level:** 2 (Two large pre-registered randomized experiments, n=1,100)
**Research topic area:** AI + creativity — divergent vs convergent thinking; spillover to UNASSISTED
performance and homogenization carryover

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 8/10 | Published at CHI 2025 (premier HCI venue); university HCI researchers. |
| 2 | Evidence Quality | 9/10 | Two pre-registered RCTs, n=1,100, with an explicit unassisted test phase — strong design for causal carryover claims. |
| 3 | Currency | 10/10 | 2024-25, current models; CHI 2025 proceedings. |
| 4 | Intent | 9/10 | Academic; pre-registration signals honest intent. |
| 5 | Bias & Objectivity | 8/10 | Tests multiple AI modalities (answer vs coach) and reports a counterintuitive harm; balanced. Scored harder — I agree with the carryover concern. |
| 6 | Logic & Coherence | 8/10 | Clean exposure→test design isolates spillover; some leaps in mechanism interpretation. |
| 7 | Corroboration | 8/10 | Homogenization carryover aligns with Doshi/Hauser and Deng/Brucks/Toubia; the "worse-when-unassisted" result is more novel. |
| 8 | Intellectual Honesty | 8/10 | Reports null exposure benefits and significant harms; pre-registered, reducing p-hacking risk. |
| 9 | Specificity | 8/10 | Exact p-values (strategies harm p=0.009; convergent guidance harm p=0.005); per-experiment n. |
| 10 | Relevance | 9/10 | Splits the question by divergent vs convergent thinking and adds the under-studied skill-atrophy angle. |

**Composite score:** 8.40

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- Two pre-registered RCTs (n=1,100; ~460 divergent, ~640 convergent) tested AI assistance during an
  exposure phase, then measured UNASSISTED performance in a final test phase.
- During the unassisted phase, participants who had received a "List of Strategies" performed
  SIGNIFICANTLY WORSE than no-AI controls (p=0.009 divergent; p=0.005 convergent guidance) — a
  skill-atrophy / dependency signal, not just a neutral handoff.
- Exposure to LLM assistance "did not enhance participants' originality or fluency in subsequent
  unassisted tasks" — the in-session boost did not transfer.
- HOMOGENIZATION carried over: participants exposed to LLM strategies generated more SIMILAR ideas
  in the test phase even WITHOUT AI present — a durable narrowing effect.
- Implication for an invention engine: AI scaffolding can degrade the human's own divergent and
  convergent capacity afterward; the tool must avoid creating dependency and anchoring.

## Verified Quote(s)

**Location reference:** Abstract and Results, arXiv:2410.03703 HTML.

> We conducted two large pre-registered parallel experiments involving 1,100 participants
> attempting tasks targeting the two core components of creativity, divergent and convergent
> thinking.

> exposure to LLM assistance—whether providing ideas or strategies—did not enhance participants'
> originality or fluency in subsequent unassisted tasks.

> participants who received the List of Strategies performed significantly worse than those with no
> LLM exposure (p = 0.009)

**Access status:** cached/partial — arXiv HTML rendered live for the abstract and quoted lines;
the ACM canonical page returned HTTP 403 at access time.

## Inclusion Decision

**Decision:** Core
**Rationale:** Only source in the track measuring the SPILLOVER to unassisted creativity and the
divergent/convergent split. Surfaces a failure mode (dependency / skill atrophy) distinct from the
collective-diversity story.

**Redundancy check:** Not redundant — adds the temporal/carryover and convergent-thinking dimensions
absent from Doshi/Hauser and the Wharton product work.

**Perspective category:** Academic
