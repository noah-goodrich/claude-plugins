---
id: 20260610-thin-cli-reframe
date: '2026-06-16'
project: claude-plugins
domain: architecture
tags:
- cli
- plugin
- model-dependency
- skill-authoring
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260614-1512-claude-plugins
created_at: '2026-06-16 10:27:03.994563+00:00'
updated_at: '2026-06-16 10:27:03.994564+00:00'
---

# 20260610-thin-cli-reframe

## decision

Thin CLI = CLI stops authoring portable artifacts; it is NOT a shell wrapper over the plugin. A model-less CLI cannot run plugin skills.

## context

Investigating the 3-layer target architecture for cairn ↔ borg ↔ plugin source-of-truth. The meaning of 'thin CLI' was ambiguous.

## reasoning

Plugin skills require a model context to execute. A CLI without model access can prepare inputs and invoke REST/MCP endpoints but cannot execute plugin logic headlessly. Conflating the two leads to a broken layering where the CLI tries to import plugin internals it cannot run.
