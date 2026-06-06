# Directive 06 — Optional Scholarly-Source Adapter (OpenAlex / Semantic Scholar)

**Priority:** 06 · **Axis:** (c) Distribution / reach + evidence-floor support · **Feasibility:** Medium
**Depends on:** Directives 01–02 (do not widen the corpus before the gate that grades it is real and fail-closed)

---

## Goal

Add a thin, first-party adapter that pulls peer-reviewed abstracts + DOIs from a free CC0 scholarly backend into the
SAME inspectable source-card pipeline — closing the no-web-scale-corpus gap without an unwinnable indexing war and
without third-party MCP supply-chain risk in a trust-first methodology.

## Context (audit findings resolved)

- **No web-scale corpus** (`audit.md:201-206`). Discovery rides the host's general WebSearch/WebFetch, bounded to
  hundreds of consumer-web results, while Elicit indexes 138M+ papers and Consensus runs quality-filtered academic
  search. The paywall-surfacing protocol is an honest admission of the limit — "we ask the human to buy what we cannot
  reach." The fix is explicitly **not** to out-index Elicit; it is to add an optional adapter for a free scholarly
  source so Phase 2 can pull abstracts into the same card pipeline (academic reach plus inspectable cards).
- This also directly raises the **thin-primary-evidence floor** (Pattern 1, `audit.md:305-325`): peer-reviewed sources
  become cheap to card, lifting the Level-1/Level-2 share that today sits at 0–15% across the corpus.

This is the audit's recommendation #10 (`audit.md:453-456`). Per the council, prefer a **first-party HTTP adapter over
a third-party MCP** to keep the trust story clean (no unaudited code in a trust-first pipeline). OpenAlex (250M+ works,
CC0, keyless) is the strongest proof-point that open+transparent beats paid+black-box — it materially defeated paid
Scopus (Sorbonne deregistration, Dec 2023) — and needs no secret to demo. Semantic Scholar (200M+ papers, keyless but
globally throttled) is the fallback.

## Acceptance Criteria

- [ ] A thin **first-party adapter** (no third-party MCP) calls a keyless scholarly HTTP API and returns abstract +
      DOI + open-access PDF link.
- [ ] **OpenAlex is the default backend**; Semantic Scholar is the documented fallback (its keyless path is
      globally throttled, so it cannot be default).
- [ ] Pulled results flow into the **standard source-card template** — no backend-specific fields. The card schema
      stays **backend-AGNOSTIC** so the corpus remains swappable and the open-corpus advantage never becomes new
      lock-in.
- [ ] A **Phase 2 routing paragraph**: academic/clinical → OpenAlex; AI/ML/CS → Semantic Scholar; general web →
      WebSearch.
- [ ] The adapter **snapshots what it pulls** (abstract text at fetch time) so the Directive 01 verifier can check the
      card against the snapshot, consistent with the ground-ledger contract.
- [ ] `README.md` states the boundary honestly: "We are not Elicit-scale; this adds a free academic backend, not a
      138M-paper index" (`audit.md:204-206`).
- [ ] The adapter is **optional** — the pipeline runs unchanged with zero scholarly backend configured (no new hard
      dependency, no secret required to run the base pipeline).
- [ ] Smoke-test: a clinical/academic Phase 2 query routes to OpenAlex, returns ≥3 carded abstracts with DOIs, and the
      cards pass the Directive 01 verifier.
- [ ] All network/build/test steps run inside the devcontainer via `drone exec`.

## Estimate

**2–3 sessions.** ~1 session: the first-party OpenAlex HTTP adapter + snapshotting. ~0.5–1 session: Phase 2 routing +
schema-preserving ingestion into the card template. ~0.5–1 session: Semantic Scholar fallback + README boundary note +
smoke test against the verifier.
