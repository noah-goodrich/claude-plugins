---
id: obs-20260527-borg-collective-dual-source-risk
session_date: '2026-06-11'
project: claude-plugins
tool: cursor
tags:
- borg-collective
- source-of-truth
- multi-repo
- drift-risk
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260610-1742-claude-plugins
superseded_by: null
created_at: '2026-06-11 20:31:25.850909+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260527-borg-collective-dual-source-risk

## content

After extracting borg-collective into claude-plugins, both repos contain skill sources with no automated sync. Any skill edit made in borg-collective will silently diverge from the claude-plugins copy and vice versa. There is no CI check or lint rule preventing this.

## resolution

A cross-project directive was captured at docs/plans/directives/2026-05-27-borg-cairn-coordination.md. The resolution requires an explicit owner decision: either (a) claude-plugins becomes canonical and borg-collective's copy is deprecated/deleted, or (b) borg-collective remains canonical and claude-plugins build consumes it as a dependency. Until decided, treat both copies as potentially stale.
