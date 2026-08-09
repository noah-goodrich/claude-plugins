---
id: obs-20260610-exit2-conflation
session_date: '2026-06-16'
project: claude-plugins
tool: claude-code
tags:
- bash
- exit-codes
- hooks
- stop-hook
- error-handling
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:04.000880+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260610-exit2-conflation

## content

stop.sh used exit 2 to mean both 'script error' and 'pattern matched / block the stop'. Callers that check exit 2 as 'error' will silently pass through a block condition; callers checking for non-zero as 'blocked' will treat errors as blocks. The dual meaning makes the hook contract ambiguous.

## resolution

Assign distinct exit codes for distinct semantics: e.g., exit 0 = allow, exit 1 = block, exit 2 = internal error. Document the contract in the script header and test each code path in the regression suite.
