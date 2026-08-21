# Directive: Template Snippet Handling

*Filed: 2026-08-20 · Status: Proposed*

**tl;dr** — A document that quotes the template in a code fence must not get credit for the headings inside that
fence. This fixture has no real `## Non-Goals` section, only a quoted one.

## Problem

A validator that greps for headings anywhere in the file passes any document that pastes the template into an
example block, which is exactly what a document about documents does.

## Solution

Skip fenced regions when building the heading table.

## Goals

- The heading table reflects the document's own structure, not its examples.

## Alternatives Considered

- **Grep the whole file.** Rejected: it is the bug this fixture exists to catch.

Here is the template being quoted, not used:

```markdown
## Non-Goals

- Not a real section. This block is an example.
```
