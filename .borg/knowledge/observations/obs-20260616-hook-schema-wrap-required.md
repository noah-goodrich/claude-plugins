---
id: obs-20260616-hook-schema-wrap-required
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- research-tools
- directives
- hooks
- schema
- plugin-load
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:02.493412+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260616-hook-schema-wrap-required

## content

On real plugin load (vs. unit test), the Dir-01 Stop hook failed because the hook registration didn't wrap the handler in the schema shape the hook system expects. The bug was invisible in isolated tests but surfaced immediately on /reload-plugins.

## resolution

Always wrap hook handlers in the schema shape required by the hook system. Test by actually loading the plugin via /reload-plugins in a live session, not only via isolated unit tests.
