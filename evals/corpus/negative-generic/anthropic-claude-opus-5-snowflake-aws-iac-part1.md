---
class: generic
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 853
source_article: snowflake-aws-iac-part1.md
prompt: |
  Write a technical blog post titled "Snowflake & AWS Infrastructure as Code (Part 1)" about Setting up a local development environment with LocalStack and VS Code devcontainers to emulate AWS and Snowflake services for infrastructure-as-code work.. Aim for about 853 words. The audience is working data engineers.

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# Snowflake & AWS Infrastructure as Code (Part 1)

Most data platform teams end up owning two clouds whether they planned to or not: AWS for storage, queues, and compute, and Snowflake for the warehouse. Once you start managing both with Terraform, the feedback loop gets painful fast. `terraform apply` against a shared sandbox account takes minutes, collides with your teammates, and occasionally leaves orphaned resources that someone has to clean up on a Friday afternoon.

This post is about shortening that loop. We'll build a reproducible local development environment using VS Code devcontainers, with LocalStack standing in for AWS and a pragmatic approach to Snowflake, which — spoiler — does not have an official emulator. Part 2 will use this environment to build out actual S3 → Snowpipe → Snowflake ingestion infrastructure.

## Why a devcontainer

The usual failure mode of "just install Terraform and the AWS CLI" is version drift. One engineer has Terraform 1.5, CI has 1.9, and the state file quietly becomes incompatible. A devcontainer pins the toolchain to the repo, so the environment is a reviewable artifact rather than tribal knowledge in a README.

Our target layout:

```
.
├── .devcontainer/
│   ├── devcontainer.json
│   ├── docker-compose.yml
│   └── Dockerfile
├── terraform/
│   ├── providers.tf
│   ├── main.tf
│   └── envs/local.tfvars
└── Makefile
```

## The container image

Start from Microsoft's Python base image and layer in the tools we need. Terraform, the AWS CLI, the Snowflake CLI, and the LocalStack wrapper scripts.

```dockerfile
FROM mcr.microsoft.com/devcontainers/python:3.12

ARG TERRAFORM_VERSION=1.9.8

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg \
      | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] \
      https://apt.releases.hashicorp.com bookworm main" \
      > /etc/apt/sources.list.d/hashicorp.list \
 && apt-get update \
 && apt-get install -y terraform=${TERRAFORM_VERSION}-* \
 && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
      awscli-local \
      terraform-local \
      snowflake-cli-labs \
      fakesnow \
      pytest
```

`awscli-local` gives you `awslocal`, and `terraform-local` gives you `tflocal`. Both are thin wrappers that inject LocalStack endpoint configuration so you don't have to hand-maintain twenty `endpoints {}` blocks.

## Composing the services

The devcontainer runs alongside LocalStack rather than inside it. Docker Compose keeps them on a shared network so `localstack:4566` resolves from the workspace container.

```yaml
services:
  workspace:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ../:/workspaces/data-platform:cached
      - /var/run/docker.sock:/var/run/docker.sock
    command: sleep infinity
    environment:
      AWS_ACCESS_KEY_ID: test
      AWS_SECRET_ACCESS_KEY: test
      AWS_DEFAULT_REGION: us-east-1
      AWS_ENDPOINT_URL: http://localstack:4566
    depends_on:
      - localstack

  localstack:
    image: localstack/localstack:3.8
    environment:
      SERVICES: s3,sqs,sns,iam,lambda,events,secretsmanager,logs,sts
      DEBUG: 1
      PERSISTENCE: 1
    volumes:
      - localstack-data:/var/lib/localstack
      - /var/run/docker.sock:/var/run/docker.sock

volumes:
  localstack-data:
```

Two details worth calling out. Mounting the Docker socket into the LocalStack container is required if you want Lambda to actually execute — LocalStack spawns sibling containers for function invocations. And `PERSISTENCE: 1` keeps state across restarts, which matters when your Terraform state and LocalStack's view of the world need to stay in sync.

Then the devcontainer definition:

```json
{
  "name": "data-platform",
  "dockerComposeFile": "docker-compose.yml",
  "service": "workspace",
  "workspaceFolder": "/workspaces/data-platform",
  "customizations": {
    "vscode": {
      "extensions": [
        "hashicorp.terraform",
        "snowflake.snowflake-vsc",
        "ms-python.python",
        "charliermarsh.ruff"
      ],
      "settings": {
        "terraform.languageServer.enable": true
      }
    }
  },
  "postCreateCommand": "bash .devcontainer/post-create.sh"
}
```

## Pointing Terraform at LocalStack

Using `tflocal` means your `providers.tf` stays clean and production-shaped:

```hcl
terraform {
  required_version = ">= 1.9"
  required_providers {
    aws       = { source = "hashicorp/aws",              version = "~> 5.70" }
    snowflake = { source = "Snowflake-Labs/snowflake",    version = "~> 0.97" }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "snowflake" {
  organization_name = var.snowflake_org
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = file(var.snowflake_key_path)
  role              = "TERRAFORM_ROLE"
}
```

Run `tflocal init && tflocal plan` and the wrapper generates an override file redirecting every AWS service to `http://localhost:4566`, sets `s3_use_path_style`, and stubs credentials. Your CI runs plain `terraform` against real AWS with the same code.

## The Snowflake problem

Here's the honest part: there is no LocalStack for Snowflake. You cannot emulate `CREATE WAREHOUSE`, resource monitors, or account-level grants locally. Anyone selling you a fully offline Snowflake IaC loop is selling you fiction.

What you can do is split your Snowflake work into two tiers.

**SQL and transformation logic** runs against [`fakesnow`](https://github.com/tekumara/fakesnow), which patches the Snowflake Python connector to execute against DuckDB with Snowflake dialect translation. It handles `VARIANT`, semi-structured access with `:`, `OBJECT_CONSTRUCT`, information schema queries, and multiple databases. Good enough to unit-test your ingestion and dbt-adjacent Python without a network round trip:

```python
import fakesnow, snowflake.connector

with fakesnow.patch():
    conn = snowflake.connector.connect(database="RAW", schema="EVENTS")
    conn.cursor().execute("CREATE TABLE orders (payload VARIANT)")
    conn.cursor().execute(
        "INSERT INTO orders SELECT PARSE_JSON('{\"id\": 42}')"
    )
    print(conn.cursor().execute(
        "SELECT payload:id::int FROM orders").fetchall())
```

**Terraform resources** need a real Snowflake account, so give every engineer their own namespace inside one shared dev account. Prefix every object with an environment variable and enforce it in the module interface:

```hcl
locals {
  prefix = upper("${var.environment}_${var.developer}")
}

resource "snowflake_database" "raw" {
  name = "${local.prefix}_RAW"
}
```

Combined with a `TERRAFORM_ROLE` scoped by a future-grants policy, engineers can iterate without stepping on each other, and teardown is a single `tflocal destroy`.

## Sanity check

Add a Makefile target so onboarding is one command:

```makefile
up:
	awslocal s3 mb s3://landing-zone
	cd terraform && tflocal init -upgrade
	cd terraform && tflocal plan -var-file=envs/local.tfvars

test:
	pytest tests/ -v
```

Reopen the folder in the container, run `make up`, and you should see a plan referencing LocalStack buckets and your prefixed Snowflake objects.

In Part 2 we'll wire these together: S3 event notifications, an SQS queue, an external stage, and a Snowpipe that survives both LocalStack and production.
