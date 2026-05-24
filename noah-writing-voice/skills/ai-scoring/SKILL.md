---
name: ai-scoring
description: "AI detection and voice-compliance scoring for all written output. This skill MUST run automatically before presenting ANY written content to the user. Use whenever generating, editing, or revising articles, blog posts, LinkedIn posts, emails, documentation, social media content, or any prose meant for human readers. Scores writing on two independent axes (AI-likeness and voice-compliance), flags specific tells with line-level citations, and suggests concrete rewrites. If you are about to show the user written text, run this scoring pass first. No exceptions."
---

# AI Detection + Voice Compliance Scoring Skill

Every piece of written content must pass through this scoring system before being presented to the user. This isn't optional. Noah's reputation depends on his writing reading as authentically human AND as authentically *him*.

## What Changed (May 2026 redesign)

The previous version of this skill conflated two different concepts: "this sounds AI-generated" and "this violates Noah's voice rules." They aren't the same thing. The 2026-05-23 validation (`noah-writing-voice/validation/2026-05-23-corpus/`) showed that the old framework flagged Noah's own published Medium articles as AI 50% of the time, including pieces he is publicly proud of. The two categories that caused 100% of those false positives (Staccato rhythm and em-dash counting) were inverted against Noah's actual rhythm and punctuation.

This redesign splits the framework into two independent axes and replaces or reworks the broken categories:

- **Axis A: AI-Likeness** — does this read like LLM output, regardless of who wrote it
- **Axis B: Voice-Compliance** — does this match `noah-voice` rules, regardless of whether it sounds AI

A piece can score high on one axis and low on the other. Both axes are reported. The publishing decision should consider both.

## Dependencies

This skill works alongside the `noah-voice` skill. Apply voice rules first during writing. Run this scoring pass before delivery. Axis B in this skill checks the same rules `noah-voice` codifies — it's the after-the-fact compliance check on those rules.

## Inputs

Before scoring, identify (or ask for) the **article type**. Thresholds and category weights differ by type. If unspecified, default to `essay`.

| Type | Description | Examples |
|------|-------------|----------|
| `essay` | Personal essay, opinion piece, "why I built X" narrative | Long Game series, Snowflake-vs-Databricks |
| `tutorial` | Step-by-step how-to with code | snowflake-aws-iac-part1/2 |
| `opinion` | Position piece with claim + defense | being-told-i-could-be-fired |
| `linkedin-post` | Short social-format post | LinkedIn promo posts |
| `documentation` | Reference docs, READMEs | Plugin READMEs |

## How to Score

Read the entire piece. For each axis, evaluate every category. Each axis starts at 100 (fully passing) and accumulates penalties.

Where the rule applies "only to certain article types," the per-type table at the end of this document defines the weight. If a category is disabled for a type, it contributes 0 regardless of what you find.

---

## Axis A — AI-Likeness Categories

Six categories. These are *only* signals that genuinely separate human writing from LLM output. They were validated against the May 2026 corpus: cleanly separating Noah's 10 Medium articles from 5 hand-rolled AI samples on the same topics.

### A1. Generic AI Transitions (up to -20 points)

**What to look for:** Transitions that announce themselves rather than carry content. These are the cleanest AI signal in the validation set (Noah corpus total: -8; AI corpus total: -75).

Phrase list:
- "Here's the thing" / "Here's the thing, though"
- "Let's dive in" / "Let's dive into"
- "That said"
- "But here's the kicker"
- "Let me explain"
- "So, what does this mean?"
- "The truth is"
- "It's worth noting"
- "At the end of the day"
- "The bottom line"
- "But wait, there's more"
- "Moreover," / "Furthermore," / "In conclusion,"

**Scoring:** 1 instance = -3. 2-3 = -8. 4+ = -15 to -20.

**Note:** "Here's the thing" has crept into Noah's recent Medium articles (`long-game-part2-wisdom-gap.md` "Note on Process"; `long-game-part3-architects-anchor.md` L68). Flag it; don't excuse it because the article is otherwise human.

**Fix:** Delete the transition entirely and see if the text still flows. Usually it does. If a bridge is needed, make the transition carry actual content.

### A2. Overly Balanced / False-Hedge Statements (up to -10 points)

