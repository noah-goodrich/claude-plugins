# Phase 0 mode hillclimb, 2026-11-03

Decision: ADOPTED variant v1. `research-tools/skills/research/SKILL.md` Phase 0 now opens with "Before any other action, print exactly one line: `Mode: <evidence|decision-design|hybrid> — <one-line reason>`" and the ambiguity rule says to print the best-fit Mode line before asking the one clarifying question. The routing table is unchanged. `research-tools` bumped 0.6.0 to 0.6.1.

## Setup

- Target: baseline mode accuracy was 1/6 and most runs never named a mode. Triggers were not re-run: Phase 0 text loads only after the skill fires, and the trigger suite is at ceiling (50/50, 0 false fires).
- Pre-registered before any stage 2 model run (commit "pre-register mode train and heldout split"): M1 to M6 are train, M7 to M12 are new held-out (2 evidence, 2 decision-design, 2 hybrid each split). No label was changed, including M5.
- Scoring, separately on every run: declared (the run states a mode at all) and routed (the declared mode is the expected one; undeclared counts as not routed). The detector reads a fixed `Mode: <mode>` line first, then falls back to the stage 1 regexes. The stage 1 baseline streams were still on disk, so they were re-scored with the same detector (`run.sh --rescore`); the baseline train numbers below therefore differ from the stage 1 report (2/6 routed, not 1/6) because the re-score also reads "<mode> mode" phrasing.
- Variants (only Phase 0 and the routing rule around lines 23 to 25 edited, built as copies under `out/variants/`, each verified through the init event):
  - v1: the print-the-Mode-line-first instruction plus the ambiguity rule change.
  - v2: v1 plus a three-line "shape of the ask" rule (only evidence, only options, both means hybrid). Its hybrid example resembles the M5 wording, so any gain on M5 is contaminated; it did not win anyway.
  - v3: v2 plus "first line of your first reply" with three worked Mode lines.
- Selection on train only, 1 rep: v1 6/6, v3 6/6, v2 5/6. v1 and v3 tied; v1 was chosen as the smaller change (tie-break fixed before looking at held-out). Held-out was run only for the baseline and v1, after selection.

## Result on held-out (6 prompts, 1 rep each)

- Baseline: declared 1/6 (Wilson 95% CI 3.0% to 56.4%), routed 0/6 (0.0% to 39.0%).
- v1: declared 6/6 (61.0% to 100.0%), routed 6/6 (61.0% to 100.0%).
- The routed gain does not sit inside the interval overlap: the baseline upper bound (39.0%) is below the v1 lower bound (61.0%). The declared gain also separates (56.4% vs 61.0%, barely). Both are still n=6, so the true rate for v1 could be as low as about 61 percent.
- Adoption rule met: both rates at least as good, both strictly better.

## Deviations and caveats

- Held-out was run at 1 rep, not 2. The 8.00 USD stage cap did not leave room: stage 2 spend was 7.77 USD, and the 12 further held-out runs would have cost about 2.4 USD. Runs of one prompt are not independent anyway, so more reps would tighten little; more prompts would.
- B1 regression check ran once with a lowered per-call cap of 0.84 USD (the remaining stage budget) and PASSED: analysis.md present with `Generated: 2026-11-03`, no .gate-armed, no pandoc or epub call, no .epub. It cost 0.61 USD.
- The baseline train runs are the stage 1 runs, rescored; the variant train runs are new. Same prompts, same model (claude-sonnet-5-5), same flags.
- The Mode line is only a declaration. v1 does not change which workflow the skill then runs; whether declaring first changes later behavior was not measured, only that B1 still passes.
- M11 ("Check what the evidence says about monorepo outcomes at scale, then design our migration options and recommend one") is the closest to a label question: the baseline declared evidence. I think the hybrid label is right (evidence then design), so it stays.
- Tests after adoption: research-tools/hooks/test/run-tests.sh all passed; check-version-bumps.sh OK (research-tools 0.6.0 to 0.6.1); `evals/research-tools/run.sh --skip-model` 19 pass, 0 fail.

## Follow-up: harder trigger near-misses (not run)

The trigger suite has no headroom (0 misses, 0 false fires). A future description hillclimb needs prompts the description can get wrong. Candidates to pre-register before running anything:

- Code questions that really do want literature: "What does the research say about the best way to structure React state, and should we use it here?" (hybrid, fire) next to "Research how state is structured in this repo" (no-fire).
- Decision asks that belong to strategic-brief: "Should we build or buy auth, and what do the studies on vendor lock-in say?" (mixed).
- design-doc handoffs: "Explore three ways to shard the database, then write the design doc" (research first, then design-doc).
- Single-source asks that look like research: "Fact-check this one claim from the attached article."
- Quick-lookup edges: "How many studies have compared TDD and test-after?" (borderline).
- Non-English or terse phrasings: "lit review: sleep and memory".
- Prompts that name another skill's vocabulary: "deep dive into our incident history" (internal data, no-fire).
- Multi-turn follow-ups (the suite is single-turn only).
- Heldout needs at least 16 fresh near-misses so train rewrites stay blind to it.

