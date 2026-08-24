# Project Plan: Design-Doc, Brevity, and PR-Description Skills

**Status:** ✅ ASSIMILATED — shipped 2026-08-21 to main via
[#39](https://github.com/noah-goodrich/claude-plugins/pull/39); all six criteria met. AC6 required
[#40](https://github.com/noah-goodrich/claude-plugins/pull/40) first, which removed an obsolete cairn test that had
been failing on main independently of this work.
*Established: 2026-08-20*

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

**D3 — Stale PRs.** [#3](https://github.com/noah-goodrich/claude-plugins/pull/3) is a verified zombie: its
`noah-writing-voice/validation` tree hash is `7b492c25`, byte-identical to main's, because the corpus landed via
`b701ceb` instead. Close it. [#5](https://github.com/noah-goodrich/claude-plugins/pull/5) is stacked on closed PR
#1, targets a file that is now a 21-line alias, and is the only one of the three that fails a test-merge. Close it
with a harvest note. [#2](https://github.com/noah-goodrich/claude-plugins/pull/2) merges clean and is not a zombie,
but landing it first would block this work behind a recalibration whose own 75 threshold flags five of Noah's ten
published articles. Build over it against main; leave it open, re-scoped.

## Acceptance Criteria

- [x] **AC1 — `design-doc` skill and a validator that enforces D1's template.** Validator exits non-zero when a
      required section is missing or the tl;dr is not first; exits zero with a printed advisory when any content
      follows `Decisions requested`, since that pushes the actionable block out of the terminal's landing region.
  - Verify: `bash noah-content-tools/skills/design-doc/test/run-tests.sh` passes, covering four defect fixtures
    (missing tl;dr, missing a required section, no outcome section, both outcome sections) and snapshots of all
    three real 2026-08-20 directives, which must exit zero.

- [x] **AC2 — `brevity` skill carrying the portable voice spine.** `noah-writing-voice/skills/brevity/SKILL.md`
      plus `references/portable-voice.md`, holding the eighteen portable rules and explicitly excluding the seven
      article-only ones (em-dash ban, no-bullets, central metaphor, set-the-scene, personal stakes, ELI5-by-analogy,
      identity byline). The spine must include the four rules an adversarial pass found missing from the first cut:
      earned confidence and self-correction (`voice-rules.md:27`, "I was wrong. On two counts."), the "warm and
      deeply human" thesis (`noah-voice/SKILL.md:8`), permission for concrete imagery, and the 120-character hard
      wrap from `~/.claude/CLAUDE.md`.
  - Verify: `grep` confirms all four restored rules present and all seven article-only rules absent; a one-line
    pointer exists in `noah-voice/SKILL.md` and the article path is otherwise byte-unchanged.

- [x] **AC3 — the quality gate is measured, not asserted.** `ai-scoring` gains an additive scanning-document mode
      that scores categories 3, 4, 6 and the category-8 word list only. Categories 1, 2 and 5 and the em-dash clause
      are disabled in that mode because they fire on mandatory directive format: under the full rubric Noah's own
      directives score 75, 77, 85, 85 and 90, losing points for status lines and `Non-Goals` bullets.
  - Verify: a committed baseline file records `ai_score.py` output for the five directives and the ten corpus
    articles before the change; after the change, directives score at or above baseline in the new mode and the ten
    articles are unchanged under the existing article mode.

- [x] **AC4 — `pr-description` produces all four blocks on a real PR.** tl;dr, chain position, review map, test
      evidence. Chain position names the directive and the acceptance criteria the PR satisfies, and degrades to an
      explicit "no manifest declared" line. Its `description:` frontmatter must state that it emits text only and
      name `/pr` as the different, auto-posting alternative.
  - Verify: run against [#38](https://github.com/noah-goodrich/claude-plugins/pull/38); confirm four blocks and the
    no-manifest line, since no `.borg/programs` directory exists anywhere on this machine.

- [x] **AC5 — CI actually exercises the new work.** Today `.github/workflows/test.yml` triggers only on
      `research-tools/**`, `borg-collective/hooks/**`, `token-cost/hooks/**` and `**/test/**`, and every job step
      names an exact file with no discovery glob — so a new test would trigger the workflow and still never run.
  - Verify: both target plugin paths appear in the push and pull_request filters, an explicit step runs AC1's test
    suite, and the PR's checks page shows that step executed.

- [x] **AC6 — nothing breaks, and the ship mechanics are done.** Existing suites stay green; both plugins are
      version-bumped from `0.1.31`, which neither has ever been bumped past in 84 commits; `marketplace.json`
      descriptions are updated to mention the new skills.
  - Verify: `bash research-tools/hooks/test/run-tests.sh` and the three bats suites pass; `bash build-plugins.sh`
    succeeds; `git diff` shows both `plugin.json` versions changed.

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
- NOT the chat-contract enforcement. That is borg-collective's S3, in a different repo.
- NOT rewriting `noah-voice`'s article rules. The article path stays byte-unchanged; every edit here is additive.
- NOT landing [#2](https://github.com/noah-goodrich/claude-plugins/pull/2).
- If done early: ship, don't expand. Fix the phantom status line in
  `docs/plans/directives/2026-05-27-voice-ai-scoring-dual-axis.md`, which claims "locked as of `9c3c320`" — a commit
  that is not an ancestor of main.

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
- **PRs [#3](https://github.com/noah-goodrich/claude-plugins/pull/3) and
  [#5](https://github.com/noah-goodrich/claude-plugins/pull/5) closed** per decision D3. #3 was a confirmed zombie
  (tree hash `7b492c2` identical on both sides); #5 was stacked on closed PR #1 and failed a test-merge.
- **Three defects found by independent verification and fixed before merge**: the validator accepted a buried
  tl;dr; the measurement baseline was anchored to untracked files in a sibling repo that were still being edited
  (one grew from 1,070 to 1,352 words mid-session); and `ai-scoring` and `portable-voice.md` described different
  scoring rubrics in the same PR.
- **Three validator fixtures beyond those the plan named**: `tldr-as-heading`, `fenced-heading`, `tldr-buried`.
  The fenced-heading case matters because a design doc about design docs quotes the template, and a quoted
  `## Non-Goals` inside a code fence must earn no credit.

## What the Plan Got Wrong

AC1 listed "both outcome sections present" as a defect fixture. It shipped as an **advisory** instead. A document
carrying both `Goals` and `Acceptance criteria` is not broken, and rejecting it would be the exact false positive
the advisory/error split exists to prevent. Zero outcome sections remains a hard error.

The plan also asserted AC6 as achievable ("existing suites stay green") without first checking that the existing
suites were green. They were not. The lesson is cheap and general: a regression criterion should be baselined
before it is written, not after.
