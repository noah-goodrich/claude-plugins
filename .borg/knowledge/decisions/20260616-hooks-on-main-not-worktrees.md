---
id: 20260616-hooks-on-main-not-worktrees
date: '2026-06-16'
project: claude-plugins
domain: infrastructure
tags:
- claude-code
- plugins
- hooks
- git-worktrees
- deployment
alternatives: []
applies_to: []
confidence: 0.9
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260614-1512-claude-plugins
created_at: '2026-06-16 10:27:02.524481+00:00'
updated_at: '2026-06-16 10:27:02.524481+00:00'
---

# 20260616-hooks-on-main-not-worktrees

## decision

Live plugin hooks resolve from the `main` working tree, not from named worktrees

## context

The `deep-research-stop.sh` Stop-hook kept recurring after fixes because the hook path resolved to a worktree that wasn't being updated

## reasoning

Hooks on `main` means a single `git pull` on main is sufficient to update all hook behavior without worktree management; eliminates the recurrence class of bug entirely
