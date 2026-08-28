---
class: voiced
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 853
source_article: snowflake-aws-iac-part1.md
prompt: |
  Write a technical blog post titled "Snowflake & AWS Infrastructure as Code (Part 1)" about Setting up a local development environment with LocalStack and VS Code devcontainers to emulate AWS and Snowflake services for infrastructure-as-code work.. Aim for about 853 words. The audience is working data engineers.

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

# Snowflake & AWS Infrastructure as Code (Part 1)

A few years back I watched a new data engineer spend the first four days of her job getting a laptop ready. Homebrew, Python version conflicts, an AWS CLI that was v1 on her machine and v2 on everyone else's, a Terraform binary that didn't match the version in our state file, and a `.env` file that somebody had shared over Slack six months earlier and was now missing half its variables. On day five, she finally got a plan to run. On day six she ran an apply against our shared sandbox account and blew away a storage integration that three production pipelines quietly depended on.

That was not her fault. That was ours. We had handed a brand new pilot the controls of a real aircraft with passengers already strapped in the back, and then acted surprised when the landing was rough.

Commercial aviation solved this problem decades ago. No airline lets a first officer learn crosswind landings on a full 737. They build a **simulator**, a box that lies convincingly enough about the world outside the windows that you can stall the plane, catch fire, lose an engine over the Atlantic, and walk out for lunch. The hours you log in there count. The crashes don't. That's the environment I want every data engineer to have before they touch infrastructure code, and this two-part series is about building one for a Snowflake and AWS stack.

## The cockpit has to be identical for everybody

The first half of a simulator isn't the scenery. It's the cockpit. The switches sit in the same place, the throttle has the same travel, and the checklist is bolted to the same spot on the yoke. That's what a **devcontainer** buys you: a Docker image, checked into the repo, that defines exactly which Terraform, which Python, which `snow` CLI, and which AWS CLI everyone on the team is flying with.

A minimal `.devcontainer/devcontainer.json` for this stack looks something like this:

```json
{
  "name": "snowflake-aws-iac",
  "dockerComposeFile": "docker-compose.yml",
  "service": "workspace",
  "workspaceFolder": "/workspaces/iac",
  "features": {
    "ghcr.io/devcontainers/features/terraform:1": { "version": "1.9.8" },
    "ghcr.io/devcontainers/features/aws-cli:1": {},
    "ghcr.io/devcontainers/features/python:1": { "version": "3.11" }
  },
  "postCreateCommand": "pip install snowflake-cli-labs localstack awscli-local"
}
```

Pinning `1.9.8` instead of `latest` is the entire point. Terraform state files are version-aware, and the fastest way to ruin a Wednesday is to have one teammate on 1.5 and another on 1.10 taking turns upgrading and refusing to downgrade the state. The version pin is a checklist item. It lives in the repo, not in somebody's memory.

## The world outside the windows

The second half of the simulator is the scenery, and that's **LocalStack**, a set of AWS service emulators that answer on `localhost:4566` and speak the same API dialect as the real thing. S3, IAM, Lambda, Secrets Manager, SQS, EventBridge, and Step Functions all respond well enough that Terraform can't tell the difference, provided you point it at the right runway:

```yaml
services:
  localstack:
    image: localstack/localstack:3.8
    environment:
      SERVICES: s3,iam,lambda,secretsmanager,sqs,events
      DEBUG: 1
    ports: ["4566:4566"]
    volumes:
      - ./.localstack:/var/lib/localstack
```

For Terraform, you either set `AWS_ENDPOINT_URL=http://localstack:4566` and let the AWS provider's endpoint resolution do the work, or you use the `tflocal` wrapper, which injects the endpoint overrides for you. Credentials can be the literal strings `test` and `test`, which is its own small joy: nothing in your local environment can reach a real account, so the worst outcome of a bad apply is that you `docker compose down -v` and start over. That's the simulator crashing. Nobody files an incident report.

## Snowflake doesn't have a simulator, so build the next best thing

Here's where the metaphor gets uncomfortable, and I'd rather tell you now than let you find out at 400 feet. There is no LocalStack for Snowflake. You cannot spin up a container that pretends to be an account, hand it a `CREATE WAREHOUSE` statement, and get a real answer back. The Snowflake Local Testing Framework covers Snowpark DataFrame logic and the `snow` CLI can validate project definitions offline, but account-level objects like roles, grants, warehouses, and storage integrations need an actual Snowflake account on the other end of the wire.

So we do what flight schools do when they can't afford full-motion: fly a small, cheap aircraft with an instructor. A dedicated **dev account** on the smallest edition you can justify, with an object naming convention that prefixes every resource with the developer's initials, gives you real Snowflake semantics without real Snowflake consequences. Terraform workspaces plus a `dev_prefix` variable means my `terraform apply` creates `NG_ANALYTICS_DB` and yours creates `SR_ANALYTICS_DB`, and the two of us can iterate on the same module at the same time on a Tuesday afternoon without stepping on each other. Auto-suspend at 60 seconds on an XS warehouse keeps the monthly bill in the range of a team lunch.

The devcontainer holds this together by making the split invisible. AWS calls resolve to LocalStack, Snowflake calls resolve to the dev account through a key-pair credential mounted from your host, and the code you're writing has no idea it's in a simulator.

In Part 2, we'll take this environment and actually fly it: a Terraform module that provisions an S3 bucket, an IAM role, and the Snowflake storage integration that binds them, tested end to end before it ever sees production.
