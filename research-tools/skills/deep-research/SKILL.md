---
name: deep-research
description: "Systematic research methodology pipeline — source evaluation, evidence
  classification, inclusion/exclusion decisions, and documentation. Use when the user asks for
  deep research, literature review, source evaluation, evidence synthesis, or says /deep-research.
  Also trigger when planning a research project, evaluating source credibility, or building a
  defensible evidence base for product/design decisions."
---

# Deep Research

A deterministic, repeatable pipeline for conducting deep research. Takes you from framing the
question through producing a defensible, documented deliverable where every inclusion and
exclusion decision is traceable.

Built on six established frameworks (CREDIBLE, CRAAP, SIFT, RADAR, PRISMA, DeepTRACE) but
extends them into a unified end-to-end pipeline that no single existing framework covers.

**This skill produces a reading deliverable, so the [Reading-Deliverable Standard](../reading-deliverable-standard.md)
is MANDATORY.** It is enforced at Phase 6 (Documentation), but it shapes the whole run: write
plain-language and define-as-you-go from the first word, not as a cleanup pass at the end. The four
clauses — readability (`noah-voice` + `ai-scoring` passes, ELI10, define every term/acronym, top-of-doc
Glossary), a `Generated: YYYY-MM-DD` line, epub-by-default, and markdown-in-repo / epub-in-`~/Documents`
pathing — are non-negotiable. A defensible-but-unreadable report is a failed deliverable.

## Before You Begin — Lazy Reference Loading (Directive 04)

**References load at the phase that consumes them — NOT all up front.** The old protocol
demanded all seven reference documents (~14k tokens) loaded before Phase 1. A 4-source
product question and a 65-source clinical synthesis paid the identical entry tax, and that
undifferentiated up-front wall was the activation-energy spike that killed task initiation
(`audit.md:175-181`). It is removed. There is no pre-load checklist to clear before Phase 1.

**Only two things carry inline — read them now:**

1. **The card-field skeleton** (so you know the shape every source card must take):
   Full citation · URL · Date accessed · Evidence level · Research topic area ·
   the 10-dimension Credibility Scores table · Score band (`keep`/`borderline`/`reject`) ·
   Bias Guard Check · Key Findings · `## Verified Quote(s)` + Location reference ·
   `Access status:` (`live`/`cached/partial`/`inaccessible`) · Inclusion Decision ·
   `Perspective category:` (one of the five enum values). The full template with anchors is
   `references/source-card-template.md` — load it at Phase 3, when you actually fill a card.
2. **The §1–§7 deliverable outline** (so you know the shape the final document must take):
   §1 Recommendations · §2 Summary · §3 Framework (if one emerged) · §4 Analysis ·
   §5 Research · §6 Methodology · §7 Bibliography, in that order. The full template is
   `references/research-document-template.md` — load it at Phase 6, when you write the doc.

**Load each reference at the phase that consumes it** (the Quick Reference table at the end
of this file is the lazy-load map):

- Phase 1 (Research Design) → `references/example-evaluation.md` is optional context; nothing
  is required to start. Run the novelty probe (below) first.
- Phase 2 (Discovery) → `references/evidence-hierarchy.md` when you start classifying.
- Phase 3 (Evaluation) → `references/source-evaluation-rubric.md`, `source-card-template.md`,
  and `evidence-hierarchy.md` — loaded at the triage screen and the scoring step.
- Phase 4 (Inclusion) → `references/inclusion-decision-matrix.md`.
- Phase 6 (Documentation) → `references/research-document-template.md` and
  `methodology-section-template.md`.

The references are still the operational contract; you just pay for each one when you reach
the step that uses it, not all at once at the moment of least commitment. SKILL.md is the
overview; the references are the manual.

---

## The Pipeline

### Phase 1: Research Design

#### Phase 1.0: Novelty probe — "is this worth a full run?" gate (Directive 04)

**Run this FIRST, before designing anything.** Promoted here from brainstorm, where it lived
in the wrong skill — a direct `/deep-research` previously always ran the full heavy pipeline
with no "should I even run this?" gate (`audit.md:191-199,444-447`). The probe is a universal
pre-flight: 2–3 targeted searches to decide whether a full pipeline is warranted at all.

1. `"[topic]" after:[date-of-any-existing-research]` — if prior research on disk exists.
2. `"[topic]" 2025 OR 2026 new research OR update`.
3. One domain-specific probe (a framework changelog for tech topics; a new-study framing for
   behavioral/clinical/domain topics).

**Early termination.** If the probe surfaces nothing materially new — same sources recurring,
no new studies/frameworks, no contradicting findings — and prior research or reliable model
knowledge already answers the question, STOP. Do NOT run the full pipeline. Note the kill
explicitly to the user:

> "Novelty probe: no significant new developments found since [date]. Full deep-research not
> warranted. Answering from [existing doc / model knowledge]; run the full pipeline only if you
> need a fresh defensible evidence base."

**Proceed** to the tier choice (below) only if the probe finds new, updated, or conflicting
information, or no prior research exists and the question genuinely needs an evidence base.

#### Phase 1.1: Stakes / tier selection (Directive 04)

Choose the tier BEFORE designing, and tie document size to the size of the decision it informs
(`audit.md:261-268`). Confirm the tier with the user at the Phase 1 checkpoint.

- **rapid tier** — when the decision is low-stakes, has ≤~4 candidate sources, is
  internal/reversible, or you are under a tight time budget. Deliverable: **§1 + §2 + §5 + a
  short methodology note ONLY**. Verification: self-check only, stamped `UNVERIFIED —
  self-check only`.
