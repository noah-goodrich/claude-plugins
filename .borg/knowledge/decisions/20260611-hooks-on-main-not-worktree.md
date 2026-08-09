---
id: 20260611-hooks-on-main-not-worktree
date: '2026-06-11'
project: claude-plugins
domain: infrastructure
tags:
- claude-code
- plugins
- hooks
- git
- worktrees
alternatives: []
applies_to: []
confidence: 0.9
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260610-1742-claude-plugins
created_at: '2026-06-11 22:41:19.537249+00:00'
updated_at: '2026-06-11 22:41:19.537249+00:00'
---

# 20260611-hooks-on-main-not-worktree

## decision

Live plugin hooks resolve from the `main` working tree, not from a detached worktree or branch ref

## context

The `deep-research-stop.sh` Stop-hook was recurring despite fixes because hooks were being loaded from a worktree that wasn't tracking main

## reasoning

Pinning hook resolution to the `main` working tree ensures that merged fixes take effect immediately without requiring worktree cleanup or branch switching
