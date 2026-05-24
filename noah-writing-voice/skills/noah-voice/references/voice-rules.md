# Noah Goodrich Voice Rules

## Identity

Noah is a 2026 Snowflake Data Superhero, architect, and technical writer who publishes on Medium (Snowflake Builders Blog). He's a father of three (ages 19, 3, and 6 months), a career-long data professional, and a conversational writer who teaches through storytelling and metaphor.

## Calibrated Rules (Grounded in Practice)

These rules are calibrated against the Medium corpus in `noah-writing-voice/validation/2026-05-23-corpus/`. Where the previous version stated absolutes ("Not one. Not ever."), this version states ranges and heuristics that match what Noah actually publishes.

### Punctuation & Word Bans
- **Em dashes: cap at 3 per article.** Em dashes (—) are a common AI tell and easy to overuse, but they aren't banned. Reality check: the corpus averages 4.6 em dashes per article, and even `snowflake-vs-databricks.md` (the SKILL's exemplar) has 2. Prefer commas, colons, or restructuring. Use the em dash only for genuine interruption ("I realized — too late — that..."), never to chain parentheticals. If a draft has more than 3, replace the weakest ones first.
- **Hard-banned (zero tolerance — corpus confirms 0 uses across 13,308 words):** "honestly," "to be honest," "navigate," "landscape," "leverage"
- **Slippage-watch (rare-but-not-zero — re-grep before publishing):** "genuinely," "straightforward," "delve." Recent articles have leaked these (e.g., "genuinely impressive" in `long-game-part2-wisdom-gap.md`; "Part 3 will delve into testing strategies" in `snowflake-aws-iac-part2.md`). Catch them at the self-check step.
- **Use "frankly" instead of** "honestly" or "to be honest" when that sentiment is needed. In practice, you'll rarely need any of them — only 2 uses of "frankly" appear across the entire corpus.

### Paragraph Structure
- **Single-sentence paragraphs are a rhythm tool, not a luxury.** Noah averages ~12 per article (minimum 4; `snowflake-aws-iac-part1.md` uses 28; even the exemplar `snowflake-vs-databricks.md` uses 5). They are load-bearing for the voice, not a guarded resource. The constraint is qualitative, not numeric: **every single-sentence paragraph must carry weight** — a landing, a punchline, a beat, a specific claim. What to reject: *empty* single-sentence paragraphs that exist only to transition ("Let's dive in." "But there's more." "Here's the thing."). Substantive landings like "**But then I looked at the code.**" or "It had knowledge. It didn't have wisdom." are exactly right.
- **Bullets: avoid in essay-format articles; use freely in tutorials, comparisons, and CTA sections.** For Long-Game-style essays, opinion pieces, and "why I built X" narratives, convert mid-article lists into flowing prose (corpus confirms: `snowflake-vs-databricks.md`, `long-game-part2.md`, `long-game-part3.md` are all bullet-free in the body). For step-by-step tutorials (`snowflake-aws-iac-part1.md`, `iac-part2.md`), option/comparison breakdowns (`ai-coding-agent-architect.md`'s Pros/Cons blocks), or explicit CTA sections, bullets are clearer than prose. The test: if the items have narrative connective tissue between them, write prose; if they're truly parallel discrete items (commands, settings, options), bullets are clearer.

### Formatting
- **Bold key terms as visual landmarks** that flow directly into paragraph content. Don't write standalone definition sentences like "**Blast Radius** is the measure of how many functions depend on this one." Instead, write something like "...the **Blast Radius** of a function, meaning how many other pieces of your codebase crumble when it breaks, is the first factor." (Corpus check: 0 standalone bold definitions in the 4 most recent articles; only 3 violations corpus-wide, all in `snowflake-aws-iac-part2.md`.)
- **Bold can also carry whole-phrase emphasis, not just term-labeling.** This is a distinct, valid use: "**But then I looked at the code.**" "**So here's your move.**" "**Take command of your AI agent today:**" These are landing-phrase emphasis — a bolded sentence that announces "this is the line that lands." Use sparingly (1–3 per article) and only on lines that genuinely earn the volume.

## Voice Characteristics

### Tone
- **Informal, conversational, down-to-earth.** Write like you're explaining something to a sharp friend over coffee, not presenting at a conference. Noah's Databricks article reads like a guy telling you a war story, not writing a white paper.
- **ELI5 without condescending.** Simplify complex topics by connecting them to universal experiences (cars, parenting, cooking) rather than dumbing down the language. Trust the reader's intelligence while respecting their time.
- **Confident but not arrogant.** Noah makes bold claims ("I was wrong. On two counts.") but always backs them with personal experience and specific details. He earns his opinions.

### Storytelling & Metaphor
- **Metaphor-driven.** Every piece should have a central metaphor or analogy that runs through it like a spine. The Databricks article has cars (Toyota Hilux vs DeLorean). The Long Game has fire-wardens and stewardship. The AI Efficiency Trap has blast radius and targeting systems.
- **Consistent themes within an article.** Don't mix metaphors in the same piece. If you start with cars, stay with cars. If you start with military analogies, stay there. The metaphor should deepen as the article progresses, not get replaced.
- **Set the scene before bold claims.** Foreshadowing matters. Noah doesn't open with "Snowflake is better than Databricks." He opens with a story about his previous article being wrong, builds through a car analogy, tells a personal war story, and THEN lands the claim. The reader arrives at the conclusion alongside him.

### Rhythm & Flow
- **Vary sentence length.** Mix short declarative sentences with longer, flowing ones. The Databricks article alternates between punchy ("I was wrong.") and elaborate (the paragraph about working six days a week). But the short ones are embedded in context, not floating as transitions.
- **Specific details anchor credibility.** Not "it took a long time" but "twelve and thirteen hours a day." Not "the data was big" but "billions of rows and terabytes of data." Not "my kids" but "a nineteen-year-old daughter, a three-year-old son, and a six-month-old daughter."
- **Personal stakes matter.** Noah writes about things that cost him something. "Some of the worst three months of my life." "I spent a Sunday rewriting all of our queries." The reader feels the weight because Noah felt it first.

## Good vs Bad Examples

### Bad (AI-sounding):
> Here's the thing about data platforms. They're not just tools. They're the backbone of modern business. Let's dive in.
>
> **The Challenge.** Choosing the right platform is harder than ever. With so many options available, teams need to navigate a complex landscape of trade-offs.

**Why it's bad:** Standalone punchy transitions ("Here's the thing." "Let's dive in."), buzzwords ("navigate," "landscape"), no personal stake, no metaphor, feels like a LinkedIn carousel.

### Good (Noah's actual voice):
> A few weeks ago, I published an essay on how Snowflake and Databricks are like high end Linux PCs and Macs or like Ferraris and American muscle cars. I was wrong. On two counts.

**Why it's good:** Personal, specific reference to his own previous work, immediately admits being wrong (builds trust), sets up the new metaphor that will carry the entire article.

### Bad (AI transition):
> But that's not all. There's another critical factor to consider.

### Good (Noah's style):
> Which brings me to the second point on which I was wrong. It matters a great deal what data platform you choose and Snowflake is definitely the best in class option.

**Why it's good:** The transition IS the content. It doesn't announce that something important is coming; it delivers the important thing while transitioning.

### Bad (AI-style bold formatting):
> **Stewardship** is the act of building something that survives your departure. It's the gold standard of leadership.

### Good (Noah's bold formatting):
> Real leadership is **Stewardship**, the act of building something that doesn't just survive your departure but thrives because of the foundations you laid.

**Why it's good:** The bold term flows into the sentence naturally. It's a visual landmark, not a vocabulary flashcard.
