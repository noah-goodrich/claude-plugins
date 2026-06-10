# Source: Evaluating Sakana's AI Scientist (independent critique)

**Full citation:** Beel, J., Kan, M.-Y., Baumgart, M. "Evaluating Sakana's AI Scientist for Autonomous
Research: Wishful Thinking or an Emerging Reality Towards 'Artificial Research Intelligence' (ARI)?"
arXiv:2502.14297 (also in ACM SIGIR Forum). February 2025.
**URL:** https://arxiv.org/html/2502.14297v1
**Date accessed:** 2026-06-06
**Evidence level:** 5 (Practitioner case study with data — a structured independent re-evaluation of a
deployed system with quantified failure-mode counts)
**Research topic area:** AI invention & discovery systems — independent verification of autonomous
research claims (the contrarian/critical view)

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 8 | Joeran Beel (Univ. Siegen) and Min-Yen Kan (NUS) are established IR/NLP academics; published in ACM SIGIR Forum. |
| 2 | Evidence Quality | 7 | Hands-on re-run with counted failure modes (5/12 experiments failed, citation counts) — empirical, though n is small. |
| 3 | Currency | 10 | Feb 2025, evaluating the then-current AI Scientist v1. |
| 4 | Intent | 9 | Academic scrutiny / field advancement; no product to sell. |
| 5 | Bias & Objectivity | 8 | Title hedges ("or an Emerging Reality"); credits promise while documenting failures; scored generously per bias guard (I agree with them). |
| 6 | Logic & Coherence | 8 | Failure counts tied directly to verdict; reasoning is traceable. |
| 7 | Corroboration | 8 | Corroborated by IEEE Spectrum quotes (Cong Lu's own admissions) and by Sakana's own v2 limitations section. |
| 8 | Intellectual Honesty | 8 | Acknowledges the system's genuine strengths; doesn't pretend it's useless. |
| 9 | Specificity | 9 | Median 5 citations, 5/34 citations post-2020, 5/12 experiments failed, 4/7 manuscripts with hallucinated numbers. |
| 10 | Relevance | 9 | Directly tests the load-bearing claim of the whole field. |

**Composite score:** 8.05

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

(I share their skepticism, so I scored dims 5/6/8 harder; they still hold up — the paper explicitly
credits the system's promise and avoids a pure hit-piece tone.)

## Key Findings

- The system "cannot critically assess its own results" — it fails to detect methodological flaws or
  logical inconsistencies, which the authors call a "fundamental limitation" making it "unsuitable for
  autonomous scientific inquiry."
- 5 of 12 proposed experiments (~42%) failed to execute due to unresolved coding errors.
- Generated manuscripts were thinly cited (median 5 citations, range 2-9; only 5 of 34 total citations
  from 2020 or later) and 4 of 7 manuscripts contained incorrect or hallucinated numerical results.
- Idea novelty assessment is unreliable because it relies on keyword matching rather than deeper
  synthesis — a literature-review weakness, not just an execution weakness.

## Verified Quote(s)

**Location reference:** Section 2.4 "Conducting Experiments," Section 2.5 "Manuscripts," Section 2.3
"Idea Generation" (arXiv HTML v1).

> These issues reveal a fundamental limitation: the AI Scientist cannot critically assess its own
> results. It fails to detect methodological flaws or logical inconsistencies, making it unsuitable for
> autonomous scientific inquiry.

> References were scarce, with a median of five citations per paper (range: 2-9), mostly outdated; only
> five of the total 34 citations were from 2020 or later.

> Four of seven manuscripts contained incorrect or hallucinated numerical results, with discrepancies in
> hyperparameters and performance metrics.

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** The essential contrarian counterweight. Provides the independent, quantified failure-mode
data that triangulates against Sakana's own (more flattering) framing. Highest composite in the track.

**Redundancy check:** Unique — no other source supplies counted failure rates from a hands-on re-run.

**Perspective category:** Contrarian
