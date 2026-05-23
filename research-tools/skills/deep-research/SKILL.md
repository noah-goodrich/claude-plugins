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
