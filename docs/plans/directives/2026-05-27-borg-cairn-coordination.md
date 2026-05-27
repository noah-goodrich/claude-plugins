# Directive — borg ↔ cairn Coordination & Source-of-Truth

**Created:** 2026-05-27
**Scope:** `borg-collective` plugin within this repo, the standalone
`~/dev/borg-collective` repo, and the `~/dev/cairn` graph-backend repo
**Status:** Confirmed 2026-05-27

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

1. **Source-of-truth:** `~/dev/borg-collective/` is the canonical home for all
   skill files and hooks. `claude-plugins/borg-collective/` distributes the
   **publishable subset** — it never originates edits. See the privacy boundary
   below for what is and isn't included in the plugin.
2. **cairn coupling:** borg skills treat cairn as **optional**. If
   `~/.cairn/` is present, skills use it for graph storage; otherwise they
   degrade gracefully to filesystem-only mode. No skill hard-requires cairn.

Decision confirmed 2026-05-27. Source: original Dispatch session `f9ef8d07`
(2026-05-24) that created the plugin — the instruction explicitly named
`~/dev/borg-collective/` as the source repo and defined an exclusion list
(CLI machinery, registry, research docs, private paths) as the privacy boundary.

## How to apply

**Editing borg-collective skills:**
- Edit in `~/dev/borg-collective/skills/<skill>/SKILL.md` — that is the
  source of truth.
- Never edit directly in `~/dev/claude-plugins/borg-collective/skills/` —
  it is a derived copy and changes will be overwritten on the next promote.

**Writing new borg skills:**
- Write and iterate in `~/dev/borg-collective/` (research branch if needed).
- When stable and safe to distribute (passes the privacy boundary check below),
  copy into `~/dev/claude-plugins/borg-collective/skills/` and rebuild
  `dist/borg-collective.plugin`. Reference the source commit in the promotion
  PR.

**Privacy boundary — what must NOT be promoted to claude-plugins:**
- Skills that reference private paths, JIRA configs, or work-machine specifics
- Skills or hooks that require the `borg`/`drone` CLI at runtime
- Any content flagged in `PRIVACY-AUDIT-2026-05-23.md`

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
