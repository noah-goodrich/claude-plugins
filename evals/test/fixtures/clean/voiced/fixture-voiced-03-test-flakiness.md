---
class: voiced
provider: anthropic
model: fixture-model-a
generated: 2026-08-27
target_words: 175
source_article: fixture-human-06-test-flakiness.md
prompt: |
  With the noah-voice skill loaded, draft a 175-word article about flaky tests and retry
  decorators. Write in Noah's voice.
---

# Tape over the check-engine light

Nine tests failed about one run in six. The team's answer was a retry decorator.

That said, I understand the appeal. A red suite blocks a deploy and a retry decorator makes the red go away in
under a minute, which is faster than understanding anything.

I pulled all nine. Seven asserted on wall-clock ordering in a system that promises no ordering. Those tests were
not flaky. They were wrong, and they had been getting away with it most of the time.

The other two were real. They had caught a race in the connection pool that was eating one request in forty
thousand in production, which nobody had traced because one in forty thousand looks like a client problem from
where the server sits.

Seven tests deleted. One bug fixed. Green for four months.

The decorator came out in the same commit. Two people wanted to keep it around as a safety net, and I understand
the instinct there too. A safety net you cannot see through is a blindfold, and we had been wearing one for most
of a year without noticing.

A retry hides the difference between a wrong test and a wrong system, and that difference was the only thing the
test was ever there to tell you.
