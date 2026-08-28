---
class: voiced
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 1033
source_article: snowflake-vs-databricks.md
prompt: |
  Write a technical blog post titled "Snowflake vs Databricks" about How the choice between Snowflake and Databricks depends on team size, Spark expertise, and tolerance for ongoing platform maintenance.. Aim for about 1033 words. The audience is working data engineers.

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

# Snowflake vs Databricks

Three years ago I bought a used truck from a guy in Ogden who had done every bit of his own maintenance for eleven years. He had a binder. Oil changes, brake pads, a transmission rebuild he did in his own garage over a long weekend, all of it logged in his handwriting with mileage and part numbers. The truck ran beautifully. It ran beautifully because he was the kind of person who spent Saturdays under it with a creeper and a socket set, and he liked that. I am not that person. I drove it for eighteen months, ignored a whining water pump because I didn't know what a whining water pump sounded like, and eventually paid a shop $1,900 to fix what he would have handled with a $60 part.

The truck was not the problem. The truck was excellent. I was the wrong owner for it.

That's the whole argument I want to make about Snowflake and Databricks, and I want to make it carefully, because the last time I wrote about these two platforms I reached for a metaphor about Linux PCs and Macs and I got it wrong in a way that made the comparison sound like taste. It isn't taste. It's about who's going to be under the vehicle on Saturday, and whether that person exists on your team, and whether they want to be there.

## The binder is the product

Databricks is a platform built by people who assume you want the binder. Cluster configuration, instance types, autoscaling bounds, spot instance fallback policies, Photon on or off, driver sizing versus worker sizing, shuffle partitions, broadcast join thresholds, Delta file compaction schedules, Z-ordering strategy, vacuum retention windows. Every one of those knobs exists because somebody, somewhere, needed to turn it, and turning it correctly produced an outcome that no automatic system would have chosen for them.

When you have Spark expertise on staff, that's not overhead. That's power. I've watched an engineer who genuinely understood the Spark execution model look at a stage that was spilling to disk, change two configuration values and repartition an upstream write, and take a job from fifty-one minutes to nine. Nobody at any vendor was going to do that for him. The knobs were the entire reason he could.

When you don't have that person, every one of those knobs is a whining water pump you can't hear. I spent some of the worst three months of my career on a Databricks platform I did not understand, working twelve and thirteen hour days, six days a week, on pipelines processing billions of rows. I remember spending a Sunday rewriting every query in a workflow because I was convinced the SQL was the problem. It wasn't the SQL. It was a cluster configuration decision somebody had made eighteen months earlier for a workload that no longer existed. When I finally got time with an actual Databricks expert, he looked at it for maybe four minutes and told me what to change. He was right. It took him four minutes because he had spent years learning to hear the water pump.

## Snowflake sells you the dealership

Snowflake made a different bet, which is that most teams would rather pay for a warranty than own a socket set. You pick a warehouse size, roughly the same decision as choosing a rental car class, and the platform handles clustering, file layout, statistics, query planning, and the several hundred other things Databricks lets you configure. You cannot tune shuffle partitions on Snowflake because there is no shuffle partition setting to tune. That is either liberating or infuriating depending entirely on whether you had a plan for that setting.

The trade is real and it cuts both ways. There will be a query that Snowflake plans badly and you will have very few levers to fix it beyond restructuring the query, adding a clustering key, and hoping. I've hit that wall. It's frustrating in exactly the way a sealed hood is frustrating. But I hit it maybe twice a year, and the rest of the year I was shipping instead of reading execution plans, and my three kids saw me at dinner.

## Sizing the decision to your actual team

Here's where team size stops being a soft factor and becomes the whole calculation. A four-person data team where two people write SQL, one builds ingestion, and one does everything else does not have a platform engineer. It has four people who all think they can be the platform engineer for about ninety minutes a week, which is not how platform engineering works. On Databricks, that team will accumulate cluster policies nobody remembers writing, notebooks pinned to runtime 11.3 because upgrading broke something in 2023, and a monthly bill that nobody can decompose. I have seen this exact configuration more times than I want to admit.

The same four-person team on Snowflake will overspend on warehouse sizing, forget to set auto-suspend on something, and get a surprising bill in month three. Then they'll fix it with a resource monitor and a conversation, and move on. Both platforms let you waste money. Snowflake's failure modes are shallower and the fix usually fits in an afternoon.

At fifteen or twenty engineers with a dedicated platform function, the math flips hard. Now you have someone whose actual job is the binder, who wants the binder, whose performance review is measured in cluster efficiency and job SLAs. Now Databricks' configurability compounds instead of decaying. Now the machine learning workloads that Spark handles natively stop being a workaround and start being the point. If you're training models at scale, doing heavy unstructured processing, or running genuine streaming (not micro-batches you call streaming in standups), Spark's expressiveness is worth the maintenance tax you can now afford to pay.

## What to actually ask

Skip the benchmark comparisons, which are marketing artifacts on both sides. Ask instead who on your team, by name, will own cluster configuration in eighteen months. If you can't produce a name, or the name belongs to your best engineer who is already at capacity, you have answered the question. Ask what fraction of your workload is SQL transformation over structured data, because if it's above eighty percent you are paying for Spark's flexibility and using almost none of it. Ask whether your organization tolerates a platform that requires ongoing care, or whether it will fund the platform in year one, celebrate the launch, and then quietly reassign the person who understood it.

That last one has killed more Databricks implementations than any technical limitation. The platform doesn't fail. The stewardship of it fails, and the platform is the thing that shows the damage.

I don't own that truck anymore. It was a better vehicle than what I drive now, and I mean that sincerely. But I needed something I could ignore, and knowing that about myself was worth more than the extra capability I gave up. Make that assessment about your team honestly, before you sign anything, and either answer is a good one.
