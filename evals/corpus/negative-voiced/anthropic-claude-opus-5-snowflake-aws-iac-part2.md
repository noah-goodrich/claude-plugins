---
class: voiced
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 1163
source_article: snowflake-aws-iac-part2.md
prompt: |
  Write a technical blog post titled "Snowflake & AWS Infrastructure as Code (Part 2)" about Moving off AWS CDK to a configuration-driven approach for provisioning Snowflake databases, roles, pipelines, and S3 storage integrations alongside AWS resources.. Aim for about 1163 words. The audience is working data engineers.

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

# Snowflake & AWS Infrastructure as Code (Part 2)

In the first part of this series, I walked through building a Snowflake and AWS deployment pipeline with the AWS CDK. TypeScript constructs, synthesized CloudFormation, the whole apparatus. It worked. We shipped it. And then, about four months in, I started to notice that every time we onboarded a new data source, someone on the team had to open a TypeScript file, understand a class hierarchy three levels deep, and write code just to say "this new source needs a database, two roles, a stage, and a Snowpipe."

That's when I realized we had built a very expensive light switch.

Let me explain what I mean by that, because the metaphor is going to carry the rest of this piece. Every house has electrical wiring. Somebody had to run the conduit, pull the romex, wire the panel, and get it inspected. That work is real, it's skilled, and you do not want an amateur doing it. But once the wiring is in the wall, the person who lives in the house doesn't think about romex. They flip a switch. The whole point of the electrician's work is that the daily interface becomes trivial.

What we had built with the CDK was a house where you had to open the wall every time you wanted to turn on a lamp. Our constructs were good. Our abstractions were reasonable. But we had made the wiring and the switch the same object, and that meant every routine act of provisioning required someone who understood the wiring.

## The moment it broke

The specific incident that pushed us over: we were onboarding a vendor feed that dropped Parquet files into an S3 bucket we didn't own. Standard stuff. New database, new schema, a storage integration pointed at the vendor bucket, an external stage, a Snowpipe with auto-ingest, an SNS topic, an IAM role with a trust policy that Snowflake's `DESC INTEGRATION` output would populate, and three RBAC roles following our access model.

One of our engineers, sharp guy, four years of data engineering experience, spent a day and a half on it. Not because the Snowflake or AWS concepts were hard. He knew those cold. He spent a day and a half because he was fighting our TypeScript. He had to figure out which construct took which props, why the `SnowflakeDatabaseStack` expected a role array but the `SnowpipeConstruct` expected a role map, and what order the CDK would deploy things in when a Snowflake resource depended on an AWS resource that depended on a Snowflake resource. The circular dependency between the IAM role ARN and the storage integration is a genuine chicken-and-egg problem, and we had solved it once, cleverly, in a way nobody else could read.

When I reviewed his PR, roughly 180 lines of TypeScript, I asked myself what information was actually in there. The answer was: a bucket name, a prefix, a database name, three role names, a file format, and a warehouse. Seven facts, buried in 180 lines of ceremony. Everything else was wiring we had already written and were writing again.

## Moving the switch to the wall

The rewrite took about three weeks. The shape of it: keep the CDK, but demote it. The CDK is now the electrician. It runs conduit and it does not get consulted about lamps.

Every environment gets a directory of YAML. A single source definition looks roughly like this, and I'm showing you real structure because vague descriptions of config schemas help nobody:

```yaml
name: vendor_claims
database: RAW_VENDOR_CLAIMS
owner_role: SYSADMIN_VENDOR
storage:
  bucket: acme-claims-dropzone
  prefix: prod/claims/
  account: "104xxxxxxxx"
  external_id_suffix: claims
pipes:
  - name: claims_daily
    stage: CLAIMS_STAGE
    target_table: CLAIMS_RAW
    file_format: PARQUET_STANDARD
    auto_ingest: true
access:
  readers: [ANALYST, DATA_SCIENCE]
  writers: [LOADER_VENDOR]
```

Twenty-two lines. Seven facts plus the structure to hold them. A data engineer who has never opened our repository can read that file and know exactly what is going to exist in Snowflake and AWS when it deploys, which was never true of the TypeScript.

The CDK app now reads the directory, validates every file against a JSON Schema, and generates constructs in a loop. The **synthesis step** became a pure function from configuration to infrastructure, which means the interesting property emerged almost by accident: we could diff configurations. Two YAML files, one before and one after, tell you exactly what changed about a source in terms a human cares about, instead of a CloudFormation changeset telling you that `SnowflakeStorageIntegrationE7A2C1` will be replaced.

For the Snowflake side we went with the Terraform provider driven from the same YAML, generating `.tf.json` files rather than trying to make the CDK speak Snowflake through custom resources and Lambda-backed providers. That was the other lesson from part one that I want to be direct about: custom resources are a tax you pay forever. Every Lambda-backed provider is a piece of code you own, in a runtime that will deprecate, with error handling you wrote at 11pm and never revisited. We had four of them. We deleted three.

## The chicken and the egg, solved boringly

The storage integration dance is worth spelling out, because it's the thing everybody hits and the config-driven approach makes it genuinely nicer. Snowflake needs an IAM role ARN to create a storage integration. The IAM role's trust policy needs the Snowflake IAM user ARN and external ID, which only exist after the integration is created. Circular.

In the CDK version we solved this with a custom resource that created the integration, described it, and updated the role in a single Lambda invocation. Clever, fragile, and impossible to debug when the Lambda timed out mid-update.

Now it's two passes with a naming convention. The CDK creates the IAM role with a deterministic name derived from the source name, `snowflake-integration-vendor_claims`, and a placeholder trust policy that trusts nothing. Terraform creates the storage integration pointed at that predictable ARN. A small deploy step reads `DESC INTEGRATION` output and writes the real trust policy back. Three steps, each independently re-runnable, each one leaving a legible artifact behind. Nobody is clever anymore, and that has been an unambiguous improvement.

## What actually changed

That same vendor feed onboarding is now a pull request that touches one file and takes about twenty minutes, most of which is waiting for the pipeline. We've added eleven sources since the migration and the median PR is 26 lines of YAML. Two of those eleven were built by analytics engineers who have never written TypeScript and don't need to.

The part I didn't expect: the configuration files became documentation. When someone asks "what does the claims pipeline actually load and who can read it," the answer is a file, in git, with a blame history showing exactly when access changed and who approved it. Our old answer involved reading TypeScript and inferring behavior from constructor arguments.

The wiring is still complicated. It should be. Storage integrations, IAM trust relationships, RBAC hierarchies, and auto-ingest notification plumbing are legitimately intricate, and I don't want to pretend a YAML file makes that complexity disappear. It moves it. The complexity now lives in one place, maintained by the two of us who care about it, tested once, and exposed to everyone else as a switch on the wall.

In Part 3 I'll get into how we handle drift detection and what happens when someone inevitably clicks around in the Snowflake UI at 2am during an incident, because they will, and pretending otherwise is how IaC projects die.
