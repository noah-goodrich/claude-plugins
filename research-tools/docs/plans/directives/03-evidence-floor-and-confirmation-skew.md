# Directive 03 — Evidence-Floor + Confirmation-Skew (Banner First, Block Later)

**Priority:** 03 · **Axis:** (b) Methodological depth · **Feasibility:** High (banner) / softer (block)
**Depends on:** Directive 01 (the gate must publicly fire before either of these ever blocks)

---

## Goal

Raise what "verify" means from citation-presence to grounding-against-reality by adding a Phase 2 evidence-floor and a
confirmation-skew gate — shipped as **non-blocking banners first** so they earn trust on real corpus runs before they
are ever allowed to fail a deliverable.

## Context (audit findings resolved)

- **Pattern 1 — thin primary evidence: a literature-and-blog machine, not an observation machine**
  (`audit.md:305-325`). True primary experimental evidence is 14% (troth), 15% (personalization), **0%** (eating-out,
  agent-teams); the only
  original ground-truth observation in the entire sampled corpus is a single n=1 informal test (reveal portrait). The
  SOTA framework is blunt: verification requires an **EXTERNAL signal** — "if the model checks itself, you have built a
  confident hallucination machine" (`analysis.md:204-206`; §3, Theme G). And the reveal portrait proves breaking the
  pattern pays: its one n=1 in-environment test (21 live calls, MAE 3.32/255) reframed the whole recommendation away
  from the published-consensus default — but by hand, because the skill never asks (`audit.md:98-106,319-325`).
- **Bias-guard summaries honestly expose a confirmation skew the methodology cannot correct** (`audit.md:248-259`).
  Agree:disagree ratios run 10:2, 27:3, 26:12, 19:8; eating-out names the mechanism — "the questions extend an
  already-believed framework rather than testing it" — and priors compound because each project carries forward the
  previous one's conclusions. Because the same agent scores the source AND decides whether it "agreed," the guard is
  self-graded confirmation bias with a paper trail.

This is the audit's recommendation #4 and #5 (`audit.md:423-432`). The council's MVV explicitly **cut HALF 2 from the
blocking path**: the testability classifier is itself an honor-system escape hatch (a tired agent declares everything
untestable, relocating the lie from "I verified" to "this wasn't testable"). So this ships as a banner and a footnote
first; it may only graduate to a blocking gate after the Directive 01 gate has publicly fired and the banner has run
clean on real deliverables.

## Acceptance Criteria

- [ ] **Phase 2 evidence-floor classifier**: for each research question, classify whether it is cheaply testable
      in-environment (UX flow, prompt behavior, API output, the household's own data).
- [ ] When a question is testable, the §2 output **PREFERS at least one direct-observation artifact** (a probe +
      committed harness, codifying the reveal portrait pattern) — but absence does **not block** in this directive; it
      surfaces in §2.
- [ ] When no primary evidence was collected, §2 carries the **verbatim banner**: `NO PRIMARY EVIDENCE — all findings
      are literature-derived predictions`. The exact string is asserted by the verifier as a non-blocking warning.
- [ ] **Confirmation-skew gate**: a `>3:1` agree:disagree ratio in the Bias-Guard Summary triggers (a) a falsification
      query required in the Phase 2 search plan and (b) a mandatory `steel-man the contrarian` subsection in Phase 4.
      Reported as a footnote/warning first, **not** a hard block (`audit.md:429-432`).
- [ ] All new checks ride the **same no-model verifier** from Directive 01 as **warnings** (non-zero advisory, not a
      hard fail) and write to a ground-ledger-shaped record so they can be promoted to blocking later without rewrite.
- [ ] A documented promotion path: these become blocking only after (a) the Directive 01 gate has fired in production
      and (b) the banner/skew warnings have run clean on ≥2 real deliverables — recorded as a follow-on note, not done
      here.
- [ ] Testability classifier carries an explicit anti-gaming note: declaring a question untestable requires a one-line
      justification in §2 (so the escape hatch leaves a paper trail), per the council's absorbed dissent.
- [ ] Run against eating-out (0% primary, 27:3 skew) and agent-teams (0% primary, 10:2 skew) fixtures → both surface
      the banner and the skew warning.
- [ ] All tests run inside the devcontainer via `drone exec`.

## Estimate

**1–1.5 sessions.** ~0.5 session: the Phase 2 evidence-floor classifier + banner string + verifier warning assertion.
~0.5–1 session: the confirmation-skew ratio check + the Phase 2 falsification-query and Phase 4 steel-man subsection
prose, tested against the eating-out/agent-teams fixtures.
