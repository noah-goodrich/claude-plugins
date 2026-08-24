# Directive: Design-Doc and Brevity Skills

*Filed: 2026-08-20 · Status: Accepted, shipped 2026-08-21 · Parent: 2026-08-20-communication-program.md (borg-collective)*

**tl;dr** — Every proposal, PR description, and long chat reply is shaped from scratch each time, so quality
depends on the agent remembering how Noah reads. Ship three skills in the noah-writing-voice / research-tools
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

## Acceptance criteria

These four were the criteria as filed. They were amended during planning and the amended set is the one that was
actually built and verified — see `docs/plans/assimilated/2026-08-21-design-doc-brevity-pr-description-skills.md`,
which carries six criteria, all met, plus a "What the Plan Got Wrong" section. The boxes below are marked against
the criteria *as written here*, which is why AC1 does not close.

- [ ] AC1 `/design-doc` produces the template with all seven sections and refuses to emit one without a
      tl;dr; the umbrella + delivery-surfaces directives (borg-collective, 2026-08-20) validate against it.
      **Superseded, not met as worded.** The seven-section template does not exist in practice: the umbrella
      directive carries `Goals` and `Decisions requested` and no acceptance criteria, while both children carry
      `Acceptance criteria` and neither has `Goals`. The shipped template requires five sections plus exactly one
      outcome section, which all three real directives pass. Decision D1 in the assimilated plan.
- [x] AC2 The brevity rules are testable: the skill includes a checklist an agent can self-audit against,
      and `ai-scoring` keeps its existing floor on the output.
      Met via [#39](https://github.com/noah-goodrich/claude-plugins/pull/39). The floor is recorded as measured
      numbers in `noah-writing-voice/validation/baselines/2026-08-20-baseline.md` rather than inherited, because
      the inherited 75 flags 5 of Noah's 10 published articles.
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
- [x] AC4 All three ship through the normal plugin build; `claude plugin install` from noah-local loads them;
      CI green.
      Met, with one correction to the criterion's own assumption: `noah-local` is a directory-source marketplace,
      so plugins load live from the working tree and no install step is involved. `dist/*.plugin` matters only for
      distributing to other machines.

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
