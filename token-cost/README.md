# token-cost

Appends estimated token counts and cost to every response. Lightweight awareness tool for building intuition about what things cost.

## Components

| Component | Type | Purpose |
|-----------|------|---------|
| token-cost | Skill | Estimates input/output tokens and cost per response |

## Usage

Triggers on every response. Appends a single line:

```
Estimated tokens: ~Xk input, ~Y output. Cost: ~$Z.ZZ
```

No dependencies. Install anywhere: Cowork, Claude Code, claude.ai projects.

## Note

This skill relies on the model self-estimating token counts, which is approximate. Accuracy is within ~2x of actual cost. The goal is awareness, not accounting.
