---
id: incremental-gate-design-with-simplify-checkpoint
project: claude-plugins
domain: skill-design
tags:
- deep-research
- gates
- skill-design
- code-quality
preconditions: []
steps:
- Ship new gates in discrete commits (one commit per gate or small batch)
- Leave modified SKILL.md and reference templates uncommitted after a gate accretion
  sprint
- Run /simplify (or equivalent consolidation pass) on SKILL.md before the final commit
- Commit deep-research polish as its own logical commit, separate from unrelated staged
  files
pitfalls:
- Committing SKILL.md mid-sprint without a simplify pass causes the gate list to grow
  unreadably; 14+ gates with full prose descriptions will overwhelm practitioners
  using the skill interactively.
- Batching the simplify commit with unrelated files (privacy audit, corpus validation)
  makes rollback harder.
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260610-1742-claude-plugins
superseded_by: null
created_at: '2026-06-11 20:31:25.849548+00:00'
updated_at: '2026-06-11 20:31:25.849549+00:00'
---

# incremental-gate-design-with-simplify-checkpoint

## description

Pattern for adding gates to an existing multi-gate skill without accumulating verbose cruft in SKILL.md
