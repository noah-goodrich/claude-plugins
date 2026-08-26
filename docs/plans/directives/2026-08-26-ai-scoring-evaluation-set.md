# Directive: Rebuild the ai-scoring Evaluation Set

*Filed: 2026-08-26 · Status: Proposed · Parent: none*

**tl;dr** — `ai-scoring` cannot measure whether it detects machine-written prose, because the negative half of its
corpus was written out of its own banned-word lists. Build an evaluation set with known provenance — model-written
negatives matched on topic and length, plus Noah's unedited voice from session transcripts — then recalibrate
against it.

## Problem

The article path flags 5 of Noah's 10 published articles as machine-written. Precision 0.500, f1 0.667,
reproduced 2026-08-26. The immediate cause is arithmetic: the gate is 75 and his corpus median is 75.5, so roughly
half fails whatever he writes.

The deeper problem is that **none of the accuracy numbers mean anything.** The five negative samples are
keyword-stuffed from the rubric's own lists — 7.14-8.33 rubric hits per 100 words, against 0.00-0.55 in his real
articles. Ablation settles it: the literal word-matching categories alone separate the classes at AUC 1.000, while
the structural categories alone reach 0.220, worse than chance. Recall of 1.000 restates how the fixtures were
written. Held out against five real agent-authored documents in this repo, the best-fitting threshold catches
3 of 5 and the in-sample-perfect rule catches 1 of 5.

Three further defects compound it. **Length is a second contamination**: the fixtures run 390-430 words against
his 739-2,595, and word count alone separates the classes at AUC 1.000, so every unnormalised counter inherits it.
**The sample cannot fit anything**: a 95% Wilson interval on an observed 1-in-10 false-positive rate spans 2% to
40%, and roughly 74 candidate rules were evaluated against 15 documents. **The deployed population is in neither
class** — the gate runs on Claude drafting in Noah's voice, which appears in no fixture and no published article.

The harm is measured, not hypothetical. Across his five most recent articles, em dashes per thousand words run
7.4 → 3.1 → 2.6 → 0.0 → 0.5 and standalone-paragraph share runs 0.50 → 0.38 → 0.24 → 0.12 → 0.06. Cat 1
still fires on all ten articles including the collapsed ones. He gave up the em dash and most of his rhythm and it
bought him nothing.

One finding points at the fix. Standalone paragraphs are **not** one feature. His carry a number or a named thing
59% of the time; the fixtures 0%. Theirs announce that something is coming ("Furthermore, teams should consider
the following:"); his are the thing itself.

## Solution

- **S1 — Generate negatives with known provenance.** Several current models write articles on Noah's topics, at
  his lengths, under normal prompting. No "write like AI" instruction and no banned-word seeding. This fixes both
  contaminations at once, because provenance is known and length is controlled.
- **S2 — Extract Noah's voice from session transcripts.** 1,437 transcripts across 24 projects, 571 MB. His
  messages only. This material predates the gate, so it is uncontaminated by the style collapse above, and it is
  unedited. Treat it as evidence of what is invariant across genres, not as a substitute for more article samples.
- **S3 — Replace the standalone-paragraph count with a content test.** A standalone line counts as a tell only
  when it is content-free. `portable-voice.md` rule 5 already states this and the 2026-05-23 validation report
  already recommended it; nobody implemented it. Separate it from the banned-transition category, which currently
  absorbs part of the same signal.
- **S4 — Recalibrate against the rebuilt set and report per category.** One number hides which lever to pull; for
  four of the five false positives, four different categories each independently clear the gate.
- **S5 — Revisit the auto-revise loop.** `snowflake-article/SKILL.md:15` calls 75 "a hard threshold, not a
  suggestion" and its Quality Gate says to rewrite flagged passages and re-score until passing, before Noah sees
  the draft. Decide that after S4, when the grader is worth acting on.

## Acceptance criteria

- [ ] AC1 The negative set has known provenance: at least 20 model-written articles from 3+ current models,
      matched to the human set on topic and length, with the generating prompt recorded per file.
  - Verify: word-count distributions of the two classes overlap; word count alone no longer separates them.
- [ ] AC2 The rubric's banned-word lists do not appear at fixture density in the negatives.
  - Verify: rubric-term hits per 100 words in the new negatives fall inside the range measured for real writing
    (0.00-0.55), not the fixture range (7.14-8.33).
- [ ] AC3 A voice corpus extracted from session transcripts exists, containing Noah's messages only, with no
      credentials, private paths, or third-party content.
  - Verify: an extraction script plus a reviewed sample; `PRIVACY-AUDIT-2026-05-23.md` boundaries applied.
- [ ] AC4 The standalone-paragraph rule tests content, not count, and is measured independently of the
      banned-transition category.
  - Verify: on the current corpus it fires on 0 of 10 human articles and a majority of negatives; the payload
    measurement (59% versus 0%) is reproduced by the shipped implementation.
- [ ] AC5 Recalibration is reported per category with its uncertainty, and no single threshold is asserted without
      a confidence interval.
  - Verify: a baseline file records per-category rates for both classes; every headline rate carries an interval.
- [ ] AC6 `ai_score.py` and the rubric prose are linked by a test, so the scorer cannot silently drift from the
      skill it claims to implement.
  - Verify: a test asserts the category set and threshold in code match the prose; it runs in CI.

## Non-Goals

- **Not scraping Medium or LinkedIn for suspected-AI articles.** Provenance is unknowable by reading, which is the
  central research finding; a set built from "looks AI to me" bakes in the prior this directive exists to remove.
- **Not reviving the dual-axis redesign.** Closed 2026-08-26 as superseded by measurement.
- **Not committing raw session transcripts.** Only extracted, filtered text lands in the repo.
- **Not changing the 75 constant** until the evaluation set exists. It is duplicated across ~15 lines in 8 files
  and every current justification for moving it is fitted to the contaminated corpus.
- **Not changing the auto-revise loop in this directive.** S5 names it; the decision follows S4.

## Alternatives Considered

- **Ship the two-category disable now.** Rejected: its f1 of 1.00 is fitted to the contaminated fixture, and the
  step from "stop subtracting" to "stop looking" needs a recall claim this corpus cannot support.
- **Invert category 1 against an author floor.** Rejected by measurement: the ranges overlap by 6.1 points (his
  13.9-87.0% against the fixtures' 8.3-20.0%), and a floor rule works only when placed at exactly his observed
  minimum, which is a rule tuned to one document.
- **Author-anchored percentile gate.** Rejected: a percentile is a quota that flags a fixed fraction forever, and
  the within-human ordering is driven by the inverted category, so it would flag his most characteristic writing.
- **Public benchmarks only (M4, RAID).** Partial credit, not sufficient: known provenance but stale model prose
  and the wrong genre. Usable for breadth alongside S1, not instead of it.
- **Retire the score for severity tiers, as every comparable linter does.** Probably the right end state, and
  deferred rather than rejected: the party reading the tiers today is the agent that wrote the prose, which makes
  it self-certification. Revisit after S5.
- **Do nothing.** Rejected: the style collapse above is measured, and the gate is currently unwinnable by
  arithmetic.

## Decisions requested

- [ ] **Privacy boundary for S2.** How much filtering before extracted transcript text may be committed, and does
      any of it leave this machine?
- [ ] **One score or per-category output.** S4 assumes per-category reporting, which changes what eight consumers
      read. Confirm, or keep the single number and accept that it cannot say what to fix.
- [ ] **Whether S5 waits.** The auto-revise loop can be changed today at no measurement cost, since it is a
      question of who decides rather than of accuracy. Sequencing it after S4 is a judgement call, not a
      constraint.
