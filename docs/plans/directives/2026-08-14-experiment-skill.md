# Directive — `experiment` Skill (drafted, needs review + ship)

**Created:** 2026-08-14
**Scope:** `dev-tools` plugin within this repo
**Status:** Draft handed off — NOT reviewed, NOT built, NOT tested

## Why

Noah's standing preference is already captured as a feedback memory (`experiment-before-change`):

> Don't change scoring, rubrics, prompts, or pipeline logic directly. Build experiment
> infrastructure first so changes can be A/B tested.

That rule is currently enforced only by Noah remembering to state it. Every project re-derives the
harness by hand. reveal has grown eleven experiment scripts (`scripts/experiment.py`,
`run_experiment.py`, `grade_experiment.py`, `compare_experiments.py`, `experiment_routing_ab.py`,
…) and an `experiments/` tree; the same framework shipped once already under the project's earlier
name (reveal commit `a77873a` "Add experiment framework and rubric scoring experiment", on reveal's
`main`; note this hash resolves in the reveal repo, not in claude-plugins). No skill exists. No directive was ever
filed. The methodology for *designing* an experiment exists as reveal knowledge patterns
(`blind-reviewed-research-arc`, `research-arc-plan-only-with-blind-review`) but nothing enforces
running one.

Noah is about to run experiments and wants this available.

## What was drafted

`dev-tools/skills/experiment/SKILL.md` — 4-phase gate (spec → scaffold → baseline → variant →
decide), written against `docs/SKILL-DISTILLATION-RUBRIC.md` (imperative, tables over prose,
numeric thresholds with comparators, no provenance or meta-commentary).

Reference implementation the layout is drawn from: `~/dev/reveal/scripts/experiment.py`
(`run` / `compare` / `list`) and `~/dev/reveal/experiments/*/` (`config.json`, `summary.json`,
`ranked.json`; comparisons in `compare-<a>-vs-<b>/` with `report.json` + `report.html`).

## What the drone must do

1. **Review against the rubric.** The draft was written to it but not checked by grep. Confirm no
   hedge prose, every threshold numeric with a comparator, no repeated re-explanation.
2. **Confirm plugin placement.** Drafted into `dev-tools` alongside `bootstrap-project`,
   `consistency-audit`, `repo-review`. `code-governance` is the plausible alternative — decide and
   move if wrong.
3. **Check registration.** `dev-tools/` currently contains only `skills/`. Determine whether a
   manifest entry is required or whether discovery is by directory, and wire it up if needed.
4. **Build + verify.** Run `build-plugins.sh`; confirm `dist/` picks up the new skill and the
   trigger description actually fires on phrases like "should I change the scoring" and
   "A/B this".
5. **Validate the scaffold contract against reveal.** The SKILL prescribes
   `run` / `compare` / `list` and a fixed directory layout. Confirm it matches what
   `~/dev/reveal/scripts/experiment.py` actually does, so the skill does not instruct an agent to
   build something incompatible with the one working implementation.
6. **Do not commit to `main` without review.** The repo has uncommitted work in progress on `main`
   (`borg-collective/` hooks + skills, untracked `skills/pane/`). Branch first; do not sweep those
   into an unrelated commit.

## Open questions for Noah

- Should the skill also **enforce** the rule (refuse a direct scoring edit) or only **offer** the
  harness when asked? Draft currently states "Do not edit … directly" as an instruction but has no
  hook backing it. A PreToolUse hook on edits to scoring/rubric/prompt paths would make it a real
  gate rather than a suggestion.
- Should `experiments/` results persist through each project's production schema? reveal decided
  yes (memory: `Reveal experiment runs persist through platform schema` — avoid a parallel
  `experiment_results` table that drifts). Draft says "persist through the project's existing
  schema where one exists" — confirm that generalizes.
