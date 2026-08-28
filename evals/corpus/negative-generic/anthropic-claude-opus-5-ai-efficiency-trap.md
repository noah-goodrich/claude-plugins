---
class: generic
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 1080
source_article: ai-efficiency-trap.md
prompt: |
  Write a technical blog post titled "The AI Efficiency Trap: Why I Built a Tool to Tell Cursor What to Test" about Scoring Python code by risk and complexity so an AI assistant writes tests for high-impact logic instead of chasing coverage percentage.. Aim for about 1080 words. The audience is working data engineers.

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# The AI Efficiency Trap: Why I Built a Tool to Tell Cursor What to Test

Last quarter I did the thing everyone does. I opened Cursor on our ingestion repo, selected the `transforms/` directory, and typed: *"Write pytest unit tests for these modules. Target 90% coverage."*

Forty minutes later I had 2,400 lines of new test code, coverage went from 41% to 88%, and CI turned green. I felt productive in the way you feel productive after reorganizing your desk.

Two weeks later we shipped a bug where a `LEFT JOIN` in a Spark transform silently fanned out rows because a supposedly-unique dimension key had duplicates after an upstream schema change. Revenue reporting was off by 3% for four days. The function containing that join had 100% line coverage. The generated test asserted that the output DataFrame was not `None`.

That's the AI efficiency trap: LLMs are extremely good at producing artifacts that satisfy the metric you named, and coverage percentage is a metric that has almost nothing to do with whether your pipeline is correct.

## Coverage is the wrong objective function for data code

Line coverage answers "did this line execute?" In data engineering, almost every bug I've shipped executed just fine. The failure modes are:

- A join grain changes and rows multiply.
- A `fillna(0)` turns missing revenue into zero revenue.
- A timezone-naive timestamp crosses a partition boundary.
- An `astype(int)` truncates instead of raising.
- A watermark filter uses `>` where it should use `>=` and drops one micro-batch.

None of these are uncovered lines. They're covered lines with unexamined semantics. Meanwhile the LLM, given a coverage target, will happily write eleven tests for your `Config` dataclass because that's the cheapest way to move the number.

The fix isn't a better prompt. It's changing what you point the model at. So I wrote a ~400-line CLI, `risk-rank`, that scores every function in a repo and emits a ranked worklist. Cursor doesn't decide what to test anymore. It gets told.

## What "risk" actually means

I settled on four signals. None are novel individually; the value is combining them and refusing to test anything below a threshold.

**1. Cyclomatic complexity.** Branching is where semantics hide. A straight-line function has one behavior; a function with six branches has at least six, and the LLM will test one of them unless you enumerate them.

**2. Blast radius (fan-in).** A helper called by fourteen DAG tasks deserves more scrutiny than a one-off backfill script. I approximate this with a static call graph over the repo.

**3. Churn.** Code that changes often is code whose assumptions are unstable. `git log` knows more about your risk profile than your architecture diagram does.

**4. Data hazards.** This is the domain-specific part and the one that made the tool actually useful. I keep a pattern registry of AST shapes that correlate with silent data corruption in Python data code.

## The implementation

Complexity is a straightforward AST walk:

```python
import ast

BRANCHING = (ast.If, ast.For, ast.While, ast.ExceptHandler,
             ast.With, ast.Assert, ast.IfExp, ast.comprehension)

def complexity(fn: ast.FunctionDef) -> int:
    score = 1
    for node in ast.walk(fn):
        if isinstance(node, BRANCHING):
            score += 1
        elif isinstance(node, ast.BoolOp):
            score += len(node.values) - 1
    return score
```

The hazard registry is where I spent most of my time. Each entry is a matcher plus a weight plus—critically—a *test hint* that gets passed downstream to the model:

