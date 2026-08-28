---
class: generic
provider: google
model: gemini-3.7-flash
generated: 2026-08-28
target_words: 1163
source_article: snowflake-aws-iac-part2.md
prompt: |
  Write a technical blog post titled "Snowflake & AWS Infrastructure as Code (Part 2)" about Moving off AWS CDK to a configuration-driven approach for provisioning Snowflake databases, roles, pipelines, and S3 storage integrations alongside AWS resources.. Aim for about 1163 words. The audience is working data engineers.

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# Snowflake & AWS Infrastructure as Code (Part 2)

In [Part 1], we explored how to provision foundational AWS resources and bootstrap Snowflake objects using the AWS Cloud Development Kit (CDK). We used TypeScript constructs to spin up S3 data lake buckets, KMS keys, and IAM roles, while bridging the Snowflake gap via Custom Resources powered by AWS Lambda.

It worked. But as our data platform matured to dozens of databases, hundreds of schemas, complex Role-Based Access Control (RBAC) hierarchies, and auto-ingesting Snowpipes, the CDK-first approach began to show structural cracks. 

This post details why we moved away from managing Snowflake via AWS CDK, the operational challenges we encountered, and how we transitioned to a configuration-driven infrastructure model that orchestrates AWS and Snowflake declaratively using Terraform and YAML-driven specifications.

---

## Why AWS CDK Broke Down for Snowflake

AWS CDK is exceptional for AWS-native topologies. Synthesizing TypeScript or Python into deterministic CloudFormation templates gives software engineers the full power of object-oriented programming for cloud infrastructure. 

However, applying this model to a high-churn data warehouse introduced three core failure modes:

### 1. The Custom Resource Anti-Pattern
CloudFormation does not have native support for Snowflake primitives. To manage a Snowflake database, schema, or grant in CDK, you must rely on Custom Resources backed by AWS Lambda functions running the Snowflake Node.js or Python SDK. 

Every schema creation, user grant, and warehouse resize turned into an asynchronous Lambda execution. We quickly encountered:
* **Lambda execution timeouts** during bulk provisioning.
* **Opaque rollback states**: If a Snowflake grant failed mid-deployment, CloudFormation would attempt a rollback, often getting stuck in `UPDATE_ROLLBACK_FAILED` due to non-idempotent DDL executions.
* **No true state mapping**: CloudFormation tracks the *status of the Lambda invocation*, not the actual state of the Snowflake object. If someone manually altered a role in Snowflake, CDK had zero drift detection.

### 2. The Multi-Disciplinary Impedance Mismatch
Data engineers and analytics engineers work primarily in SQL, Python, and declarative configuration formats (like dbt’s `yaml` files). Forcing data engineers to write imperative TypeScript or deeply nested CDK constructs just to add an ingestion stage or grant `SELECT` access to a new role created an organizational bottleneck. Infrastructure changes required software engineering reviews rather than data platform reviews.

### 3. Complex State Cycles in Cross-Cloud Integrations
Configuring an S3-to-Snowflake integration requires a mutual trust handshake:
1. Snowflake needs the AWS IAM Role ARN to create a `STORAGE INTEGRATION`.
2. AWS IAM needs the Snowflake `STORAGE_AWS_IAM_USER_ARN` and `STORAGE_AWS_EXTERNAL_ID` (generated *by* the Storage Integration) in its trust policy.

In CDK, orchestrating this two-phase handshake required multi-pass deployments, temporary open trust policies, or brittle SSM parameter exchanges across separate stacks.

---

## The Pivot: Configuration-Driven Infrastructure

To solve these bottlenecks, we decoupled cloud-native primitives from data warehouse platform configuration. 

We adopted a hybrid model:
* **Terraform** serves as the underlying stateful execution engine, leveraging the official `aws` and Snowflake-Labs `snowflake` providers natively.
* **Declarative YAML manifests** act as the contract for all platform definitions: databases, schemas, functional/access roles, stages, and pipelines.

