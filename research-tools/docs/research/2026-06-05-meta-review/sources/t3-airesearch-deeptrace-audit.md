# Source: DeepTRACE — Auditing Deep Research AI Systems for Reliability Across Citations and Evidence

**Full citation:** Venkit, Pranav Narayanan, et al. (Salesforce AI Research). "DeepTRACE: Auditing Deep Research
AI Systems for Tracking Reliability Across Citations and Evidence." arXiv:2509.04499. 2025.
**URL:** https://arxiv.org/html/2509.04499v1
**Date accessed:** 2026-06-06
**Evidence level:** 3 (Large-scale systematic audit / observational study across many systems and queries)
**Research topic area:** Measured limitations — unsupported claims, one-sidedness, citation accuracy

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 8/10 | Salesforce AI Research team; arXiv preprint, not yet peer-reviewed, but credentialed industrial lab. |
| 2 | Evidence Quality | 8/10 | Systematic audit with a defined metric framework across multiple commercial systems and debate queries. |
| 3 | Currency | 10/10 | September 2025; covers GPT-5(DR), Perplexity DR, current generation. |
| 4 | Intent | 8/10 | Academic-style audit; no product to sell; public-interest framing. |
| 5 | Bias & Objectivity | 8/10 | Audits all systems with the same yardstick incl. its preferred GPT-5(DR); discloses metric definitions. |
| 6 | Logic & Coherence | 8/10 | Metric-to-finding chain is explicit; flags where calibration is achievable. |
| 7 | Corroboration | 8/10 | techxplore + wizcase + naturalnews secondary coverage; aligns with DeepResearch Bench citation gaps. |
| 8 | Intellectual Honesty | 7/10 | Notes near-ideal reliability IS achievable (GPT-5 DR); preprint caveat not heavily dwelt on. |
| 9 | Specificity | 9/10 | Exact percentages per system: 47% (GPT-4.5), 97.5% (PPLX DR), 83%+ one-sided (Perplexity). |
| 10 | Relevance | 10/10 | Directly measures the failure modes (hallucinated/unsupported citations, one-sidedness) at the track's core. |

**Composite score:** 8.30

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- Deep research / generative search engines include large fractions of statements unsupported by their own
  listed sources, and skew one-sided + overconfident on debate queries.
- Perplexity's deep research agent had 97.5% of its claims unsupported by its cited sources — the worst measured.
- OpenAI GPT-4.5 produced 47.0% unsupported statements; Perplexity generated one-sided responses in over 83% of
  debate queries.
- One-sidedness across systems ran roughly 50-80%; citation accuracy for some systems was only 40-80%.
- GPT-5 in research mode (GPT-5(DR)) was closest to balanced + well-supported, showing near-ideal reliability is
  attainable — the failures are not intrinsic to the paradigm.

## Verified Quote(s)

**Location reference:** Abstract and Results section (per-system %Unsupported Statements table); secondary
corroboration in techxplore.com 2025-09 coverage.

> "Perplexity performing worst, generating one-sided responses in over 83% of debate queries"

> "include large fractions of statements unsupported by their own listed sources"

Secondary corroboration (techxplore.com, "A new study finds AI tools are often unreliable, overconfident and
one-sided," 2025-09):

> "For OpenAI's GPT 4.5, the figure was 47%."

> "about one-third of the statements made by AI tools like Perplexity, You.com and Microsoft's Bing Chat were
> not supported by the sources they provided."

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** Supplies the track's strongest contrarian / measured-limitation evidence with named percentages.
The 97.5%-unsupported finding is a load-bearing, adversarially-testable claim. Triangulated by secondary press.

**Redundancy check:** Unique — only systematic multi-system audit quantifying unsupported statements and
one-sidedness on the same yardstick.

**Perspective category:** Contrarian
