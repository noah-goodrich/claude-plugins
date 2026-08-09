---
id: obs-20260611-stop-hook-recurrence-worktree
session_date: '2026-06-11'
project: claude-plugins
tool: cursor
tags:
- claude-code
- hooks
- stop-hook
- worktrees
- git
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260610-1742-claude-plugins
superseded_by: null
created_at: '2026-06-11 22:41:19.541106+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260611-stop-hook-recurrence-worktree

## content

The `deep-research-stop.sh` Stop-hook kept recurring after fixes because the live plugin was resolving hooks from a worktree that had diverged from main. Fixes merged to main were not reflected in the active hook execution path.

## resolution

Permanently fixed by ensuring live plugins resolve hooks from the `main` working tree directly. Worktree-based hook resolution is unreliable when the worktree can drift.
