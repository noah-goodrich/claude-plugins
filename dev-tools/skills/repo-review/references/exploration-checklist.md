# Repo Exploration Checklist

Systematic protocol for first-time repository review. Each section maps to a subagent focus area in Phase 1.

## Root Files (read first, always)

- README.md (or README.rst, README.txt)
- LICENSE
- CONTRIBUTING.md
- CHANGELOG.md / HISTORY.md
- CODEOWNERS
- Makefile / Justfile / Taskfile.yml
- .editorconfig
- .gitignore / .airflowignore

## Project Definition

- pyproject.toml -> name, version, dependencies, scripts, build system
- setup.py / setup.cfg -> legacy Python packaging
- package.json -> Node.js project
- dbt_project.yml -> dbt project
- Cargo.toml -> Rust project
- go.mod -> Go project
- .project.yml -> custom project metadata (e.g., Astronomer Airflow)

## Environment & Runtime

- .python-version / .tool-versions / .nvmrc
- .env.example / .env.template
- docker-compose.yml / Dockerfile
- .devcontainer/ directory
- requirements.txt / requirements-dev.txt
- poetry.lock (confirms Poetry usage)
- Pipfile / Pipfile.lock

## CI/CD & Automation

- .github/workflows/*.yml
- .gitlab-ci.yml
- Jenkinsfile
- .circleci/config.yml
- .pre-commit-config.yaml
- tox.ini / noxfile.py

## Code Structure Signals

- src/ layout vs flat package
- dags/ directory -> Airflow
- models/ directory -> dbt or Django
- tests/ or test/ directory
- scripts/ directory
- migrations/ directory
- alembic/ directory

## Data Engineering Specific

- dags/ -> Airflow DAG definitions
- models/ + dbt_project.yml -> dbt models
- profiles.yml -> dbt connection profiles
- sources.yml / schema.yml -> dbt sources and tests
- soda/ -> Soda data quality checks
- great_expectations/ -> GE checkpoints
- .airflowignore -> Airflow file exclusions
- connections.yaml -> Airflow connections

## Quality & Testing

- conftest.py -> pytest fixtures
- pytest.ini / pyproject.toml [tool.pytest]
- .flake8 / pyproject.toml [tool.ruff]
- pyproject.toml [tool.black] / [tool.ruff.format]
- mypy.ini / pyproject.toml [tool.mypy]
- .eslintrc / .prettierrc
- coverage config (.coveragerc, pyproject.toml [tool.coverage])
