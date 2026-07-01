# Directive: Token-Cost Optimization

*Standalone plan (split from 2026-05-27-plugin-marketplace-consolidation on 2026-07-01) — promote to PROJECT_PLAN.md after the marketplace-consolidation plan assimilates.*
*Filed: 2026-06-29*

## Objective

Make Claude Code token spend **measurable** (per agent-type and per-turn), then cut the dominant main-loop cost
through opt-in **structural** levers and **encoded** behavioral defaults — validated by the measurement, not
assumed. Success = a measured drop in main-loop $/session at corrected pricing, with no quality/turn-count
regression.

## Context (corrected baseline)

Verified pricing: **Opus 4.6+ is $5/$25 per MTok, not $15/$75** (the token-cost skill hardcoded the stale Opus 4.1
rate). Recomputed: all-time spend ≈ **$18.5k**; **MAIN loop ≈ $15.4k (84%)** over 34 days; subagents ≈ $3k (16%).
Practical floor with good hygiene ≈ **$3–5k/month**. Cache reads of the growing context dominate; `cache_creation`
(~34%) is structurally useful (it makes reads 10× cheaper). The honest ceiling: much of the 84% is **irreducible**
Opus reasoning over large multi-project context — the durable win is the measurement, which tells real savings from
noise. Expensive sessions concentrate in `ingle`/`reveal`/`troth`/`claude-desktop`, **not** `borg-collective` — so
levers must apply portfolio-wide.

**Billing model (load-bearing correction, 2026-06-30):** This is a Claude **subscription** (`claude.ai/settings/usage`),
NOT per-token API billing. Within the plan allotment, usage is **included** — the `est_cost_usd` figures are an
*API-equivalent estimate*, not an invoice. Real money accrues only on **overage credits** beyond the plan (monthly cap
— hit 2026-06-29). So the program's true value is **staying under the usage allotment + minimizing credit overage +
preserving speed/headroom**, NOT cutting a per-token bill. Every lever (less context, lower effort, cheaper-tier
subagents) reduces *usage consumed*, which extends the allotment and limits overage — still worth doing, just framed
as "use less of the plan," not "$X saved."

## Acceptance Criteria

