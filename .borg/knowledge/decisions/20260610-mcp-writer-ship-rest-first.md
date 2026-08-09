---
id: 20260610-mcp-writer-ship-rest-first
date: '2026-06-16'
project: claude-plugins
domain: architecture
tags:
- cairn
- mcp
- rest
- migration-strategy
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260614-1512-claude-plugins
created_at: '2026-06-16 10:27:03.996734+00:00'
updated_at: '2026-06-16 10:27:03.996735+00:00'
---

# 20260610-mcp-writer-ship-rest-first

## decision

Ship the cairn writer-move on the existing cairn record session REST shim first; absorb MCP in a separate PR before cairn v0.3 removes REST.

## context

cairn v0.3 will remove the REST interface in favor of MCP-first. The question was whether to absorb MCP now or ship the writer-move incrementally.

## reasoning

Absorbing MCP now couples two risky changes (writer-move + protocol change) into one PR, making failures harder to bisect. The REST shim works today; MCP can be a clean follow-up before the v0.3 deadline.
