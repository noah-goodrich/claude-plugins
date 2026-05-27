# Directive — borg ↔ cairn Coordination & Source-of-Truth

**Created:** 2026-05-27
**Scope:** `borg-collective` plugin within this repo, the standalone
`~/dev/borg-collective` repo, and the `~/dev/cairn` graph-backend repo
**Status:** Operational rule, decision component pending Noah confirmation

## Why

After PR #4 (`234cdab`), borg-collective exists in two places:

- `~/dev/claude-plugins/borg-collective/` — the publishable plugin with
  manifest, hooks, and 10 skills, packaged into
  `dist/borg-collective.plugin`.
- `~/dev/borg-collective/` — the original standalone repo with research
  branches (`research/agent-teams-2026-05-23`) and its own skills directory.

Both repos can drift. Without a stated source-of-truth, edits land in
whichever repo the active session opens first, and the published `.plugin`
artifact loses sync with the canonical skills.

Separately, cairn (the optional graph backend at `~/dev/cairn`) provides
knowledge-graph storage that several borg skills (`borg-search`,
`borg-link`, `borg-next`) call into when present. The `cairn-mcp-phase1`
branch is approaching merge. borg skills need to know whether to require,
prefer, or treat cairn as fully optional.

## What

Two coordinated decisions:

1. **Source-of-truth:** designate `claude-plugins/borg-collective/` as the
   canonical home for the publishable plugin's skill files and hooks.
   `~/dev/borg-collective/` remains the research repo where new skills
   incubate before being promoted into the plugin.
2. **cairn coupling:** borg skills treat cairn as **optional**. If
   `~/.cairn/` is present, skills use it for graph storage; otherwise they
   degrade gracefully to filesystem-only mode. No skill hard-requires cairn.

Both decisions are **proposed** in this directive. Noah confirms by either
leaving this file in place after PR merge, or amending it with the actual
decision.

## How to apply

**Editing borg-collective skills:**
- Edit in `~/dev/claude-plugins/borg-collective/skills/<skill>/SKILL.md`.
- If the edit originates from research in `~/dev/borg-collective/`,
  port it across explicitly with a commit message referencing the source
  commit.
- Never edit only in `~/dev/borg-collective/` and expect the plugin to
  pick it up — there is no auto-sync.

**Writing new borg skills:**
- Incubate in `~/dev/borg-collective/` on a research branch.
- When stable, copy into `~/dev/claude-plugins/borg-collective/skills/`
  and rebuild `dist/borg-collective.plugin`.
- Reference both commits in the promotion PR.

**cairn integration in borg skills:**
- Wrap cairn calls in a `cairn_available()` check.
- On absence, log a single-line notice and continue with filesystem
  fallback. Do not error.
- Do not import cairn libraries at module top-level — defer to lazy import
  inside the availability check.

## Open questions

- Should `~/dev/borg-collective/` be archived once the plugin stabilizes,
  or kept as the long-term research repo?
- When cairn ships v0.1.0 (per `~/dev/cairn` PROJECT_PLAN), should any
  borg skills upgrade to **prefer** cairn (warn on absence) rather than
  remain fully optional?

## References

- `~/dev/claude-plugins/borg-collective/.claude-plugin/plugin.json`
- `~/dev/borg-collective/` (research branch
  `research/agent-teams-2026-05-23`)
- `~/dev/cairn/` (`feat/cairn-mcp-phase1-2026-05-24`)
- PR #4 (`234cdab Extract borg-collective plugin`)
