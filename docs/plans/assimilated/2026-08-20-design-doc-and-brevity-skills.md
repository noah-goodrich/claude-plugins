# Directive: Design-Doc and Brevity Skills

**Archived:** ⚠️ ASSIMILATED WITH ONE CRITERION SUPERSEDED 2026-08-27. AC2, AC3 and AC4 are met and verified.
AC1 is not met and never will be: it requires a seven-section template that does not exist in practice, and the
shipped template deliberately differs (decision D1). Archived because nothing is outstanding, not because
everything closed.

*Filed: 2026-08-20 · Status: Shipped 2026-08-21 via [#39](https://github.com/noah-goodrich/claude-plugins/pull/39)*
*AC2-AC4 met; AC1 superseded, will not close · Parent: 2026-08-20-communication-program.md (borg-collective)*

**tl;dr** — Every proposal, PR description, and long chat reply is shaped from scratch each time, so quality
depends on the agent remembering how Noah reads. Ship three skills in the noah-writing-voice / noah-content-tools
family that make the format the default: a design-doc template, a brevity layer, and a PR-description
generator.

## Problem

Noah's work tooling (2026-08-19) converged on a template — Problem, Solution, Goals, Non-Goals, Alternatives
Considered — and a tl;dr discipline: one sentence of problem, one of solution, readable without context.
Nothing on the personal side encodes either. Naming note from research: the industry calls this shape a
**design doc** (Google lineage) or **RFC**; "TRD" elsewhere means a requirements spec, a different artifact
(industrialempathy.com/posts/design-docs-at-google, rust-lang.github.io/rfcs). Keep "TRD" as Noah's spoken
alias; name the skill `design-doc`.

## Solution

Three skills, one plugin family:

- **K1 — `design-doc`.** Scaffolds and reviews documents in the template: tl;dr (top), Problem, Solution,
  Goals, Non-Goals (falsifiable boundary statements), Alternatives Considered (load-bearing, each rejected
  option with the trade-off that killed it), Decisions requested. Length caps: 1-3 pages incremental, hard
  stop at the point a reader stops (industrialempathy). Status line kept current (Proposed/Accepted/
  Superseded), per ADR practice.
- **K2 — brevity layer.** Extend `noah-voice` (or sibling skill) with the distilled, unbranded method:
  front-load the one thing; one explicit why-it-matters line; depth goes to a linked "go deeper", never the
  body; bullets over prose past two facts; bold only figures and decisions; conditions before instructions;
  never flatten a real trade-off into a bullet (the documented Smart Brevity failure mode); chat replies end
  with the tl;dr, documents start with it. Sources recorded in the skill: developers.google.com/style/tone,
  /style/highlights; Smart Brevity method + CJR critique.
- **K3 — `pr-description`.** Generates PR bodies as: tl;dr (problem + solution sentences), chain position
  (which program/lane, what it blocks and is blocked by, from `.borg/programs` manifests when present),
  review map (the 2-3 files that carry the change), test evidence. Replaces freeform bodies.

**Where they actually landed** (verified 2026-08-27 against `main`): K1 is
`noah-content-tools/skills/design-doc/` — `SKILL.md`, `scripts/validate.sh`, `test/run-tests.sh`, ten defect and
pass fixtures, and three frozen snapshots of the real 2026-08-20 directives under `test/fixtures/real/`. K2 is
`noah-writing-voice/skills/brevity/` — `SKILL.md` plus `references/portable-voice.md`. K3 is
`noah-content-tools/skills/pr-description/SKILL.md`. The tl;dr as filed named `research-tools` as the second home
and nothing landed there: `research-tools/skills/` still holds only `research`, `deep-research` and `brainstorm`.
The tl;dr above is corrected to name `noah-content-tools`; this line records what the original said.

## Acceptance criteria

These four were the criteria as filed. They were amended during planning and the amended set is the one that was
actually built and verified — see `docs/plans/assimilated/2026-08-21-design-doc-brevity-pr-description-skills.md`,
which carries six criteria, all met, plus a "What the Plan Got Wrong" section. The boxes below are marked against
the criteria *as written here*, which is why AC1 does not close.

Reconciliation history: AC1, AC2 and AC4 were annotated in
[#41](https://github.com/noah-goodrich/claude-plugins/pull/41) (merged 2026-08-24); AC3 was closed in
[#46](https://github.com/noah-goodrich/claude-plugins/pull/46) (merged 2026-08-24) once the manifest evidence was
tracked. All four states were re-verified against `main` on 2026-08-27 and the evidence lines below record what was
run. Three of four are met; AC1 stays open permanently by decision, not by omission.

- [ ] AC1 `/design-doc` produces the template with all seven sections and refuses to emit one without a
      tl;dr; the umbrella + delivery-surfaces directives (borg-collective, 2026-08-20) validate against it.
      **Superseded, not met as worded.** The seven-section template does not exist in practice: the umbrella
      directive carries `Goals` and `Decisions requested` and no acceptance criteria, while both children carry
      `Acceptance criteria` and neither has `Goals`. The shipped template requires five sections plus exactly one
      outcome section, which all three real directives pass. Decision D1 in the assimilated plan.
      Re-verified 2026-08-27. `grep -n '^## '` over the three frozen snapshots in
      `noah-content-tools/skills/design-doc/test/fixtures/real/` returns `Problem, Solution, Goals, Non-Goals,
      Alternatives Considered, Decisions requested, Ship definition` for the umbrella and `Problem, Solution,
      Acceptance criteria, Non-Goals, Alternatives Considered` for both children — no real document carries the
      seven sections this criterion names, and the umbrella never will, because `Goals` and `Acceptance criteria`
      are alternatives by design. The shipped rule is the `REQUIRED` array at `scripts/validate.sh:117` plus the
      outcome check at `:129`, not a seven-section list. `bash noah-content-tools/skills/design-doc/test/run-tests.sh`
      → `ALL TESTS PASSED`, with all three real directives exiting 0. Leave unchecked; do not reopen.
- [x] AC2 The brevity rules are testable: the skill includes a checklist an agent can self-audit against,
      and `ai-scoring` keeps its existing floor on the output.
      Met via [#39](https://github.com/noah-goodrich/claude-plugins/pull/39). The floor is recorded as measured
      numbers in `noah-writing-voice/validation/baselines/2026-08-20-baseline.md` rather than inherited, because
      the inherited 75 flags 5 of Noah's 10 published articles.
      Re-verified 2026-08-27. `noah-writing-voice/skills/brevity/SKILL.md:67` is the heading
      `## Self-audit checklist`; `references/portable-voice.md:161` is rule 17, "Run the self-audit before
      delivering". `noah-writing-voice/skills/ai-scoring/SKILL.md:27` defines the additive scanning mode and `:65`
      its report line. The baseline file states in its own words: "Five of the ten land below the 75 threshold the
      `snowflake-article` skill enforces." `noah-voice/SKILL.md:9` carries the one-line pointer to `brevity`.
      Merge commit `37c17e2` for [#39](https://github.com/noah-goodrich/claude-plugins/pull/39) is an ancestor of
      `main` (`git merge-base --is-ancestor 37c17e2 main` → LANDED).
- [x] AC3 `/pr-description` run against a real PR in this repo produces a body with all four blocks and
      correct chain position for a manifest-declared PR.
      Met across two runs, because no manifest existed in this repo when the skill shipped and none exists here
      now. Four blocks plus the `No manifest declared.` fallback were verified against
      [#38](https://github.com/noah-goodrich/claude-plugins/pull/38) in this repo. The manifest path was proven
      separately by the S4 evals in borg-collective (`evals/s4-k3/run.sh`, outputs in `evals/s4-k3/out/`): E4 ran
      against `stillpoint-labs/stillpoint#48` and rendered chain position from
      `.borg/programs/ingle-t1-cutover.json` — program `ingle-t1-cutover`, lane `cutover`, order 1, marked `next`,
      with blocks and blocked-by taken from the manifest's own entries — and E5 proved the fallback discriminator
      on a repo with no manifests. Both manifests are now tracked: stillpoint `90c6f63`, borg-collective `638b7c4`.
      Re-verified 2026-08-27. `git -C /Users/noah/dev/stillpoint merge-base --is-ancestor 90c6f63 main` → LANDED,
      and `git cat-file -e main:.borg/programs/ingle-t1-cutover.json` succeeds, so the manifest E4 read as untracked
      is now on `main`. `git -C /Users/noah/dev/borg-collective merge-base --is-ancestor 638b7c4 main` → LANDED;
      that commit adds `.borg/programs/viz-program.json`, `evals/s4-k3/run.sh` and `merge-tree/test_s4_manifests.py`.
      The two rendered bodies are still at `evals/s4-k3/out/e4-body.md` — chain position reads program
      `ingle-t1-cutover`, lane `cutover`, order 1, marked `next` — and `e5-body.md`, which carries the literal
      `No manifest declared.` line. `claude-plugins` still has no `.borg/programs` directory, so the fallback path
      remains the one this repo exercises. Closed by
      [#46](https://github.com/noah-goodrich/claude-plugins/pull/46), merge commit `d9efef6`, an ancestor of `main`.
- [x] AC4 All three ship through the normal plugin build; `claude plugin install` from noah-local loads them;
      CI green.
      Met, with one correction to the criterion's own assumption: `noah-local` is a directory-source marketplace,
      so plugins load live from the working tree and no install step is involved. `dist/*.plugin` matters only for
      distributing to other machines.
      Re-verified 2026-08-27. `gh pr checks 39 -R noah-goodrich/claude-plugins` reports every run green, including
      the new `design-doc validator suite` job. `.claude-plugin/marketplace.json` gives both plugins directory
      sources (`./noah-content-tools`, `./noah-writing-voice`) and descriptions that now name the new skills; both
      `.claude-plugin/plugin.json` files read `0.2.0`, up from the `0.1.31` the plan recorded.
      `.github/workflows/test.yml` lists `noah-content-tools/**` and `noah-writing-voice/**` in both the push and
      pull_request path filters and runs `bash noah-content-tools/skills/design-doc/test/run-tests.sh` as an
      explicit step.

## Non-Goals

- No branded lingo ("Smart Brevity", "Axios-style") in any output.
- No rewrite of existing noah-writing-voice rules; K2 layers on top.
- No auto-posting of PR bodies; K3 writes text, humans post it.

## Alternatives Considered

- **One mega writing skill**: rejected; the three trigger in different moments (planning, replying,
  shipping) and a single skill would load its full weight on every turn.
- **Encode the rules only in CLAUDE.md/memory**: rejected; the audit showed volunteered discipline decays.
  Skills load mechanically at the moment of use.
- **Adopt an off-the-shelf TRD generator**: none found that encodes reading mechanics (tl;dr placement,
  landing region) rather than section headings alone.
