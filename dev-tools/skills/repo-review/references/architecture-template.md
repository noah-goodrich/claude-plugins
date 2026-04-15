# ARCHITECTURE.md Template Guide

Generate this file only when the repo has sufficient complexity. This guide defines when to generate it and what to include.

## When to Generate

ALL of these must be true:
- Repo has 3+ distinct modules or packages
- There is a non-trivial data or control flow between components
- The README's project structure section alone would not adequately explain the relationships

## When to Skip

- Single-purpose CLI tool or script collection
- Repo with fewer than 10 source files
- The README covers the structure adequately

## Structure

### 1. Overview Diagram

ASCII diagram showing high-level components and their relationships. Keep it simple and editable:

```
[Source A] --> [Ingestion Layer] --> [Transform] --> [Destination]
                    |
              [Shared Utils]
```

Rules:
- Use arrows to show data/control flow
- Label arrows if the relationship is not obvious
- Keep to 1 diagram unless the system has genuinely separate flows
- ASCII only, no Mermaid

### 2. Component Descriptions

For each box in the diagram, write a paragraph covering:
- What it does
- Key files/directories that implement it
- What it depends on
- What depends on it

Use actual file paths. Link to specific files when helpful.

### 3. Data Flow (for data engineering repos)

Trace a single record from source to destination. Name the actual files and functions it passes through. Example:

```
1. DAG `ingest_github_dag.py` triggers on schedule
2. Task calls `scripts/ingest_github.py` via EKS pyscript
3. Script invokes `data_eng_dags.github_ingest.pipeline.run()`
4. Pipeline uses `GitHubClient` to fetch PR data from GitHub API
5. `PRCrawler` transforms raw API response into structured records
6. `SnowflakeLoader` writes records to `raw.github.pr_analysis`
```

This is the most valuable section for onboarding. It turns the abstract diagram into a concrete path someone can follow in the code.

### 4. Key Architectural Decisions

Document the non-obvious "why" behind structural choices:
- Why is X split into two modules instead of one?
- Why does Y use this pattern instead of the simpler alternative?
- What constraints drove the current design?

Only include decisions you can infer from the code. If a decision is unclear, note it as "worth asking the team about."

### 5. Extension Points

Where and how to add new functionality:
- For Airflow: how to add a new DAG, where shared operators live, task creation patterns
- For dbt: how to add a new model, where to put sources, testing conventions
- For APIs: how to add a new endpoint, middleware patterns

### 6. Dependencies Between Components

Document non-obvious coupling:
- "Changing X requires also updating Y because..."
- Shared state, shared configs, import chains
- Order-of-operations requirements
