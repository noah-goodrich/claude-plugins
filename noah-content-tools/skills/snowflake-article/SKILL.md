---
name: snowflake-article
description: "Snowflake article writing and editing skill for Medium and the Snowflake Builders Blog. Use whenever writing, editing, drafting, or revising articles for Medium, the Snowflake Builders Blog, WAF series content, Long Game series content, or any technical article related to Snowflake, data engineering architecture, or snowfort. Also trigger when the user mentions article structure, series planning, or asks for feedback on article drafts. Enforces article-specific conventions on top of the noah-voice skill, including mandatory AI detection scoring before delivery."
---

# Snowflake Article Skill

This skill enforces article-specific conventions for Noah's Medium and Snowflake Builders Blog writing. It layers on top of the foundational voice and AI detection skills.

## Dependencies

Both of these skills must be loaded and applied:

- **noah-voice**: Read `references/voice-rules.md` and at least one example article before writing. All voice rules apply.
- **ai-scoring**: Run the scoring pass and present the draft with its score and flags attached, whatever the score is. Do not revise to clear the threshold before showing it — see Quality Report below.

## Before Writing

1. Read the `noah-voice` skill's voice rules and at least one reference article
2. Read `references/article-conventions.md` in this skill's directory for series context, structure patterns, and technical conventions
3. Identify which series this article belongs to (Long Game, WAF, or standalone) and apply the appropriate tone

## Article Structure

Every article follows this progression. Read `references/article-conventions.md` for detailed explanation and examples of each stage:

### 1. Scene-Setting Opening
Start with a personal story, observation, or honest admission. Not a topic introduction. Not "In this article, we'll explore..." The reader should feel something before they learn something. Noah's Databricks article opens with admitting his previous article was wrong. The Long Game opens with reflecting on the Data Superhero title.

### 2. Metaphor/Analogy Bridge
Introduce the central metaphor that will carry the entire piece. This is the teaching tool. The metaphor must be:
- Accessible (something most readers have experienced)
- Extensible (rich enough to carry multiple points)
- Consistent (don't switch metaphors mid-article)

Refer to the **PoEAA/Rails pattern** in `references/article-conventions.md`: hook with the metaphor, unpack as an analogy, apply to the technical problem.

### 3. Technical Content
Deliver the substance through the lens of the metaphor. This is where code blocks, architectural patterns, and Snowflake-specific content lives.

**Code formatting rules:**
- Use code blocks, not screenshots, for all code/SQL/config
- Exception: snowfort TUI output can use screenshots (the terminal UI formatting matters)
- **Never use the word "snowflake" in image generation prompts** because models render literal snowflakes

### 4. CTA Section
This is the ONE place bullet points are acceptable. Keep it to 3-5 actionable items. Link to resources, next articles in the series, or community connections.

## Series Awareness

When writing for either series, maintain awareness of how they connect:

**The Long Game** = philosophical foundation (leadership, stewardship, mentoring)
**WAF Series** = practical manual (architecture, implementation, snowfort)
**Connection:** The CCC mental model (Calm, Connect, Coach) bridges both. See `references/article-conventions.md` for details.

When referencing the other series, do it naturally: "As I explored in The Long Game, the real test of architecture isn't how it performs under your watch..." Don't force cross-references. Let them emerge from the content.

## Quality Report

Before presenting any article draft:

1. Run the `ai-scoring` skill
2. Present the draft with its score and the specific flagged passages, whatever the score is
3. If you acted on a flag because the flag was right, say which one and what you changed
4. Never re-score in a loop to clear the threshold

**The score is evidence for Noah's decision, not a bar to clear on his behalf.** A draft that arrives at 68 with
its three flags named is more useful than the same draft quietly rewritten to 76, because the rewrite is where his
voice goes.

This is deliberate and reverses the previous instruction. The rubric flags 5 of Noah's 10 published articles as
machine-written, and its threshold sits at his corpus median, so roughly half fails as arithmetic rather than as a
judgement about the writing. Revising to clear it means editing his voice out to satisfy a number that is known to
be wrong. See `docs/plans/directives/2026-08-26-ai-scoring-evaluation-set.md` for the measurements and for the
work that will make the score trustworthy.

## Structural Redundancy Analysis

This analysis is available **on request only**, not automatic. When Noah asks for it, follow the process described in `references/article-conventions.md`: map every major point, count repetitions, distinguish intentional reinforcement from accidental redundancy, and propose a tighter structure.

## Common Pitfalls for AI Writing Snowflake Content

Watch out for these patterns that are especially common when writing about data platforms:

- **Falling into marketing language:** "Snowflake's powerful platform enables seamless..." Noah doesn't sound like a press release. He sounds like a practitioner who has opinions.
- **Being too balanced:** Noah has a clear preference for Snowflake and isn't shy about it. He backs it up with experience, not hype. Don't hedge with "it depends on your use case" when Noah's position is clear.
- **Generic technical examples:** Don't use the standard "SELECT * FROM customers" examples. Use examples that reflect real architectural decisions, with specifics about why one approach beats another.
- **Forgetting the human element:** Even the most technical WAF article should connect back to why this matters for the people doing the work. Architecture serves teams, not the other way around.
