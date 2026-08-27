# Directive — Voice + AI-Scoring as Dual-Axis Framework

**Archived:** ❌ ASSIMILATED AS SUPERSEDED 2026-08-27 — never in effect and now formally closed. Its only
implementing PR, [#2](https://github.com/noah-goodrich/claude-plugins/pull/2), was closed unmerged on 2026-08-26,
and all five commits it cites are off `main`. The problem it names is real and was re-measured, but its own
justification is unmeasurable: the corpus it was validated against had a negative class written out of the
rubric's banned-word lists. Replacement work is scoped in the evaluation-set directive filed 2026-08-26.

**Created:** 2026-05-27
**Scope:** `noah-writing-voice` plugin (`noah-voice` + `ai-scoring` skills)
**Status:** ❌ SUPERSEDED — never in effect, and now formally closed. The implementation was drafted on branch
`feat/voice-ai-scoring-recalibration-2026-05-23` (tip `9c3c320`) and opened as
[#2](https://github.com/noah-goodrich/claude-plugins/pull/2), which was **CLOSED without merging on 2026-08-26**,
with the closing note "superseded by measurement rather than abandoned." `9c3c320` is not an ancestor of `main`,
and neither are `d7fbb4f`, `97e84f3`, `a7fe56e` or `e231f40`. Do not treat the rules below as binding: the
`ai-scoring` and `noah-voice` skills actually on `main` cannot produce the two scores this directive asks for, and
no work is planned to make them able to.

**Superseded by:** `docs/plans/directives/2026-08-26-ai-scoring-evaluation-set.md` — **filed, not yet landed**. It
sits on [#48](https://github.com/noah-goodrich/claude-plugins/pull/48), which is still OPEN; the file is not on
`main`. Until that PR merges there is no directive in force on this subject. Do not cite the replacement as
shipped.

## Why

The previous design treated AI-detection scoring and Noah-voice enforcement as
two views of a single "good writing" axis. In practice this collapsed two
independent failure modes:

- Output can be highly human-sounding but completely off-voice (correct
  grammar, varied rhythm, but doesn't sound like Noah).
- Output can be on-voice but reads as AI (Noah's signature moves applied
  mechanically — em-dash overuse, parallel triplets stacked too tight).

Conflating the axes meant a single score gave no actionable signal. A piece
could fail the bar without telling you whether to loosen the voice rules or
rewrite for humanness.

## What

Treat **humanness** and **Noah-voice fidelity** as two independent axes. Each
skill scores its own axis and reports separately. The combined verdict is a
2D point, not a 1D average.

- `ai-scoring` measures humanness on a 0-100 scale, flagging AI tells with
  line-level citations.
- `noah-voice` measures voice fidelity by checking adherence to Noah's
  signature structural moves (drafted in `d7fbb4f`, unmerged — see Status) against
  the Medium corpus.

Both skills run on every written deliverable. The user sees both scores.

## How to apply

> **Not active, and will not become active.** Steps 1-6 describe the design on
> [#2](https://github.com/noah-goodrich/claude-plugins/pull/2), closed unmerged on 2026-08-26. On `main`,
> `ai-scoring` emits a single 0-100 humanness score and `noah-voice` emits no score at all, so steps 3 and 5 cannot
> be executed as written. The 70/70 gate was never measured; worse, the corpus that would have measured it is now
> known to be contaminated, so the design's own justification is unmeasurable as it stands. See Verification.

When writing or editing any prose deliverable (articles, LinkedIn posts,
README files, prose docs):

1. Draft using `noah-voice` rules as a generator.
2. Run `ai-scoring` to get the humanness score and line-level AI tells.
3. Run `noah-voice` to get the voice-fidelity score and rule violations.
4. If humanness < 70 → rewrite for naturalness, even if it weakens voice.
5. If voice-fidelity < 70 → rewrite for voice, even if humanness drops.
6. If both ≥ 70 → ship.

The two axes are independent. Do not average them into a single score. Do not
treat a high score on one as compensating for a low score on the other.

## References

Audited 2026-08-21, re-verified 2026-08-27: every commit below except `b701ceb` and `37c17e2` lives only on an
abandoned branch and is NOT an ancestor of `main`. Hashes are preserved so the trail survives.

- `noah-writing-voice/skills/ai-scoring/SKILL.md` as redesigned in `9c3c320` — on
  [#2](https://github.com/noah-goodrich/claude-plugins/pull/2), **CLOSED unmerged 2026-08-26**. `main` carries the
  older single-axis file (last touched by `37c17e2`, which IS an ancestor of `main`).
- `noah-writing-voice/skills/noah-voice/SKILL.md` as revised in `d7fbb4f`, `97e84f3`, `a7fe56e` — all on
  [#2](https://github.com/noah-goodrich/claude-plugins/pull/2), **CLOSED unmerged 2026-08-26**.
- `noah-writing-voice/validation/2026-05-23-corpus/` (seed validation corpus) — this one IS on `main`,
  landed independently via `b701ceb`. Its negative class is now known to be contaminated; see Verification.
- Commit `e231f40 validation: noah-voice + ai-scoring vs Medium corpus` — on
  [#3](https://github.com/noah-goodrich/claude-plugins/pull/3), CLOSED without merging.
- Replacement directive `docs/plans/directives/2026-08-26-ai-scoring-evaluation-set.md` — on
  [#48](https://github.com/noah-goodrich/claude-plugins/pull/48), **OPEN**. Not on `main`.

## Verification (2026-08-27)

Ancestry, against a freshly fetched `origin/main` (`6466aae`):

```
git merge-base --is-ancestor <hash> origin/main
  9c3c320 NOT-ON-MAIN   d7fbb4f NOT-ON-MAIN   97e84f3 NOT-ON-MAIN
  a7fe56e NOT-ON-MAIN   e231f40 NOT-ON-MAIN
  b701ceb LANDED        37c17e2 LANDED
```

PR state:

```
gh pr view 2  -R noah-goodrich/claude-plugins  →  state CLOSED, mergedAt null, closedAt 2026-08-26T10:36:52Z
gh pr view 3  -R noah-goodrich/claude-plugins  →  state CLOSED, mergedAt null, closedAt 2026-08-21T18:14:01Z
gh pr view 48 -R noah-goodrich/claude-plugins  →  state OPEN,   mergedAt null
```

Deliverables, against `origin/main`:

- `git show origin/main:noah-writing-voice/skills/ai-scoring/SKILL.md` — no "Axis A"/"Axis B", no voice-fidelity
  score. One 0-100 humanness scale, one `AI DETECTION SCORE: [X]/100` output line, thresholds at 90/75/60.
- `git show origin/main:noah-writing-voice/skills/noah-voice/SKILL.md` — zero occurrences of "score" or
  "fidelity". It emits no number, so step 5's voice-fidelity threshold has nothing to read.
- `git ls-tree origin/main docs/plans/directives/` — five directives, none of them
  `2026-08-26-ai-scoring-evaluation-set.md`.

Why the design's justification is unmeasurable, not merely unimplemented. The dual-axis split was argued from
accuracy numbers on `validation/2026-05-23-corpus/`. Re-measured 2026-08-27, that corpus cannot support any
accuracy claim: its five negative samples are keyword-stuffed from the rubric's own banned-word lists, and they are
length-separated from the positives as well.

| class | rubric banned-word hits / 100 words | word count |
|---|---|---|
| 5 `ai-samples/` negatives | 3.38 - 4.20 | 390 - 430 |
| 10 published `articles/` positives | 0.00 - 0.43 | 853 - 2,535 |

The negatives are keyword-dense by construction, so recall of 1.000 restates how the fixtures were written rather
than measuring detection. Either axis of this table separates the classes on its own. A framework justified by
"a single score gave no actionable signal" therefore has no measured signal to improve on — which is why
[#2](https://github.com/noah-goodrich/claude-plugins/pull/2) was closed as superseded by measurement, and why
[#48](https://github.com/noah-goodrich/claude-plugins/pull/48) rebuilds the evaluation set before anyone touches
the rubric again.

**No formal acceptance criteria.** This directive states rules ("both skills run on every deliverable", the 70/70
gate, "do not average them") rather than checkable criteria. None of those rules is in force on `main`, and none
will be: the dual-axis split, Axis B, and the two-number output contract were all explicitly dropped when
[#2](https://github.com/noah-goodrich/claude-plugins/pull/2) closed. The one idea that survived review — narrowing
the empty-single-sentence-paragraph check — carries forward into
[#48](https://github.com/noah-goodrich/claude-plugins/pull/48) as S3/AC4, not as a second axis.
