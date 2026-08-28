---
class: voiced
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 2535
source_article: the-long-game-part2-wisdom-gap.md
prompt: |
  Write a technical blog post titled "The Long Game, Part 2: The Wisdom Gap" about The gap between an AI model's recall of technical information and the judgment required to apply it correctly on a complex data platform project.. Aim for about 2535 words. The audience is working data engineers.

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

# The Long Game, Part 2: The Wisdom Gap

In the first part of this series I wrote about fire-wardens, about the difference between owning a system and tending one, about stewardship being the thing you do so that the forest is healthier after you leave than it was when you arrived. A reader emailed me afterward with a question that has been rattling around in my head ever since. He's a lead on a four-person data team and he said, more or less: my model knows more about Snowflake than my junior engineers do, and it knows more about dbt than I do. What am I supposed to do with that?

He's right, by the way. That's the uncomfortable part. I've been doing this work for the better part of two decades and there are corners of the Snowflake documentation that a model can recite verbatim while I'm still opening a browser tab. It knows the exact syntax for `ALTER TABLE ... CLUSTER BY`. It knows what `MAX_DATA_EXTENSION_TIME_IN_DAYS` does and what it defaults to. It knows the difference between a stream on a view and a stream on a table, which is a thing I have looked up more times than I want to admit. On raw recall, it beats me, it beats you, and it beats every engineer you're ever going to hire.

And it will still, given the chance, hand you an answer that costs your company three hundred dollars a day and hides the actual problem for six weeks.

## The Tuesday Morning

Last November I got pulled into a slow pipeline. The table was `fct_order_events`, roughly 6.8 billion rows and just over 3 TB, the spine of the whole reporting model at a retail client. The nightly load had run in about 22 minutes for the better part of a year. On a Tuesday in early November it took two hours and forty minutes. By Thursday it was over four hours and bleeding into the morning SLA, which is the point at which people who don't know what a micro-partition is start joining your standups.

I did what everybody does now. I pasted the query, the DDL, and the runtime history into a model and asked what was going on.

The answer was beautiful. Genuinely well-organized, well-written, and correct in the way a textbook is correct. It suggested adding a clustering key on `(event_date, store_id)` because the predicates in the downstream queries filtered on both. It suggested enabling search optimization on `order_id` for the point lookups. It suggested scaling the warehouse from Large to 2X-Large to reduce the wall-clock time, and it noted, accurately, that a larger warehouse finishing faster is not always more expensive because you pay per second. Every single one of those statements is true. I have said versions of all three of them out loud, in meetings, to clients, and been right.

All three were wrong for this table, on this day, for this problem.

The actual cause was upstream. The source system had been changed on November 3rd to resend a rolling fourteen days of history instead of a rolling two, which nobody told us because why would they. The incremental model was a `MERGE`, and the merge's join key had quietly stopped being unique for a subset of rows, so instead of touching a day's worth of micro-partitions every night, the load was rewriting close to 40% of a 3 TB table. Bytes scanned was high but bytes written was the number that mattered, and it was the number nobody was looking at.

Now walk back through those three suggestions with that in mind. Adding a clustering key to a table that's rewriting 40% of its partitions every night doesn't fix the load; it adds an automatic reclustering bill on top of it, and on a table that size that's not a rounding error. Search optimization on a table under constant heavy DML means paying to rebuild the search access path against churn you haven't stopped. And scaling to 2X-Large would have taken a four-hour job down to maybe ninety minutes, made the alert go away, quadrupled the credit burn, and bought the problem another two months to grow before anyone looked at it again. The model would have "solved" the ticket. It would have made the underlying situation strictly worse and more expensive, and it would have done it while sounding completely reasonable.

The fix took an afternoon: change the incremental strategy from `MERGE` to a delete-and-insert scoped to the fourteen-day window, add a uniqueness test on the source key so we'd hear about it next time, and send an email to the upstream team that I tried to keep friendly. Runtime went to 26 minutes. Cost went down, not up.

