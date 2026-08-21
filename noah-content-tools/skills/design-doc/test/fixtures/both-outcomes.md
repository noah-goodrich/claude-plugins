# Directive: Nightly Index Rebuild

*Filed: 2026-08-20 · Status: Proposed*

**tl;dr** — The search index rebuild stalls checkout for four minutes a day. Move it to a nightly job with a shadow
index and cut the stall to zero.

## Problem

The rebuild holds a table lock for 3m50s on average and fires at 14:00 UTC, mid-checkout.

## Solution

Build into a shadow index, then swap the alias atomically.

## Goals

- Checkout latency during rebuild is indistinguishable from baseline.

## Acceptance criteria

- [ ] AC1 A rebuild triggered under synthetic checkout load shows no p99 regression.
  - Verify: `bash bench/checkout-p99.sh --during-rebuild`.

## Non-Goals

- Not replacing the indexing engine.

## Alternatives Considered

- **Incremental updates.** Rejected: the engine's delta path corrupts facet counts.
