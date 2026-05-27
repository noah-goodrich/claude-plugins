---
title: "The Long Game, Part 3: The Architect's Anchor"
url: https://medium.com/snowflake/the-long-game-part-3-the-architects-anchor-4a02f5788f11
date: 2026-03-09
publication: snowflake-builders-blog
reading_time_min: 8
claps_response_count: 1
tags: [data-superhero, snowflake, data-engineering, software-development]
subtitle: "Building Systems That Remember Why"
---

# The Long Game, Part 3: The Architect's Anchor

## Building Systems That Remember Why

The best architects don't just hand you the blueprint. They pull up a chair and show you how to read it.

My son was born six weeks early. Three pounds, fourteen ounces. He spent his first three weeks in the NICU, and I spent those three weeks learning how to take care of an infant inside a framework I didn't know I needed.

The nurses taught me everything. Bottle feeding, diaper changes, reading the monitors. Every task had a procedure. Every mistake had a safety net. A nurse was always within arm's reach, not to do the work for me, but to catch me before a mistake became a catastrophe. By the time we brought him home, I could handle him on my own.

The thing is, it wasn't my first rodeo. Sixteen years earlier our first daughter was born. I didn't realize then how hopelessly in over my head I was. Having never babysat, and with only one younger sibling two years my junior, I didn't know the first thing about babies or their care. My wife, on the other hand, had been providing care for infants, toddlers, and small children for most of her life. And she tried to teach me. But I couldn't absorb it because there was no shared context, no common framework or language for us to build from. When she was clearly better at something, my default became to step back entirely. The burden fell on one person.

So what changed with our son? The NICU nurses didn't have better knowledge than my wife. They had a different delivery system. A structured, rigid environment where I could practice with real stakes and fail safely. Fixed schedules, standard procedures, common language. The nurses created a shared context between us. That's why I could go home and operate on my own. The context transferred with me.

If you've ever been part of an organization where the same one or two engineers had to be on every outage call, where nothing got resolved unless a specific person was in the room, you've seen this same pattern. The knowledge exists. It's just trapped in someone instead of encoded in something.

## Calm, Connect, Coach

Our son is what researchers call a "spirited" child. The term comes from Dr. Mary Sheedy Kurcinka, whose work on temperament has helped millions of families. A spirited kid isn't broken. They're just running at higher settings: more intense, more sensitive, more persistent, more perceptive, more uncomfortable with change. These are traits we value in adults. They're exhausting in a three-year-old.

Last Sunday at a birthday party, he hit the wall. Too many people, too much noise. He started screaming, then started tearing apart the balloon photo booth. We took him to a quiet room downstairs. He was still running hot, but gradually he came down. Found his equilibrium.

Kurcinka's framework for moments like these is three words: Calm, Connect, Coach. Calm means you regulate yourself first, then help the child. Structure and routine are your primary preventive tools. Connect means you meet them where they are emotionally before you redirect. Coach means that once they're calm and feel understood, then you teach.

The power isn't in the complexity. It's in the simplicity. I can remember three words at 2 AM on four hours of sleep. I don't need a hundred tools for each step. Just one or two reliable ones. His favorite lullaby. Making sure he's fed (we call him our little hobbit). And when nothing else works, just holding him and letting our calm heartbeat do what words can't.

The framework didn't make our son less spirited. But it gave my wife and me, two people with different temperaments and instincts, a shared context to operate from. The techniques vary. The sequence is the same. Inside those ground rules, there's room for each of us to bring our own judgment.

## Shared Context in the Wild

If you were building web applications in the mid-2000s, you probably remember what it felt like before opinionated frameworks existed. Martin Fowler's *Patterns of Enterprise Application Architecture* had given us the vocabulary. We knew about Data Mappers and Active Record and Table Data Gateways. But knowing the patterns and consistently applying them in a codebase were two completely different problems. Every team reinvented the wheel. Every project had its own conventions, or worse, no conventions at all.

Ruby on Rails changed that. DHH took Fowler's patterns, picked specific ones (Active Record, convention over configuration), and enforced them across every implementation of the framework. You could walk into any Rails project on earth and know where things lived on day one. The framework did the remembering so the developer could focus on the problem. That's what shared context looks like at scale.

The same arc played out in cloud infrastructure. AWS released their Well-Architected Framework years ago. Azure followed. Every mature platform eventually recognizes that principles without opinionated implementation leave a gap. And that gap gets filled by whoever happens to be the most experienced person on the team, which means it's fragile, inconsistent, and walks out the door when they do.

Snowflake is on the same trajectory. The company published their Well-Architected Framework in November 2025. But the community had been reaching for it long before that.

Data Superhero Keith Belanger talks about what he refers to as "[popcorn architecture](https://www.cloverdx.com/behind-the-data/data-superheroes)," teams without a real data strategy that just build technical debt on top of technical debt, each decision made in isolation, each fire fought without learning from the last one. His argument is that you need a business strategy backed by a data strategy, and then everybody operates under that shared understanding. Without it, every project is a new adventure in reinventing wheels that already exist.

