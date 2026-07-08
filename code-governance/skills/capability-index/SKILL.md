---
name: capability-index
description: "Scan a project's domain layer and emit a capability index — a machine- and human-readable map of every exported pure function: name, signature, one-line intent, invariants, and caller surfaces. Use this skill when the user wants to audit, document, or index the domain functions in a project, says 'what capabilities does the domain layer expose', 'build a capability index', 'document the domain functions', 'what does src/lib/domain export', or wants to check for duplicate/missing capability coverage. Also trigger before adding a new domain function, to verify the capability does not already exist."
---

# Capability Index

Scan a TypeScript domain directory and emit a capability index: a markdown table + JSON file
cataloguing every exported function's name, signature, intent, invariants, and caller surfaces.
Generalizes ingle's `src/lib/domain/` pattern to any project following the single-source-of-truth
pure-compute convention.

## When to Run

- Before adding a new derived-value function — confirm the capability does not already exist.
- After a batch of new domain functions land — refresh the index so the team can see what's owned.
- During a governance audit — find functions with no doc, no invariant annotation, or no caller map.

## Phase 1: Locate the domain directory

If the user named a directory, use it. Otherwise look for common patterns in this order:

1. `src/lib/domain/`
2. `src/domain/`
3. `lib/domain/`
4. `packages/domain/src/`

If none exists, ask the user where the pure compute functions live before proceeding.

## Phase 2: Run the generator

The generator lives at:
`/Users/noah/dev/claude-plugins/code-governance/bin/capability-index.mjs`

Run it against the target directory:

```zsh
node /Users/noah/dev/claude-plugins/code-governance/bin/capability-index.mjs \
  <target-dir> \
  --out-dir <project-root>/docs/capability-index
```

- `<target-dir>` — the domain directory identified in Phase 1 (absolute path).
- `--out-dir` — where to write `capability-index.md` and `capability-index.json`. Default is
  `<target-dir>/../../../docs/capability-index` (works for `src/lib/domain/` → `docs/`).

If the host cannot run Node (container-only project), emit the exact `drone exec` command instead:

```zsh
drone exec <project-name> -- node \
  /Users/noah/dev/claude-plugins/code-governance/bin/capability-index.mjs \
  <container-target-dir> --out-dir <container-out-dir>
```

## Phase 3: Surface findings

After the generator runs, read both output files and report:

1. **Count** — total functions, total modules.
2. **Missing docs** — functions where intent is `(no doc comment found)`. List them.
3. **No invariant** — functions with no "Pure. No I/O." annotation. These may have hidden I/O
   or caller-responsibility gaps.
4. **No caller map** — functions where both `caller_pwa` and `caller_mcp` are null. May be
   unused or caller-map comment is missing.
5. **Potential duplicates** — two functions with similar intent sentences. Flag for review.

Show the summary table from the markdown file inline for the user. Offer to open the full file.

## Hard Rules

- Never invent function signatures. Parse only — no guessing from names alone.
- Never modify source files. The generator is read-only.
- If a file has no exported functions, note it (could be a type-only or re-export module).
- The index is a snapshot. Note the timestamp and remind the user to re-run after schema changes.

## Output locations (defaults for ingle)

| File | Path |
|---|---|
| Markdown index | `/Users/noah/dev/ingle/docs/capability-index/capability-index.md` |
| JSON index | `/Users/noah/dev/ingle/docs/capability-index/capability-index.json` |
