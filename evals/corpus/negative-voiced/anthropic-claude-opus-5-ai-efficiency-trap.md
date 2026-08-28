---
class: voiced
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 1080
source_article: ai-efficiency-trap.md
prompt: |
  Write a technical blog post titled "The AI Efficiency Trap: Why I Built a Tool to Tell Cursor What to Test" about Scoring Python code by risk and complexity so an AI assistant writes tests for high-impact logic instead of chasing coverage percentage.. Aim for about 1080 words. The audience is working data engineers.

  Write it in Noah Goodrich's voice, following the rules below. They are the contents of noah-writing-voice/skills/noah-voice/SKILL.md and its references/voice-rules.md, reproduced verbatim.

  ===== BEGIN noah-voice/SKILL.md =====
  ---
  name: noah-voice
  description: "Noah Goodrich's writing voice enforcement skill. MANDATORY for ALL writing tasks across ALL projects. Use this skill whenever producing written content of any kind: articles, blog posts, LinkedIn posts, documentation, emails, social media, presentation scripts, README files, or any prose output. Also trigger when editing, revising, or giving feedback on existing writing. If the output includes sentences meant for humans to read (not code comments), this skill applies. Always read the voice rules and reference articles before writing."
  ---

  # Noah Goodrich Voice Skill

  This skill enforces Noah's distinctive writing voice across all written output. Noah is a conversational, metaphor-driven technical writer who teaches through storytelling and personal experience. His voice is warm, confident, specific, and deeply human.
  Scanning documents (design docs, PR bodies, directives, status updates, chat replies) use the `brevity` skill instead.

  ## Before You Write Anything

  Read these reference files in order:

  1. **Always read first:** `references/voice-rules.md` in this skill's directory. It contains the hard rules (what to never do) and voice characteristics (what to always do), with good/bad examples.

  2. **For calibration**, read at least one example article from `references/examples/` in this skill's directory. Priority order:
     - `snowflake-vs-databricks-nov2023.txt` is Noah's purest voice (pre-AI, 100% him)
     - `long-game-feb2026.txt` is a strong article he's proud of (light AI partnership)
     - `ai-efficiency-trap-dec2025.txt` shows his technical writing voice

  ## The Non-Negotiable Rules (Quick Reference)

  These are explained in detail in `voice-rules.md`, but here's the checklist:

  1. **No em dashes.** Rewrite with commas, colons, semicolons, or parentheses.
  2. **Banned words:** "genuinely," "straightforward," "honestly," "to be honest," "navigate," "landscape," "leverage," "delve"
  3. **Use "frankly"** when you need "honestly/to be honest."
  4. **No standalone punchy one-liners as transitions.** Embed observations inside larger thoughts.
  5. **No bullet-point lists in article body** (only in explicit CTA sections).
  6. **Single-sentence paragraphs are expensive.** Max 2 per article, 1 per LinkedIn post. Earn them.
  7. **Bold terms flow into paragraph content**, not as standalone definitions.
  8. **Every piece needs a central metaphor** that runs through it consistently. Don't mix metaphors.
  9. **Set the scene before bold claims.** Build the case through story, then land the point.
  10. **Specific details over vague claims.** Numbers, names, timeframes.

  ## Voice DNA

  Noah's writing feels like a smart friend explaining something over coffee. The key ingredients:

  **Storytelling as teaching.** Noah doesn't explain concepts in the abstract. He tells you about the worst three months of his life wrestling with Databricks, and through that story you understand why platform choice matters. Start with a human experience, bridge through metaphor, arrive at the insight.

  **Metaphor as structure.** The metaphor isn't decoration. It's the skeleton of the piece. Cars in the Databricks article. Fire-wardens and stewardship in The Long Game. Blast radius and targeting in the AI Efficiency Trap. Pick one metaphor family and deepen it throughout. If you started with a construction metaphor, don't switch to cooking halfway through.

  **Confidence earned through specifics.** Noah doesn't hedge with "it could be argued that..." He says "I was wrong. On two counts." But he earns that confidence by backing it up: the Sunday he rewrote all the queries, the twelve-hour days, the exact response from the Databricks expert. Bold claims need receipts.

  **Rhythm that breathes.** Mix sentence lengths. Let a long, flowing sentence carry the narrative forward, then land a short declarative one for impact. But those short sentences live inside paragraphs, not floating alone as dramatic transitions.

  ## Self-Check Before Delivering

  Before presenting any written content, run through this quick audit:

  1. Search for em dashes and replace them
  2. Search for banned words and replace them
  3. Count single-sentence paragraphs (max 2 for articles, 1 for posts)
  4. Check that bold terms flow into sentences, not standing alone
  5. Verify the central metaphor is consistent throughout
  6. Look for AI-style transitions ("Here's the thing," "Let's dive in," "That said") and remove them
  7. Confirm specific details are present (numbers, names, timeframes) rather than vague claims
  ===== END noah-voice/SKILL.md =====

  ===== BEGIN noah-voice/references/voice-rules.md =====
  # Noah Goodrich Voice Rules

  ## Identity

  Noah is a 2026 Snowflake Data Superhero, architect, and technical writer who publishes on Medium (Snowflake Builders Blog). He's a father of three (ages 19, 3, and 6 months), a career-long data professional, and a conversational writer who teaches through storytelling and metaphor.

  ## Hard Rules (Non-Negotiable)

  ### Punctuation & Word Bans
  - **No em dashes.** Not one. Not ever. Use commas, colons, semicolons, parentheses, or restructure the sentence. If you catch yourself reaching for an em dash, stop and rewrite.
  - **Never use:** "genuinely," "straightforward," "honestly," "to be honest," "navigate," "landscape," "leverage," "delve"
  - **Use "frankly" instead of** "honestly" or "to be honest" when that sentiment is needed.

  ### Paragraph Structure
  - **Single-sentence paragraphs are expensive.** An article gets at most 2. A LinkedIn post gets at most 1. Spend them only on lines that genuinely earn the pause. If a sentence doesn't land harder by standing alone, fold it into its neighbors.
  - **No standalone punchy one-liners as transitions.** This is a classic AI tell. Instead of a dramatic one-liner followed by a new section, embed the observation inside a larger thought. The punchline should be woven into the fabric of the paragraph, not dropped on a pedestal.
  - **No bullet-point lists in article body.** The only exception is explicit CTA (Call to Action) sections at the end of a piece. If you're tempted to use bullets mid-article, convert to flowing prose.

  ### Formatting
  - **Bold key terms as visual landmarks** that flow directly into paragraph content. Don't write standalone definition sentences like "**Blast Radius** is the measure of how many functions depend on this one." Instead, write something like "...the **Blast Radius** of a function, meaning how many other pieces of your codebase crumble when it breaks, is the first factor."

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
  ===== END noah-voice/references/voice-rules.md =====

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# The AI Efficiency Trap: Why I Built a Tool to Tell Cursor What to Test

