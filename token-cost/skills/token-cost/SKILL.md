---
name: token-cost
description: "Token cost estimation appended to substantial or delegated responses. Append a token/cost line when non-trivial work was done (multi-step tasks, file edits, tool chains) or a subagent/workflow ran. Skip on trivial conversational replies: one-line answers, clarifications, yes/no responses, or simple lookups that require no tools."
---

# Token Cost Estimation

Append a rough token/cost line to substantial or delegated responses for awareness. IMPORTANT: the
inline estimate is a LOWER BOUND, not an invoice — from inside a turn you cannot see two of the
biggest cost drivers: extended-thinking tokens (billed as output) and cache reads of the growing
context (which usually dominate a long session). For accurate spend, a SessionEnd hook writes
per-session, per-model data to `~/.claude/token-spend.jsonl` — see "Accurate spend" below.

## What to Do

**Append the cost line when:**
- A subagent or workflow ran (delegated work happened).
- Non-trivial work was done: multi-step reasoning, file reads/edits, tool chains, research, or
  any response that took more than a handful of tokens to produce.

**Skip the cost line when:**
- The reply is a one-line answer, clarification, or yes/no.
- The reply is purely conversational with no tool use and minimal reasoning.

At the end of qualifying responses, add this line (drop the delegated clause when no
subagent/workflow ran):

```
Tokens — main ~Xk in / ~Y out; delegated ~$S (subagents). Turn ≈ $T (rough lower bound).
```
```
Tokens — main ~Xk in / ~Y out ≈ $T (rough lower bound).
```

## Main-loop estimate (rough, runs LOW)

- **Input:** visible context. A user message is 50-200 tokens; a loaded skill 1-3k; prior turns
  accumulate.
- **Output:** your visible reply (~0.75 tok/word) PLUS extended thinking, which you cannot see and which
  can be several times the visible text. Assume real output is well above what you can count.
- **Cache reads** of the accumulated context are billed every turn and usually DOMINATE — invisible to
  you mid-turn. This is the main reason the inline line is only a lower bound.

## Pricing (USD per million tokens)

| Model  | input | output | cache write (5m) | cache read |
|--------|-------|--------|------------------|------------|
| Opus   | $15   | $75    | $18.75           | $1.50      |
| Sonnet | $3    | $15    | $3.75            | $0.30      |
| Haiku  | $0.25 | $1.25  | $0.31            | $0.025     |

Price each side by the model actually running it — the main loop and subagents usually differ (main on
Opus; subagents on Sonnet/Haiku). Cache reads are ~10x cheaper than fresh input; never price cached
context as fresh input.

## Where the cost actually is (measured)

A real heavy multi-agent session measured **~96% main loop** (Opus: thinking-as-output + tens of
millions of cache reads) and only **~4% subagents** (Sonnet/Haiku). Takeaways:
- The orchestrator / main loop is usually the dominant cost, NOT delegation. The harness already routes
  subagents to cheaper tiers, so delegated spend is typically small.
- Biggest main-loop levers: keep the context lean (don't pull large tool outputs into the main context —
  they get cached and re-read every turn), fewer/shorter turns, less unnecessary thinking.

## Delegated work (subagents & workflows)

Subagents run in SEPARATE contexts; their tokens never pass through the main loop, so the main-loop
estimate misses them — count them when present (usually a small addition).

The workflow `<usage>` block reports `subagent_tokens` = the sum over agents of each agent's
FINAL-message context footprint (input + cache_read + cache_creation). It is a context-footprint signal
— NOT output, NOT throughput, and NOT a reliable cost figure (it ignores per-turn cache reads, output,
and the agents' models). Use it only as a rough size signal; for cost, use the accurate source below.

## Accurate spend (source of truth)

The token-cost SessionEnd hook appends one per-session record to `~/.claude/token-spend.jsonl` with
per-model raw counts (main + subagents, kept separate) and a cache-aware `est_cost_usd`. Sum or group it
for real numbers and trends:

```
jq -s 'map(.est_cost_usd) | add' ~/.claude/token-spend.jsonl                       # all-time total
jq -s 'group_by(.project) | map({project:.[0].project,
        cost:(map(.est_cost_usd)|add)})' ~/.claude/token-spend.jsonl               # by project
```

To recompute a session's cost from transcripts directly, the hook is the reference: sum
input/output/cache_creation/cache_read from the assistant `.message.usage` blocks and apply the
per-model rates above. `est_cost_usd` is API-pay-as-you-go-equivalent — useful for relative trends, not
your actual subscription billing.

## Notes

- The inline line is a rough lower bound for awareness; `~/.claude/token-spend.jsonl` is the truth.
- Keep the inline line brief. Don't show the math inline.
