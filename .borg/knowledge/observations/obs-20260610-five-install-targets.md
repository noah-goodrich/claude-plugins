---
id: obs-20260610-five-install-targets
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- install
- deployment
- hooks
- skills
- architecture
category: domain_knowledge
files_involved: []
confidence: 0.7
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:04.003296+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260610-five-install-targets

## content

The borg-collective has 5 distinct install targets that must each be considered when moving hooks or skills: (1) Claude ~/.claude/hooks, (2) Claude ~/.claude/lib, (3) Claude ~/.claude/skills, (4) Cortex/CoCo, (5) the plugin itself. A change to source-of-truth or hook location must be traced through all five.

## resolution

Maintain an explicit install-target matrix in the unified cairn plan documenting which artifact goes where and which tool reads from which source.
