# Audit: Directive Commit and PR Citations

*Filed: 2026-08-21 · Status: Accepted · Parent: none*

**tl;dr** — Ten citations across the `claude-plugins` planning record present unmerged commits as shipped work,
including a directive that calls itself a locked operational rule and an archive stamped as fully assimilated.
Every false claim is rewritten to state what is actually true while preserving the hash, so the trail survives.

## Problem

The planning record is trusted by both agents and humans, and parts of it are wrong in a way nothing detects.

Measured 2026-08-21 across both repos: **215 citations checked**. `claude-plugins` carries 25 citations across 6
files in `docs/plans/` — **10 phantom, 15 landed, 0 unresolvable**. A phantom is a commit or PR presented as
completed work whose hash is not an ancestor of `main`. All ten trace to six distinct hashes on three branches from
one week in May 2026: PR [#2](https://github.com/noah-goodrich/claude-plugins/pull/2), which is still open, and PRs
[#3](https://github.com/noah-goodrich/claude-plugins/pull/3) and
[#5](https://github.com/noah-goodrich/claude-plugins/pull/5), both since closed unmerged.

Two are load-bearing:

- `docs/plans/directives/2026-05-27-voice-ai-scoring-dual-axis.md:5` read **"Status: Operational rule, locked as of
  `9c3c320`"**. That reads as binding policy for all written output. `9c3c320` is not an ancestor of `main`, and
  `git grep -ci dual-axis main -- noah-writing-voice/skills/ai-scoring/SKILL.md` returns nothing. The directive's
  own steps 3 and 5 were literally unexecutable, because the skills on `main` emit no voice-fidelity score at all.
- `docs/plans/assimilated/2026-05-27-plugin-marketplace-consolidation.md` was stamped **"✅ ASSIMILATED — criteria
  1–6 met"** while criteria 4 and 5 were signed off against `10b962b`, `9c3c320` and `a7fe56e` — none of them on
  `main`. Criteria 1, 2, 3 and 6 genuinely are met, which is what makes it dangerous: a partial-truth archive
  survives scrutiny that a wholly false one would not.

The reassuring half of the measurement matters as much. `borg-collective` returned **zero phantoms across 50 commit
citations in 72 files**. This is not a fleet-wide discipline failure; it is one cluster from one week where three
PRs were written up as done and then never landed. The cross-repo PR sweep also found **zero phantom PR
citations** — every `#N` presented as merged is in fact merged.

## Solution

Rewrite each false claim to state the true status, preserving the original hash and adding the PR link, so the
correction is auditable rather than an erasure. Eight repairs, all in `claude-plugins`:

In `directives/2026-05-27-voice-ai-scoring-dual-axis.md`, four repairs:

- The status line said "Operational rule, locked as of `9c3c320`". It now opens
  "⚠️ NOT IN EFFECT — proposed only, never adopted" and names the branch and open PR the work sits on.
- Line 31 said the rules were "codified in `d7fbb4f`". Now "drafted in `d7fbb4f`, unmerged — see Status".
- `## How to apply` presented its six steps as an active procedure. It is now prefixed with a note that steps 3
  and 5 cannot be executed on `main`, because the skills there emit no voice-fidelity score.
- The References section listed three hashes as the shipped post-state of two files. It now opens with the audit
  date and the finding that every commit listed except `b701ceb` lives only on an unmerged branch.

In `assimilated/2026-05-27-plugin-marketplace-consolidation.md`, three repairs:

- The header said "✅ ASSIMILATED — criteria 1–6 met". It now says "⚠️ ASSIMILATED WITH UNMET CRITERIA" and
  names which four are genuinely met and which two are not.
- Criterion 4 was signed off "met as of `10b962b` (gate 14)". Now "NOT MET (audited 2026-08-21)", with the
  original sign-off quoted so the change is visible.
- Criterion 5 was signed off "met as of `9c3c320` + `a7fe56e`", same treatment.

In `directives/2026-08-14-experiment-skill.md:18`, one repair: `a77873a` carried a fabricated quoted title. It now
carries the real commit title and is marked as a **reveal** commit.

That last row is a correction to the audit itself, not to the record's honesty. `a77873a` was first flagged
unresolvable; it is a real commit and is an ancestor of `main` **in the reveal repo**. It is a cross-repo citation,
not a phantom. One further scanner error was caught and reverted before it reached this list: the corpus path at
`:56` is accurate, because that tree reached `main` independently via `b701ceb`.

Only the phantom rows are tabulated here. Listing all 215 citations would push this past the three-page cap for no
gain, since the check is cheap to re-run:

```
cd /Users/noah/dev/claude-plugins && git grep -ohE '`[0-9a-f]{7,40}`' -- docs/plans/ | tr -d '`' | sort -u | while read -r h; do git cat-file -e "$h" 2>/dev/null && { git merge-base --is-ancestor "$h" main 2>/dev/null && echo "LANDED  $h" || echo "PHANTOM $h"; } || echo "UNKNOWN $h"; done
```

## Acceptance criteria

- [x] Every phantom citation in `claude-plugins` states its true status, with the hash and PR link preserved.
  - Verify: `grep -c "NOT IN EFFECT\|NOT MET (audited" docs/plans/` returns 3 across the two repaired files.
- [x] No citation is deleted. The correction is additive to the historical trail.
  - Verify: `git diff` shows every original hash still present.
- [x] Ancestry claims independently re-verified, not taken from the scanners.
  - Verify: the reproduce block above; `9c3c320`, `d7fbb4f`, `97e84f3`, `a7fe56e`, `10b962b`, `e231f40` all return
    PHANTOM, `b701ceb` returns LANDED, and `a77873a` resolves only in reveal.
- [x] `borg-collective` findings are reported, not repaired — another session owns that repo and several of its
  directives are untracked and in flight.

## Non-Goals

- Not repairing `borg-collective`. It has no phantoms, and writing to a repo another session is actively editing
  would conflict.
- Not deleting or rewriting the directives themselves. A wrong status line is a fact about the record's history and
  is corrected in place, not erased.
- Not automating this as a hook or CI gate. One measurement does not justify standing machinery; see Alternatives.
- Not resolving PR [#2](https://github.com/noah-goodrich/claude-plugins/pull/2). Its re-scoping is separate work.

## Alternatives Considered

- **Delete the false citations.** Rejected: it destroys the trail that makes the error legible, and a reader who
  later finds the branch would have no way to connect it back.
- **Add a CI check that fails on any non-ancestor hash in `docs/plans/`.** Rejected for now, and this is the close
  call. It would catch recurrence mechanically, which is exactly the derived-not-volunteered principle the
  communication program is built on. But directives legitimately cite commits from sibling repos (`a77873a` in
  reveal) and from branches that have not merged *yet*, so a naive gate produces false failures on correct
  documents — the failure mode that gets a gate disabled. It needs a way to declare the intended repo and an
  expected state before it is worth building.
- **Mark the whole dual-axis directive superseded.** Rejected: the design may still be right, and PR
  [#2](https://github.com/noah-goodrich/claude-plugins/pull/2) is open. The defect is the claim that it shipped,
  not the content.

## Decisions requested

- [ ] Whether the CI gate above is worth building once a repo/state annotation exists for citations, or whether a
      periodic re-run of the reproduce block is enough.
