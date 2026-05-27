# Directive — Voice + AI-Scoring as Dual-Axis Framework

**Created:** 2026-05-27
**Scope:** `noah-writing-voice` plugin (`noah-voice` + `ai-scoring` skills)
**Status:** Operational rule, locked as of `9c3c320`

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
  signature structural moves (codified in `d7fbb4f`) against the Medium
  corpus.

Both skills run on every written deliverable. The user sees both scores.

## How to apply

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

- `noah-writing-voice/skills/ai-scoring/SKILL.md` (post-`9c3c320`)
- `noah-writing-voice/skills/noah-voice/SKILL.md` (post-`d7fbb4f`, `97e84f3`,
  `a7fe56e`)
- `noah-writing-voice/validation/2026-05-23-corpus/` (seed validation corpus)
- Commit `e231f40 validation: noah-voice + ai-scoring vs Medium corpus`
