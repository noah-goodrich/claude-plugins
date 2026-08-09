---
id: 20260610-cairn-writer-move-gate
date: '2026-06-16'
project: claude-plugins
domain: infrastructure
tags:
- cairn
- sub-task
- network-reachability
- devnet
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260614-1512-claude-plugins
created_at: '2026-06-16 10:27:03.995121+00:00'
updated_at: '2026-06-16 10:27:03.995122+00:00'
---

# 20260610-cairn-writer-move-gate

## decision

Gate the cairn-writer move on a verified reachability test (spawn Cowork sub-task, probe cairn-api:8767) before committing to the architecture change.

## context

The entire value of moving the cairn writer into the plugin depends on sub-tasks being able to reach cairn-api:8767. This was explicitly UNVERIFIED at session end.

## reasoning

If sub-tasks don't join devnet, the writer-move delivers no telemetry benefit and adds complexity for nothing. A single reachability probe collapses the fork cheaply.
