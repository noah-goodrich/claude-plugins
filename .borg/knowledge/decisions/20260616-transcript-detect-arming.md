---
id: 20260616-transcript-detect-arming
date: '2026-06-16'
project: claude-plugins
domain: architecture
tags:
- research-tools
- directives
- transcript-detect
- arming
- hooks
alternatives: []
applies_to: []
confidence: 0.9
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: 20260614-1512-claude-plugins
created_at: '2026-06-16 10:27:02.491861+00:00'
updated_at: '2026-06-16 10:27:02.491862+00:00'
---

# 20260616-transcript-detect-arming

## decision

Dir 01 gate arms via transcript-detect so it only fires on a real /deep-research invocation, not on every hook event

## context

Without arming, the gate would fire on every Stop hook, adding latency and noise to all plugin operations. The gate is only meaningful in the context of a deep-research run.

## reasoning

Transcript-detect provides reliable signal that the current session actually invoked /deep-research, scoping the gate check to exactly the cases where it matters.
