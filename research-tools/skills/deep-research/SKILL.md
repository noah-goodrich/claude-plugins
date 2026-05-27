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

## Before You Begin

**Reference loading is mandatory.** Before doing any research — before Phase 1, before
any search, before any source evaluation — load ALL SEVEN reference documents into
context. The references are not optional reading; they are the operational contract. If
you skip a reference because the task "feels small" or "is obvious," you will skip the
structure that reference enforces, and the deliverable will fail the Phase 6 manifest
check.

Verify each reference has been read before proceeding:

- [ ] 1. `references/source-evaluation-rubric.md` — 10-dimension scoring system with anchors
- [ ] 2. `references/evidence-hierarchy.md` — 9-level evidence classification
- [ ] 3. `references/source-card-template.md` — per-source evaluation card format
- [ ] 4. `references/inclusion-decision-matrix.md` — keep/throw decision tree with override
      rules
- [ ] 5. `references/research-document-template.md` — final document structure and language
      guide
- [ ] 6. `references/methodology-section-template.md` — "show your work" section structure
- [ ] 7. `references/example-evaluation.md` — worked example evaluating Morgan Housel's
      "The Psychology of Money"

Do not start Phase 1 until every box above is checked. SKILL.md is the overview; the
references are the manual.

---

## The Pipeline

### Phase 1: Research Design

Before searching for anything, define:

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

For every source pulled from discovery, complete a source evaluation card (see
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

4. **Calculate the composite score** using the weighted formula in the rubric

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
the purpose).

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
   misattributed is a failure.
4. **Confirms location reference.** The page/section/timestamp/paragraph offset on
   the card must point to the actual location of the quote. Off-by-one paragraph is
   acceptable; "wrong section entirely" is a failure.

**Per-card outcome.** Exactly one of: `verified` / `failed` / `inaccessible`. No
"partial credit." Borderline cases default to `failed` — the verifier is the
adversarial check, not a sympathetic reviewer.

**Verification report.** Write the report to
`docs/research/[date]/verification-report.md`. Required contents:

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
3. **Document as access-limited.** If the failure is genuinely an access problem (the
   source changed, the URL now redirects, the paywall hardened), reclassify the card's
   `Access` field to `cached/partial` with a note explaining what changed. Then re-run
   verification — the reclassified card now counts as `inaccessible` rather than
   `failed`, and may bring the rate under 5%.

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

---

### Phase 5: Synthesis

With included sources identified and scored, synthesize findings.

**Weighting:** When multiple sources address the same question, weight their contributions
by composite credibility score. A source scoring 8.5 carries more weight than one scoring 5.2,
but both contribute.

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

Produce the final deliverable at `[project]/docs/research/analysis.md` (or a named
equivalent under `[project]/docs/research/`) using
`references/research-document-template.md`.

**The document MUST contain the following top-level headings, in this exact order. Do
not invent new top-level sections that displace these seven, and do not reorder them:**

1. `## 1. Recommendations` — actionable bullets, each starting with a verb, each
   referencing the analysis section that backs it. See template L17-30.
2. `## 2. Summary` — the "tired dad at 4am" version (2-3 pages max). See template L34-44.
3. `## 3. [Domain-Specific Framework]` — include ONLY if a framework, typology, or model
   emerged from the research. If no framework emerged, omit this section entirely (do not
   ship an empty heading). See template L48-61.
4. `## 4. Analysis` — themes with the research-question / what-the-evidence-says /
   consensus / contested / gaps / institutional-vs-ground-truth structure. See
   template L65-92.
5. `## 5. Research` — full findings by topic area, with per-source citations including
   composite score and evidence level in brackets. See template L96-106.
6. `## 6. Methodology` — see `references/methodology-section-template.md`. MUST include
   all required subsections: research design, search-log table, source-evaluation
   framework, inclusion/exclusion summary + all four distribution tables (evidence level,
   source category, credibility score), perspective-balance matrix, bias-guard summary,
   limitations.
7. `## 7. Bibliography` — every included source with full citation, composite score,
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

**Language rules** (from the document template):
- ELI10 throughout — clear, not condescending
- Define every term on first use
- Concrete examples over abstractions
- Show the tension (where experts disagree is more interesting than where they agree)
- No orphaned claims — every factual statement has a citation

**Bias-guard summary required in the deliverable.** Per-card bias-guard checkboxes are
not enough. The §6 Methodology section MUST contain a Bias-Guard Summary table reporting
how many sources fired the agree-with check, how many fired the disagree-with check, and
how many were neutral (see `references/methodology-section-template.md`). This pulls the
bias-guard discipline up from per-source bookkeeping to deliverable-level accountability —
if the agree-with count dwarfs the disagree-with count, the reader can see the asymmetry
and weight conclusions accordingly.

**Required-artifacts verification (Deliverable Manifest).** Before declaring the research
complete, verify each item below exists on disk. Do not present the deliverable to the user
until every box is checked:

- [ ] Final document file at `[project]/docs/research/analysis.md` (or a named equivalent
      under `[project]/docs/research/`), containing numbered top-level sections
      **§1 Recommendations, §2 Summary, §3 Framework (if applicable), §4 Analysis,
      §5 Research, §6 Methodology, §7 Bibliography — in that order**.
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
- [ ] §7 Bibliography lists every included source with composite score, evidence level,
      inclusion decision, and a one-line contribution summary.
- [ ] Source counts reconcile: source-card files on disk == sources reported in the
      methodology counts == sources cited in §5 Research. If the three counts disagree,
      something was dropped silently — investigate before proceeding.
- [ ] Citation verification report exists at `docs/research/[date]/verification-report.md`
      with documented failure rate ≤5%. The report must include sample size, per-card
      outcomes, and the aggregate verified/failed/inaccessible counts (see Phase 3.5).
      If the rate is >5%, you are not done — return to Phase 3.5 and remediate.

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

## Quick Reference: When to Use Each Reference Document

| I need to... | Read... |
|--------------|---------|
| Score a source | `source-evaluation-rubric.md` |
| Classify evidence type | `evidence-hierarchy.md` |
| Fill out a source evaluation | `source-card-template.md` |
| Decide keep/throw | `inclusion-decision-matrix.md` |
| Structure the final document | `research-document-template.md` |
| Write the methodology section | `methodology-section-template.md` |
| See a worked example | `example-evaluation.md` |