## What My Daughter's Textbooks Taught Me About Models

My oldest is nineteen and started a nursing program last year, which means our kitchen table now has anatomy flashcards on it next to my three-year-old's dinosaurs. She's been explaining her curriculum to me and I have not been able to stop thinking about it since.

Medical school is four years. Most of the first two are recall: biochemistry, pharmacology, pathology, the sheer volume of facts a human being has to cram into their skull before they're allowed near a person. Then come the board exams, which test recall. And then, after all that, a newly minted MD is not turned loose on patients. They go into residency, which is three more years for internal medicine, five for general surgery, seven or more for neurosurgery. During those years they are supervised by an attending physician who signs the chart, which is to say who is legally and professionally accountable for what happens.

Here's the question that stopped me cold. If all the knowledge is written down, and the graduate has demonstrably memorized it, why does residency exist at all? Why not hand them a pager on graduation day?

Because knowing the twelve causes of chest pain is a different skill from standing in front of a specific fifty-four-year-old at 2am and figuring out which one he has. The textbook lists them. It cannot tell you that this particular patient minimizes his symptoms, that his blood pressure has been drifting for three visits, that the shortness of breath started before the pain and not after. The **differential diagnosis**, the discipline of holding several competing explanations open and then deliberately gathering the evidence that kills off the wrong ones, is not something you can read your way into. It's built out of reps, out of being wrong in front of someone more experienced than you, out of the specific and permanent memory of the time you anchored on the obvious answer and missed.

That's the gap. The model went to every medical school that ever published a textbook and it graduated top of the class at all of them simultaneously.

It has never once been paged at 3am.

## Recall Is a Real Skill and I Am Not Dismissing It

I want to be careful here, because the lazy version of this argument is "AI doesn't really understand anything" and that's both boring and not useful to you on a Tuesday when you have work to do.

Recall is enormously valuable. A huge percentage of what junior and even mid-level data engineering work consists of is recall, and pretending otherwise is snobbery. What's the correct syntax for a Snowflake dynamic table with a target lag? What are the actual semantics of `QUALIFY`? How do I express a lateral flatten over a nested array where some of the elements are null? Which dbt materialization strategies support a `unique_key` as a list? What does the Iceberg catalog integration require if the storage is in Azure? These are questions with answers, the answers are written down, and having something that returns them in four seconds instead of twenty minutes of tab-hopping is a real, compounding gain. I use it every day and I would not go back.

The trap is that recall questions and judgment questions look identical when you type them into the same box. "How do I speed up this query" and "what is the correct syntax for a clustering key" arrive at the model through the same interface, in the same tone, and come back in the same confident paragraph shape. One of them has an answer. The other one has a differential, and the model will hand you the most statistically common item on that differential dressed up as a diagnosis.

There are tells, and they're worth learning to spot. The first is that it answers before it asks. When I brought that slow load to a colleague, his first three sentences were all questions: what changed, when exactly did it change, and is it slow every night or only some nights. The model led with a recommendation. A model will almost never say "I don't have enough information to tell you which of these three things is happening, go run this and come back." It's built to produce an answer, and an answer is what you'll get.

The second tell is that it optimizes the thing you named. If you say "this query is slow," you will get query optimization, because you framed the case. Nobody in that conversation is going to say the query is fine and the problem is that an upstream team changed a payload two weeks ago. That reframing requires a model of the organization, not a model of the SQL.

The third tell, and the one that costs the most money on a data platform specifically, is that there's no cost model in the reasoning. Snowflake, BigQuery, and Databricks all share the property that almost every performance problem has a solution you can buy your way out of with about four keystrokes. Scale up. Add a cluster. Turn on the accelerator. Every one of those is a legitimate tool and every one of those is also the way a $40 a day problem becomes a $310 a day problem that nobody notices until the finance review in Q2. A model will suggest a warehouse resize with no more hesitation than it suggests a formatting change, because from where it sits, those are both just edits to a config file. The attending is the one who knows that a resize is a spending decision.

