# Contradiction Resolution — Phase 4.5 Reasoning Aid

Load this file ONLY at Phase 4.5, and only when Phase 1 surfaced a genuine constraint tension (two
constraints that pull against each other so that satisfying one appears to sacrifice the other). The
job here is the move the rest of the skill never makes: **dissolve a trade-off into a both-poles
design** instead of conceding one pole. A resolved option holds BOTH poles; if it quietly drops one,
it is not a resolution — it is the old trade-off wearing a new name, and the council must catch it.

## REFUSED: the 39x39 contradiction matrix

Do NOT consult, reconstruct, or reason from TRIZ's 39x39 contradiction matrix. Its principle
selection is effectively random for mechanical problems, its patent data froze in 1985, it covers
only ~10–15% of problems, and **Altshuller himself dropped it** from his final 1985 formulation in
favor of Su-field analysis / ARIZ (`analysis.md:308-316`, Borgianni et al. 2021). The matrix is the
weakest-validated part of TRIZ. Keep the heuristics below; distrust the lookup table.

## The 4 separation heuristics (the load-bearing move)

When constraint X demands one thing and constraint Y demands its opposite, ask whether the two
demands can be separated so each holds where it matters:

1. **Separation in time** — X holds at one moment, Y at another. (Earmark money at *spend* time, not
   at *deposit* time → funds stay fungible until the instant they are committed.)
2. **Separation in space** — X holds in one place/surface, Y in another. (Strict validation at the
   write API; permissive display in the read view.)
3. **Separation on condition** — X holds when a condition is true, Y when it is false. (Lock the
   budget only once the user opts into a goal; stay flexible by default.)
4. **Separation by scale/level** — X holds at the part, Y at the whole, or vice versa. (Per-item
   rigidity, portfolio-level flexibility.)

Tag every Phase-4.5 option with the exact separation move it used. If you cannot name the move, you
have not separated anything.

## The Ideal Final Result (IFR) prompt

Before generating options, state the IFR: *"The benefit appears WITHOUT the cost, by the system
itself, using resources already present."* Write the one sentence. It anchors generation on
dissolving the cost rather than paying it more cheaply. If your best option still pays the cost in
full, you have not reached for the IFR.

## The 40 principles as a reasoning MENU (not a lookup)

Read the 40 inventive principles as prompts to think WITH, scanned for fit — never as a table to
index into from a contradiction pair. Useful ones for software/product tensions: Segmentation,
Local quality, Asymmetry, Nesting, Prior action, Cushion-in-advance, Self-service, "The other way
round," Dynamics, Partial/excessive action, Feedback, Intermediary, Copying, Cheap short-life,
Composite materials. Use 2–3 that genuinely apply; ignore the rest. The menu broadens search; it
does not pick the answer.

## Worked examples — reason against these CONTRASTS (do not copy them)

These are deliberately presented as contrasts to argue with, not templates to fill. Copying examples
homogenizes output (~10.7% similarity penalty, `analysis.md:120-126`); reacting against them
preserves variety. For each, the trade-off version is what the current skill would have shipped.

- **Account earmarking (clarity vs. flexibility).** Trade-off: lock funds to a category (clear,
  rigid) OR leave them pooled (flexible, murky). Resolution (time): tag intent at *spend* time, not
  *deposit* time — pooled until committed, then labeled. Contrast: a "soft lock" you can override is
  still a lock — that smuggles the rigidity cost back in.
- **Onboarding (fast first-run vs. capable later).** Trade-off: short setup OR full configuration.
  Resolution (condition): defaults that work day one; depth unlocks on the first action that needs
  it. Contrast: a "skip for now" button is deferral, not resolution — the setup cost still arrives.
- **List dedup (catch dupes vs. never block a real add).** Trade-off: strict match (blocks) OR loose
  match (misses). Resolution (space): warn inline at the add surface; never block; reconcile on the
  read view. Contrast: a confirm dialog still interrupts — it pays the friction cost it claimed to
  avoid.
- **Pantry freshness (accurate counts vs. zero logging effort).** Trade-off: manual logging OR stale
  data. Resolution (scale): infer at the portfolio level from purchase cadence; correct per-item
  only on contradiction. Contrast: a weekly "review your pantry" prompt is manual logging rescheduled.
- **Meal suggestions (variety vs. respect strong dislikes).** Trade-off: wide net (hits dislikes) OR
  narrow safe list (boring). Resolution (condition): widen only inside categories already accepted;
  treat a logged dislike as a hard boundary, not a soft weight. Contrast: "rate this so we learn" is
  just deferred trade-off — it pays the bad-suggestion cost first.
- **Portrait generation (fidelity vs. demographic coverage).** Trade-off: one tuned pipeline (high
  fidelity, narrow) OR many (broad, uneven). Resolution (space): shared base + per-segment adapters
  at the last layer. Contrast: a single "diverse" prompt that AVERAGES segments holds neither pole —
  the empirical probe (below) is what exposed this; reasoning alone called it resolved.

## When the resolution can be tested — empirical probe

If a resolved option has a CHEAP real-world test that measures the actual poles, a Task agent runs
the probe and commits the harness; the council then scores on the MEASURED result, not the argument.
The probe is only trustworthy if it passes a validity check FIRST: **"Is this probe decisive, and
does it measure the contradiction's actual poles?"** A probe that measures a proxy is validation
theater (the A-Lab failure: 41 "new" materials collapsed to ~zero under independent re-analysis,
`analysis.md:539-543`). If no decisive probe is possible, stamp the resolved option
`NO PRIMARY EVIDENCE` (shared vocabulary with Directive 03) — never silently pass it as proven.
