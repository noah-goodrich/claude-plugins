# Directive: Nightly Index Rebuild

*Filed: 2026-08-20 · Status: Proposed · Parent: 2026-08-01-search-program.md*

*Reviewers: search, checkout*

**tl;dr** — The search index rebuild stalls checkout for four minutes a day. Move it to a nightly job with a shadow
index and cut the stall to zero. The title and the italic metadata lines above are the only things allowed to
precede this one.

## Problem

The rebuild holds a table lock for 3m50s on average and fires at 14:00 UTC, mid-checkout.

## Solution

Build into a shadow index, then swap the alias atomically.

## Acceptance criteria

- Checkout p99 during a rebuild is within 5ms of baseline, verified by the load-test job.

## Non-Goals

- Not replacing the indexing engine.

## Alternatives Considered

- **Incremental updates.** Rejected: the engine's delta path corrupts facet counts.
