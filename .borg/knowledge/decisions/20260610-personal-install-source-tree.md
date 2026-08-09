---
id: 20260610-personal-install-source-tree
date: '2026-06-16'
project: claude-plugins
domain: infrastructure
tags:
- borg-setup
- install
- dev-loop
- plugin
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260614-1512-claude-plugins
created_at: '2026-06-16 10:27:03.996156+00:00'
updated_at: '2026-06-16 10:27:03.996157+00:00'
---

# 20260610-personal-install-source-tree

## decision

borg setup copies from the plugin SOURCE tree (~/dev/claude-plugins/borg-collective) rather than the built dist/*.plugin.

## context

Choosing the personal-install source for borg setup to balance dev-loop simplicity against installation hygiene.

## reasoning

Simpler dev loop — edits in the source tree are immediately reflected on the next borg setup run without a build step. The built artifact path adds friction for local iteration.
