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

- **S1 — Stop the auto-revise loop. Do this first, ahead of any measurement.**
  `snowflake-article/SKILL.md:15` calls 75 "a hard threshold, not a suggestion" and its Quality Gate says to
  rewrite flagged passages and re-score until passing, before Noah sees the draft. `linkedin-post` repeats the
  pattern. Change both to present the draft with its flags attached and never revise to clear a threshold. This is
  a question of who decides, so no corpus can validate or invalidate it, and every article written before it lands
  is silently sanded toward a rubric that is known to be wrong.
- **S2 — Generate negatives with known provenance.** Several current models write articles on Noah's topics, at
  his lengths, under normal prompting. No "write like AI" instruction and no banned-word seeding. This fixes both
  contaminations at once, because provenance is known and length is controlled.
- **S3 — Extract Noah's voice from session transcripts, numbers in the repo and text on disk.** 1,437 transcripts
  across 24 projects, 571 MB. His messages only, extracted locally. Derived measurements are committed; the raw
  extracted text stays gitignored and never leaves the machine. This material predates the gate, so it is
  uncontaminated by the style collapse above, and it is unedited. Treat it as evidence of what is invariant across
  genres, not as a substitute for more article samples.
- **S4 — Replace the standalone-paragraph count with a content test.** A standalone line counts as a tell only
  when it is content-free. `portable-voice.md` rule 5 already states this and the 2026-05-23 validation report
  already recommended it; nobody implemented it. Separate it from the banned-transition category, which currently
  absorbs part of the same signal.
- **S5 — Recalibrate against the rebuilt set, reporting per category alongside the existing number.** One number
  hides which lever to pull; for four of the five false positives, four different categories each independently
  clear the gate. The single score is retained as a summary so the eight consumers that read it keep working, but
  it stops being the verdict.

## Acceptance criteria

- [ ] AC1 The negative set has known provenance: at least 20 model-written articles from 3+ current models,
      matched to the human set on topic and length, with the generating prompt recorded per file.
  - Verify: word-count distributions of the two classes overlap; word count alone no longer separates them.
- [ ] AC2 The rubric's banned-word lists do not appear at fixture density in the negatives.
  - Verify: rubric-term hits per 100 words in the new negatives fall inside the range measured for real writing
    (0.00-0.55), not the fixture range (7.14-8.33).
- [ ] AC3 A voice corpus is extracted from session transcripts under the two-tier rule: only derived measurements
      are committed, and the raw extracted text is gitignored and stays on the machine.
  - Verify: the repo contains distributions and rates but no transcript prose; `git check-ignore` covers the raw
    directory; the extraction script makes no network call; `PRIVACY-AUDIT-2026-05-23.md` boundaries applied.
- [ ] AC7 The auto-revise loop is gone. `snowflake-article` and `linkedin-post` present drafts with flags rather
      than revising to clear a threshold.
  - Verify: neither file instructs re-scoring until passing; `grep` for "hard threshold" and "until passing"
    returns nothing in either skill.
- [ ] AC4 The standalone-paragraph rule tests content, not count, and is measured independently of the
      banned-transition category.
  - Verify: on the current corpus it fires on 0 of 10 human articles and a majority of negatives; the payload
    measurement (59% versus 0%) is reproduced by the shipped implementation.
- [ ] AC5 Recalibration is reported per category with its uncertainty, the single score is retained as a summary
      rather than a verdict, and no threshold is asserted without a confidence interval.
  - Verify: a baseline file records per-category rates for both classes; every headline rate carries an interval;
    the eight consumers that read the single number still resolve without edits.
- [ ] AC6 `ai_score.py` and the rubric prose are linked by a test, so the scorer cannot silently drift from the
      skill it claims to implement.
  - Verify: a test asserts the category set and threshold in code match the prose; it runs in CI.

## Non-Goals

- **Not scraping Medium or LinkedIn for suspected-AI articles.** Provenance is unknowable by reading, which is the
  central research finding; a set built from "looks AI to me" bakes in the prior this directive exists to remove.
- **Not reviving the dual-axis redesign.** Closed 2026-08-26 as superseded by measurement.
- **Not committing transcript prose in any form.** Derived measurements only. The raw extraction is gitignored,
  stays local, and no part of it is sent anywhere.
- **Not changing the 75 constant** until the evaluation set exists. It is duplicated across ~15 lines in 8 files
  and every current justification for moving it is fitted to the contaminated corpus. S1 removes the constant's
  power without moving it, which is why S1 does not have to wait.
- **Not retiring the single score.** S5 demotes it to a summary and keeps it, because eight consumers read it.
  Retiring it entirely is a separate decision, deferred below.

## Alternatives Considered

- **Ship the two-category disable now.** Rejected: its f1 of 1.00 is fitted to the contaminated fixture, and the
  step from "stop subtracting" to "stop looking" needs a recall claim this corpus cannot support.
- **Invert category 1 against an author floor.** Rejected by measurement: the ranges overlap by 6.1 points (his
  13.9-87.0% against the fixtures' 8.3-20.0%), and a floor rule works only when placed at exactly his observed
  minimum, which is a rule tuned to one document.
- **Author-anchored percentile gate.** Rejected: a percentile is a quota that flags a fixed fraction forever, and
  the within-human ordering is driven by the inverted category, so it would flag his most characteristic writing.
- **Public benchmarks only (M4, RAID).** Partial credit, not sufficient: known provenance but stale model prose
  and the wrong genre. Usable for breadth alongside S2, not instead of it.
- **Retire the score for severity tiers, as every comparable linter does.** Probably the right end state, and
  deferred rather than rejected. The objection was that the party reading the tiers is the agent that wrote the
  prose, which makes it self-certification — but S1 removes that objection by putting a human back at the point of
  decision. Revisit once S5 has real per-category numbers to tier on.
- **Do nothing.** Rejected: the style collapse above is measured, and the gate is currently unwinnable by
  arithmetic.

## Decisions made

All three resolved by Noah on 2026-08-27. Recorded here rather than deleted, so the reasoning survives the choice.

- [x] **Privacy boundary — numbers in the repo, text on disk.** Only derived measurements are committed:
      distributions, rates, frequencies. The raw extracted messages are gitignored, stay on the machine, and are
      not sent anywhere. Chosen because the calibration value is in the statistics, not in the prose, so the
      exposure is avoidable rather than a trade-off. Folded into S3 and AC3.
- [x] **Per-category output, keeping the single score as a summary.** The failure being fixed is that a 74 cannot
      say which of eight things to change — on one article four different fixes each cleared the bar. Retaining
      the number means the eight consumers that read it keep working, so the change is additive rather than a
      migration. Folded into S5 and AC5.
- [x] **The auto-revise loop does not wait; it goes first.** It was originally sequenced last. That was wrong:
      fixing it needs no measurement, and until it lands every draft is revised toward a rubric known to be
      miscalibrated, before Noah sees it. Promoted to S1 with its own criterion, AC7.

The directive's own framing changed with that last one. It was written as a measurement project with a policy
change attached at the end. It is now a policy change that unblocks a measurement project.
