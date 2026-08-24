# Directive — Voice + AI-Scoring as Dual-Axis Framework

**Created:** 2026-05-27
**Scope:** `noah-writing-voice` plugin (`noah-voice` + `ai-scoring` skills)
**Status:** ⚠️ NOT IN EFFECT — proposed only, never adopted. The implementation was drafted on branch
`feat/voice-ai-scoring-recalibration-2026-05-23` (tip `9c3c320`) and opened as
[#2](https://github.com/noah-goodrich/claude-plugins/pull/2), which is still OPEN and has never merged.
`9c3c320` is not an ancestor of `main`. Do not treat the rules below as binding: the `ai-scoring` and
`noah-voice` skills actually on `main` cannot produce the two scores this directive asks for.

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

> **Not active.** Steps 1-6 describe the unmerged
> [#2](https://github.com/noah-goodrich/claude-plugins/pull/2) design. On `main`, `ai-scoring` emits a
> single 0-100 humanness score and `noah-voice` emits no score at all, so steps 3 and 5 cannot be
> executed as written.

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

Audited 2026-08-21: every commit below except `b701ceb` lives only on an unmerged branch and is NOT an
ancestor of `main`. Hashes are preserved so the trail survives.

- `noah-writing-voice/skills/ai-scoring/SKILL.md` as redesigned in `9c3c320` — on
  [#2](https://github.com/noah-goodrich/claude-plugins/pull/2), still OPEN. `main` carries the older
  single-axis file (last touched by `37c17e2`).
- `noah-writing-voice/skills/noah-voice/SKILL.md` as revised in `d7fbb4f`, `97e84f3`, `a7fe56e` — all on
  [#2](https://github.com/noah-goodrich/claude-plugins/pull/2), still OPEN.
- `noah-writing-voice/validation/2026-05-23-corpus/` (seed validation corpus) — this one IS on `main`,
  landed independently via `b701ceb`.
- Commit `e231f40 validation: noah-voice + ai-scoring vs Medium corpus` — on
  [#3](https://github.com/noah-goodrich/claude-plugins/pull/3), CLOSED without merging.
