---
id: 20260610-directive-lifecycle-assimilation
date: '2026-06-16'
project: claude-plugins
domain: architecture
tags:
- directives
- project-management
- documentation
- borg-collective
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260614-1512-claude-plugins
created_at: '2026-06-16 10:27:03.993016+00:00'
updated_at: '2026-06-16 10:27:03.993019+00:00'
---

# 20260610-directive-lifecycle-assimilation

## decision

Move shipped directives 01–06 to assimilated/ subdirectory rather than deleting them or keeping them in place; directive 07 stays pending.

## context

No PROJECT_PLAN.md exists for the deep-research/brainstorm work — it lives as docs/brainstorms/2026-06-05-next-gen-research-invention.md feeding directives 01–07. Question arose about how to close out shipped work without losing history.

## reasoning

Assimilation preserves rationale/history for audits while clearly signaling completion state. Avoids the ambiguity of in-place directives that are 'done but not marked'.
