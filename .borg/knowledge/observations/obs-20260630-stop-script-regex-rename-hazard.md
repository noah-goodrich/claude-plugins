---
id: obs-20260630-stop-script-regex-rename-hazard
session_date: '2026-06-30'
project: claude-plugins
tool: claude-code
tags:
- claude-plugins
- stop-scripts
- regex
- rename
- hooks
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:45:41.535765+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260630-stop-script-regex-rename-hazard

## content

deep-research-stop.sh contained a regex matching the literal string 'deep-research'. After git mv to skills/research/, the stop script would have silently stopped firing for the renamed skill. The fix was to broaden the regex to match 'research' instead of the full original name.

## resolution

Whenever a skill is renamed or moved, audit all stop-scripts and hook scripts for hardcoded name patterns and update them in the same PR. Add a test assertion that the stop-script fires on the new canonical name.
