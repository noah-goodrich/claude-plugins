---
id: obs-20260527-voice-rule-inconsistency-single-sentence-para
session_date: '2026-06-11'
project: claude-plugins
tool: cursor
tags:
- noah-writing-voice
- single-sentence-paragraph
- rule-inconsistency
- corpus-validation
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260610-1742-claude-plugins
superseded_by: null
created_at: '2026-06-11 20:31:25.851300+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260527-voice-rule-inconsistency-single-sentence-para

## content

The noah-writing-voice plugin had an internal inconsistency on single-sentence paragraph handling. The rule as written conflicted with observed Medium corpus practice. This was discovered via corpus validation (2026-05-23-corpus) and required both a rule fix and a loosening pass to align with actual published work.

## resolution

Fixed in a7fe56e (resolve internal inconsistency) followed by 97e84f3 (loosen rules to match observed Medium practice). The fix was validated against the corpus. The validation corpus is now staged at noah-writing-voice/validation/2026-05-23-corpus/ but not yet wired to a regression runner — drift could re-emerge silently.
