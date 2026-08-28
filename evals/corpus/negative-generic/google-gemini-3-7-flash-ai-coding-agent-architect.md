---
class: generic
provider: google
model: gemini-3.7-flash
generated: 2026-08-28
target_words: 1275
source_article: ai-coding-agent-architect.md
prompt: |
  Write a technical blog post titled "Why Your AI Coding Agent Needs a Professional Architect" about Using Clean Architecture layers and a pylint plugin to constrain the code structure that AI coding assistants produce in Python projects.. Aim for about 1275 words. The audience is working data engineers.

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# Why Your AI Coding Agent Needs a Professional Architect

Autonomous coding agents and Large Language Model (LLM) workflows have permanently shifted the baseline for data engineering velocity. With tools like Cursor, GitHub Copilot Workspace, and Claude-powered CLI agents, generating a 200-line data extraction pipeline takes thirty seconds instead of an entire afternoon.

Yet, data platforms everywhere are witnessing a quiet crisis: the rapid accumulation of architectural rot. 

Left to their own devices, AI agents are hyper-competent junior developers with near-infinite typing speed and zero systemic discipline. They solve problems locally. If you ask an agent to implement a data reconciliation check, it will happily embed raw DuckDB queries, AWS S3 API calls, custom validation logic, and Airflow context handles inside a single, untestable 400-line script. 

When your codebase is generated at machine speed, technical debt compounds at machine speed.

To harness the power of AI coding agents without sacrificing maintainability, data engineering teams must stop treating prompt engineering as an architectural strategy. You cannot solve structural drift with natural language guidelines. You need deterministic, automated architectural boundaries: **Clean Architecture** enforced by **custom static analysis linters**.

---

## The Root Cause: Local Optimization and Context Drift

LLMs generate code by optimizing token probabilities based on the immediate context window. They possess no innate mental model of your project’s long-term modularity. 

When an agent writes code for a data pipeline, it exhibits three predictable anti-patterns:

1. **Framework Entanglement:** Mixing execution engines (PySpark, Polars, DuckDB) directly into core business rules, making compute migrations or local unit testing painful.
2. **I/O Leakage:** Scattering storage calls (`boto3`, database cursors, REST API calls) throughout business logic layers.
3. **Leaky Abstractions:** Passing framework-specific constructs (like an Airflow `TaskInstance` or an orchestration runtime context) deep into analytical calculation engines.

Adding a sentence like *"Please follow clean architecture principles"* to your `.cursorrules` or system prompt works for the first two iterations. But as the context window fills with stack traces, file diffs, and schema definitions, the agent experiences context drift. It reverts to the path of least resistance: tightly coupled, monolithic code.

---

## Clean Architecture for Data Engineering

Clean Architecture (and its sibling, the Ports and Adapters / Hexagonal pattern) is not just for backend web services. It is arguably *more* critical in data engineering, where the velocity of underlying technology shifts (e.g., migrating from Spark to Polars, or Snowflake to DuckDB) routinely breaks monolithic scripts.

```
       +-------------------------------------------------------+
       | Infrastructure (Airflow, AWS SDK, DB Drivers)         |
       |   +-----------------------------------------------+   |
       |   | Adapters (Data Repositories, Spark I/O)       |   |
       |   |   +---------------------------------------+   |   |
       |   |   | Use Cases (Pipelines, Transformations)|   |   |
       |   |   |   +-------------------------------+   |   |   |
       |   |   |   | Domain (Entities, Pure Rules) |   |   |   |
       |   |   |   +-------------------------------+   |   |   |
       |   |   +---------------------------------------+   |   |
       |   +-----------------------------------------------+   |
       +-------------------------------------------------------+
```

Under this model, we organize our data repository into four concentric layers governed by the **Dependency Rule**: *Source code dependencies must point inward only.*

1. **Domain Layer (`src/domain`):** Pure Python. Contains domain models (Pydantic models, dataclasses) and core validation logic. It has zero external dependencies—no Spark, no SQL drivers, no network libraries.
2. **Use Cases Layer (`src/use_cases`):** Orchestrates the flow of data. Defines *what* the pipeline does (e.g., `CalculateMonthlyChurnUseCase`), relying only on abstract interfaces (Protocols/ABCs) for data loading and saving.
3. **Adapters Layer (`src/adapters`):** Concrete implementations of those interfaces. This is where your engine-specific code lives: Polars reader implementations, SQL repositories, or Delta Lake writers.
4. **Infrastructure Layer (`src/infrastructure`):** Entry points and environment configurations. This is where your Airflow DAG definitions, Prefect flows, CLI parsers, and cloud provider initialization logic reside.

When an AI agent is tasked with adding a new metric, it shouldn't touch storage mechanisms or DAG parameters. It should write a pure function in the domain layer, wire it into a use case, and test it in milliseconds using standard Python fixtures.

---

## The Guardian: Structural Linting with Pylint

You cannot rely on manual code reviews to catch architectural violations when your team merges dozens of AI-assisted PRs a week. You need the build to break the second an agent violates layer boundaries.

While standard linters check for PEP 8 compliance, variable naming, and unused imports, we can extend **Pylint** with a custom Abstract Syntax Tree (AST) checker to turn Clean Architecture rules into hard compile-time constraints.

### Designing a Layer-Enforcement Pylint Plugin

Below is an implementation of a custom Pylint checker that inspects AST import nodes (`astroid.nodes.Import` and `astroid.nodes.ImportFrom`) to enforce our dependency boundaries.

