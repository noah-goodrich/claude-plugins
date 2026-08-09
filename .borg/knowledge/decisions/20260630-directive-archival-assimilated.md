---
id: 20260630-directive-archival-assimilated
date: '2026-06-30'
project: claude-plugins
domain: process
tags:
- directives
- assimilation
- git
- workflow
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260630-1814-claude-plugins
created_at: '2026-06-30 20:44:57.249274+00:00'
updated_at: '2026-06-30 20:44:57.249275+00:00'
---

# 20260630-directive-archival-assimilated

## decision

Archive completed directives to `assimilated/` with ship-stamp (PR number + commit hash) rather than deleting them.

## context

Directive 08 (research front door) was completed in PR #21 / commit `4b5936c`.

## reasoning

Preserves the decision trail and lets future sessions understand *why* the architecture is shaped the way it is, without cluttering the active directive queue.
