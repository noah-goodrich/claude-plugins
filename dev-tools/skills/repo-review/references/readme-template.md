# README Template Guide

Adapt this structure to the repo type. Omit sections that do not apply. Every section includes guidance on what to write and when to skip it.

## Section Reference

### 1. Title and Badges (always include)

```
# project-name

[CI badge] [Python version badge] [Coverage badge if available]
```

One-line description directly under the title. Not a paragraph. What does this repo do, in one sentence a new engineer can understand.

### 2. Overview (always include)

2-4 sentences expanding on the one-liner. Answer:
- What problem does this solve?
- Who uses it? (team, service, external users)
- Where does it run? (Astronomer, AWS, local, etc.)

For data engineering repos, include: what data flows through this, from where to where.

### 3. Tech Stack (always include)

Table format:

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Language | Python 3.11 | ... |
| Framework | Airflow 2.x | ... |

### 4. Prerequisites (always include)

Numbered list of what must be installed. Include version constraints from the repo config. For new-member audience, include install commands:

```
1. Python 3.11+ (`brew install python@3.11`)
2. Poetry (`pip install poetry`)
3. Docker Desktop (`brew install --cask docker`)
```

### 5. Getting Started (always include)

Sequential, copy-pasteable commands from clone to running. Adapt to what the repo actually uses (Poetry, pip, npm, etc.).

For repos with devcontainers:
```
git clone <url>
cd <repo>
dev up
```

For Poetry repos:
```
git clone <url>
cd <repo>
poetry install
```

### 6. Project Structure (include for repos with 3+ top-level directories)

Annotated directory tree, top 2 levels. Use comments to explain non-obvious directories:

```
repo/
  dags/              # Airflow DAG definitions (thin wrappers)
  data_eng_dags/     # Shared Python modules (business logic)
  scripts/           # Entry point scripts called by DAG tasks
  tests/             # pytest test suite
  soda/              # Data quality check definitions
```

### 7. Development (include when repo has dev tooling)

How to:
- Run tests
- Run linting/formatting
- Run locally (if applicable)
- Common development tasks

Use actual commands from the repo (Makefile targets, npm scripts, pyproject.toml scripts).

### 8. Configuration (include when repo has non-trivial config)

Table format for environment variables, config files, feature flags:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| ... | ... | ... | ... |

### 9. Deployment (include when CI/CD is present)

How code gets from PR to production. Branch strategy, CI pipeline stages, deployment targets. If you cannot determine this from the repo, note it as a gap that needs human documentation.

### 10. Key Concepts (include for domain-specific repos)

Explain patterns and conventions that are not obvious from the code structure:
- For Airflow: DAG naming, operator patterns, connection management, task delegation model
- For dbt: model layers (staging/intermediate/marts), naming conventions, materialization strategy
- For APIs: endpoint patterns, auth approach, error handling

### 11. Troubleshooting (include only when you find real issues)

Known gotchas, common errors, debugging tips. Only include if you can identify real issues from the code (e.g., VPN requirements, Docker daemon dependency, version conflicts).

### 12. Contributing (include for repos with multiple contributors)

Brief: branch naming, PR process, review requirements. Reference CODEOWNERS if present.

## Repo-Type Adaptations

### Airflow DAG Repos
Add a **DAG Inventory** table:

| DAG ID | Schedule | Description | Key Datasets |
|--------|----------|-------------|-------------|

Emphasize: task delegation model (DAGs -> scripts -> modules), connection requirements, how tasks run (K8s, local, etc.).

### dbt Projects
Add a **Model Layers** section explaining staging/intermediate/marts. Include a sources table. Emphasize: how to run specific models, profile setup, testing strategy.

### Python Packages
Emphasize: installation, public API surface, usage examples pulled from tests, versioning/release process.

### API Services
Add an **Endpoints** table. Emphasize: authentication, request/response examples, local dev server, database migrations.

### Data Pipelines
Add a **Data Flow** section with ASCII diagram showing sources -> transforms -> destinations. Emphasize: scheduling, retry behavior, data quality checks.
