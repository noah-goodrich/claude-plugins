---
id: obs-20260616-hook-recurrence-from-worktree-drift
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- hooks
- worktrees
- git
- claude-code
- plugin-deployment
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:02.528762+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260616-hook-recurrence-from-worktree-drift

## content

A Stop-hook fix that is committed but resolves at runtime from a worktree path (not `main`) will recur after every session restart because the worktree is not updated. The fix exists in the repo but is never executed.

## resolution

Permanently fixed by moving hook resolution to the `main` working tree. Any hook path pointing to a named worktree is vulnerable to this if the worktree falls behind main.
