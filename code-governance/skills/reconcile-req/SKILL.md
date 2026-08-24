---
name: reconcile-req
description: "Reuse gate. Given a REQUIREMENT or acceptance criterion, load the project capability index and classify
  every existing capability against it (FULLY-MEETS / PARTIALLY-MEETS / CONFLICTS-WITH / NULLIFIES), then emit a REUSE
  MAP with a recommended disposition per finding (REUSE / EXTEND / REFACTOR / NET-NEW) for a guided human call. Use this
  skill before writing net-new domain code, when the user says 'do we already have this', 'reconcile this requirement',
  'is there a reuse path', 'reuse gate', 'check for duplication before I build', or before an objective locks in
  borg-plan. Prevents fragmented write paths and duplicate capabilities."
---

# Reconcile Requirement (Reuse Gate)

Before a project spends effort building something, reconcile the REQUIREMENT against what the codebase already exposes.
The failure this prevents is ingle's root cause: fragmented write paths and duplicate capabilities that drift because
nobody checked whether the capability already existed. This skill turns "we already had that" from a post-merge
discovery into a pre-build decision.

Output is a **REUSE MAP** in Noah's decision-doc format, ending in a guided human call — never a silent auto-build.

## When to Run

- Before adding a new domain function, MCP tool, route, or write path — confirm no existing capability covers it.
- Inside `borg-plan`, after acceptance criteria are confirmed but before they lock (see `borg-plan-integration.md`).
- During a scope/estimate review — surface REUSE/EXTEND findings that shrink the work before it is committed.
- When two surfaces are suspected of computing the same derived value independently.

## Inputs

- **REQUIREMENT** — one requirement or acceptance criterion, stated as a single verifiable outcome. If handed a list,
  run one pass per criterion; do not blend them.
- **Project root** — to locate the capability index and the ratified standards.

If the requirement is a vague theme ("make meals better"), stop and ask for a single checkable outcome first. A reuse
gate needs a target it can match against function signatures.

## Phase 1: Load the capability index

The capability index is produced by the `capability-index` skill. Load it in this order:

1. **Local JSON first** (zero cost, machine-readable):
   `<project-root>/docs/capability-index/capability-index.json`
2. **Local markdown** (human-readable fallback): `<project-root>/docs/capability-index/capability-index.md`

If neither exists, run the `capability-index` skill first, then return here. Never classify against memory —
classify only against a parsed index (name, signature, intent, invariants, caller surfaces). Guessing from function
names alone is banned (same rule as the generator).

## Phase 2: Classify each capability against the requirement

For every capability in the index that is plausibly related to the requirement, assign exactly one class. Cite the
function name, signature, and the index's intent line as evidence for each.

- **FULLY-MEETS** — an existing capability already satisfies the requirement end-to-end. *Evidence:* the
  requirement's outcome is the function's documented intent + invariants, with a caller surface already wired.
- **PARTIALLY-MEETS** — an existing capability covers part of the requirement; a gap remains. *Evidence:* same
  domain, same single source of truth, but the requirement adds an input, a branch, or an output it does not yet
  produce.
- **CONFLICTS-WITH** — an existing capability contradicts the requirement's semantics or an invariant. *Evidence:*
  both act on the same entity but disagree on a rule (e.g. requirement wants a raw write; capability enforces
  canonicalization).
- **NULLIFIES** — implementing the requirement would render an existing capability obsolete, OR an existing
  capability already makes the requirement redundant. *Evidence:* the requirement duplicates a write path, or
  supersedes a function that would then become dead code.

Rules:
- A requirement can produce **multiple** findings across different capabilities. Report all of them.
- **No self-comparison.** When the evidence is "a test proves it," confirm the test invokes the real canonical
  entrypoint on both sides — re-running one surface's expression twice is not evidence of FULLY-MEETS.
- If nothing in the index relates to the requirement, that is a valid result: zero findings means the requirement
  is genuinely NET-NEW surface (still run Phase 3).

## Phase 3: Apply the standards checks

These are the RECON-C reusable principles, encoded as conformance checks. For each, decide whether the requirement
**touches that domain**; if it does, the check becomes a pass/fail question whose answer is either an added acceptance
criterion or a named scope risk. Do not skip a check silently — mark it `n/a` with a one-line reason.

1. **Golden-fixture literals.** If the requirement asserts a cross-surface value, is there a golden fixture pinned to a
   hand-verified literal? `A === A` dressed as `A === B` is banned. No fixture → EXTEND with one, or flag as risk.
