---
class: generic
provider: google
model: fixture-model-b
generated: 2026-08-27
target_words: 185
source_article: fixture-human-02-late-arriving-data.md
prompt: |
  Write a 185-word technical blog post explaining how data pipelines should handle records
  that arrive after their processing window has closed. Do not imitate any particular author.
---

# Handling Records That Arrive After the Window Closes

Distributed data collection guarantees that some records will arrive after the period they describe has already
been processed. Mobile clients lose connectivity, third-party systems retry on their own schedules, and batch
exports are occasionally delayed by hours.

Pipelines that partition on ingestion time treat every such record as an anomaly requiring manual intervention.
Moreover, this design places the operational burden on whoever happens to be responsible when the discrepancy is
discovered, which is often long after the affected reports have been circulated.

Partitioning on event time resolves the structural problem. Records are assigned to the period in which the event
occurred, regardless of when the platform received them. A bounded reprocessing window then recomputes recent
periods on each execution, absorbing late arrivals without human involvement.

The tradeoff is that recent periods become provisional. Reports covering the reprocessing window may change
between refreshes, and consumers must be informed of this property rather than discovering it independently.

Documenting the window length alongside every affected report converts a source of confusion into a stated
guarantee.