```
       ┌────────────────────────┐
       │ platform_manifest.yaml │
       └───────────┬────────────┘
                   │
                   ▼
       ┌────────────────────────┐
       │   Terraform Engine     │
       │  (yamldecode + Dynamic)│
       └─────┬────────────┬─────┘
             │            │
   ┌─────────▼──┐      ┌──▼──────────┐
   │ AWS Provider│      │  Snowflake  │
   │ (S3, IAM)  │      │  Provider   │
   └────────────┘      └─────────────┘
```

This model provides native drift detection, fast plan/apply cycles, and allows data engineers to self-serve infrastructure using human-readable configuration files.

---

## Solving the Circular S3 Storage Integration

The cross-cloud IAM handshake is the quintessential AWS + Snowflake IaC challenge. Here is how we automated the trust handshake cleanly using Terraform without manual intervention or security holes.

### Step 1: Bootstrap IAM Role with Placeholder Trust
We define an IAM role whose trust policy can temporarily accommodate the circular dependency, or we use a deterministic AWS module pattern.

```hcl
# aws_iam.tf
resource "aws_iam_role" "snowflake_storage_role" {
  name = "snowflake-s3-ingest-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          # Seeded with current AWS Account ID; will be updated post-integration
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_reader_policy" {
  name = "snowflake-s3-reader-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.raw_data_lake.arn,
          "${aws_s3_bucket.raw_data_lake.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_reader" {
  role       = aws_iam_role.snowflake_storage_role.name
  policy_arn = aws_iam_policy.s3_reader_policy.arn
}
```

### Step 2: Provision the Snowflake Storage Integration
The Snowflake provider creates the integration referencing the initial IAM Role ARN.

```hcl
# snowflake_integration.tf
resource "snowflake_storage_integration" "s3_integration" {
  name                      = "S3_RAW_DATA_INTEGRATION"
  type                      = "EXTERNAL_STAGE"
  storage_provider          = "S3"
  storage_aws_role_arn      = aws_iam_role.snowflake_storage_role.arn
  enabled                   = true
  storage_allowed_locations = ["s3://${aws_s3_bucket.raw_data_lake.id}/"]
}
```

### Step 3: Complete the Trust Handshake Declaratively
We update the AWS IAM Role's trust policy using the properties exported directly by `snowflake_storage_integration`.

```hcl
# aws_iam_trust_update.tf
resource "aws_iam_role_assume_role_policy" "snowflake_trust_update" {
  role_name = aws_iam_role.snowflake_storage_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = snowflake_storage_integration.s3_integration.storage_aws_iam_user_arn
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = snowflake_storage_integration.s3_integration.storage_aws_external_id
          }
        }
      }
    ]
  })
}
```

Because Terraform builds an execution Directed Acyclic Graph (DAG), it handles the resource dependencies natively, applying changes in the correct sequence within a single execution plan.

---

## Configuration-Driven Pipelines and RBAC

With core integration solved, we moved data warehousing objects into declarative YAML specifications. This completely removes raw HCL and TypeScript from day-to-day data engineering workflows.

### The Contract: `platform_spec.yaml`

```yaml
databases:
  - name: PROD_RAW
    comment: "Landing zone for raw S3 events"
    data_retention_time_in_days: 7
    schemas:
      - name: TELEMETRY
        pipes:
          - name: PIPE_TELEMETRY_STREAM
            auto_ingest: true
            stage_path: "telemetry/"
            target_table: "RAW_TELEMETRY_EVENTS"
            file_format: "TYPE = JSON STRIP_OUTER_ARRAY = TRUE"

rbac_matrix:
  access_roles:
    - name: AR_PROD_RAW_TELEMETRY_READ
      database: PROD_RAW
      schema: TELEMETRY
      privileges: ["USAGE", "SELECT"]
  functional_roles:
    - name: FR_DATA_ANALYST
      assigned_access_roles:
        - AR_PROD_RAW_TELEMETRY_READ
```

