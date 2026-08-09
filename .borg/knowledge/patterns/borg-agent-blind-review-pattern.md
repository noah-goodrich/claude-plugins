---
id: borg-agent-blind-review-pattern
project: claude-plugins
domain: agent-orchestration
tags:
- claude-plugins
- borg-researcher
- borg-reviewer
- blind-review
- multi-agent
preconditions: []
steps:
- borg-researcher receives the full brief and produces structured findings
- borg-reviewer receives only the findings output, not the original brief (blind review)
- 'The orchestrating skill checks an explicit honest gate before surfacing results:
  output is marked NOT design-reviewed if the reviewer step did not complete'
- Final synthesis merges research findings with reviewer critique before presenting
  to user
pitfalls:
- If the reviewer receives the original brief alongside the findings, the blind-review
  property is lost — pass only the researcher output
- Silent reviewer failure (agent error, timeout) will produce findings without critique;
  the honest gate exists to make this visible rather than producing a false sense
  of completeness
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:45:41.534728+00:00'
updated_at: '2026-06-30 20:45:41.534729+00:00'
---

# borg-agent-blind-review-pattern

## description

Use two sequenced agents — a researcher that produces findings and a reviewer that evaluates those findings without knowing the original brief — to get unbiased critique within a single skill invocation.
