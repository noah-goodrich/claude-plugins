---
id: plugin-consolidation-with-thin-aliases
project: claude-plugins
domain: plugin-design
tags:
- consolidation
- aliases
- backward-compatibility
- skills
- git-mv
preconditions: []
steps:
- git mv the canonical plugin's source into skills/<domain>/ — preserves full git
  history
- Verify the moved skill is byte-identical in its core pipeline before adding new
  behavior
- Add a Phase-0 mode selector at the top of the canonical skill to route between old
  and new modes
- 'Replace each deprecated plugin file with a thin alias (target: ~21 lines) that
  simply invokes the canonical skill with the appropriate mode'
- Update any stop scripts / hooks so regex matches the new canonical name (e.g., deep-research-stop.sh
  regex matches 'research')
- Add test assertions for each alias and each mode in the test suite
- Run full hook test suite to confirm no regressions before shipping
pitfalls:
- Stop/hook scripts that match plugin names by exact string will silently fail to
  fire for the renamed skill — update regexes before shipping
- Byte-identity of the moved core pipeline is easy to accidentally break during the
  move; verify explicitly before adding new sections
- Aliases that are too thin (no mode hint) will route to the wrong default mode if
  the canonical skill's default changes later
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:46:23.708833+00:00'
updated_at: '2026-06-30 20:46:23.708833+00:00'
---

# plugin-consolidation-with-thin-aliases

## description

Consolidate multiple overlapping plugins into one canonical skill entry point while preserving old plugin names as thin aliases for backward compatibility
