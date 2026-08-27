# Directive — `experiment` Skill (shipped)

**Archived:** ✅ ASSIMILATED 2026-08-27 — every acceptance criterion verified met against the codebase. This is the
only directive in the 2026-08-27 reconciliation that closed on merit rather than by supersession.

**Created:** 2026-08-14
**Scope:** `dev-tools` plugin within this repo
**Status:** Shipped 2026-08-14 by [#38](https://github.com/noah-goodrich/claude-plugins/pull/38), merge commit
`4947095`. All six drone tasks below are verified complete and both open questions were answered in the PR.

**Correction (2026-08-27).** This line previously read "Draft handed off — NOT reviewed, NOT built, NOT tested".
That was accurate at filing and was never updated after the skill merged the same day, so the record understated
the work by a week and a half. `gh pr view 38 -R noah-goodrich/claude-plugins` returns `MERGED`,
`mergedAt: 2026-08-14T21:21:00Z`, merge commit `49470956b02061d398085b480e5d7f55cdd85b3d`, head branch
`skill/experiment`; `git merge-base --is-ancestor 4947095 main` exits 0. No assimilated record exists for this
directive — it is the only record of the work, which is why the stale Status line went unnoticed.

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

**Section state (2026-08-27).** Preserved as filed. Two sentences above are now false: a skill does exist
(`dev-tools/skills/experiment/SKILL.md`, added by `4947095`) and a directive was filed — this one. The `a77873a`
citation was corrected on 2026-08-24 by `f4212aa` ([#42](https://github.com/noah-goodrich/claude-plugins/pull/42))
and the correction is present above; re-verified today:
`git -C /Users/noah/dev/reveal merge-base --is-ancestor a77873a main` exits 0, while
`git -C /Users/noah/dev/claude-plugins cat-file -t a77873a` returns `fatal: Not a valid object name`.

## What was drafted, and what shipped

`dev-tools/skills/experiment/SKILL.md` — 4-phase gate (spec → scaffold → baseline → variant →
decide), written against `docs/SKILL-DISTILLATION-RUBRIC.md` (imperative, tables over prose,
numeric thresholds with comparators, no provenance or meta-commentary).

Reference implementation the layout is drawn from: `~/dev/reveal/scripts/experiment.py`
(`run` / `compare` / `list`) and `~/dev/reveal/experiments/*/` (`config.json`, `summary.json`,
`ranked.json`; comparisons in `compare-<a>-vs-<b>/` with `report.json` + `report.html`).

Shipped as 142 lines at that path, unchanged since merge (`git log --oneline -- dev-tools/skills/experiment/`
returns exactly one commit, `4947095`). The draft was amended before merge on two points — the Phase 0 spec
location and the numeric degenerate-baseline conditions — both recorded under task 5 below.

## What the drone must do — all six verified complete

- [x] 1. **Review against the rubric.** The draft was written to it but not checked by grep. Confirm no
      hedge prose, every threshold numeric with a comparator, no repeated re-explanation.
      Verified 2026-08-27. `grep -niE "worth noting|deliberately|importantly|rule of thumb|a handful|most of"
      dev-tools/skills/experiment/SKILL.md` returns nothing (exit 1); `awk 'length > 120'` returns nothing. Every
      threshold in the shipped file carries a comparator: `stdev == 0`, `at_max / count ≥ 0.10`, `count < 30`
      (SKILL.md:99-101), and Phase 0 requires GO/KILL as numbers with `≥ ≤ > <` (SKILL.md:37-41). The
      [#38](https://github.com/noah-goodrich/claude-plugins/pull/38) body records the fixes made during this
      pass: the Phase 2 check was prose and became numeric, duplicate gates 1/4 were merged, a second
      motivational line was cut, the trigger table pointed at the wrong phase, and one row was 122 chars.
- [x] 2. **Confirm plugin placement.** Drafted into `dev-tools` alongside `bootstrap-project`,
      `consistency-audit`, `repo-review`. `code-governance` is the plausible alternative — decide and
      move if wrong.
      Decided `dev-tools`; the skill is at `dev-tools/skills/experiment/SKILL.md` on `main`. Rationale in
      [#38](https://github.com/noah-goodrich/claude-plugins/pull/38): `code-governance` had no
      `.claude-plugin/plugin.json` at the time, so `build-plugins.sh` skipped the whole directory and moving
      there would have unshipped the skill. That gap has since closed —
      `git log --diff-filter=A -- code-governance/.claude-plugin/plugin.json` returns `a1445f1`
      ([#44](https://github.com/noah-goodrich/claude-plugins/pull/44)) — so the original reason no longer holds,
      but the placement decision stands on the family argument.
- [x] 3. **Check registration.** `dev-tools/` currently contains only `skills/`. Determine whether a
      manifest entry is required or whether discovery is by directory, and wire it up if needed.
      Answer: discovery is by directory under `skills/`; no per-skill manifest entry exists or is needed.
      `dev-tools/.claude-plugin/plugin.json` has no `skills` key, and `.claude-plugin/marketplace.json` lists
      plugins (`dev-tools → ./dev-tools`), not skills. `4947095` bumped the plugin 0.2.13 → 0.2.14 and widened
      the description and keywords (`experiment`, `ab-test`, `baseline`), which is what the build script needs
      since version bumps are manual.
- [x] 4. **Build + verify.** Run `build-plugins.sh`; confirm `dist/` picks up the new skill and the
      trigger description actually fires on phrases like "should I change the scoring" and
      "A/B this".
      Re-verified 2026-08-27 by running `./build-plugins.sh`: marketplace guard passes, `Packaging dev-tools
      (0.2.14)` → `dist/dev-tools.plugin`, and `tar -tf dist/dev-tools.plugin | grep experiment` lists
      `skills/experiment/SKILL.md`. Trigger side, narrower than worded: the skill loads in a live session as
      `dev-tools:experiment` carrying the SKILL.md description verbatim, which names "changing scoring, rubrics,
      prompts, or pipeline logic", `/experiment`, "A/B this", and "does this actually help". Presence in the
      session's skill roster is the evidence; no phrase-level trigger eval was run, then or now.
- [x] 5. **Validate the scaffold contract against reveal.** The SKILL prescribes
      `run` / `compare` / `list` and a fixed directory layout. Confirm it matches what
      `~/dev/reveal/scripts/experiment.py` actually does, so the skill does not instruct an agent to
      build something incompatible with the one working implementation.
      Validated, and it caught a real defect. Re-checked against `/Users/noah/dev/reveal/scripts/experiment.py`
      on 2026-08-27: `run` at :363, `compare` at :409, `list_experiments` at :449; `run --force` at :368 and the
      non-destructive bail at :373-375; `ranked.json` / `config.json` / `summary.json` written at :395-397;
      `compare-<a>-vs-<b>/` with `report.json` + `report.html` at :416-423; `summary` carries `count`, `min`,
      `max`, `mean`, `median`, `stdev`, `at_max` at :166-177, matching SKILL.md:94 exactly. The defect: the draft
      told the agent to write the spec into `experiments/<name>/config.json` before the first run, but `run`
      exits 0 with "Already exists" when the directory is present and then overwrites `config.json` from its own
      config registry — every first run would have silently no-opped. Fixed before merge; the spec now lives in
      the config entry and `--force` is documented (SKILL.md:44-47, :72-78).
- [x] 6. **Do not commit to `main` without review.** The repo has uncommitted work in progress on `main`
      (`borg-collective/` hooks + skills, untracked `skills/pane/`). Branch first; do not sweep those
      into an unrelated commit.
      Honored. `gh pr view 38` reports head branch `skill/experiment`; `git show --stat 4947095` touches exactly
      three files — `dev-tools/.claude-plugin/plugin.json`, `dev-tools/skills/experiment/SKILL.md`, and this
      directive. Nothing under `borg-collective/` and no `skills/pane/` was swept in.

## Open questions for Noah — both answered in [#38](https://github.com/noah-goodrich/claude-plugins/pull/38)

Neither remains open. Both answers are recorded in the PR body under "Open questions — answered by Noah".

- ~~Should the skill also **enforce** the rule (refuse a direct scoring edit) or only **offer** the
  harness when asked?~~ **Answered: offer-only, as drafted.** The SKILL.md instruction "Do not edit scoring,
  rubrics, prompts, model selection, thresholds, or pipeline routing directly" (SKILL.md:14) ships with no hook
  behind it, by decision rather than oversight. Confirmed still true 2026-08-27: `find . -name hooks.json` returns
  only `borg-collective/`, `research-tools/`, and `token-cost/` — `dev-tools/` has no `hooks/` directory at all.
  A PreToolUse hook on edits to scoring/rubric/prompt paths remains the available upgrade if the instruction
  proves too weak in practice; it is unbuilt, and that is a future proposal, not an open item on this directive.
- ~~Should `experiments/` results persist through each project's production schema?~~ **Answered: yes,
  generalize reveal's rule.** reveal's memory (`Reveal experiment runs persist through platform schema` — avoid a
  parallel `experiment_results` table that drifts) generalized cleanly and shipped as a Phase 1 constraint:
  "Persist results through the project's existing schema where one exists. Do NOT create a parallel results table
  that will drift from production." (SKILL.md:83-84).
