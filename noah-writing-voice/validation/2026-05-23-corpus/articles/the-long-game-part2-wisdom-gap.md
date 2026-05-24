---
title: "The Long Game, Part 2: The Wisdom Gap"
url: https://medium.com/snowflake/the-long-game-part-2-the-wisdom-gap-eb640ad0321e
date: 2026-03-04
publication: snowflake-builders-blog
reading_time_min: 10
claps_response_count: 0
tags: [snowflake, data-superhero, artificial-intelligence, leadership, mentorship]
subtitle: "Why AI Has Perfect Memory and Zero Wisdom, and Why That Should Change How You Build"
---

# The Long Game, Part 2: The Wisdom Gap

## Why AI Has Perfect Memory and Zero Wisdom, and Why That Should Change How You Build

AI can read the blueprint. It can't teach you why it matters.

I was going to write a very different article.

[Part 1](https://medium.com/snowflake/the-long-game-74cb3d68e173) of this series was about stewardship. The quiet, unglamorous work of building systems and people that thrive long after you're gone. Part 2 was supposed to be a tidy follow-up about mentorship and the difference between knowledge and wisdom.

And then I read Matt Shumer's piece, *Something Big is Happening*.

Frankly, it hit me in the gut. Not because the technology predictions were new to me. I build on the Snowflake Data Platform every day, and I've been using AI tools aggressively for over a year. What hit me was the personal math. I grew up in the world of "go to college, get a good job, work hard until retirement." I've spent two decades building deep expertise in data architecture based on that promise. Now I have a nineteen-year-old daughter, a three-year-old son, and a six-month-old daughter, and someone credible is telling me that the professional world I've been preparing them for might not exist by the time they need it.

I know I'm not the only one feeling this. So instead of the article I planned, I want to share what I actually found when I spent a year pressure-testing AI against real work. It didn't confirm the hype. It didn't dismiss it either. It pointed at something more specific and more useful than the "AI replaces us all" vs. "AI is just a tool" debate.

## The Experiment

Over the past year, I started building an accelerator toolkit for my own Snowflake projects. As that work progressed, I realized there wasn't a great codified solution for enforcing Snowflake's Well-Architected Framework as part of the development process. So I started building one. AI coding assistants became a core part of my workflow, and for a while, it was genuinely impressive. Scaffolding code, writing functions, generating test suites. I was moving fast.

Then the project got complex.

Slowly, the AI started making architectural decisions that contradicted ones we'd agreed on three sessions earlier. It would write tests that technically passed but tested nothing meaningful. Vanity coverage that made the numbers look good while leaving the actual risk areas untouched. It would solve a structural problem on Monday and reintroduce the exact same problem on Thursday.

So I built guardrails. Deterministic rules. A linting framework that could catch violations and feed them back to the AI in a loop. Clear success criteria: fix the violations, make the tests pass, reduce the error count each iteration. If you fail to improve three times in a row, stop.

It didn't work. Not catastrophically. Incrementally. One violation would get fixed and two new ones would appear in a different layer. A module would get refactored for testability, quietly breaking an interface contract that six other modules depended on. Like watching someone solve a Rubik's cube by unsolving a different face with every turn.

Here's what got me. The AI had perfect knowledge of clean architecture patterns. It could recite them, apply them, explain them back to me. What it completely lacked was the understanding of *why those patterns exist*. It didn't carry the memory of the production outage that taught me why dependency boundaries matter. It didn't feel the weight of the $50,000 Snowflake bill I once saw hit a team that hadn't set `STATEMENT_TIMEOUT_IN_SECONDS` at the account level, leaving the default at two full days. It had never inherited a Snowflake environment from a predecessor and had to untangle a web of overprivileged service accounts that nobody documented and nobody remembered creating.

It had knowledge. It didn't have wisdom.

## How Wisdom Actually Forms

A few weeks before my AI experiment fell apart, my three-year-old taught me something about this distinction that no research paper could have.

We'd been going through a phase. I'd put him down for a nap, close the door, and come back to find his room destroyed. Clothes yanked from the dresser, books and toys scattered wall to wall, sheets off the bed, lamp on the floor. A full tornado. First few times, I did what most tired parents do: told him it wasn't acceptable, then cleaned it up myself after he fell asleep. Faster. Easier. And it made zero difference.

The last time it happened, I sat down on the floor with him and we picked up every piece together. Every book back on the shelf. Every toy in the bin. We made his bed. It wasn't the painful ordeal I expected. It was a teaching moment and a relationship-building moment rolled together. He learned that making messes is okay AND that he's responsible for cleaning them up. That dad is a safe person when messes happen. What it required from me was patience, and a reframe from "I need this room clean" to "I need him to learn."

The tornadoes stopped. Not because he was punished. Because he felt the weight of the consequence in his own hands.

That's how wisdom forms. Not through being told. Through feeling the weight.

His baby sister was born six weeks premature, barely four pounds. She spent her first month in the NICU. One day we were out running errands and drove past the intersection where we'd normally turn to go to the hospital. From his car seat, he started shouting "Sister! Sister!" and crying since we'd kept driving. His nineteen-year-old sister has a hard time remembering the route to the grocery store when she visits from Maryland. But this little boy had cemented the way to his baby sister because the emotional weight of that connection demanded it. His brain literally reorganized itself around something that mattered to him.

You can't prompt your way to that. Wisdom forms when something matters enough to change how you're wired. And that process requires two ingredients that AI fundamentally lacks: felt consequences and accumulated context.

Felt consequences are the tornado. The cleanup. The sleepless night after you drop a table in production. The memory of being burned is what rewires the brain, not the knowledge that the stove is hot.

Accumulated context is what turns those individual scars into judgment. Juniors ask me clean, binary questions all the time. "Should I index this column?" "Subquery or join?" And the answer almost always starts with "it depends." Not because I'm being evasive, but I once watched a correlated subquery outperform a join by orders of magnitude on a specific workload, even though conventional wisdom says otherwise. That surprise broke an assumption I'd been carrying, and the break made me a better architect. AI gives confident, clean answers. No lifetime of broken assumptions tempering its certainty. It doesn't have the pause. The squint. The "well, I saw something weird once…"

(My son's version of accumulated context is still in the early stages. Thanks to a Moana phase from months ago, when I prompt him to say "thank you" his default response is still a very enthusiastic "Welcome!" We're working on it.)

## The Stakes

Here's where this stops being philosophical and starts being urgent.

The Snowflake Well-Architected Framework exists because thousands of practitioners made expensive mistakes. Every principle is encoded experience. Someone learned that a warehouse without auto-suspend bleeds credits silently for months. Someone discovered that a permissive network policy on a single admin account can bypass an entire security perimeter. Someone watched query spillage turn a $1 operation into a $100 one.

When I tried to get AI to enforce the WAF holistically across an entire project, it fell short. Specific violations? Fine: "this warehouse is missing auto-suspend, here's the ALTER statement." But ask it to look at an environment as a whole and identify structural problems? Out comes the textbook. Boxes get checked. And the things that only show up when you've seen enough environments to know where the bodies are usually buried? Those get missed.

And here's the trap: the industry is now making a calculation. AI can produce senior-level output at junior-level cost. So why hire juniors? Why invest in the slow, inefficient process of teaching when the AI can just do the thing?

We tell our children that failure is how you learn, and we mean it. We swap war stories about the kid who painted the dog and flooded the bathroom. But in the business world, where quarterly earnings and board expectations demand efficiency above all else, failure is a liability. "Fail fast" is a slogan that works great right up until you fail to fail fast enough. And now AI is promising to skip the failure step entirely, which is the most seductive pitch imaginable to a CFO staring at a budget.

I was once mentoring a new engineer who hit the dreaded white screen of death in our PHP codebase. I knew immediately what the problem was. Instead of handing him the answer, I walked him through debugging with print statements. Tracing the output. Finding where it stopped. He was frustrated. He kept asking "Why won't you just tell me what to fix?!" Because telling him the fix solves one bug. Walking him through the process gives him a skill he'll use for the rest of his career. That twenty minutes of frustration was the foundation of something permanent.

If we stop creating those moments, if we let the bottom rungs of the ladder disappear, we won't just lose a generation of junior engineers. We'll lose the future seniors. The future architects. The people who carry the wisdom forward after we're gone. In Part 1, I wrote about Captain Marquet's miracle on the USS Santa Fe: the culture he built kept producing exceptional leaders for years after he left. The framework survived the man. If we replace the learning process with AI output, the framework dies with the people who built it.

## The Opportunity

AI doesn't have to kill the learning process. It can supercharge it.

Imagine a junior data engineer starting at a company running on Snowflake. In the old world, they'd get a wiki page, maybe a mentor if they were lucky, and spend six months absorbing institutional judgment through osmosis and pain. Now imagine that same junior with access to an AI assistant loaded with the architectural decision records for their specific environment. Not just the WAF best practices, but the *reasons behind the local choices*. Why this organization uses a specific RBAC model. Why the warehouse strategy looks the way it does. What happened the last time someone shortcut the cost controls.

In this scenario, the AI doesn't replace the mentor. When the junior is about to configure a warehouse without auto-suspend, the AI doesn't just fix it silently. It explains why auto-suspend matters, tells the story of the time it wasn't set, and lets the junior make the correction themselves. The learning still happens. The "ouch" still registers. But the feedback loop is tighter, the context is richer, and the senior's time is freed up for the judgment calls that actually require human experience.

That's using AI to make the senior a better teacher and the junior a faster learner. The human pipeline stays intact.

But it only works if the seniors do their part. The AI can't teach wisdom it was never given. Someone has to encode the *why* into the system. Not just "use RBAC" but "here's the story of what happened when we didn't, and here's the judgment call I made when the standard model didn't fit."

**So here's your move.** Pick one architectural decision you've made in your Snowflake environment. Not a textbook best practice. One where you chose a specific approach because you'd been burned by the alternative. Write down the why. Not the documentation-friendly version. The real one. "We set `STATEMENT_TIMEOUT_IN_SECONDS` to 3600 at the account level because a query once ran for two days on the default timeout and the bill nearly sank our quarterly budget. Here's what I learned about how our team actually uses compute resources, and why the default two-day timeout is dangerous for any environment where developers have direct warehouse access."

Now share it. With your team, with a junior engineer, in your project docs, on LinkedIn. Anywhere that someone who comes after you might find it when they need it.

You just turned a scar into a map. That's something AI cannot do. And if enough of us do it, if we treat the encoding of *why* as a core part of our professional responsibility, then the Wisdom Gap doesn't have to grow. It can shrink. Not because the AI gets wiser, but because we build the systems that let human wisdom scale beyond the humans who earned it.

That's the long game. That's stewardship in the AI era.

My three-year-old isn't going to grow up in the same professional world I did. That used to terrify me. I'm starting to think it might be okay, as long as the people building that world remember that the point was never to replace the humans. The point was to build a better world *for* them.

At least, that's what I tell myself when I'm up at 2 AM with the baby and the fear creeps back in. Some nights it's more convincing than others. But I'd rather build toward something worth believing in than sit with the alternative.

*Next in The Long Game: Part 3, The Architect's Anchor: Building Systems That Remember Why.*

*Noah Goodrich is a Snowflake Data Superhero and architect. Connect with him on LinkedIn.*

## A Note on Process

*All of the ideas, opinions, and stories in this article are mine, written in my own words first. I then worked with Claude to shape that raw material into something structured and readable. It was a great collaborator on flow and pacing. It could not have written the story about my son and the tornado, because it never sat on that floor. The wisdom is mine. The craft is a partnership.*

*Here's the thing, though. Even in that partnership, the article's own thesis kept proving itself. When early drafts came back bloated and circular, repeating the same arguments three different ways, I had to be the one to point that out. Once I did, the AI built a solid strategy to consolidate them into a clean flow. But it didn't notice the problem on its own. Same story with the AI detection scoring. All the knowledge about how to evaluate writing for AI tells was right there in the model. But it wasn't until I specifically asked for a score that it built a system and walked me through remediation. The capability was there. The initiative wasn't. That's the Wisdom Gap in miniature. Not a gap in what AI knows, but in knowing when and why to apply it.*
