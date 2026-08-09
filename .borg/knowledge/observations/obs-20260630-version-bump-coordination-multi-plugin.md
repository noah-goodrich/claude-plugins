---
id: obs-20260630-version-bump-coordination-multi-plugin
session_date: '2026-06-30'
project: claude-plugins
tool: claude-code
tags:
- claude-plugins
- versioning
- multi-plugin
- release-coordination
category: domain_knowledge
files_involved: []
confidence: 0.7
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:45:41.537468+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260630-version-bump-coordination-multi-plugin

## content

This session touched three separate versioned plugins in two PRs: borg-collective (→0.8.4), token-cost (→0.1.34), and research-tools (→0.3.0). Each needed its own rebuild into dist/ and reinstall into Claude desktop before the acceptance test was valid. Partial reinstalls (only some plugins rebuilt) would have produced misleading acceptance results.

## resolution

When a session spans multiple plugins, treat rebuild+reinstall as an atomic step across all changed plugins before running any live acceptance test. Track which plugins were touched in the PR description to make this checklist explicit.