- [ ] **C1 — Pricing correct, single-source (L0).** SKILL.md table + the hook `rate()` use model-aware rates
  (Opus 4.6+ = $5/$25), defined once.
  - Verify: run the hook on a fixture → `est_cost` matches new rates; a sample `opus-4-8` record computes 3× lower
    than before; `grep` SKILL.md shows the tiered table. *(Shipped: PR #23, 28/28 bats green.)*
- [ ] **C2 — Measurement live.** `subagents.by_type` cost (PR #22) merged **and** a context-growth signal exists
  (per-turn `cache_creation` delta hook, or a transcript "context-bombers" report).
  - Verify: `jq` shows `by_type` in a fresh record; the growth tool ranks tool-calls by cache delta on a sample
    session.
- [ ] **C3 — Truncation hook works & is safe (L1).** Opt-in PostToolUse hook truncates >threshold Bash/Read output
  with a marker stating lines cut + how to get the rest; ≤threshold output is byte-unchanged.
  - Verify: 500-line fixture → truncated + marker; 50-line → unchanged. **Regression guard:** enabling it does not
    raise turn/re-run count on a smoke task.
- [x] **C4 — 1-hour cache TTL: VERIFIED N/A for this account; do NOT set the flag.** Confirmed against
  `code.claude.com/docs/en/prompt-caching`: `ENABLE_PROMPT_CACHING_1H=1` is the **API-key / third-party** lever. On a
  **Claude subscription** (this account), Claude Code **already requests the 1h TTL automatically and free within
  plan**, and intentionally **drops to 5m when over the usage limit / on credits** to cap overage. Forcing the flag
  while over-limit would *raise* credit spend (2× writes). **Decision: leave it unset.** (Real lever for idle-gap cost
  on a subscription = just keep the session active, or accept the 5m drop while on credits.)
- [ ] **C5 — Behavioral defaults encoded (L2/L3/routing).** `effortLevel: medium` default set **at session start**
  (never toggled mid-session — that busts the entire cache), with `/effort high` for planning blocks; CLAUDE.md
  carries compact-retain instructions + `/clear`-on-project-switch guidance; ROUTING.md (shipped in #22) is the
  delegation default (Opus subagents opt-in only).
  - Verify: read settings.json `effortLevel`; `grep` CLAUDE.md for the compact + clear guidance; ROUTING.md present.
- [ ] **C6 — Measured impact (the real test).** Over a 2-week window post-rollout, main-loop $/session (corrected
  pricing) trends down vs the prior 2 weeks, with no rise in turns/task.
  - Verify: `jq` window-vs-window on `token-spend.jsonl`. *If flat → the levers were wrong; revisit.*
- [ ] **C7 — Nothing breaks (regression).** token-cost bats suite green; `token-spend.jsonl` schema additive-only.
  - Verify: run bats; `jq` old + new records share the schema.

## Work queue (status)

| Item | Lever | Status |
|---|---|---|
| Correct token-cost pricing (model-aware `rate()`) | L0 | **DONE** — PR #23 (merge first; then rebase #22 over it) |
| Tiered agent roster + `by_type` cost attribution | measurement | **READY** — PR #22 (review-passed, nits fixed) |
| `ENABLE_PROMPT_CACHING_1H=1` | 1h-TTL | **QUICK WIN** — one-line env change, pending Noah |
| Tool-output truncation hook + context-growth measurement (opt-in) | L1 | **QUEUED** — build hit the monthly spend cap; resume when clear |
| `effortLevel: medium` default at session start (+ `/effort high` for planning) | L2 | **QUEUED** — encode in settings.json; do NOT toggle mid-session |
| CLAUDE.md compact-retain + `/clear`-on-project-switch | L3 | **QUEUED** |
| Routing discipline (delegate to Sonnet/Haiku specialists by default) | routing | **PARTLY** — ROUTING.md shipped in #22; adopt as default behavior |
| Triangulated main-loop research synthesis | research | **QUEUED** — re-run hit the cap; Track 1 (caching economics) captured |
| Backfill `token-spend.jsonl` historical records at corrected rates | L0 follow-up | **OPTIONAL** |
| Update global `~/.claude/CLAUDE.md` stale rate table | L0 follow-up | **OPTIONAL** (outside the plugin) |

## Scope Boundaries

- **NOT** moving the orchestrator itself to Sonnet (Opus-on-demand main loop) — revisit only if measurement shows
  routing dominates **and** levers underdeliver. (Note: `opusplan`-style Opus↔Sonnet toggling is quietly expensive —
  every switch busts the cache.)
- **NOT** optimizing Claude Desktop local-agent-mode here — it may not honor Claude Code hooks; **separate track**.
- **NOT** chasing the irreducible floor — accept ~$3–5k/mo as practical; stop at diminishing returns.
- If done early: ship + measure, don't add levers.

## Ship Definition

Each lever = PR → CI/bats green → merged; behavioral encodings committed; the measurement dashboard producing data;
then the 2-week window runs. The **program** ships when C1–C5 + C7 are merged and C6 has produced a verdict
(down / flat / revisit).

## Timeline

L0 (C1) shipped this session; #22 merge + the env-var + behavioral encodings ≈ 1 short session once the spend cap
clears; L1 build resumes from the queue. Then a 2-week passive measurement tail for C6. ~1–2 sessions of work +
observation.

## Risks

1. **Truncation hides output Claude needs → more re-runs** (net-negative, invisible). Mitigate: opt-in + clear
   markers + the turn-count regression guard (C3). Top risk.
2. **Savings don't materialize** — much of the 84% is irreducible Opus reasoning, and the % estimates came from a
   single un-triangulated synth agent. Mitigate: measurement is load-bearing (C6) — we'll *know*, and revisit if flat.
3. **Behavioral levers decay** (willpower-dependent) and the spend concentrates in app projects + Claude Desktop, not
   borg. Mitigate: encode (settings.json / CLAUDE.md / ROUTING.md) not habit; treat Desktop as a separate coverage track.

## Status note

The 2026-06-29 build/research session hit the **monthly spend cap** (`claude.ai/settings/usage`), which halted the
L1 build, the verifications, and the research synthesis. Those are queued above; resume when the cap clears or is
raised. (Ironically, this session hitting the cap is itself the case for the program.)
