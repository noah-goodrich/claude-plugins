---
id: obs-20260630-borg-researcher-reviewer-agents-require-plugin-active
session_date: '2026-06-30'
project: claude-plugins
tool: claude-code
tags:
- borg-collective
- borg-researcher
- borg-reviewer
- dependency
- plugins
category: gotcha
files_involved: []
confidence: 0.7
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:44:57.259727+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260630-borg-researcher-reviewer-agents-require-plugin-active

## content

The new `/research` decision-design mode delegates to `borg-researcher` and `borg-reviewer` sub-agents, which live in the `borg-collective` plugin. If `borg-collective` is not reinstalled (or is on an older version), the delegation calls will silently fail or produce 'unknown command' errors — with no obvious error message pointing at the version mismatch.

## resolution

Treat reinstall of `borg-collective` (0.8.4) as a hard prerequisite before smoke-testing `/research` in decision-design mode. The smoke-test itself (delegating to borg-researcher + checking the `NOT design-reviewed` stamp) will surface the failure, but it's faster to reinstall all three plugins atomically before testing any of them.
