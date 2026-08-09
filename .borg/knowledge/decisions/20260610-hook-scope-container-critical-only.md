---
id: 20260610-hook-scope-container-critical-only
date: '2026-06-16'
project: claude-plugins
domain: architecture
tags:
- hooks
- plugin
- lifecycle
- borg-collective
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260614-1512-claude-plugins
created_at: '2026-06-16 10:27:03.995612+00:00'
updated_at: '2026-06-16 10:27:03.995612+00:00'
---

# 20260610-hook-scope-container-critical-only

## decision

Scope hooks moving into the plugin to container-critical only (writer + bash-guard + nudges); leave host-state hooks (link-down SessionStart, plan-promote, nanoprobe) CLI-only.

## context

Deciding which lifecycle hooks to include when splitting borg-hooks.sh for the plugin vs CLI.

## reasoning

Host-state hooks depend on host context (network state, local file paths) that is unavailable or meaningless inside a container/plugin sandbox. Bundling them causes silent no-ops or errors in container environments.
