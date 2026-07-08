---
name: research
description: "The single research front door. Routes to one of three modes — evidence (cited
  literature synthesis), decision-design (explore options and recommend), or hybrid (evidence
  then design). Use when the user asks for deep research, a literature review, source evaluation,
  or evidence synthesis (→ evidence mode); to ideate, explore approaches, brainstorm, or solve an
  open design problem with no obvious answer (→ decision-design mode); or says /research,
  /deep-research, or /brainstorm. Also trigger when building a defensible evidence base or making
  a high-stakes product/design decision."
---

# Research — The Research Front Door

Three modes, kept separate. Pick one at Phase 0:

- **evidence** — cited literature-synthesis pipeline with executable citation gate.
- **decision-design** — explore an open problem, generate neutral options, recommend one, blind-review it.
- **hybrid** — evidence first, then decision-design, with evidence as load-bearing D2 input.

## Phase 0: Mode Selection (run FIRST, always)

| If the goal is… | Mode | Section |
|---|---|---|
| "What does the evidence say?" — cited, fact-checked synthesis | **evidence** | [Evidence Mode](#evidence-mode-phases-16) |
| "What should we build/do?" — explore options for an open problem | **decision-design** | [Decision-Design Mode](#decision-design-mode) |
| Both — establish evidence base, then decide what to do | **hybrid** | [Hybrid Mode](#hybrid-mode) |

**Routing rules:**
- `/deep-research` → **evidence**. `/brainstorm` → **decision-design**. `/research` → use table above;
  if genuinely ambiguous ask ONE clarifying question, then proceed.
- High-stakes and unsure between evidence vs. decision-design → **hybrid** (safe superset).
- Decision-design and hybrid delegate research to `borg-researcher` agent (Sonnet, lean-return) and
  review to `borg-reviewer` agent. Never use `general-purpose` for this work.

---

## Evidence Mode (Phases 1–6)

**Reading-Deliverable Standard is MANDATORY** (four clauses): first line `Generated: YYYY-MM-DD`;
ELI10 + Glossary + `noah-voice` then `ai-scoring` ≥ 75 (record `AI-scoring: NN/100`); epub by
default via pandoc; markdown in repo, epub to `~/Documents/Claude/<Project>/`. A defensible-but-
unreadable report is a failed deliverable.

## Before You Begin — Lazy Reference Loading

References load at the phase that consumes them — NOT all up front.

**Two things carry inline — read them now:**

1. **Card-field skeleton** (every source card must include all of these fields in order):
   Full citation · URL · Date accessed · Evidence level · Research topic area ·
   10-dimension Credibility Scores table · Score band (`keep`/`borderline`/`reject`) ·
   Bias Guard Check · Key Findings · `## Verified Quote(s)` + Location reference ·
   `Access status:` (`live` / `cached/partial` / `inaccessible`) · Inclusion Decision ·
   `Perspective category:` (exactly one of: `Academic` / `Institutional` / `Practitioner` /
   `Boots-on-the-ground` / `Contrarian`). Full template: `references/source-card-template.md` —
   load at Phase 3.

2. **§1–§7 deliverable outline** (exact order):
   `## 1. Recommendations` · `## 2. Summary` · `## 3.` [Framework, if applicable] ·
   `## 4. Analysis` · `## 5. Research` · `## 6. Methodology` · `## 7. Bibliography`.
   Full template: `references/research-document-template.md` — load at Phase 6.

**Lazy-load map — load each reference at the phase that consumes it:**

| I need to… | Load… | At phase |
|---|---|---|
| See a worked example (optional) | `example-evaluation.md` | Phase 1 (optional) |
| Classify evidence type | `evidence-hierarchy.md` | Phase 2 / Phase 3 |
| Triage keep/cut, then score a source | `source-evaluation-rubric.md` | Phase 3 |
| Fill out a source evaluation card | `source-card-template.md` | Phase 3 |
| Decide keep/throw (final inclusion) | `inclusion-decision-matrix.md` | Phase 4 |
| Structure the final document | `research-document-template.md` | Phase 6 |
| Write the methodology section | `methodology-section-template.md` | Phase 6 |

---

## Phase 1: Research Design

### Phase 1.0: Novelty probe — "is this worth a full run?" gate

Run this FIRST. Execute 2–3 targeted searches:
1. `"[topic]" after:[date-of-any-existing-research]` — if prior research on disk exists.
2. `"[topic]" 2025 OR 2026 new research OR update`.
3. One domain-specific probe (framework changelog for tech topics; new-study framing for
   behavioral/clinical topics).

**Early termination.** If the probe surfaces nothing materially new and prior research or model
knowledge already answers the question, STOP. Tell the user: "Novelty probe: no significant new
developments found since [date]. Full deep-research not warranted. Answering from [existing doc /
model knowledge]; run the full pipeline only if you need a fresh defensible evidence base."

Proceed only if the probe finds new, updated, or conflicting information — or no prior research exists and the question genuinely needs an evidence base.

### Phase 1.1: Stakes / tier selection

Choose the tier BEFORE designing. Confirm with the user at the Phase 1 checkpoint.

- **rapid tier** — low-stakes, ≤~4 candidate sources, internal/reversible, or tight time budget.
  Deliverable: **§1 + §2 + §5 + short methodology**, stamped `UNVERIFIED — self-check only`.
- **full tier** — high-stakes, externally published, costly/irreversible, or contested evidence base.
  Deliverable: **complete §1–§7 manifest** with independent Phase 3.5 verification subagent.

### Phase 1.2: Design

Define all of the following before searching:
1. **Research questions** — 1–3 explicit questions.
2. **Scope boundaries** — in-scope list and explicit out-of-scope list.
3. **Topic map** — domains and subtopics; 1–2 questions per subtopic.
4. **Inclusion/exclusion criteria** — PRISMA-style pre-registration: source types, date ranges,
   geographies, languages. Define before searching.
5. **Target audience** — expertise level and what they need.
6. **Output structure** — confirm with the user before proceeding.

**Checkpoint:** Present the research design for user validation before Phase 2. Do not search until
confirmed.

---

## Rapid Tier — Honest Reduced Guarantees

The rapid tier produces a smaller compliant artifact, not a quietly non-compliant full one.

**What rapid keeps:**
- Phase 1.0 novelty probe and Phase 1.2 design.
- Phase 2 discovery and Phase 3 triage screen.
- Full 10-dimension source cards only for sources that pass triage.
- Deliverable capped at **§1 Recommendations + §2 Summary + §5 Research + a short methodology note**
  (search-log + triage in/out log + the honest stamps). §3, §4, §6 (full), and §7 are NOT produced.

**What rapid honestly gives up:** independent Phase 3.5 verification. Therefore:
- Stamp the artifact `UNVERIFIED — self-check only` in BOTH §2 Summary AND the short methodology note.
- Stamp the artifact `NOT INDEPENDENTLY VERIFIED` in §2 so a reader sees it at a glance.
- Never fabricate a verifier ID. Record that no distinct verifier agent ran.
- The executable gate correctly fails a rapid run as `NOT fact-checked` — that is the honest, intended
  outcome. A rapid artifact does not pretend to be fact-checked.

To upgrade to full tier: produce §3/§4/§6/§7 and run the Phase 3.5 verification subagent.

---

## Phase 2: Source Discovery

Goal: BREADTH first, DEPTH second.

**Required source diversity.** For each major topic area, actively seek from all 5 categories:
1. **Academic** — peer-reviewed research, university publications, working papers
2. **Institutional** — government agencies, professional bodies, established financial orgs
3. **Practitioner** — advisors, coaches, tool builders, counselors who do the work daily
4. **Boots-on-the-ground** — forums, personal blogs, community experience, real households
5. **Contrarian** — voices that challenge the mainstream consensus

**Search strategy:** Minimum 3 queries per subtopic. Vary framing: factual, evaluative, contrarian,
experiential. Log every search query in the methodology section.

**Triangulation rule:** No claim can rest on a single source type. Non-negotiable. Stop when new
searches return already-seen sources AND all 5 categories have representation per topic area.

**Scholarly adapter (optional).** For academic/clinical questions, `hooks/scholarly-adapter.sh` pulls
peer-reviewed abstracts + DOIs into the standard source-card pipeline (both backends are keyless):
- Academic / clinical → OpenAlex (default). `hooks/scholarly-adapter.sh search "<query>" --topic <area>`.
- AI / ML / CS → Semantic Scholar (fallback; globally throttled). Add `--backend semanticscholar`.
- General web → WebSearch / WebFetch (always available; adapter is additive, not required).

Adapter-pulled cards use the STANDARD template; `## Verified Quote(s)` is a verbatim span of the
snapshotted abstract; Phase 3.5 verifier checks it exactly as any web card.

**Evidence-floor classifier.** Before finishing Phase 2, classify each question: is it cheaply testable
in-environment (UX flow, prompt behavior, API output, household data)?
- **Cheaply testable** → prefer at least one direct-observation artifact. If absent, surface in §2.
- **Declared untestable** → requires a one-line justification in §2 (e.g., "Q3 depends on multi-week
  household behavior we cannot observe in this session").

**Confirmation-skew remediation.** If the Bias-Guard Summary ends up skewed `>3:1` agree:disagree,
the Phase 2 search plan MUST include at least one deliberate FALSIFICATION query framed to find
evidence the thesis is WRONG ("counterexamples to X," "evidence X fails," "when X backfires"). Log it
in the search-log table. The executable gate footnotes its absence (warning W2).

**Paywall surfacing.** If you encounter high-value paywalled sources, STOP and write
`docs/research/[date]/drafts/paywalled-candidates.md` — for each: full citation/URL · paywall
publisher · estimated procurement cost ("unknown" if discovering price requires registering; do NOT
register) · specific claim it supports or refutes (vague justifications are non-compliant). Ping the
user for a procurement decision before completing Phase 2. Document excluded paywalled sources in §6
Methodology Limitations (citation + reason for exclusion). If zero found: note "Paywall scan: no high-value paywalled candidates
identified" in §6 Methodology Source Discovery subsection. Do NOT create an empty file.

---

## Phase 3: Source Evaluation

### Phase 3.0: Triage screen — fast keep/cut BEFORE expensive scoring

Apply a fast keep/cut screen to ALL discovered sources first; write full 10-dimension cards only for
sources that pass.

For each source, spend ~15 seconds on three questions:
1. **On-topic?** Addresses a research question or subtopic? If not → **cut** (note in search log).
2. **Minimally credible?** Author/outlet plausibly authoritative? Content-farm/SEO-spam → **cut**.
3. **Non-redundant?** Adds something an already-kept source does not? If dominated → **cut**.

Source clearing all three: **kept for full evaluation**. Source failing any one: **triaged out** — log
in §6 with a one-line reason; no card. In the **rapid tier**, card only the few survivors.

### Phase 3.1: Full source evaluation

For every source that PASSED triage, complete a source evaluation card (`references/source-card-template.md`)
and write it to disk at `[project]/docs/research/sources/<topic>-<slug>.md`.

**Gate-arm marker.** Write the deliverable directory's absolute path — and nothing else — to
`docs/research/.gate-armed` (e.g. `/home/user/myproject/docs/research/2026-06-12`, one line). The
Stop hook reads this to scope the hard verification gate to this session's deliverable. Do NOT write
on a **rapid-tier** run.

**Gate:** Do not proceed to Phase 4 until every evaluated source has a card file on disk at
`[project]/docs/research/sources/<topic>-<slug>.md`. Inline summaries do not satisfy this requirement.

**Verbatim-quote requirement.** Each card must include a `## Verified Quote(s)` section with verbatim
text — not paraphrases — supporting the strongest claim in Key Findings, plus a precise location
reference (page, section, timestamp, paragraph offset). If a source cannot be fetched live, use
whatever excerpt was visible and flag as `Access: cached/partial`. A card with no `## Verified
Quote(s)` section or with paraphrases instead of verbatim text has not satisfied this gate.

**The evaluation process:**
1. Classify the evidence level using the 9-level hierarchy (`references/evidence-hierarchy.md`).
2. Score all 10 credibility dimensions using the rubric (`references/source-evaluation-rubric.md`).
   Use the anchors. Justify every score in 1–2 sentences.
3. Apply the bias guard before scoring dimensions 5 (Bias), 6 (Logic), and 8 (Intellectual Honesty):
   - If you agree with the source → score those three HARDER.
   - If you disagree → score those three MORE GENEROUSLY.
   Check the appropriate box on the source card.
4. Assign the score band using the weighted average in the rubric (`keep` / `borderline` / `reject`). Report the band word, not a decimal
   composite. Every run must cut ≥1 source OR name the lowest-scoring source that cleared the bar.
5. Extract key findings — 3–5 discrete, citable claims.

**Batch evaluation:** Evaluate each source completely before moving to the next.

---

## Phase 3.5: Independent Citation Verification

Spawn an independent verification subagent — a fresh Task-tool agent with no shared context from the
synthesis work. Give it ONLY:
- Read access to `docs/research/[date]/sources/`
- The verification protocol below
- The fetch/search tools it needs (WebFetch, WebSearch, Read)

Do NOT give it the analysis document, topic map, draft synthesis, or any context about what
conclusions the research is reaching.

**Sampling rule.** The verifier samples **≥30% of source cards, rounded up, min 3**. If **< 10**
cards total, verify ALL. Random sample — not weighted toward "important" sources. The executable gate
(Assertion 7) hard-fails any run below the 30% floor.

**Per-card verification protocol.** For each sampled card, the verifier:
1. **Fetches the URL.** Live → continue. Paywalled/dead WITH `cached/partial` flag → `inaccessible`.
   Paywalled/dead WITHOUT that flag → `failed`.
2. **Searches for the verbatim quote(s).** Must appear character-for-character. Smart-quote vs.
   straight-quote and normalized whitespace are trivial. A "close paraphrase" is a failure.
3. **Confirms attribution.** Misattributed quote = failure. **Domain rule:** quote credited to a
   domain OTHER than the card's `URL:` host → automatic `failed` (Assertion 9).
4. **Confirms location reference.** Off-by-one paragraph acceptable; wrong section = failure.

**Per-card outcome:** exactly one of `verified` / `failed` / `inaccessible`. No partial credit.
Borderline cases default to `failed`.

**Verification report.** Write to `docs/research/[date]/verification-report.md`:
- `**Synthesis agent ID:** <id>` and `**Verifier agent ID:** <id>` — both required, MUST differ;
  missing or duplicate ID hard-blocks the run (Assertion 4).
- Sample size, sample-selection method, list of sampled card filenames.
- Per-card outcome table (filename | outcome | notes if failed/inaccessible).
- Aggregate counts: verified / failed / inaccessible.
- **Failure rate** = `failed / (verified + failed)`. Inaccessible cards excluded from denominator.
- **Failure-rate band:** `<=5%` / `>5%-10%` / `>10%`

**Gate — if failure rate is `>5%`, DO NOT proceed to Phase 4.** Three remediation paths:
1. Re-evaluate failed sources: fetch, correct quotes, rewrite cards. Re-draw a fresh 30% sample
   (original sample is contaminated).
2. Re-source claims the failed cards supported. Find a real source or remove the claim.
3. `cached/partial` flag is honored ONLY for access problems that existed at synthesis time.
   Retroactive flip from `failed` to `cached/partial` AFTER verification is forbidden — hard-fails
   the gate (Assertion 8). A card scored `inaccessible` without `Access status:` enum → treated
   as `failed`. If a source genuinely became inaccessible between synthesis and verification, the honest path is to re-source the claim (path #2) or stamp the deliverable low-confidence — never relabel a real failure as an honest gap.

After any remediation, re-run Phase 3.5 from scratch on a freshly-drawn sample.

**Inaccessible cap:** `~30%` of sample → stamp `low-confidence`, not `passed` (Assertion 10).

**Methodology reporting.** §6 MUST report: sample size (`N of M (%)`), failure count, failure-rate
band. Omitting these fails the gate even if the report file exists.

**Executable gate.** `hooks/deep-research-verify.sh` via Stop hook — deterministic, no model calls:
- **A1–A6** — report exists; §6 has the three numbers; band is canonical; distinct verifier ID; every
  card has `Access status:` enum line and `## Verified Quote(s)` heading; a corrected card counts as
  `failed` (corrected-then-verified is forbidden — no corrected card scored `verified`).
- **A7** — sample ≥30% (rounded up, min 3; all if < 10). Hard-fails under-sampled runs.
- **A8** — `inaccessible` card without `Access status:` enum → treated as `failed`; retroactive
  reclassification note hard-fails. No git/mtime provenance check.
- **A9** — quote attributed to domain other than card's URL host → automatic `failed`.
- **A10** — inaccessible exclusions capped at ~30%; above cap → stamp `low-confidence`.
- **A11** — every `Perspective category:` must be exactly one of: `Academic` / `Institutional` /
  `Practitioner` / `Boots-on-the-ground` / `Contrarian`. Bespoke or hybrid values fail.
- **A12** — every run must exclude ≥1 source OR explicitly name the lowest-scoring source that
  cleared the bar.

On failure, exits non-zero; Stop hook injects blocking `NOT fact-checked` message.

**Advisory warnings (non-blocking — emit `WARN:` lines, never change exit code):**
- **W1** — when §6 Level 1 and Level 2 both at 0, asserts verbatim:
  `NO PRIMARY EVIDENCE — all findings are literature-derived predictions`. Satisfied if §2 already
  carries that exact string.
- **W2** — `>3:1` agree:disagree in Bias-Guard Summary; footnotes whether Phase 2 falsification query
  and Phase 4 `### Steel-man the contrarian` are present. W1 and W2 are advisory — do NOT block.

**Honest fallback.** If you cannot spawn a fresh Task-tool verification subagent, stamp the deliverable
`UNVERIFIED — self-check only` in BOTH §6 Methodology Source Evaluation AND the Deliverable Manifest's
verification-report item. Never copy the synthesis ID into the verifier field. The ground gate exits
non-zero on any attempt to print `Gate result: PASS` without a distinct verifier ID.

---

## Phase 4: Inclusion/Exclusion Decisions

Apply `references/inclusion-decision-matrix.md`. Work through the 6 decision rules IN ORDER for each
source. Stop at the first rule that matches.

**Perspective balance check.** After all decisions: verify at least 3 of 5 source categories are
represented for each major topic area. If a category is missing, determine whether it is a search gap
(return to Phase 2) or a genuine absence (document in methodology).

**Override protocol.** If a rule produces the wrong answer, override it — document: (1) which rule
would have applied, (2) why overriding, (3) what role this source plays.

**`### Steel-man the contrarian`** (confirmation-skew remediation). If the run's Bias-Guard Summary is
skewed `>3:1` agree:disagree, Phase 4 MUST include a `### Steel-man the contrarian` subsection. State
the STRONGEST version of the contradicting position on its own terms, charitably, before weighing it.
The executable gate footnotes its absence (warning W2).

---

## Phase 5: Synthesis

**Weighting.** `keep` > `borderline`. `reject` sources already cut.

**Handling contradictions.** State both positions clearly and fairly. Note credibility and evidence-level
differentials. State which position has stronger backing and why. If unresolvable: "the evidence is mixed."

**Pattern identification:** Consensus zones · Contested zones (present both sides) · Gaps (flag for
future research) · Institutional vs. ground truth (where big-name advice diverges from lived
experience).

**Framework extraction.** If research reveals a natural typology or model, document in §3. Ground
every element in source citations.

---

## Phase 6: Documentation

**Tier check first.** If **rapid**: deliverable is capped at **§1 + §2 + §5 + short methodology note**
(search-log + triage in/out log + `UNVERIFIED — self-check only` + `NOT INDEPENDENTLY VERIFIED`
stamps). Skip §3, §4, §6 (full), §7. The Reading-Deliverable Standard applies to BOTH tiers.

Produce the final deliverable at `[project]/docs/research/<YYYY-MM-DD>-<slug>/analysis.md` using
`references/research-document-template.md`.

**Reading-Deliverable Standard gate (MANDATORY):**
1. **Date header.** First line: `Generated: YYYY-MM-DD`.
2. **Readability + two passes.** ELI10, define every term/acronym inline, top-of-document Glossary
   (≤~12 terms). Run `noah-voice` then `ai-scoring` on FINAL text. Score **≥ 75**; revise if not.
   Record `AI-scoring: NN/100`.
3. **Epub by default.** `pandoc analysis.md -o "<title>.epub" --metadata title="..." --metadata
   author="Claude (deep-research)" --metadata date=<YYYY-MM-DD> --toc` unless user opted out.
4. **Pathing.** Markdown in repo. Epub to `~/Documents/Claude/<Project>/<Human Readable Title>.epub`
   or `~/Documents/Personal/<area>/`. Tell the user both paths.

**Document structure — top-level headings in this exact order:**
1. `## 1. Recommendations` — actionable bullets starting with a verb, each referencing the analysis
   section that backs it.
2. `## 2. Summary` — plain-language (2–3 pages max). If §6 evidence-level distribution reports
   Level 1 AND Level 2 both at 0, §2 MUST carry verbatim on its own line:
   `NO PRIMARY EVIDENCE — all findings are literature-derived predictions`. Also state the testability
   classification from Phase 2 (cheaply testable with no artifact; declared-untestable with
   one-line justification).
3. `## 3. [Domain-Specific Framework]` — include ONLY if a framework emerged; omit otherwise.
4. `## 4. Analysis` — consensus / contested / gaps / institutional-vs-ground-truth by research
   question.
5. `## 5. Research` — findings by topic area, per-source citations with score band + evidence level.
6. `## 6. Methodology` — research design, search-log table, source-evaluation framework,
   inclusion/exclusion summary + four distribution tables, perspective-balance matrix, bias-guard
   summary, limitations.
7. `## 7. Bibliography` — every included source: full citation, score band, evidence level,
   inclusion decision, one-line contribution summary.

**Writing order:** §5 → §4 → §3 (if applicable) → §6 → §7 → §1 → §2 (last; hardest). Assemble in
§1–§7 reading order after drafting in writing order.

**Language rules** (enforced by `ai-scoring` ≥ 75 gate): ELI10 throughout · define every term/acronym
inline on first use · top-of-document Glossary (≤~12 terms) · concrete examples over abstractions ·
show the tension · no orphaned claims.

**Bias-guard summary required.** §6 MUST contain a Bias-Guard Summary table: agree-with count,
disagree-with count, neutral count.

**Confirmation-skew gate (advisory).** When agree:disagree exceeds `>3:1`: (a) FALSIFICATION query
in Phase 2, and (b) `### Steel-man the contrarian` in Phase 4. W2 — advisory, does NOT block.

**Deliverable Manifest — verify each item before presenting to user:**
- [ ] `[project]/docs/research/<YYYY-MM-DD>-<slug>/analysis.md` with §1–§7 in order.
- [ ] Reading-Deliverable Standard: `Generated: YYYY-MM-DD` first line; terms/acronyms defined;
      Glossary; `noah-voice` applied; `ai-scoring` **≥ 75** (recorded as `AI-scoring: NN/100`).
- [ ] Epub via pandoc (`--metadata date=`) under `~/Documents/Claude/<Project>/` or
      `~/Documents/Personal/<area>/`. Both paths told to user. (Unless user opted out.)
- [ ] One source-card file per evaluated source at `[project]/docs/research/sources/<topic>-<slug>.md`.
      Inline summaries do NOT count.
- [ ] §6 contains: search-log table, evidence-level distribution, source-category distribution,
      credibility-score distribution, perspective-balance matrix, Bias-Guard Summary.
- [ ] §7 lists every included source with score band, evidence level, inclusion decision, contribution.
- [ ] Source counts reconcile: card files == methodology counts == §5 citations.
- [ ] Verification report at `docs/research/[date]/verification-report.md`, failure rate ≤5%,
      with sample size, per-card outcomes, aggregate counts. **Checked by the executable gate.**
      If stamped `UNVERIFIED — self-check only`, gate correctly fails — NOT fact-checked.
- [ ] `docs/research/.gate-armed` contains this session's deliverable directory absolute path.

**Checkpoint:** Once the Deliverable Manifest is fully checked, present the draft to the user.

---

## Multi-Session Research

1. Checkpoint after each session.
2. Intermediate drafts → `[project]/docs/research/drafts/` with session identifiers.
3. Completed source cards → `[project]/docs/research/sources/`.
4. Scores across sessions are comparable — both use the same anchored rubric.
5. Begin each new session by reading the previous session's draft and source cards.

---

# Decision-Design Mode

You reach this section ONLY when Phase 0 selected **decision-design** (or **hybrid** routed you here
after the evidence pipeline). This mode produces a reading deliverable — the Reading-Deliverable
Standard is MANDATORY (see D6).

**Two non-negotiables:**
1. **Don't anchor.** D1 catalog is walled off from D3 option generation. Record what exists, then
   generate options from zero.
2. **Blind-review the recommendation (D5).** If that review does not run, stamp the output
   `NOT design-reviewed` — never present an unreviewed recommendation as reviewed.

## D1: Prior-Work Catalog (walled off — do NOT anchor)

Catalog existing solutions, prior art, internal docs, the obvious default. One-line entry each: what
it is · where it lives · what it gets right · what it gets wrong. File under **Prior Work** appendix.

Wall it off. State explicitly: *"Prior work catalogued and quarantined; options below were generated
from zero."*

## D2: Parallel From-Zero Research Tracks (delegate to `borg-researcher`)

Decompose into **2–5 independent research tracks** (cap the fan-out; name the cap). Typical tracks:
user/behavioral, technical-feasibility, market/precedent, domain-specific. Each is a question, not a
foregone conclusion.

Delegate each track to the `borg-researcher` agent (Sonnet, web-enabled, lean-return) via the Task
tool — one per track, in parallel. Each returns distilled findings (conclusions + source records).
Never use `general-purpose`. Load-bearing factual claims → route through the evidence citation pipeline.

## D3: Neutral Candidate Options (generate from zero)

One synthesis pass over track findings produces **3–5 genuinely distinct options**. "Distinct" means
different architectural or interaction approaches. If two options are the same approach with different
labels, merge them. Present them **neutrally** — do NOT pre-pick a winner here.

For each option, produce this block in full:

### Option [A/B/C…]: [Short name — 3–5 words]
- **What it is:** [2–3 sentences. Core idea; what makes it different from the others.]
- **How it works:** [Brief flow. For UI: user steps. For systems: how data/components move.]
- **Pros / Cons:** [bullets]
- **Key tradeoffs:** [unavoidable ones — what you concede by choosing this. Specific, not "it's harder".]
- **Feasibility:** High / Medium / Low — [one-line reason grounded in a track finding.]
- **Estimate:** [rough sessions or engineer-hours — planning input, not a commitment.]
- **Visual:** [Claude Design prompt for UI options, or Mermaid diagram for system/flow options.]
- **Minimum viable version:** *"The smallest version that delivers the core value is: [X]."*

### D3.5: Contradiction Forge (GATED — fires only on a genuine constraint tension)

If D2/D3 surfaced two constraints that pull against each other, load `references/contradiction-resolution.md`
and propose **≥1 NEW option that holds BOTH poles**. State the Ideal Final Result first; reach for a
separation move (time / space / condition / scale); tag the new option with the exact separation move
used. If you can't name the move, it's a re-skinned trade-off. Each resolved option re-enters as a
full Option block with a `Separation move:` line. If no real tension exists, say so and skip.

## D4: Internal Evaluation → Draft Recommendation (the council)

Five personas evaluate the options. Each speaks once, references options by letter, cites specific
track findings. **Dissent is mandatory** — before the Recommender speaks, at least one persona must
formally DISAGREE with the emerging choice (logged as a named risk) or KILL an option for a reason
OTHER than effort/feasibility.

- **Product Strategist** — does this solve the right problem and fit the business shape?
- **Technical Realist** — can we actually build this; hidden complexity; what breaks first?
- **User Advocate** — will the actual target user (their constraints, load, time) benefit?
- **Pragmatist** — effort-to-impact; 80% value for 20% work; can it reduce to MVP?
- **Recommender** — synthesizes all four, names ONE option (optionally with scope constraint), MUST
  engage the strongest dissent explicitly. May not default to lowest-estimate option on effort alone.

The Recommender's pick is the **draft recommendation** — not final until it survives D5.

## D5: Blind Adversarial Review of the Recommendation (delegate to `borg-reviewer`)

Spawn the `borg-reviewer` agent (Sonnet, read-only, lean-return) via the Task tool. Give it the
problem statement, the option set, and the chosen option — but **NOT the council's reasoning for why
it won** (no-refeed). The reviewer tries to REFUTE the choice across three lenses:

- **Ideator** — is there a materially better option the option set missed entirely?
- **Critic** — does the chosen option have a fatal flaw the council talked itself past?
- **Auditor** — is the recommendation actually supported by track findings, or by assertion?

Record the reviewer's verdict (uphold / revise / overturn) and its strongest objection verbatim. If it
overturns or forces a revision, loop back to D3/D4, then re-review.

**Honest gate.** The blind review MUST run and its verdict MUST be recorded. If the `borg-reviewer`
pass did not run, stamp `NOT design-reviewed` at the top of §Recommendation.

## D6: Output Document (Reading-Deliverable Standard — MANDATORY)

Save markdown to `docs/research/YYYY-MM-DD-[slug]/recommendation.md` (or `docs/brainstorms/`). All
four clauses apply before presenting:
1. **Date header** — `Generated: YYYY-MM-DD`; same date into epub metadata.
2. **Readability + two passes** — ELI10, define every term/acronym, top-of-doc Glossary; run
   `noah-voice` then `ai-scoring`. Score **≥ 75**; record `AI-scoring: NN/100`.
3. **Epub by default** — `pandoc <file>.md -o "<title>.epub" --metadata author="Claude (research)"
   --toc` unless user opts out.
4. **Pathing** — markdown in repo; epub to `~/Documents/Claude/<Project>/<Title>.epub` (or
   `~/Documents/Personal/<area>/`). Tell the user both paths.

Document order: §Recommendation (verdict or `NOT design-reviewed` stamp) · §Options · §Council +
Dissent · §Track Findings · §Prior Work.

---

# Hybrid Mode

Run in sequence — do NOT merge:
1. **Evidence first.** Run Evidence Mode end to end → §1–§7 deliverable, executable citation gate.
2. **Then decision-design.** Run Decision-Design Mode — in D2, feed the evidence synthesis as a
   load-bearing track finding instead of re-researching from zero. D5 blind review still runs.

Both gates apply: the citation gate (evidence run) and the design-review gate (decision-design run).
The deliverable is the recommendation with the evidence deliverable linked as §Track Findings.
