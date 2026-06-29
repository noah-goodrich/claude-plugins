# Research Tools

Research and ideation methodology plugin for Claude Code. One front door — `/research` — routes
to the right pipeline by **mode**, covering the full spectrum from open-ended problem exploration
through rigorous evidence synthesis.

## Skills

| Skill | Trigger | When to use |
|-------|---------|-------------|
| `research` | `/research` | The single research front door. Picks a **mode** at Phase 0 and runs the matching pipeline. |
| `deep-research` | `/deep-research` | Thin alias → `research` in **evidence** mode. |
| `brainstorm` | `/brainstorm` | Thin alias → `research` in **decision-design** mode. |

### The three modes of `/research`

- **evidence** — evidence synthesis with academic rigor. Full pipeline: design, discovery,
  10-dimension source evaluation, citation verification, inclusion/exclusion decisions, synthesis,
  and documentation. Carries an executable citation gate. Use when you need a defensible evidence
  base, not just a recommendation. (This is the original `deep-research` pipeline, unchanged.)
- **decision-design** — open-ended problems where the implementation approach can't be specified
  before the options are known. Walls off prior work, runs parallel from-zero research tracks,
  synthesizes 3–5 distinct options, convenes a 5-persona council, and subjects the recommendation
  to a BLIND adversarial review (`borg-reviewer`). Carries a self-enforced design-review gate.
  (This is the former `brainstorm` design council, absorbed.)
- **hybrid** — evidence first, then decision-design, with the evidence synthesis fed in as
  load-bearing input. The safe superset for high-stakes decisions.

## When to use which

```
"What does the evidence say?"              → /research (evidence)    [or the /deep-research alias]
"What should we build/do?"                 → /research (decision-design) [or the /brainstorm alias]
Both — evidence base, then a decision      → /research (hybrid)
```

## How it fits together

Decision-design and hybrid delegate their research to the `borg-researcher` agent and their
recommendation review to the `borg-reviewer` agent (both Sonnet, lean-return — never
`general-purpose`). The output document feeds into `/borg-plan` for implementation planning. The
typical flow for a vague, high-stakes problem is: research (decision-design or hybrid) → borg-plan
→ implementation.

## Redundancy between the two skills (Directive 04)

The two skills deliberately share machinery, and a few controls used to be DUPLICATED across
them with diverging rigor. Directive 04 collapsed that overlap to a single owner each:

- **Novelty probe ("is this worth a full run?")** lives ONLY in `deep-research` now (Phase 1.0),
  as a universal pre-flight gate for any direct `/deep-research`. It was previously inlined in
  `brainstorm` (firing only for "evidence-backed" tracks, which never fired), so a direct
  `/deep-research` had no "should I even run this?" gate at all. It is promoted to where it
  belongs.
- **Evidence rigor / freshness** is OWNED by `deep-research`. `brainstorm` no longer runs a
  second, lower-rigor research pipeline. Its tracks return ONE unified finding shape (a discrete
  claim + a minimal source record: author/outlet, title, URL, access date) — the same minimal
  evidentiary record a deep-research source card carries — so one brainstorm no longer carries
  two incompatible evidentiary standards side by side. The old ~85-line evidence-backed-track /
  recency-band / recursive-`/deep-research` apparatus (0% utilization across the corpus) is
  demoted to a single escape-hatch line: *if a track's correctness is load-bearing and your
  model knowledge is stale, run `/deep-research` separately and feed its §1–§2 back in.*
- **Triage screen + rapid tier + lazy reference loading** (below) are `deep-research`
  mechanisms; `brainstorm` reaches them only via the escape hatch.

Net: `brainstorm` stays fast and owns option-generation + the council; `deep-research` owns
evidence rigor, verification, and the freshness probe. There is no longer a parallel
mini-pipeline in `brainstorm`.

## Triage Screen + Rapid Tier + Lazy Loading (Directive 04)

`deep-research` no longer taxes every run with an all-or-nothing protocol:

- **Triage screen (Phase 3.0).** A fast keep/cut screen runs against ALL discovered sources
  first (on-topic? minimally credible? non-redundant?); full 10-dimension source cards are
  written ONLY for the survivors. The inclusion cut moves BEFORE the expensive scoring instead
  of after it.
- **Rapid tier (Phase 1.1).** A documented low-stakes mode with HONEST reduced guarantees. It
  caps the deliverable at **§1 + §2 + §5 + a short methodology note**, runs no independent
  Phase 3.5 verification, and stamps the artifact `UNVERIFIED — self-check only` and `NOT
  INDEPENDENTLY VERIFIED` — the SAME honest-fallback vocabulary as the Directive 01 gate, so the
  verifier **never prints `Gate result: PASS` on a rapid run** (it carries no distinct verifier
  ID, so Assertion 4 fails it by design). The full §1–§7 manifest fires only for high-stakes /
  external-publication runs. Document size is tied to decision size.
- **Lazy reference loading.** The mandatory ~14k-token up-front pre-load wall is removed. Only
  the card-field skeleton and the §1–§7 outline carry inline; each reference loads at the phase
  that consumes it (per the skill's Quick Reference lazy-load map).

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
