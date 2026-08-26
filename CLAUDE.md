# claude-plugins

The plugin marketplace. `noah-local` is a **directory source** pointing at this working tree
(`~/.claude/settings.json` → `extraKnownMarketplaces`), so every plugin here loads **live from the checked-out
branch**. There is no install step and no `~/.claude` fallback — `borg setup` stopped copying skills and agents
there. `dist/*.plugin` exists only to hand plugins to another machine; nothing local reads it.

**Consequence: the checked-out branch is production config for every Claude session on this machine.** An
uncommitted change here is already live, and a branch switch changes what every new session loads.

## `borg-collective/` is generated. Never edit it here.

`borg-collective/skills/` and `borg-collective/agents/` are build output. The source of truth is
`~/dev/borg-collective`, and `scripts/build-plugin.sh` in that repo generates this copy. Editing them here
produces a change that the next build silently overwrites, and that no one reviewing the source repo will ever see.

To change a borg skill, agent, or hook: edit it in `~/dev/borg-collective`, run its `scripts/build-plugin.sh`, then
commit the regenerated output here.

The hooks legitimately differ from their source: the build inlines `lib/borg-hooks.sh` and `reaper.sh` into them,
so a mirrored hook is longer than its source file. That is expected output, not drift.

**Three paths under `borg-collective/` are hand-maintained and are not generated:**

- `borg-collective/README.md`
- `borg-collective/INSTALL.md`
- `borg-collective/hooks/test/`

Everything else under `borg-collective/` is generated. If that list grows, the rule stops meaning anything — prefer
moving a file into the source repo over adding a fourth exception.

## Everything else here is authored in place

The other plugins (`noah-writing-voice`, `noah-content-tools`, `research-tools`, `dev-tools`, `token-cost`,
`noah-strategy`, `code-governance`) have no upstream. Edit them here.

## Adding or changing a plugin

Every plugin needs both halves or it is unreachable: an entry in `.claude-plugin/marketplace.json` (how an
installer finds it) and its own `.claude-plugin/plugin.json` (what gets installed). `build-plugins.sh` verifies
both directions and refuses to build if either is missing — that guard exists because `code-governance` was listed
and uninstallable for six weeks without anything noticing.

Versions in `plugin.json` are bumped by hand. Nothing derives them, and nothing else will catch a skipped bump.

## CI

`.github/workflows/test.yml` triggers on explicit path filters and every job names an exact file — there is no
discovery glob. **A new test does not run until you add both its path filter and a step that invokes it.**
