---
name: pr-description
description: "Writes a pull request body as four blocks: tl;dr, chain position (the directive and acceptance criteria the PR satisfies), review map, and test evidence. Use when asked for a PR description, PR body, PR writeup, or 'describe this branch', or when the user says /pr-description. This skill emits text only and never posts: it does not run `gh pr create`, `gh pr edit`, or any other command that writes to GitHub. When the PR should actually be opened, use the separate `/pr` command instead, which writes a shorter Summary plus Test-plan body and creates the PR in one step. Pick this skill for the body, `/pr` for the posting."
---

# PR Description

Produces the body of a pull request as four blocks: tl;dr, chain position, review map, test evidence. The output
is text. A human posts it.

## This skill does not post

There are two PR tools and they do different jobs.

| | `/pr` | `pr-description` (this skill) |
|---|---|---|
| Writes a body | Summary bullets plus a test-plan checklist | Four structured blocks |
| Runs `gh pr create` | Yes | Never |
| Records directive and acceptance criteria | No | Yes, block 2 |
| Test section | Checklist of intended tests | Commands run, with their real output |

Use `/pr` when the goal is a PR that exists on GitHub in one step. Use this skill when the goal is the body
itself: a body worth reviewing, pasted by a human into a new PR, an existing PR, or a file.

Not posting is a deliberate boundary, not a missing feature. The parent directive lists it under Non-Goals: "No
auto-posting of PR bodies; K3 writes text, humans post it."

## Why this exists beyond formatting

Block 2 is the point of the skill. It correlates a PR to the directive it descends from and the specific
acceptance criteria it satisfies, which is the capture end of a state pipeline: the moment "what shipped" becomes
answerable against "what was promised," in a place a query can reach.

That correlation lives here because PR bodies get written at ship time, as part of work already being done. Every
other surface that asks for the same fact asks for it as a separate act, after the work is finished: a status
document, a tracker field, a weekly update. Those decay, because they depend on volunteered discipline at the
moment attention has already moved on. This is derived capture instead. The state falls out of an artifact the
author was going to write anyway.

Which is why block 2 stays even when there is no manifest. The manifest supplies the program graph; the directive
and the acceptance criteria come from the repo and are nearly always available. Dropping the whole block because
one input is missing is precisely what breaks the pipeline.

## Before writing

Load the `brevity` skill and read its `references/portable-voice.md`. That file is the single source of truth for
the prose rules in this genre.

Do **not** load `noah-voice`. It is calibrated for long-form Medium articles, and several of its rules conflict
with a scanning document like a PR body. The "Not carried over" section of `portable-voice.md` names each dropped
rule and why.

Gather evidence before writing any block. Never write a block from the branch name alone.

```bash
git -C "$REPO" log --oneline main..HEAD; git -C "$REPO" diff --stat main...HEAD; ls "$REPO"/.borg/programs/*.json 2>/dev/null || echo "No manifest declared"
```

Then read, when they exist: `PROJECT_PLAN.md` at the repo root for acceptance criteria, and
`docs/plans/directives/*.md` for the directive this branch descends from.

## Block 1 — tl;dr

One sentence of problem. One sentence of solution. Both readable by someone with no context on the branch, the
directive, or the repo.

- The problem sentence names the failure, not the area. "Chart colors are inconsistent" is an area. "Series colors
  are chosen per chart, so the same series renders a different color on two pages" is a failure.
- The solution sentence says what the change does, not what it enables. "Adds a shared palette module every chart
  reads from," not "unlocks consistent visual identity."
- No preamble. Not "This PR..." and not "In this change...". Two sentences, no bullets, no bold.

The test: hand the two sentences to someone who has never seen the branch. If their first question is "what was
broken?", the problem sentence failed.

## Block 2 — Chain position

Four facts, in this order:

- **Program / lane** — which program or workstream this belongs to.
- **Blocks** — what cannot start until this merges.
- **Blocked by** — what has to land first. Render PR numbers as markdown links, never bare.
- **Directive + satisfies** — the directive file path, then the specific acceptance criteria IDs this PR
  satisfies. IDs, not a paraphrase. "AC4" is checkable; "improves the PR workflow" is not.

