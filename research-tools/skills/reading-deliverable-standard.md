# Reading-Deliverable Standard

**Scope: any skill that produces something a human is meant to READ** — a research report, a
brainstorm document, a strategic brief, a synthesis, an analysis. If the output is prose a person
will sit down and read (not code, not a config file, not a one-line answer in chat), this standard is
MANDATORY and the producing skill MUST enforce every clause below before presenting the deliverable.

This file exists because a reading deliverable shipped that was nearly unreadable: dense with
undefined acronyms, assumed prior knowledge, and carried no generation date. Noah's global rules
already require human-readable, define-as-you-go writing and an `ai-scoring` pass before ANY written
content is presented — the research/brainstorm pipelines simply were not enforcing it. This standard
is the enforcement contract the pipelines reference.

The four clauses are non-negotiable. A deliverable that misses any one is NOT done.

---

## 1. Readability — plain language, assume NO prior knowledge

The reader is a smart, tired person who does NOT work on this problem and does NOT know your jargon.
Write for them.

- **ELI10 throughout.** Explain like the reader is ten: clear, not condescending. Short words over
  long ones, concrete examples over abstractions. "A way of changing a photo that adjusts colour
  pixel-by-pixel but never moves anything" beats "a geometry-preserving luminance map" — and if you
  use the technical term, you define it like that the FIRST time it appears.
- **Define every term AND every acronym on first use, inline.** The first time `ITA`, `MST`, `VLM`,
  `RAW`, `ICP`, or any project-specific term appears, expand it in parentheses or a clause right
  there. No exceptions. An undefined acronym is a defect.
- **Include a short Glossary block near the TOP** for the handful of unavoidable jargon terms the
  document leans on repeatedly (aim for ≤ 12 terms). The Glossary repeats the inline definitions so a
  skimmer can keep them in their head; it does NOT replace defining inline.
- **Show the tension.** Lead with where experts disagree or where the obvious answer is wrong — that
  is what the reader needs, more than a recitation of consensus.
- **No orphaned claims.** Every factual statement carries a citation or is clearly marked as the
  author's synthesis/opinion.

### Readability is enforced by two MANDATORY passes — not by good intentions

Before finalizing ANY reading deliverable, run BOTH, in this order, on the FINAL document text:

1. **`noah-voice`** (noah-writing-voice plugin) — applies Noah's voice rules: no em dashes, no banned
   words ("genuinely", "straightforward", "leverage", "navigate", "landscape", "delve", etc.), no AI
   transitions, specific details over vague claims. Apply its rules during writing, then self-check.
2. **`ai-scoring`** (noah-writing-voice plugin) — scores the prose 0–100 for how human vs. AI it
   reads and flags specific AI tells with line-level citations. **A reading deliverable must score ≥
   75 before it is presented.** If it scores below 75, revise against the flagged passages and
   re-score. Record the final score in the document (a one-line footer is fine:
   `AI-scoring: 84/100`).

These two passes are the same gate Noah's global rules already require before presenting ANY written
content. The research/brainstorm pipelines now invoke them explicitly so the requirement is not
silently skipped.

---

## 2. Date — `Generated:` line at the very top, and in epub metadata

- **Every produced document MUST begin with a `Generated: YYYY-MM-DD` line at the very top** (first or
  second line, above or just under the title). Use today's date. A reader must be able to tell, at a
  glance, how fresh the document is — the missing date is exactly what made the failed reveal report
  untrustworthy.
- **The same date MUST go into the epub metadata** via `pandoc --metadata date=YYYY-MM-DD` (see clause
  3). The on-page date and the epub metadata date must match.

---

## 3. Epub by default — generate an epub unless the user opts out

Any skill producing a reading deliverable generates an epub from the final markdown **by default**.
Noah reads long-form on an e-reader; a markdown file in a repo is not how he reads. Skip epub
generation ONLY if the user explicitly opts out (e.g. "no epub", "markdown only").

Generate it with pandoc after the markdown is finalized and has passed the readability passes:

```bash
pandoc "<markdown-path>" \
  -o "<epub-path>" \
  --metadata title="<Human Readable Title>" \
  --metadata author="Claude (deep-research)" \
  --metadata date="<YYYY-MM-DD>" \
  --toc --toc-depth=2
```

`pandoc` is installed (`/opt/homebrew/bin/pandoc`). If for some reason it is unavailable, say so
explicitly and offer to install it (`brew install pandoc`) rather than silently skipping the epub.

---

## 4. Pathing — markdown in the repo, epub under `~/Documents/`

State this explicitly to the user when you save.

- **Markdown deliverables live IN the relevant repo**, under the convention the skill already uses:
  - deep-research → `<repo>/docs/research/<YYYY-MM-DD>-<slug>/analysis.md`
  - brainstorm → `<repo>/docs/brainstorms/<YYYY-MM-DD>-<slug>.md`
  The markdown is the source of record and is version-controlled with the project.

- **Epubs live under `~/Documents/`**, mirroring the EXISTING convention (do not invent a new one):
  - **Project work → `~/Documents/Claude/<Project>/<Human Readable Title>.epub`.** Example: reveal
    research already lands at `~/Documents/Claude/reveal/People Photo First Principles.epub`. Match the
    capitalization of the existing `~/Documents/Claude/<Project>/` folder for the project.
  - **Personal (non-project) work → `~/Documents/Personal/<area>/<Human Readable Title>.epub`** (e.g.
    `~/Documents/Personal/Reading/`). Use a human-readable title for the epub filename, not the
    hyphenated slug.

If you cannot determine the project, ask which `~/Documents/Claude/<Project>/` folder to use rather
than guessing.

---

## Producer checklist (the skill checks every box before presenting)

- [ ] `Generated: YYYY-MM-DD` line at the very top of the markdown.
- [ ] Every acronym/term defined inline on first use; a top-of-document Glossary for the unavoidable
      jargon.
- [ ] `noah-voice` pass applied to the final text.
- [ ] `ai-scoring` pass run on the final text; score ≥ 75; score recorded in the document.
- [ ] Markdown saved to the repo path for this skill (`docs/research/...` or `docs/brainstorms/...`).
- [ ] Epub generated with pandoc (date in `--metadata date=`) UNLESS the user opted out.
- [ ] Epub saved under `~/Documents/Claude/<Project>/` (project) or `~/Documents/Personal/<area>/`
      (personal), with a human-readable title.
- [ ] You told the user both paths (markdown + epub).
