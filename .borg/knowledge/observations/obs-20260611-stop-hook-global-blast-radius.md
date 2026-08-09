---
id: obs-20260611-stop-hook-global-blast-radius
session_date: '2026-06-11'
project: claude-plugins
tool: cursor
tags:
- research-tools
- hooks
- stop-hook
- blast-radius
- scope
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260610-1742-claude-plugins
superseded_by: null
created_at: '2026-06-11 22:41:19.513367+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260611-stop-hook-global-blast-radius

## content

A globally-registered Stop hook in a Claude plugin fires on ALL stop events across the entire session, not just those from the registering plugin. This caused the Directive 01 gate to intercept unrelated plugin stop events.

## resolution

Always add a context/scope guard inside global Stop hook handlers to check whether the current session context is relevant before taking action.
