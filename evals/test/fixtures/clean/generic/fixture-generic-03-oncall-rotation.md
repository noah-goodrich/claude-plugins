---
class: generic
provider: cortex
model: fixture-model-c
generated: 2026-08-27
target_words: 275
source_article: fixture-human-03-oncall-rotation.md
prompt: |
  Write a 275-word technical blog post about what an on-call alert history reveals about the
  design of a data platform. Do not imitate any particular author.
---

# What Alert History Reveals About Platform Design

An on-call rotation produces a continuous record of where a system fails, and that record is frequently a more
accurate description of the architecture than any document the team has written.

Alert volume concentrated on a small number of components indicates that those components carry
responsibilities their design did not anticipate. When six tables account for the majority of pages across a
quarter, the appropriate response is a structural review of those six rather than a tuning exercise on the
thresholds that surfaced them.

Ownership gaps appear in the same record. Components with a named owner tend to accumulate documentation, tests,
and deliberate thresholds. Components owned by a shared channel accumulate none of these, and the alert history
will show longer acknowledgement times and higher repeat rates for exactly those components.

A lightweight review process addresses both patterns. Any alert that fires more than once in a calendar month
receives a short scheduled review with a written outcome: remediate, decommission, or accept and disable. The
written outcome matters more than the meeting, because an accepted alert that is deliberately disabled is
operationally different from one that is habitually ignored.

Teams applying this process typically observe a substantial reduction in alert volume within a quarter, along with
the removal of assets that no consumer had queried in the preceding year. Both outcomes come from the same source,
which is a decision made with information rather than under time pressure.

The underlying observation is that the review was always happening. Moving it out of the overnight window changes
who performs it and what information they have available when they do.
