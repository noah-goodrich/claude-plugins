# Caching Economics Synthesis — Token-Cost Optimization Directive

**Date:** 2026-06-30
**Question:** Where does Claude Code main-loop cost actually go (cache reads of growing context vs fresh
input vs output vs thinking), what are the economics of the 5-min vs 1-hour cache TTL, and which levers
yield the biggest % savings under corrected Opus 4.6+ pricing ($5/$25 per MTok)?

**Sources used:** Track 4 session/turn hygiene research (`~/.claude/research/track4-session-turn-hygiene.md`,
2026-06-29); Anthropic official pricing page (`platform.claude.com/docs/en/about-claude/pricing`, fetched
2026-06-30); Claude Code prompt-caching docs (`code.claude.com/docs/en/prompt-caching`, fetched 2026-06-30);
directive (`claude-plugins/docs/plans/directives/2026-06-29-token-cost-optimization.md`).

---

## Executive Summary

- **Cache reads and cache creation together = 87.8% of main-loop cost** ($13,677 of $15,589 across 210
  sessions). Fresh input is negligible (0.3%). This means nearly all spend is the overhead of re-presenting
  an ever-growing context — not reasoning over new content.
- **The single highest-ROI lever is context leanness.** At an 18x cache read-to-write ratio, every token
  added to context gets read back 18 times per session. Tool-output truncation (L1) and `/clear` on project
  switch (L3) are structural — they cut context permanently and reduce both `cache_creation` and
  `cache_read` on every future turn.
- **Corrected pricing confirms a 3x cost overstatement.** Opus 4.6+ = $5/$25 per MTok; old stale figure
  was $15/$75 (Opus 4.1). All-time `est_cost` was recalculated to ~$18.5k. The corrected figures are used
  throughout this document.
- **Subscription vs credits creates a hidden TTL switch.** On a Claude subscription, the main session gets
  1h TTL automatically — but when over the usage cap (on credits), the TTL drops to 5m automatically.
  Subagents ALWAYS get 5m TTL, regardless of subscription status.
- **Billing framing is usage allotment, not $/token.** The real cost lever is staying under the monthly
  allotment and minimizing credit overage. Every cache-read reduction extends allotment; the `est_cost_usd`
  figures are API-equivalent estimates, not invoices.

---

## Findings

### 1. Confirmed Pricing (Opus 4.6/4.7/4.8 — all identical)

