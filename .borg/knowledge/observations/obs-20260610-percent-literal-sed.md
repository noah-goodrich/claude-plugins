---
id: obs-20260610-percent-literal-sed
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- bash
- sed
- percent
- literal
- regex
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:03.999459+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260610-percent-literal-sed

## content

Using % as a sed delimiter (e.g., s%pattern%replacement%) can cause the literal % character in the pattern to be consumed as a delimiter, silently producing a phantom substitution. Affected the denominator extraction in deep-research-verify.sh.

## resolution

Use a delimiter that cannot appear in the pattern/replacement data, or escape % explicitly. Default to / and escape any / in data with \/ .
