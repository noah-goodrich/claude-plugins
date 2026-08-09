---
id: 20260629-token-cost-scoping-substantial-turns
date: '2026-06-30'
project: claude-plugins
domain: infrastructure
tags:
- claude-plugins
- token-cost
- borg-collective
- cost-visibility
- scoping
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260630-1814-claude-plugins
created_at: '2026-06-30 20:45:41.532616+00:00'
updated_at: '2026-06-30 20:45:41.532617+00:00'
---

# 20260629-token-cost-scoping-substantial-turns

## decision

Scope token-cost reporting to substantial/delegated turns only rather than every turn

## context

token-cost was generating noise on trivial interactions, obscuring signal for the turns that actually matter for quota management

## reasoning

Filtering to substantial and delegated turns preserves cost visibility where it counts while eliminating low-value churn in the output stream
