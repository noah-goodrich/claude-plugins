# noah-content-tools

Applied content creation skills for specific platforms and publications. Layers on top of the noah-writing-voice plugin.

## Dependencies

Requires **noah-writing-voice** plugin to be installed. Both skills in this plugin reference noah-voice and ai-scoring from that plugin.

## Components

| Component | Type | Purpose |
|-----------|------|---------|
| linkedin-post | Skill | Algorithm-optimized LinkedIn post creation with 2-variant output |
| snowflake-article | Skill | Article conventions for Medium / Snowflake Builders Blog |

## Skills

### linkedin-post
Triggers on LinkedIn post requests, article promotion, and social media content. Produces 2 variants with different strategic hooks. Enforces fold optimization (210 chars), "link in comments" pattern, and specific engagement CTAs.

Includes reference files:
- Analysis of Noah's top 3 performing LinkedIn posts with pattern extraction

### snowflake-article
Triggers on article writing for Medium, Snowflake Builders Blog, WAF series, or Long Game series. Enforces scene-setting > metaphor bridge > technical content > CTA structure. Hard 75+ ai-scoring threshold. Series awareness (Long Game vs WAF connected through CCC model).

Includes reference files:
- Article conventions, series context, PoEAA/Rails analogy pattern, image prompt rules

## Usage

These skills trigger automatically based on the content type being created. No commands needed.
