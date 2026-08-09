---
id: obs-20260610-bsd-sed-no-word-boundary
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- bash
- sed
- bsd
- macos
- portability
- regex
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:03.998788+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260610-bsd-sed-no-word-boundary

## content

BSD sed (macOS) silently ignores \b word-boundary escapes in regex patterns — the pattern matches as if \b were absent rather than erroring. This means a hook intended to match whole words will match substrings, producing false positives.

## resolution

Replace \b with explicit bracket expressions or use grep -w / awk for word-boundary logic on macOS. Always test regex hooks on macOS bash 3.2 if that is a deployment target.