**What to look for:** Reflexive "both sides" framing in places the author has a clear position. Good separator in validation (Noah -9 vs AI -39).

Phrase patterns:
- "While X has its merits, Y also offers..."
- "There are pros and cons to both approaches"
- "It depends on your specific use case"
- "Ultimately, the choice comes down to..."
- Diplomatic conclusions that refuse to commit

**Scoring:** 1 hedge in a genuinely nuanced section = 0. Pattern of hedging throughout = -5 to -10.

**Fix:** Take a position. Back it with evidence. Noah wrote "I was wrong" and "Snowflake is definitely the best in class option." He didn't write "both platforms have their strengths."

### A3. Lists Disguised as Prose (up to -10 points)

**What to look for:** Paragraphs that are clearly bullet points reformatted as sentences. Each sentence covers one discrete point with mechanical connectors. Perfectly clean signal in validation (Noah 0 vs AI -15).

Trigger: paragraph contains ≥3 sentences, ≥2 of them short (≤18 words), connected by "also," "additionally," "furthermore," "moreover," "what's more."

> "The tool analyzes code complexity. It also measures test coverage. Additionally, it tracks dependency graphs. Furthermore, it generates priority scores."

**Scoring:** 1 instance = -3. 2+ = -7 to -10.

**Fix:** Weave the points together. Show how they connect. Let one idea flow into the next.

### A4. Mechanical Parallel Structure (up to -15 points)

**What to look for:** Four or more consecutive sentences or paragraphs following the *exact same* syntactic pattern. AI generates symmetrical prose to a degree humans rarely do.

Triggers:
- 4+ consecutive sentences with identical first word
- 4+ consecutive paragraphs starting "The first/second/third Nth..."
- 4+ consecutive sentences of form "[Subject] [verb] [object]" with same subject and same verb form

