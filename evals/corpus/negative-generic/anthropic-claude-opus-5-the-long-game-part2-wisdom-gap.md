---
class: generic
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 2535
source_article: the-long-game-part2-wisdom-gap.md
prompt: |
  Write a technical blog post titled "The Long Game, Part 2: The Wisdom Gap" about The gap between an AI model's recall of technical information and the judgment required to apply it correctly on a complex data platform project.. Aim for about 2535 words. The audience is working data engineers.

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# The Long Game, Part 2: The Wisdom Gap

In [Part 1](#), I argued that data platforms are measured in years, not sprints, and that the defining property of platform work is that decisions compound. A schema choice made in week three is still generating support tickets in year four. A partitioning scheme that was fine at 40 GB is a $9,000/month line item at 40 TB. The long game is about how you make decisions whose consequences arrive long after the person who made them has moved on.

This post is about a specific problem that has landed in the middle of that long game: the models we now work with all day are extraordinary at recalling technical information and mediocre at knowing when to apply it. I want to be precise about the shape of that gap, because "AI is unreliable" is both true and useless. The gap is not random. It has structure. And once you can see the structure, you can route around it — and, more importantly, you can stop your team from walking into it.

## Recall Is Not Judgment

Ask a current frontier model to explain Iceberg's copy-on-write versus merge-on-read write modes and you will get an answer that is better than what most senior data engineers could produce from memory. It will correctly describe position deletes and equality deletes, the read amplification tradeoff, the interaction with compaction, the relevant table properties (`write.merge.mode`, `write.delete.mode`, `write.target-file-size-bytes`), and the fact that merge-on-read shifts cost from write time to read time. It will be accurate, well-organized, and complete.

Then ask it: "Should we switch our `fct_orders` table to merge-on-read?"

It will give you a reasonable-sounding answer. It will probably hedge appropriately. And it has almost no idea, because the answer depends on things that are not in the question and usually not in your repo:

- How many of your reads are point lookups by a BI tool with a 30-second timeout, versus full scans by a nightly aggregation job?
- Does your compaction job actually run, or was it disabled six months ago during an incident and never re-enabled?
- Is your query engine version one that pushes down delete files efficiently, or the one with the known planning regression?
- Does the team that owns the downstream marts have the on-call capacity to debug a read-latency regression at 2 a.m.?
- Are you nine weeks from a migration that will make this table irrelevant?

None of those are recall questions. All of them dominate the decision. This is the wisdom gap: the distance between knowing the tradeoff space and knowing which point in it your organization should occupy this quarter.

## A Taxonomy of the Gap

It helps to break the gap into categories, because each one has a different mitigation.

### 1. Context that never got written down

The largest category, and the most mundane. The model doesn't know that the `customer_id` in the CRM extract is a string that's numeric 97% of the time and contains legacy alphanumeric IDs for accounts created before 2016. It doesn't know that the upstream team's "real-time" API is actually a batch job that fires at 04:15 with a 40-minute tail. It doesn't know that Finance reconciles against the raw extract, not your model, so a "correct" dedup is a support escalation.

This knowledge lives in people's heads, in Slack threads, and in the scar tissue of past incidents. A model working from your codebase sees the artifact, not the reason. It sees `WHERE source_system != 'LEGACY_CRM'` and reads it as a filter. You know it as the settlement of a two-week argument.

### 2. Scale and cost effects that only appear in production

Models reason about correctness far more reliably than they reason about physics. A generated Spark job can be logically perfect and operationally catastrophic. Consider a MERGE the model writes for an incremental dbt model:

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge'
) }}

