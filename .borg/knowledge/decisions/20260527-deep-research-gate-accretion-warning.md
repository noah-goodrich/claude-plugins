---
id: 20260527-deep-research-gate-accretion-warning
date: '2026-06-11'
project: claude-plugins
domain: code-quality
tags:
- deep-research
- skill-design
- gates
- simplify
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260610-1742-claude-plugins
created_at: '2026-06-11 20:31:25.848136+00:00'
updated_at: '2026-06-11 20:31:25.848137+00:00'
---

# 20260527-deep-research-gate-accretion-warning

## decision

Defer committing modified deep-research files and recommend a /simplify pass before they land

## context

Gates 9-14 were shipped on top of an existing 8-gate audit set. The SKILL.md and reference templates were left uncommitted and flagged as verbose.

## reasoning

Gate accretion — incrementally adding gates without pruning — degrades skill usability. The /simplify step prevents SKILL.md from becoming a maintenance burden. Deferring to a separate triage commit keeps the PR history clean.
