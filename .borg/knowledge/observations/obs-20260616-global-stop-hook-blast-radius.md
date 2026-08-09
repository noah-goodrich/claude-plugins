---
id: obs-20260616-global-stop-hook-blast-radius
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- research-tools
- directives
- hooks
- stop-hook
- scope
- blast-radius
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:02.493770+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260616-global-stop-hook-blast-radius

## content

A Stop hook registered globally (without scope guard) fires on every session end across all plugin operations, not just deep-research runs. The Dir-01 gate was initially registered this way, causing it to run — and potentially block — on every Stop event.

## resolution

Stop hooks that are feature-specific must include a scope guard (e.g., transcript-detect arming) to verify the hook is relevant to the current session before executing. Treat global Stop hooks as high-blast-radius and scope-guard by default.
