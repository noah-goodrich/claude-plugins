---
name: strategic-brief
description: >-
  Strategic analysis and executive brief production skill. Use when the user asks for a
  build-vs-buy evaluation, competitive landscape analysis, technology assessment, architecture
  decision record, or executive brief for any project or tool. Also trigger when the user asks
  to evaluate whether a tool should exist, whether to rebuild it, or whether alternatives are
  better. Produces layered documents: executive summary for board audiences, full technical
  analysis for engineering and security teams.
---

# Strategic Brief Skill

This skill produces objective, evidence-based strategic analysis documents. It is designed to
challenge assumptions, not confirm them. The output should be useful whether the recommendation
is "proceed," "pivot," or "kill."

## Before You Start

1. **Read the analytical framework:** `references/framework.md` in this skill's directory.
   It defines the 9-step analysis process, the document structures, and the quality gates.
2. **Read the project:** README, docs, recent git log, pyproject.toml / package.json, test
   suite, CI config. Understand what was built and why before evaluating it.
3. **Identify the decision context:** What triggered this analysis? A go/no-go decision?
   Architecture pivot? Budget review? The context shapes emphasis.

## The Non-Negotiable Rules

1. **No advocacy.** You are an analyst, not a salesperson. If the evidence says "don't use
   this tool," say so clearly. Never soften a negative finding to protect the project.
2. **Multiple reasoning paths.** For every major conclusion, show at least two ways you
   arrived there. Name the reasoning path ("cost-driven analysis," "reliability-first
   analysis") and explain why you chose it.
3. **Challenge assumptions explicitly.** Dedicate a section to listing assumptions found in
   the code/docs and stress-testing each one. Some will hold. Some won't. Show your work.
4. **Specific numbers over vibes.** $/scan, $/year, rule counts, latency in seconds, pricing
   tiers. Vague comparisons ("much cheaper") are worthless in an executive brief.
5. **Include "what would change this."** Every recommendation has conditions under which it
   becomes wrong. Name them. This builds trust and gives the reader a framework for
   re-evaluating as conditions change.
6. **Sources or it didn't happen.** Every factual claim about a competitor, pricing model, or
   market trend needs a source. Group sources in an appendix. 20+ sources minimum.
7. **120-character line wrap.** All generated markdown hard-wraps at 120 characters.

## Research Phase

Before writing, complete these research tracks (use Explore agents in parallel):

### Track 1: Internal Analysis
- What does the tool actually do? (Read source code, not just docs)
- How complex is the implementation? Could it be replaced?
- What's the test coverage and code quality?
- What assumptions are baked into the architecture?
- What's the maintenance burden?

### Track 2: Competitive Landscape
Research in concentric rings:
1. **First-party/native:** Does the platform vendor offer this capability?
2. **Commercial tools:** Who charges money to solve this problem?
3. **Open-source:** Free alternatives, community projects, framework plugins
4. **Adjacent tools:** CSPM, observability, governance platforms that partially overlap
5. **Agent/LLM approaches:** Could an AI agent do this without custom code?

For each competitor: what it does, pricing, rule/check count, deployment model, limitations.

### Track 3: Architecture Alternatives
- Deterministic code vs LLM agent vs hybrid: cost, reliability, portability
- Build vs buy economics at 1x, 10x, 100x scale
- Security and regulatory implications of each approach
- What the market consensus pattern looks like

## Document Production

Produce two documents. See `references/framework.md` for detailed structure templates.

### Document 1: Full Strategic Analysis
Target audience: engineering leads, security team, technical stakeholders.
Length: 2500-3500 words + appendices.

Sections (in order):
1. Executive Summary (1 page, board-readable even in isolation)
2. Problem Statement & Market Gap
3. Competitive Landscape (matrix with 15+ entries)
4. Build vs Buy Analysis
5. Architecture Decision: Agent vs Deterministic vs Hybrid
6. Assumptions Challenged
7. Recommendation & Decision Framework
8. Risk Register
9. Appendices (competitive matrix, cost models, sources)

### Document 2: Executive Summary
Target audience: executive board, non-technical stakeholders.
Length: 500-800 words. Must fit on 2 printed pages.

Sections (in order):
1. The Problem (2-3 sentences)
2. What We Built / What Exists (2-3 sentences)
3. Market Position (condensed comparison)
4. Key Architecture Decision (3 bullets max)
5. Recommendation (1 paragraph)
6. Next Steps (3-5 bullets)
7. Risk Summary (3 bullets)

## Quality Gate

Before delivering, verify:
- [ ] Every major conclusion has 2+ reasoning paths shown
- [ ] At least 3 assumptions are explicitly challenged with counter-arguments
- [ ] Competitive matrix has 15+ entries with specific pricing/feature data
- [ ] Cost models use specific $/unit numbers, not relative comparisons
- [ ] "What would change this" section exists with concrete conditions
- [ ] Sources section has 20+ references
- [ ] No lines exceed 120 characters
- [ ] Executive summary works standalone (doesn't reference "see Section 5")
- [ ] Recommendation is clear and actionable, not hedged into uselessness
