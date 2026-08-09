---
id: obs-20260630-stale-pr-rename-conflict
session_date: '2026-06-30'
project: claude-plugins
tool: claude-code
tags:
- claude-plugins
- git
- stale-pr
- rename
- conflict
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:45:41.536490+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260630-stale-pr-rename-conflict

## content

PR #1 ('Add citation verification to deep-research skill') was open against the deep-research skill path at the time deep-research was git mv'd to skills/research/. The PR is now almost certainly conflicting or obsolete but remains open, creating a trap for the next contributor who might try to merge it.

## resolution

After any skill rename/move, immediately audit open PRs targeting the old path. Either close them with an explanation, or rebase their intent onto the new canonical path before the rename fades from memory.
