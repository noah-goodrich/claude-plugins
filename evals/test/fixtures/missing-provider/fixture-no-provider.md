---
class: generic
model: fixture-model-a
generated: 2026-08-27
target_words: 120
source_article: fixture-human-01-warehouse-sizing.md
prompt: |
  Provenance fixture. Every frontmatter field is present except provider, so the loader has to
  fail and name both the file and the missing field.
---

# A Document With No Recorded Provider

The body of this document is deliberately unremarkable. It exists so the loader has something well-formed to parse
past before it reaches the missing field.

Compute sizing decisions benefit from measurement. Queue time and spill volume are both observable, and both are
better inputs to a capacity decision than an impression of slowness.

Where queue time dominates the window, restructuring the schedule returns more than additional compute does. Where
spill dominates, additional memory is the correct remedy.

The point of this fixture is the frontmatter above, not the paragraphs below it.
