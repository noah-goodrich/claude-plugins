---
id: 20260611-dir01-transcript-detect-arming
date: '2026-06-11'
project: claude-plugins
domain: architecture
tags:
- research-tools
- directive-01
- gate
- transcript-detect
- arming
alternatives: []
applies_to: []
confidence: 0.9
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260610-1742-claude-plugins
created_at: '2026-06-11 22:41:19.511266+00:00'
updated_at: '2026-06-11 22:41:19.511266+00:00'
---

# 20260611-dir01-transcript-detect-arming

## decision

Arm the Directive 01 fail-closed ground gate via transcript-detect rather than a static flag, so the gate auto-fires only on a real /deep-research invocation.

## context

The gate was firing on plugin load and unrelated commands, causing false positives. Needed a mechanism to arm the gate conditionally based on actual research session context.

## reasoning

transcript-detect can inspect the live conversation to confirm a /deep-research command was actually issued before arming the gate. This eliminates false positives without weakening the fail-closed guarantee for real research runs.
