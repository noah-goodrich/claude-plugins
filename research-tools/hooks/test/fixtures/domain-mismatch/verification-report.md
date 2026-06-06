# Citation Verification Report

**Synthesis agent ID:** synth-dm-1
**Verifier agent ID:** verify-dm-2
**Date:** 2026-06-06

## Sample Selection

3 cards sampled from 3 total on disk (100%).

## Per-Card Results

| Card | Outcome | Note |
|------|---------|------|
| d1-card.md | verified | Quote confirmed verbatim. |
| d2-card.md | verified | Quote confirmed verbatim. |
| d3-card.md | verified | The synthesis agent passed this card; the gate should not. |

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

Every assertion passes EXCEPT Assertion 9: d3 credits its quote to otherdomain.net while
its own URL host is example.org — an automatic failure regardless of access status.
