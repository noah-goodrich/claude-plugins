---
class: generic
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 1133
source_article: the-long-game.md
prompt: |
  Write a technical blog post titled "The Long Game" about Leadership as stewardship, evaluated by the health and resilience of a system years after the leader has moved on rather than by near-term performance.. Aim for about 1133 words. The audience is working data engineers.

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# The Long Game

There's a particular kind of ghost that haunts data engineering teams. It arrives as a Slack message from someone in finance: "Hey, is `revenue_daily_v3` still the right table to use?" Nobody knows. The person who built it left eighteen months ago. It's referenced by four dashboards, two of which are pinned to an executive's homepage. Its DAG has a `depends_on_past=True` flag nobody understands and a retry count of 47.

That table is a leadership artifact. It tells you more about how the team was led than any performance review ever will.

We evaluate engineering leaders almost entirely on near-term signals: velocity, incident counts, quarterly roadmap delivery, whether the migration landed on time. These are the measurements available while the leader is still in the room, which makes them convenient and, for that same reason, deeply misleading. The actual test of leadership in data infrastructure happens three years later, when the person who made the decisions is gone and the system either bends or shatters.

## Why Data Systems Punish Short-Termism Especially Hard

Every engineering domain has technical debt. Data engineering has something worse: **semantic debt**.

If you write a bad service, the service is bad and you can rewrite it. The blast radius is bounded by its API. If you write a bad table, you don't just have a bad table — you have a bad *definition* that has propagated into hundreds of downstream decisions, into spreadsheets, into board decks, into a competitor analysis someone ran in 2022 and still cites. The wrongness has been laundered into institutional belief.

This asymmetry means the cost curve for data decisions is unusually steep and unusually delayed. A leader who ships fast by skipping the boring work — no lineage, no contracts, no ownership model, no deprecation process — will look excellent for about six quarters. The interest payments don't come due until the person collecting the credit has been promoted somewhere else.

I've watched this cycle enough times to name the pattern: **decisions that compound negatively resolve slower than tenure**. The average engineering manager tenure at a given company is something like two to three years. The average lifespan of a core fact table is longer than that. The incentive structure is quietly, structurally broken.

Stewardship is the discipline of leading as though you'll be judged after the incentive window closes.

## What Stewardship Actually Looks Like in Practice

It is not caution. This is the most common misreading. Stewardship isn't "move slowly and don't break things" — that's a different failure mode, and it produces its own ruins: a platform so encrusted with process that nobody can ship, staffed by people who've learned that initiative is punished.

Stewardship is about **preserving optionality for the people who come next**. Concretely:

**Reversible decisions get made fast; irreversible ones get made carefully.** Choosing an orchestrator is fairly reversible — DAGs are portable-ish, the migration is painful but bounded. Choosing your partitioning strategy on a 400TB table, or your primary grain for the core customer entity, or your event schema versioning philosophy: those are load-bearing walls. A steward spends their carefulness budget where it compounds.

**Naming and modeling are treated as first-class engineering work.** `revenue_daily_v3` is a leadership failure, not an individual contributor's failure. It means nobody enforced that new versions replace old ones, that names describe grain and semantics, that a table's existence implies an owner. The steward's contribution here isn't writing better names — it's making bad names socially and technically expensive.

**Deletion is a funded activity.** This is the clearest tell. Ask a data leader when their team last deleted a pipeline. Not deprecated-in-a-doc — actually deleted, with the downstream consumers migrated and the storage reclaimed. Teams that never delete are accumulating a maintenance liability that grows superlinearly, because every asset multiplies the surface area of every future change. A steward budgets for subtraction, and does it while they're still around to absorb the political cost of telling someone their dashboard is going away.

**Knowledge is externalized aggressively.** The heroic on-call engineer who knows why the Snowflake warehouse scales up at 3 a.m. on the second Tuesday of the month is a liability the org has chosen to tolerate. Runbooks, decision records, and architecture docs are boring, and they are the primary mechanism by which a system survives personnel turnover. A leader who is personally indispensable has, by definition, failed at stewardship.

## The Metrics That Actually Predict Resilience

If near-term performance is a bad proxy, what's a better one? Some candidates that hold up reasonably well:

- **Time-to-first-meaningful-change for a new hire.** Not time to first commit — time until they can modify a core model without supervision. This measures documentation, test coverage, and architectural legibility simultaneously. Under two weeks is healthy. Over two months means the system exists mostly in people's heads.

- **Percentage of assets with a named, living owner.** Not a team alias that resolves to nobody. If it's below 70%, the system is already partly abandoned and just hasn't noticed.

- **Ratio of new pipelines to retired pipelines.** Persistent, unbounded growth here is a slow-motion incident.

- **Cost of the last schema change to a core entity.** How many people did you have to notify? How many broke anyway? This measures whether you have real contracts or just hope.

- **How often incidents are caused by things nobody knew existed.** The rate of "wait, *what* consumes this?" is a direct read on lineage quality and, indirectly, on whether past leaders thought about the future.

None of these will appear in a quarterly business review. All of them predict whether your platform will be an asset or an archaeological site in 2029.

## The Uncomfortable Part

Stewardship costs you, personally, in the short run. The leader who spends a quarter on ownership models and deprecation tooling will lose the roadmap comparison to the leader who shipped six new dashboards. There's no way around this. The rewards of stewardship accrue to your successor, and the rewards of extraction accrue to you.

Which is why this is fundamentally a values question rather than a tactics question. You can learn the practices from a blog post. You can't be argued into caring about a system's state after you've stopped benefiting from it.

But here's the pragmatic case, for what it's worth: you will almost certainly inherit someone else's system before you build your own. Most of your career will be spent living inside decisions made by people who are no longer accountable for them. The culture of stewardship you build is the culture you'll eventually be a beneficiary of — not from the person you handed off to, but from the peers and successors who watched how you operated and calibrated accordingly.

The long game is the only one where the score is real. Everything else is a snapshot taken before the interest came due.
