---
class: generic
provider: google
model: fixture-model-b
generated: 2026-08-27
target_words: 240
source_article: fixture-human-05-cost-review.md
prompt: |
  Write a 240-word technical blog post about diagnosing an unexpected increase in a data
  platform bill. Do not imitate any particular author.
---

# Diagnosing an Unexpected Increase in Platform Spend

Consumption-based platforms distribute cost across many small decisions, which makes an aggregate increase
difficult to attribute from the invoice alone. Attribution requires querying the platform's own usage metadata.

Begin by grouping consumption along two dimensions: the compute resource that executed the work, and a normalized
identifier for the query text itself. Most platforms expose both. The resulting table ranks consumers by their
contribution to the change rather than by their absolute size, which is the quantity of interest.

Scheduled workloads dominate these rankings more often than interactive ones. A dashboard configured to refresh at
a short interval executes its queries continuously regardless of whether anyone is viewing it, and a test suite
attached to a scheduler continues running long after the project that required it has concluded.

Verification comes next. Identify the consumers of each high-ranking workload and confirm that the observed refresh
frequency corresponds to an actual requirement. Frequencies are commonly set once at creation and never revisited,
and the people using the asset are often unaware of the configured cadence.

Establishing this as a recurring review changes its character. A scheduled thirty-minute analysis following each
billing period, producing a ranked list of the largest changes, will surface anomalies while they are still small.

The alternative is a policy discussion, which consumes more time than the analysis and produces less information
about the specific workloads driving the increase.