### The Engine: Dynamic Expansion in Terraform

We parse the YAML contract and construct our objects using Terraform’s `yamldecode()` and `for_each` meta-arguments.

```hcl
# locals.tf
locals {
  platform = yamldecode(file("${path.module}/platform_spec.yaml"))

  # Flatten schemas for iteration
  schemas = flatten([
    for db in local.platform.databases : [
      for schema in db.schemas : {
        key      = "${db.name}.${schema.name}"
        db_name  = db.name
        name     = schema.name
        pipes    = lookup(schema, "pipes", [])
      }
    ]
  ])

  # Flatten pipes for iteration
  pipes = flatten([
    for schema in local.schemas : [
      for pipe in schema.pipes : {
        key          = "${schema.db_name}.${schema.name}.${pipe.name}"
        db_name      = schema.db_name
        schema_name  = schema.name
        name         = pipe.name
        auto_ingest  = pipe.auto_ingest
        stage_path   = pipe.stage_path
        target_table = pipe.target_table
        file_format  = pipe.file_format
      }
    ]
  ])
}

# snowflake_resources.tf
resource "snowflake_database" "databases" {
  for_each                    = { for db in local.platform.databases : db.name => db }
  name                        = each.value.name
  comment                     = each.value.comment
  data_retention_time_in_days = each.value.data_retention_time_in_days
}

resource "snowflake_schema" "schemas" {
  for_each   = { for s in local.schemas : s.key => s }
  database   = snowflake_database.databases[each.value.db_name].name
  name       = each.value.name
  depends_on = [snowflake_database.databases]
}

resource "snowflake_stage" "stages" {
  for_each            = { for p in local.pipes : p.key => p }
  name                = "STAGE_${each.value.name}"
  database            = each.value.db_name
  schema              = each.value.schema_name
  url                 = "s3://${aws_s3_bucket.raw_data_lake.id}/${each.value.stage_path}"
  storage_integration = snowflake_storage_integration.s3_integration.name
  depends_on          = [snowflake_schema.schemas]
}

resource "snowflake_pipe" "pipes" {
  for_each       = { for p in local.pipes : p.key => p }
  name           = each.value.name
  database       = each.value.db_name
  schema         = each.value.schema_name
  auto_ingest    = each.value.auto_ingest
  copy_statement = "COPY INTO ${each.value.db_name}.${each.value.schema_name}.${each.value.target_table} FROM @${snowflake_stage.stages[each.key].name} FILE_FORMAT = (${each.value.file_format})"
  depends_on     = [snowflake_stage.stages]
}
```

---

## Operational Wins

Migrating from CDK custom Lambda handlers to a configuration-driven Terraform foundation unlocked several tangible operational advantages:

| Capability | AWS CDK + Custom Lambda | Terraform + YAML Specs |
| :--- | :--- | :--- |
| **Drift Detection** | None (only tracks Lambda state) | Native (`terraform plan` identifies out-of-band changes) |
| **Deployment Speed** | 8–15 mins (Lambda cold starts & CFN overhead) | 30–60 seconds (Direct Snowflake SQL API calls) |
| **Self-Service RBAC** | Requires TypeScript engineering PRs | Simple YAML updates reviewed by platform team |
| **Blast Radius** | Monolithic CloudFormation stacks | Decoupled state layers (Network/IAM vs. Warehouse Ops) |

## Conclusion

AWS CDK remains an exceptional tool for AWS-native systems, but data warehouses require a paradigm tailored to continuous DDL churn, external stages, and complex RBAC. 

By shifting to a declarative, configuration-driven model, we eliminated the fragility of CloudFormation Custom Resources, bridged the cross-cloud IAM gap cleanly, and provided our data engineering team with a simple, self-documenting interface to provision infrastructure at scale.