```python
HAZARDS = [
    Hazard(
        name="join_without_validate",
        weight=5,
        match=lambda n: (is_call(n, {"merge", "join"})
                         and not has_kwarg(n, "validate")),
        hint=("Join has no `validate=` guard. Test that duplicate keys on the "
              "right side raise or are detected, not silently fanned out."),
    ),
    Hazard(
        name="null_coercion",
        weight=4,
        match=lambda n: is_call(n, {"fillna", "coalesce", "na.fill"}),
        hint="Null is being replaced. Test that a legitimately-null input is "
             "distinguishable from the fill value downstream.",
    ),
    Hazard(
        name="unsafe_cast",
        weight=3,
        match=lambda n: is_call(n, {"astype", "cast"}) and not has_kwarg(n, "errors"),
        hint="Test cast behavior on out-of-range, null, and malformed values.",
    ),
    Hazard(
        name="naive_datetime",
        weight=4,
        match=lambda n: is_call(n, {"now", "utcnow", "to_datetime"})
                        and not has_kwarg(n, "tz") and not has_kwarg(n, "utc"),
        hint="Timezone-naive timestamp. Test DST boundary and UTC-offset inputs.",
    ),
    Hazard(
        name="swallowed_exception",
        weight=5,
        match=lambda n: isinstance(n, ast.ExceptHandler)
                        and all(isinstance(s, (ast.Pass, ast.Continue)) for s in n.body),
        hint="Exception is swallowed. Test that the failure path does not "
             "produce a partial write or empty-but-successful output.",
    ),
    Hazard(
        name="float_equality",
        weight=2,
        match=lambda n: isinstance(n, ast.Compare)
                        and any(isinstance(o, ast.Eq) for o in n.ops)
                        and involves_float(n),
        hint="Float equality comparison. Test near-boundary values.",
    ),
]
```

Churn comes from git, scoped to the line range of each function:

```python
def churn(path: str, start: int, end: int, since="18.months") -> int:
    out = subprocess.run(
        ["git", "log", f"--since={since}", "--format=%H",
         "-L", f"{start},{end}:{path}"],
        capture_output=True, text=True).stdout
    return len(set(re.findall(r"^[0-9a-f]{40}$", out, re.M)))
```

And the score, with everything min-max normalized across the repo:

```python
score = (0.30 * n(complexity)
         + 0.25 * n(fan_in)
         + 0.20 * n(churn)
         + 0.25 * n(hazard_weight)) * (1.0 - existing_branch_coverage)
```

The final multiplier matters. It reads `coverage.json` and discounts functions that already have real branch coverage, so the tool converges instead of nagging you about the same three modules forever.

## Wiring it into Cursor

The output isn't a report for humans. It's a prompt payload:

```markdown
## TEST TARGET 1 — risk 0.91
`transforms/orders.py::enrich_with_customer` (L44–L98)
complexity 17 | fan-in 9 | churn 22 commits | coverage 0.34

Hazards detected:
- join_without_validate (L61): Join has no `validate=` guard. Test that
  duplicate keys on the right side raise or are detected, not silently
  fanned out.
- null_coercion (L73): Null is being replaced. Test that a legitimately-null
  input is distinguishable from the fill value downstream.

Required assertions:
- Output row count relative to input row count under duplicate keys
- Behavior when the right frame is empty
- Behavior when the join key is null on either side
```

Then a `.cursorrules` entry that constrains the model hard:

```
When writing tests, only test functions listed in RISK_REPORT.md.
Do not write tests for dataclasses, config objects, or thin wrappers.
Every test must assert on data semantics: row counts, null handling,
grain, dtypes, or boundary values. `assert result is not None` and
`assert not df.empty` are forbidden as sole assertions.
Prefer property-based tests (hypothesis) for numeric transforms.
One test file per target function, named test_<module>_<function>.py.
```

The behavioral change is dramatic. Given a risk report instead of a directory, Cursor writes ten tests that catch real bugs rather than two hundred that catch nothing. On the orders module, the very first generated test reproduced the fan-out bug that cost us four days of bad reporting.

## What it doesn't do

It's static analysis, so dynamic dispatch, string-built SQL, and anything behind a plugin registry are invisible. It underrates I/O boundary code that's structurally simple but operationally dangerous—I hand-pin those into the report. And the weights are vibes calibrated against our incident history, not a fitted model; yours will differ.

But the core idea generalizes past testing: **the bottleneck with coding assistants is no longer generation, it's aim.** When generation is nearly free, the scarce resource is a defensible ranking of what's worth generating. Coverage percentage is a ranking, technically. It's just an actively bad one, and the model will pursue it with a diligence that makes the badness expensive.

Score your code. Then tell the assistant where to point.
