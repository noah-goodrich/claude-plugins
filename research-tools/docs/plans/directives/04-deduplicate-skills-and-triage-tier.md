# Directive 04 — De-Duplicate the Skills + Triage / Rapid Tier + Lazy Loading

**Priority:** 04 · **Axis:** (b) Methodological depth + ADHD-fit ergonomics · **Feasibility:** High

---

## Goal

Collapse the two skills' divergent evidentiary standards into one, add a documented triage screen and an HONEST rapid
tier with reduced-guarantee stamps, and load references lazily at the phase that consumes them — so the pipeline stops
taxing every run with a 14k-token wall and stops shipping quietly non-compliant artifacts under time pressure.

## Context (audit findings resolved)

- **brainstorm re-implements a parallel mini-pipeline that diverges from the real one** (`audit.md:191-199`). The two
  skills are sold as a clean split, but brainstorm's lightweight tracks run a second, lower-rigor research process
  whose findings are free-form (no cards, no scoring), so a single brainstorm carries two incompatible evidentiary
  standards side by side. The genuinely good novelty-probe early-termination lives in the wrong skill: a direct
  `/deep-research` has **no** "should I even run this?" gate.
- **brainstorm's evidence-backed track machinery is dead weight — never exercised once** (`audit.md:278-287`). Phases
  2–3 spend ~85 lines on evidence-backed tracks, a 3-query novelty probe, recency bands, early-termination, and a
  recursive `/deep-research` invocation — **0% utilization** across all four brainstorms; the most elaborate sub-system
  in the skill taxes every read.
- **The mandatory 14k-token reference pre-load is a wall, not an on-ramp** (`audit.md:175-181`). A 4-source product
  question and a 65-source clinical synthesis pay the identical entry tax — the activation-energy spike that kills task
  initiation for the project's stated ADHD user model. The Quick Reference table (`SKILL.md:423-432`) already maps
  which reference each phase needs.
- **No lightweight mode and no honest escape valve under time pressure** (`audit.md:183-189`). An all-or-nothing
  protocol under pressure produces a quietly non-compliant artifact (troth: 65 cards, no verification) or a non-start —
  not a smaller *compliant* one.
- **The §1–§7 manifest reliably produces 650–1350-line documents for ~40-line decisions** (`audit.md:261-268`). The
  manifest enforces completeness, not proportionality.

This is the audit's recommendation #6 and #8 (`audit.md:434-447`). It is methodological consolidation, not a feature
add — fewer moving parts is the goal, per the user's "simple = fewest moving parts" preference.

## Acceptance Criteria

- [ ] **Promote the novelty probe into `deep-research` Phase 1** as a universal "is this worth a full run?" gate; a
      direct `/deep-research` now runs the probe first (`audit.md:444-447`).
- [ ] **Unify brainstorm-track findings** with `deep-research`'s minimal source record so a single brainstorm no longer
      carries two incompatible evidentiary standards.
- [ ] **Demote brainstorm's evidence-backed apparatus** (the ~85 lines of tracks, recency bands, recursive
      `/deep-research`) to a **one-line escape hatch**: "if a track's correctness is load-bearing and your model
      knowledge is stale, run `/deep-research` separately and feed its §1–§2 back in." Delete the inline
      novelty-probe/recency apparatus from brainstorm (`audit.md:284-287`).
- [ ] **Document the redundancy** between the two skills in `README.md`.
- [ ] **Triage screen**: apply a fast keep/cut screen to all discovered sources first; full 10-dim cards only to those
      that pass — moving the inclusion cut **before** the expensive scoring (`audit.md:434-438`).
- [ ] **Rapid tier**: a documented "rapid" mode with HONEST reduced guarantees that stamps the artifact `NOT
      INDEPENDENTLY VERIFIED`; rapid caps the deliverable at §1 + §2 + §5 + a short methodology note. The full manifest
      fires only for high-stakes / external-publication runs — document size tied to decision size (`audit.md:266-268`).
- [ ] **Lazy reference loading**: references load at the phase that consumes them (per the Quick Reference table); only
      the card-field skeleton and §1–§7 outline carry inline. The 14k up-front pre-load checkbox wall is removed
      (`audit.md:179-181`).
- [ ] The rapid-tier stamp is the SAME honest-fallback vocabulary as Directive 01 (`UNVERIFIED — self-check only`), so
      the verifier never prints `PASS` on a rapid run.
- [ ] Smoke-test both skills end to end on a real low-stakes question (≤4 sources) and confirm the rapid path produces
      a smaller **compliant** artifact, not a non-compliant full one.

## Estimate

**1.5–2 sessions.** ~1 session: move the novelty probe into deep-research Phase 1, unify the finding shape, demote/
delete brainstorm's dead apparatus, README redundancy note. ~0.5–1 session: triage screen + rapid tier + lazy loading
and end-to-end smoke test.
