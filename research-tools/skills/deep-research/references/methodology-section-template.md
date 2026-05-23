# Methodology Section Template

This section goes in the final research document. It answers: "How did you decide what to
include and exclude?" It's the "show your work" section — the reader should be able to follow
your process and understand every decision.

---

## Required subsections — all must be present in the final deliverable

A Methodology section that contains only "Methodology Gaps" or a limitations paragraph is
**non-compliant**. The final §6 Methodology MUST contain every subsection below; bullet
lists are not substitutes for the required tables.

- [ ] **Research Design** — research questions, scope boundaries (in/out), target audience,
      methodology version.
- [ ] **Source Discovery** — search strategy, source-diversity targets, and a **search-log
      TABLE** (not prose). One row per query.
- [ ] **Source Evaluation** — evaluation framework reference, evidence-classification
      reference, and the bias guards applied.
- [ ] **Inclusion/Exclusion Results** — the summary counts table, the **evidence-level
      distribution table**, the **source-category distribution table**, and the
      **credibility-score distribution table**. All four tables required.
- [ ] **Perspective Balance** — the per-topic matrix table (rows: topic areas, columns:
      Academic / Institutional / Practitioner / Boots / Contrarian).
- [ ] **Bias-Guard Summary** — counts of sources where the agree-with box fired, the
      disagree-with box fired, and neutral. Forces card-level bias guards up to deliverable
      accountability.
- [ ] **Limitations** — honest accounting of what this methodology cannot do.

---

```markdown
## 6. Methodology

### Research Design

**Research questions:**
1. [Primary question]
2. [Secondary question(s)]

**Scope boundaries:**
- In scope: [what was included]
- Out of scope: [what was explicitly excluded, and why]

**Target audience:** [who will read this and what they need from it]

**Methodology version:** deep-research v[X.Y.Z]

### Source Discovery

**Search strategy:**
- [N] search queries executed across [date range]
- Databases/platforms searched: [list — e.g., Google Scholar, web search, specific
  publications, community forums]
- Source diversity targets: academic, institutional, practitioner, boots-on-the-ground,
  contrarian

**Search log:**

| # | Query | Results found | Sources pulled for evaluation |
|---|-------|---------------|------------------------------|
| 1 | [query text] | [N] | [N] |
| 2 | [query text] | [N] | [N] |
| ... | ... | ... | ... |

**Total sources discovered:** [N]
**Total sources pulled for evaluation:** [N]

### Source Evaluation

**Evaluation framework:** 10-dimension credibility rubric (see source-evaluation-rubric.md)

**Evidence classification:** 9-level hierarchy (see evidence-hierarchy.md)

**Bias guards applied:**
- Confirmation bias check on every source (score harder when agreeing, gentler when
  disagreeing, on dimensions 5, 6, and 8)
- Triangulation rule: no claim accepted from a single source type

**Bias-Guard Summary** *(required — aggregates per-card bias-guard checkboxes):*

| Bias-guard outcome | Count |
|--------------------|-------|
| Agreed with source — scored harder on dims 5, 6, 8 | [N] |
| Disagreed with source — scored more generously on dims 5, 6, 8 | [N] |
| Neutral / no strong reaction | [N] |
| **Total sources evaluated** | [N] |

### Inclusion/Exclusion Results

**Summary:**

| Category | Count |
|----------|-------|
| Total sources evaluated | [N] |
| Included — Core | [N] |
| Included — Supporting | [N] |
| Excluded | [N] |
| Overrides applied | [N] |

**Distribution by evidence level:**

| Level | Description | Count |
|-------|-------------|-------|
| 1 | Systematic review / meta-analysis | [N] |
| 2 | RCT | [N] |
| 3 | Large-scale observational | [N] |
| 4 | Expert consensus / professional body | [N] |
| 5 | Practitioner case study | [N] |
| 6 | Qualitative research | [N] |
| 7 | Expert opinion / thought leadership | [N] |
| 8 | Anecdotal / personal experience | [N] |
| 9 | Marketing / promotional | [N] |

**Distribution by source category:**

| Category | Included | Excluded |
|----------|----------|----------|
| Academic | [N] | [N] |
| Institutional | [N] | [N] |
| Practitioner | [N] | [N] |
| Boots-on-the-ground | [N] | [N] |
| Contrarian | [N] | [N] |

**Distribution by credibility score:**

| Score range | Count | Disposition |
|-------------|-------|-------------|
| 7.0 – 10.0 | [N] | [N] included, [N] excluded |
| 5.0 – 6.9 | [N] | [N] included, [N] excluded |
| 3.0 – 4.9 | [N] | [N] included, [N] excluded |
| 0.0 – 2.9 | [N] | [N] included, [N] excluded |

### Perspective Balance

[For each major topic area, note which of the 5 source categories are represented among
included sources. Flag any gaps and explain why.]

| Topic area | Academic | Institutional | Practitioner | Boots | Contrarian |
|------------|----------|---------------|--------------|-------|------------|
| [Topic 1] | [Y/N] | [Y/N] | [Y/N] | [Y/N] | [Y/N] |
| [Topic 2] | [Y/N] | [Y/N] | [Y/N] | [Y/N] | [Y/N] |
| ... | ... | ... | ... | ... | ... |

### Limitations

[Honest accounting of what this methodology CANNOT do:]

- [e.g., "Web search surfaces SEO-optimized content disproportionately, which may
  underrepresent academic sources not published online"]
- [e.g., "Paywalled journal articles were accessible only via abstracts, which may have
  caused relevant findings to be missed"]
- [e.g., "The researcher's existing knowledge of [topic] may have influenced search query
  design, introducing selection bias at the discovery stage"]
- [e.g., "Credibility scoring is applied by a single evaluator without inter-rater
  reliability checks"]
```
