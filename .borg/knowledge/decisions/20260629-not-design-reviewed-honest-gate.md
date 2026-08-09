---
id: 20260629-not-design-reviewed-honest-gate
date: '2026-06-30'
project: claude-plugins
domain: architecture
tags:
- agents
- borg-reviewer
- honesty
- design-review
- trust
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260630-1814-claude-plugins
created_at: '2026-06-30 20:46:23.707397+00:00'
updated_at: '2026-06-30 20:46:23.707398+00:00'
---

# 20260629-not-design-reviewed-honest-gate

## decision

Enforce a self-declared NOT design-reviewed gate in the decision-design mode: the skill explicitly marks output as unreviewed until borg-reviewer has run

## context

Decision-design mode delegates research to borg-researcher and blind review to borg-reviewer; without an explicit gate, consumers could mistake intermediate output for a fully reviewed decision

## reasoning

Explicit honest-state labeling prevents silent promotion of partial results; the gate is self-enforcing inside the skill so callers don't need to track review state externally
