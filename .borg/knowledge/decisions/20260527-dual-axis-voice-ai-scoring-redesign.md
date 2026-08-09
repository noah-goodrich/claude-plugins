---
id: 20260527-dual-axis-voice-ai-scoring-redesign
date: '2026-06-11'
project: claude-plugins
domain: plugin-design
tags:
- noah-writing-voice
- ai-scoring
- dual-axis
- scoring-framework
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260610-1742-claude-plugins
created_at: '2026-06-11 20:31:25.847489+00:00'
updated_at: '2026-06-11 20:31:25.847490+00:00'
---

# 20260527-dual-axis-voice-ai-scoring-redesign

## decision

Redesign noah-voice and ai-scoring into a dual-axis framework rather than maintaining them as independent scoring systems

## context

Prior to this session, voice scoring and AI-detection scoring were separate. A corpus validation pass (2026-05-23) revealed internal inconsistency in the single-sentence paragraph rule and loose alignment between the two systems.

## reasoning

Dual-axis allows voice fidelity and AI-signal avoidance to be scored and tuned independently while sharing a common evaluation pass. Fixing the single-sentence rule inconsistency required touching both systems anyway.
