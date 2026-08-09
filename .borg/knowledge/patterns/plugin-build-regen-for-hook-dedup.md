---
id: plugin-build-regen-for-hook-dedup
project: claude-plugins
domain: infrastructure
tags:
- claude-code
- plugins
- build
- hooks
- deduplication
preconditions: []
steps:
- Identify duplicate hook entries in `~/.claude/settings.json` (typically from repeated
  installs or plugin updates)
- Run `build-plugin.sh` to regenerate the canonical plugin manifest
- Run `borg setup` (or equivalent install command) which applies de-dup logic during
  settings merge
- Verify 248/248 bats pass (or equivalent test suite) to confirm no data-loss regression
- Confirm `session-log.sh` and other user-defined hooks survive the de-dup pass
pitfalls:
- 'De-dup over-removal is a real failure mode: if the de-dup code removes all copies
  instead of N-1, user hooks are silently deleted (see #45)'
- Always run regression tests after de-dup changes before deploying to additional
  machines
- 'Closing a superseded PR (e.g., #9 superseded by clean regen) is correct hygiene
  — don''t merge both'
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:02.526836+00:00'
updated_at: '2026-06-16 10:27:02.526836+00:00'
---

# plugin-build-regen-for-hook-dedup

## description

Use a clean `build-plugin.sh` regen to resolve hook duplication in settings.json rather than manual editing
