---
id: 20260527-borg-collective-source-of-truth-resolved
date: '2026-06-29'
project: claude-plugins
domain: architecture
tags:
- borg-collective
- source-of-truth
- cairn
- directive-resolution
alternatives: []
applies_to: []
confidence: 0.95
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260629-2126-claude-plugins
created_at: '2026-06-29 23:23:59.799142+00:00'
updated_at: '2026-06-29 23:23:59.799150+00:00'
---

# 20260527-borg-collective-source-of-truth-resolved

## decision

borg-collective source-of-truth RESOLVED: ~/dev/borg-collective/ is canonical for all skill files and hooks; claude-plugins/borg-collective/ distributes the publishable, privacy-filtered subset only and never originates edits. cairn is OPTIONAL for borg skills (cairn_available() check, filesystem fallback, lazy import, never hard-required).

## context

Supersedes the open risk in obs-20260527-borg-collective-dual-source-risk, which framed the dual-source question as still requiring an owner decision. The directive docs/plans/directives/2026-05-27-borg-cairn-coordination.md was confirmed 2026-05-27, tracing the decision to Dispatch session f9ef8d07 (2026-05-24) that created the plugin and named ~/dev/borg-collective/ as the source repo with an explicit privacy exclusion list.

## reasoning

The dual-source-risk observation keeps resurfacing in /borg-link recall as an unresolved risk even though both decisions (canonical repo + optional cairn) were locked on 2026-05-27. Recording the resolving decision so recall reflects current state. Remaining OPEN follow-ups (not blockers): (1) archive ~/dev/borg-collective/ vs keep as research repo once the plugin stabilizes; (2) whether borg skills should upgrade optional->prefer cairn after cairn v0.1.0.
