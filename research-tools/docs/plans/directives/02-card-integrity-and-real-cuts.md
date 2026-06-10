# Directive 02 — Card-Integrity Hardening + Real Cuts

**Priority:** 02 · **Axis:** (b) Methodological depth · **Feasibility:** High · **Depends on:** Directive 01

---

## Goal

Extend the no-model verifier and the card-write contract to close the gameable failure-rate loopholes and force the
scoring rubric to actually reject — so a card lacking the canonical enum auto-fails, an inaccessible reclassification
cannot be set retroactively, and every run either cuts a source or names the lowest one that cleared the bar.

## Context (audit findings resolved)

- **The 5% gate is gameable by reclassifying failed cards as inaccessible — reveal did exactly this**
  (`audit.md:35-40,146-154`). Inaccessible cards are excluded from the denominator; the skill itself blesses it as
  remediation path #3 (`SKILL.md:250-253`). The reveal s11 card carries no `Access status:` enum yet the report
  claimed `cached/partial` and scored it `inaccessible`, holding the rate at 0% when the honest rate is 25%.
- **Source-card template compliance is unverified — non-canonical Access fields and quote headings ship**
  (`audit.md:156-173`). Only 4 of 8 reveal cards carry any `Access status:` field; s11 substitutes a freeform line and
  uses a singular `## Verified Quote` heading; the portrait analysis uses bespoke perspective categories outside the
  five-value enum (`source-card-template.md:83-87`).
- **The verification band is reported in non-compliant formats and under-sampled** (`audit.md:137-144`): personalization
  shipped a `≤20% partial-or-failed at sample size 5` band (not a legal band, 4× the threshold) and sampled
  5/53 ≈ 9% against the mandated 30%, weighting toward "highest-leverage claims" — the exact weighting the skill forbids
  (`SKILL.md:204-207`).
- **The 10-dimension weighted rubric implies false precision and never rejects anything** (`audit.md:270-276`):
  agent-teams included 16/16 sources, 0 excluded, every score in a comfortable 5.5–8.65 band — the inclusion
  decision is made on vibes and the score back-filled to justify it.

This is the audit's recommendation #1 (extensions), #3, and #9 (`audit.md:404-409,417-421,449-451`). It rides the
same no-model script and ground-ledger contract Directive 01 builds — extending, not duplicating.

## Acceptance Criteria

- [ ] Verifier adds an assertion: verification **sample is ≥30% of total cards** (rounded up, min 3; all cards if <10
      total) — fails personalization's 9% sample.
- [ ] Verifier adds an assertion: a card **lacking the canonical `Access status:` enum is treated as `failed`**, not
      excluded — fails the reveal s11 reclassification.
- [ ] Verifier adds an assertion: a **quote attributed to a domain other than the card URL is automatic `failed`**
      regardless of access status (resolves `audit.md:227-234`).
- [ ] Verifier adds an assertion: **inaccessible exclusions capped at ~30%** — above the cap, the deliverable is
      stamped `low-confidence`, not `passed` (`audit.md:152-154`).
- [ ] A `cached/partial` flag is honored only if it is documented as existing at synthesis time; **retroactive
      reclassification to lower the rate is rejected** (remediation path #3 in `SKILL.md:250-253` is amended to forbid
      rate-gaming reclassification). Git/mtime provenance proof is NOT required (out of scope per Directive 01) — the
      check is the absence of a retroactive-change note plus the enum-missing-equals-failed rule.
- [ ] Card-write contract enforces the **perspective-category enum** (`Academic` / `Institutional` / `Practitioner` /
      `Boots-on-the-ground` / `Contrarian`) and the literal `## Verified Quote(s)` heading; the verifier fails the
      manifest on any deviation (`source-card-template.md:45,83-87`).
- [ ] Rubric replaces the 2-decimal composite with a **3-bucket band: keep / borderline / reject**; the source card
      template and `source-evaluation-rubric.md` are updated.
- [ ] **Every run must exclude ≥1 source OR explicitly name the lowest-scoring source that cleared the bar**, asserted
      by the verifier against §6 (`audit.md:449-451`).
- [ ] Re-run against reveal (s11 reclassification, non-enum cards) and personalization (9% sample, non-canonical band)
      fixtures → both FAIL on the new assertions.
- [ ] All tests run inside the devcontainer via `drone exec`.

## Estimate

**1–1.5 sessions.** ~0.5 session: the four new no-model assertions on the existing script. ~0.5–1 session: the
3-bucket band + perspective-enum enforcement in the rubric/template + the "name a real cut" assertion, tested against
the reveal/personalization fixtures.
