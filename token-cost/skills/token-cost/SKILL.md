---
name: token-cost
description: "Token cost estimation appended to every response. UNIVERSAL skill that applies to EVERY SINGLE response regardless of topic or task. Whenever you finish responding to the user, append an estimated token count and cost line. This skill triggers on all prompts, all tasks, all conversations. No exceptions. If you just responded to the user, you should have included the token estimate line."
---

# Token Cost Estimation

Append an estimated token count and cost to every response. Lightweight awareness, not a precise
calculator — but it MUST account for delegated work (subagents / workflows), which is usually the
dominant cost and is invisible to a naive main-loop estimate.

## What to Do

At the end of every response, add this line. On turns where a subagent/workflow ran, include the
delegated clause:

```
Tokens — main ~Xk in / ~Y out; delegated ~D subagent-tok ≈ $S. Turn ≈ $T.
```

On the common case (no delegation this turn), drop the delegated clause:

```
Tokens — main ~Xk in / ~Y out ≈ $T.
```

## Main-loop estimate

You don't see exact counts, so approximate:
- **Input:** the context visible to you. A user message is 50-200 tokens; a loaded skill 1-3k;
  prior turns accumulate. Round to the nearest thousand.
- **Output:** your response length. ~0.75 tokens/word (~1 token per 4 chars). Short reply 100-300,
  medium 500-1500, long 2000-5000+.

## Pricing (USD per million tokens)

Cache reads/writes matter. Long-context and subagent work is dominated by **cache reads**, which are
~10x cheaper than fresh input — do not price cached context as fresh input.

| Model  | input | output | cache write (5m) | cache read |
|--------|-------|--------|------------------|------------|
| Opus   | $15   | $75    | $18.75           | $1.50      |
| Sonnet | $3    | $15    | $3.75            | $0.30      |
| Haiku  | $0.25 | $1.25  | $0.31            | $0.025     |

Default to the model you are actually running as (check the environment); fall back to Sonnet if
unknown.

## Delegated work (subagents & workflows) — the part that used to be missing

Subagents / nanoprobes / workflow agents run in SEPARATE contexts; their tokens never pass through
the main loop, so they are invisible to the main-loop estimate above. They are usually the bulk of
the spend — count them explicitly.

When a workflow or background Task completes you receive a `<usage>` block, e.g.
`<usage><agent_count>7</agent_count><subagent_tokens>382603</subagent_tokens>...</usage>`.

**What `subagent_tokens` is (measured against transcripts, not assumed):** the sum over agents of
each agent's *final-message context size* (`input_tokens + cache_read_input_tokens +
cache_creation_input_tokens` at its last turn). It is a peak-context-footprint proxy — NOT output,
and NOT total throughput. It undercounts real token throughput by ~50-60x (one heavy wave reported
382k while ~24.5M tokens were actually processed) because you pay cache-read on every turn but this
counts each agent's context only once.

**Quick proxy (use for the inline line):** delegated cost ≈ `subagent_tokens × $0.16 / 1k` for Opus
workflows (observed $0.147-0.177 per 1k across runs on 2026-06-10; lands within ~10%). Scale by
model — Sonnet ≈ 1/5 of Opus. Good enough for the awareness line.

**Accurate (use for a cost post-mortem or when the number matters):** sum the real usage from the
subagent transcripts and apply cache-aware pricing. The workflow result names a transcript dir
containing `agent-*.jsonl`:

```
jq -s '[.[]|.message.usage?|select(.!=null)]
  | {inp:(map(.input_tokens//0)|add), out:(map(.output_tokens//0)|add),
     cc:(map(.cache_creation_input_tokens//0)|add), cr:(map(.cache_read_input_tokens//0)|add)}
  | .cost=((.inp*15)+(.cc*18.75)+(.cr*1.5)+(.out*75))/1e6' <transcript-dir>/agent-*.jsonl
```

(swap the four rates for the model used). Two real Opus waves cost $56.14 and $43.08 by this method;
the `× $0.16/1k` proxy estimated $61 and $39 — within ~10%.

## Notes

- Within 2x is fine for the inline line; the point is intuition, not an invoice.
- The proxy rate is model- and workload-dependent (cache-hit ratio, turns per agent). Re-derive it
  if Opus pricing or the harness's `subagent_tokens` definition changes.
- Keep the line brief. Don't show the math inline.
