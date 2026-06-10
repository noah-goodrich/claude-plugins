# Citation Verification Report

**Synthesis agent ID:** synth-bp-1
**Verifier agent ID:** verify-bp-2
**Date:** 2026-06-06

## Sample Selection

3 cards sampled from 3 total on disk (100%).

## Per-Card Results

| Card | Outcome | Note |
|------|---------|------|
| p1-card.md | verified | Quote confirmed verbatim. |
| p2-card.md | verified | Quote confirmed verbatim. |
| p3-card.md | verified | Quote confirmed verbatim; perspective label is non-canonical. |

## Aggregate

| Outcome | Count |
|---------|-------|
| Verified | 3 |
| Failed | 0 |
| Inaccessible | 0 |
| **Sample total** | **3** |

## Failure Rate and Band

- **Failure count:** 0
- **Failure-rate band:** ≤5%

## Inclusion Cut

Excluded | 1

Every assertion passes EXCEPT Assertion 11: p3 carries the hybrid value
`Academic/Institutional`, which is outside the five-value perspective enum.
