Generated: 2026-08-26

# Fixing the ai-scoring article path

**tl;dr** — The gate flags 5 of Noah's 10 published articles as machine-written, and the reason is arithmetic: the
cut sits at his median. Fix the loop that lets an agent rewrite his voice before he sees it, stop penalising the
feature that fires on 10 of 10 of his real articles, and retract the detection numbers entirely — because the AI
half of the corpus was built out of the rubric's own word lists and cannot measure detection at all.

## Glossary

- **The gate** — `ai-scoring`, a skill that reads prose and returns 0-100. Below 75 is treated as a failure.
- **Precision / recall** — precision is "of the things flagged, how many deserved it." Recall is "of the things
  that deserved flagging, how many were caught."
- **False positive** — human writing wrongly flagged as machine-written.
- **The corpus** — 10 of Noah's published Medium articles plus 5 hand-written "AI-flavoured" samples, used to
  check the rubric.
- **Category 1** — the rubric rule that penalises single-sentence paragraphs.
- **AUC** — a 0-1 measure of how well a feature separates two groups. 0.5 is a coin flip. Below 0.5 means the
  feature works, but backwards.
- **Scanning mode** — a genre setting added earlier that switches off some rules for design docs and PR bodies.

## Recommendation

Three moves, in this order. The first needs no measurement at all; the second is justified by Noah's own published
writing without reference to the AI samples; the third is a retraction, not a change.

**1. Stop the auto-revise loop.** `noah-content-tools/skills/snowflake-article/SKILL.md:15` calls 75 "a hard
threshold, not a suggestion," and its Quality Gate says to "identify the top 3 flagged passages and rewrite them"
and "re-score until passing" *before* presenting anything to Noah. `linkedin-post` carries the same pattern. That
is the actual harm surface. The gate does not block Noah from publishing; it authorises an agent to sand his voice
before he reads a word. Change it to: present the draft with the flags attached, and never revise to clear a
threshold. This is a policy choice about who decides, so no corpus can validate or invalidate it.

**2. Stop *penalising* single-sentence paragraphs in article mode — but keep measuring them.** Category 1 fires on
10 of 10 of Noah's published articles at a mean of −16.2 points, contributing −162 of the −270 human penalty.
Scored alone its AUC is 0.010, which means it is a near-perfect *Noah detector* wired into the sum with a minus
sign. Its prescribed remedy — "fold the standalone sentence into its neighbouring paragraph" — instructs him to
delete the rhythm that makes him legible as himself. Remove the penalty. Do not remove the measurement: keep
reporting the density as an observation with no points attached. That preserves the information without asserting
a detection claim the corpus cannot support.

**3. Retract the detection numbers rather than annotating them.** Delete the f1 and recall figures from the rubric
and state plainly that recall is unmeasured. Annotating them as provisional is not enough — a number on the page
gets read as validated, and this repo has already demonstrated that failure mode three separate times.

Fix the baseline's acceptance rule in the same commit. It currently says article-mode scores must not move, which
any article-path fix violates by construction.

**Explicitly do not:** pick a new threshold, adopt a percentile gate, or adopt the inverted density floor
described below. All three are fitted to a corpus that cannot support them.

## What changed my mind twice

This is the part worth reading, because the recommendation above is the third position I held.

**The prior default was "two category edits reach f1 1.00."** That number is real and reproduces. It is also
meaningless. The five AI samples are keyword-stuffed from the rubric's own banned-word lists: 7.14-8.33 rubric
hits per 100 words against 0.00-0.55 in Noah's real articles. Ablation settles it — the literal word-matching
categories alone separate the classes at AUC 1.000, while the structural categories alone manage 0.220, which is
worse than chance. Every point of measured discrimination is keyword lookup. Recall of 1.000 is a restatement of
how the fixtures were written. Held out against five genuinely agent-authored documents in this repo, the
best-fitting threshold catches 3 of 5 and the in-sample-perfect rule catches 1 of 5.

