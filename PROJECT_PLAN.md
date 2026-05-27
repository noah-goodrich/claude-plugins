# PROJECT_PLAN — Plugin Marketplace Consolidation

**Status:** Proposed, awaiting Noah confirmation
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
   *Status: met as of `234cdab`.*

2. **Seven built artifacts exist in `dist/`.** `dist/*.plugin` directories or
   archives exist for each of the seven plugins. *Status: met — `dist/` lists
   seven `.plugin` entries.*

3. **`borg-collective` extracted with manifest + hooks + 10 skills.** Plugin
   manifest at `borg-collective/.claude-plugin/plugin.json`, four lifecycle
   hooks (`bash-guard.sh`, `notify.sh`, `pre-commit-remind.sh`, `hooks.json`),
   and 10 publishable skills. *Status: met as of PR #4 (`234cdab`).*

4. **Deep-research v3 ships gates 1-14.** `research-tools/skills/deep-research/`
   reflects all 14 compliance gates; SKILL.md references them. *Status: met as
   of `10b962b` (gate 14); pending verification that the three uncommitted
   SKILL.md / template edits don't regress.*

5. **Voice + AI-scoring dual-axis framework live.** `noah-writing-voice/skills/`
   contains both `noah-voice` and `ai-scoring` skills, with `ai-scoring`
   redesigned to a dual-axis (humanness × Noah-voice fidelity) model.
   *Status: met as of `9c3c320` + `a7fe56e`.*

6. **borg-collective source-of-truth resolved.** A directive at
   `docs/plans/directives/2026-05-27-borg-cairn-coordination.md` (or a
   subsequent decision) names one repo as canonical for borg-collective skill
   files, and the other as a downstream consumer.
   *Status: open — directive drafted, decision pending.*

## Non-goals (explicit)

- Migrating to a hosted marketplace.
- Adding new plugin authors.
- Replacing the local `build-plugins.sh` with a CI workflow (separate concern).

## Open questions for Noah

- Confirm criterion 6's resolution: is `claude-plugins` or `borg-collective`
  canonical?
- Should INSTALL.md live in each plugin folder (currently only
  `borg-collective/INSTALL.md` exists), or only on the marketplace README?
- Is the voice/AI-scoring validation corpus in scope here, or does it belong in
  its own plan?
