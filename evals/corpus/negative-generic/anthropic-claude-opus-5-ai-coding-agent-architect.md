---
class: generic
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 1275
source_article: ai-coding-agent-architect.md
prompt: |
  Write a technical blog post titled "Why Your AI Coding Agent Needs a Professional Architect" about Using Clean Architecture layers and a pylint plugin to constrain the code structure that AI coding assistants produce in Python projects.. Aim for about 1275 words. The audience is working data engineers.

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# Why Your AI Coding Agent Needs a Professional Architect

Your coding agent is a fast, tireless mid-level engineer with no memory of last Tuesday. It writes correct-looking Python at an alarming rate, it passes the tests it wrote for itself, and it has absolutely no opinion about where code should live. Left alone for three sprints, it will produce a data platform that works and that nobody — human or model — can safely change.

The fix is not a longer system prompt. It's making your architecture *executable*: encoding the dependency rules of Clean Architecture as a pylint plugin that fails loudly, in the agent's own feedback loop, the moment a boundary is crossed.

## The failure mode is structural, not syntactic

Ask an agent to "add a job that enriches order events with customer tier and lands them in the warehouse." You'll get something like this:

```python
@task
def enrich_orders(execution_date: str) -> None:
    spark = SparkSession.builder.getOrCreate()
    orders = spark.read.parquet(f"s3://raw/orders/dt={execution_date}")
    customers = pd.read_sql("SELECT * FROM dim_customer", get_snowflake_conn())
    ...
    # 180 lines of business logic, tier thresholds, currency conversion,
    # late-arriving-data handling, and a hardcoded retry loop
    df.write.mode("overwrite").saveAsTable("analytics.fct_orders_enriched")
```

Nothing here is *wrong*. It's the code a competent engineer writes under time pressure. The problem is that the tier thresholds — genuine business rules that finance argues about — now live inside a function that requires a Spark session, S3 credentials, and a Snowflake connection to execute. You cannot unit test them. You cannot reuse them in the streaming path. And when the next agent session is asked to "add tier logic to the realtime consumer," it will not find this code, because it isn't anywhere findable. It will write a second copy that drifts within a month.

Agents amplify this pattern for structural reasons:

- **No persistent architectural memory.** Each session reconstructs its mental model from whatever files it happened to read. If your layering is a convention rather than an artifact, it's invisible.
- **Token gravity.** The most probable continuation of `spark.read.parquet(...)` is more Spark code. Models pull toward the local idiom of the file they're in, not toward your global design.
- **Prose instructions are soft.** `CLAUDE.md` or `AGENTS.md` saying "keep business logic out of infrastructure" competes with 40k tokens of context. A linter error does not compete; it blocks.

## Clean Architecture, translated into data engineering

Strip Clean Architecture down to its one load-bearing idea: **dependencies point inward, toward policy, away from mechanism.** Four layers, mapped to things data engineers actually build:

| Layer | Contains | Never imports |
|---|---|---|
| `domain` | Entities, value objects, business rules. Pure Python + stdlib. `OrderTier`, `is_late_arriving()`, currency math. | Anything. Not even pandas. |
| `application` | Use cases orchestrating domain objects. `EnrichOrdersUseCase`. Defines `Protocol`s for the ports it needs. | Any concrete I/O library. |
| `adapters` | Implementations of those ports. `SparkOrderRepository`, `SnowflakeCustomerRepository`, schema mapping. | Entrypoints. |
| `infrastructure` | Airflow DAGs, CLI entrypoints, Spark session config, secrets, dbt shims. | Nothing — outermost layer. |

The payoff is concrete. Tier thresholds live in `domain/pricing.py`, tested in 4 milliseconds with no Spark session. The use case takes an `OrderRepository` protocol, so the batch job and the Kafka consumer share the exact same policy code with different adapters. And when someone asks "where does business logic live?", the answer is a directory, not a story.

The layout an agent can navigate:

```
src/acme_pipelines/
├── domain/          # pure
├── application/     # use cases + ports (Protocols)
├── adapters/        # spark, snowflake, s3 implementations
└── infrastructure/  # dags/, cli.py, settings.py
```

## Making the rule executable: a pylint plugin

`import-linter` is a fine tool and worth knowing, but a pylint checker has one decisive advantage in an agentic workflow: it emits per-line diagnostics from the tool the agent already runs, alongside the errors it already knows how to fix. It shows up in the same output stream as `undefined-variable`.

Here's a working checker in about 60 lines.

