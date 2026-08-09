---
id: directive-assimilation-closeout
project: claude-plugins
domain: process
tags:
- borg-assimilate
- directives
- archiving
- session-closeout
preconditions: []
steps:
- Ship and verify all PRs live
- Run /borg-assimilate for each completed directive; artifact lands in assimilated/<date>-<slug>.md
- Run /simplify to catch any leftover dead code or structural debt
- Confirm working tree clean (local main == origin/main) before closing session
pitfalls:
- Running /simplify before all PRs are merged can produce changes that conflict with
  in-flight work
- Skipping /borg-assimilate leaves directives in the active queue, cluttering the
  next session's context
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:46:23.709440+00:00'
updated_at: '2026-06-30 20:46:23.709441+00:00'
---

# directive-assimilation-closeout

## description

Standard closeout sequence for a shipped directive: archive it via /borg-assimilate, run /simplify, confirm clean working tree
