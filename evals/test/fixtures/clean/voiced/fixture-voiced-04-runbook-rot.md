---
class: voiced
provider: anthropic
model: fixture-model-a
generated: 2026-08-27
target_words: 290
source_article: fixture-human-07-runbook-rot.md
prompt: |
  With the noah-voice skill loaded, draft a 290-word article about runbooks going stale and
  how to keep them useful. Write in Noah's voice.
---

# Eleven pages that were true in 2023

I read the ingestion runbook at two in the morning. Eleven pages. Four of them referenced a service we had deleted.
One told me to restart a host that a migration had decommissioned eight months earlier.

Code rots loudly. A dead function throws and somebody fixes it inside a sprint. A dead runbook step costs twenty
minutes of the worst twenty minutes anybody on the team will have that month, and it costs them silently.

What replaced it was a page and a half. Three commands, each of which either fixes the thing or prints why it
cannot. One escalation path with a name and a number. One paragraph on what the service is for, so the next person
can reason about the failure the page does not cover.

There is exactly one way to test a runbook. Whoever used it edits it before going back to sleep, while the
wrongness is still fresh. Nothing to edit means they add a date at the bottom and close the laptop.

Six months in: nine dates, four edits. The edits are where the value is. Two commands had changed flags. One
permission had moved. One escalation contact had switched teams and would have been paged for a system she no
longer owned.

A review would have caught none of those four, because a review reads the document the way the author wrote it
instead of the way an exhausted stranger reads it at two in the morning.

The page and a half is worse documentation than the eleven pages were. It is a much better runbook, and those are
not the same job.