### Resolving the program graph

1. **When `.borg/programs/*.json` manifests exist**, read them and take the program name, lane, and the blocks /
   blocked-by edges from the manifest entry matching this branch or repo. Manifests are hand-authored, so treat
   what they say as authoritative and do not second-guess an edge that looks stale.

2. **When there is no `.borg/programs` directory, which is the normal case**, write the literal line
   `No manifest declared.` under the heading, then fill the directive and satisfies lines from the repo, and
   blocks / blocked-by from open PRs and the plan of record. No manifest directory exists on this machine today,
   so this is the path nearly every run takes. It is not an error and it is not a degraded mode; it is the default
   shape of the block.

Never infer a program name from a branch name or a directory name. Either a manifest declares it or the block says
no manifest was declared.

Example, no manifest:

```markdown
## Chain position

No manifest declared.

- **Directive:** `docs/plans/directives/2026-08-20-design-doc-and-brevity-skills.md`
- **Satisfies:** AC2 (portable voice spine), AC4 (pr-description four blocks)
- **Blocks:** nothing
- **Blocked by:** nothing open
```

## Block 3 — Review map

The two or three files that carry the change, each with one line on why a reviewer should open it. This is not a
file list. `git diff --stat` is already the file list and GitHub renders it above the body for free.

- Cap at three. If four files each carry independent risk, that is usually two PRs.
- Rank by risk, not by line count. A three-line change to an exit code outranks four hundred lines of fixtures.
- The reason line answers one question: what would a reviewer miss by skipping this file?
- Generated files, lockfiles, fixtures, and version bumps never appear here.

Example:

```markdown
## Review map

- `noah-content-tools/skills/design-doc/scripts/validate.sh` — the entire gate. The exit-code contract lives here:
  non-zero for a missing section, zero plus a printed advisory for content after `Decisions requested`.
- `.github/workflows/test.yml` — adds the path filter and the explicit step. Without both, the new suite exists
  and still never runs.
```

## Block 4 — Test evidence

The commands that were actually run and what they actually printed. Not a plan, not a checklist of intentions.

- **Never claim a test passed without its output.** Paste the real summary line from the real run.
- Trim long output to the command, the summary line, and any failure. Nobody needs two hundred lines of dots.
- If a suite was not run, name it and say so. "Not run" is a fact. A checked box next to a test nobody ran is a
  false claim, and it is the specific failure this block exists to prevent.
- If something failed and was then fixed, show the passing run and say what the failure was. A clean-looking
  history that hides a real failure costs the reviewer the one thing worth knowing.
- Manual verification counts, when it is described concretely: what was done, what was observed.

Example:

~~~markdown
## Test evidence

```
$ bash noah-content-tools/skills/design-doc/test/run-tests.sh
ok 1 missing tl;dr exits 1
ok 2 missing required section exits 1
...
7 passed, 0 failed

$ bash research-tools/hooks/test/run-tests.sh
12 passed, 0 failed
```

Not run: the three bats suites. This branch touches no file they cover.
~~~

## Output contract

- Emit the finished body as text in the reply, inside one fenced block so it can be copied whole.
- Never run `gh pr create`, `gh pr edit`, `gh pr comment`, or any other command that writes to GitHub. Writing the
  body to a local file is fine when asked for it.
- If a title is requested too, keep it under 70 characters and use the repo's existing commit-prefix convention.
- Render every PR and issue number as a markdown link, `[#38](https://github.com/<org>/<repo>/pull/38)`.
- Hard-wrap the body at 120 characters.

## Self-audit before emitting

- [ ] All four blocks present, in order.
- [ ] tl;dr is exactly two sentences and needs no context to parse.
- [ ] Chain position names a directive and specific AC IDs, or carries the `No manifest declared.` line, or both.
- [ ] Review map has at most three files, each with a reason, and no lockfiles or version bumps.
- [ ] Every test claim is backed by pasted output; anything unrun is labeled unrun.
- [ ] No command that writes to GitHub was run.
