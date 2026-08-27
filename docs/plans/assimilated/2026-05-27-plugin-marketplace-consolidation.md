# PROJECT_PLAN — Plugin Marketplace Consolidation

**Status:** ⚠️ ASSIMILATED WITH UNMET CRITERIA — archived 2026-07-01. Criteria 1, 3 and 6 are met and
independently re-verified on `main` (C6 resolved: borg-collective repo = source, claude-plugins =
marketplace/build target per D1). Criterion 2 is met in practice but is **not** verifiable from repo state —
`dist/` is gitignored and has never been tracked, so the "verifiable from repo state" promise in the heading
below does not hold for it. Criteria 4 and 5 were signed off against commits that never reached `main` and
are NOT met — see the audit note on each. This archive is kept as the historical record of what was
intended; it is not evidence that 4 and 5 shipped.
*Corrected 2026-08-21 by the phantom-citation audit, merged as
[#42](https://github.com/noah-goodrich/claude-plugins/pull/42) (`f4212aa`, merged 2026-08-24).
Re-verified 2026-08-27: the C4/C5 audit notes hold, but C5's PR-state claim had gone stale and C2's
"verifiable from repo state" framing was wrong — both corrected below.*
**Drafted:** 2026-05-27 by borg link-up agent
**Supersedes:** none (first PROJECT_PLAN.md for this repo)

## Objective

Consolidate `claude-plugins` as the canonical marketplace for Noah's Claude Code
plugins, with seven plugins published, all built into `dist/` as installable
`.plugin` artifacts, and `borg-collective` fully extracted from its standalone
repo with a clear source-of-truth.

## Scope

In: marketplace structure, plugin extraction and packaging, deep-research v3,
voice + AI-scoring dual-axis recalibration, validation corpus.

Out: building new plugins, expanding to non-Noah authors, switching from
local marketplace to a remote registry.

## Acceptance criteria (verifiable from repo state)

1. **Marketplace registers seven plugins.** `.claude-plugin/marketplace.json`
   includes `borg-collective`, `dev-tools`, `noah-content-tools`,
   `noah-strategy`, `noah-writing-voice`, `research-tools`, `token-cost`.
   *Status: MET as of `234cdab`.*
   *Verified 2026-08-27: `git merge-base --is-ancestor 234cdab main` → LANDED (`234cdab` is the merge commit
   of [#4](https://github.com/noah-goodrich/claude-plugins/pull/4), merged 2026-05-27).
   `git show 234cdab:.claude-plugin/marketplace.json` lists exactly those seven plugin entries;
   `git show main:.claude-plugin/marketplace.json` still lists all seven, plus an eighth (`code-governance`)
   added after this plan. "Seven" was a floor, not a cap — the criterion as written is satisfied.*

2. **Seven built artifacts exist in `dist/`.** `dist/*.plugin` directories or
   archives exist for each of the seven plugins. *Status: met — `dist/` lists
   seven `.plugin` entries.*
   *Corrected 2026-08-27: MET IN PRACTICE, BUT NOT VERIFIABLE FROM REPO STATE. `dist/` is the first line of
   `.gitignore` and has never been tracked: `git ls-tree -r main dist/` returns nothing, and the path does
   not exist in a fresh checkout. The original sign-off was reading a local build directory, not the repo.
   Against the live build at `/Users/noah/dev/claude-plugins/dist/` the claim does hold — it contains eight
   `.plugin` directories including all seven named here (plus `code-governance.plugin`), produced by the
   tracked `build-plugins.sh`. So the deliverable exists, but this criterion can never be checked the way
   the section heading promises; a future restatement should assert `build-plugins.sh` succeeds rather than
   assert the contents of an ignored directory.*

3. **`borg-collective` extracted with manifest + hooks + 10 skills.** Plugin
   manifest at `borg-collective/.claude-plugin/plugin.json`, four lifecycle
   hooks (`bash-guard.sh`, `notify.sh`, `pre-commit-remind.sh`, `hooks.json`),
   and 10 publishable skills.
   *Status: MET as of [#4](https://github.com/noah-goodrich/claude-plugins/pull/4) (`234cdab`).*
   *Verified 2026-08-27 against the commit itself, not the prose: `git ls-tree 234cdab
   borg-collective/.claude-plugin/` → `plugin.json` present; `git ls-tree 234cdab borg-collective/hooks/` →
   all four named files present (`bash-guard.sh`, `notify.sh`, `pre-commit-remind.sh`, `hooks.json`, plus
   `tool-count-nudge.sh`); `git ls-tree 234cdab borg-collective/skills/` → exactly 10 skill directories.
   Still true on `main`, where the plugin has since grown more hooks and skills.*

4. **Deep-research v3 ships gates 1-14.** `research-tools/skills/deep-research/`
   reflects all 14 compliance gates; SKILL.md references them.
   *Status: NOT MET (audited 2026-08-21). Originally signed off as "met as of `10b962b` (gate 14)", but
   `10b962b` lives only on `feat/skill-v3-research-quality-2026-05-25` and is not an ancestor of `main`;
   [#5](https://github.com/noah-goodrich/claude-plugins/pull/5) was CLOSED without merging. Verified by
   content too: `git grep -oiE "gate [0-9]+" main -- research-tools` returns nothing, so the numbered-gate
   scheme never existed on `main` — research-tools was later rebuilt on a different architecture. Hash and
   original wording retained for the trail.*
   *Re-verified 2026-08-27, independently of the above: `git merge-base --is-ancestor 10b962b main` →
   NOT-ON-MAIN. `gh pr view 5` → `{"state":"CLOSED","mergedAt":null}`, closed 2026-08-21 from branch
   `feat/skill-v3-research-quality-2026-05-25`. `git grep -oiE "gate [0-9]+" main -- research-tools` returns
   nothing; a broader `git grep -in gate main -- research-tools` shows only the current architecture's
   named gates (fail-closed ground gate, Directive 01 gate) — no numbered 1-14 scheme. `main` now carries
   `research-tools/skills/{research,deep-research,brainstorm}`, where `deep-research/SKILL.md` is a thin
   alias delegating to the unified `research` skill. The v3 gate design was superseded, not shipped.*

5. **Voice + AI-scoring dual-axis framework live.** `noah-writing-voice/skills/`
   contains both `noah-voice` and `ai-scoring` skills, with `ai-scoring`
   redesigned to a dual-axis (humanness × Noah-voice fidelity) model.
   *Status: NOT MET (audited 2026-08-21). Originally signed off as "met as of `9c3c320` + `a7fe56e`", but
   both commits live only on `feat/voice-ai-scoring-recalibration-2026-05-23` and neither is an ancestor of
   `main`; [#2](https://github.com/noah-goodrich/claude-plugins/pull/2) was OPEN at the time of that audit.
   Verified by content too: `git grep -i dual-axis main -- noah-writing-voice/skills/ai-scoring/SKILL.md`
   returns nothing. Hashes and original wording retained for the trail.*
   *Re-verified and amended 2026-08-27. Two corrections to the note above:*
   *(a) The PR state is stale — `gh pr view 2` now returns `{"state":"CLOSED","mergedAt":null}`, closed
   2026-08-26 without ever merging. So this criterion is not merely unshipped, it is abandoned: both PRs
   that carried it ([#2](https://github.com/noah-goodrich/claude-plugins/pull/2) here and
   [#5](https://github.com/noah-goodrich/claude-plugins/pull/5) for criterion 4) are closed unmerged.*
   *(b) The criterion is only half-unmet, and the note should say so. The first clause IS satisfied:
   `git ls-tree main noah-writing-voice/skills/` → `ai-scoring`, `brevity`, `noah-voice`, so both named
   skills do ship. It is the second clause — the dual-axis (humanness × Noah-voice fidelity) redesign —
   that never landed: `git grep -il dual-axis main -- noah-writing-voice/` returns nothing at all, and the
   shipped `ai-scoring` still scores on the single 0-100 humanness axis.*
   ***Superseded** as written: the dual-axis model will not be met by this plan. `brevity` was added to
   `noah-writing-voice` instead, splitting scanning-document prose from article prose — a different answer
   to the same problem. The design itself survives as a proposal in
   `docs/plans/directives/2026-05-27-voice-ai-scoring-dual-axis.md`, which is itself stamped "NOT IN EFFECT
   — proposed only, never adopted". Reopen it there if the model is still wanted; do not mark this one met.*

6. **borg-collective source-of-truth resolved.** A directive at
   `docs/plans/directives/2026-05-27-borg-cairn-coordination.md` (or a
   subsequent decision) names one repo as canonical for borg-collective skill
   files, and the other as a downstream consumer.
   *Status: MET (2026-07-01) — DECIDED: the standalone borg-collective repo is canonical/source for the
   borg-collective plugin; claude-plugins is the marketplace/build target (holds a synced mirror). The
   other 6 plugins are native to claude-plugins.*
   *Verified 2026-08-27 by reading the artifact, not the claim: `git ls-tree -r main
   docs/plans/directives/` confirms `2026-05-27-borg-cairn-coordination.md` is on `main`. Its Status is
   "Confirmed 2026-05-27" and its "What" section decision 1 reads: "`~/dev/borg-collective/` is the
   canonical home for all skill files and hooks. `claude-plugins/borg-collective/` distributes the
   publishable subset — it never originates edits." That matches the Status line above exactly, including
   the privacy-boundary exclusion list that makes claude-plugins a subset rather than a full mirror.*

## Non-goals (explicit)

- Migrating to a hosted marketplace.
- Adding new plugin authors.
- Replacing the local `build-plugins.sh` with a CI workflow (separate concern).

## Open questions for Noah

*These were open at drafting. Their state as of 2026-08-27 is annotated inline.*

- Confirm criterion 6's resolution: is `claude-plugins` or `borg-collective`
  canonical?
  *RESOLVED — `borg-collective` is canonical; see criterion 6 and the D1 directive at
  `docs/plans/directives/2026-05-27-borg-cairn-coordination.md`.*
- Should INSTALL.md live in each plugin folder (currently only
  `borg-collective/INSTALL.md` exists), or only on the marketplace README?
  *STILL OPEN — never decided, and nothing changed. `git ls-tree -r main | grep INSTALL.md` on 2026-08-27
  still returns exactly one plugin-level file, `borg-collective/INSTALL.md`. Carry it forward if it matters.*
- Is the voice/AI-scoring validation corpus in scope here, or does it belong in
  its own plan?
  *MOOT — the dual-axis work this corpus would have validated was abandoned with
  [#2](https://github.com/noah-goodrich/claude-plugins/pull/2); see criterion 5.*