2. **No self-comparison in tests.** Does the requirement's verification invoke the real canonical entrypoints (MCP fn,
   route, page loader) on both sides? Re-computing one surface twice proves nothing.
3. **Hotspot gate derives from the risk tool.** If the requirement adds or changes a mutation/quality gate, does it read
   the risk tool's top-N output (`hotspots.sh`, churn × complexity) rather than a hand-maintained exemption list? A
   hand-curated list is a tautological guard.
4. **Bounded, convergent worker loops.** If the requirement adds a re-pull / retry / reconcile loop, does it have BOTH a
   hard `MAX_PULLS` ceiling AND a zero-progress guard (quarantine when an iteration does not shrink the work set)?
5. **Error classification: transient park vs permanent quarantine.** If the requirement handles failures, does it split
   transient infra faults (5xx, stream reset → release lease, reschedule) from permanent errors (count toward the
   retry ceiling → quarantine)? An undifferentiated catch is a defect.
6. **State transitions via RPC, no raw UPDATE.** If the requirement mutates pipeline/run state, does it go through a
   service-role function (e.g. `requeue_pipeline_run`) rather than a raw table write that bypasses audit, lease checks,
   and invariants?
7. **Stuck-run monitors alert, not merely query.** If the requirement adds a monitor or liveness check, does it deliver
   a notification (push / email / log-drain) on quarantine or SLO breach? Queryable is not observable.

## Phase 4: Emit the REUSE MAP

Present the result in Noah's decision-doc format. One block per finding, then one overall recommendation. Never a bare
"reuse or build?" — always ELI10 + ELI5, a concrete in-app example, and current-vs-should-be data.

```
## REUSE MAP — <requirement, one line>

### Finding N: <capability name>  — <FULLY-MEETS | PARTIALLY-MEETS | CONFLICTS-WITH | NULLIFIES>
- **ELI10:** <what this capability does and how it relates, in plain language>
- **ELI5:** <one sentence a child could follow>
- **In-app example:** <a concrete flow in THIS project where it already fires / would collide>
- **Current vs should-be:**
  - Current: <what exists today: signature, caller surfaces, invariants>
  - Should-be: <what the requirement needs>
- **Evidence:** <function signature + index intent line + test path if any>
- **Recommended disposition:** <REUSE | EXTEND | REFACTOR | NET-NEW> — <one-line why>

### Standards checks (Phase 3)
- <check>: pass / added-criterion / risk / n/a — <one line each>

### Recommendation (guided call)
<the disposition you would pick, the trade-off named, and the ONE decision you are asking the human to confirm>
```

### Disposition rubric (classification → disposition)

- **FULLY-MEETS → REUSE.** Call the existing capability. The requirement may be redundant — confirm before building.
- **PARTIALLY-MEETS → EXTEND.** Add the missing branch/input/output at the capability's single source of truth. Do
  not fork a parallel function.
- **CONFLICTS-WITH → REFACTOR.** Reconcile the two semantics first. Shipping over a conflict creates a second write
  path that will drift.
- **NULLIFIES → REFACTOR (unify) or NET-NEW + explicit deprecation.** Never leave the nullified capability as silent
  dead code — unify write paths or deprecate on record.
- **(no finding) → NET-NEW.** Genuinely new surface. Still subject to the Phase 3 standards checks before it lands.

The rubric gives the *default*; the human makes the call. Always name the trade-off of the non-recommended option.

## Scope: local index only

This skill reconciles against one project's own capability index and its own copy of the standards. There is no
cross-project store and none is planned: cairn was decommissioned (borg-collective repo,
`docs/plans/directives/2026-08-08-cairn-decommission-and-unconditional-block.md`) and nothing replaced it. A
requirement that genuinely spans projects therefore cannot be fully reconciled here — the reach is a real limit, not
missing wiring.

- Standards and capability indices are per-project copies. Reconciling against another project's capabilities means
  opening that project and running this skill there.
- When a requirement spans projects, name the unchecked projects in the REUSE MAP so the gap is explicit. A local-only
  pass must never read as cross-project coverage.

## Hard Rules

- **Never auto-build.** This skill ends at a guided human call. It proposes dispositions; it does not implement them.
- **Never classify from memory.** Only from a parsed capability index. No index → run `capability-index` first.
- **One requirement per pass.** A list is N passes, not one blended verdict.
- **Report every finding.** A requirement with three related capabilities has three findings, not the one you like.
- **Name the trade-off.** For each recommendation, state what the human gives up by not taking the other option.
- **The index is a snapshot.** If it predates recent domain changes, say so and offer to re-run the generator first.
