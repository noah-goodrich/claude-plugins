---
id: 20260630-honest-gate-not-design-reviewed
date: '2026-06-30'
project: claude-plugins
domain: architecture
tags:
- research-tools
- decision-design
- transparency
- borg-reviewer
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260630-1814-claude-plugins
created_at: '2026-06-30 20:44:57.248510+00:00'
updated_at: '2026-06-30 20:44:57.248511+00:00'
---

# 20260630-honest-gate-not-design-reviewed

## decision

Enforce a self-stamped `NOT design-reviewed` honest gate in the decision-design pipeline when blind review via `borg-reviewer` is skipped, rather than silently omitting the review step.

## context

Decision-design mode delegates to `borg-researcher` and then sends the draft recommendation to `borg-reviewer` for blind review. Users might skip the review leg for speed.

## reasoning

Explicit stamping prevents outputs from being mistaken for fully-reviewed recommendations. Forces traceability into the artifact itself, not just session logs.
