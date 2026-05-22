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

Read these reference documents. They are the operating manual — this SKILL.md is the overview.

1. `references/source-evaluation-rubric.md` — 10-dimension scoring system with anchors
2. `references/evidence-hierarchy.md` — 9-level evidence classification
3. `references/source-card-template.md` — per-source evaluation card format
4. `references/inclusion-decision-matrix.md` — keep/throw decision tree with override rules
5. `references/research-document-template.md` — final document structure and language guide
6. `references/methodology-section-template.md` — "show your work" section structure
7. `references/example-evaluation.md` — worked example evaluating Morgan Housel's
   "The Psychology of Money"

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
`references/source-card-template.md`).

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

Produce the final deliverable using `references/research-document-template.md`.

**Writing order** (not the same as reading order):
1. Write the Research section first (organized findings by topic)
2. Write the Analysis section (synthesis, patterns, contradictions)
3. Write the Framework section if applicable
4. Write the Methodology section (using `references/methodology-section-template.md`)
5. Write the Bibliography
6. Write the Recommendations (what to DO based on all of the above)
7. Write the Summary LAST (hardest to write — requires distilling everything)

**Language rules** (from the document template):
- ELI10 throughout — clear, not condescending
- Define every term on first use
- Concrete examples over abstractions
- Show the tension (where experts disagree is more interesting than where they agree)
- No orphaned claims — every factual statement has a citation

**Checkpoint:** Present the draft to the user for feedback before finalizing.

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
