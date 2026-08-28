# Directive: Enforce Status/Criteria Consistency in the Planning Record

*Filed: 2026-08-27 · Status: Proposed · Parent: borg-collective `2026-08-20-communication-program.md`*

**tl;dr** — A directive's status line can declare "shipped" while its own acceptance criteria sit unchecked, and
nothing catches it. Add a fifth validator check for that state and a CI job that runs the validator against filed
directives, which nothing does today.

## Problem

The `design-doc` validator has never been run against the planning record it governs.

`.github/workflows/test.yml` runs `noah-content-tools/skills/design-doc/test/run-tests.sh`, which exercises 41
assertions against fixtures. No job passes a file from `docs/plans/` to `scripts/validate.sh`. A 171-line gate
with four checks exists, is green, and covers zero real documents.

The cost is measured. [#41](https://github.com/noah-goodrich/claude-plugins/pull/41) set
`2026-08-20-design-doc-and-brevity-skills.md` to `Status: Accepted, shipped 2026-08-21` in a one-line diff while
leaving all four of that document's acceptance criteria as `- [ ]`. They stayed unchecked for three days until
[#46](https://github.com/noah-goodrich/claude-plugins/pull/46), whose own commit message concedes the gap: the
criteria "were verified in #39 and had simply never been recorded here." Six days after the stamp,
[#49](https://github.com/noah-goodrich/claude-plugins/pull/49) re-verified every criterion against the codebase and
found four factual errors the assimilation had already shipped, including an em-dash count of 48 where the baseline
that directive commissioned measured 54.

The defect is a rate, not an incident. The 2026-08-20 completion audit measured **36 shipped-unarchived directives
and 0/44 checkbox flips** across the board.

Two documents carry a bare `- [ ]` under a terminal status today and are correct to:
`2026-05-27-voice-ai-scoring-dual-axis.md` and `2026-08-20-design-doc-and-brevity-skills.md` each hold a criterion
that will never be met. Both say so in prose. Neither says so in a form a checker can read.

## Solution

- **S1 — A fifth check in `validate.sh`: terminal status, bare criterion.** When the status line declares a
  terminal state (`Accepted`, `Shipped`, `Superseded`, `Assimilated`), every `- [ ]` in the outcome section must
  carry an explicit disposition on the same line. The accepted vocabulary is fixed: `Superseded`, `Not met`,
  `Withdrawn`, `Descoped`. A bare unchecked box under a terminal status is the error; an annotated one passes.
  This keeps the check a pure function over one file, which is the validator's existing contract.
- **S2 — A CI job that runs the validator over filed directives.** Select every file under `docs/plans/` whose
  title line begins `# Directive:` and pass each to `validate.sh`. Selection by title, not by directory, because
  `docs/plans/assimilated/` holds both directives and `PROJECT_PLAN` archives, and the two use different templates.
  S2 is what makes S1 real. A rule with no runner is the null check this repo has already shipped once: the
  `ai-scoring` baseline instructs a re-run after any edit to `ai-scoring/SKILL.md`, and `ai_score.py` never reads
  that file, so the instruction cannot fire.

## Acceptance criteria

- [ ] AC1 The validator errors on a terminal-status document with a bare unchecked criterion, and passes the same
      document once the criterion is annotated.
  - Verify: three new fixtures — terminal plus bare (exit 1), terminal plus annotated (exit 0), `Proposed` plus
    bare (exit 0) — and `run-tests.sh` stays green.
- [ ] AC2 The disposition vocabulary lives in one place and the code cannot drift from the prose.
  - Verify: `design-doc/SKILL.md` names the four dispositions; a test asserts the vocabulary in `validate.sh`
    matches the list in the skill and fails when either side changes alone.
- [ ] AC3 CI runs the validator against every filed directive, and against nothing else.
  - Verify: the job selects by `# Directive:` title; a `PROJECT_PLAN` archive sitting in the same directory is not
    selected; the job appears on a PR's checks page having actually executed.
- [ ] AC4 The existing record passes the new job at the moment it lands, without suppressions.
  - Verify: the two deliberate never-met criteria named in Problem pass because they are annotated, not because
    they are excluded. No allowlist, no skip file.

## Non-Goals

- **Not validating `PROJECT_PLAN.md` or its archives.** Different artifact, different template. The `design-doc`
  skill already says not to run the validator against them, and AC3 encodes that boundary rather than widening it.
- **Not restricting unchecked boxes in a `Proposed` document.** That is the normal state of a filed directive and
  the reason the checkbox exists.
- **Not deriving status from criteria, or checking boxes automatically.** State derivation is owned by
  borg-collective `2026-08-20-directive-state-deriver.md`. Inferring "shipped" from checkboxes would let one wrong
  box move a status line, which inverts the failure instead of fixing it.
- **Not re-auditing assimilated criteria.** [#49](https://github.com/noah-goodrich/claude-plugins/pull/49) did that
  pass once. This prevents the next drift; it does not repeat that one.

## Alternatives Considered

- **A diff-level rule: a PR that changes a `Status:` line must annotate every box in the same diff.** Rejected on
  coupling. `validate.sh` takes one file path and shells out to nothing but `awk`, `grep`, `head`, `tr`, `mktemp`
  and `cp`; handing it a git ref range makes a pure checker depend on repo state and on being run inside a
  worktree. The file-local form catches the same defect, because a stamped status above a bare box is visible
  without the diff that produced it.
- **A hookify `PreToolUse` hook that blocks the edit locally.** Rejected as the primary gate, accepted as an
  optional echo. Hooks bind one machine; the failure shipped through a pull request, where no hook runs.
- **Leave it to `borg-assimilate`.** Rejected by evidence. That skill existed on 2026-08-21 and
  [#41](https://github.com/noah-goodrich/claude-plugins/pull/41) stamped the directive anyway. Agent discretion is
  the mechanism that failed, so more of it is not the repair.
- **Do nothing; the record is already repaired.** Rejected. The repair took two PRs and six days for one document,
  and the audit measured 0/44 flips corpus-wide. Nothing about the next assimilation is different.

## Decisions requested

- [ ] Error or advisory for a bare box under a terminal status? Recommend **error** — an advisory reproduces
      today's state, where the finding exists and nobody acts on it.
- [ ] Approve the fixed vocabulary `Superseded` / `Not met` / `Withdrawn` / `Descoped`, or name a different set.
- [ ] Should AC3's job fail the build immediately, or run advisory-only for one week first? Recommend failing
      immediately, since AC4 requires the record to be clean before the job lands.
