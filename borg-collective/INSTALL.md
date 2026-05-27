# Installing borg-collective

The build output lives at `dist/borg-collective.plugin` (a zip-format `.plugin` bundle produced by
`./build-plugins.sh` at the repo root).

## What this plugin actually contains

**Skills (10)** — invoked via slash commands or auto-triggered by skill descriptions:
`borg-plan`, `borg-review`, `borg-assimilate`, `borg-link`, `borg-link-up`, `borg-collective-review`,
`simplify`, `adhd-guardrails` (always-on), `break-glass`, `no-unnecessary-read-perms`.

**Hooks (4)** — fire on Claude Code lifecycle events:
`bash-guard.sh` (PreToolUse on Bash), `pre-commit-remind.sh` (PreToolUse on Bash, matches `git commit`),
`tool-count-nudge.sh` (PostToolUse), `notify.sh` (Notification + Stop).

**No MCP servers.** This plugin does not expose MCP tools. The "read/write borg cards" capability
comes from skills like `borg-link` shelling out to the `cairn` CLI (when present on `PATH`) and
reading files under `~/.config/borg/` and project-level `.borg/` directories directly. If you want
MCP-tool-style live graph access, that's a separate plugin to build.

## Install via Cowork

1. Open Cowork.
2. Plugins panel → **Install plugin** (or drag `dist/borg-collective.plugin` onto the window).
3. Select `~/dev/claude-plugins/dist/borg-collective.plugin`.
4. Confirm the install dialog.

The build script's parting message ("Install .plugin files via Cowork UI (drag or 'Copy to your
skills')") is the canonical instruction.

## Verify it loaded

Skills (run any one of these in a Claude Code session inside Cowork):

```
/borg-plan
/borg-link
/simplify
```

Each should resolve to the plugin's skill description. `/borg-link` with no arguments prints a
multi-project overview built from `~/.config/borg/registry.json` and project `.borg/` directories.

Hooks (lightweight check — do not actually run destructive commands):

- Ask Claude to run `rm -rf ~` — `bash-guard.sh` should hard-block it with the message
  `Blocked: recursive delete of home or root directory`.
- Ask Claude to run `git commit -m "test"` — `pre-commit-remind.sh` should nudge to run `/simplify`
  first.
- After ~75 tool calls in a session, `tool-count-nudge.sh` should suggest a checkpoint.

If a hook never fires, the plugin probably loaded skills but did not register hooks — check that
`hooks/hooks.json` is included in the installed bundle and that `${CLAUDE_PLUGIN_ROOT}` resolved
correctly.

## Cross-project telemetry — caveats

The user-stated goal is for the Dispatch session AND sub-tasks spawned from Dispatch to read/write
borg cards live. This plugin enables that **only partially**:

1. **Dispatch session**: install the plugin once in Cowork's user-level plugins. The skills become
   available; `borg-link` reads the host-side `~/.config/borg/registry.json` and project
   `.borg/checkpoints/`. Writes happen when you (or Claude) invoke a skill that calls `cairn` — the
   plugin does not write opportunistically.

2. **Sub-tasks (Code tasks spawned from Dispatch)**: each sub-task runs in its own container. For
   the plugin to be loaded inside the sub-task, one of these has to be true:
   - **User-level plugin install in Cowork propagates to sub-task containers.** If Cowork mounts the
     user-level plugin directory into each spawned Code task, you're done — install once.
   - **Per-workspace install.** If sub-task containers do NOT inherit user-level plugins, the plugin
     has to be added at the workspace level (e.g. committed under `.claude/plugins/` in the
     workspace, or added via Cowork's per-workspace plugin config).
   - **Per-session install.** Worst case, each sub-task has to install the `.plugin` file on first
     run.

   I do not know which of these Cowork actually does — verify by spawning a Code task and running
   `/borg-link` inside it. If the skill resolves, propagation works. If not, fall back to per-
   workspace install.

3. **For sub-tasks to actually report findings back to a shared graph**, three things must all be
   true inside each sub-task container:
   - The plugin is loaded (skills available).
   - `cairn` CLI is on `PATH` inside the container.
   - The cairn data files (`~/.config/borg/` and `~/.config/cairn/`, if used) are bind-mounted into
     the container so reads and writes go to the same store as the host.

   If any of those three is missing, sub-tasks will appear to work but their writes won't surface
   in the host-side graph.

## Updating the plugin

After editing source under `borg-collective/`:

```
cd ~/dev/claude-plugins && ./build-plugins.sh
```

Then re-install `dist/borg-collective.plugin` in Cowork (it replaces the previous version). Bump
`borg-collective/.claude-plugin/plugin.json` `version` before re-publishing if you want the change
tracked across machines.
