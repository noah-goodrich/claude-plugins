---
class: voiced
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 1133
source_article: the-long-game.md
prompt: |
  Write a technical blog post titled "The Long Game" about Leadership as stewardship, evaluated by the health and resilience of a system years after the leader has moved on rather than by near-term performance.. Aim for about 1133 words. The audience is working data engineers.

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

# The Long Game

Three years ago I inherited a pipeline that a very smart person built very fast.

The guy who wrote it had been a legend at that company. He shipped a data warehouse migration in five months that the previous team had failed to deliver in eighteen. Executives loved him. He got promoted twice, then took a director role somewhere else, and by the time I sat down in his chair he was two companies removed from anything he had built. What he left behind was 340 dbt models, 11 of which had tests, and a scheduler with 62 DAGs where the dependency graph existed entirely in his head. There was a Slack channel named after him that people still used to ask questions he was no longer around to answer.

His near-term performance was extraordinary. His stewardship was a catastrophe.

I want to talk about that gap, because I think we measure leadership in data organizations almost exclusively on the wrong side of it. And I want to use a metaphor that has stuck with me since I first read about how the U.S. Forest Service actually thinks about fire, because I have not found a better frame for what leading a data platform is supposed to be.

## The Fire-Warden's Problem

For most of the twentieth century, American fire policy was built around a single rule: put out every fire as fast as possible. It was called the 10 a.m. policy, and it meant that any fire spotted should be contained by ten o'clock the next morning. On paper, it worked beautifully. Acres burned dropped year over year. Every annual report showed a fire-warden who was winning.

What nobody was measuring was the fuel load. Every small fire suppressed is dead wood that doesn't burn, undergrowth that doesn't clear, seedlings that grow into a dense canopy where there used to be gaps. A forest that has not burned in eighty years is not a healthy forest, it is a bomb with a very patient fuse. The fire-wardens who looked best in 1955 handed their successors a system that could no longer absorb a lightning strike without losing half a million acres.

That is the shape of the problem. A **fire-warden** is judged on this season's acres burned, but the health of the forest is determined by decisions whose consequences arrive two decades after the warden has retired. The metrics that make you look good and the metrics that make the system survive are not just different, they are frequently in direct opposition.

Data leadership works exactly the same way. The pipeline I inherited had a spectacular acres-burned number. Five months instead of eighteen. And it got there by suppressing every small fire that would have cleared the underbrush: no tests, because tests slow you down; no documentation, because the person who knows everything is right there; no interface boundaries between models, because abstraction is a cost you pay upfront. Every one of those choices was locally rational and every one of them added fuel.

## What the Fuel Load Actually Looks Like

I spent my first four months in that role doing nothing that would have shown up on a quarterly review. I mapped the DAG dependencies into an actual document. I added tests to the 30 models that fed executive reporting, which took longer than it should have because half of them turned out to be silently wrong and nobody had noticed for fourteen months. I broke a 900-line SQL model into six pieces with names that described what they did.

None of that generated a new dashboard. My manager was patient about it, which I did not appreciate enough at the time, because a less patient manager would have been entirely justified in asking why the new hire was spending a third of a year reorganizing things that already worked. From the outside, refactoring looks identical to procrastination. That is the fire-warden's trap in miniature: the work that reduces fuel load is invisible, unglamorous, and produces no measurable output in the period during which you do it.

Here is what I have come to believe is the actual test, and it is uncomfortable. The health of a data system is measured by how it behaves when the person who built it is unreachable. Not on vacation. Unreachable. Gone to another company, out of the industry, uninterested in your Slack message. Every piece of tribal knowledge in your head is a suppressed fire, and the fuel it leaves behind is the hour, or the week, or the quarter that someone loses reconstructing what you already knew.

I ran a version of this test on purpose at my next role. We had a senior engineer, Dana, who owned our customer identity resolution logic, which is the kind of thing that is genuinely hard and genuinely fiddly and where the edge cases only make sense if you were in the room for the conversations. She was our single point of failure and everyone knew it. So we did something that cost us about six weeks of feature velocity: Dana stopped touching the identity codebase, and a mid-level engineer named Marcus took over with Dana available only to review pull requests, never to write them. Marcus was slower. Some things broke. Dana wrote documentation she found tedious. Six weeks of underbrush clearing.

Eleven months later Dana left for a startup, and the identity resolution system did not even hiccup. Marcus owned it. Two other engineers could work in it. When we needed to add a new source, it took four days instead of the three weeks it would have taken to first understand what Dana had built. That six-week investment is the single highest-return thing I have ever done as a lead, and it appeared on precisely zero quarterly reviews as an accomplishment.

## The Timescale Mismatch

The reason we get this wrong is not that leaders are stupid or vain. It is that the feedback loop on stewardship is longer than the average tenure of the person being evaluated. Median time in a data engineering leadership role is something like two and a half years. The consequences of architectural decisions land in year three, four, five. You are almost never in the building when the bill comes due, which means the market rewards fuel accumulation and has no mechanism at all for punishing it.

I have started asking a different question in interviews, both as a candidate and as a hiring manager. Not "what did you build," but "what are you still hearing about from the team you left?" The answers are revealing. Some people cannot answer because nobody has needed to contact them, which is the best possible answer and almost never presented as a strength. Some people light up describing how they still get pulled into incidents at a company they left in 2022, and they mean it as evidence of their importance. It is evidence of a forest they left full of dead wood.

Real leadership is **stewardship**, which means accepting that the thing you are optimizing is not this quarter's throughput but the system's capacity to absorb a lightning strike in 2031 when you are somewhere else entirely. It means writing the documentation nobody asked for, insisting on the test that slows the sprint, forcing knowledge out of your own head and into places you cannot control. It means being replaceable on purpose, and it means the reward for doing it well is that nothing dramatic happens, which is the hardest kind of success to put on a résumé.

The fire-wardens who let the small fires burn looked worse every single year than the ones who suppressed them. They were also the only ones who left behind a forest.
