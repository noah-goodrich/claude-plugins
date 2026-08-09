---
id: 20260629-research-front-door-consolidation
date: '2026-06-30'
project: claude-plugins
domain: architecture
tags:
- claude-plugins
- research
- skill-design
- consolidation
- aliases
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260630-1814-claude-plugins
created_at: '2026-06-30 20:45:41.527871+00:00'
updated_at: '2026-06-30 20:45:41.527873+00:00'
---

# 20260629-research-front-door-consolidation

## decision

Collapse deep-research and brainstorm into thin 21-line aliases pointing to a single /research skill with a Phase-0 mode selector (evidence | decision-design | hybrid)

## context

Two overlapping research entry points (deep-research, brainstorm) created user confusion about which to invoke and duplicated maintenance surface

## reasoning

A single front door with an explicit mode selector is easier to discover, documents intent at the point of invocation, and keeps the evidence pipeline implementation in one place while preserving backward compatibility via aliases
