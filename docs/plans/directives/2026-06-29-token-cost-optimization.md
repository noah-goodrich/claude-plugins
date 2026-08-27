# Directive: Token-Cost Optimization

*Standalone plan (split from 2026-05-27-plugin-marketplace-consolidation on 2026-07-01) — promote to PROJECT_PLAN.md after the marketplace-consolidation plan assimilates.*
*Filed: 2026-06-29*

**Status (reconciled 2026-08-27): PARTIALLY SHIPPED — 3 of 7 criteria met (C1, C3, C4). Keep open for C6.**
All three build PRs landed on `main` — [#22](https://github.com/noah-goodrich/claude-plugins/pull/22) (`236ea49`,
merged 2026-06-30), [#23](https://github.com/noah-goodrich/claude-plugins/pull/23) (`7755008`, merged 2026-06-30),
[#24](https://github.com/noah-goodrich/claude-plugins/pull/24) (`463835c`, merged 2026-07-01). The spend cap that
halted the 2026-06-29 session cleared long ago; the work resumed and shipped. The truncation hook went from built to
**live on 2026-08-26**. What remains genuinely unbuilt: the **context-growth reporter** (C2 second half) and the
**CLAUDE.md compact/`/clear` guidance** (C5 third clause). C6's measurement window could not have run before
2026-08-26 and has produced no verdict. The marketplace-consolidation plan has assimilated, so the promote-to-
PROJECT_PLAN.md precondition in the header is satisfied — the promotion was simply never done.

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

- [x] **C1 — Pricing correct, single-source (L0).** SKILL.md table + the hook `rate()` use model-aware rates
  (Opus 4.6+ = $5/$25), defined once.
  - Verify: run the hook on a fixture → `est_cost` matches new rates; a sample `opus-4-8` record computes 3× lower
    than before; `grep` SKILL.md shows the tiered table. *(Shipped: PR #23, 28/28 bats green.)*
  - **Verified 2026-08-27.** `git merge-base --is-ancestor 7755008 main` → LANDED;
    `gh pr view 23` → `MERGED 2026-06-30T18:27:37Z`. `token-cost/hooks/token-spend-log.sh` `_costof()` defines
    `rate(m)` with the tier order `fable|mythos` → `opus-4-[6-9]` ($5/$25/$6.25/$0.50) → generic `opus` ($15/$75)
    → `sonnet` → `haiku`, so 4.6+ resolves 3× lower than pre-4.6 Opus. `token-cost/skills/token-cost/SKILL.md`
    lines 46–52 carry the matching tiered table. **Known deviation:** "defined once" is not literally true — the
    rates live in two places (the SKILL.md prose table and the hook's jq `rate()`). They agree today, and both
    Verify steps pass, but there is no shared source file, so the two can drift.
- [ ] **C2 — Measurement live.** `subagents.by_type` cost (PR #22) merged **and** a context-growth signal exists
  (per-turn `cache_creation` delta hook, or a transcript "context-bombers" report).
  - Verify: `jq` shows `by_type` in a fresh record; the growth tool ranks tool-calls by cache delta on a sample
    session.
  - **Half met — first clause yes, second clause NOT BUILT (2026-08-27).** `by_type` shipped:
    `gh pr view 22` → `MERGED 2026-06-30T18:29:17Z`, `git merge-base --is-ancestor 236ea49 main` → LANDED, and
    `jq` over `~/.claude/token-spend.jsonl` shows 580 of 795 records at `schema: 2` carrying `subagents.by_type`.
    The **context-growth signal does not exist**: `token-cost/scripts/` contains only `backfill-spend.sh` (which
    predates this directive — PR #13, `a664ca3`), and a repo-wide grep for `context-bomber|context.growth|cache
    delta` hits nothing but prose in `docs/research/.../caching-economics-synthesis.md`. This is the one genuinely
    unbuilt deliverable in the directive. Stays `[ ]`.
- [x] **C3 — Truncation hook works & is safe (L1).** Opt-in PostToolUse hook truncates >threshold Bash/Read output
  with a marker stating lines cut + how to get the rest; ≤threshold output is byte-unchanged.
  - Verify: 500-line fixture → truncated + marker; 50-line → unchanged. **Regression guard:** enabling it does not
    raise turn/re-run count on a smoke task.
  - **Verified 2026-08-27 — built AND now live.** `gh pr view 24` → `MERGED 2026-07-01T03:34:38Z`;
    `git merge-base --is-ancestor 463835c main` → LANDED. `token-cost/hooks/truncate-tool-output.sh` gates on
    `TRUNCATE_TOOL_OUTPUT=1`, cuts Bash/Read output over `TRUNCATE_TOOL_OUTPUT_MAX_LINES` (default 200) to
    head 120 + tail 40, and emits a marker naming the omitted-line count and the retrieval hint
    (`grep / head -n / sed -n 'A,Bp'`). 13 bats cases in `hooks/test/truncate-tool-output.bats` cover exactly the
    two Verify fixtures — "over threshold: 500-line Bash output is replaced + valid JSON + marker" and
    "under threshold: 50-line output → no hook output (byte-unchanged)" — plus four fail-safe cases; all pass.
  - **Enablement (new, 2026-08-26):** the hook is no longer merely opt-in-available, it is **switched on**.
    `jq '.env, .hooks.PostToolUse' ~/.claude/settings.json` → `"TRUNCATE_TOOL_OUTPUT": "1"` and a PostToolUse
    entry with `"matcher": "Bash|Read"` running
    `$HOME/dev/claude-plugins/token-cost/hooks/truncate-tool-output.sh` (timeout 10). settings.json mtime is
    `Aug 26 04:38`, matching the reported enablement date.
  - **Caveat — the turn-count regression guard was never measured.** No smoke-task turn/re-run comparison is
    recorded anywhere. Since 2026-08-26 the hook is live in the default path, so that guard is now observable but
    unevaluated; it folds into C6's window. The checkbox reflects the criterion's stated claim ("works & is safe"),
    which the 13 tests do establish — it does not assert the regression guard was run.
- [x] **C4 — 1-hour cache TTL: VERIFIED N/A for this account; do NOT set the flag.** Confirmed against
  `code.claude.com/docs/en/prompt-caching`: `ENABLE_PROMPT_CACHING_1H=1` is the **API-key / third-party** lever. On a
  **Claude subscription** (this account), Claude Code **already requests the 1h TTL automatically and free within
  plan**, and intentionally **drops to 5m when over the usage limit / on credits** to cap overage. Forcing the flag
  while over-limit would *raise* credit spend (2× writes). **Decision: leave it unset.** (Real lever for idle-gap cost
  on a subscription = just keep the session active, or accept the 5m drop while on credits.)
  - **Re-verified 2026-08-27 — decision still in force.** `jq -r '.env | keys[]' ~/.claude/settings.json` returns
    only `DISABLE_AUTOUPDATER` and `TRUNCATE_TOOL_OUTPUT`; `ENABLE_PROMPT_CACHING_1H` is absent, as decided.
- [ ] **C5 — Behavioral defaults encoded (L2/L3/routing).** `effortLevel: medium` default set **at session start**
  (never toggled mid-session — that busts the entire cache), with `/effort high` for planning blocks; CLAUDE.md
  carries compact-retain instructions + `/clear`-on-project-switch guidance; ROUTING.md (shipped in #22) is the
  delegation default (Opus subagents opt-in only).
  - Verify: read settings.json `effortLevel`; `grep` CLAUDE.md for the compact + clear guidance; ROUTING.md present.
  - **Two of three clauses met (2026-08-27); stays `[ ]` on the third.**
    (a) `jq '.effortLevel' ~/.claude/settings.json` → `"medium"` — **met**.
    (b) ROUTING.md present — `borg-collective/agents/ROUTING.md`, 75 lines, and
    `git show --stat 236ea49` confirms PR #22 added it alongside `borg-grunt.md` / `borg-scout.md` and the effort
    pins on `borg-nanoprobe` / `borg-researcher` / `borg-reviewer` — **met** as an artifact.
    (c) **CLAUDE.md compact-retain + `/clear`-on-project-switch guidance is ABSENT.**
    `grep -niE 'compact|/clear|project.switch|retain' ~/.claude/CLAUDE.md` returns a single unrelated hit — the
    Session Continuity handover pointer ("If a previous session was compacted…"), which is not compact-retain
    instruction and says nothing about `/clear` on project switch. Not written.
- [ ] **C6 — Measured impact (the real test).** Over a 2-week window post-rollout, main-loop $/session (corrected
  pricing) trends down vs the prior 2 weeks, with no rise in turns/task.
  - Verify: `jq` window-vs-window on `token-spend.jsonl`. *If flat → the levers were wrong; revisit.*
  - **NOT MET, and not yet evaluable (2026-08-27).** No verdict is recorded anywhere — a grep across `docs/` for a
    C6 / window-vs-window result finds nothing. The window also cannot have run: the last lever only went live on
    2026-08-26 (C3 enablement), one day ago. For the record, the pre-enablement trend is **up, not down** —
    `jq -s` over `~/.claude/token-spend.jsonl` gives 2026-08-13→27 = 25 sessions / $11,806.77 ≈ **$472/session**
    vs 2026-07-30→08-13 = 41 sessions / $5,375.46 ≈ **$131/session**. That window predates the truncation hook, so
    it does **not** test the levers — it does show the program has no measured win yet. The real C6 window runs
    ~2026-08-26 → 2026-09-09.
- [ ] **C7 — Nothing breaks (regression).** token-cost bats suite green; `token-spend.jsonl` schema additive-only.
  - Verify: run bats; `jq` old + new records share the schema.
  - **Second clause met, first clause currently RED on this machine (2026-08-27). Stays `[ ]`.**
    Schema additivity holds: `jq` bucketing all 795 records gives `schema 2` × 580 and `schema 1` × 215, and
    *every* record in both carries `subagents.by_model`, `subagents.agent_count` and `est_cost_usd` —
    `by_type` appears only in schema 2. Purely additive, as required.
    **But `bats token-cost/hooks/test/` now fails 1 of 53** — test 41, *"opt-in: disabled (env unset) → exits 0,
    no output even for 500 lines"*. The test runs the hook without unsetting the variable, so it inherits the
    real `TRUNCATE_TOOL_OUTPUT=1` that C3's 2026-08-26 enablement put in `settings.json`, the hook correctly
    truncates, and the assertion `[ -z "$output" ]` fails. `env -u TRUNCATE_TOOL_OUTPUT bats token-cost/hooks/test/`
    → **53/53 green**. So this is a test-isolation defect, not a product defect — but it is a real regression
    *caused by* shipping C3, and the suite is not green as the criterion is written. Fix: have the test run
    `env -u TRUNCATE_TOOL_OUTPUT bash "$HOOK"` rather than assuming an unset environment.

## Work queue (status — reconciled 2026-08-27)

The pre-reconciliation version of this table was written mid-session on 2026-06-29, before the spend cap cleared,
and was never updated. It **under-claimed badly**: three items marked READY/QUEUED had in fact shipped, and one
"QUICK WIN" had already been formally rejected by C4. Corrected below; every PR and commit reference is preserved.

| Item | Lever | Status |
|---|---|---|
| Correct token-cost pricing (model-aware `rate()`) | L0 | **DONE** — [#23](https://github.com/noah-goodrich/claude-plugins/pull/23) merged 2026-06-30, `7755008` on `main` |
| Tiered agent roster + `by_type` cost attribution | measurement | **DONE** (was "READY") — [#22](https://github.com/noah-goodrich/claude-plugins/pull/22) merged 2026-06-30, `236ea49` on `main`; 580 records carry `by_type` |
| `ENABLE_PROMPT_CACHING_1H=1` | 1h-TTL | **WON'T DO** (was "QUICK WIN — pending Noah") — superseded by C4: the flag is API-key-only and would *raise* credit spend on a subscription. Verified still unset. |
| Tool-output truncation hook (opt-in) | L1 | **DONE + LIVE** (was "QUEUED") — [#24](https://github.com/noah-goodrich/claude-plugins/pull/24) merged 2026-07-01, `463835c` on `main`; **enabled in `~/.claude/settings.json` 2026-08-26** (`TRUNCATE_TOOL_OUTPUT=1`, PostToolUse `Bash|Read`) |
| Context-growth measurement (cache-delta / "context-bombers" report) | L1 | **NOT BUILT** — the one genuinely unbuilt deliverable; `token-cost/scripts/` holds only `backfill-spend.sh`. Blocks C2. |
| `effortLevel: medium` default at session start (+ `/effort high` for planning) | L2 | **DONE** (was "QUEUED") — `settings.json` `effortLevel: "medium"` |
| CLAUDE.md compact-retain + `/clear`-on-project-switch | L3 | **NOT DONE** — confirmed absent from `~/.claude/CLAUDE.md`. Blocks C5. |
| Routing discipline (delegate to Sonnet/Haiku specialists by default) | routing | **PARTLY** — ROUTING.md shipped in #22 (`borg-collective/agents/ROUTING.md`, 75 lines) + effort pins on three agents; adoption-as-default-behavior is unmeasured |
| Triangulated main-loop research synthesis | research | **STILL PARTIAL** — only Track 1 survives: `docs/research/2026-06-29-token-cost-optimization/caching-economics-synthesis.md`. No other tracks were ever run. |
| Fix `truncate-tool-output.bats` test 41 env-isolation failure | regression | **NEW, OPEN** — surfaced by the 2026-08-26 enablement; suite is 52/53 unless `TRUNCATE_TOOL_OUTPUT` is unset. Blocks C7. |
| Backfill `token-spend.jsonl` historical records at corrected rates | L0 follow-up | **OPTIONAL, NOT RUN** — the tool exists (`token-cost/scripts/backfill-spend.sh`, from PR #13 `a664ca3`) but 215 schema-1 records remain un-recomputed |
| Update global `~/.claude/CLAUDE.md` stale rate table | L0 follow-up | **MOOT** — CLAUDE.md carries no rate table of its own; it `@`-references the plugin SKILL.md, which #23 already corrected |

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

*Original (2026-06-29):* L0 (C1) shipped this session; #22 merge + the env-var + behavioral encodings ≈ 1 short
session once the spend cap clears; L1 build resumes from the queue. Then a 2-week passive measurement tail for C6.
~1–2 sessions of work + observation.

*Actual (reconciled 2026-08-27):* C1 and the #22 merge landed 2026-06-30, the day after filing — on schedule. The
truncation hook landed 2026-07-01. Then the directive went quiet for **eight weeks**: the hook sat merged but
disabled until someone turned it on 2026-08-26. The env-var item was never needed (C4 killed it). What slipped is
the un-glamorous remainder — the context-growth reporter and three lines of CLAUDE.md guidance — neither of which
was ever started. The C6 measurement tail therefore starts ~2026-08-26, not early July, and reports ~2026-09-09.

## Risks

1. **Truncation hides output Claude needs → more re-runs** (net-negative, invisible). Mitigate: opt-in + clear
   markers + the turn-count regression guard (C3). Top risk.
2. **Savings don't materialize** — much of the 84% is irreducible Opus reasoning, and the % estimates came from a
   single un-triangulated synth agent. Mitigate: measurement is load-bearing (C6) — we'll *know*, and revisit if flat.
3. **Behavioral levers decay** (willpower-dependent) and the spend concentrates in app projects + Claude Desktop, not
   borg. Mitigate: encode (settings.json / CLAUDE.md / ROUTING.md) not habit; treat Desktop as a separate coverage
   track.
   - **This risk materialized (2026-08-27).** The two encodings that were a *file edit* got done and stuck
     (`effortLevel: medium`, ROUTING.md). The one that needed someone to sit down and write guidance prose — the
     CLAUDE.md compact-retain + `/clear` clause — was never written, eight weeks on. The mitigation was right; it
     just wasn't applied to the last item. Risk 2 is also still open: C6 has produced no verdict, so we still do
     not *know* whether the savings materialized.

## Status note

*Original (2026-06-29, now historical):* The 2026-06-29 build/research session hit the **monthly spend cap**
(`claude.ai/settings/usage`), which halted the L1 build, the verifications, and the research synthesis. Those are
queued above; resume when the cap clears or is raised. (Ironically, this session hitting the cap is itself the case
for the program.)

*Superseding note (2026-08-27):* The cap cleared and the L1 build **did** resume and ship — #24 merged 2026-07-01.
The blocker described above has not applied for roughly two months; only the research synthesis genuinely remains
un-rerun. Treat the paragraph above as a record of why the original session stopped, not as current status.

## Reconciliation summary (2026-08-27)

Verified with `git merge-base --is-ancestor`, `gh pr view`, `bats`, and `jq` over `~/.claude/token-spend.jsonl` and
`~/.claude/settings.json`.

| Criterion | Verdict | One-line reason |
|---|---|---|
| C1 — pricing correct | **MET** | #23 on `main`; tiered `rate()` + matching SKILL.md table. Rates duplicated across two files (drift risk). |
| C2 — measurement live | **HALF** | `by_type` shipped in #22; context-growth reporter does not exist. |
| C3 — truncation hook | **MET** | #24 on `main`; 13 bats cases; live in settings.json since 2026-08-26. Turn-count guard unmeasured. |
| C4 — 1h cache TTL N/A | **MET** | Decision holds; flag confirmed unset. |
| C5 — behavioral defaults | **PARTIAL** | `effortLevel: medium` ✓, ROUTING.md ✓, CLAUDE.md compact/`/clear` guidance ✗. |
| C6 — measured impact | **NOT MET** | No verdict recorded; window only starts 2026-08-26. Pre-rollout trend is up. |
| C7 — nothing breaks | **NOT MET** | Schema additive ✓, but bats is 52/53 in the live env (test-isolation defect from C3's enablement). |

**Recommendation: keep open.** Per the Ship Definition this program ships when C1–C5 + C7 are merged and C6 has
produced a verdict. Three of the four gaps are small and concrete — the CLAUDE.md guidance is three lines, the bats
fix is one `env -u`, and C6 is passive observation that needs only a `jq` run after 2026-09-09. The one real build
left is the context-growth reporter. Do not archive: C6 is the criterion the whole directive was designed around,
and it has not yet been allowed to run.
