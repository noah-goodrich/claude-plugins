---
id: obs-20260630-dist-plugin-not-live-until-ui-reinstall
session_date: '2026-06-30'
project: claude-plugins
tool: claude-code
tags:
- deployment
- claude-desktop
- plugins
- dist
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:44:57.259150+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260630-dist-plugin-not-live-until-ui-reinstall

## content

Rebuilt `dist/*.plugin` files merged to `main` are present on disk but the skills inside them are not callable until the plugin is explicitly reinstalled through the Claude desktop / Cowork UI. There is no auto-reload. A clean working tree and a successful merge do not imply the new functionality is live.

## resolution

After any session that rebuilds dist artifacts, the very next human action must be reinstalling the affected plugins via the UI before attempting smoke tests. Carried as an explicit first item in the Next Session checklist.
