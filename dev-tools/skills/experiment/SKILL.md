---
name: experiment
description: >
  Build comparison infrastructure before changing scoring, rubrics, prompts, or pipeline logic.
  Scaffolds an isolated run/compare/list harness, runs baseline against variant, and gates the
  change on measured deltas. Use when proposing any change whose effect is a matter of degree
  rather than correctness, or when the user says /experiment, "A/B this", or "does this actually
  help".
user-invocable: true
---

# Experiment — Measure Before You Change

Do not edit scoring, rubrics, prompts, model selection, thresholds, or pipeline routing directly.
Build the comparison first. Run baseline and variant as isolated experiments. Change the code only
after the data says the variant wins.

## When this triggers

| Trigger | Action |
|---|---|
| Change to scoring, rubric, prompt, threshold, routing, or model choice | Run this skill |
| Change with a correctness answer (bug, crash, wrong output) | Do NOT run this skill — just fix it |
| User asks "is this better", "A/B this", "does this help" | Run this skill |
| No baseline exists yet | Phase 2 creates it before any variant runs |

Bugs have a right answer and get fixed. Matters of degree get measured.

## Phase 0 — Spec before code

Write the spec first. Refuse to run an experiment without these four fields:

| Field | Requirement |
|---|---|
| `hypothesis` | One sentence, falsifiable |
| `metric` | The single number that decides it, named exactly |
| `GO` | Numeric threshold with comparator that means ship it |
| `KILL` | Numeric threshold with comparator that means abandon it |

State GO/KILL as numbers with a comparator (`≥`, `≤`, `>`, `<`). Never "improves", "better",
"most". If the metric cannot be named, stop and run the `research` skill in decision-design mode
to pick one — do not proceed on an unnamed metric.

Record the four fields in the experiment's config **entry** before the first run — the harness
writes them into `experiments/<name>/config.json` as part of the run. Do NOT hand-create
`experiments/<name>/` ahead of the run: `run` refuses a name whose directory already exists unless
`--force`, and it overwrites `config.json` with what the config entry declares.

## Phase 1 — Scaffold (skip if the harness exists)

Check for an existing harness before building one:

```
ls scripts/experiment.py experiments/ 2>/dev/null
```

If absent, scaffold this structure. Do not invent a different layout:

```
scripts/experiment.py              run | compare | list
experiments/<name>/config.json     the spec + variant config
experiments/<name>/summary.json    aggregate metrics
experiments/<name>/ranked.json     per-item results, ordered
experiments/compare-<a>-vs-<b>/report.json
experiments/compare-<a>-vs-<b>/report.html
```

Required commands:

| Command | Behavior |
|---|---|
| `experiment.py run <name>` | Execute one config, write `config.json` + `summary.json` + `ranked.json` |
| `experiment.py run <name> --force` | Same, overwriting an existing run dir |
| `experiment.py compare <a> <b>` | Diff two runs into `compare-<a>-vs-<b>/`, write `report.json` + `report.html` |
| `experiment.py list` | Enumerate runs with their headline metric |

`run` without `--force` must exit non-destructively when `experiments/<name>/` exists. Results are
never silently overwritten.

Constraints:
- Each run writes only inside `experiments/<name>/`. A run never mutates production code paths.
- Runs are reproducible: same config + same corpus = same numbers.
- Persist results through the project's existing schema where one exists. Do NOT create a parallel
  results table that will drift from production.

## Phase 2 — Baseline

Run the unchanged system first.

```
python scripts/experiment.py run baseline-<what>
```

`summary.json` must carry at minimum `count`, `min`, `max`, `mean`, `median`, `stdev`, `at_max`.
Inspect it and declare the baseline broken if any of these hold:

| Condition | Meaning |
|---|---|
| `stdev == 0` | Every item scores identically — the metric does not discriminate |
| `at_max / count ≥ 0.10` | Ceiling pileup — the metric saturates |
| `count < 30` | Corpus too small to read a delta |

Fix the metric or the corpus before testing variants, and say so plainly. A variant measured
against a broken baseline proves nothing.

## Phase 3 — Variant

One variable per experiment. Two changes in one run produce an uninterpretable result.

```
python scripts/experiment.py run <variant-name>
python scripts/experiment.py compare baseline-<what> <variant-name>
```

## Phase 4 — Decide

Read `report.json` against the Phase 0 thresholds and state one verdict:

| Verdict | Condition | Next |
|---|---|---|
| **GO** | Metric meets the GO threshold | Apply the change; keep both experiment dirs as the record |
| **KILL** | Metric meets the KILL threshold | Abandon; record why in the experiment dir |
| **INCONCLUSIVE** | Neither threshold met | Do NOT ship. Report the delta; propose a sharper metric or larger corpus |

Report the actual numbers. Never report "improved" without the delta and the threshold it was
measured against.

## Gates

1. No spec with all four Phase 0 fields → do not run. If the blocker is an unnamed or non-numeric
   metric, run `research` in decision-design mode.
2. No baseline, or a baseline failing any Phase 2 condition → do not run a variant.
3. More than one variable changed → split into separate experiments.
4. INCONCLUSIVE → the change does not ship.

## Handoffs

| Situation | Skill |
|---|---|
| Which approach to test is unclear | `research` (decision-design mode) |
| Need a literature-grounded design before committing corpus time | `research` (evidence mode) |
| Experiment code is written and ready to commit | `simplify` |
