---
name: design-doc
description: "Design-doc authoring and review. Use whenever writing, scaffolding, or reviewing a design doc, TRD, RFC, technical proposal, ADR, or directive: any document that proposes a change and asks a reader to approve it. Trigger on 'write a design doc', 'draft a TRD', 'write an RFC', 'file a directive', 'turn this into a proposal', or a request to check whether an existing proposal is missing sections. Enforces the locked template (tl;dr lead line, Problem, Solution, Non-Goals, Alternatives Considered, plus Goals or Acceptance criteria) and runs scripts/validate.sh before delivery. Loads the brevity skill for prose rules, never noah-voice."
---

# Design-Doc Skill

Produces and reviews the documents Noah triages: design docs, directives, RFCs, technical proposals. "TRD" is his
spoken alias for the same artifact. Elsewhere in the industry TRD means a requirements spec, which is a different
thing, so the skill is named `design-doc` and answers to both.

The reader gives this document about two minutes. Everything below serves that fact.

Not every planning document is a design doc. `PROJECT_PLAN.md` follows the `borg-plan` template — Objective, Scope
Boundaries, Ship Definition, Timeline, Risks — and archived copies under `docs/plans/assimilated/` keep that shape.
Do not run the validator against those and do not reshape them to pass it; they are a different artifact answering
a different question.

## Voice: load `brevity`, never `noah-voice`

Before writing a word, load the `brevity` skill and read its `references/portable-voice.md`. That file is the
single source of truth for the prose rules in this genre. Everything below is structure, not prose rules.

**Do not load `noah-voice` for this genre.** It is calibrated for long-form Medium articles, and two of its hard
rules contradict this template directly: the em-dash ban (em dashes carry the tl;dr opener and every work-item
label) and the ban on bullet lists in body text (Non-Goals, Alternatives Considered, Goals, and Acceptance
criteria are all lists by design). The full set of dropped `noah-voice` rules, each with the measurement behind
it, is the "Not carried over" section of `portable-voice.md`.

The split runs along reading documents versus scanning documents. Articles are read start to finish and use
`noah-voice` unchanged. Design docs are scanned, and use the portable spine in `brevity`.

## The template

```markdown
# Directive: <title>

*Filed: <date> · Status: Proposed · Parent: <parent file or "none">*

**tl;dr** — <one sentence of problem> <one sentence of solution>

## Problem

## Solution

## Goals            <!-- program-level -->
## Acceptance criteria   <!-- implementation-level; pick the one that fits -->

## Non-Goals

## Alternatives Considered

## Decisions requested   <!-- only when you are asking for a decision; always last -->
```

**Always required, five things:**

1. **tl;dr** as a bold lead line, not a heading. It sits under the title and status line, above the first `## `
   heading. One sentence of problem, one of solution, readable by someone with no context. This is the only part
   that is guaranteed to be read.
2. `## Problem` — the measured facts that make this worth doing. Numbers, dates, observed failures. Not the
   solution wearing a problem costume.
3. `## Solution` — what you will build, concrete enough to argue with.
4. `## Non-Goals` — falsifiable boundary statements. "Not X" where X is a thing a reasonable reader would
   otherwise assume is in scope. A Non-Goal nobody would have expected is filler.
5. `## Alternatives Considered` — load-bearing, not decoration. Every rejected option gets the trade-off that
   killed it. If an alternative has no stated reason for rejection, it was not considered.

**One outcome section, minimum:**

- `## Goals` for a program-level document: what is true for the reader once this lands.
- `## Acceptance criteria` for an implementation-level document: checkable statements, each with how it is
  verified.

Pick the one that matches the document's level. Both in one document is legal and the validator only advises on
it, but it usually means the document has not decided whether it is a program or a change.

**Conditional:** `## Decisions requested` appears only when the document actually asks for a decision, and when it
appears it goes last. Anything after it pushes the block you need answered off the bottom of the terminal, which is
where the reader's eyes land.

Extra sections (Ship definition, Risks, Timeline, Testability) are always allowed. Put them before
`## Decisions requested`.

## Length

One to three pages, per `portable-voice.md` rule 12, which owns the cap and the measured word target. If the
document is longer than three pages, the usual fix is that it is really two documents: an umbrella and a child.
Split it and give the child a `Parent:` in its status line.

## Status line

Every document carries one, immediately under the title:

```
*Filed: 2026-08-20 · Status: Proposed · Parent: 2026-08-20-communication-program.md*
```

`Status` is `Proposed`, `Accepted`, or `Superseded`, and it is kept current: an accepted document records the date
and who accepted it (`Status: Accepted 2026-08-20 · Owner: Noah`). A superseded one names its replacement. `Parent`
is omitted on a top-level document.

## Before delivering

Run the validator on the file. Always. It is the reason this template stays enforceable:

```bash
bash <this skill's directory>/scripts/validate.sh path/to/doc.md
```

In an installed plugin that path is `"$CLAUDE_PLUGIN_ROOT/skills/design-doc/scripts/validate.sh"`; in a checkout of
`claude-plugins` it is `noah-content-tools/skills/design-doc/scripts/validate.sh`. Use whichever resolves, and do
not skip the run because the document "obviously" has every section.

- **Exit 1** means a required piece is missing. Fix it and re-run before showing the document to anyone.
- **Exit 2** is a usage error: wrong argument count or an unreadable path.
- **Exit 0** ships, even with advisories printed. Advisories are shape warnings, not rejections. Read each one,
  then either restructure or keep the shape deliberately and say why in the delivery message.

When reviewing an existing document rather than writing one, run the validator first and lead the review with its
output.