On a Tuesday morning in October, our customer dimension came out of the nightly run with 43,000 duplicate rows. The merge key logic had a branch that handled late-arriving records with a null source system ID, and someone (me, three weeks earlier) had changed the comparison from a coalesce to an is-null check without thinking about the composite key. The pipeline didn't fail. It just quietly produced garbage that four downstream marts inherited before anyone was awake.

Our test suite was at 87% coverage. Three hundred and forty tests, all green.

I had spent an afternoon two months prior pointing Cursor at the repo and telling it to raise coverage. It did exactly what I asked. In about four hours it produced roughly 200 test functions and dragged us from 61% to 87%. I remember feeling pretty good about that afternoon. What I actually got was 200 tests that asserted our config loader returned a dict, that our string formatters formatted strings, and that a dataclass constructed with two arguments had two attributes. The merge key function, sixty lines with six branches and every incident ticket from the last quarter attached to it, had exactly zero tests. Cursor never touched it, because the function was hard to set up fixtures for and coverage math doesn't care about which line you cover.

That's when the metaphor clicked for me. Asking an AI to raise coverage percentage is calling in an artillery battery with map coordinates and no forward observer. The guns work beautifully. The rounds land. You get an enormous amount of ordnance downrange, and the after-action report shows impressive numbers. But nobody was standing on the ridge deciding which targets actually mattered, so you shelled an empty field while the machine gun nest kept firing.

