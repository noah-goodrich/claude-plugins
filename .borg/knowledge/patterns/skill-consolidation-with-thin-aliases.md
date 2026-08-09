---
id: skill-consolidation-with-thin-aliases
project: claude-plugins
domain: skill-design
tags:
- claude-plugins
- refactoring
- aliases
- backward-compatibility
- consolidation
preconditions: []
steps:
- Identify the skill whose implementation is most complete / byte-stable to become
  the canonical version
- git mv the canonical skill to its new home (e.g., skills/research/) preserving full
  git history
- Verify the moved file is byte-identical to the original to confirm no accidental
  edits
- Add any new capability sections (e.g., mode selector, new phases) to the canonical
  skill
- Replace each deprecated skill file with a thin alias (~21 lines) that documents
  its relationship to the canonical skill and forwards invocation
- Update any stop-scripts or hooks whose regex must match the new canonical name
- Add test assertions covering both the canonical name and each alias name
- Run full hook test suite to confirm nothing regressed
pitfalls:
- Stop-scripts with hardcoded skill-name regexes will silently stop matching after
  a rename — always update regex patterns alongside the mv
- Aliases that don't document why they exist will look like dead code to future maintainers;
  include a one-line explanation in the alias file
- git mv preserves history only if the move is a clean rename with no content edits
  in the same commit — verify byte-identity before adding new content
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:45:41.533547+00:00'
updated_at: '2026-06-30 20:45:41.533548+00:00'
---

# skill-consolidation-with-thin-aliases

## description

Consolidate multiple overlapping skills into one canonical implementation, then replace the originals with thin aliases that forward to the canonical skill. Keeps backward compatibility while eliminating duplicate maintenance surface.
