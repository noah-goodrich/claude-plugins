---
id: obs-20260630-stop-script-regex-must-match-renamed-skill
session_date: '2026-06-30'
project: claude-plugins
tool: claude-code
tags:
- testing
- regex
- skill-rename
- transcript
- stop-script
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: 20260630-1814-claude-plugins
superseded_by: null
created_at: '2026-06-30 20:44:57.255660+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260630-stop-script-regex-must-match-renamed-skill

## content

The `deep-research-stop.sh` transcript parser matched skill invocations by a regex tied to the old skill name `deep-research`. When the skill was `git mv`'d to `research`, the stop script silently stopped matching — existing tests would pass (no error thrown) but the script would fail to detect real research sessions.

## resolution

Updated the regex in `deep-research-stop.sh` to match `research` (the new canonical name), then added a dedicated test assertion in `run-tests.sh §5` to prove the regex matches. Any future skill rename must include a grep of all stop/transcript scripts for the old name.
