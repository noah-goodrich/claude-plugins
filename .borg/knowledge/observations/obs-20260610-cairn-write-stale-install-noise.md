---
id: obs-20260610-cairn-write-stale-install-noise
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- cairn
- logging
- false-alarm
- diagnosis
- timeout
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:04.001249+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260610-cairn-write-stale-install-noise

## content

cairn-write failures logged in session output were caused by a stale install producing log noise combined with a dead timeout cap (coreutils gtimeout not installed, so the 5s cap was silently skipped). Actual writes succeeded. The log noise masked the real status.

## resolution

Install coreutils (brew install coreutils) so gtimeout is available and the timeout cap actually enforces the 5s limit. Distinguish stale-install log noise from genuine write failures before concluding there is a cairn bug.
