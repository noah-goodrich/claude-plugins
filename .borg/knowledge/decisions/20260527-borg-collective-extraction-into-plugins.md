---
id: 20260527-borg-collective-extraction-into-plugins
date: '2026-06-11'
project: claude-plugins
domain: architecture
tags:
- borg-collective
- plugin-extraction
- monorepo
- source-of-truth
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260610-1742-claude-plugins
created_at: '2026-06-11 20:31:25.845920+00:00'
updated_at: '2026-06-11 20:31:25.845923+00:00'
---

# 20260527-borg-collective-extraction-into-plugins

## decision

Extract borg-collective skills into claude-plugins as a plugin artifact, while leaving the source-of-truth question unresolved pending a cross-project directive

## context

borg-collective existed as a standalone repo; claude-plugins needed it as a marketplace plugin. The extraction was completed (PR #4) but both repos now contain skill sources.

## reasoning

Shipping the extraction unblocked marketplace completeness (7 plugins). The source-of-truth ambiguity was explicitly deferred rather than resolved ad-hoc to avoid making an irreversible structural choice without Noah's input.
