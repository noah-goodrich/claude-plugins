# Directive: Nightly Index Rebuild

*Filed: 2026-08-20 · Status: Proposed*

**tl;dr** — The search index rebuild stalls checkout for four minutes a day. Move it to a nightly job with a shadow
index and cut the stall to zero.

## Problem

The rebuild holds a table lock for 3m50s on average and fires at 14:00 UTC, mid-checkout.

## Solution

Build into a shadow index, then swap the alias atomically.

## Non-Goals

- Not replacing the indexing engine.
- Not touching the ranking model.

## Alternatives Considered

- **Incremental updates.** Rejected: the engine's delta path corrupts facet counts.
- **Just move the cron.** Rejected: keeps the lock, so a manual rebuild still takes the site down.
