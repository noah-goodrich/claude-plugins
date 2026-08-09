---
id: obs-20260630-byte-identity-verification-after-git-mv
session_date: '2026-06-30'
project: claude-plugins
tool: claude-code
tags:
- git-mv
- skills
- testing
- consolidation
- evidence-pipeline
category: pattern_discovered
files_involved: []
confidence: 0.7
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:46:23.713355+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260630-byte-identity-verification-after-git-mv

## content

When consolidating plugins by moving the core skill, the session explicitly verified the evidence pipeline was byte-identical after git mv before adding new sections. This is a meaningful checkpoint — silent content drift during a move is easy to miss and hard to debug later.

## resolution

Make byte-identity verification of the moved core an explicit step in any plugin consolidation, before adding new modes or sections