**Then the blind review proposed keeping category 1 and flipping its sign** — flag drafts whose single-sentence
density falls *below* Noah's observed floor — on the grounds that density separates the two classes cleanly with
zero overlap. That would have been a better idea than anything in the option set. It does not survive measurement.
Noah's articles run 13.9% to 87.0%; the AI fixtures run 8.3% to 20.0%. The ranges **overlap by 6.1 points**, and
two of his articles sit inside the AI range. The review's own figures show the same thing — a human floor of 14%
against an AI ceiling of 20% — and it described that as zero overlap, which is an arithmetic error in its
headline claim.

The direction is right: Noah's prose really is denser in single-sentence paragraphs than the fixtures. The margin
is not there. A floor rule works only when placed at exactly 13.9%, his observed minimum, where it catches 4 of 5
fixtures and flags none of his articles. Move it one tenth of a point and it flags him. A rule tuned to a single
document is not a rule.

## Why the gate fails, in one line

The threshold is 75. Noah's median is 75.5. Roughly half his work fails as arithmetic, whatever he writes.

## The harm is not hypothetical

Across Noah's five most recent articles, both penalised features collapse. Em dashes per thousand words run
7.4 → 3.1 → 2.6 → 0.0 → 0.5. Single-sentence paragraph share runs 0.50 → 0.38 → 0.24 → 0.12 → 0.06, an
eightfold
drop ending at the corpus boundary. The validation report itself describes the last of these as the most
self-conscious-of-AI article in the set.

Five articles is a signal, not a proof, and a genre shift toward long-form is a competing explanation. But the
flattering reading is not the safe one. And the decisive detail is that category 1 still fires on all ten
articles including the collapsed ones — he gave up the em dash and eight-tenths of his rhythm, and it bought him
nothing.

## Options considered

- **A — Surgical two-category disable.** Turn off category 1 and the em-dash clause. Smallest diff. Rejected as
  insufficient alone: it fixes the thermometer while `voice-rules.md` still forbids at writing time exactly what
  the scorer would stop penalising.
- **B — Author-anchored percentile gate.** Killed by three of four council voices independently. A percentile is a
  quota: it flags a fixed fraction forever by construction. Worse, the within-human ordering is driven by category
  1, so "flag the bottom 20%" would flag Noah's two most characteristically staccato articles.
- **C — Retire the number; ship severity tiers.** The correct end state and the only option matching every
  external precedent. Held back because the party reading the tiers is currently the agent that wrote the prose,
  which makes it self-certification.
- **D — Two-tier pass / review / fail band.** Rejected: the band is read by an agent, which resolves ambiguity
  against a stated threshold the only way an agent can — by revising.
- **E — Rebuild the corpus first.** Correct and deferred. It is the precondition for any future detection claim,
  not for stopping the current harm.
- **F — Ship the fix, quarantine the detection claims.** The council's choice. The audit found its central claim —
  that neither justification needs the AI class — holds for category 1 but fails for the em-dash clause, whose
  stated grounds are an external corpus and a direct observation about the AI samples.
- **G — Invert category 1 against an author floor.** The blind review's proposal. Overturned by measurement above.

## What the evidence cannot tell us

Recall. There is no usable measurement of whether this rubric catches machine-written prose, because the negative
class was written from the rubric. Anything asserting otherwise is quoting a fixture back to itself.

Two further limits worth stating. The runtime gate is a language model reading prose; `ai_score.py` is an offline
proxy wired to no runner, and its agreement with the deployed behaviour has never been measured. And the
population the gate actually sees — a model drafting in Noah's voice — appears in neither half of the corpus.

## Method note

Produced with the decision-design pipeline: four parallel from-zero research tracks, a five-persona council with
mandatory dissent, and a blind adversarial review that saw the option set and the choice but not the reasoning.
The review returned **revise**, and its proposed replacement was then overturned by direct measurement.

The `borg-researcher` and `borg-reviewer` agents the skill specifies are unavailable in this session; equivalent
agents were used, with the blind reviewer given no access to the council's reasoning. That substitution is
disclosed rather than being stamped as unreviewed.
