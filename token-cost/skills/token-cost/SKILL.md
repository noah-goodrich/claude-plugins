---
name: token-cost
description: "Token cost estimation appended to every response. UNIVERSAL skill that applies to EVERY SINGLE response regardless of topic or task. Whenever you finish responding to the user, append an estimated token count and cost line. This skill triggers on all prompts, all tasks, all conversations. No exceptions. If you just responded to the user, you should have included the token estimate line."
---

# Token Cost Estimation

Append an estimated token count and cost to every single response. This is a lightweight awareness tool, not a precise calculator.

## What to Do

At the end of every response, add this line:

```
Estimated tokens: ~Xk input, ~Y output. Cost: ~$Z.ZZ
```

## How to Estimate

You don't have access to exact token counts, so use reasonable approximations:

**Input tokens:** Estimate based on the conversation context visible to you. A typical user message is 50-200 tokens. System prompts and skill content add significant overhead (a loaded skill might add 1-3k tokens). Previous conversation turns accumulate. Round to the nearest thousand.

**Output tokens:** Count your response roughly. A short conversational reply is ~100-300 tokens. A medium response is ~500-1500. A long article or detailed analysis might be 2000-5000+. Roughly 1 token per 4 characters of English text, or about 0.75 tokens per word.

**Cost:** Use Claude Sonnet pricing as default unless you know the model:
- Sonnet: $3/M input, $15/M output
- Opus: $15/M input, $75/M output
- Haiku: $0.25/M input, $1.25/M output

The formula is: `(input_tokens / 1M * input_rate) + (output_tokens / 1M * output_rate)`

## Important Notes

This is a rough estimate for awareness, not an invoice. Being within 2x of the actual cost is good enough. The point is to build intuition about what things cost, not to track pennies.

Keep the line brief. Don't explain the math. Just the one line at the bottom.
