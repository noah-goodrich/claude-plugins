# Directive 05 — Force Council Dissent + Phase 4.5 Contradiction Forge & Empirical Probe

**Priority:** 05 · **Axis:** (a) Invention primitive + adversarial design · **Feasibility:** High (dissent + Forge) /
Medium (probe) · **Depends on:** Directive 01 (invention on a self-certifying substrate manufactures
pseudo-inventions — the gate must hold first)

---

## Goal

Make the council produce real dissent instead of scripted consensus, and add an optional Phase 4.5 that resolves named
constraint tensions into both-poles options (contradiction resolution) and — where a cheap real-world test exists —
runs an empirical probe whose measured result feeds the council, rather than trading the tension off.

## Context (audit findings resolved)

- **The 5-persona council produces scripted consensus, not dissent — and the Pragmatist pre-decides every review**
  (`audit.md:236-246`). Across the corpus the council never splits on the actual decision: in troth account-earmarking
  all five personas independently name Option A, the cheapest (~40-line) option. The structural cause is in the skill —
  the Pragmatist is hard-wired to ask "80% of value for 20% of work" and every option carries an Estimate field, so the
  lowest-estimate option enters council pre-blessed. A council that always ratifies the cheapest option is a
  cost-estimator with four extra paragraphs of prose. SOTA backs the fix: **authentic dissent** reliably broadens
  search and improves quality, while scripted devil's advocacy mostly bolsters the original view (`analysis.md:71-72,
  654-656`; Theme H, Nemeth).
- **No invention/contradiction primitive** (`audit.md:393-396`). brainstorm flags constraint tensions then **trades
  them off instead of resolving them**. The missing move in the whole field is the disciplined act of dissolving a
  trade-off into a both-poles design. The SOTA caveat is load-bearing: ship TRIZ's defensible heuristics (separation
  in time/space/condition/scale, Ideal Final Result, the 40 principles as a reasoning MENU) and **refuse the discredited
  39x39 contradiction matrix** — near-random for mechanical problems and abandoned by Altshuller himself
  (`analysis.md:65-68,308-316`; Theme B). Worked examples must be CONTRASTS to reason against, not templates to copy
  (the ~10.7% homogenization penalty, `analysis.md:120-126`; Theme E).
- **No closed empirical loop** (`audit.md:393-396`). The reveal portrait brainstorm is the lone counterexample that
  closed the loop — by hand, because the skill never asks. The probe is only as good as the test the model designs, so
  it MUST carry an "is this probe decisive / does it measure the contradiction's actual poles?" check or it becomes
  validation theater (the A-Lab failure, `analysis.md:539-543`; Theme F).

This is the audit's recommendation #7 and #11 (`audit.md:440-442,458-462`). Invention is deliberately sequenced after
the gate: a both-poles synthesis on an honor-system substrate manufactures confident pseudo-inventions the council
cannot catch.

## Acceptance Criteria

- [ ] **Council dissent is mandatory**: require ≥1 persona to formally DISAGREE with the Recommender (logged as a risk)
      OR to kill an option for a reason **other than effort/feasibility**; add a non-empty `Dissent` field to the
      brainstorm output template (`audit.md:245-246`).
- [ ] The council must explicitly judge whether each Phase-4.5 "resolved" option **truly holds both poles or smuggled a
      hidden cost** — the resolved option is an authentic-dissent surface to attack, not a rubber-stamp.
- [ ] **`contradiction-resolution.md` reference** (~50 lines): 4 separation heuristics (time/space/condition/scale),
      the Ideal Final Result prompt, the 40 principles as a reasoning MENU (not a lookup), and 6–8 worked examples
      presented as **CONTRASTS**. The file MUST explicitly refuse the 39x39 contradiction matrix and say why.
- [ ] **Phase 4.5 (gated)**: fires only when Phase 1 surfaced a genuine constraint tension. For each top contradiction
      the model proposes ≥1 NEW option that resolves rather than trades off, tagged with the separation move used; the
      new option(s) re-enter the council as full Option blocks.
- [ ] **Optional empirical probe**: for an option with a cheap real-world test, a Task agent runs the probe, commits the
      harness, and the council scores on the MEASURED result (the reveal portrait pattern). The probe carries a
      "decisive? measures the actual poles?" validity check before its result is trusted.
- [ ] When no probe is possible, the resolved option is stamped `NO PRIMARY EVIDENCE` (shared vocabulary with Directive
      03), never silently passed.
- [ ] Lazy-loaded: `contradiction-resolution.md` loads only at Phase 4.5, per Directive 04's lazy-loading rule.
- [ ] Tested on ≥2 real corpus tensions (e.g. troth account-earmarking clarity-vs-flexibility) → produces at least one
      option that dissolves a trade-off the current skill would have traded off, plus a council `Dissent` entry.

## Estimate

**2–3 sessions.** ~0.5 session: the `Dissent` field + dissent requirement in the council. ~1 session:
`contradiction-resolution.md` with contrast examples + the Phase 4.5 prompt step. ~0.5–1.5 sessions: the optional
empirical-probe runner + harness-commit + probe-validity check, tested on real corpus tensions.
