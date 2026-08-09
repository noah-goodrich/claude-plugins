---
id: obs-20260611-dir01-hook-schema-wrap
session_date: '2026-06-11'
project: claude-plugins
tool: cursor
tags:
- research-tools
- directive-01
- hooks
- schema
- plugin-load
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260610-1742-claude-plugins
superseded_by: null
created_at: '2026-06-11 22:41:19.513027+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260611-dir01-hook-schema-wrap

## content

The Directive 01 hook registration used bare handler syntax that failed schema validation on real plugin load (not caught in isolation testing). The hook schema requires a specific wrap/registration format.

## resolution

Wrap hook handlers in the schema-required registration format. Always do a live plugin load smoke test (not just unit/adversarial tests) before considering a hook-based directive complete.
