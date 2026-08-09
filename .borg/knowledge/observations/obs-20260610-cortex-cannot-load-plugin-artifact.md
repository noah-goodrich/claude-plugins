---
id: obs-20260610-cortex-cannot-load-plugin-artifact
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- cortex
- coco
- plugin
- skill
- install-targets
category: domain_knowledge
files_involved: []
confidence: 0.7
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:04.002580+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260610-cortex-cannot-load-plugin-artifact

## content

Cortex/CoCo cannot load a .plugin artifact directly. For cortex skill add to work after the source-of-truth is inverted to the plugin tree, either: (a) CLI retains a skills/ directory kept in sync by a CI drift check, or (b) cortex reads from the plugin SOURCE tree directly.

## resolution

Decide which persistence strategy to use before inverting the source-of-truth. A CI drift check between plugin source and CLI skills/ is the safer option as it gives an explicit sync point.