Another Data Superhero, Sudhendu Pandey, in [*Snowflake Well-Architected Framework — Unofficial Guide*](https://medium.com/snowflake/snowflake-well-architected-framework-unofficial-guide-1663f43619c6) covers design principles and checklists for each pillar because the author was "searching for go-to resources to validate what we have done." He was an experienced practitioner, looking for a shared reference point. Because he wanted the context codified so his team could operate from it together.

In early 2023, our Snowflake Solutions Engineer reached out with something I hadn't asked for: a health assessment of our account. She'd gone through our environment and built a diagnostic picture of where we were versus where we should have been, organized around Snowflake's own best practices.

That report taught me things I didn't know. This was still early in my own Snowflake journey, and while I understood the basics of watching warehouse sizes and query runtimes, I didn't have the context to evaluate things like disk spillage patterns or workload-to-warehouse mapping. She wasn't just confirming what I already knew. She was creating shared context between Snowflake's institutional knowledge and our specific environment. Manually. For one account. The same thing the NICU nurses did for me: taking expertise that existed somewhere and delivering it in a form that actually transferred.

The Snowflake community is in the same place web development was before Rails. We have the patterns (the Well-Architected Framework). What's still missing is the opinionated implementation: a layer that picks specific checks, enforces specific conventions, and creates shared context that doesn't depend on one person's memory. Fowler gave us the vocabulary. Rails gave us the framework. Snowflake's Well-Architected Framework gives us the principles. What comes next is the convention layer that makes those principles runnable, repeatable, and accessible to every team, not just the ones lucky enough to have a Solutions Engineer or a veteran architect in the room.

## The Beginning of a Framework

So what does that convention layer actually look like for Snowflake?

Start with what the Solutions Engineer showed me. She wasn't running anything exotic. She was checking fundamentals. Are your warehouses sized appropriately for the workloads they're running? Do you have spillage that suggests your compute is undersized, or idle time that suggests it's oversized? How many users have ACCOUNTADMIN, and do they actually need it? What are your worst-performing queries doing, and why?

These aren't advanced questions. They're the Snowflake equivalent of checking blood pressure and cholesterol. The problem isn't that nobody knows they matter. Teams know. The problem is that teams are being asked to do more with fewer people and smaller budgets every quarter. The first things to hit the cutting room floor aren't the shiny features that sales and marketing are convinced will land the next big client. They're the unsexy work: tightening up security vulnerabilities, refactoring a query that shows linear growth in execution time as data volume increases, reviewing warehouse utilization before it becomes a cost problem. The fundamentals get deferred until they become fires.

Here's the thing that anyone who has ever tried to scale a product already knows: you have to have a tight security profile and right-side-up unit economics before you scale.

If you want to start thinking about this for your own environment, try two things this week. First, run `SHOW WAREHOUSES` and look at the `auto_suspend` values. How many of your warehouses are set to auto-suspend after 600 seconds (the default)? For warehouses that serve ad-hoc queries, that's probably fine. For warehouses that run scheduled jobs every hour, that means they're sitting idle burning credits for nine minutes out of every ten. Second, run `SHOW GRANTS OF ROLE ACCOUNTADMIN` and count the users. If you have more than two or three, ask yourself whether each of those people genuinely needs the keys to the kingdom, or whether they got ACCOUNTADMIN because it was faster than figuring out the right role.

Those two checks take five minutes. They won't give you a full picture, but they'll give you a feel for whether your environment's fundamentals are solid or drifting. And that instinct, the habit of checking, is the first step toward building the shared context your team needs to operate without depending on one person's memory.

## The Anchor Holds

The NICU didn't make me less scared. It took the knowledge my wife had been trying to share for years and delivered it in a form I could finally absorb. Not because the content changed, but because the structure matched the learner. Our son still gets overwhelmed at large, chaotic gatherings. The Calm, Connect, Coach framework didn't make him less spirited. It gave us a shared way back when things get loud.

In Part 1, I wrote that the real test of my time as a Data Superhero will be the quality of the architects who take my place in 2036. In Part 2, I asked you to turn a scar into a map.

Part 3 is about what comes after the map. It's about encoding what you know into shared context so your team can operate from it together. Not as a document that sits in a wiki and gets stale. As a living framework: principles that guide decisions, checks that verify them, and conventions that make the right choice the default.

The knowledge was always available. The gap was never information. It was context, trapped in people instead of encoded in systems.

Build the NICU. Be the nurse.

**Your move:** In Part 2, I asked you to write down a piece of hard-won institutional knowledge. Now take the next step. Think about your own Snowflake environment and list out the things you'd want to verify if you were assessing its health from scratch. What would you check? What would you want automated so you'd never have to remember it again? That list is the seed of a framework. And coming up in the Well-Architected Framework series, we're going to build that framework together, one pillar at a time.

*Next in The Long Game: Part 4, Builders of Builders. Before that, I'll be launching a new series on Snowflake's Well-Architected Framework where we'll turn these principles into practice.*

*Noah Goodrich is a Snowflake Data Superhero and architect. Connect with him on* [*LinkedIn*](https://www.linkedin.com/in/noahgoodrich/)*.*

*All of the ideas, opinions, and stories in this article are mine, written in my own words first. I then worked with Claude to shape that raw material into something structured and readable. It was a great collaborator on flow and pacing. The experiences are mine. The craft is a partnership.*
