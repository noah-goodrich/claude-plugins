# Source: Sakana AI Scientist-v2 (primary paper)

**Full citation:** Yamada, Y., Lange, R.T., Lu, C., et al. "The AI Scientist-v2: Workshop-Level
Automated Scientific Discovery via Agentic Tree Search." arXiv:2504.08066 / pub.sakana.ai. April 2025.
**URL:** https://pub.sakana.ai/ai-scientist-v2/paper/paper.pdf (also https://arxiv.org/abs/2504.08066)
**Date accessed:** 2026-06-06
**Evidence level:** 5 (Practitioner case study with data — a self-reported system demonstration with a
controlled peer-review experiment, IRB-approved)
**Research topic area:** AI invention & discovery systems — end-to-end autonomous research (generate ->
experiment -> write -> peer review)

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 8 | Sakana AI is a well-funded lab with credentialed ML researchers; not peer-reviewed venue but reputable. |
| 2 | Evidence Quality | 6 | Real controlled experiment (3 manuscripts to a real ICLR workshop, IRB approval) but n=1 acceptance, self-evaluated. |
| 3 | Currency | 10 | April 2025, using 2024-2025 systems. Cutting edge. |
| 4 | Intent | 6 | Education + field advancement, but strong commercial/PR incentive (Sakana sells this capability). |
| 5 | Bias & Objectivity | 6 | Discloses withdrawal arrangement and citation hallucination, but frames the result as a milestone; scored harder (I lean toward "real but overhyped"). |
| 6 | Logic & Coherence | 7 | Architecture and experiment described coherently; the leap from "passed a workshop bar" to "automated discovery" is asserted more than proven. |
| 7 | Corroboration | 7 | Architecture corroborated by GitHub repo + independent press; the "first AI peer-reviewed paper" claim is corroborated but the quality is contested (Beel et al.). |
| 8 | Intellectual Honesty | 7 | Notably honest: discloses the withdrawal agreement, the negative-result nature of the accepted paper, and citation inaccuracies. |
| 9 | Specificity | 9 | Exact scores (6,6,7), exact threshold reasoning, named workshop (ICBINB), IRB number. |
| 10 | Relevance | 10 | Directly the closest prior art to an autonomous "invention primitive." |

**Composite score:** 7.25

## Bias Guard Check

- [ ] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [x] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

(I am skeptical that workshop acceptance equals "scientific discovery," so per the bias guard I scored
dims 5/6/8 more generously than my gut — the paper is actually fairly candid about its own caveats.)

## Key Findings

- The accepted manuscript scored 6, 6, 7 (average 6.33/10, ~top 45% of submissions), the first fully
  AI-generated paper to pass peer review at a workshop — but the accepted paper reported a *negative*
  result ("compositional regularization does not yield significant improvements").
- The architecture is a "progressive agentic tree-search methodology managed by a dedicated experiment
  manager agent," plus a VLM feedback loop for figures — a generate -> experiment -> critique -> refine
  loop, removing v1's reliance on human-authored templates.
- The authors pre-arranged with ICLR leadership and workshop organizers to **withdraw** any accepted
  AI paper; reviewers were told some submissions might be AI-generated and could opt out. The papers
  are not on OpenReview's public forum.
- The authors acknowledge the system "occasionally introduced inaccuracies in citations, similar to the
  well-known 'hallucination' issue" and "sometimes lacked the detailed methodological rigor."

## Verified Quote(s)

**Location reference:** Section 5 "Human Evaluation Study," subsections 3 ("Review Outcomes") and 4
("Post-Review Withdrawal"); and the limitations discussion (final pages, p.13).

> Among the three manuscripts produced by The AI Scientist-v2, one manuscript achieved a sufficiently
> high average reviewer score (6.33 out of 10, with individual scores of 6, 6, and 7) to surpass the
> workshop's acceptance threshold. The remaining two submissions received lower scores and were not
> accepted.

> Prior to the workshop submission, we arranged with the workshop organizers and ICLR leadership that
> any accepted AI-generated manuscripts would be withdrawn after the review process.

> The AI Scientist-v2 occasionally introduced inaccuracies in citations, similar to the well-known
> "hallucination" issue encountered in large language models.

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** Primary source for the single most-cited "AI passed peer review" milestone and the
canonical generate -> experiment -> write loop. Authority + Specificity + Relevance carry it.

**Redundancy check:** Adds the exact scores and the withdrawal/consent detail that secondary coverage
garbles. Not superseded by anything.

**Perspective category:** Institutional
