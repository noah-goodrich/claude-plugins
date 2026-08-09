---
id: 20260611-dir01-stop-hook-scope-guard
date: '2026-06-11'
project: claude-plugins
domain: code-quality
tags:
- research-tools
- directive-01
- hooks
- stop-hook
- blast-radius
alternatives: []
applies_to: []
confidence: 0.9
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260610-1742-claude-plugins
created_at: '2026-06-11 22:41:19.511659+00:00'
updated_at: '2026-06-11 22:41:19.511659+00:00'
---

# 20260611-dir01-stop-hook-scope-guard

## decision

Add a scope guard to the global Stop hook in Directive 01 to limit blast radius to research-tools plugin context only.

## context

The Stop hook was defined globally and would intercept stop events from all plugins/contexts, not just research-tools. This surfaced as a real bug on plugin load.

## reasoning

Stop hooks without scope guards affect the entire Claude session. A context check ensures the gate only activates when a research-tools session is active, preventing interference with other plugins.
