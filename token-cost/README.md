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

## Hooks

Two hooks ship alongside the skill (registration in `hooks/hooks.json`):

### `token-spend-log.sh` — SessionEnd (always on)

Appends one per-session record to `~/.claude/token-spend.jsonl` with per-model raw token counts (main loop and subagents
kept separate) plus a cache-aware `est_cost_usd`. Data collection only — query it with `jq` for real spend and trends.

### `truncate-tool-output.sh` — PostToolUse (OPT-IN, default OFF)

Caps the model-visible output of large `Bash`/`Read` tool calls to curb the dominant cost lever — cache reads of an
ever-growing context. When a tool's output exceeds the line threshold, the result the model sees is replaced (via the
PostToolUse `hookSpecificOutput.updatedToolOutput` field) with the head + tail plus a marker stating how many lines were
cut and how to fetch the rest. Output at or under the threshold is left byte-unchanged.

**Safety — it can never break a tool result.** It is inert unless `TRUNCATE_TOOL_OUTPUT=1`, and it fails safe: any missing
dependency, parse error, or unrecognized `tool_response` shape leaves the output untouched.

**Enable** by registering it as a PostToolUse hook in `settings.json` and exporting the env flag:

```json
{
  "hooks": {
    "PostToolUse": [
      { "matcher": "Bash|Read",
        "hooks": [ { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/truncate-tool-output.sh", "timeout": 10 } ] }
    ]
  }
}
```

```sh
export TRUNCATE_TOOL_OUTPUT=1             # required; the hook is inert otherwise
export TRUNCATE_TOOL_OUTPUT_MAX_LINES=200 # optional tunables (defaults shown)
export TRUNCATE_TOOL_OUTPUT_HEAD=120
export TRUNCATE_TOOL_OUTPUT_TAIL=40
```

**Before relying on it, verify the regression guard (directive C3):** enable it for a session or two and confirm it does
not raise turn/re-run count on real tasks — truncation that hides output Claude needs is net-negative. The script-level
behaviour (500-line → truncated, 50-line → unchanged, fail-safe) is covered by `hooks/test/truncate-tool-output.bats`.

## Note

This skill relies on the model self-estimating token counts, which is approximate. Accuracy is within ~2x of actual cost. The goal is awareness, not accounting.
