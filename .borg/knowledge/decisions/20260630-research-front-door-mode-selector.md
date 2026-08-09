---
id: 20260630-research-front-door-mode-selector
date: '2026-06-30'
project: claude-plugins
domain: architecture
tags:
- plugin-design
- skills
- research-tools
- ux
- consolidation
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260630-1814-claude-plugins
created_at: '2026-06-30 20:44:57.237504+00:00'
updated_at: '2026-06-30 20:44:57.237507+00:00'
---

# 20260630-research-front-door-mode-selector

## decision

Collapse multiple research/brainstorm skills into a single `/research` front door with a Phase-0 mode selector (evidence | decision-design | hybrid) rather than maintaining separate entry points.

## context

The codebase had separate `deep-research`, `brainstorm`, and brainstorm-council/contradiction-forge skills that overlapped conceptually and created an unclear user-facing API.

## reasoning

A single entry point with explicit mode selection reduces cognitive load for the caller, keeps the evidence pipeline byte-identical (no regression risk), and allows decision-design to delegate cleanly to `borg-researcher`/`borg-reviewer` as sub-agents. Thin aliases for the old names preserve backward compatibility at near-zero cost (21 lines each).
