# Snowflake Article Conventions

## Series Awareness

Noah maintains two active article series that share a philosophical foundation but serve different purposes:

### The Long Game Series
**Purpose:** Philosophical foundation. Explores leadership, stewardship, mentoring, and the long-term view of technology careers.
**Tone:** Reflective, story-driven, draws from parenting and military leadership examples.
**Key mental model:** The fire-warden vs the firefighter. Real leadership is preventing fires, not being the hero who puts them out.
**Published on:** Snowflake Builders Blog (Medium)

### WAF Series (Snowflake Well-Architected Framework)
**Purpose:** Practical manual. Concrete architectural guidance for Snowflake implementations.
**Tone:** Still Noah's voice, but more technical. Code examples, configuration details, real-world implementation patterns.
**Key tool:** snowfort (Noah's open-source CLI tool for WAF assessments)

### Connection Between Series
Both series connect through the **CCC mental model: Calm, Connect, Coach.**
- **Calm**: Step back from the fire. Understand the system before reacting.
- **Connect**: Build relationships and context. Understand why things are the way they are.
- **Coach**: Guide others toward better decisions rather than making all decisions yourself.

The Long Game provides the "why" (stewardship philosophy). The WAF Series provides the "how" (practical frameworks).

## Article Structure Pattern

Noah's articles follow a consistent structure that builds from personal to technical:

1. **Scene-setting opening**: A personal story, observation, or admission that creates emotional entry. ("Yesterday, Snowflake announced the 2026 Data Superheroes. It is a profound honor...") ("A few weeks ago, I published an essay... I was wrong.")

2. **Metaphor/analogy bridge**: A central metaphor that will carry through the entire piece. This is where the teaching begins. The metaphor connects the personal opening to the technical content. (Cars for platform comparison. Fire-wardens for stewardship. Blast radius for test prioritization.)

3. **Technical content**: The substance. But always delivered through the lens of the metaphor. Code blocks, architectural patterns, configuration examples, all connected back to the central analogy.

4. **CTA section**: The ONE place where bullet points are acceptable. Calls to action, resources, next steps. Keep it concise.

## The PoEAA/Rails Analogy Pattern

Noah frequently uses what he calls the "PoEAA/Rails" pattern (named after how Martin Fowler's Patterns of Enterprise Application Architecture concepts became accessible through Ruby on Rails):

1. Start with a metaphor that hooks (the Rails experience)
2. Unpack as an analogy to teach the underlying concept (the PoEAA theory)
3. Apply to the specific technical problem at hand

This pattern makes dense technical concepts accessible without dumbing them down. The reader gets the intuition first, then the rigor.

## Image Prompt Rules

When generating image prompts for article illustrations:
- **NEVER use the word "snowflake"** in image prompt copy. Image generation models will render literal snowflakes instead of anything related to the Snowflake data platform.
- Use descriptive alternatives: "data warehouse," "cloud platform," "data architecture," etc.

## Code vs Screenshots

- **Prefer code blocks** over screenshots for all code, SQL, configuration, and terminal output
- **Exception:** snowfort TUI output can use screenshots because the terminal UI formatting is part of the value
- Code blocks are searchable, copyable, and accessible. Screenshots are not.

## Structural Redundancy Analysis

Available on request (not automatic). When asked, perform this analysis:
1. Map every major point or claim in the article
2. Count how many times each point appears (sometimes in different words)
3. Identify which repetitions are intentional reinforcement vs accidental redundancy
4. Propose a consolidated structure that keeps intentional echoes and removes accidental repetition
