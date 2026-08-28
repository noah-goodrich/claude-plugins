---
class: generic
provider: anthropic
model: fixture-model-a
generated: 2026-08-27
target_words: 200
source_article: fixture-human-04-schema-drift.md
prompt: |
  Write a 200-word technical blog post about upstream schema changes breaking downstream data
  models, and what teams should do about it. Do not imitate any particular author.
---

# Upstream Schema Changes and Downstream Breakage

A type change in a producing service propagates silently into every consuming model that does not validate its
inputs. The failure mode is rarely an error. It is a column of nulls that passes every existing test and reaches a
report before anyone examines it.

Detection tooling addresses the symptom. A consumer can compare observed types against expected types on each run
and fail loudly when they diverge. This shortens the interval between breakage and discovery, which is valuable,
but it does not prevent the breakage.

Furthermore, prevention requires an agreement rather than a check. The consuming team enumerates the specific
fields it depends on, presents that enumeration to the producing teams, and obtains a commitment to advance notice
before those fields change. Scoping the request to a short list rather than an entire schema makes the commitment
inexpensive to give.

Formal contract registries can then encode agreements that already exist socially. Registries introduced before any
such agreement tend to be adopted as a compliance obligation and abandoned once attention moves elsewhere.

The sequence matters more than the tooling. Agreement first, enforcement second.
