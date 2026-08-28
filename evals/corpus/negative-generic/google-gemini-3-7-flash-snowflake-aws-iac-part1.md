---
class: generic
provider: google
model: gemini-3.7-flash
generated: 2026-08-28
target_words: 853
source_article: snowflake-aws-iac-part1.md
prompt: |
  Write a technical blog post titled "Snowflake & AWS Infrastructure as Code (Part 1)" about Setting up a local development environment with LocalStack and VS Code devcontainers to emulate AWS and Snowflake services for infrastructure-as-code work.. Aim for about 853 words. The audience is working data engineers.

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# Snowflake & AWS Infrastructure as Code (Part 1)

Modern data platforms rarely operate in isolation. A production-grade Snowflake deployment almost always depends on an underpinning cloud provider—most commonly AWS—to handle landing zones, event notifications, credential management, and orchestration. 

When managing this hybrid ecosystem with Infrastructure as Code (IaC) tools like Terraform or OpenTofu, data engineers face a persistent challenge: feedback loops are painfully slow. Deploying real S3 buckets, SQS queues, and IAM roles into cloud dev accounts creates permission bottlenecks, risks configuration drift, and incurs unnecessary costs.

In this first part of our series, we will build a reproducible, containerized local development environment using **VS Code Dev Containers** and **LocalStack**. This setup allows you to emulate AWS infrastructure locally, dry-run your IaC templates, and validate end-to-end integration workflows before deploying a single resource to the cloud.

---

## The Architecture of a Local Data IaC Environment

Our target architecture isolates toolchains from the host operating system while providing local emulation of cloud APIs:

```
+-------------------------------------------------------------------+
| Host Machine                                                      |
|                                                                   |
|   +-------------------------------------------------------------+ |
|   | VS Code Workspace (Dev Container)                           | |
|   | - Terraform / OpenTofu      - AWS CLI v2                    | |
|   | - Snowflake CLI             - Python 3.11 / uv              | |
|   +------------------------------+------------------------------+ |
|                                  | (Docker Network)               |
|   +------------------------------v------------------------------+ |
|   | LocalStack Container (AWS Emulation)                        | |
|   | - S3 (Landing Zones)         - SQS (Snowpipe Queues)        | |
|   | - IAM & STS (Role Assumption)- EventBridge (Orchestration)  | |
|   +-------------------------------------------------------------+ |
+-------------------------------------------------------------------+
```

While Snowflake does not provide an official offline engine for query execution, running local AWS infrastructure gives us complete control over testing:
- S3 Bucket notification configurations.
- Storage Integration IAM trust policies and external IDs.
- Automated Snowpipe trigger queues.
- Local data generation pipelines and mock event delivery.

---

## 1. Defining the Dev Container

Dev Containers guarantee that every engineer on your team runs identical versions of Terraform, the AWS CLI, and language toolchains.

Create a `.devcontainer/docker-compose.yml` file to orchestrate the workspace and LocalStack:

```yaml
version: "3.8"

services:
  workspace:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ..:/workspace:cached
    network_mode: service:localstack
    depends_on:
      - localstack

  localstack:
    image: localstack/localstack:latest
    ports:
      - "127.0.0.1:4566:4566"
    environment:
      - SERVICES=s3,sqs,sns,iam,sts
      - DOCKER_HOST=unix:///var/run/docker.sock
    volumes:
      - "${LOCALSTACK_VOLUME_DIR:-./.localstack}:/var/lib/localstack"
```

Next, define the `.devcontainer/Dockerfile` to install your IaC tools:

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:debian-12

# Install OpenTofu, AWS CLI, and Snowflake dependencies
RUN apt-get update && apt-get install -y curl unzip jq \
    && curl -fsSL https://get.opentofu.org/install-opentofu.sh | bash -s -- --install-method deb \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip ./aws

ENV AWS_ACCESS_KEY_ID=mock_access_key
ENV AWS_SECRET_ACCESS_KEY=mock_secret_key
ENV AWS_DEFAULT_REGION=us-east-1
ENV AWS_ENDPOINT_URL=http://localhost:4566
```

Finally, wire it together with `.devcontainer/devcontainer.json`:

```json
{
  "name": "Snowflake-AWS IaC Workspace",
  "dockerComposeFile": "docker-compose.yml",
  "service": "workspace",
  "workspaceFolder": "/workspace",
  "customizations": {
    "vscode": {
      "extensions": [
        "hashicorp.terraform",
        "amazonwebservices.aws-toolkit-vscode",
        "ms-azuretools.vscode-docker"
      ]
    }
  }
}
```

Reopen your workspace inside the container (`Remote-Containers: Reopen in Container`).

---

## 2. Configuring IaC for Local Emulation

To route cloud provisioning requests to LocalStack rather than public AWS endpoints, configure your provider overrides.

Create a `providers.tf` file:

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87"
    }
  }
}

variable "use_localstack" {
  type        = bool
  default     = true
  description = "Route AWS requests to LocalStack"
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack
  s3_use_path_style           = var.use_localstack

  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      s3  = "http://localhost:4566"
      sqs = "http://localhost:4566"
      iam = "http://localhost:4566"
      sts = "http://localhost:4566"
    }
  }
}
```

---

## 3. Validating the Local Workflow

Let's test the local environment by defining an ingestion bucket and notification queue that will eventually feed an automated Snowpipe.

Create `main.tf`:

```hcl
resource "aws_s3_bucket" "raw_landing" {
  bucket = "data-landing-zone-local"
}

resource "aws_sqs_queue" "snowpipe_queue" {
  name = "snowflake-snowpipe-queue"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.raw_landing.id

  queue {
    queue_arn     = aws_sqs_queue.snowpipe_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "raw/"
  }
}
```

Inside your Dev Container terminal, run:

```bash
# Initialize OpenTofu/Terraform
tofu init

# Apply against LocalStack
tofu apply -auto-approve

# Test data generation and event routing
aws --endpoint-url=http://localhost:4566 s3 cp - s3://data-landing-zone-local/raw/customers.json <<< '{"id": 1, "name": "ACME Corp"}'

# Verify SQS received the event payload
aws --endpoint-url=http://localhost:4566 sqs receive-message --queue-url http://localhost:4566/000000000000/snowflake-snowpipe-queue
```

The receive-message call outputs the notification payload instantly. You have validated your infrastructure dependencies without provisioning a single AWS cloud resource or incurring billing charges.

---

## What’s Next?

With deterministic toolchains and local AWS emulation running seamlessly inside VS Code, we have eliminated the slowest parts of our IaC feedback loop. 

In **Part 2**, we will build on this foundation to write production Terraform modules connecting LocalStack S3 buckets to real Snowflake instances, configure cross-account AWS IAM trust relationships, and automate end-to-end Snowpipe auto-ingest pipelines with zero-trust storage integrations.