select * from {{ ref('stg_orders') }}
{% if is_incremental() %}
where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
```

This is textbook. It's also what you'll find in a hundred blog posts. It's also going to rewrite an enormous fraction of your table every run if `order_id` is high-cardinality and randomly distributed across a table partitioned by `order_date` spanning four years, because a late-arriving update to a 2021 order touches a 2021 file, and the copy-on-write engine rewrites that whole file. Your 12-minute job becomes a 90-minute job over six months, gradually, in a way no single PR review catches.

The model knows all the concepts involved. It knows about file rewrite amplification. It did not *apply* that knowledge, because nothing in the prompt signaled that this table was four years deep with a long update tail. You knew. You've watched a job's runtime chart bend upward before.

### 3. Time-shape and reversibility

Some decisions are two-way doors: change the config, measure, change it back. Some are one-way: once you've published a topic schema to nineteen consumers, or committed to a surrogate key strategy, or told the business that a metric means something specific, you own it.

Models are notably bad at weighting reversibility. They will offer a partition-scheme change and a `spark.sql.shuffle.partitions` tweak with the same tone of voice. One is an afternoon; the other is a quarter-long migration with a dual-write period, a backfill, and a consumer-by-consumer cutover. The *technical* description of both will be flawless. The relative gravity will be flat.

### 4. The median-of-the-internet problem

Training data over-represents what people write about and under-represents what people do. Blog posts are written about interesting architectures, conference talks are given about the streaming rewrite, and nobody writes "we kept it in Postgres and it was fine." The result is a systematic bias toward the more sophisticated option.

Ask for a design to handle late-arriving events and you'll get Flink, watermarks, allowed lateness, and state TTL — a genuinely correct answer that is also, for a team of four running a nightly warehouse, an enormous mistake. The boring answer (reprocess a trailing seven-day window every night, idempotently) is under-represented in the corpus relative to how often it's the right call.

This bias is compounded by recency skew in the other direction: models are often confidently fluent in the version of a tool from their training cutoff. Spark 3.5 defaults, an Airflow 2.x idiom, a Delta feature that moved from preview to GA with different semantics. The API surface of the data ecosystem churns fast enough that "correct as of eighteen months ago" is a real failure mode, and it's the kind that passes code review because it *reads* right.

### 5. Uncalibrated confidence

A senior engineer says "I think this works but I want to test it on last October's data because that's when we had the duplicate-event problem." That sentence contains a probability estimate, a threat model, and a specific empirical test, all derived from having been burned. Models produce hedges, but the hedges are stylistic rather than evidential. There's no "I've seen this fail" behind them, and — crucially — the hedging doesn't correlate well with actual risk. The model hedges on the well-documented thing and asserts confidently on the edge case.

## Why the Gap Is Structural, Not a Bug to Be Fixed

It's tempting to assume this all gets solved by the next model. Some of it will. Reasoning about scale effects is improving quickly, and better tool use — actually querying your catalog, reading your query history, checking your table statistics — closes a lot of the context gap.

But part of it is structural, and it's worth understanding why.

The written record of software engineering is a record of *artifacts*, not *decisions*. GitHub contains the code that shipped. It doesn't contain the three designs that were rejected in a whiteboard session, or the reason. Stack Overflow contains the question that got asked, not the eleven times someone almost asked it and figured it out. Architecture decision records are the rare exception, which is precisely why they're valuable — and even ADRs are usually written after the fact, as justification rather than deliberation.

Judgment is largely the accumulated residue of *counterfactuals*: knowing what would have happened if you'd done the other thing. That information is systematically absent from the training corpus, because nobody publishes it. You have it because you lived through it. The model doesn't, and won't, until organizations start writing down their rejected options and their postmortems in volume — which they mostly don't, and mostly can't, because that material is confidential and embarrassing in roughly equal measure.

## Working the Gap

Here's what actually changes in day-to-day practice. None of this is "don't use AI." I use it constantly. It's about where you insert human judgment in the loop.

### Supply the context deliberately, in writing

The single highest-leverage habit: before asking for a design, write the constraints down. Not "help me design an ingestion pipeline" but:

> Source: Postgres 14, ~200 tables, largest is 1.2B rows with ~4M updates/day. Debezium is already running for three tables. Consumers: one nightly dbt project (batch, 04:00), one Flink job doing sessionization (needs sub-5-min latency on two tables only). Team is 3 engineers, one of whom is 50% allocated. We are on Iceberg 1.4 with Trino 435 and Spark 3.5. Constraint: we cannot add a new managed service this quarter for procurement reasons. Failure mode we care most about: silent data loss during Postgres failover, which has happened twice.

That prompt gets a dramatically better answer. But notice what else it does: writing it forced you to articulate constraints you were carrying implicitly. Half the time I write one of these, I answer my own question before I hit enter. The prompt is doing double duty as a design doc. Keep them; they're the ADRs you were never going to write.

### Ask for the option space, not the recommendation

Models are much better at enumerating than at choosing. This plays to the strength:

> Give me four architecturally distinct approaches to this, including at least one that's deliberately low-tech. For each: what breaks first as volume grows 10x, what the operational burden looks like at 3 a.m., what's the cost of reversing the decision in 18 months, and what has to be true about our data for it to work.

You are the selector. The model is a very fast, very well-read generator of candidates. That division of labor matches the actual capability profile.

### Use it as an adversary against invariants you define

The best code-review use I've found isn't "review this PR." It's:

> Here is a dbt incremental model and here are three invariants: (1) it must be idempotent under full re-run of the last 7 days; (2) it must not produce duplicate `order_id` under any interleaving of late-arriving CDC events; (3) runtime must not scale with total table size, only with the incremental window. Find every way each invariant can be violated.

Invariants are yours to specify — that's judgment. Systematically hunting violations across a large surface area is exactly what the model is good at, and it will find things you missed. I've had models catch a non-idempotent `current_timestamp()` in a surrogate key hash that had survived two human reviews.

### Triage by reversibility before you delegate

A rough rule I use:

| Decision type | AI role |
|---|---|
| Two-way door, low blast radius (config tuning, a new staging model, a test) | Generate and ship, with normal review |
| Two-way door, wide blast radius (refactor across 40 models) | Generate, but verify empirically — diff outputs, not just code |
| One-way door (schema contracts, key strategy, partitioning on a large table, metric definitions) | Use for option generation and critique only. A human owns it and writes down why. |
| Anything involving a promise to another team | Human, always. The technical part is not the hard part. |

The failure mode isn't the model being wrong. It's the model being wrong on a one-way door, plausibly, at a moment when nobody had the bandwidth to think hard.

### Verify against data, not against agreement

Models are agreeable. If you ask "is this right?" you'll usually be told it is. If you ask "why is this wrong?" you'll get a list of reasons, some invented. Neither is evidence.

Cheap empirical checks beat both:

```sql
-- Before trusting any dedup/merge logic, know the actual shape
select
  count(*)                                    as rows_total,
  count(distinct order_id)                    as ids_distinct,
  max(update_count)                           as max_updates_per_id,
  approx_percentile(update_count, 0.999)      as p999_updates,
  max(datediff(ingested_at, order_date))      as max_lateness_days,
  approx_percentile(datediff(ingested_at, order_date), 0.99) as p99_lateness_days