The fourth is that it has no idea what happens on Tuesday. Every real platform has a rhythm: the Monday morning surge, the month-end close that triples the concurrency for four days, the marketing team that runs a full-history rebuild whenever a campaign wraps, the vendor SFTP drop that lands at 4:15am and is late roughly one day in nine. Judgment on a data platform is largely the accumulated memory of that rhythm. It's why the engineer who's been on the team three years is worth more than her job description says, and it's precisely the thing that doesn't fit in a context window.

## The Part That Should Worry You

If the story ended with "senior engineers should supervise the model," this would be a comfortable article and you could go back to work. It doesn't end there, and this is the part I actually sat down to write.

Judgment is built out of reps. Specifically, it's built out of reps where you owned the outcome, made a call, and then found out whether you were right. The reason a third-year resident is better than a first-year isn't that she read more; it's that she has stood in the room three hundred more times and been corrected. Every one of those corrections is a small permanent modification to how she sees the next patient.

So consider what happens on a team where every rep goes to the intern.

I watched a smart engineer, two years into her career, ship model-generated incremental models for most of a quarter. They were good. Better formatted than mine, better commented, consistent naming, tests included. Then one of them started producing duplicate rows in production and she could not tell me why, not because she isn't sharp, but because she had never once sat with the question of what a `unique_key` actually guarantees and what it doesn't, and under what upstream conditions the guarantee stops holding. She had the artifact without the reasoning that produces the artifact. In residency terms, she'd been signing charts she hadn't written for someone else's patients.

That is not her failure. It's the failure of everyone above her, including me, who let the throughput look good enough that nobody asked what was being traded away. We were harvesting recall and quietly declining to invest in judgment, and the bill for that comes due in about eighteen months when your platform hits a problem that isn't in any textbook and the only people who can read a query profile are the two of you who learned before the shortcut existed.

## Running Rounds

What I've settled into is something close to teaching rounds, and it has changed how I use these tools more than any prompt-engineering trick I've picked up.

Before I ask for a solution, I ask for a differential. Give me the three most likely causes of this behavior, ranked, and for each one tell me what evidence would confirm it and what evidence would rule it out. That single reframing does more for the quality of the output than anything else I do, because it forces the model out of recommendation mode and into a shape where its enormous recall is actually the right tool. It is superb at enumerating causes. It is bad at picking among them without data, and asking it to enumerate rather than pick puts the work where it belongs.

Then I go get the evidence myself. Query profile, warehouse load history, `TABLE_STORAGE_METRICS`, the actual bytes written per run over the last thirty days. That's the physical exam, and it's not delegable, because the whole point is that I need to see it with my own eyes to know what I'm looking at next time.

Then, before anything ships, I make it write the rollback. Not the change, the rollback. If this clustering key turns out to be wrong, what does it cost me to remove it, and how long does the table take to settle afterward? If this warehouse resize is wrong, how will I know, and what's my alert? A model will happily describe the forward path forever and rarely volunteers the reverse one, and the reverse path is where all the risk lives.

And then I sign the chart. My name is on it. Not "the AI suggested it," which is the data engineering equivalent of a resident telling a family that the textbook said so. If it breaks at 3am, I'm the one awake.

The reason I called this series The Long Game is that all of this is a stewardship problem, not a productivity problem. Residency is long on purpose. Nobody designed it to be seven years because they enjoy the suffering; it's seven years because that's roughly how long it takes to convert a very large pile of facts into the ability to act correctly under uncertainty, with someone accountable standing behind you the whole time. We now have, sitting in every terminal, something that has completed the first four years perfectly and cannot ever complete the last three, because the last three are made of consequences and it doesn't have any.

Your juniors do. That's the whole asset. Protect the reps that build their judgment the way you'd protect any other scarce resource on the platform, because in three years the recall will be free and commoditized and the judgment will be the only thing your team actually sells.

The model graduated. You still have to teach the residents.
