# Directive: Nightly Index Rebuild

*Filed: 2026-08-20 · Status: Proposed · Parent: 2026-08-01-search-program.md*

**tl;dr** — The search index rebuild runs during business hours and stalls checkout for four minutes a day. Move it
to a nightly job with a shadow index and cut the stall to zero.

## Problem

The rebuild holds a table lock for 3m50s on average, measured across 14 days of production traces. It fires at
14:00 UTC because that is when the cron was written, not because anything needs it then.

## Solution

Build into a shadow index, then swap the alias. The swap is atomic and takes 40ms. Schedule at 09:00 UTC, the
measured traffic floor.

## Goals

- Checkout latency during rebuild is indistinguishable from baseline.
- One command triggers an out-of-band rebuild when someone needs one.

## Non-Goals

- Not replacing the indexing engine.
- Not touching the ranking model.

## Alternatives Considered

- **Incremental updates.** Rejected: the engine's delta path corrupts facet counts, which is the open upstream bug
  that started this.
- **Just move the cron.** Rejected: it removes the daytime stall but keeps the lock, so any manual rebuild still
  takes the site down.
