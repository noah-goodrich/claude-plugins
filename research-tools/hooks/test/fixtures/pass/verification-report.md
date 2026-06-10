# Independent Blind Citation Verification Report

**Phase:** Deep-research Phase 3.5 (independent, blind citation verification)
**Synthesis agent ID:** synth-a1b2c3
**Verifier agent ID:** verify-z9y8x7
**Date:** 2026-06-06

## Sample Selection

3 cards sampled from 3 total on disk (100% — all cards verified, fewer than 10 total).

## Per-Card Results

| Card | Outcome | Note |
|------|---------|------|
| t1-example-alpha.md | verified | Quote found character-for-character at source; attribution matches. |
| t2-example-beta.md | verified | Quote confirmed verbatim in abstract; location accurate. |
| t3-example-gamma.md | inaccessible | Card self-flagged cached/partial; scanned PDF the fetcher cannot parse. |

## Aggregate

| Outcome | Count |
|---------|-------|
| Verified | 2 |
| Failed | 0 |
| Inaccessible | 1 |
| **Sample total** | **3** |

## Failure Rate and Band

- **Failure rate = failed / (verified + failed) = 0 / (2 + 0) = 0.0%**
- **Failure-rate band: ≤5%**

Inaccessible cards are excluded from the denominator per the rubric.

## Inclusion Cut

No source was excluded in this run. The lowest-scoring source that cleared the bar is
`t2-example-beta.md` (borderline band) — named here so the marginal keep is owned rather
than hidden.
