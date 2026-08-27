# Project Plan: Design-Doc, Brevity, and PR-Description Skills

**Status:** ✅ ASSIMILATED — shipped 2026-08-21 to main via
[#39](https://github.com/noah-goodrich/claude-plugins/pull/39); all six criteria met. AC6 required
[#40](https://github.com/noah-goodrich/claude-plugins/pull/40) first, which removed an obsolete cairn test that had
been failing on main independently of this work.
*Established: 2026-08-20*

**Reconciled 2026-08-27.** Every criterion below was re-verified against the codebase, not against this document's
own checkboxes; the evidence is inlined under each one. Both merge commits are ancestors of main —
`git merge-base --is-ancestor 37c17e2 origin/main` and `8af3c92` both return LANDED (#39 merged 2026-08-21T20:06:02Z,
#40 at 20:03:27Z, three minutes earlier, which is what made AC6 reachable). Three statements in the body have been
overtaken by later events and are annotated in place rather than rewritten: D3 and the #2 scope boundary, the
`.borg/programs` premise behind AC4, and the em-dash count in D2. No criterion is affected.

## Objective

Ship three writing skills — `design-doc`, `brevity`, and `pr-description` — that make Noah's reading format the
default for proposals, PR bodies, and chat replies. Underneath them, extract the genre-independent half of
`noah-voice` into a portable spine the technical-writing path can use without inheriting the Medium-article rules,
and put the whole thing behind a validator that CI actually executes.

## Decisions Locked

Three decisions were resolved before this plan was written. They are recorded here because reversing them changes
the acceptance criteria.

**D1 — Template shape.** The directive's "seven sections" were never one template. The umbrella directive carries
`Goals` and `Decisions requested` and no acceptance criteria; both child directives carry `Acceptance criteria` and
neither has `Goals`. That is a real distinction between a program-level document and an implementation-level one.
The template is therefore: five sections always required (tl;dr, Problem, Solution, Non-Goals, Alternatives
Considered), plus **exactly one outcome section** — `Goals` or `Acceptance criteria`, both permitted — plus
`Decisions requested` only when the document asks for a decision. Extra sections are allowed. All three real
2026-08-20 directives pass under this rule.

**D2 — Voice layering.** Design docs do not load `noah-voice`. They load a portable spine extracted from it. The
evidence is decisive: `voice-rules.md:10` reads "**No em dashes.** Not one. Not ever," and Noah's five real
directives contain 48 em dashes. `voice-rules.md:17` bans bullets in body text; his directives are built from
bullets. The article rules and the technical-doc genre are in direct conflict, so the split runs along
**reading documents** (articles, research reports — full `noah-voice` unchanged) versus **scanning documents**
(design docs, PR bodies, chat replies — portable spine only).

> **Correction (measured at ship time).** The count of 48 is stale. The committed baseline measured **54** em dashes
> across the same five directives at the anchored paths, by both `ai_score.py` and a raw `grep -o`, and flags the
> discrepancy itself at `noah-writing-voice/validation/baselines/2026-08-20-baseline.md:110-113`. The 48 is left in
> place because it is what the decision was written against; 54 is the number to cite. The direction of the argument
> is unchanged, and only strengthens: the whole 13,560-word article corpus carries 23 em dashes.
> Note that `brevity/references/portable-voice.md` still quotes 48 and the "7.8x denser" ratio derived from it.

**D3 — Stale PRs.** [#3](https://github.com/noah-goodrich/claude-plugins/pull/3) is a verified zombie: its
`noah-writing-voice/validation` tree hash is `7b492c25`, byte-identical to main's, because the corpus landed via
`b701ceb` instead. Close it. [#5](https://github.com/noah-goodrich/claude-plugins/pull/5) is stacked on closed PR
#1, targets a file that is now a 21-line alias, and is the only one of the three that fails a test-merge. Close it
with a harvest note. [#2](https://github.com/noah-goodrich/claude-plugins/pull/2) merges clean and is not a zombie,
but landing it first would block this work behind a recalibration whose own 75 threshold flags five of Noah's ten
published articles. Build over it against main; leave it open, re-scoped.

> **Verified 2026-08-27, and one outcome has moved.** The zombie finding on #3 is exact:
> `git rev-parse e231f40:noah-writing-voice/validation` (PR #3's head) and the same command on `b701ceb` both return
> `7b492c2500d7064261819586223c3db28b8cb3f4`, and `b701ceb` is an ancestor of main. #3 and #5 were both closed
> unmerged at 2026-08-21T18:14 as this plan directed; `research-tools/skills/deep-research/SKILL.md` is 21 lines,
> and #5's base branch is still `feat/skill-v2-citation-paywall-gates-2026-05-23`, PR #1's head.
> **#2 did not stay open.** It was closed without merging on 2026-08-26, five days after this shipped, by the
> citation-audit sweep — "superseded by measurement rather than abandoned," recorded in
> `docs/plans/directives/2026-05-27-voice-ai-scoring-dual-axis.md`. D3's "leave it open" is preserved as the
> decision this plan was built on; it is no longer the state of the world.

## Acceptance Criteria

- [x] **AC1 — `design-doc` skill and a validator that enforces D1's template.** Validator exits non-zero when a
      required section is missing or the tl;dr is not first; exits zero with a printed advisory when any content
      follows `Decisions requested`, since that pushes the actionable block out of the terminal's landing region.
  - Verify: `bash noah-content-tools/skills/design-doc/test/run-tests.sh` passes, covering four defect fixtures
    (missing tl;dr, missing a required section, no outcome section, both outcome sections) and snapshots of all
    three real 2026-08-20 directives, which must exit zero.
    **Met — re-ran 2026-08-27, `ALL TESTS PASSED`.** `scripts/validate.sh` and `test/run-tests.sh` both exist and
    the suite is green today, not merely at merge. All ten fixtures are present under `test/fixtures/`, plus
    `test/fixtures/real/` holding the three 2026-08-20 snapshots, each asserted `rc=0` and two of the three
    finding-free. Usage errors exit 2, never 1, so an argument mistake can never read as a validation failure.
    Closed by [#39](https://github.com/noah-goodrich/claude-plugins/pull/39) (`37c17e2`, ancestor of main).
    One deviation, disclosed under "What the Plan Got Wrong" below: `both-outcomes` shipped as an advisory
    (`rc=0`, no ERROR) rather than the defect fixture this criterion names.

- [x] **AC2 — `brevity` skill carrying the portable voice spine.** `noah-writing-voice/skills/brevity/SKILL.md`
      plus `references/portable-voice.md`, holding the eighteen portable rules and explicitly excluding the seven
      article-only ones (em-dash ban, no-bullets, central metaphor, set-the-scene, personal stakes, ELI5-by-analogy,
      identity byline). The spine must include the four rules an adversarial pass found missing from the first cut:
      earned confidence and self-correction (`voice-rules.md:27`, "I was wrong. On two counts."), the "warm and
      deeply human" thesis (`noah-voice/SKILL.md:8`), permission for concrete imagery, and the 120-character hard
      wrap from `~/.claude/CLAUDE.md`.
  - Verify: `grep` confirms all four restored rules present and all seven article-only rules absent; a one-line
    pointer exists in `noah-voice/SKILL.md` and the article path is otherwise byte-unchanged.
    **Met — read in full 2026-08-27.** `noah-writing-voice/skills/brevity/SKILL.md` (110 lines) and
    `references/portable-voice.md` (220 lines) both exist. The spine carries exactly eighteen numbered rules and a
    "Not carried over" section naming exactly the seven article-only rules this criterion lists, each with the
    `voice-rules.md` line it came from. All four adversarially-restored rules are present and cited as required:
    rule 1 is the "warm, confident, specific, and deeply human" thesis (`noah-voice/SKILL.md:8`), rule 2 is earned
    confidence and public self-correction (`voice-rules.md:27`, quoting "I was wrong. On two counts."), rule 9 is
    the permission for one concrete image per claim, and rule 13 is the 120-character hard wrap from
    `~/.claude/CLAUDE.md`. The pointer is a single line at `noah-voice/SKILL.md:9`; `git show 37c17e2` touches no
    other line of the article path. Closed by [#39](https://github.com/noah-goodrich/claude-plugins/pull/39).

- [x] **AC3 — the quality gate is measured, not asserted.** `ai-scoring` gains an additive scanning-document mode
      that scores categories 3, 4, 6 and the category-8 word list only. Categories 1, 2 and 5 and the em-dash clause
      are disabled in that mode because they fire on mandatory directive format: under the full rubric Noah's own
      directives score 75, 77, 85, 85 and 90, losing points for status lines and `Non-Goals` bullets.
  - Verify: a committed baseline file records `ai_score.py` output for the five directives and the ten corpus
    articles before the change; after the change, directives score at or above baseline in the new mode and the ten
    articles are unchanged under the existing article mode.
    **Met, and still green — re-ran the baseline's own reproduce block 2026-08-27.** The mode is at
    `noah-writing-voice/skills/ai-scoring/SKILL.md:20-69` ("Document Modes", "Why those categories are off in
    scanning mode", and a mode-named score line). The baseline is committed at
    `noah-writing-voice/validation/baselines/2026-08-20-baseline.md`. Re-running `ai_score.py` over all fifteen
    inputs reproduced the committed tables exactly: directives 77, 85, 85, 75, 90 and articles 63, 50, 93, 80, 68,
    82, 74, 65, 77, 78 — not one number moved. The regression detector this criterion asked for works, which is the
    thing that could not be taken on faith. Closed by
    [#39](https://github.com/noah-goodrich/claude-plugins/pull/39).
    Note on the wording: this criterion's second sentence enumerates categories 1, 2 and 5 plus the em-dash clause
    as disabled. The shipped mode also drops category 7 (specificity), which measured zero on all five. That
    follows from the criterion's own leading clause — "categories 3, 4, 6 and the category-8 word list **only**" —
    so the enumeration was incomplete, not the build.

- [x] **AC4 — `pr-description` produces all four blocks on a real PR.** tl;dr, chain position, review map, test
      evidence. Chain position names the directive and the acceptance criteria the PR satisfies, and degrades to an
      explicit "no manifest declared" line. Its `description:` frontmatter must state that it emits text only and
      name `/pr` as the different, auto-posting alternative.
  - Verify: run against [#38](https://github.com/noah-goodrich/claude-plugins/pull/38); confirm four blocks and the
    no-manifest line, since no `.borg/programs` directory exists anywhere on this machine.
    **Met, on better evidence than this criterion named.** The skill is at
    `noah-content-tools/skills/pr-description/SKILL.md`; its `description:` frontmatter states "emits text only and
    never posts," names `gh pr create` / `gh pr edit` as commands it does not run, and points at `/pr` as the
    auto-posting alternative. The four blocks are the file's own section structure (`## Block 1 — tl;dr` through
    `## Block 4 — Test evidence`), with the degradation path spelled out at lines 86-99 and an example rendering.
    The durable artifact is not the #38 run, which left no trace: **PR #39's own body is the skill's output**,
    carrying all four blocks and the literal `No manifest declared.` line under Chain position. #38's body predates
    the skill by a week (merged 2026-08-14) and was never rewritten, so the run named here was a throwaway
    exercise. Verified by `gh pr view 39 --json body`.
    **Premise since falsified.** "No `.borg/programs` directory exists anywhere on this machine" was true on
    2026-08-21 and is false now: borg-collective [#158](https://github.com/noah-goodrich/borg-collective/pull/158)
    merged 2026-08-23, and `/Users/noah/dev/borg-collective/.borg/programs/viz-program.json` exists today. The
    manifest branch of the skill's resolution logic is therefore live and has never been exercised. That does not
    unmake this criterion — the no-manifest degradation is what it asked for and what shipped — but the skill's own
    line "No manifest directory exists on this machine today" is now stale and should be corrected under a separate
    directive.

- [x] **AC5 — CI actually exercises the new work.** Today `.github/workflows/test.yml` triggers only on
      `research-tools/**`, `borg-collective/hooks/**`, `token-cost/hooks/**` and `**/test/**`, and every job step
      names an exact file with no discovery glob — so a new test would trigger the workflow and still never run.
  - Verify: both target plugin paths appear in the push and pull_request filters, an explicit step runs AC1's test
    suite, and the PR's checks page shows that step executed.
    **Met — all three halves checked.** `.github/workflows/test.yml` now lists `noah-content-tools/**` and
    `noah-writing-voice/**` in both the `push` and the `pull_request` path filters. Job 3, `design-doc`, runs
    `bash noah-content-tools/skills/design-doc/test/run-tests.sh` as an explicit step. And it demonstrably ran:
    `gh pr checks 39` returns `design-doc validator suite  pass  4s` and `pass  5s` across two runs. The third
    condition is the one that mattered — a filter and a step both present still prove nothing until a checks page
    shows the step executing. Closed by [#39](https://github.com/noah-goodrich/claude-plugins/pull/39).
    (Job 4, the marketplace manifest guard now in the same file, is not this plan's work; it arrived later via
    [#44](https://github.com/noah-goodrich/claude-plugins/pull/44).)

- [x] **AC6 — nothing breaks, and the ship mechanics are done.** Existing suites stay green; both plugins are
      version-bumped from `0.1.31`, which neither has ever been bumped past in 84 commits; `marketplace.json`
      descriptions are updated to mention the new skills.
  - Verify: `bash research-tools/hooks/test/run-tests.sh` and the three bats suites pass; `bash build-plugins.sh`
    succeeds; `git diff` shows both `plugin.json` versions changed.
    **Met — but only because [#40](https://github.com/noah-goodrich/claude-plugins/pull/40) landed first, and the
    archive should say so plainly.** At the time #39 was opened this criterion was *not* satisfiable: its own PR
    body says "One suite fails, and it is not this branch," names `borg-link-down.bats` test 17, and states "AC6's
    'existing suites stay green' is therefore not satisfiable here, and I am not claiming it is." #40 merged at
    20:03:27Z, #39 at 20:06:02Z. Re-verified 2026-08-27: `research-tools/hooks/test/run-tests.sh` →
    `ALL TESTS PASSED`; `borg-link-down.bats` → `ok 15` (15/15, was 17 with 1 failure); `borg-link-up.bats` →
    `ok 15`; `token-spend-log.bats` → `ok 40`. `bash build-plugins.sh` packages all eight plugins and exits clean.
    Versions: `git show 37c17e2^1` shows both plugins at `0.1.31`; `git show 37c17e2` shows both at `0.2.0`, and
    both still read `0.2.0` on main. `marketplace.json` changed 2 lines in the same commit — `noah-content-tools`
    now advertises "design docs, and PR descriptions," `noah-writing-voice` "a brevity layer for scanning
    documents."

## Testability

- **`design-doc` validator — the only real code in this plan.** Testable core is
  `noah-content-tools/skills/design-doc/scripts/validate.sh`: a pure function of a file path to an exit code plus
  printed findings, with no network, no state, and no dependency on the agent. `SKILL.md` is a thin shell that tells
  the agent to run it. Tests ship in the same commit at
  `noah-content-tools/skills/design-doc/test/run-tests.sh`, following the existing fixture-per-scenario pattern in
  `research-tools/hooks/test/run-tests.sh` rather than adding a bats dependency to a plugin that has none.
- **`brevity` and the portable spine — pure documentation, no code.** Their only mechanical check is AC3's corpus
  measurement. That is the honest limit: rule text cannot be unit-tested, so the baseline file is the regression
  detector.
- **`pr-description` — pure prompt text, no code, and deliberately no automated test.** Verified by the manual run
  in AC4. Writing a block-presence checker for prose output would cost more than it catches; flagged here rather
  than silently omitted.
- **Existing untested code this plan touches.** `noah-voice/SKILL.md` gets a one-line pointer and has zero test
  coverage. `ai-scoring/SKILL.md` gains an additive mode section and also has zero coverage. Neither is refactored.
  `validation/2026-05-23-corpus/scripts/ai_score.py` has never been wired to any runner — an open gap since
  2026-06-11 — and AC3 wires it into a checked-in baseline for the first time. That is the one place this plan adds
  coverage to previously untested code, and it is additive.

## Scope Boundaries

- NOT moving `reading-deliverable-standard.md`. It has exactly one inbound reference, and `build-plugins.sh` zips
  each plugin independently, so a cross-plugin relative path cannot resolve in an installed plugin.
- NOT building manifest-driven chain position. Dropped from scope, not deferred in place: no `.borg/programs`
  directory exists anywhere on this machine and [#158](https://github.com/noah-goodrich/borg-collective/pull/158) is
  still open. Re-file it as its own directive once that ships.
  > **That trigger has now fired.** #158 merged 2026-08-23 and
  > `/Users/noah/dev/borg-collective/.borg/programs/viz-program.json` exists. The follow-on directive this line
  > calls for has not been filed. See the AC4 note above.
- NOT the chat-contract enforcement. That is borg-collective's S3, in a different repo.
- NOT rewriting `noah-voice`'s article rules. The article path stays byte-unchanged; every edit here is additive.
- NOT landing [#2](https://github.com/noah-goodrich/claude-plugins/pull/2).
  > Held. #2 was never landed, and was later closed unmerged on 2026-08-26 — see the D3 note above.
- If done early: ship, don't expand. Fix the phantom status line in
  `docs/plans/directives/2026-05-27-voice-ai-scoring-dual-axis.md`, which claims "locked as of `9c3c320`" — a commit
  that is not an ancestor of main.
  > **Not done by this plan.** `9c3c320` is confirmed NOT-ON-MAIN, but the status line was corrected later, by
  > [#42](https://github.com/noah-goodrich/claude-plugins/pull/42) (`f4212aa`, "correct ten phantom citations in the
  > planning record"). The directive now opens `❌ SUPERSEDED` and states the non-ancestry outright. This
  > optional-if-early item simply was not reached; crediting it to this plan would be the exact error the audit was
  > cleaning up.

## Ship Definition

PR opened, the new CI job from AC5 runs and passes, merged, then `bash build-plugins.sh` and a manual reinstall —
a rebuilt `.plugin` sits inert until it is reinstalled. AC6's version bumps must be in the same PR; nothing else
will catch a skipped bump.

## Timeline

Target: two sessions. AC1 and AC5 are one session (the validator plus its tests plus the CI wiring are the only
real engineering). AC2, AC3 and AC4 are the second: rule extraction, the baseline measurement, and one manual PR
run.

## Risks

- **AC3 is the scope-creep risk and the first thing to cut.** Adding a genre mode to `ai-scoring` is the only
  criterion that edits an existing skill's behavior. If the session runs long, ship AC1/AC2/AC4/AC5/AC6 and file
  AC3 separately — but then AC2's spine ships ungated.
- **The validator's first rejection decides whether it survives.** A false positive on a document Noah already
  considers done is how a gate becomes a thing he disables. The advisory-versus-error split in AC1 exists
  specifically to prevent that, and all three real directives were checked against it before this plan was written.
- **[#2](https://github.com/noah-goodrich/claude-plugins/pull/2) diverges further while this ships.** It touches
  the same three files. It merges clean today; that is not guaranteed after AC2 edits `noah-voice/SKILL.md`.
- **Shipped is not live.** There is no auto-reload, so a merged, rebuilt plugin does nothing until someone
  reinstalls it through the UI. AC6 is a one-time manual check, not a standing guarantee.

## Additional Work Shipped

Beyond the six criteria:

- **[#40](https://github.com/noah-goodrich/claude-plugins/pull/40)** removed two obsolete cairn tests from
  `borg-link-down.bats`. Test 17 asserted the hook invokes `cairn`, which it has not done since the decommission,
  and had been failing on main for every PR touching `borg-collective/hooks/**`. Test 16 was the more interesting
  one: it passed *vacuously*, asserting that a flag suppresses a call nothing can make. AC6 was unreachable without
  this.
  *Verified:* `8af3c92` is an ancestor of main, and its diff removes exactly two `@test` blocks —
  `"synthetic session: BORG_NO_SPEND_RECORD=1 skips the cairn search"` (the vacuous one) and
  `"real session: cairn search still runs when the flag is unset"` (the failing one) — plus the `_fake cairn` stub.
  The commit message independently records "17 tests with 1 failure to 15 with none"; the suite runs `ok 15` today.
- **PRs [#3](https://github.com/noah-goodrich/claude-plugins/pull/3) and
  [#5](https://github.com/noah-goodrich/claude-plugins/pull/5) closed** per decision D3. #3 was a confirmed zombie
  (tree hash `7b492c2` identical on both sides); #5 was stacked on closed PR #1 and failed a test-merge.
  *Verified:* both CLOSED unmerged at 2026-08-21T18:14. The tree hash checks out in full —
  `git rev-parse e231f40:noah-writing-voice/validation` (PR #3's head) and the same on `b701ceb` both return
  `7b492c2500d7064261819586223c3db28b8cb3f4`.
- **Three defects found by independent verification and fixed before merge**: the validator accepted a buried
  tl;dr; the measurement baseline was anchored to untracked files in a sibling repo that were still being edited
  (one grew from 1,070 to 1,352 words mid-session); and `ai-scoring` and `portable-voice.md` described different
  scoring rubrics in the same PR.
  *Verified, all three, by the artifacts each fix left behind:* the `tldr-buried` fixture exists and asserts three
  separate error messages; `baselines/2026-08-20-baseline.md:29-44` narrates the 1,070→1,352 drift verbatim and
  explains why the table was re-anchored to in-repo snapshots; and `portable-voice.md` rule 18 now defers the
  rubric to `ai-scoring` outright — "do not restate its thresholds or its baselines here."
- **Three validator fixtures beyond those the plan named**: `tldr-as-heading`, `fenced-heading`, `tldr-buried`.
  The fenced-heading case matters because a design doc about design docs quotes the template, and a quoted
  `## Non-Goals` inside a code fence must earn no credit.
  *Verified, and undercounted.* All three exist. So do three more the plan did not name — `pass-minimal`,
  `tldr-after-status-line` and `trailing-after-decisions` — for ten fixtures total against the four this plan
  scoped. The three listed here are the extra *defect* fixtures; the other three cover the clean and advisory
  paths. Undercounting its own delivery is the harmless direction, but the number is six.

## What the Plan Got Wrong

AC1 listed "both outcome sections present" as a defect fixture. It shipped as an **advisory** instead. A document
carrying both `Goals` and `Acceptance criteria` is not broken, and rejecting it would be the exact false positive
the advisory/error split exists to prevent. Zero outcome sections remains a hard error.
*Confirmed 2026-08-27:* the suite asserts `both-outcomes -> rc=0 with an advisory, not an error` and
`both-outcomes emits no ERROR`.

The plan also asserted AC6 as achievable ("existing suites stay green") without first checking that the existing
suites were green. They were not. The lesson is cheap and general: a regression criterion should be baselined
before it is written, not after.
*Confirmed, and it is the sharpest thing in this document:* PR #39's body says so in its own words — "AC6's
'existing suites stay green' is therefore not satisfiable here, and I am not claiming it is." That refusal to
check a box it could not earn is why this archive survived re-verification intact.

Two smaller things, found only by re-reading against the code (both cosmetic, neither changes a criterion):

- **AC3's disabled-category list is incomplete.** It names categories 1, 2, 5 and the em-dash clause; the shipped
  mode also drops category 7. See the AC3 note.
- **D2's em-dash count is stale.** 48 was superseded by the measured 54 in the very baseline this plan commissioned,
  which flags the discrepancy itself. See the D2 note.

## Standing Accuracy of This Archive

The three skills, the validator, the CI job and the baseline are all on main and all still green as of 2026-08-27.
What has drifted is context, not delivery: `.borg/programs` manifests now exist, so AC4's "no manifest anywhere on
this machine" premise is dead and `pr-description`'s untested manifest branch is now reachable; and #2 is closed
rather than open. Neither reopens a criterion. The one piece of unfinished business this document points at is the
manifest-driven chain-position directive it deferred, whose trigger has since fired and which has not been filed.