## Mode declaration (Phase 0): declared and routed, scored separately

declared = the run states a mode at all. routed = the declared mode is the expected one (undeclared counts as not routed). Mode: line first, regex fallback.

### variant: baseline, split: train (6 runs)
- Declared rate: 3/6 = 50.0% (Wilson 95% CI 18.8% to 81.2%)
- Routed accuracy (of all runs): 2/6 = 33.3% (Wilson 95% CI 9.7% to 70.0%)
- Routed among declared runs: 2/3 = 66.7% (Wilson 95% CI 20.8% to 93.9%)
- Runs with the fixed Mode: line: 1 of 6

### variant: baseline, split: heldout (6 runs)
- Declared rate: 1/6 = 16.7% (Wilson 95% CI 3.0% to 56.4%)
- Routed accuracy (of all runs): 0/6 = 0.0% (Wilson 95% CI 0.0% to 39.0%)
- Routed among declared runs: 0/1 = 0.0% (Wilson 95% CI 0.0% to 79.3%)
- Runs with the fixed Mode: line: 0 of 6

### variant: v1, split: train (6 runs)
- Declared rate: 6/6 = 100.0% (Wilson 95% CI 61.0% to 100.0%)
- Routed accuracy (of all runs): 6/6 = 100.0% (Wilson 95% CI 61.0% to 100.0%)
- Routed among declared runs: 6/6 = 100.0% (Wilson 95% CI 61.0% to 100.0%)
- Runs with the fixed Mode: line: 5 of 6

### variant: v1, split: heldout (6 runs)
- Declared rate: 6/6 = 100.0% (Wilson 95% CI 61.0% to 100.0%)
- Routed accuracy (of all runs): 6/6 = 100.0% (Wilson 95% CI 61.0% to 100.0%)
- Routed among declared runs: 6/6 = 100.0% (Wilson 95% CI 61.0% to 100.0%)
- Runs with the fixed Mode: line: 6 of 6

### variant: v2, split: train (6 runs)
- Declared rate: 5/6 = 83.3% (Wilson 95% CI 43.6% to 97.0%)
- Routed accuracy (of all runs): 5/6 = 83.3% (Wilson 95% CI 43.6% to 97.0%)
- Routed among declared runs: 5/5 = 100.0% (Wilson 95% CI 56.6% to 100.0%)
- Runs with the fixed Mode: line: 5 of 6

### variant: v3, split: train (6 runs)
- Declared rate: 6/6 = 100.0% (Wilson 95% CI 61.0% to 100.0%)
- Routed accuracy (of all runs): 6/6 = 100.0% (Wilson 95% CI 61.0% to 100.0%)
- Routed among declared runs: 6/6 = 100.0% (Wilson 95% CI 61.0% to 100.0%)
- Runs with the fixed Mode: line: 6 of 6

| variant | id | expected | declared per run |
|---|---|---|---|
| baseline | M1 | evidence | evidence |
| baseline | M10 | decision-design | undeclared |
| baseline | M11 | hybrid | evidence |
| baseline | M12 | hybrid | undeclared |
| baseline | M2 | evidence | undeclared |
| baseline | M3 | decision-design | undeclared |
| baseline | M4 | decision-design | undeclared |
| baseline | M5 | hybrid | evidence |
| baseline | M6 | hybrid | hybrid |
| baseline | M7 | evidence | undeclared |
| baseline | M8 | evidence | undeclared |
| baseline | M9 | decision-design | undeclared |
| v1 | M1 | evidence | evidence |
| v1 | M10 | decision-design | decision-design |
| v1 | M11 | hybrid | hybrid |
| v1 | M12 | hybrid | hybrid |
| v1 | M2 | evidence | evidence |
| v1 | M3 | decision-design | decision-design |
| v1 | M4 | decision-design | decision-design |
| v1 | M5 | hybrid | hybrid |
| v1 | M6 | hybrid | hybrid |
| v1 | M7 | evidence | evidence |
| v1 | M8 | evidence | evidence |
| v1 | M9 | decision-design | decision-design |
| v2 | M1 | evidence | evidence |
| v2 | M2 | evidence | evidence |
| v2 | M3 | decision-design | undeclared |
| v2 | M4 | decision-design | decision-design |
| v2 | M5 | hybrid | hybrid |
| v2 | M6 | hybrid | hybrid |
| v3 | M1 | evidence | evidence |
| v3 | M2 | evidence | evidence |
| v3 | M3 | decision-design | decision-design |
| v3 | M4 | decision-design | decision-design |
| v3 | M5 | hybrid | hybrid |
| v3 | M6 | hybrid | hybrid |

