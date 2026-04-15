---
name: bootstrap-project
description: "Scaffold a new project's devcontainer setup so `drone up` works immediately. Use this skill whenever the user wants to create a new project, set up a devcontainer, bootstrap a development environment, initialize a project for containerized development, or mentions needing docker-compose.yml / Dockerfile / devcontainer.json for a new project. Also trigger when the user says 'new project', 'start a project', 'set up dev environment', or 'make this work with drone up'."
---

# Bootstrap Project — Devcontainer Scaffolding

This skill generates the `.devcontainer/` directory for a new project so that `drone up` works out of the box. Every project uses a shared base Docker image that provides the standard dev toolchain (zsh, neovim, tmux, git, ssh, node.js, claude-code CLI) and mounts the user's dotfiles into the container.

## Before You Begin

Read the reference templates to understand the current base image and mount conventions:
- `references/Dockerfile.template` — project Dockerfile that extends the base
- `references/docker-compose.template.yml` — standard volume mounts and service config
- `references/devcontainer.template.json` — VS Code / devcontainer CLI config

These templates reflect Noah's actual working setup across multiple projects. Follow them closely.

## What to Ask the User

Before generating files, gather these details (use AskUserQuestion):

1. **Project name** — used for the devcontainer name and directory
2. **Project language/framework** — determines which extra system deps or pip/npm packages to install in the Dockerfile
3. **Workspace folder** — usually `/workspace` but could be `/development` for legacy projects
4. **Extra services** — does the project need a database (postgres, redis, etc.)?  If so, which ones?
5. **Project-specific env vars or secrets files** — any `.env` files to reference?

## File Generation

Generate three files in `<project-root>/.devcontainer/`:

### 1. Dockerfile

Extends the shared base image. Only add project-specific deps.

```dockerfile
# Extends the shared base devcontainer image.
# Base provides: zsh, neovim, tmux, git, ssh, node.js, claude-code CLI.
#
# To rebuild the base locally:
#   docker build -f ~/.config/dotfiles/devcontainer/Dockerfile.base -t devcontainer-base:local .
FROM devcontainer-base:local

# Project-specific deps
# (adjust based on the project's language/framework)
RUN apt-get update && apt-get install -y --no-install-recommends \
    <project-specific-packages> \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
```

If the project has no extra system deps beyond what the base provides, the Dockerfile can just be:
```dockerfile
FROM devcontainer-base:local
WORKDIR /workspace
```

### 2. docker-compose.yml

Always include the standard dotfile mounts block. Add project-specific services as needed.

Key rules:
- The main service MUST be named `devcontainer` (drone's container lookup greps for this)
- Project files mount at the workspace folder path
- Always include `command: sleep infinity`
- Always include `SSH_AUTH_SOCK` environment variable
- Always include the full dotfile mounts block from the template

If extra services are needed (databases, etc.), add them with appropriate health checks and use `depends_on` with `condition: service_healthy` on the devcontainer service.

### 3. devcontainer.json

Standard config pointing at docker-compose.yml. Key rules:
- `features: {}` — the base image handles everything, no devcontainer features needed
- `postCreateCommand` should fix SSH permissions and install project deps
- Always include `shutdownAction: "stopCompose"`
- Always include `updateRemoteUserUID: true`

## After Generation

Remind the user:
1. Build the base image first (if not already built):
   ```bash
   docker build -f ~/.config/dotfiles/devcontainer/Dockerfile.base -t devcontainer-base:local .
   ```
2. Then `drone up <project-name>` should work immediately
3. If the project needs secrets/env files, create them before first `drone up`

## Important Conventions

- The user is `dev` with UID/GID 1000 (inherited from the base image)
- All dotfile mounts go to `/home/dev/` inside the container
- The base image is `devcontainer-base:local` (built locally from dotfiles)
- `drone up` / `drone down` / `drone status` are the CLI commands for managing devcontainers (part of borg-collective)
- Every project MUST have `.devcontainer/docker-compose.yml` — `drone up` enforces this
- The template files use `__USERNAME__` as a placeholder for the host user's username. When
  generating devcontainer files, replace `__USERNAME__` with the actual username (the output of
  `whoami` or `$USER` on the host machine)
