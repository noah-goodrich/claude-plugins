# Code Governance Extraction — Build Report

**Date:** 2026-07-08
**Plugin:** `code-governance` (new, in `claude-plugins/`)
**Status:** Index generator + pilot are usable now. Reuse gate is built but unrun. borg-plan wiring is a
PROPOSAL awaiting Noah's review — nothing is wired.

---

## 1. What was built (every new file path)

All files are additive. `borg-plan`, existing skills, and prior `code-governance` artifacts were not modified.

**Generator + skills**

- `/Users/noah/dev/claude-plugins/code-governance/bin/capability-index.mjs` — the generator. Node.js, no external
  dependencies. Regex-based, tolerant of missing JSDoc; emits both Markdown and JSON.
- `/Users/noah/dev/claude-plugins/code-governance/skills/capability-index/SKILL.md` — runs the generator and reads
  back the index.
- `/Users/noah/dev/claude-plugins/code-governance/skills/reconcile-req/SKILL.md` — the reuse-gate skill (built,
  replacing an earlier placeholder stub).
- `/Users/noah/dev/claude-plugins/code-governance/docs/borg-plan-integration.md` — the wiring proposal (doc only).

**Marketplace registration**

- `/Users/noah/dev/claude-plugins/.claude-plugin/marketplace.json` — added a `code-governance` entry.

**Pilot outputs (in the ingle repo)**

- `/Users/noah/dev/ingle/docs/capability-index/capability-index.md`
- `/Users/noah/dev/ingle/docs/capability-index/capability-index.json`

---

## 2. Capability-index pilot result on ingle

Ran the generator against `/Users/noah/dev/ingle/src/lib/domain`. Clean output. Emitted **29 functions across 16
modules**.

Findings surfaced by the index:

- **1 undocumented function:** `resolveCartLine` in the `cart` module has no doc.
- **9 modules missing the `Pure. No I/O.` annotation:** golden-promotion, meal-ranking, plan-golden-split,
  product-attributes, resolution-confidence, rollover, staples, store-products, plus one in quantities.
- **No caller surface map** on those same 9 modules — i.e. nothing records who calls into them.

These are exactly the "un-enforced invariants / fragmented write paths" signals from the earlier ingle diagnosis:
the index makes them visible as a governable checklist rather than tribal knowledge.

---

## 3. The reconcile-req reuse gate + how it uses cairn

`skills/reconcile-req/SKILL.md` is the reuse gate. It replaced an explicit "not yet implemented" placeholder (the
SKIP-if-exists rule did not apply — there was no real skill to preserve). Its procedure:

- **Phase 1 — Load the capability index.** Prefers the local JSON/MD emitted by the generator; **cairn is the
  fallback** source when no local index is present.
- **Phase 2 — Classify each capability** against the incoming requirement: FULLY-MEETS / PARTIALLY-MEETS /
  CONFLICTS-WITH / NULLIFIES.
- **Phase 3 — Apply the seven RECON-C principles** encoded as explicit pass/fail checks.
- **Phase 4 — Emit a REUSE MAP** in Noah's decision-doc format (ELI10 + ELI5, in-app example, current-vs-should-be)
  with a per-finding disposition: REUSE / EXTEND / REFACTOR / NET-NEW.

**Cairn usage is a read/write interface spec only — a design note, not wired.** The skill specifies how it would
read the index from cairn and write the REUSE MAP back, but no cairn call is live yet.

---

## 4. borg-plan wiring — PROPOSAL (needs Noah review before wiring)

Captured in `code-governance/docs/borg-plan-integration.md`. Proposal only; no borg-plan file was touched.

- **Insert a new step `### 2b. Reconcile Against Existing Capabilities`** between Step 2 (Propose Acceptance
  Criteria, after the user confirms) and Step 3 (Propose Verification).
- It fires **while criteria are still editable and before `PROJECT_PLAN.md` locks** under The Lock Rule (line 200).
- It runs `reconcile-req` on each confirmed criterion and routes the REUSE MAP back into the flow, so
  REUSE / EXTEND / REFACTOR / NULLIFIES findings become reworded criteria, retargeted verification, or logged risks
  (Step 7).
- **Advisory, non-blocking**, ending at a guided human decision — it never auto-rejects a criterion.

---

## 5. Honest gaps — what's stubbed / needs a real run

- **reconcile-req has never actually run.** The procedure is fully written but unexecuted end-to-end against a real
  requirement, so classification quality and the REUSE-MAP output are unvalidated.
- **Cairn is unwired.** Both the index fallback-read and the REUSE-MAP write-back are specified but not implemented
  or tested against a live cairn.
- **The pilot ran on the host, not in the ingle container.** It covered only `src/lib/domain` (the pure layer).
  The generator has not run over the full ingle tree, other repos (reveal, troth), or inside the devcontainer where
  the real toolchain and paths live.
- **Generator coverage is regex-based.** It tolerates missing JSDoc by design, but that means it can miss or
  mis-parse non-standard signatures; accuracy beyond the 29-function pilot is unverified.
- **No caller-surface extraction yet.** The index flags modules that lack a caller map but does not build the map
  itself — that's a known follow-on.
- **borg-plan integration is a doc, not a change.** Nothing in the planning flow calls the gate.

---

## 6. Exact next steps to make it production-usable across projects

1. **Run reconcile-req for real, once.** Feed it one confirmed ingle criterion plus the pilot index; capture the
   REUSE MAP and eyeball classification quality. This is the single highest-value validation.
2. **Run the generator inside the ingle container over the full tree** (not just `src/lib/domain`), confirm paths
   and output resolve under the devcontainer, then commit the index into the ingle repo.
3. **Wire cairn** — implement the read (index fallback) and write (REUSE MAP) against a live cairn; test both paths.
4. **Decide on the borg-plan Step 2b proposal** (see section 4). If accepted, wire it as a separate change with its
   own review — do not fold it into this extraction.
5. **Add caller-surface extraction** to the generator so the "no caller map" finding is self-healing.
6. **Roll the generator across reveal and troth** to prove the index is project-agnostic, then register a standard
   `docs/capability-index/` location per repo.

---

**Tokens (delegated build):** index build ~$0.17 + gate build ~$0.25 ≈ $0.42 across the two subagents (rough lower
bound).
