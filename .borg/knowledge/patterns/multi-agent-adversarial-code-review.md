---
id: multi-agent-adversarial-code-review
project: claude-plugins
domain: code-quality
tags:
- code-review
- multi-agent
- shell
- bash
- adversarial-reconciliation
preconditions: []
steps:
- 'Assign agents distinct lenses: fail-open (false negatives), fail-closed (false
  positives), portability (BSD vs GNU), arity/crash paths'
- Collect raw findings per agent without cross-contamination
- 'Adversarial reconciliation pass: each finding must be confirmed or refuted with
  a concrete test case or counterexample'
- Produce a numbered CONFIRMED findings list with severity and affected file
- Fix all confirmed findings in a single atomic commit
- Add regression fixtures that cover each confirmed finding before committing
pitfalls:
- Agents without a specific lens tend to rediscover the same surface bugs; mandate
  distinct failure-mode assignments
- BSD sed does not support \b word-boundary escapes — portability bugs are invisible
  unless an agent specifically targets macOS/BSD behavior
- Reconciliation must be adversarial, not additive; without pushback, low-confidence
  findings inflate the fix list
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:03.997502+00:00'
updated_at: '2026-06-16 10:27:03.997503+00:00'
---

# multi-agent-adversarial-code-review

## description

Run multiple agents over a shell script codebase, each looking for different failure modes (fail-open vs fail-closed, portability, arity bugs), then adversarially reconcile findings before fixing.
