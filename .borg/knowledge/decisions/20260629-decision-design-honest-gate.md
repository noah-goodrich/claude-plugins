---
id: 20260629-decision-design-honest-gate
date: '2026-06-30'
project: claude-plugins
domain: architecture
tags:
- claude-plugins
- borg-reviewer
- trust
- self-enforcement
- honest-gate
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260630-1814-claude-plugins
created_at: '2026-06-30 20:45:41.531398+00:00'
updated_at: '2026-06-30 20:45:41.531399+00:00'
---

# 20260629-decision-design-honest-gate

## decision

Embed a self-enforced NOT design-reviewed honest gate in the decision-design path before surfacing results to the user

## context

The decision-design mode delegates research to borg-researcher and blind review to borg-reviewer; without an explicit gate the output could silently skip the review step

## reasoning

Making the gate textually explicit in the skill forces the agent to acknowledge when review hasn't completed, preserving the integrity of the blind-review pattern rather than letting it become a rubber stamp