## Volume was never the bottleneck

Before Copilot and Cursor, writing tests was expensive enough that we rationed them by instinct. You wrote a test for the gnarly function because you didn't want to hand-write forty of them and the gnarly one scared you. Scarcity did our prioritization for free.

Generation is now nearly free, and the constraint has moved. The hard part is no longer producing tests, it's deciding where to aim. I've watched three teams this year, mine included, respond to cheap generation by producing more of everything, which is how you end up with a suite that takes eleven minutes to run, breaks constantly on refactors, and still doesn't catch the bug that pages you at 2am. The AI didn't fail. It hit exactly what we told it to hit.

So I stopped trying to write better prompts and built the observer instead. It's about 400 lines of Python that walks the repo with the `ast` module, scores every function, and writes a targeting file the AI reads before it writes a single test.

## The four factors that decide a target

The first and heaviest factor is **Blast Radius**, meaning how many other pieces of the codebase break when this function breaks. I build a crude call graph by walking every module's AST, resolving imports, and counting inbound edges to each function definition. A utility that eleven modules import has a blast radius of eleven. A private helper called once from the module it lives in has a blast radius of one. This is the single strongest predictor I've found for whether a bug becomes an incident, because a bug in a leaf function annoys one person and a bug in a shared key-building function corrupts four marts before breakfast.

Second is **Cyclomatic Complexity**, the branch count, which I get from walking the AST for `If`, `For`, `While`, `Try`, boolean operators, and comprehension conditions. Straight-line code that transforms one shape into another rarely surprises you. The functions that surprise you are the ones with six paths through them, because you tested the path you were thinking about and shipped the other five untested.

Third is **Churn**, pulled from `git log --numstat` over the trailing 90 days and mapped back to line ranges so I can attribute commits to specific functions. Code that changes often is code that's still being understood. A function nobody has touched in two years has been battle-tested by production whether you wrote tests for it or not. A function edited nine times since August is where the requirements are still moving, and moving requirements are where the bugs live.

Fourth is what I call **Data Gravity**, a flag that fires when a function's AST contains anything that touches the outside world or the numbers people care about: SQL string construction, a Snowflake connector call, a write to a table, arithmetic on anything named amount, revenue, price, or balance. A pure transformation that returns a wrong list is a bug. A function that builds a MERGE statement and returns the wrong predicate is a Tuesday morning.

The scoring itself is deliberately unsophisticated, because I wanted to be able to explain any score to a teammate in one sentence:

```python
risk = (complexity * (1 + log1p(churn))) * (1 + log1p(blast_radius))
if data_gravity:
    risk *= 1.75
priority = risk * (1 - coverage_pct)
```

The final multiplication is the piece that matters. I parse `coverage.xml` and discount anything already covered, so the tool never sends the AI back to shell a target we already flattened. The output is a file at `.cursor/rules/test-targets.md` listing the top 15 functions by priority with their file path, line range, score, and a one-line explanation of why they scored high. My prompt to Cursor is now boring: read the targeting file, work the list top to bottom, write tests that exercise every branch of the named function, and do not write tests for anything not on the list.

## What changed

On our repository of about 1,100 functions, the first run put the merge key builder at the top with a score of 84. Second place was an incremental watermark calculator that four DAGs depend on. Twelve of the top fifteen were functions I could have named from memory as the ones I was afraid of, which told me the scoring was tracking something real, and three were functions I'd forgotten existed with blast radii above eight.

Cursor wrote 41 tests against that list over two sessions. Those 41 tests caught three live bugs, including a timezone comparison in the watermark logic that had been silently reprocessing an extra hour of data every night since June. Our coverage number went from 87% to 89%, which is the least interesting sentence in this article and exactly the point. We deleted about 60 of the original 200 tests along the way because they asserted nothing and broke on every rename.

Coverage percentage is a measure of how many rounds you fired. Risk scoring is the forward observer telling you which ridge to hit. The tools got good enough that firing is free, so the only skill left worth having is knowing where to point them.
