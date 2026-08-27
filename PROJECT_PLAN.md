# Project Plan: ai-scoring Evaluation Set
*Established: 2026-08-27*
*Parent directive: docs/plans/directives/2026-08-26-ai-scoring-evaluation-set.md (S2, and the harness S5 needs)*

## Objective

Build a negative corpus with known provenance and a harness that measures against it honestly, so the ai-scoring
article path can be recalibrated on evidence instead of on a corpus assembled from the rubric's own answer key.

## Acceptance Criteria

- [ ] **AC1 — Negatives with known provenance.** At least 20 generated documents from at least 3 providers
      (Anthropic, Google, Snowflake Cortex), matched pairwise to the 10 human articles on topic and word target.
      Each carries frontmatter recording provider, model, generation date, the exact prompt, and the word target.
  - Verify: `bash evals/test/run-tests.sh` includes a provenance check that fails on any missing field; the
    human and negative word-count distributions overlap, so word count alone no longer separates the classes.
- [ ] **AC2 — Two negative classes, both present and labelled.** `generic` is unprompted model prose. `voiced` is
      Claude drafting in Noah's voice with `noah-voice` loaded — the population the gate actually runs on, which
      exists in neither the human corpus nor the old fixtures.
  - Verify: both directories are non-empty and the manifest records a class per document; the harness refuses to
    report if either class is missing.
- [ ] **AC3 — No rubric contamination.** Rubric-term density in the negatives falls inside the range measured for
      real writing, 0.00-0.55 hits per 100 words, not the old fixture range of 7.14-8.33.
  - Verify: `python3 evals/harness/evaluate.py --contamination` prints per-class density and exits non-zero above
    a 1.0 ceiling.
- [ ] **AC4 — The held-out split is sealed.** Membership is committed, a seal file records a content hash and a
      use counter, and the harness refuses to report held-out numbers a second time without an explicit override.
  - Verify: editing a held-out file changes the hash and the harness fails loudly; a second held-out run without
    `--break-seal` exits non-zero with the reason.
- [ ] **AC5 — Every rate carries an interval.** No bare percentage appears in the report, and the report states
      how many documents the interval the reader wants would actually need.
  - Verify: a test asserts every reported rate is accompanied by a Wilson 95% interval.
- [ ] **AC6 — The harness is offline; only generation touches the network.** `generate.sh` defaults to a dry run.
      CI runs the harness and never the generator.
  - Verify: harness tests pass with no network; `grep` finds no network call under `evals/harness/`; the CI job
    invokes only the test runner.
- [ ] **AC7 — Nothing breaks.** Existing suites stay green.
  - Verify: `bash research-tools/hooks/test/run-tests.sh` and the `design-doc` suite both pass.

## Testability

- **Testable core.** `evals/harness/*.py` are pure functions over files: no network, no global state, no clock
  dependence. Split membership is deterministic from a committed seed, so two runs agree.
- **Shell is a thin wrapper.** `evals/generate/generate.sh` dispatches to one provider script per API and writes
  frontmatter. It holds no scoring logic.
- **Tests ship in the same commit** at `evals/test/run-tests.sh`, fixture-driven, following the existing pattern in
  `research-tools/hooks/test/run-tests.sh` — plain bash, no bats dependency.
- **Existing untested code this plan touches: none.** `ai_score.py` is read by the harness and not modified here.
  Wiring a test between it and the rubric prose is AC6 of the parent directive and is deliberately not in scope.

## Scope Boundaries

- NOT recalibrating the rubric. That is S4 and S5 of the directive and needs this corpus to exist first.
- NOT changing the 75 constant, or any category's computation.
- NOT extracting session transcripts. That is S3, it carries its own privacy decision, and it is a separate build.
- NOT scraping Medium or LinkedIn, per the directive's first Non-Goal.
- NOT generating the full corpus automatically. Generation costs real API spend, so the build ships a working
  generator plus a small proven pilot, and the full run is a command Noah triggers.
- If done early: ship what we have, don't expand scope.

## Ship Definition

PR opened → harness tests green in CI → corpus committed with provenance → held-out split sealed → merged.

## Timeline

Target: 2 sessions. The harness is one; generation and validation is the other, and its length depends on how many
documents Noah wants to pay for.

## Risks

- **API spend is the real cost and it is not mine to authorise.** Thirty-plus articles across three providers is
  the bulk of the work. The generator therefore defaults to a dry run and reports estimated volume before writing.
- **The voiced class is unavoidably all-Anthropic.** That is not a flaw — it is the deployed population, since the
  gate runs on Claude drafting in Noah's voice. But it means the voiced class cannot also serve as evidence about
  machine prose in general, and the report must not blur the two.
- **The sample stays too small for tight intervals.** Bounding a false-positive rate to ±10 points needs roughly
  35 human documents against the 10 that exist. AC5 exists so the report says this out loud rather than
  presenting a clean-looking rate that the sample cannot support.
- **Cortex auth may not be available non-interactively.** If it is not, the provider count drops to two and AC1
  fails honestly rather than being quietly redefined.
