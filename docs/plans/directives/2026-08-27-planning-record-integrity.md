# Directive: Enforce Status/Criteria Consistency in the Planning Record

*Filed: 2026-08-27 · Status: Proposed · Parent: borg-collective `2026-08-20-communication-program.md`*

**tl;dr** — A directive's status line can declare "shipped" while its own acceptance criteria sit unchecked, and
nothing catches it, because the validator has never been run against the record it governs. Add that check, fix the
prologue rule that archiving currently breaks, then enforce both in CI.

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

**The record does not pass the validator today. Measured 2026-08-28, before proposing to enforce it: of the three
files whose title line reads `# Directive:`, one passes and two fail.** The two failures have different causes and
only one is the document's fault.

- `2026-06-29-token-cost-optimization.md` — 5 errors, no tl;dr and four missing sections. It was filed 2026-06-29
  and the template shipped 2026-08-21, so it predates the rule it is being measured against.
- `2026-08-20-design-doc-and-brevity-skills.md` — 1 error, and it is **caused by assimilation, not by the author**.
  The document carries every required section; it fails only because archiving prepended
  `**Archived:** ⚠️ ASSIMILATED WITH ONE CRITERION SUPERSEDED` above the tl;dr, and the prologue rule admits only
  blank lines, the title, and an italic status line. Archiving a conforming directive is what makes it
  non-conforming. Every future assimilation reproduces this.

That second finding matters more than the first. A gate that goes red the moment a document is filed correctly and
then archived correctly is a gate its author turns off, which is the failure mode `validate.sh` already warns about
in its own header comment.

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
- **S3 — Let the prologue carry an archival banner, and grandfather pre-template documents.** Two changes, both
  required before S2 can fail a build. The prologue rule accepts a bold `**Archived:**` line alongside the italic
  status line, so assimilating a conforming directive stops breaking it. Separately, a document filed before
  2026-08-21 is reported but not failed, because retrofitting the template onto a historical record rewrites
  evidence rather than checking it. Both are exemptions with a stated reason and an end date, not an allowlist.

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
- [ ] AC4 The record is green when the job lands, and every exemption is stated in the document rather than in a
      skip list. It is not green today: two of three directives fail, measured 2026-08-28.
  - Verify: `2026-08-20-design-doc-and-brevity-skills.md` passes because S3 admits the archival banner, not because
    it is excluded. `2026-06-29-token-cost-optimization.md` is reported and not failed, under a grandfather the job
    prints by date rather than by filename. The two deliberate never-met criteria named in Problem pass because
    they are annotated. No allowlist file exists in the repo.
- [ ] AC5 Archiving a conforming directive leaves it conforming.
  - Verify: a valid fixture, and the same fixture with `**Archived:** ...` inserted above the tl;dr, both exit 0; a
    banner below the tl;dr also exits 0; ordinary prose above the tl;dr still errors, so the buried-tl;dr rule is
    narrowed rather than removed.

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
- [ ] Grandfather pre-2026-08-21 directives, or retrofit them? Recommend **grandfather**. Only
      `2026-06-29-token-cost-optimization.md` is affected, and rewriting a historical document to satisfy a template
      published two months after it was filed edits evidence rather than checking it.
- [ ] Should AC3's job fail the build immediately, or run advisory-only first? Recommend **advisory until S3
      lands, then failing**. The earlier draft of this directive recommended failing immediately on the assumption
      that the record was already clean. That assumption was wrong — see Problem — so the order now matters: fix
      the archival-banner rule, confirm green, then turn it red-on-fail.
