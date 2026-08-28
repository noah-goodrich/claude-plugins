---
class: generic
provider: anthropic
model: claude-opus-5
generated: 2026-08-28
target_words: 1163
source_article: snowflake-aws-iac-part2.md
prompt: |
  Write a technical blog post titled "Snowflake & AWS Infrastructure as Code (Part 2)" about Moving off AWS CDK to a configuration-driven approach for provisioning Snowflake databases, roles, pipelines, and S3 storage integrations alongside AWS resources.. Aim for about 1163 words. The audience is working data engineers.

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# Snowflake & AWS Infrastructure as Code (Part 2)

In [Part 1](#) we walked through provisioning Snowflake objects from AWS CDK using Lambda-backed custom resources. It worked. It shipped. And about nine months later we tore most of it out.

This post is about why, and what replaced it: a configuration-driven provisioning layer where a data engineer describes a domain in YAML and gets a database, a role hierarchy, an S3 bucket, a storage integration, an external stage, and a Snowpipe — without writing a line of CDK, Terraform, or DDL.

## Why CDK stopped working for us

CDK is excellent at what it's designed for: synthesising CloudFormation for AWS resources. Snowflake is not an AWS resource. Every Snowflake object we managed went through the same pipeline:

```
CDK construct → CloudFormation custom resource → Lambda → Snowflake connector → SQL
```

Four layers of indirection between "I want a database" and `CREATE DATABASE`. The problems compounded:

**Failure modes were opaque.** A failed `GRANT` surfaced as `CREATE_FAILED` on a `Custom::SnowflakeGrant` resource, with the actual error truncated in CloudWatch. Rollback semantics were ours to implement, and we implemented them badly — a failed update would frequently leave the Lambda's `Delete` handler dropping an object that CloudFormation still believed existed.

**No plan step.** CloudFormation change sets tell you a custom resource *will* be updated. They cannot tell you that the update means `DROP` and recreate a database. We learned this the way you'd expect.

**Drift was invisible.** Someone with `ACCOUNTADMIN` runs a `GRANT` in a worksheet. CDK has no idea. Six weeks later a deploy silently removes it, or doesn't, depending on how our Lambda diffed state.

**The construct API became a DSL nobody wanted to learn.** Onboarding a new data domain meant writing TypeScript. Our analytics engineers write SQL and Python. The bus factor on the CDK codebase was two.

The deeper issue: 90% of what we were doing was *repetition*. Every domain got the same shape — a database, three schemas, a functional role, three access roles, a warehouse, a landing bucket, an integration, a pipe. We had built a general-purpose imperative tool to express a highly constrained, declarative problem.

## The shape of the replacement

We inverted it. Instead of code that produces infrastructure, we have **configuration that describes intent**, and a thin generator that renders Terraform.

A domain looks like this:

```yaml
# domains/retail_sales.yaml
domain: retail_sales
owner: retail-data-platform@example.com
cost_centre: CC-4471

database:
  name: RETAIL_SALES
  schemas:
    - name: RAW
      managed_access: true
      retention_days: 7
    - name: STAGING
      managed_access: true
    - name: MARTS
      managed_access: true

warehouse:
  size: SMALL
  auto_suspend: 60
  scaling_policy: STANDARD

access:
  read:
    - AAD_GROUP_RETAIL_ANALYSTS
  write:
    - AAD_GROUP_RETAIL_ENGINEERS

landing:
  bucket: acme-retail-sales-landing
  lifecycle_expiry_days: 30
  ingest:
    - name: POS_TRANSACTIONS
      prefix: pos/transactions/
      target_table: RAW.POS_TRANSACTIONS
      file_format: JSON
      auto_ingest: true
```

Forty lines. That renders to roughly 700 lines of Terraform across the `snowflake` and `aws` providers, plus the SQS notification wiring and IAM trust policy that people always get wrong.

## Why Terraform and not "just SQL scripts"

We seriously considered a schema-migration approach (Flyway/schemachange style) for Snowflake and keeping CDK for AWS. We rejected it because storage integrations are the one place where the two clouds are genuinely coupled, and a migration tool has no way to reason about an IAM role that doesn't exist yet.

Terraform gives us three things that mattered more than provider maturity:

1. A real `plan`. Reviewers see `- snowflake_database.this` in a PR and stop the merge.
2. State. Drift detection is a scheduled `terraform plan -detailed-exitcode` that opens a ticket on exit code 2.
3. One graph across both providers, so the storage integration dependency chain is expressed as data flow rather than deployment ordering documentation.

## The storage integration chicken-and-egg

This is the part that justifies the whole exercise. To create a Snowflake external stage on S3 you need a storage integration. To create the storage integration you supply an IAM role ARN. To make that IAM role assumable you need `STORAGE_AWS_IAM_USER_ARN` and `STORAGE_AWS_EXTERNAL_ID`, which Snowflake only generates *after* the integration exists.

Under CDK we solved this with a two-stack deploy and a runbook step. In Terraform it's just a graph:

```hcl
resource "aws_iam_role" "snowflake_ingest" {
  name = "snowflake-${var.domain}-ingest"
  # Bootstrap with a self-referential trust policy; refined below.
  assume_role_policy = data.aws_iam_policy_document.bootstrap_trust.json
}

resource "snowflake_storage_integration" "this" {
  name                      = upper("${var.domain}_S3_INT")
  type                      = "EXTERNAL_STAGE"
  storage_provider          = "S3"
  storage_aws_role_arn      = aws_iam_role.snowflake_ingest.arn
  storage_allowed_locations = ["s3://${aws_s3_bucket.landing.id}/"]
  enabled                   = true
}

data "aws_iam_policy_document" "snowflake_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [snowflake_storage_integration.this.storage_aws_iam_user_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [snowflake_storage_integration.this.storage_aws_external_id]
    }
  }
}

resource "aws_iam_role_policy" "trust_refinement" {
  # applied via aws_iam_role.assume_role_policy update in a second pass
}
```

The honest caveat: this still needs two applies on first creation, because `aws_iam_role.assume_role_policy` can't depend on a resource that depends on the role. We handle it with a `null_resource` provisioner that calls `aws iam update-assume-role-policy` after the integration is created, keyed on the external ID. It's not beautiful. It is documented, tested, and it happens once per domain instead of once per engineer's memory of the runbook.

## Generated RBAC, not hand-written grants

The config's `access` block expands into our standard role model:

```
RETAIL_SALES_DB_RO ──┐
RETAIL_SALES_DB_RW ──┼──> granted to functional roles
RETAIL_SALES_DB_ADM ─┘
```

Access roles hold privileges on objects. Functional roles (mapped to identity-provider groups via SCIM) hold access roles. Nobody grants a privilege directly to a user, and nobody writes `GRANT SELECT ON FUTURE TABLES` by hand — the generator emits it for every schema, every time, including the `ON FUTURE` and `ON ALL` pair that people forget:

```hcl
resource "snowflake_grant_privileges_to_account_role" "ro_future_tables" {
  for_each          = toset(var.schemas)
  account_role_name = snowflake_account_role.ro.name
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${var.database}\".\"${each.value}\""
    }
  }
}
```

This alone eliminated the most common support ticket we had: "I can see the table but not query it."

## Pipes and notifications

Each `ingest` entry produces a stage, a pipe, an SQS notification configuration on the bucket, and the S3 event filter. The pipe's `notification_channel` attribute is fed straight into the bucket notification, so the SQS ARN is never copied by hand:

```hcl
resource "snowflake_pipe" "this" {
  name        = each.value.name
  database    = snowflake_database.this.name
  schema      = "RAW"
  auto_ingest = true
  copy_statement = <<-SQL
    COPY INTO ${each.value.target_table}
    FROM @${snowflake_stage.landing.name}/${each.value.prefix}
    FILE_FORMAT = (FORMAT_NAME = 'FF_${each.value.file_format}')
  SQL
}

resource "aws_s3_bucket_notification" "landing" {
  bucket = aws_s3_bucket.landing.id
  dynamic "queue" {
    for_each = snowflake_pipe.this
    content {
      queue_arn     = queue.value.notification_channel
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = var.ingest[queue.key].prefix
    }
  }
}
```

## What we gained, and what still hurts

Onboarding a domain went from a two-day TypeScript exercise to a PR against a YAML file, reviewed by a human and applied by CI. Drift detection is real. Plan output is readable by people who don't write infrastructure code.

What still hurts: the Snowflake Terraform provider has churned significantly, and provider upgrades are not free — the v0.9x → v1.x grant resource rename was a multi-week state surgery. Deleting a domain is deliberately gated behind a manual approval, because `terraform destroy` on a database is exactly as final as it sounds. And YAML is not a type system; we run JSON Schema validation in pre-commit, and it catches maybe 80% of what a compiler would have.

In Part 3 we'll cover the CI pipeline itself: ephemeral Snowflake accounts for PR validation, policy-as-code checks on generated plans, and how we handle secrets rotation for the Terraform service user.