```python
# linters/clean_architecture_checker.py
import astroid
from pylint.checkers import BaseChecker
from pylint.interfaces import IAstroidChecker

class CleanArchitectureChecker(BaseChecker):
    __implements__ = IAstroidChecker

    name = "clean-architecture"
    priority = -1
    msgs = {
        "E9001": (
            "Domain layer cannot import from outer layers: %s",
            "domain-layer-violation",
            "The domain layer must remain pure and cannot import adapters, use_cases, or infrastructure.",
        ),
        "E9002": (
            "Prohibited framework import in domain or use_case: %s",
            "framework-leak-violation",
            "Data frameworks (pyspark, duckdb, boto3) cannot be imported in domain or use_case modules.",
        ),
    }

    RESTRICTED_FRAMEWORKS = {"pyspark", "duckdb", "boto3", "sqlalchemy", "airflow"}

    def visit_import(self, node: astroid.Import) -> None:
        for name, _ in node.names:
            self._check_violation(node, name)

    def visit_importfrom(self, node: astroid.ImportFrom) -> None:
        modname = node.modname or ""
        self._check_violation(node, modname)

    def _check_violation(self, node: astroid.NodeNG, imported_module: str) -> None:
        module_path = node.root().name

        # Enforce Domain Layer Isolation
        if "src.domain" in module_path:
            forbidden_layers = ("src.adapters", "src.use_cases", "src.infrastructure")
            if any(imported_module.startswith(layer) for layer in forbidden_layers):
                self.add_message("domain-layer-violation", node=node, args=imported_module)

        # Enforce Engine Decoupling from Core Logic
        if "src.domain" in module_path or "src.use_cases" in module_path:
            root_import = imported_module.split(".")[0]
            if root_import in self.RESTRICTED_FRAMEWORKS:
                self.add_message("framework-leak-violation", node=node, args=imported_module)


def register(linter):
    linter.register_checker(CleanArchitectureChecker(linter))
```

### Hooking the Plugin into Pylint

To activate the plugin, register it inside your project's `.pylintrc` or `pyproject.toml`:

```toml
# pyproject.toml
[tool.pylint.master]
load-plugins = ["linters.clean_architecture_checker"]

[tool.pylint.messages_control]
enable = ["domain-layer-violation", "framework-leak-violation"]
```

If an AI agent generates code inside `src/domain/aggregations.py` that includes:

```python
import duckdb  # Prohibited in domain!
from src.adapters.postgres_repository import PostgresRepository  # Prohibited!
```

Pylint immediately fails with:

```text
src/domain/aggregations.py:1:0: E9002: Prohibited framework import in domain or use_case: duckdb (framework-leak-violation)
src/domain/aggregations.py:2:0: E9001: Domain layer cannot import from outer layers: src.adapters.postgres_repository (domain-layer-violation)
```

---

## The AI Feedback Loop: Deterministic Self-Correction

The true beauty of using deterministic linters with AI coding agents is that LLMs excel at fixing code when provided with explicit compiler or linter errors.

When your CI pipeline or local environment agent encounters a structural failure, the linter output acts as an actionable, low-token feedback mechanism:

```
[Agent Prompts & Feedback Workflow]
       |
       v
  1. Agent writes code inside src/domain/models.py
       |
       v
  2. Agent executes pre-commit / pylint
       |
       v
  3. Pylint yields: E9002: Prohibited framework import: pyspark
       |
       v
  4. Agent reads exact error trace, realizes it violated
     the architecture boundary, refactors PySpark code into
     an adapter interface, and updates domain models to pure dataclasses.
```

Instead of a human reviewer writing an essay on a pull request about why using Spark transformations directly inside a domain validation model violates separation of concerns, the linter catches it in milliseconds. The agent self-corrects before human eyes ever look at the diff.

---

## Structuring the Repository for Maximum Agent Precision

To make this architecture frictionless for AI agents, structure your Python package explicitly:

```text
my_data_platform/
├── linters/
│   └── clean_architecture_checker.py
├── src/
│   ├── domain/              # Pure Python entities, schemas, logic
│   │   ├── __init__.py
│   │   └── models.py
│   ├── use_cases/           # Pipeline logic & protocols
│   │   ├── __init__.py
│   │   ├── ports.py         # Abstract interfaces (Typing Protocols)
│   │   └── process_orders.py
│   ├── adapters/            # Engine implementations
│   │   ├── __init__.py
│   │   ├── s3_polars_reader.py
│   │   └── delta_lake_writer.py
│   └── infrastructure/      # Orchestration runtime
│       ├── __init__.py
│       └── airflow_dags.py
├── tests/
└── pyproject.toml
```

By defining interfaces in `src/use_cases/ports.py` using standard `typing.Protocol` classes, you give the AI agent concrete contracts to implement:

```python
# src/use_cases/ports.py
from typing import Protocol
from src.domain.models import OrderBatch

class OrderReader(Protocol):
    def read_unprocessed_orders(self) -> OrderBatch:
        """Fetch raw unprocessed orders from storage."""
        ...

class OrderWriter(Protocol):
    def write_processed_orders(self, batch: OrderBatch) -> None:
        """Persist processed domain entities."""
        ...
```

When you instruct an AI agent: *"Implement a new DuckDB-based OrderReader adapter,"* the agent has a strictly isolated target. It knows it belongs in `src/adapters/`, must satisfy `OrderReader`, and cannot bleed into other domains.

---

## Velocity Requires Boundaries

Generative AI agents provide unprecedented development throughput. But throughput without structural constraints leads straight into an unmaintainable codebase.

By establishing Clean Architecture boundaries and codifying them with custom Pylint plugins, you give your AI coding assistants a safe sandbox. You allow the agent to generate local code at lightning speed while ensuring your overall system remains clean, testable, and completely decoupled from framework churn. 

AI coding agents don't eliminate the need for software architects. They make software architecture more essential than ever.
