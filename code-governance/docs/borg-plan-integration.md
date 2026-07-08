# Proposal: Wire `reconcile-req` into `borg-plan` as a pre-lock reuse gate

**Status:** PROPOSAL ONLY. This document describes a change; it does NOT make one. `borg-plan/SKILL.md` is unmodified.
**Owner decision required:** Noah, before any edit to `borg-plan`.

---

## ELI10

`borg-plan` walks you through defining a project: it proposes an objective, then acceptance criteria, then how to verify
them, then it writes `PROJECT_PLAN.md` and **locks** the criteria (The Lock Rule). Today, nothing checks whether the
thing you are about to build *already exists* in the codebase before those criteria lock. So a criterion like "add a
requeue path" can lock even though a `requeue_pipeline_run` RPC already exists — and now you have two write paths that
drift. This proposal inserts one step: right after you confirm the criteria and right before they lock, `reconcile-req`
loads the capability index and tells you, per criterion, "you already have this (REUSE)", "you have most of it
(EXTEND)", "this fights an existing rule (REFACTOR)", or "this is new (NET-NEW)". Gaps become explicit criteria or named
risks instead of silent assumptions baked into a locked plan.

## ELI5

Before you promise to build something, the robot checks the toy box to see if you already own it.

---

## Exact hook point

`borg-plan/SKILL.md` runs a numbered conversation:

- `### 1. Propose the Objective`
- `### 2. Propose Acceptance Criteria` — ends when the user confirms the full criteria list.
- `### 3. Propose Verification`
- ... (Scope, Ship, Timeline, Risks) ...
- `## The Lock Rule` — once `PROJECT_PLAN.md` is written, criteria cannot change without "I'm changing scope."

**Insert the reconcile gate between Step 2 and Step 3.** At that moment `borg-plan` has (a) the confirmed criteria text
and (b) an already-read codebase — everything the gate needs. It fires before verification (so reuse findings can
change *how* a criterion is verified) and well before `PROJECT_PLAN.md` is written under The Lock Rule, so any gap
surfaces
while the criteria are still editable.

## What the inserted step does

For each confirmed acceptance criterion, treat the criterion as a REQUIREMENT and run `reconcile-req`:

1. Load the project capability index (`docs/capability-index/capability-index.json`; run `capability-index` first if
   absent).
2. Classify existing capabilities against the criterion: FULLY-MEETS / PARTIALLY-MEETS / CONFLICTS-WITH / NULLIFIES.
3. Run the Phase-3 standards checks (golden-fixture literals, no self-comparison, hotspot-from-risk-tool, bounded
   convergent loops, transient-vs-permanent error classing, RPC-not-raw-UPDATE state transitions, alerting monitors).
4. Emit the REUSE MAP and ask the one question: **"Address now, or note as a scope risk?"**

The answer folds back into `borg-plan`'s existing flow:
- **REUSE / NULLIFIES** → the criterion may be redundant or should be reworded to "call the existing capability";
  adjust before Step 3.
- **EXTEND / REFACTOR** → the criterion stays but its verification (Step 3) targets the existing single source of
  truth, not a new parallel path.
- **NET-NEW** → proceed unchanged; the standards checks may still add a regression criterion.
- **Deferred gaps** → captured verbatim into `### 7. Flag Risks` so they are on record, not silent.

## Why before the lock, not after

The Lock Rule exists so criteria stop moving once written. That is exactly why the reuse check must run *before* it: a
gate that fires after the lock can only file scope-change requests. Firing before the lock means a "you already have
this" finding costs one edit to a still-fluid list instead of a scope reset. This directly targets the fragmented
-write-path / duplicate-capability failure mode — it makes reuse the default *at the moment the plan commits*.

## Proposed edit (for a FUTURE, separately-approved change — not applied here)

A single new subsection in `borg-plan/SKILL.md`, e.g. `### 2b. Reconcile Against Existing Capabilities`, placed between
Steps 2 and 3, that invokes the `reconcile-req` skill on the confirmed criteria and routes its REUSE MAP back into the
flow as described above. No existing step is rewritten; the numbering simply gains a `2b`. Optionally add one line to
`## The Lock Rule` noting that criteria should not lock with an unaddressed CONFLICTS-WITH / NULLIFIES finding
outstanding.

## Scope boundaries of this proposal

- Does **not** modify `borg-plan` or any skill. Proposal only.
- Does **not** build the cairn wiring (`reconcile-req` specifies that interface as a design note).
- Does **not** make the gate blocking — it is advisory and always ends at a guided human call, consistent with
  `borg-plan`'s "propose, then confirm" style.
