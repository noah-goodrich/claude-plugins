---
id: plugin-dist-rebuild-then-reinstall-two-step
project: claude-plugins
domain: infrastructure
tags:
- deployment
- claude-desktop
- dist
- plugins
preconditions: []
steps:
- Run whatever build command produces `dist/*.plugin`.
- Commit and merge the updated dist artifact to `main`.
- Manually open Claude desktop UI / Cowork and reinstall each changed plugin from
  the new dist path.
- Smoke-test each reinstalled plugin to confirm the new code is active.
pitfalls:
- The working tree being clean and merged does NOT mean the plugin is live. Skills
  added or renamed in the dist exist on disk but are not callable until reinstall.
- If multiple plugins were rebuilt in one session, all of them need individual reinstall
  — it's easy to reinstall one and forget the others.
cost_estimate: null
times_applied: 0
last_applied: null
confidence: 0.7
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:44:57.254502+00:00'
updated_at: '2026-06-30 20:44:57.254503+00:00'
---

# plugin-dist-rebuild-then-reinstall-two-step

## description

After any change that produces a new `.plugin` dist artifact, the artifact is not live until manually reinstalled via the Claude desktop / Cowork UI. The rebuild and the reinstall are distinct steps, and the reinstall is a human action outside the repo.
