---
id: obs-20260610-unquoted-scan-files-word-split
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- bash
- word-splitting
- quoting
- IFS
- hooks
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:04.000241+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260610-unquoted-scan-files-word-split

## content

Leaving $SCAN_FILES and $WARN_SCAN unquoted in for/while loops causes word-splitting on spaces in filenames and IFS characters, silently dropping or misrouting files. This is a fail-closed bug: legitimate files with spaces in their paths are skipped.

## resolution

Always quote array/list variables: "$SCAN_FILES". If the variable holds newline-separated paths, use while IFS= read -r with process substitution instead of unquoted expansion.
