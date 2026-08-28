---
class: generic
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 998
source_article: being-told-i-could-be-fired.md
prompt: |
  Write a technical blog post titled "Being Told I Could Be Fired Was the Best Thing for My Career" about What a manager's warning that an engineer could be fired changed about that engineer's teamwork, and what it implies about delivering hard feedback.. Aim for about 998 words. The audience is working data engineers.

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# Being Told I Could Be Fired Was the Best Thing for My Career

Four years ago, my manager ended a Tuesday one-on-one by saying, "I want to be direct with you. If nothing changes in the next quarter, I don't think you'll still be on this team."

I remember the exact shape of the silence afterward. I had shipped the migration off cron-driven bash into Airflow. I had cut our nightly batch from six hours to ninety minutes. My ticket throughput was, by any dashboard we had, the highest on the team. I genuinely thought I was about to be told I was being promoted.

What I got instead was the most useful forty minutes of my career.

## What I thought the job was

I thought the job was closing tickets and keeping data fresh. Latency, correctness, cost. Those are real metrics and I was good at them.

Here is what was actually happening, which my manager laid out in specifics I couldn't argue with:

- I owned 31 of our 74 DAGs, and I was the only person who had ever deployed to 22 of them. When I took a week off, we ran a "please don't touch anything" policy.
- Onboarding our last hire took nine weeks to first independent production change. The team average before me had been four. Most of the tribal knowledge about our CDC pipeline lived in my head, and I had answered every question in DMs rather than in docs.
- I had rewritten a colleague's incremental dbt model over a weekend because his merge strategy was, in my judgment, wrong. I pushed it Monday morning with the commit message `simplify`. He found out in standup.
- My code review comments included the phrase "this will obviously break" eleven times in three months. My manager had counted.

None of that showed up in throughput. All of it showed up in the team's throughput. Our PR cycle time was rising while my personal velocity climbed. I was a high-performing bottleneck, which is a thing you can be for a surprisingly long time before anyone says the word "fired."

## Why nobody told me sooner

Two people had tried. I can find the evidence now, in retrospect: "maybe loop Devansh in earlier next time," "you could be a little gentler in reviews." I heard those as social pleasantries, not as signals. They cost the speaker nothing and they cost me nothing, so I paid the price they were listed at, which was zero.

That's the failure mode. Softened feedback isn't kinder; it's just cheaper for the person giving it. It transfers the interpretive burden onto the person least equipped to do the interpretation. I wasn't ignoring feedback. I was correctly parsing a low-confidence signal as noise.

The reason the "you could be fired" conversation worked is not that fear is motivating. Fear mostly makes people defensive and short-term. It worked because the stakes clause was **information**. It told me, unambiguously, the magnitude of a variable I had been estimating at zero.

## What I actually changed

The changes were embarrassingly concrete once I knew what to aim at. Almost none of them were about being nicer.

**Bus factor became a tracked metric.** We added a monthly report: for each DAG and dbt model, how many distinct humans had merged a change in the last 180 days. Anything at 1 was a defect. I spent the next quarter deliberately not fixing things — routing pages to whoever owned the domain, pairing for an hour instead of solving it in ten minutes alone.

**I wrote the runbooks I'd been carrying in my head.** Nineteen of them. Each one was worse than what I knew, and each one was infinitely better than nothing at 3 a.m.

**I changed the grammar of my review comments.** Imperatives became questions with a stated concern: "What happens here if the source emits a late-arriving partition? I might be missing it." Style opinions got a `nit:` prefix and an explicit "non-blocking." I started approving PRs I would have written differently, and asking myself one question first: *is this reversible?* In data work that's usually a cost question — a backfill is a two-way door if it's a day of compute and a one-way door if it corrupts a downstream contract that six teams read. I fought about the one-way doors. I let everything else ship.

**I stopped rewriting other people's work without a conversation.** Not because it's rude, though it is. Because every time I did it, I converted a colleague who was learning our system into a colleague who was waiting for me to fix things.

Eighteen months later I was leading that team. The thing that got me there was the thing I'd been penalized for lacking.

## What this implies if you're the one giving feedback

Most data engineers will end up as tech leads or managers, and most of us are bad at this. Some things I took from being on the receiving end:

**Vagueness is cowardice with better manners.** If you can't name the behavior, the impact, and the consequence, you haven't given feedback — you've hinted. "Be more collaborative" is a code smell. "You merged a rewrite of Devansh's model without telling him, and he's stopped submitting PRs to that repo" is a diff.

**Say the stakes out loud.** Withholding the fact that someone's job is at risk isn't protecting them. It's protecting you from an uncomfortable hour while they burn a quarter they could have spent fixing it. People are entitled to know what game they're playing.

**Deliver it early, when it's cheap.** Feedback debt behaves exactly like schema drift: small, ignorable, compounding, and eventually a breaking change you have to handle in an incident.

**Attack the behavior, never the identity.** "Your reviews are landing as contemptuous" is actionable. "You're arrogant" is a personality diagnosis, and nobody has ever refactored their personality in response to a one-on-one.

**Close the loop.** My manager set a check-in three weeks out and told me exactly what "better" would look like. Without that, hard feedback is just a threat with no acceptance criteria.

One caveat: this only works when the feedback is honest. A warning delivered as the opening move of a documented exit is a different artifact entirely, and engineers can tell the difference immediately. My manager took a real risk by telling me the truth while I still had time to use it.

I've tried to pay that forward. It never stops being uncomfortable. It's still the most valuable thing I know how to do for someone.
