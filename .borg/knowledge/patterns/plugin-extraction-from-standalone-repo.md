---
id: plugin-extraction-from-standalone-repo
project: claude-plugins
domain: plugin-architecture
tags:
- extraction
- plugin
- marketplace
- multi-repo
preconditions: []
steps:
- 'Identify the publishable skills in the source repo; scope to a discrete set (here:
  10 skills)'
- Add lifecycle hooks and plugin registration in the source plugin directory
- Add a plugin manifest (e.g., plugin.json or equivalent)
- Register the plugin in marketplace.json
- Build the .plugin artifact into dist/
- Add a README in the plugin directory
- Open a cross-project directive doc capturing the source-of-truth ambiguity before
  it becomes implicit
- Merge as a standalone PR; do not bundle with other feature work
pitfalls:
- Both repos will contain skill sources after extraction — this is an unstable state.
  If not documented explicitly, future contributors will make conflicting edits in
  both places.
- Skipping the directive doc means the source-of-truth decision gets made implicitly
  by whoever edits next, not deliberately.
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260610-1742-claude-plugins
superseded_by: null
created_at: '2026-06-11 20:31:25.848876+00:00'
updated_at: '2026-06-11 20:31:25.848877+00:00'
---

# plugin-extraction-from-standalone-repo

## description

How to extract a skill/plugin from a standalone repo into the claude-plugins marketplace without resolving cross-repo source-of-truth immediately
