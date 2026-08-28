---
class: voiced
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 1275
source_article: ai-coding-agent-architect.md
prompt: |
  Write a technical blog post titled "Why Your AI Coding Agent Needs a Professional Architect" about Using Clean Architecture layers and a pylint plugin to constrain the code structure that AI coding assistants produce in Python projects.. Aim for about 1275 words. The audience is working data engineers.

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

# Why Your AI Coding Agent Needs a Professional Architect

Back in October I handed Claude Code a ticket and a Snowflake account and asked it to build an ingestion pipeline for a vendor API that paginated badly and rate-limited worse. Ninety minutes later I had a working pipeline. It pulled the data, handled the 429s with exponential backoff, wrote to a raw landing table, and even generated a passable set of tests. I closed the laptop feeling like I'd gotten away with something.

Three weeks later, when we needed to add a second vendor with a nearly identical API, I opened that codebase and found 3,100 lines spread across fourteen files. Nine of those files imported `snowflake.connector` directly. The retry decorator existed in four places with three different backoff strategies. The business rule that decided whether a record was a duplicate lived inside the same function that opened the database cursor, which meant the only way to test it was to spin up a warehouse. Adding vendor number two wasn't a two-hour job. It was a rewrite, and I did most of it on a Sunday while my three-year-old watched Bluey at a volume I'm not proud of.

The agent didn't do anything wrong, exactly. It did what an extremely fast, tireless, deeply competent **framing crew** does when you hand them lumber and no blueprint. It built walls. The walls were plumb, the nails were spaced correctly, and every single one of them was load-bearing because nobody told the crew which ones weren't supposed to be.

## The Crew Is Not the Problem

I want to be careful here, because there's a genre of blog post that amounts to "AI writes bad code" and that's not what I'm arguing. The code the agent wrote was better than a lot of what I've seen from humans on a deadline. Variable names were clear. Error handling existed. It wrote docstrings, which is more than I can say for my 2019 self.

The problem is that a framing crew optimizes for the wall in front of them. An agent working inside a context window is doing exactly the same thing: it sees the file it's editing, maybe a handful of neighbors, and it produces the most plausible code for that local view. Plausible code that runs is the target. Nobody on that crew is standing in the driveway with rolled-up drawings asking whether the second floor is going to sit on top of a load-bearing wall or on top of a coat closet.

That person is the **architect**, and the architect's job was never to swing a hammer. The architect's job is to decide what depends on what, and then to make those decisions legible to everyone who shows up with a nail gun afterward. When you're the only human on a project with three agents running in parallel terminal windows, you are the architect whether you signed up for it or not.

## Blueprints for Data Work

Clean Architecture gets a bad reputation in data circles, mostly because it arrives wrapped in Java-shaped vocabulary and diagrams with too many concentric circles. Strip that away and the idea is embarrassingly simple: your code has layers, and **dependencies only point inward**, toward the stuff that doesn't change, never outward toward the stuff that does.

For a data engineering codebase I've settled on three layers and I'd fight to keep it at three. The innermost is the **domain**, which holds your entities and your business rules: what a valid order looks like, how you decide two customer records are the same person, what the currency conversion rules are for a refund issued in a different fiscal year. This layer imports nothing but the standard library and maybe Pydantic. It is the foundation, and foundations don't get to know what color the siding is.

Above that sits the **application** layer, the use cases, where you describe what the pipeline actually does in the order it does it: fetch pages until exhausted, normalize each record, deduplicate against the existing keys, write the survivors. This layer knows about interfaces, a `SourceReader` with a `read()` method, a `RecordWriter` with a `write()` method. It does not know that the source is a REST API or that the writer talks to Snowflake. Those are fixtures, and fixtures get swapped.

The outermost layer is **infrastructure**, and this is where all the ugly, changeable, vendor-specific reality lives. The Snowflake connector. The `requests` session with the retry adapter. The S3 client, the Airflow operator, the secrets manager call. This is plumbing and wiring and HVAC, and I fully expect to rip it out and replace it when we move a workload or a vendor deprecates an endpoint. When that happens, I want to open four files, not fourteen.

The payoff shows up the first time you write a test. Business logic in the domain layer tests in milliseconds with a list of dictionaries. That's not a style preference, that's the difference between a test suite you run on every save and one you run when you remember.

## The Building Inspector

Here's where most architecture initiatives die. You write the blueprint into a `CONTRIBUTING.md`, everyone nods, and then it's 4:45 on a Thursday and someone imports the Snowflake connector into a domain module because it's right there and it works. Agents do this constantly, and they do it faster than any human ever could. A convention that lives only in prose is a suggestion, and agents are not especially moved by suggestions buried in a file they may or may not have read.

So you hire an inspector. In our case the inspector is a **pylint plugin**, about eighty lines of Python, that refuses to sign off when a dependency points the wrong direction. The mechanics are less complicated than they sound. Pylint hands you an AST, you register a checker, and you implement `visit_import` and `visit_importfrom`. For each import you map the current module's path to a layer number and the imported module's path to a layer number, and if the imported number is higher than the current one, you emit a message.

```python
LAYERS = {"domain": 0, "application": 1, "infrastructure": 2}

class LayerBoundaryChecker(BaseChecker):
    name = "layer-boundary"
    msgs = {
        "E9001": (
            "Layer violation: %s (layer %d) imports %s (layer %d)",
            "layer-violation",
            "Dependencies must point inward toward the domain.",
        )
    }

    def visit_importfrom(self, node):
        here = layer_of(node.root().file)
        there = layer_of(node.modname)
        if there is not None and here is not None and there > here:
            self.add_message("layer-violation", node=node, args=(...))
```

Wire it into `pyproject.toml`, put pylint in your pre-commit hooks and your CI, and the inspection becomes a wall the crew cannot frame through. And this is the part I did not expect: agents are exceptionally good at responding to a failing check with a clear message. Tell an agent "keep the domain pure" in a prompt and you'll get compliance for maybe six files. Give it `E9001: Layer violation: domain.dedupe (layer 0) imports infrastructure.snowflake (layer 2)` and it will move the dependency behind an interface without being asked twice, because it now has a feedback loop instead of a vibe.

## Permits, Not Red Tape

The failure mode on the other side is real and I've caused it. Seven layers, an abstract factory for the abstract factory, a `Protocol` for a function that will only ever have one implementation. That's not architecture, that's a permitting office designed to make sure nothing ever gets built. My rule of thumb is that a layer earns its existence when something inside it changes at a different rate than the thing next to it, and vendors change faster than business rules roughly a hundred percent of the time.

Three layers, one rule about which direction the arrows point, and an inspector who fails the build. That's the entire blueprint, and it took me an afternoon to set up on the rewrite of that vendor pipeline. Adding vendor number three took forty minutes and touched two files in the infrastructure layer, and I wrote it while my six-month-old slept on my chest.

The agent is a phenomenal crew. Give it drawings.

**If you want to try this on your next project:**

- Start with three directories: `domain/`, `application/`, `infrastructure/`. Nothing else.
- Write the layer checker before you write the second module, not after the fourteenth.
- Put pylint in pre-commit AND CI, because agents will happily skip a hook you let them skip.
- Add the layer rule to your `CLAUDE.md` or `.cursorrules` too, but treat that as documentation, not enforcement.
