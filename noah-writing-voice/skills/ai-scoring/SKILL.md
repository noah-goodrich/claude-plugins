---
name: ai-scoring
description: "AI detection scoring for all written output. This skill MUST run automatically before presenting ANY written content to the user. Use whenever generating, editing, or revising articles, blog posts, LinkedIn posts, emails, documentation, social media content, or any prose meant for human readers. Scores writing on a 0-100 scale for how human vs AI it reads, flags specific AI tells with line-level citations, and suggests concrete rewrites. If you are about to show the user written text, run this scoring pass first. No exceptions."
---

# AI Detection Scoring Skill

Every piece of written content must pass through this scoring system before being presented to the user. This isn't optional. Noah's reputation depends on his writing reading as authentically human.

## Dependencies

This skill works alongside the `noah-voice` skill. Apply voice rules first during writing, then run this scoring pass before delivery.

## How to Score

Read the entire piece of writing and evaluate it against each of the detection categories below. For each category, assign a penalty based on severity. Start at 100 (fully human) and subtract points.

## AI Tell Categories

### 1. Staccato Rhythm (up to -20 points)
**What to look for:** Excessive single-sentence paragraphs, especially used as transitions. AI loves the dramatic one-liner drop:

> "But that wasn't the real problem."
>
> "The answer surprised me."
>
> "And then everything changed."

**Scoring:** 1-2 single-sentence paragraphs in an article = fine (-0). 3-4 = noticeable (-5 to -10). 5+ = very AI (-15 to -20).

**Fix:** Fold the standalone sentence into its neighboring paragraph, or expand it with a supporting detail that earns the pause.

### 2. Too-Clean Parallel Structure (up to -15 points)
**What to look for:** Three or more consecutive sentences or paragraphs following the exact same syntactic pattern. AI generates unnervingly symmetrical prose:

> "The first lesson was about patience. The second lesson was about persistence. The third lesson was about perspective."

**Scoring:** Occasional parallelism is fine and even powerful (-0). But when every section opening, every transition, or every list item follows the same grammatical template, it reads as generated (-5 to -15 depending on how pervasive).

**Fix:** Break the pattern. Vary sentence openings. Let some ideas take two sentences while others take half a sentence embedded in a larger thought.

### 3. Generic Transitions (up to -15 points)
**What to look for:** Transitions that announce they're transitioning instead of actually moving the narrative forward:

- "Here's the thing"
- "Let's dive in"
- "That said"
- "But here's the kicker"
- "Let me explain"
- "So, what does this mean?"
- "The truth is"
- "It's worth noting"
- "At the end of the day"
- "The bottom line"
- "But wait, there's more"

**Scoring:** 1 instance = minor (-2). 2-3 = noticeable (-5 to -10). 4+ = clearly AI (-15).

**Fix:** Delete the transition entirely and see if the text still flows. Usually it does. If a bridge is needed, make the transition carry actual content: instead of "Here's the thing about data platforms," write a sentence that IS the thing about data platforms.

### 4. Overly Balanced/Hedged Statements (up to -10 points)
**What to look for:** AI reflexively presents "both sides" even when the author has a clear position. Watch for:

- "While X has its merits, Y also offers..."
- "There are pros and cons to both approaches"
- "It depends on your specific use case"
- Diplomatic conclusions that refuse to commit

**Scoring:** Noah has opinions and states them. One hedge in a nuanced section = fine (-0). Pattern of hedging throughout = AI (-5 to -10).

**Fix:** Take a position. Back it with evidence. Noah wrote "I was wrong" and "Snowflake is definitely the best in class option." He didn't write "both platforms have their strengths."

### 5. Repetitive Sentence-Opening Patterns (up to -10 points)
**What to look for:** Multiple consecutive sentences starting with the same word or structure, especially "I," "The," "This," or "It." AI tends to fall into opening ruts.

**Scoring:** 3+ consecutive sentences with the same opening pattern = -5. Pervasive throughout = -10.

**Fix:** Restructure sentences. Lead with different elements: a prepositional phrase, a dependent clause, a direct object, a quote, a question.

### 6. Lists Disguised as Prose (up to -10 points)
**What to look for:** Paragraphs that are clearly bullet points reformatted as sentences. Each sentence covers exactly one discrete point with no flowing connection to the next:

> "The tool analyzes code complexity. It also measures test coverage. Additionally, it tracks dependency graphs. Furthermore, it generates priority scores."

**Scoring:** One instance = -3. Multiple = -5 to -10.

**Fix:** Weave the points together. Show how they connect. Let one idea flow into the next naturally rather than stacking discrete facts.

### 7. Lack of Specific/Personal/Surprising Detail (up to -15 points)
**What to look for:** Vague claims without receipts. AI tends toward generality:

- "many companies are facing challenges" (which companies? what challenges?)
- "this can significantly improve performance" (by how much? in what context?)
- "in my experience" without actually describing the experience

**Scoring:** Human writing is specific. Noah writes "twelve and thirteen hours a day" not "long hours." He writes "billions of rows and terabytes of data" not "large datasets." Vagueness throughout = -10 to -15.

**Fix:** Add the specific number, name, date, or anecdote. If you don't have one, that's a signal the claim might not be earned.

### 8. Banned Words and Phrases (up to -10 points)
**What to look for:** Words that are AI calling cards:

- "genuinely," "straightforward"
- "navigate," "landscape," "leverage," "delve"
- "game-changer," "cutting-edge," "revolutionary"
- "in today's fast-paced world"
- "it's important to note that"
- "synergy," "paradigm shift"
- Em dashes (Noah's specific ban)

**Scoring:** 1-2 instances = -3. 3+ = -5 to -10.

**Fix:** Replace with plain language. "Use" not "leverage." "Area" or "field" not "landscape." Cut the filler phrases entirely.

## Output Format

Present the score and findings in this format:

```
AI DETECTION SCORE: [X]/100

FLAGGED PASSAGES:
1. [Category]: "[quoted passage]"
   Why: [specific reason this reads as AI]
   Suggested rewrite: "[concrete alternative]"

2. [Category]: "[quoted passage]"
   Why: [specific reason]
   Suggested rewrite: "[concrete alternative]"

SUMMARY: [1-2 sentence overall assessment]
```

## Score Thresholds

- **90-100:** Reads fully human. Ship it.
- **75-89:** Minor AI tells. Worth a quick revision pass but publishable.
- **60-74:** Noticeable AI patterns. Needs revision before publishing.
- **Below 60:** Heavy AI fingerprint. Significant rewrite needed.

For Noah's Snowflake Builders Blog articles, the minimum threshold is **75** (enforced by the `snowflake-article` skill). For other content, aim for 75+ but use judgment.

## Important Nuance

This scoring system catches patterns, not certainties. A human writer might occasionally use parallel structure or a generic transition. The score reflects the cumulative effect: any one tell is minor, but they compound. A piece with clean rhythm, specific details, and a strong personal voice can afford one or two flags. A piece with five or six different AI patterns, even if each is individually mild, reads as generated.

The goal isn't robotic avoidance of every flagged pattern. It's awareness. Flag the patterns, offer alternatives, and let the writer (or the voice skill) make the call.
