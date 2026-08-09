---
id: stacked-pr-adversarial-verification
project: claude-plugins
domain: code-quality
tags:
- PRs
- stacking
- adversarial
- verification
- directives
preconditions: []
steps:
- Implement base directive/feature on branch A; open PR
- Stack branch B on A for next directive; implement
- Run adversarial verifier against the full set (B must not regress A)
- Repeat for each subsequent directive
- Push all branches; open PRs with explicit stack order documented
- Merge in order (A first, then B rebases cleanly onto main)
pitfalls:
- If PRs are merged out of order, the stacked branch will have conflicts or duplicate
  commits
- Adversarial verification must cover all prior directives on each new branch, not
  just the new one
- Hook bug fixes that surface during verification on later branches should be committed
  to the earliest branch that introduced the bug
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:02.492314+00:00'
updated_at: '2026-06-16 10:27:02.492314+00:00'
---

# stacked-pr-adversarial-verification

## description

When shipping a stack of related directives/features, implement each on a stacked branch, adversarially verify each new directive doesn't regress prior ones, then push as ordered PRs for sequential merge
