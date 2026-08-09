---
id: obs-20260630-stale-pr-targets-renamed-path
session_date: '2026-06-30'
project: claude-plugins
tool: claude-code
tags:
- git
- pull-requests
- git-mv
- stale-prs
- deep-research
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:46:23.712893+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260630-stale-pr-targets-renamed-path

## content

PR #1 ('Add citation verification to deep-research skill') targets the path of the now-renamed/moved deep-research skill. After a git mv consolidation, open PRs targeting the old path will conflict or silently apply to the wrong location without obvious error.

## resolution

After any git mv that moves a skill, audit open PRs for path references to the old location. Either close stale PRs or rebase their intent onto the new path before merging.
