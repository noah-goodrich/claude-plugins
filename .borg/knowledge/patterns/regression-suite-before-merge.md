---
id: regression-suite-before-merge
project: claude-plugins
domain: testing
tags:
- regression
- shell
- bash
- shellcheck
- hooks
- ci
preconditions: []
steps:
- Create test/run-tests.sh alongside the hooks under test
- Write fixture files covering each assertion type the hook evaluates
- Add evasion/honest mutation pairs for each fixture (attacker bypasses vs legitimate
  variants)
- Add cross-cutting checks (empty input, missing args, exit codes)
- Run shellcheck on all scripts before executing tests
- Validate on macOS bash 3.2 explicitly if hooks will run in that environment
- Gate the PR merge on all checks passing
pitfalls:
- shellcheck may pass on Linux bash 5 but hide bash 3.2 incompatibilities; always
  run on the deployment platform
- Evasion mutations are as important as honest fixtures — without them, regex bugs
  that allow bypasses go undetected
- Exit-code conflation (e.g., exit 2 meaning both 'error' and 'pattern found') causes
  silent failures in callers; test caller behavior, not just script output
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260614-1512-claude-plugins
superseded_by: null
created_at: '2026-06-16 10:27:03.998179+00:00'
updated_at: '2026-06-16 10:27:03.998180+00:00'
---

# regression-suite-before-merge

## description

Before merging a shell-hook branch, build and run a regression suite covering fixtures, evasion mutations, and cross-cutting checks, validated on the target platform (macOS bash 3.2).
