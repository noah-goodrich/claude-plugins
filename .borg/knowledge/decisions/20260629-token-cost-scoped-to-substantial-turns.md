---
id: 20260629-token-cost-scoped-to-substantial-turns
date: '2026-06-30'
project: claude-plugins
domain: architecture
tags:
- token-cost
- scoping
- borg-collective
- performance
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260630-1814-claude-plugins
created_at: '2026-06-30 20:46:23.708100+00:00'
updated_at: '2026-06-30 20:46:23.708100+00:00'
---

# 20260629-token-cost-scoped-to-substantial-turns

## decision

Scope token-cost instrumentation to substantial/delegated turns only, not every turn

## context

token-cost was previously applied more broadly; PR #20 tightened scope as part of shipping borg-researcher/borg-reviewer agents

## reasoning

Attaching cost tracking to every turn adds noise and overhead; substantial/delegated turns are the ones where cost visibility actually matters for budgeting decisions
