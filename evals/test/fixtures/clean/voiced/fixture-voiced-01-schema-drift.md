---
class: voiced
provider: anthropic
model: fixture-model-a
generated: 2026-08-27
target_words: 200
source_article: fixture-human-04-schema-drift.md
prompt: |
  With the noah-voice skill loaded, draft a 200-word article about an upstream schema change
  breaking downstream models. Write in Noah's voice.
---

# Nobody upstream agreed to anything

A column went from integer to string on a Tuesday. Six models downstream started returning nulls on Wednesday. The
finance dashboard was wrong for nine days and the controller found it, not us.

The postmortem wanted to talk about alerting. The alerting was fine. We had built an excellent smoke detector in a
building with no fire code.

Here is what nobody said out loud: there was no contract, so there was no breach, so there was nothing to detect.
The upstream team had not broken a promise. They had never made one.

What fixed it was twelve columns on a page. Not a registry, not a governance initiative. Twelve column names, two
service owners, one ask: tell us before these change.

Both teams agreed inside a week. They agreed because we asked for twelve columns instead of their whole schema, and
twelve columns is a favor rather than a process.

The registry showed up eight months later and it sold itself, because by then two teams could point at a rollback
the agreement had already prevented.

Ask for the smallest thing that would have worked. Then let the tooling catch up to the agreement.
