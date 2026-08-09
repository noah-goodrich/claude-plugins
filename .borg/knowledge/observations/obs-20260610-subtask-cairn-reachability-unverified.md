---
id: obs-20260610-subtask-cairn-reachability-unverified
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- cairn
- sub-task
- cowork
- network
- devnet
- architecture
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:04.001821+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260610-subtask-cairn-reachability-unverified

## content

The assumption that Cowork sub-tasks can reach cairn-api:8767 was the load-bearing premise of the entire cairn writer-move migration plan, but it was explicitly UNVERIFIED at the end of the session. If sub-tasks do not join devnet, the migration delivers no value.

## resolution

Before writing the migration plan to disk or starting any migration steps, spawn a minimal Cowork sub-task and probe cairn-api:8767 reachability. Treat this as a mandatory STEP -1 gate.