from (
  select order_id, order_date, min(ingested_at) as ingested_at,
         count(*) as update_count
  from stg_orders group by 1, 2
);
```

Five minutes of this tells you more about whether the proposed design is right than an hour of conversation. It also *makes the model useful*, because now you can paste the numbers in and the context gap narrows substantially. The model's recall becomes genuinely powerful once it's pointed at real distributions instead of imagined ones.

### Make it run the pre-mortem

> Assume we shipped this and it caused a Sev-1 six months from now. Write the postmortem. What was the root cause?

This reliably surfaces failure modes that direct questioning misses. It's a prompt-engineering trick, but it works because it shifts the model from "generate a plausible design" to "generate a plausible failure," and the corpus of failure narratives is rich enough that it produces real hits: unbounded state growth, the compaction job that silently stopped, the backfill that ran with the wrong `catchup` semantics and double-counted revenue, the topic retention that expired before the consumer caught up.

## The Part That Should Worry You

Here's the thing I keep circling back to, and it's a career-shaped concern rather than a technical one.

Judgment is built from consequences. You learn that late-arriving data is a bigger deal than it looks because you shipped something that assumed it wasn't and then spent a weekend on a backfill. You learn to distrust `SELECT *` in a staging model because an upstream team added a column with a reserved-word name and your build broke at 3 a.m. Every piece of judgment I have is a scar.

The current tooling is exceptionally good at preventing junior engineers from acquiring scars. The model writes the code, the code mostly works, the incident doesn't happen, and the learning doesn't happen either. Then in year three that engineer faces a one-way door and has recall without judgment — which is exactly the model's failure profile, now instantiated in a human who is nominally accountable.

I don't have a clean answer, but I have practices we've adopted:

- **Ownership of the on-call consequence.** Whoever ships it, debugs it. Not the model, not the senior who reviewed it. The feedback loop has to close on the same person.
- **Explain-before-merge.** For anything nontrivial, the author walks through *why* this approach, including what was rejected. If the answer is "the model suggested it," that's not a review failure, it's a learning opportunity — go find the alternatives.
- **Deliberate slow paths.** Some percentage of work should be done without assistance, chosen for its learning value rather than its urgency. This is unpopular and it's correct.
- **Postmortems that name the decision, not just the bug.** "The root cause was a merge strategy chosen without checking the update-lateness distribution" is a transferable lesson. "The root cause was duplicate rows" is not.

## Where This Leaves Us

The wisdom gap is not a reason to be a skeptic. Recall at this quality is genuinely transformative — I no longer lose forty minutes to finding the right Iceberg table property, and I no longer write boilerplate. The velocity gain on the mechanical 70% of data engineering is real and permanent.

But the value of the remaining 30% went *up*, not down. When generating a plausible design costs nothing, the scarce resource becomes the ability to look at four plausible designs and know which one your organization can actually operate for the next five years. That's the long game. That's the part that still runs on scar tissue.

In Part 3, I want to get concrete about how to build that judgment deliberately rather than accidentally — what a data platform team's decision record should actually contain, and how to make the organization's memory outlive the people who formed it.
