---
id: stacked-pr-adversarial-verify
project: claude-plugins
domain: code-quality
tags:
- pull-request
- stacked-prs
- adversarial-verification
- directives
preconditions: []
steps:
- Implement directive N on a branch stacked on directive N-1's branch
- 'Run adversarial verification: attempt to violate the directive''s guarantees and
  confirm they hold'
- Re-run verification suite for all prior directives (N-1, N-2, ...) to check for
  regressions
- Commit and push; open PR targeting the prior directive's branch (not main)
- Repeat for directive N+1
- 'Merge in order: PR for Dir 01 first, then Dir 02, etc.'
pitfalls:
- Merging out of order breaks the stacked base; always merge lowest PR number first
- Hook bugs (schema wrap, scope) often only surface on real plugin load, not unit
  tests — do a live load smoke test after each directive
- Regression on Dir 01 is easy to introduce when Dir 02+ adds new Stop/hook registrations;
  always re-verify Dir 01 gate after each addition
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260610-1742-claude-plugins
superseded_by: null
created_at: '2026-06-11 22:41:19.512007+00:00'
updated_at: '2026-06-11 22:41:19.512007+00:00'
---

# stacked-pr-adversarial-verify

## description

When shipping a multi-directive feature stack, implement each directive, adversarially verify it in isolation, confirm no regression on prior directives, then stack the PR on the previous branch before opening.
