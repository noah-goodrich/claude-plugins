# Research Tools

Research and ideation methodology plugin for Claude Code. Two complementary pipelines covering
the full spectrum from open-ended problem exploration through rigorous evidence synthesis.

## Skills

| Skill | Trigger | When to use |
|-------|---------|-------------|
| `brainstorm` | `/brainstorm` | Open-ended problems where the implementation approach can't be specified before the options are known. Decomposes into parallel research tracks, synthesizes 3–5 distinct solution options, and convenes a 5-persona design council that makes a recommendation. |
| `deep-research` | `/deep-research` | Evidence synthesis with academic rigor. Full pipeline: design, discovery, 10-dimension source evaluation, citation verification, inclusion/exclusion decisions, synthesis, and documentation. Use when you need a defensible evidence base, not just a recommendation. |

## When to use which

```
Need options before you can plan?          → /brainstorm
Need a defensible evidence base?           → /deep-research
Brainstorm track needs academic evidence?  → /brainstorm invokes /deep-research for that track
```

## How they fit together

`/brainstorm` can invoke `/deep-research` for individual tracks that require evidence depth.
The brainstorm output document feeds into `/borg-plan` for implementation planning. The typical
flow for a vague, high-stakes problem is: brainstorm → borg-plan → implementation.

## Fail-Closed Ground Gate

`deep-research` ships with a no-model, deterministic verifier (`hooks/deep-research-verify.sh`)
run by a `Stop` hook (`hooks/deep-research-stop.sh`, registered in `plugin.json`). It physically
blocks a research deliverable from being presented as fact-checked until six falsifiable on-disk
integrity facts pass: (1) a `verification-report.md` exists; (2) §6 carries sample N, failure
count, and a band string; (3) the band is canonical (`≤5%` / `>5%–10%` / `>10%`); (4) the report
records a verifier agent ID distinct from the synthesis agent ID; (5) every source card has the
literal `Access status:` enum line and a `## Verified Quote(s)` heading; (6) no card corrected
during verification is scored `verified`. On any failure the `Stop` hook injects a blocking
`NOT fact-checked — verification gate failed: <reason>` message and refuses to present a PASS.

On a pass the gate prints the badge: **`a distinct verifier agent ran and the files prove it`**.
That badge is deliberately modest. The script is **context-blind, not model-blind**: it proves a
distinct verifier ID was recorded and that a quote exists on the page — it does **not** claim the
verification was "blind," "true," or that the verifier "cannot lie." It cannot prove the
verifier's mind was uninfluenced (out-of-band hint-feeding survives). If Task-tool spawning is
unavailable, the deliverable is stamped `UNVERIFIED — self-check only` and the gate fails rather
than laundering a self-check into a green stamp.

The gate is hard-capped to those integrity facts and never rejects on cosmetic enum-format
nits (spacing/casing that is still semantically the literal enum passes). When in doubt, it passes.

## Evidence-Floor + Confirmation-Skew Banners (advisory)

On top of the hard gate, the same no-model verifier raises two NON-BLOCKING advisory
warnings — they emit `WARN:` lines and a `Warnings:` tally but NEVER change the exit code, so
a clean deliverable that trips a warning still PASSES the hard gate:

- **NO-PRIMARY-EVIDENCE banner (W1).** When the §6 evidence-level distribution shows Level 1
  (systematic review / meta-analysis) and Level 2 (RCT) both at 0, no primary experimental
  evidence was collected. The verifier asserts the verbatim banner
  **`NO PRIMARY EVIDENCE — all findings are literature-derived predictions`** as a warning;
  §2 should carry that exact string. The skill also runs a Phase 2 *evidence-floor
  classifier* — for each cheaply-testable question (UX flow, prompt behavior, API output, the
  household's own data) it PREFERS a direct-observation probe + committed harness (codifying
  the reveal portrait pattern), and declaring a question untestable requires a one-line
  justification in §2 (anti-gaming paper trail).
- **Confirmation skew (W2).** A `>3:1` agree:disagree ratio in the §6 Bias-Guard Summary
  raises a warning and requires a falsification query in the Phase 2 search plan plus a
  "steel-man the contrarian" subsection in Phase 4. The verifier footnotes whichever is
  missing.

These ship as **banners first, blocks later**: they graduate to blocking only after the
Directive 01 gate has fired in production AND the warnings have run clean on ≥2 real
deliverables. Each warning is written to the same ground-ledger-shaped record the hard
assertions read, so promotion is a one-line change with no detection-logic rewrite.

## Scholarly-Source Adapter (optional)

deep-research has no web-scale corpus of its own — discovery rides the host's general
WebSearch/WebFetch. To close the academic-reach gap WITHOUT an unwinnable indexing war and
WITHOUT third-party MCP supply-chain risk in a trust-first pipeline, the plugin ships a thin,
**first-party** HTTP adapter (`hooks/scholarly-adapter.sh`, ~one screen of `curl` + `jq`) that
pulls peer-reviewed abstracts + DOIs + open-access PDF links from a **keyless** scholarly API
into the SAME inspectable source-card pipeline.

- **OpenAlex is the default backend** — 250M+ works, CC0, keyless, not throttled. (It is the
  proof-point that open+transparent beats paid+black-box — it materially defeated paid Scopus,
  the Sorbonne deregistration of Dec 2023.)
- **Semantic Scholar is the documented fallback** — 200M+ papers, keyless but globally
  throttled, so it cannot be the default; use `--backend semanticscholar` for AI/ML/CS queries.
- **Phase 2 routing:** academic/clinical → OpenAlex; AI/ML/CS → Semantic Scholar; general web →
  WebSearch.
- **Backend-agnostic cards.** Pulled results use the standard source-card template with NO
  backend-specific fields, so the corpus stays swappable and the open-corpus advantage never
  becomes new lock-in.
- **Snapshotting.** The adapter writes the abstract AS PULLED to
  `docs/research/snapshots/<card-id>.txt`; the Directive 01 verifier checks each card's verbatim
  quote against that snapshot, consistent with the ground-ledger contract.
- **Optional, no secret.** The pipeline runs unchanged with no scholarly backend configured;
  both backends are keyless, so nothing here adds a hard dependency or a required secret.

**The honest boundary: we are not Elicit-scale; this adds a free academic backend, not a
138M-paper index.** It lifts the cheap-to-card peer-reviewed share (raising the thin
primary-evidence floor) — it does not turn deep-research into a quality-filtered academic
search engine.

## Prior Art

This plugin synthesizes and extends six established source evaluation and research frameworks:

- **CREDIBLE** — 8-component source evaluation (most comprehensive single framework)
- **CRAAP** — Currency, Relevance, Authority, Accuracy, Purpose (widely taught)
- **SIFT** — Stop, Investigate, Find, Trace (process-oriented, web sources)
- **PRISMA** — Systematic review inclusion/exclusion pre-registration
- **RADAR** — Rationale, Authority, Date, Accuracy, Relevance (academic)
- **DeepTRACE** — AI citation audit, 8 reliability dimensions
