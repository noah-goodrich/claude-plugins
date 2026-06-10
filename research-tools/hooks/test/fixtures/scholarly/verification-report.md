# Independent Blind Citation Verification Report

**Synthesis agent ID:** synth-scholarly-fixture-a
**Verifier agent ID:** verify-scholarly-fixture-b
**Date:** 2026-06-06

## Sample Selection

3 cards sampled from 3 total on disk (100% — all cards verified, fewer than 10 total).
Each quote was checked against its fetch-time abstract snapshot under `snapshots/`.

## Per-Card Results

| Card | Outcome | Note |
|------|---------|------|
| scholarly-01-open-corpus-feeds-cards.md | verified | Quote present verbatim in snapshot. |
| scholarly-02-keyless-default-backend.md | verified | Quote present verbatim in snapshot. |
| scholarly-03-swappable-corpus.md | verified | Quote present verbatim in snapshot. |

## Aggregate

| Outcome | Count |
|---------|-------|
| Verified | 3 |
| Failed | 0 |
| Inaccessible | 0 |
| **Sample total** | **3** |

## Failure Rate and Band

- **Failure count:** 0
- **Failure-rate band:** <=5%

## Inclusion Cut

Excluded | 1

One abstract-less OpenAlex hit was excluded at the adapter step. The lowest-scoring source
that cleared the bar is `scholarly-03-swappable-corpus.md` — named so the marginal keep is owned.