```python
# tools/archlint/checker.py
from astroid import nodes
from pylint.checkers import BaseChecker
from pylint.lint import PyLinter

ROOT = "acme_pipelines"
RANK = {"domain": 0, "application": 1, "adapters": 2, "infrastructure": 3}

# Third-party packages banned per layer.
FORBIDDEN = {
    "domain": {"pyspark", "pandas", "boto3", "sqlalchemy",
               "requests", "airflow", "snowflake"},
    "application": {"pyspark", "boto3", "sqlalchemy", "requests", "airflow"},
}


def _layer(modname: str) -> str | None:
    parts = modname.split(".")
    if len(parts) >= 2 and parts[0] == ROOT and parts[1] in RANK:
        return parts[1]
    return None


class LayerChecker(BaseChecker):
    name = "clean-architecture"
    msgs = {
        "E9001": (
            "Layer '%s' must not import from outer layer '%s'",
            "layer-violation",
            "Dependencies must point inward. Define a Protocol in the "
            "inner layer and inject the implementation.",
        ),
        "E9002": (
            "Layer '%s' must not depend on I/O package '%s'",
            "forbidden-dependency",
            "Inner layers stay pure so they are testable without "
            "infrastructure.",
        ),
    }

    def _check(self, node: nodes.NodeNG, imported: str) -> None:
        here = _layer(node.root().name)
        if here is None:
            return
        there = _layer(imported)
        if there is not None:
            if RANK[there] > RANK[here]:
                self.add_message("layer-violation", node=node,
                                 args=(here, there))
            return
        top = imported.split(".")[0]
        if top in FORBIDDEN.get(here, set()):
            self.add_message("forbidden-dependency", node=node,
                             args=(here, top))

    def visit_import(self, node: nodes.Import) -> None:
        for name, _ in node.names:
            self._check(node, name)

    def visit_importfrom(self, node: nodes.ImportFrom) -> None:
        modname = node.modname
        if node.level:
            modname = node.root().relative_to_absolute_name(
                node.modname, node.level)
        self._check(node, modname)


def register(linter: PyLinter) -> None:
    linter.register_checker(LayerChecker(linter))
```

Wire it up in `pyproject.toml`:

```toml
[tool.pylint.main]
load-plugins = ["archlint.checker"]
init-hook = "import sys; sys.path.insert(0, 'tools')"

[tool.pylint."messages control"]
enable = ["layer-violation", "forbidden-dependency"]
```

Now the earlier code produces:

```
src/acme_pipelines/domain/pricing.py:3:0: E9002: Layer 'domain' must not
depend on I/O package 'pyspark' (forbidden-dependency)
```

That message is the important artifact. It doesn't just say *no* — the `msgs` description tells the agent what to do instead: *define a Protocol in the inner layer and inject the implementation.* Write your check descriptions as instructions to a competent stranger, because that is exactly who is reading them.

## Closing the loop

A linter the agent runs at the end is a nuisance. A linter it runs *continuously* is an architect. Three places to install it:

1. **The agent's inner loop.** Put `make check` (pylint + mypy + pytest) in your agent instructions as the mandatory command after every edit. Most agents will iterate against a failing command until it's green — that's the entire mechanism you're exploiting.
2. **Pre-commit.** Catches the sessions that skipped step 1.
3. **CI.** Non-negotiable, no `--exit-zero`.

Keep the escape hatch explicit and expensive. Allow `# pylint: disable=layer-violation` only with a mandatory adjacent comment explaining why, and add a `grep` in CI that counts them. A slowly rising disable count is your architecture erosion metric — and unlike a wiki page, it's a number you can put on a dashboard.

## What this doesn't buy you

The checker verifies *direction of dependency*, not *quality of design*. An agent can still write a 500-line use case, an anemic domain model, or a `Protocol` with fourteen methods. It won't stop someone from putting a SQL string in a domain constant. Semantic review is still your job.

Two failure modes to watch. First, over-layering: a three-table ingestion job that only ever moves bytes does not need four layers, and forcing it there produces ceremony the agent will faithfully replicate everywhere. Apply this where business rules actually live. Second, drift between the rules and reality: if your `FORBIDDEN` map is stale, the checker becomes noise that everyone disables. Treat `checker.py` as production code — it has tests, it has an owner, it gets reviewed.

The broader point generalizes past architecture. Anything you want an AI agent to do consistently, you should encode as a check rather than a paragraph. Prose is a suggestion. A failing exit code is a specification. Your agent will happily write ten thousand lines this quarter; the only question is whether the shape of those lines is something you chose deliberately, or something that happened to you.
