---
id: plugin-skill-consolidation-with-thin-aliases
project: claude-plugins
domain: plugin-design
tags:
- refactoring
- backward-compatibility
- skills
- aliases
preconditions: []
steps:
- Identify overlapping skills with shared pipeline segments (e.g., evidence gathering).
- '`git mv` the canonical implementation to a new canonical location; verify byte-identity
  of the core pipeline before and after.'
- Add a Phase-0 mode selector block at the top of the new front-door skill.
- Implement new modes (e.g., decision-design, hybrid) as additional sections within
  the same skill file, delegating to sub-agents as needed.
- Replace old skill files with thin alias scripts (delegate + passthrough args) to
  preserve existing call sites.
- Update `plugin.json`, README, and version bump.
- 'Add test assertions covering: (a) the rename regex in any stop/transcript scripts,
  (b) each new mode''s non-blocking behavior.'
- Rebuild the `.plugin` dist artifact.
pitfalls:
- Stop/transcript scripts that match skill names by regex will silently miss the renamed
  skill if the regex is not updated — update and add a test assertion for it.
- Thin aliases must pass through all arguments; forgetting arg passthrough breaks
  callers that supply options.
- Bump the plugin version even if only skill files changed — dist consumers (Claude
  desktop UI) check the version to know whether to reload.
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:44:57.250126+00:00'
updated_at: '2026-06-30 20:44:57.250127+00:00'
---

# plugin-skill-consolidation-with-thin-aliases

## description

Consolidate overlapping skills into a single front-door skill with a mode selector, then replace the old skill files with thin aliases (~21 lines) that delegate to the new front door. Keeps the working pipeline byte-identical while improving UX.
