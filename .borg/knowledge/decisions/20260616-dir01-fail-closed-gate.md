---
id: 20260616-dir01-fail-closed-gate
date: '2026-06-16'
project: claude-plugins
domain: architecture
tags:
- research-tools
- directives
- fail-closed
- gate
- deep-research
alternatives: []
applies_to: []
confidence: 0.9
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260614-1512-claude-plugins
created_at: '2026-06-16 10:27:02.491387+00:00'
updated_at: '2026-06-16 10:27:02.491388+00:00'
---

# 20260616-dir01-fail-closed-gate

## decision

Directive 01 ground gate is fail-closed: if the gate check errors or is ambiguous, the deep-research run is blocked, not allowed

## context

Meta-research review identified that a fail-open gate would allow unconstrained research runs even when quality controls are unavailable, defeating the purpose of the directive system

## reasoning

Safety/quality controls that fail open provide false assurance. A blocked run surfaces the problem immediately; a silently-passed run with broken controls produces low-quality output that may not be caught.