**Scoring:** Occasional parallelism is fine and even powerful (Noah's "I was wrong. On two counts. First... Second..." is parallel and right). Penalize only when it goes mechanical: 1 cluster = -5. 2+ = -10 to -15.

**Note:** Threshold raised from 3+ to 4+ vs the old framework. Three-clause parallelism is a standard rhetorical move ("I came, I saw, I conquered"). Four+ starts to read mechanical.

**Fix:** Break the pattern. Vary openings. Let some ideas take two sentences while others take half a sentence embedded in a larger thought.

### A5. Empty Single-Sentence Transitions (up to -15 points)

**What to look for:** Single-sentence paragraphs that exist only to transition, with no specific content. This *replaces* the old Cat 1 (Staccato), which counted ALL single-sentence paragraphs and was inverted against Noah's actual rhythm.

A single-sentence paragraph counts as an "empty transition" if **BOTH** of these hold:
1. It is **≤8 words** OR it matches a known generic-transition phrase (the A1 list above)
2. It contains **no specific tokens** (no numbers, no currency, no named entities, no quoted phrases, no first-person verbs)

Examples of empty transitions (flag these):
- "But that wasn't the real problem."
- "The answer surprised me."
- "And then everything changed."
- "Let's break it down."

Examples of substantive single-sentence paragraphs (do NOT flag — these are Noah's voice):
- "I was wrong. On two counts." (specific claim, first-person)
- "It had knowledge. It didn't have wisdom." (specific contrast)
- "**But then I looked at the code.**" (specific action + bold landing)
- "Three pounds, fourteen ounces." (specific number)

**Scoring:** 1-2 empty transitions = 0. 3-4 = -7. 5+ = -15.

**Critical:** count only the *empty* ones. Noah averages 12 substantive single-sentence paragraphs per article. Those are correct.

**Fix:** If it's a bare transition, fold it into a neighboring paragraph. If it's filler, delete it.

### A6. Low Anecdote Density (up to -15 points)

**What to look for:** AI-generated text in technical domains often uses the same proper nouns as humans (Snowflake, AWS, Terraform) but lacks specific personal anecdotes. This *replaces* the old Cat 7 (numeric-token density), which was a dead check.

**Operationalization:** count sentences matching the pattern `(I|we|my|our) <past-tense verb> ... <specific token>` where specific token = number, currency, named person, specific date, or named place. Examples that count:

- "I spent twelve and thirteen hours a day on the queries." (I + spent + 12, 13)
- "We hit a $50,000 Snowflake bill that month." (We + hit + $50k)
- "My nineteen-year-old daughter has a hard time remembering the route to the grocery store." (My + has + nineteen-year-old)
- "I set STATEMENT_TIMEOUT_IN_SECONDS to 3600 after a query ran for two days." (I + set + 3600, two days)

**Threshold (varies by article type, see weighting table):**
- For `essay` and `opinion`: expect ≥ 1 anecdote per 300 words.
  - < 1 per 300w = -5
  - < 1 per 500w = -10
  - < 1 per 1000w = -15
- For `tutorial`: lower expectation, since tutorials anchor on commands not anecdotes. Skip this check (weight = 0).
- For `linkedin-post`: expect ≥ 1 anecdote per 100w (posts are short).
- For `documentation`: skip this check.

**Fix:** Replace abstract examples with a specific personal anecdote. Add the dollar amount, the date, the name. If you don't have one, ask whether the claim is earned.

---

## Axis B — Voice Compliance Categories

Six categories. These come straight from `noah-voice`. They affect whether the piece is publishable on the voice axis. A piece can read fully human (high Axis A) while still violating these (low Axis B), and vice versa.

### B1. Em-Dash Count (up to -10 points)

Count em dashes (—). Per `voice-rules.md`, cap is 3 per article (not 0).

- 0-3 em dashes = 0
- 4-5 = -5
- 6+ = -10

**Critical:** Do NOT treat em dashes as an AI tell. Noah uses them constantly. This is a *voice* preference, not an AI signal.

### B2. Hard-Banned Words (up to -15 points)

Hard ban — zero tolerance. Validated 0 uses across Noah's 13,308-word corpus. Grep for:

- "honestly" (use "frankly" instead if needed)
- "to be honest"
- "navigate" (the verb sense)
- "landscape" (the metaphorical sense)
- "leverage" (the verb sense)

**Scoring:** Any single use = -5. 2+ = -10 to -15.

### B3. Slippage-Watch Words (up to -7 points)

Rare-but-not-zero. These have leaked into recent published articles. Grep specifically:

- "genuinely" (leaked into `long-game-part2-wisdom-gap.md`)
- "straightforward" (leaked into `snowflake-aws-iac-part2.md`)
- "delve" (leaked into `snowflake-aws-iac-part2.md`)

**Scoring:** 1 use = -3. 2 = -5. 3+ = -7.

### B4. Bold Formatting Pattern (up to -5 points)

Per `voice-rules.md`, bold terms should flow into sentence content, not stand as definition flashcards.

**Bad pattern (flag):**
> **Stewardship** is the act of building something that survives your departure.

**Good pattern (don't flag):**
> Real leadership is **Stewardship**, the act of building something that...

Also valid (don't flag): whole-phrase bold emphasis on a landing line like **"So here's your move."**

**Scoring:** 1 standalone bold definition = -3. 2+ = -5.

### B5. Bullets in Wrong Genre (up to -10 points)

Per `voice-rules.md`, bullets are allowed in tutorials, comparisons, and CTA sections. Bullets in essay-format article bodies are wrong.

- For `tutorial`, `documentation`: no penalty for bullets.
- For `essay`, `opinion`: any mid-body bullet block = -5. Multiple = -10.
- For `linkedin-post`: case-by-case; usually bullets are fine for the listicle format.

### B6. Lack of Specific Detail (up to -10 points)

Per `voice-rules.md`, the strongest signature of Noah's voice is concrete detail. This overlaps with A6 (anecdote density) but is broader — it includes all specific tokens, not just first-person anecdotes.

**Scoring:** Read the piece end-to-end. Ask: does every major claim have a specific receipt (number, name, date, dollar amount, named system)?

- Pervasively vague = -10
- Some vague claims = -5
- All claims specifically anchored = 0

---

## Article-Type Weighting Table

| Category | essay | tutorial | opinion | linkedin-post | documentation |
|----------|-------|----------|---------|---------------|---------------|
| A1 Transitions | 1.0 | 0.5 | 1.0 | 1.0 | 0.7 |
| A2 Hedging | 1.0 | 0.3 | 1.0 | 1.0 | 0.5 |
| A3 Lists-as-prose | 1.0 | 0.0 | 1.0 | 0.7 | 0.5 |
| A4 Parallel | 1.0 | 0.5 | 1.0 | 1.0 | 0.7 |
| A5 Empty transitions | 1.0 | 0.5 | 1.0 | 0.7 | 0.7 |
| A6 Anecdote density | 1.0 | 0.0 | 1.0 | 1.0 | 0.0 |
| B1 Em-dashes | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 |
| B2 Hard-banned | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 |
| B3 Slippage-watch | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 |
| B4 Bold pattern | 1.0 | 0.7 | 1.0 | 1.0 | 0.7 |
| B5 Bullets-in-genre | 1.0 | 0.0 | 1.0 | 0.3 | 0.0 |
| B6 Specific detail | 1.0 | 0.7 | 1.0 | 1.0 | 0.7 |

Multiply each category's raw penalty by its weight before subtracting from the axis score.

---

## Output Format

Present both axes side-by-side with flags and suggestions:

```
ARTICLE TYPE: [type, e.g. essay]
WORD COUNT: [N]

AXIS A — AI-LIKENESS SCORE: [X]/100
AXIS B — VOICE-COMPLIANCE SCORE: [Y]/100

AXIS A FLAGS (reads as LLM output):
1. [Category code, e.g. A1]: "[quoted passage]"
   Why: [specific reason this reads as AI]
   Suggested rewrite: "[concrete alternative]"

AXIS B FLAGS (violates noah-voice rules):
1. [Category code, e.g. B2]: "[quoted passage]"
   Why: [specific noah-voice rule violated]
   Suggested fix: "[concrete alternative]"

SUMMARY: [1-2 sentence assessment of both axes]

PUBLISHING VERDICT: [ship / quick revision / significant rewrite, broken down per axis]
```

## Score Thresholds (Per Axis)

| Score | Interpretation |
|-------|----------------|
| 90-100 | Clean. Ship. |
| 75-89 | Minor issues. Worth a quick revision pass but publishable. |
| 65-74 | Noticeable issues. Revise before publishing. |
| < 65 | Significant problems. Rewrite the affected sections. |

**Publishing decision:** consider BOTH axes. A piece scoring 90 on Axis A but 60 on Axis B reads human but isn't recognizably Noah's voice — fix the voice issues. A piece scoring 60 on Axis A but 90 on Axis B sounds AI-generated but in Noah's preferred style — fix the AI tells.

For Snowflake Builders Blog articles, the recommended minimum is **75 on both axes**. (Note: the existing `snowflake-article` skill enforces 75 on the legacy single-axis score. That threshold should be re-baselined against this new framework before being treated as a hard gate — see `noah-writing-voice/validation/2026-05-23-corpus/RECOMMENDATIONS.md` Decision 4.)

## Sanity-Check Behavior

Before reporting scores, verify these two anti-failure conditions:

1. **Don't flag Noah's own structural moves as AI.** If a passage matches a Signature Structural Move from `noah-voice/references/voice-rules.md` (the "I was wrong" opener, the family-anchor pivot, the "Your move" CTA, etc.), it is *not* an AI flag. The new Axis A categories should not trigger on these by construction, but double-check.

2. **Don't flag substantive single-sentence paragraphs.** Re-read each one flagged under A5. If it contains a specific claim, named entity, number, or first-person verb, drop the flag. The check is for *empty* transitions only.

## Important Nuance

This scoring system catches patterns, not certainties. The dual-axis design means most pieces will lean strong on one axis and have some friction on the other. That's normal. The score reflects the cumulative effect within each axis: any one tell is minor, but they compound.

The goal isn't robotic compliance. It's awareness. Flag the patterns, offer alternatives, and let the writer make the call.

## Calibration Provenance

This skill's design and thresholds were calibrated against:

- **10 Noah Medium articles** (Jan 2022 → Mar 2026, ~13,308 words) — `noah-writing-voice/validation/2026-05-23-corpus/articles/`
- **5 hand-rolled AI samples** on Noah's topics — `noah-writing-voice/validation/2026-05-23-corpus/ai-samples/`

Against the old single-axis framework, F1 was 0.67 (precision 0.50, recall 1.00). The redesign targets F1 ≥ 0.85 with Noah's actual published work scoring ≥ 75 on both axes.
