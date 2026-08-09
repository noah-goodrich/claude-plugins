---
id: obs-20260610-grep-EI-case-flag
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- bash
- grep
- flags
- case-insensitive
- typo
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:03.999856+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260610-grep-EI-case-flag

## content

grep -EI (uppercase I) is the binary-file flag, not case-insensitive. The case-insensitive flag is -i (lowercase). grep -EI silently skips binary files rather than performing case-insensitive matching, making the hook appear to work on text fixtures while failing on any file grep classifies as binary.

## resolution

Use grep -Ei (lowercase i) for case-insensitive extended regex. Add a shellcheck or grep --help verification step to flag -I vs -i confusion.
