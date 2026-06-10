# Directive 07 — Shared Card/Report Parser (Altitude Fix for A7–A12)

**Priority:** 07 · **Axis:** (b) Methodological depth / maintainability · **Feasibility:** Medium
**Depends on:** Directives 01–02 (the assertions it refactors) + the 2026-06-09 hardening pass (the regression
suite it must keep green)

---

## Goal

Replace the per-assertion `grep`/`sed`/`head`/`tail` scrapes over unstructured markdown in `deep-research-verify.sh`
with a SINGLE shared parse pass that extracts the structured facts once into an in-memory record the A* assertions
read from — so the gate's correctness stops depending on fragile text-position heuristics and a benign table-format
change can no longer silently flip a verdict.

## Context (review findings resolved)

- The 2026-06-09 multi-agent code review found 15 verify-gate bugs. The **altitude finding**: A7–A12 (and A2/A3)
  share ONE root cause — each assertion independently re-scrapes the same unstructured markdown with ad-hoc regex,
  extracting "the first/last integer on a line" instead of "the count cell." Both failure modes the review
  surfaced trace here: fail-OPEN (A7 `N>M`, A10/A12 reading the wrong integer, A3 accepting stray `>`-form bands)
  and fail-CLOSED (A6/A8 substring matches, A3 flagging unrelated prose).
- The 2026-06-09 pass **hardened each assertion individually** — anchored the band to its declaration line,
  read the aggregate `| Inaccessible | N |` row, bounded the exclusion match, switched the domain compare to a
  suffix test, fixed the BSD-sed `\b` no-op — and added `test/run-tests.sh` (37 checks). Every fix is correct, but
  each is still a point patch on a brittle line-scrape; the next benign formatting change will leak again.
- The durable fix is the one the verifier's own header already names as the forward-compat path: the gate should
  reason about a **ground-ledger record**, not files —
  `{ card_id, access_status, outcome, band, sample_n, sample_m, inaccessible_count, excluded_count,
  attribution_host }` — so "Directive 04 [can] swap the on-disk report/cards for a real emitted `ground.jsonl`
  WITHOUT a rewrite of the assertion logic." Parsing once into that record is the same move at a lower altitude:
  one parser owns markdown-cell-vs-colon-form, bold/whitespace tolerance, and band canonicalization; the assertions
  read fields.

## Acceptance Criteria

- [ ] A **single parse pass** materializes the §6/report facts into one in-memory record (band string, sample N,
      sample M, failure count, inaccessible count, excluded count) plus a per-card table (card → outcome, note),
      keyed the way the ground-ledger contract in the verifier header documents.
- [ ] A2/A3/A7/A8/A10/A12 **read fields from that record** — no assertion re-greps the report/deliverable for its
      own number. Cell extraction is by table-column / labelled-row position, never "first/last integer on the
      matched line."
- [ ] The parser is the **single** place that normalizes markdown-cell vs `Label: N` colon form, tolerates
      bold/whitespace, and canonicalizes the band token. Duplicated parsing across assertions is removed (reuse, not
      copy-paste).
- [ ] **Portability:** no GNU-only regex constructs (`\b`, `\<`, `grep -P`); validated on the macOS default
      toolchain — bash 3.2 + BSD `sed`/`grep`.
- [ ] **`test/run-tests.sh` stays 100% green** — all 16 fixtures keep their verdict, all 12 evasion/honest cases
      stay closed, all cross-cutting checks pass. This refactor changes structure, not behavior.
- [ ] Add **≥3 fixtures for benign formatting variants** (e.g. an `Inaccessible: N` colon form, a bold-wrapped
      count cell, an extra prose column in a table) that a position-based parser reads correctly but the old
      line-scrape would have mis-read — proving the altitude gain, not just preserving behavior.
- [ ] The record shape is chosen to anticipate a future emitted `ground.jsonl` (Directive 04 forward-compat) so it
      is not reworked again.
- [ ] All tests run inside the devcontainer via `drone exec`.

## Estimate

**2–3 sessions.** ~1–1.5 sessions: the parser + record shape + porting A2/A3/A7/A8/A10/A12 to read fields.
~0.5–1 session: de-duplicate the band/host/cell helpers and add the formatting-variant fixtures, keeping
`run-tests.sh` green throughout.

## Risks

- **Behavior drift.** A "cleanup" refactor can silently re-open a fail-open vector. Mitigation: `run-tests.sh` is
  the contract — green before and after — and the new variant fixtures lock the gain.
- **Over-engineering.** A full markdown AST is overkill; the parser must be a thin field-extractor, not a document
  model. Fewest moving parts, not fewest lines.
- **Premature ground.jsonl coupling.** Design the record to *anticipate* `ground.jsonl` without taking a hard
  dependency on Directive 04 shipping first.