Source: [Anthropic API pricing page](https://platform.claude.com/docs/en/about-claude/pricing) [2024-2026]

| Component | Rate per MTok | Notes |
|-----------|--------------|-------|
| Base input | $5.00 | Standard fresh input |
| 5-min cache write | $6.25 | 1.25x input; cheaper to write |
| 1-hour cache write | $10.00 | 2.0x input; more expensive write |
| Cache read (hit) | $0.50 | 0.1x input; 10% of base rate |
| Output | $25.00 | Includes extended thinking tokens |

Comparison: Opus 4.1 (deprecated) = $15/$75 per MTok — 3x higher. The directive's corrected baseline
of $5/$25 is confirmed. All Opus 4.6, 4.7, and 4.8 variants share identical pricing.

**Tokenizer note:** Opus 4.7 and later use a newer tokenizer producing ~30% more tokens for the same
text vs Opus 4.6. Token counts inflate by ~30% on upgrade, but per-token price is unchanged — so
effective cost per unit of text rises ~30% moving from 4.6 → 4.7/4.8. Sessions migrating upward should
expect higher `cache_read_input_tokens` counts for the same prompts.

Subagent tiers (for routing decisions):
- Sonnet 4.6: $3/$15 input/output; cache write $3.75/MTok; cache read $0.30/MTok
- Haiku 4.5: $1/$5 input/output; cache write $1.25/MTok; cache read $0.10/MTok

---

### 2. Actual Cost Structure — Where the Money Goes

Source: local analysis of `~/.claude/token-spend.jsonl`, 210 sessions, corrected Opus 4.6+ pricing
[2026-06-29]

| Component | Tokens | Cost | % of Main Loop |
|-----------|--------|------|---------------|
| Cache reads (`cache_read_input_tokens`) | 16,173,409,369 | $8,086 | 51.9% |
| Cache creation (`cache_creation_input_tokens`) | 894,528,324 | $5,591 | 35.9% |
| Output + thinking (`output_tokens`) | 103,610,231 | $2,590 | 16.6% |
| Fresh input (`input_tokens`) | 8,319,926 | $42 | 0.3% |
| **Main loop total** | — | **$15,589** | **100%** |
| Subagents | — | $3,152 | (separate) |
| **All-time total** | — | **$18,741** | — |

The **cache read-to-write ratio is 18.0x** (16,173M reads / 894M writes). This is high — caching is
working effectively. The problem is not cache misses; it is the sheer volume of context being presented
on every turn. Even at the 10%-of-input rate, 16B tokens at $0.50/MTok = $8,087.

**The implication of 18x:** If context grows by 1,000 tokens (e.g., one moderately verbose tool output),
those tokens get cache-read approximately 18 times across the session. That's 18,000 additional
cache-read tokens. At $0.50/MTok: $0.009 per 1,000 tokens per session — small individually, enormous
at scale across 210 sessions.

**Output + thinking (16.6%):** This portion is irreducible as long as Claude is doing complex reasoning.
Extended thinking tokens bill as output tokens and are invisible mid-turn. Medium effort (`effortLevel:
medium`) caps thinking depth vs high effort, making this the only lever on the output/thinking share.

---

### 3. Cache TTL Economics — Subscription vs API vs Credits

Source: [Claude Code prompt caching docs](https://code.claude.com/docs/en/prompt-caching) [2024-2026]

**Three distinct regimes** exist for this account, not two:

| Regime | TTL | Cache write cost | Triggered by |
|--------|-----|-----------------|-------------|
| Subscription (main session, within allotment) | 1h | $10/MTok | Normal operation |
| Subscription (main session, on overage credits) | 5m | $6.25/MTok | Over monthly cap |
| Subagents (always, regardless of subscription) | 5m | $6.25/MTok | Every subagent spawn |

**The directive's C4 finding ("VERIFIED N/A — leave unset") is partially correct but incomplete:**
- True: `ENABLE_PROMPT_CACHING_1H=1` is the API-key lever; the subscription gets 1h automatically for
  the main session.
- New finding: When over the usage limit on credits (as happened 2026-06-29), the TTL drops to 5m
  automatically. Forcing the flag while on credits would raise the write cost from $6.25 to $10/MTok
  per cache miss — confirming "leave it unset."
- New finding: **Subagents always use 5m TTL on the subscription.** This means every subagent-spawned
  conversation pays 5m cache dynamics — including cold re-creates if the subagent has pauses or
  multi-turn internal loops. Routing to Sonnet/Haiku reduces the absolute cost of these writes.

**Break-even math for 5m vs 1h TTL:**
For a 100K-token context with one idle break > 5 minutes:
- 5m regime (cache expires): cache_creation = 100K × $6.25/MTok = $0.625
- 1h regime (cache survives): cache_read = 100K × $10/MTok (write) → amortized over reads = $0.50 read
- Break-even: 1h write pays back after just ONE read vs re-create. Any session with a single human
  review pause > 5 min benefits from 1h TTL — which the subscription provides automatically (until cap).

**The cap-triggered TTL drop is the costliest hidden event.** A session that hits the cap mid-work
silently shifts from 1h to 5m. The next pause > 5 minutes triggers a full cache_creation for the
accumulated context. With a 100K+ token context late in a long session, that's $0.625+ per pause.
This is a self-reinforcing spiral: capping triggers 5m TTL, which increases credit spend on re-creates,
which deepens the overage.

---

### 4. Context Growth Dynamics — How Context Becomes the Enemy

Source: Track 4 research [2026-06-29]; Claude Code context window docs [2024-2026]

**Baseline session context at startup** (before any user turn):

| Layer | Tokens | Notes |
|-------|--------|-------|
| System prompt | ~4,200 | Core instructions + tool definitions |
| Auto memory (MEMORY.md) | ~680 | First 200 lines or 25KB |
| Environment info | ~280 | Working dir, platform, git status |
| MCP tools (deferred) | ~120 | Names only; schemas deferred |
| Skill descriptions | ~450 | One-liners; full skill loads on invocation |
| ~/.claude/CLAUDE.md | ~320 | Global preferences |
| Project CLAUDE.md | ~1,800 | Project conventions |
| **Total baseline** | **~7,850** | Before any user turn |

The baseline is fixed and healthy. Growth comes from **file reads and tool outputs** accumulating in the
conversation layer. Every file Claude reads, every Bash output, every tool result — all permanent in context
until `/clear` or `/compact`.

**CLAUDE.md overhead at 18x read ratio:** Every token in CLAUDE.md is present in EVERY request. At the
18x ratio, 1,000 extra tokens in CLAUDE.md = 18,000 extra cache-read tokens per session. At $0.50/MTok:
$0.009 per 1,000 tokens per session. Across 210 sessions, 1,000 extra CLAUDE.md tokens ≈ $1.89 total.
This is small but non-zero; keeping CLAUDE.md ≤ 200 lines is still correct practice.

**Autocompact threshold:** Auto-compaction fires at approximately 83.5% context usage (~167K usable tokens
out of 200K context). Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`. Target compact at ~60% for better
summary quality and to prevent mid-task compaction.

---

### 5. Actions That Invalidate the Cache — Hidden Cost Spikes

Source: [Claude Code prompt caching docs](https://code.claude.com/docs/en/prompt-caching) [2024-2026]

Each of these triggers a full cache rebuild on the next turn (expensive one-time cost):

| Action | Cache effect | Avoidance |
|--------|-------------|-----------|
| Model switch (`/model`) | Each model has its own cache; full rebuild | Set model at session start, never switch |
| Effort level change (`/effort`) | Keyed separately per model; full rebuild | Set effort at session start; confirmed dialog shown |
| Fast mode enable | Adds cache-key header; full rebuild once | Enable at session start if needed, not mid-session |
| MCP server connect/disconnect | If tools in prefix (not deferred) | Keep tool search enabled (deferred mode default) |
| Plugin enable/disable (MCP type) | Same as MCP connect/disconnect | Manage plugins at session start |
| `/compact` | Conversation layer rebuilds from new summary | Run at natural breaks, not mid-task |
| Claude Code upgrade | System prompt changes; first turn = full rebuild | Expect first-post-upgrade turn to be expensive |
| Resume session after upgrade | Entire history reprocessed; no cache hits | Use handover file + `/clear` instead of resume |

**The `opusplan` danger:** `opusplan` switches Opus ↔ Sonnet on each plan-mode toggle. Every toggle =
model switch = full cache rebuild. If plan/execute cycles are frequent (> once per session), `opusplan`
is more expensive than staying on one model.

**Resuming long sessions after upgrade** is the single most expensive request a user can send. The full
conversation history — potentially 150K+ tokens — reprocesses with no cache hits. Cost: 150K ×
$5/MTok = $0.75 just for fresh input processing. Pre-upgrade handover + `/clear` + fresh session costs
only the 7,850-token baseline.

---

### 6. Lever Prioritization Under Corrected Pricing

Estimated impact ranges are based on the observed cost structure (51.9% cache reads, 35.9% cache creation,
16.6% output, 0.3% fresh input) and the 18x read multiplier.

| Rank | Lever | Directive ref | Mechanism | Estimated % impact | Effort |
|------|-------|--------------|-----------|-------------------|--------|
| 1 | Tool-output truncation (>N lines) | L1 (C3) | Cuts cache_creation AND 18x cache_reads per added token | **20–40% of 87.8%** cache share if tool outputs are the main grower | Medium (hook build) |
| 2 | `/clear` on project switch + `/compact` at 60% | L3 (C5) | Eliminates stale cross-project context; earlier compact = smaller baseline | **10–30%** depending on multi-project bloat | Low (behavioral) |
| 3 | `effortLevel: medium` default (never toggle mid-session) | L2 (C5) | Reduces output/thinking tokens (16.6% share) + prevents full cache rebuild on effort change | **5–15%** on output share; prevents rebuild spike | Very low (already in settings.json) |
| 4 | Model stability (pick model once per session) | L2 (C5) | Prevents full cache rebuild on every model switch | Moderate per-switch; high if opusplan in use | Very low (behavioral) |
| 5 | Subagent routing to Sonnet/Haiku (ROUTING.md) | routing (C5) | Subagent cache writes at $0.30/$0.10 vs $0.50/MTok; subagent output at $15/$5 vs $25/MTok | **Subagent share only (~16%)**; savings proportional to routing discipline | Low (already shipping) |
| 6 | `/rewind` instead of stacked corrections | L3 (C5) | Cache-preserving rollback; zero rebuild cost vs /compact rebuild | Per-correction cost avoidance; low absolute impact | Very low (behavioral) |
| 7 | Handover file + `/clear` instead of long-session resume | L3 (C5) | Avoids expensive post-upgrade full re-read of entire history | High per upgrade event | Low (behavioral) |
| 8 | CLAUDE.md ≤ 200 lines; move workflow docs to skills | L3 (C5) | Reduces baseline present in EVERY request × 18x reads | Low (~$1.89 per 1K extra tokens/210 sessions) | Medium |
| 9 | Avoid `opusplan` for frequent plan/execute cycles | — | Prevents model-switch cache rebuild on each toggle | Moderate if opusplan is in use | Very low |
| 10 | Staying under monthly cap (avoid credits regime) | — | Keeps main session TTL at 1h; prevents 5m TTL cold re-creates | Context-dependent; high during cap events | Structural (L0–L3 combined) |

**The critical insight:** Levers 1–4 all target the 87.8% cache share. Lever 5 targets only the 16%
subagent share. This confirms the directive's framing: subagent routing matters but the main-loop
context is the dominant cost driver.

**Quantified ceiling:** If Levers 1–4 cut the cache share by 30%, that's 0.30 × $13,677 = $4,103
saved from the $15,589 main-loop total — a 26% reduction in main-loop spend. The directive's practical
floor of ~$3–5k/month is consistent: much of the cache_creation (~35.9%) represents actual useful
caching (the system prompt and project context are legitimately large); only the conversation-layer growth
from tool outputs is the target.

---

### 7. Subscription Billing Framing — What the Numbers Actually Mean

Source: directive (`2026-06-29-token-cost-optimization.md`); Claude support docs [2024-2026]

`est_cost_usd` in `token-spend.jsonl` = API-equivalent cost at the listed per-token rates. It is **not
an invoice**. On a Claude subscription:

- Usage within the monthly allotment is **included** in the plan price.
- Usage beyond the allotment draws on **overage credits** (real money).
- The monthly cap was hit on 2026-06-29; the following effects cascade:
  1. Main session TTL drops from 1h to 5m automatically.
  2. Credit spend begins per-token.
  3. Cache re-creates on any pause > 5 min now cost real money.

**The true program value is therefore:**
- Keep usage under the allotment → extend the included allotment, no credits consumed.
- When on credits (cap exceeded) → minimize spend per credit dollar; shorter sessions, fewer re-creates,
  lean context.
- Levers still apply; framing shifts from "$/session savings" to "credits consumed per session."

Every lever that reduces cache_read tokens or prevents cache_creation re-creates extends the monthly
allotment AND reduces credit overage when the cap is hit. The ROI framing is correct regardless of
billing model.

---

## Evidence Gaps and Uncertainties

- **Track 1 file not found.** The directive's work queue noted "Track 1 (caching economics) captured"
  but only Track 4 (session/turn hygiene) was present at `~/.claude/research/`. This synthesis draws on
  Track 4 (which contains the actual cost structure data) plus live primary source fetches. The missing
  Track 1 may have been an in-context artifact that wasn't flushed to disk before the cap hit.

- **18x read ratio is a session-average, not a per-turn figure.** The ratio is computed across 210
  sessions. Individual sessions may vary significantly — shorter sessions have lower ratios; long deep
  sessions may approach 30x+. The lever impact estimates are directional, not precise.

- **Tool-output truncation impact (L1) is unverified.** The 20–40% cache share estimate assumes tool
  outputs are a primary driver of context growth. If most growth comes from file reads or conversation
  accumulation, L1's impact is lower. C3 requires the turn-count regression guard to confirm L1 doesn't
  increase re-runs (net-negative outcome).

- **Tokenizer inflation on Opus 4.7/4.8 is unquantified for this account.** The 30% more tokens
  claim is from the official pricing page but no session data comparing 4.6 vs 4.7 token counts exists
  in the current `token-spend.jsonl`. Sessions may show apparent cost increases that are tokenizer
  inflation, not behavioral changes.

- **Subagent 5m TTL impact on routing economics.** The finding that subagents always use 5m TTL
  strengthens the case for Sonnet/Haiku routing (cheaper cache operations). This was not in the
  directive's original routing rationale. Quantification requires knowing how often subagents have
  multi-turn internal loops or pauses > 5 min.

- **Autocompact threshold (83.5% / 33K buffer).** The figure comes from the third-party claudefa.st
  blog, not official docs. Use `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` to control behavior; don't rely on the
  specific threshold.

---

## Paywalled Must-Reads

None. All primary sources are publicly accessible.

---

## Sources Index

| # | Title | URL | Date | Tier |
|---|-------|-----|------|------|
| 1 | Anthropic API: Model pricing (Opus 4.6/4.7/4.8 = $5/$25) | https://platform.claude.com/docs/en/about-claude/pricing | 2026 | [2024-2026] |
| 2 | Claude Code: How Claude Code uses prompt caching | https://code.claude.com/docs/en/prompt-caching | 2026 | [2024-2026] |
| 3 | Claude Code: Manage costs / reduce token usage | https://code.claude.com/docs/en/costs | 2026 | [2024-2026] |
| 4 | Claude Code: Explore the context window | https://code.claude.com/docs/en/context-window | 2026 | [2024-2026] |
| 5 | Track 4 research: Session & turn hygiene (cost structure, 210 sessions) | ~/.claude/research/track4-session-turn-hygiene.md | 2026-06-29 | [2024-2026] |
| 6 | Directive: Token-cost optimization | claude-plugins/docs/plans/directives/2026-06-29-token-cost-optimization.md | 2026-06-29 | [2024-2026] |
| 7 | Anthropic Blog: Prompt caching is everything | https://claude.com/blog/lessons-from-building-claude-code-prompt-caching-is-everything | 2026 | [2024-2026] |
| 8 | GitHub Issue #46829: Cache TTL regression 1h→5m (March 2026) | https://github.com/anthropics/claude-code/issues/46829 | 2026 | [2024-2026] |
| 9 | claudefa.st: Context buffer management (autocompact threshold) | https://claudefa.st/blog/guide/mechanics/context-buffer-management | 2026 | [2024-2026] |
| 10 | Local data: ~/.claude/token-spend.jsonl (210 sessions) | local | 2026-06-29 | [2024-2026] |