- **full tier** — when the decision is high-stakes, externally published, costly/irreversible,
  or the evidence base is contested. Deliverable: **the complete §1–§7 manifest**. Verification:
  an independent Phase 3.5 verification subagent.

The **rapid tier is HONEST about its reduced guarantees** — see "Rapid Tier" below. It is the
documented escape valve so that under time pressure the pipeline produces a smaller *compliant*
artifact, not a quietly non-compliant full one (troth: 65 cards, no verification —
`audit.md:183-189`). The **full manifest fires only for high-stakes / external-publication runs.**

#### Phase 1.2: Design

Once the tier is chosen, define:

1. **Research questions** — What specifically are you trying to answer? Write 1-3 explicit
   questions. Vague questions produce vague research.

2. **Scope boundaries** — What is in scope? What is explicitly out? Why? Write both lists.
   Scope boundaries prevent rabbit-holing.

3. **Topic map** — Break the research into domains and subtopics. For each subtopic, write
   1-2 specific questions. The topic map becomes the organizing structure for the research
   section of the final document.

4. **Inclusion/exclusion criteria** — Define these BEFORE searching (PRISMA-style
   pre-registration). What types of sources will you accept? What date ranges? What
   geographies? What languages? Write these down. They prevent post-hoc rationalization
   of inclusion decisions.

5. **Target audience** — Who will read this? What do they need? What is their expertise level?
   This determines the language level and document structure.

6. **Output structure** — Use the research document template or propose an alternative.
   Confirm with the user before proceeding.

**Checkpoint:** Present the research design to the user for validation before proceeding to
Phase 2. Do not search until the design is confirmed.

---

### Rapid Tier — HONEST reduced guarantees (Directive 04)

The rapid tier exists so that under time pressure (or for a genuinely low-stakes decision) the
pipeline produces a smaller **compliant** artifact rather than a quietly non-compliant full one
or a non-start (`audit.md:183-189`). It is NOT "the full pipeline with steps skipped silently" —
it wears its rigor level on its face.

**What rapid keeps:**

- Phase 1.0 novelty probe and Phase 1.2 design (always).
- Phase 2 discovery and the Phase 3 **triage screen** (the fast keep/cut — see Phase 3).
- Full 10-dimension source cards ONLY for the handful of sources that survive triage.
- A deliverable capped at **§1 Recommendations + §2 Summary + §5 Research + a short
  methodology note** (search-log + which sources were triaged in/out + the honest stamp).
  §3, §4, §6 (full), and §7 are NOT produced in rapid — the full manifest fires only for the
  full tier.

**What rapid honestly gives up:** independent Phase 3.5 verification. A rapid run does NOT spawn
a fresh, independent verifier subagent. Therefore:

- **Stamp the artifact `UNVERIFIED — self-check only`** — the SAME honest-fallback vocabulary
  Directive 01 defined for the Task-tool-unavailable case. Put the stamp in BOTH the §2 Summary
  AND the short methodology note (the rapid analogue of the §6 Source Evaluation subsection and
  the manifest's verification-report item). Also stamp the artifact `NOT INDEPENDENTLY VERIFIED`
  in §2 so a reader sees it at a glance.
- **Never fabricate a verifier ID.** Record in any report header that no distinct verifier agent
  ran; never copy the synthesis ID into the verifier field to satisfy a check.
- Because a rapid run carries no distinct verifier ID, the executable ground gate
  (`hooks/deep-research-verify.sh`, Assertion 4) **correctly FAILS it** and the `Stop` hook
  surfaces it as `NOT fact-checked` — by design. **The verifier never prints `Gate result: PASS`
  on a rapid run, and that is the honest, intended outcome.** A rapid artifact is a smaller
  compliant deliverable for its tier; it is explicitly NOT a fact-checked one, and it does not
  pretend to be.

If a rapid run's decision turns out to be higher-stakes than first judged, **upgrade to the full
tier**: produce the missing sections (§3/§4/§6/§7) and run the Phase 3.5 verification subagent so
the deliverable can earn a real `PASS`.

---

### Phase 2: Source Discovery

Systematic searching across multiple source types. The goal is BREADTH first, DEPTH second.

**Required source diversity.** For each major topic area, actively seek sources from all 5
categories:

1. **Academic** — peer-reviewed research, university publications, working papers
2. **Institutional** — government agencies, professional bodies, established financial orgs
3. **Practitioner** — advisors, coaches, tool builders, counselors who do the work daily
4. **Boots-on-the-ground** — forums, personal blogs, community experience, real households
5. **Contrarian** — voices that challenge the mainstream consensus

**Search strategy:**
- Minimum 3 search queries per subtopic (more for broad subtopics)
- Vary query framing: factual ("budgeting retention rates"), evaluative ("why budgets fail"),
  contrarian ("budgeting is pointless"), experiential ("our family budget experience")
- Log every search query in the methodology section

**Triangulation rule:** No claim in the final document can rest on a single source type. If
only academics say it, find a practitioner who confirms or contradicts. If only practitioners
say it, look for data. This is non-negotiable.

**When to stop searching:** When new searches are returning sources you've already seen, and
all 5 source categories have at least some representation for each major topic area.

**Backend routing (Directive 06 — optional scholarly adapter).** deep-research has no
web-scale corpus of its own: discovery rides the host's general WebSearch/WebFetch
(`audit.md:201-206`). For academic and clinical questions that is a real gap, so an OPTIONAL
first-party adapter (`hooks/scholarly-adapter.sh`) can pull peer-reviewed abstracts + DOIs +
open-access PDF links from a keyless scholarly API into the SAME source-card pipeline. Route
each Phase 2 query by topic:

- **academic / clinical → OpenAlex** (the adapter default; 250M+ works, CC0, keyless, not
  throttled). Run `hooks/scholarly-adapter.sh search "<query>" --topic <area>` — it writes one
  standard source card per result to `docs/research/sources/` and one fetch-time abstract
  SNAPSHOT to `docs/research/snapshots/`.
- **AI / ML / CS → Semantic Scholar** (the documented FALLBACK; 200M+ papers, keyless but
  GLOBALLY THROTTLED, which is exactly why it is NOT the default). Add `--backend
  semanticscholar`; expect rate-limited/empty responses and fall back to OpenAlex or WebSearch.
- **general web → WebSearch / WebFetch** (the existing default path; everything above is
  additive).

The adapter is OPTIONAL and adds NO hard dependency: with no scholarly backend invoked, the
pipeline runs exactly as before, and neither backend needs a secret (both are keyless).
Adapter-pulled cards use the STANDARD template with NO backend-specific fields — a reader
cannot tell OpenAlex from Semantic Scholar from a card, so the corpus stays swappable and the
open-corpus advantage never becomes new lock-in. Each card's `## Verified Quote(s)` blockquote
is a verbatim span of the snapshotted abstract, so the Phase 3.5 verifier (and the executable
ground gate) check the card against the fetch-time snapshot exactly as they check a web card
against its live page — consistent with the Directive 01 ground-ledger contract. We are NOT
Elicit-scale; this adds a free academic backend, not a 138M-paper index (`audit.md:204-206`).

**Evidence-floor classifier (Directive 03 — advisory now, blocking later).** Before you
finish Phase 2, classify EACH research question on one axis: *is it cheaply testable
in-environment?* A question is cheaply testable when you could answer it by directly
observing a UX flow, a prompt's behavior, an API's output, or the household's own data —
rather than only by reading what others have written. The reveal portrait research is the
worked example: instead of defaulting to the published-consensus answer, it ran a single
n=1 in-environment probe (21 live calls, MAE 3.32/255) and that one measurement reframed
the entire recommendation.

- **When a question IS cheaply testable**, the pipeline PREFERS at least one
  direct-observation artifact over more source-scoring: a small probe PLUS the committed
  harness that produced its numbers (a script, a notebook, a logged transcript). Absence of
  such an artifact does NOT block in this directive — it surfaces in §2 so the reader knows
  the testable question was answered from literature rather than measurement.
- **When you declare a question UNTESTABLE** (to skip the direct-observation preference),
  that declaration REQUIRES a one-line justification in §2 — e.g. "Q3 is not cheaply
  testable in-environment: it depends on multi-week household behavior we cannot observe in
  this session." This anti-gaming note exists because the classifier is otherwise an
  honor-system escape hatch: a tired agent can declare everything untestable to dodge the
  preference. The one-line justification leaves a paper trail; it does not have to be long,
  it has to exist.
- **Falsification query (confirmation-skew remediation).** If the run's Bias-Guard Summary
  ends up skewed `>3:1` agree:disagree (see Phase 6), the Phase 2 search plan MUST include
  at least one deliberate FALSIFICATION query — a search framed to find evidence the thesis
  is WRONG ("counterexamples to X," "evidence X fails," "when X backfires"), not merely a
  contrarian-flavored rephrase of the thesis. Log it in the search-log table like any other
  query. The executable gate footnotes its absence (warning W2); it does not yet block.

**Paywall surfacing.** If during source discovery you encounter sources behind paywalls
(academic journals, paid industry reports, gated analyst notes, subscription-only trade
publications) that look genuinely high-value for the research question, STOP the pipeline
and write a candidate list to `docs/research/[date]/drafts/paywalled-candidates.md`
before completing Phase 2. Each entry must contain:

- **Full citation** — author(s), title, publication, date, DOI/URL.
- **Paywall publisher / platform** — Elsevier, JSTOR, Gartner, WSJ, Substack, etc.
- **Estimated procurement cost** if known (e.g., "$39 per-article PDF," "$1,995 report,"
  "$15/month subscription"). Write "unknown" if you cannot find pricing without
  registering — do not register or submit forms to discover pricing.
- **Why this source would materially improve the research** — be specific about what
  claim it would support or refute. Vague justifications ("seems important," "looks
  comprehensive") are non-compliant; the user needs to weigh procurement cost against
  concrete research value.

After writing the candidates file, ping the user for a procurement decision before
completing Phase 2. Once the user decides which (if any) to procure, resume discovery
with those sources included or document the exclusion in the §6 Methodology Limitations
subsection (citation + reason for exclusion). Silently dropping a paywalled source you
identified as high-value, without surfacing it for a procurement decision, is non-compliant.

**Negative case.** If discovery surfaces zero genuinely high-value paywalled sources,
do NOT create an empty `paywalled-candidates.md` file. Instead, note in the §6
Methodology Source Discovery subsection: "Paywall scan: no high-value paywalled
candidates identified." The negative result must be documented so a reader knows the
scan was actually performed.

---

### Phase 3: Source Evaluation

#### Phase 3.0: Triage screen — fast keep/cut BEFORE expensive scoring (Directive 04)

**Apply a fast keep/cut screen to ALL discovered sources first; write full 10-dimension cards
only for the sources that pass.** This moves the inclusion cut BEFORE the expensive scoring
(`audit.md:434-438`) — previously every discovered source paid the full 10-dimension card cost
even when it was obviously off-topic or strictly dominated by a stronger source.

For each discovered source, spend ~15 seconds on three keep/cut questions:

1. **On-topic?** Does it actually address a research question or topic-map subtopic? Off-topic →
   **cut** (note it in the search log so the cut is visible; do not card it).
2. **Minimally credible?** Is the author/outlet plausibly authoritative, or is this content-farm
   / SEO-spam / undated rehash? Obvious junk → **cut**.
3. **Non-redundant?** Does it add something a source you have already kept does not? If a stronger
   already-kept source strictly dominates it → **cut** (record the superseding source).

A source that clears all three is **kept for full evaluation** (gets a 10-dimension card below).
A source that fails any one is **triaged out** — log it as a cut in the §6 search-log /
methodology note with a one-line reason; it does NOT get a card. The triage screen is the cheap
front gate; the 10-dimension rubric is the expensive back gate only the survivors reach.

(In the **rapid tier** the triage screen is the primary instrument: card only the few survivors
and write the short methodology note from the triage log.)

#### Phase 3.1: Full source evaluation

For every source that PASSED triage, complete a source evaluation card (see
`references/source-card-template.md`) and write it to disk at
`[project]/docs/research/sources/<topic>-<slug>.md`.

**Gate — do not proceed to Phase 4 until every evaluated source has a card file on disk
at `[project]/docs/research/sources/<topic>-<slug>.md`, using the template exactly.**
Inline summaries inside the analysis document do not satisfy this requirement. A subagent
that "summarized the source in the analysis doc" instead of producing a card has skipped
the step; go back and produce the card.

**Verbatim-quote requirement.** Each card must include a `## Verified Quote(s)` section
per the updated `references/source-card-template.md`. The quotes must be verbatim from
the source — not paraphrases, not "the source basically says X" summaries. Pick the
strongest claim the card makes in Key Findings and have at least one quote support that
claim with a precise location reference (page, section, timestamp, paragraph offset —
whatever the source supports). If a source cannot be fetched live (paywalled, taken
down, dead link, geo-blocked), use whatever excerpt was visible at access time and flag
the source as `Access: cached/partial` in the card. A card with no Verified Quote(s)
section — or with a section that contains paraphrases instead of verbatim text — has
not satisfied this gate; go back and pull the quote before proceeding.

**The evaluation process:**

1. **Classify the evidence level** using the 9-level hierarchy
   (`references/evidence-hierarchy.md`)

2. **Score all 10 credibility dimensions** using the rubric
   (`references/source-evaluation-rubric.md`). Use the anchors — do not score intuitively.
   Justify every score in 1-2 sentences.

3. **Apply the bias guard.** Before scoring dimensions 5 (Bias), 6 (Logic), and 8
   (Intellectual Honesty), check your own reaction to the source's conclusions:
   - If you agree → score those three dimensions HARDER (you're primed to be generous)
   - If you disagree → score those three dimensions MORE GENEROUSLY (you're primed to punish)
   - Check the appropriate box on the source card

4. **Assign the score band** (`keep` / `borderline` / `reject`) using the weighted
   average in the rubric. Report the band word on the card, not a 2-decimal composite —
   the band is the disposition (see `references/source-evaluation-rubric.md`). Every run
   must cut ≥1 source or name the lowest source that cleared the bar.

5. **Extract key findings** — 3-5 bullet points of discrete, citable claims or insights

**Batch evaluation:** When evaluating many sources, do NOT score them all on one dimension
at a time. Evaluate each source completely before moving to the next. This prevents anchoring
bias from the previous source's scores.

---

### Phase 3.5: Independent Citation Verification

Phases 1–3 produce source cards with verbatim quotes. This phase verifies those quotes
actually exist where the cards say they do. Source cards can be fabricated — URLs that
resolve to unrelated pages, quotes that paraphrase rather than reproduce, attributions
to authors who never made the claim. Phase 3.5 catches all three by running a
**blind** verification pass: an independent subagent re-reads the sources, not the
analysis. If the analysis is fiction dressed as research, this is the phase that
surfaces it.

**Spawn an independent verification subagent.** This subagent MUST be a fresh Task-tool
agent with no shared context from the synthesis work. Give it ONLY:
- Read access to `docs/research/[date]/sources/`
- The verification protocol below
- The fetch/search tools it needs (WebFetch, WebSearch, Read)

Do NOT give it the analysis document, the topic map, the draft synthesis, or any
context about what conclusions the research is reaching. The whole point is that the
verifier evaluates each card against its source on the card's own terms, uninfluenced
by what the larger document needs the source to say.

**Sampling rule.** The verifier samples **30% of source cards, rounded up, with a
minimum of 3**. If there are fewer than 10 cards total, verify ALL of them. Sample
selection is random across the full set — not weighted toward "important" sources
(important sources are exactly the ones most worth fabricating, so weighting defeats
the purpose). The executable gate (Assertion 7) reads the reported sample size against
the card count on disk and hard-fails any run below the 30% floor — an under-sampled
"verification" of a handful of hand-picked cards does not satisfy this phase.

**Per-card verification protocol.** For each sampled card, the verifier:

1. **Fetches the URL.** Live → continue. Paywalled/dead/geo-blocked but the card is
   flagged `Access: cached/partial` → mark `inaccessible` (NOT failed) and move on.
   Paywalled/dead/geo-blocked WITHOUT the `cached/partial` flag → mark `failed`
   (the card claimed live access it cannot demonstrate).
2. **Searches for the verbatim quote(s).** The quote must appear character-for-character
   in the fetched content. Allow only trivial variation (smart-quote vs. straight-quote,
   normalized whitespace). A "close paraphrase" is a failure.
3. **Confirms attribution.** The author/speaker named on the card must be the one to
   whom the quote is attributed in the source. A quote correctly reproduced but
   misattributed is a failure. **Domain rule (machine-checked):** if the quote's
   attribution credits a domain OTHER than the card's own `URL:` host, the card is an
   automatic `failed` regardless of access status — the quote did not come from the
   source the card claims (this is the reveal s11 defect: a quote credited to
   `Lavivienpost.net` on a card whose URL is `stable-diffusion-art.com`). The gate
   enforces this as Assertion 9.
4. **Confirms location reference.** The page/section/timestamp/paragraph offset on
   the card must point to the actual location of the quote. Off-by-one paragraph is
   acceptable; "wrong section entirely" is a failure.

**Per-card outcome.** Exactly one of: `verified` / `failed` / `inaccessible`. No
"partial credit." Borderline cases default to `failed` — the verifier is the
adversarial check, not a sympathetic reviewer.

**Verification report.** Write the report to
`docs/research/[date]/verification-report.md`. Required contents:

- **Report header IDs (machine-checked).** Record two distinct IDs in the report header:
  a **Synthesis agent ID** (the agent that authored the cards) and a **Verifier agent
  ID** (the fresh Task-tool subagent spawned above). Use the form
  `**Synthesis agent ID:** <id>` and `**Verifier agent ID:** <id>` (a session ID is
  fine). These two IDs MUST differ — that difference is the on-disk proof that the
  verification was independent rather than self-graded. The executable ground gate
  (`hooks/deep-research-verify.sh`, Assertion 4) fails the deliverable if the verifier
  ID is absent or equal to the synthesis ID, so a missing or duplicate ID hard-blocks
  the run; it is not a stylistic nicety.
- Sample size, sample-selection method, list of sampled card filenames
- Per-card outcome table (filename | outcome | notes if failed/inaccessible)
- Aggregate counts: verified / failed / inaccessible
- **Failure rate** = `failed / (verified + failed)`. Inaccessible cards are excluded
  from the denominator because they are honestly flagged unverifiable, not failed
  attempts at deception.
- Failure-rate band: `≤5%` / `>5%–10%` / `>10%`

**Gate — if failure rate is >5% (more than 1 in 20 sampled-and-verifiable cards
failed), DO NOT proceed to Phase 4.** Three remediation paths, in preference order:

1. **Re-evaluate the failed sources.** Fetch them, pull correct quotes, rewrite the
   cards. Then re-sample (the original sample is now contaminated — draw a fresh 30%
   from the full set, including any newly-rewritten cards).
2. **Re-source the claims the failed cards supported.** If a card's quote turns out to
   not exist, the claim that quote supported in the analysis is now unsourced. Find a
   real source for the claim or remove the claim.
3. **Document as access-limited — but NOT to game the rate.** A `cached/partial` flag is
   honored ONLY if it documents a genuine access problem that existed at synthesis time
   (the source was already paywalled/dead/geo-blocked when the card was written).
   Retroactively flipping a `failed` card to `cached/partial` AFTER verification, solely
   to move it out of the failure denominator and bring the rate under 5%, is forbidden
   rate-gaming — it converts the honest "this attempt failed" into a laundered
   "unverifiable, not our fault." The executable gate (Assertion 8) enforces this two
   ways, with NO git/mtime provenance check (that is out of scope):
   - A card scored `inaccessible` in the report whose card file lacks the canonical
     `Access status:` enum is treated as `failed`, not excluded. (A missing enum is
     exactly what let the reveal s11 card be scored `inaccessible` on a `cached/partial`
     flag it never carried — see `references/source-card-template.md`.)
   - A retroactive-reclassification note in the report (e.g. "reclassified to
     cached/partial after synthesis," "now counts as inaccessible") hard-fails the gate.
   If a source genuinely became inaccessible between synthesis and verification, the
   honest path is to re-source the claim (path #2) or stamp the deliverable
   `low-confidence` — never to relabel a real failure as an honest gap. And the
   inaccessible exclusions themselves are capped: if more than ~30% of the sample lands
   in `inaccessible`, the deliverable is stamped `low-confidence`, not `passed`
   (Assertion 10).

After any remediation path, **re-run Phase 3.5 from scratch** on a freshly-drawn sample
before proceeding to Phase 4. A subagent that "patched the failed ones and moved on"
without re-sampling has skipped the gate.

**Methodology reporting.** The §6 Methodology section MUST report:
- Verification sample size (`N sampled` out of `M total cards`, `P%`)
- Failure count
- Failure-rate band

These three numbers appear in the Source Evaluation subsection of the methodology
template. A methodology that omits them has not satisfied the gate even if the
verification report file exists.

**Executable gate (not honor-system).** Phase 3.5 is now enforced by a no-model script,
`hooks/deep-research-verify.sh`, run by the plugin's `Stop` hook. The script is
context-blind, deterministic, and makes zero model calls. Directive 01 shipped the first
six integrity facts (A1–A6): report exists; §6 has the three numbers; the band is
canonical; a distinct verifier ID is recorded; every card has the `Access status:` enum
line and a `## Verified Quote(s)` heading; no corrected-then-recounted card is scored
`verified`. Directive 02 adds six more (A7–A12):

- **A7** — the verification sample is ≥30% of total cards (rounded up, min 3; all cards
  if fewer than 10). Fails an under-sampled run (e.g. 5/53 ≈ 9%).
- **A8** — a card scored `inaccessible` whose file lacks the canonical `Access status:`
  enum is treated as `failed`; and any retroactive cached/partial reclassification note
  hard-fails (no rate-gaming). No git/mtime provenance is read.
- **A9** — a quote attributed to a domain other than the card's own URL host is an
  automatic `failed`, regardless of access status.
- **A10** — inaccessible exclusions are capped at ~30% of the sample; above the cap the
  deliverable must be stamped `low-confidence`, not `passed`.
- **A11** — every present `Perspective category:` value is exactly one of the five enum
  values (Academic / Institutional / Practitioner / Boots-on-the-ground / Contrarian); a
  bespoke or hybrid value fails.
- **A12** — every run must exclude ≥1 source OR explicitly name the lowest-scoring source
  that cleared the bar.

On any failure it exits non-zero and the `Stop` hook injects a blocking
`NOT fact-checked — verification gate failed: <reason>` message and refuses to let the
deliverable be presented as PASS. The honest badge it prints on a pass is
`a distinct verifier agent ran and the files prove it` — NOT "blind," NOT "true," NOT
"cannot lie": the script proves a distinct verifier ID was recorded and a quote exists
on the page, but it cannot prove the verifier's mind was uninfluenced. The box is now
checked by the script, not the agent.

Directive 03 adds two NON-BLOCKING advisory warnings on the same no-model script — they
emit `WARN:` lines and a `Warnings:` tally but NEVER change the exit code, so a clean
deliverable with warnings still passes the hard gate:

- **W1 — NO-PRIMARY-EVIDENCE banner.** When the §6 evidence-level distribution shows
  Level 1 and Level 2 both at 0, the verifier asserts the verbatim banner
  `NO PRIMARY EVIDENCE — all findings are literature-derived predictions` as a warning; if
  §2 already carries that exact string, the warning is satisfied.
- **W2 — confirmation skew.** A `>3:1` agree:disagree ratio in the Bias-Guard Summary
  raises a warning and footnotes whether the Phase 2 falsification query and the Phase 4
  steel-man subsection are present.

**Promotion path (documented, not done here).** W1 and W2 stay ADVISORY until two
conditions are met: (a) the Directive 01 hard gate has fired in production, AND (b) the
banner/skew warnings have run clean on `>=2` real deliverables. Only then may they graduate
to blocking. Because each warning is written to the same ground-ledger-shaped record the A*
assertions read, promotion is a one-line change (move the warning's verdict into the
failure accumulator) with no rewrite of the detection logic.

**Honest fallback (Task-tool unavailable).** If you cannot spawn a fresh, independent
Task-tool verification subagent in this environment, do NOT silently downgrade to
self-verification and claim a pass. Instead, stamp the deliverable
`UNVERIFIED — self-check only` in BOTH the §6 Methodology Source Evaluation subsection
AND the Deliverable Manifest's verification-report item, and record in the report header
that no distinct verifier agent ran (omit a fabricated verifier ID — never copy the
synthesis ID into the verifier field to satisfy the check). The ground gate exits
non-zero on any attempt to print `Gate result: PASS` without a distinct verifier ID, so
a self-check-only deliverable correctly fails the gate and is surfaced as NOT
fact-checked rather than laundered into a green stamp.

---

### Phase 4: Inclusion/Exclusion Decisions

After all source cards are completed, apply the decision matrix
(`references/inclusion-decision-matrix.md`).

Work through the 6 decision rules IN ORDER for each source. Stop at the first rule that
matches.

**After all decisions are made, run the perspective balance check:**
- For each major topic area, verify at least 3 of 5 source categories are represented
- If a category is missing, determine whether it's a search gap (go back to Phase 2) or
  a genuine absence (document in methodology)

**Override protocol:** If a rule produces the wrong answer, override it. But document:
1. Which rule would have applied
2. Why you're overriding
3. What role this source plays in the final document

**Steel-man the contrarian (confirmation-skew remediation).** If the run's Bias-Guard
Summary is skewed `>3:1` agree:disagree (see Phase 6), Phase 4 MUST include a
`### Steel-man the contrarian` subsection. State the STRONGEST version of the position that
contradicts the thesis — on its own terms, charitably, before weighing it — not a strawman
set up to be knocked down. The point is to counterbalance the documented agreement skew: a
corpus selected to confirm a thesis needs the dissenting case argued at full strength, not
just noted in passing. The executable gate footnotes the subsection's absence (warning W2);
it does not yet block.

---

### Phase 5: Synthesis

With included sources identified and scored, synthesize findings.

**Weighting:** When multiple sources address the same question, weight their contributions
by credibility band. A `keep` source carries more weight than a `borderline` one, but both
contribute; a `reject` source was already cut and does not appear here.

**Handling contradictions:** When credible sources disagree:
1. State both positions clearly and fairly
2. Note the credibility differential
3. Note the evidence level differential
4. State which position has stronger backing and why
5. If genuinely unresolvable, say so — "the evidence is mixed" is an honest finding

**Identifying patterns across sources:**
- **Consensus zones** — where most credible sources agree (high confidence findings)
- **Contested zones** — where credible sources genuinely disagree (present both sides)
- **Gaps** — important questions that no source addresses well (flag for future research)
- **Institutional vs. ground truth** — where big-name advice diverges from lived experience

**Framework extraction:** If the research reveals a natural typology, framework, or model,
document it in Section 3 of the final document. Ground every element of the framework in
specific source citations.

---

### Phase 6: Documentation

**Tier check first (Directive 04).** If this is a **rapid** run, the deliverable is capped at
**§1 Recommendations + §2 Summary + §5 Research + a short methodology note** (search-log + the
triage in/out log + the `UNVERIFIED — self-check only` and `NOT INDEPENDENTLY VERIFIED` stamps).
Skip §3, §4, the full §6, and §7 — and skip the full Deliverable Manifest below (it governs the
full tier). A rapid deliverable does not run the Phase 3.5 verification subagent, so the ground
gate correctly fails it as `NOT fact-checked` — that is the honest outcome for the tier, not a
defect. The rest of this section governs the **full** tier. **The Reading-Deliverable Standard below
applies to BOTH tiers** — a rapid run is smaller, but it is still something a human reads, so it still
gets the `Generated:` date header, the readability + `noah-voice`/`ai-scoring` passes, the
define-every-term/Glossary discipline, the epub-by-default, and the repo/Documents pathing.

Produce the final deliverable at `[project]/docs/research/<YYYY-MM-DD>-<slug>/analysis.md`
(date-and-slug subdirectory — match the existing convention, e.g.
`docs/research/2026-06-13-people-photo-firstprinciples/analysis.md`) using
`references/research-document-template.md`.

**Reading-Deliverable Standard gate (MANDATORY — see `../reading-deliverable-standard.md`).** This
document is something a human will READ, so all four clauses apply before you present it:

1. **Date header.** The FIRST line of the document (above or just under the title) MUST be
   `Generated: YYYY-MM-DD` with today's date. The failed reveal report had none — that omission alone
   makes a report untrustworthy. The same date goes into the epub metadata (`--metadata date=`).
2. **Readability + the two enforcement passes.** The document must be plain-language / ELI10, assume NO
   prior knowledge, DEFINE every term and acronym inline on first use, and carry a short **Glossary**
   near the top for the unavoidable jargon. Then run, on the FINAL text, in order: the **`noah-voice`**
   pass (voice rules) and the **`ai-scoring`** pass (0–100 human-vs-AI score). The deliverable must
   score **≥ 75**; revise against flagged passages and re-score if it does not. Record the final score
   in the document (`AI-scoring: NN/100`). These are the same passes Noah's global rules require before
   ANY written content is shown; the pipeline now runs them explicitly so they are not skipped.
3. **Epub by default.** After the markdown is finalized and has passed the two passes, generate an epub
   with pandoc UNLESS the user opted out (`pandoc analysis.md -o "<title>.epub" --metadata
   title="..." --metadata author="Claude (deep-research)" --metadata date=<YYYY-MM-DD> --toc`).
4. **Pathing.** Markdown stays in the repo at the path above. The epub goes to
   `~/Documents/Claude/<Project>/<Human Readable Title>.epub` for project work (match the existing
   folder, e.g. `~/Documents/Claude/reveal/`) or `~/Documents/Personal/<area>/` for personal work. Tell
   the user both paths.

**The document MUST contain the following top-level headings, in this exact order. Do
not invent new top-level sections that displace these seven, and do not reorder them:**

1. `## 1. Recommendations` — actionable bullets, each starting with a verb, each
   referencing the analysis section that backs it. See template L17-30.
2. `## 2. Summary` — the "tired dad at 4am" version (2-3 pages max). See template L34-44.
   **NO-PRIMARY-EVIDENCE banner (Directive 03):** if no primary experimental evidence was
   collected — i.e. the §6 evidence-level distribution table reports Level 1 (systematic
   review / meta-analysis) AND Level 2 (RCT) both at 0 — §2 MUST carry this exact string,
   verbatim, on its own line: `NO PRIMARY EVIDENCE — all findings are literature-derived
   predictions`. The executable gate asserts this string as a non-blocking warning (W1); it
   surfaces the floor without failing the deliverable. Also state in §2 the testability
   classification from Phase 2 — for each cheaply-testable question with no
   direct-observation artifact, say so; for each question declared untestable, carry its
   one-line justification.
3. `## 3. [Domain-Specific Framework]` — include ONLY if a framework, typology, or model
   emerged from the research. If no framework emerged, omit this section entirely (do not
   ship an empty heading). See template L48-61.
4. `## 4. Analysis` — themes with the research-question / what-the-evidence-says /
   consensus / contested / gaps / institutional-vs-ground-truth structure. See
   template L65-92.
5. `## 5. Research` — full findings by topic area, with per-source citations including
   score band and evidence level in brackets. See template L96-106.
6. `## 6. Methodology` — see `references/methodology-section-template.md`. MUST include
   all required subsections: research design, search-log table, source-evaluation
   framework, inclusion/exclusion summary + all four distribution tables (evidence level,
   source category, credibility score), perspective-balance matrix, bias-guard summary,
   limitations.
7. `## 7. Bibliography` — every included source with full citation, score band,
   evidence level, inclusion decision, and one-line contribution summary. See template
   L119-134.

**Writing order** (not the same as reading order — write in this order, then assemble in
the §1-§7 order above):
1. Write the Research section (§5) first — organized findings by topic.
2. Write the Analysis section (§4) — synthesis, patterns, contradictions.
3. Write the Framework section (§3) if applicable.
4. Write the Methodology section (§6) using `references/methodology-section-template.md`.
5. Write the Bibliography (§7).
6. Write the Recommendations (§1) — what to DO based on all of the above.
7. Write the Summary (§2) LAST — hardest to write, requires distilling everything.

**Language rules (enforced by the Reading-Deliverable Standard — `../reading-deliverable-standard.md`,
clause 1).** These are not aspirational; the `ai-scoring` ≥ 75 gate above checks them:
- ELI10 throughout — clear, not condescending. Plain words over long ones.
- Define every term AND every acronym inline on first use. An undefined acronym is a defect.
- A short top-of-document Glossary (≤ ~12 terms) for the unavoidable jargon the report leans on.
- Concrete examples over abstractions.
- Show the tension (where experts disagree is more interesting than where they agree).
- No orphaned claims — every factual statement has a citation.

**Bias-guard summary required in the deliverable.** Per-card bias-guard checkboxes are
not enough. The §6 Methodology section MUST contain a Bias-Guard Summary table reporting
how many sources fired the agree-with check, how many fired the disagree-with check, and
how many were neutral (see `references/methodology-section-template.md`). This pulls the
bias-guard discipline up from per-source bookkeeping to deliverable-level accountability —
if the agree-with count dwarfs the disagree-with count, the reader can see the asymmetry
and weight conclusions accordingly.

**Confirmation-skew gate (Directive 03 — advisory now, blocking later).** When the
Bias-Guard Summary's agree:disagree ratio exceeds `3:1` (e.g. eating-out's 27:3,
agent-teams' 10:2), the run carries a confirmation-skew risk the methodology cannot
self-correct — the same agent scored the source AND decided whether it "agreed," so the
guard is self-graded confirmation bias with a paper trail. A `>3:1` skew REQUIRES two
remediations: (a) a deliberate FALSIFICATION query in the Phase 2 search plan, and (b) a
`### Steel-man the contrarian` subsection in Phase 4. The executable gate reads the two
Bias-Guard counts and, on a `>3:1` skew, raises warning W2: it footnotes whichever
remediation is missing, and even when both are present it flags the skew as a research-
design risk the reader should weight. W2 is a footnote/warning first — it does NOT block.

**Required-artifacts verification (Deliverable Manifest).** Before declaring the research
complete, verify each item below exists on disk. Do not present the deliverable to the user
until every box is checked:

- [ ] Final document file at `[project]/docs/research/<YYYY-MM-DD>-<slug>/analysis.md`,
      containing numbered top-level sections **§1 Recommendations, §2 Summary, §3 Framework
      (if applicable), §4 Analysis, §5 Research, §6 Methodology, §7 Bibliography — in that order**.
- [ ] **Reading-Deliverable Standard satisfied** (`../reading-deliverable-standard.md`):
      `Generated: YYYY-MM-DD` is the first line; every term/acronym is defined inline on first use;
      a top-of-document Glossary covers the unavoidable jargon; the `noah-voice` pass was applied and
      the `ai-scoring` pass scored **≥ 75** (score recorded in the document).
- [ ] **Epub generated** with pandoc (date in `--metadata date=`) and saved under
      `~/Documents/Claude/<Project>/` (project) or `~/Documents/Personal/<area>/` (personal) with a
      human-readable title — UNLESS the user explicitly opted out. Both the markdown path and the epub
      path were told to the user.
- [ ] One source-card file per evaluated source at
      `[project]/docs/research/sources/<topic>-<slug>.md`, using the exact template
      from `references/source-card-template.md` (table format for the 10 scores, bias-guard
      checkboxes, inclusion-decision section, perspective-category field). Inline summaries
      inside the analysis document do NOT count.
- [ ] §6 Methodology contains every required subsection from
      `references/methodology-section-template.md`: the search-log table, evidence-level
      distribution table, source-category distribution table, credibility-score distribution
      table, and perspective-balance matrix. A "Methodology Gaps" / limitations-only section
      is non-compliant.
- [ ] §6 Methodology includes a Bias-Guard Summary (counts of sources that fired the
      agree-with check, the disagree-with check, and the neutral box).
- [ ] §7 Bibliography lists every included source with score band, evidence level,
      inclusion decision, and a one-line contribution summary.
- [ ] Source counts reconcile: source-card files on disk == sources reported in the
      methodology counts == sources cited in §5 Research. If the three counts disagree,
      something was dropped silently — investigate before proceeding.
- [ ] Citation verification report exists at `docs/research/[date]/verification-report.md`
      with documented failure rate ≤5%. The report must include sample size, per-card
      outcomes, and the aggregate verified/failed/inaccessible counts (see Phase 3.5).
      If the rate is >5%, you are not done — return to Phase 3.5 and remediate.
      **This box is checked by the executable gate, not by you.** The `Stop`-hook
      verifier (`hooks/deep-research-verify.sh`) asserts this item plus the report's
      distinct verifier ID, canonical band, and per-card enum/quote-heading facts, and
      hard-blocks the deliverable on any failure. If Task-tool spawning was unavailable
      and the deliverable is stamped `UNVERIFIED — self-check only`, the gate fails and
      the run is presented as NOT fact-checked — that is the correct, honest outcome.

If any box is unchecked, return to the relevant phase and fix the gap. Do not skip to
user presentation with an unchecked box.

**Checkpoint:** Once the Deliverable Manifest is fully checked, present the draft to the
user for feedback before finalizing.

---

## Multi-Session Research

For large research projects spanning multiple sessions:

1. **Checkpoint after each session** using the project's checkpointing system
2. **Store intermediate drafts** in `[project]/docs/research/drafts/` with session identifiers
3. **Store completed source cards** in `[project]/docs/research/sources/`
4. **The source evaluation rubric is the continuity mechanism** — scores from Session B are
   comparable to scores from Session D because both use the same anchored rubric
5. **Begin each new session** by reading the previous session's draft and source cards to
   restore context

---

## Quick Reference: Lazy-Load Map (Directive 04)

This table is the lazy-load contract: load each reference at the phase that consumes it, NOT all
up front. Only the card-field skeleton and the §1–§7 outline carry inline (see "Before You
Begin"). The 14k-token up-front pre-load wall is removed.

| I need to... | Load... | At phase |
|--------------|---------|----------|
| See a worked example (optional) | `example-evaluation.md` | Phase 1 (optional) |
| Classify evidence type | `evidence-hierarchy.md` | Phase 2 / Phase 3 |
| Triage keep/cut, then score a source | `source-evaluation-rubric.md` | Phase 3 |
| Fill out a source evaluation card | `source-card-template.md` | Phase 3 |
| Decide keep/throw (final inclusion) | `inclusion-decision-matrix.md` | Phase 4 |
| Structure the final document | `research-document-template.md` | Phase 6 |
| Write the methodology section | `methodology-section-template.md` | Phase 6 |
