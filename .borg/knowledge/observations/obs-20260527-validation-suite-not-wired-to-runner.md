---
id: obs-20260527-validation-suite-not-wired-to-runner
session_date: '2026-06-11'
project: claude-plugins
tool: cursor
tags:
- noah-writing-voice
- ai-scoring
- validation
- regression
- ci
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260610-1742-claude-plugins
superseded_by: null
created_at: '2026-06-11 20:31:25.851686+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260527-validation-suite-not-wired-to-runner

## content

A seed corpus for voice + AI-scoring validation exists at noah-writing-voice/validation/2026-05-23-corpus/ but is not connected to any test runner. The dual-axis redesign was validated manually against this corpus, but there is no automated check to catch scoring drift if the skill files are subsequently modified.

## resolution

Flagged as a next-session action: wire the corpus into a regression suite that runs voice + AI-scoring against the Snowflake Builders Blog corpus and flags drift. Until that exists, any edit to noah-writing-voice or ai-scoring skill files must be manually re-validated against the corpus.
