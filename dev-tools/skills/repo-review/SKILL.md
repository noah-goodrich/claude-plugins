---
name: repo-review
description: "First-time repository onboarding, exploration, and documentation generation. Use this skill when the user wants to understand a new repo, generate a README, create architecture docs, review a codebase they haven't seen before, or says 'review this repo', 'what does this repo do', 'generate docs', 'write a README', 'document this project', 'onboard me to this codebase'. Also trigger when asked to create ARCHITECTURE.md, explain a repo's structure, or audit existing documentation."
---

# Repo Review — Repository Onboarding & Documentation

Systematically explore a repository you have never seen before and generate documentation tailored to the repo type. Works across Python packages, Airflow DAG repos, dbt projects, data pipelines, APIs, CLI tools, and general software projects.

## Before You Begin

Read the reference files in this skill's directory:
- `references/exploration-checklist.md` — systematic exploration protocol
- `references/readme-template.md` — README structure by repo type
- `references/architecture-template.md` — ARCHITECTURE.md structure and when to generate one

## Defaults

These defaults apply unless the user explicitly overrides them:
- **Output**: README.md always. ARCHITECTURE.md only if the repo has 3+ modules with non-obvious relationships.
- **Audience**: New team member onboarding — explain everything, assume no company or project context.
- **Scope**: Cover everything. No specific focus.

**Low-friction rule**: If the user says "review this repo", "generate docs", or similar, just go. Do not ask clarifying questions. Only ask (via AskUserQuestion) if the user's intent is genuinely ambiguous (e.g., "document the deployment part" — clarify which part).

## Phase 1: Explore

Launch up to 5 Explore subagents in parallel. Each subagent gets a specific focus area. Pass each subagent the exploration checklist from `references/exploration-checklist.md` relevant to their focus.

### Subagent 1: Project Identity
- Read root directory listing
- Read existing README, CONTRIBUTING, LICENSE, CHANGELOG
- Read pyproject.toml, setup.py, package.json, Cargo.toml, go.mod, dbt_project.yml, or equivalent
- Read .project.yml, .tool-versions, .python-version if present
- **Report**: project name, language, framework, version, description, entry points, existing doc quality

### Subagent 2: Structure & Architecture
- Map directory tree (top 3 levels)
- Identify architectural pattern (monolith, package, DAG repo, dbt project, microservice, CLI, library)
- Read key structural files: __init__.py, main.py, app.py, or equivalent entry points
- Read up to 5 representative source files to understand code patterns
- **Report**: module boundaries, shared utilities, configuration patterns, data flow

### Subagent 3: Dependencies & Environment
- Read dependency files (requirements.txt, poetry.lock, pyproject.toml, package.json, etc.)
- Read environment config (.env.example, docker-compose.yml, Dockerfile, .devcontainer/, Makefile)
- Read CI/CD config (.github/workflows/, .gitlab-ci.yml, Jenkinsfile)
- **Report**: runtime deps, dev deps, internal vs external packages, infrastructure requirements, deployment targets, CI pipeline stages

### Subagent 4: Testing & Quality
- Read test directory structure and 2-3 representative test files
- Read linting/formatting config (.flake8, pyproject.toml [tool.black], .pre-commit-config.yaml)
- Read CODEOWNERS if present
- **Report**: test framework, test patterns, coverage setup, code quality tools, team ownership

### Subagent 5: Data & Domain (conditional)
Only spawn if Subagent 1 identifies the repo as data-related (Airflow, dbt, pipeline, ETL).
- Read DAG definitions, model files, pipeline configs
- Read connection/source configs (profiles.yml, connections.yaml, sources.yml)
- Read data quality configs (soda/, great_expectations/, dbt tests)
- **Report**: data sources, destinations, transformation patterns, scheduling, data quality approach

## Phase 2: Analyze

Synthesize subagent findings internally. Do not show this to the user.

### Repo Type Classification

Classify the repo to determine which template sections apply:

| Type | Indicators |
|------|-----------|
| airflow-dags | dags/ directory, airflow imports, DAG definitions |
| dbt-project | dbt_project.yml, models/ directory, .sql files with jinja |
| python-package | pyproject.toml with [build-system], src/ layout or flat package |
| python-app | Dockerfile, app entry point, no build-system config |
| data-pipeline | ETL scripts, scheduler configs, source/sink patterns |
| api-service | FastAPI/Flask/Django imports, routes, endpoint definitions |
| cli-tool | Click/Typer/argparse entry points, console_scripts |
| monorepo | Multiple independent packages/services in subdirectories |
| general | Does not match the above |

### Analysis Checklist

For each item, note present/absent and summarize in 1-2 sentences:
- Clear entry point(s)
- Dependency management approach
- Environment/config management
- Test coverage and patterns
- CI/CD pipeline
- Existing documentation quality
- Code organization pattern
- Error handling approach
- Logging/observability
- Security considerations (secrets, auth)

### ARCHITECTURE.md Decision

Generate ARCHITECTURE.md only if ALL of these are true:
- Repo has 3+ distinct modules or packages
- There is a non-trivial data or control flow between components
- The README's project structure section alone would not adequately explain the relationships

## Phase 3: Generate

Use `references/readme-template.md` and `references/architecture-template.md` as structural guides. Adapt section depth and content to what the repo actually contains.

### Hard Rules

1. **No invented information.** If you cannot determine something from the code, say so or omit the section.
2. **Real file paths only.** Every path you mention must exist in the repo.
3. **Real commands only.** Every command you write must actually work. Pull from Makefile targets, pyproject.toml scripts, CI configs, or test by reading the actual tooling config.
4. **Code examples from the repo.** Pull actual usage patterns from tests, scripts, or source — not hypothetical examples.
5. **Match the repo's terminology.** If the repo calls something a "crawler", don't call it a "scraper".
6. **Setup must be executable.** Someone should be able to copy-paste the setup section and get a working environment.

### Audience: New Team Member Onboarding

Since this is the default audience:
- Explain all acronyms and internal tool names on first use
- Include "what is X" context for frameworks (e.g., "Airflow is a workflow orchestration platform")
- Provide full prerequisite install instructions, not just a list
- Explain why things are the way they are, not just what they are

## Phase 4: Review

Before presenting the generated documentation, verify:

1. **Accuracy**: `grep` or `glob` every file path and command mentioned in the docs to confirm they exist
2. **Completeness**: Cross-reference against the Phase 2 analysis — are any major aspects missing?
3. **No hallucination**: Did you invent any features, endpoints, configs, or capabilities not in the code?
4. **Appropriate depth**: Does the detail level match new-member-onboarding audience?
5. **Gaps identified**: List things the team should document that you could not determine from the code (deployment process, access requirements, tribal knowledge)

## Output

Present each generated file in a clearly labeled code block. Include a brief summary of:
- What the repo does (2-3 sentences)
- Key findings or surprises
- Documentation gaps that need human input

Ask the user to review before writing files to disk.

## Conventions for Generated Docs

- SQL: uppercase keywords, lowercase identifiers, CTEs over subqueries
- Python: black-formatted examples
- 4-space indentation (2-space for YAML)
- ASCII diagrams over Mermaid (Mermaid renders inconsistently across platforms)
- Tables over bullet lists for structured comparisons
- No em dashes in prose
- No emojis unless the user asks for them
