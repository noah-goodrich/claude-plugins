---
title: "Snowflake & AWS Infrastructure as Code (Part 1)"
url: https://medium.com/@noah.goodrich/snowflake-aws-infrastructure-as-code-c86ddd41b25d
date: 2024-12-28
publication: personal
reading_time_min: 4
claps_response_count: 0
tags: [snowflake, snowflake-data-superhero, data-superhero]
subtitle: "Part 1: Set up your local development environment"
---

# Snowflake & AWS Infrastructure as Code

## Part 1: Set up your local development environment

Managing infrastructure for cloud-based applications has long been a challenge. For one thing, most of the guides out there just rely on click-ops instructions through the UI rather than providing practical examples of how to build out infrastructure through tools like Cloudformation or Terraform. And even within Terraform which does kind of support Snowflake, you quickly run into things you just can't do natively with it. Also, keeping your Terraform code fully DRY is a huge endeavor itself. Alternatively, you can use open-source or commercial tools to run and track migrations in Snowflake. But then what do you if you need to mix order of operations where Snowflake and AWS dependencies mix? And this doesn't even begin to consider the complexities of testing code other than just trying to deploy your Cloudformation stack or run the Snowflake migration and then stepping through the errors until you finally get something that works.

With the advent of of CDK and the Snowflake APIs we finally have a potential solution that can allow us to mix our AWS and Snowflake infrastructure code in such a way that we can neatly resolve dependencies and with the latest advancements from Localstack including a Snowflake local container environment, we can emulate these services locally, enabling faster, more efficient development while minimizing expenses.

In this article, I'll guide you through setting up a local development environment that includes **LocalStack** for AWS and Snowflake service emulation. We'll configure a containerized workspace using **VS Code devcontainers**, ensuring a reproducible and isolated setup.

## Why Use LocalStack?

LocalStack is a powerful tool that emulates AWS services locally, including an experimental Snowflake integration. This setup allows you to:

- Develop and test cloud applications locally without incurring cloud service costs.
- Quickly prototype and debug without waiting for remote infrastructure.
- Maintain a consistent environment across team members.

## Prerequisites

Before starting, ensure you have the following installed:

- **VSCode** or **Cursor IDE**
- **Docker CLI** or **Docker Desktop**

## Setup Instructions

## Step 1: Clone the Repository

Start by cloning the example repository containing the necessary configuration files:

```
git clone https://github.com/noah-goodrich/snowflake-examples.git
```

## Step 2: Start Docker

Ensure Docker is running on your system. You can verify this with:

```
docker --version
```

If Docker is not running, start Docker Desktop or your Docker CLI.

## Local Configuration Changes

## Step 3: Configure AWS CLI Credentials

For LocalStack to emulate AWS services properly, you need to set up local AWS CLI credentials:

1. **Create or modify the AWS configuration files**:

- In `~/.aws/config`:

```
[profile localstack]
region = us-east-1
output = json
endpoint_url = http://localhost.localstack.cloud:4566
```

- In `~/.aws/credentials`:

```
[localstack]
aws_access_key_id = test
aws_secret_access_key = test
```

These credentials are local placeholders and won't interact with your real AWS account.

## Step 4: (Optional) Configure Local DNS

If you encounter DNS resolution issues, you can configure your system to resolve LocalStack's domain by modifying your `/etc/hosts` file:

- Open the file with elevated permissions:

```
sudo vim /etc/hosts
```

- Add the following line:

```
127.0.0.1 localhost.localstack.cloud
```

- Save and close the file.

This step helps ensure LocalStack services are accessible by their expected domain.

## Step 5: Open devcontainer in VSCode / Cursor

### In VSCode:

1. Install the Dev Containers Extension
2. Open the snowflake-examples/vscode-devcontainer folder
3. Open the command palette with `Cmd + Shift + P`
4. Execute `Reopen in Container`

## Step 6: Verify Setup

Once you are connected to your devcontainer in VSCode, open the integrated terminal and verify your setup with the following commands:

**Create a test S3 bucket**:

```
aws s3 mb s3://test-bucket
```

**List S3 buckets**:

```
aws s3 ls
```

**Test Snowflake connectivity**:

```
curl -d '{}' http://snowflake.localhost.localstack.cloud:4566/session
```

You should receive the response:

```
{"success": true}
```

## Troubleshooting

If you encounter issues during setup:

- Ensure Docker is running and LocalStack is active:

```
docker-compose ps
```

- Verify AWS credentials are correctly configured in `~/.aws/config` and `~/.aws/credentials`.
- Ensure no other services are using ports `4566` or `4510-4559`.
- Check your `/etc/hosts` file if DNS resolution fails.

## Key Configuration Files

This setup relies on three primary configuration files: devcontainer.json, docker-compose.yml, Dockerfile (see article for full code).

## Next Steps

With your LocalStack environment ready, you can now develop and test AWS and Snowflake applications locally. In the next article, we'll explore:

- Initializing and bootstrapping AWS CDK.
- Creating foundational objects in Snowflake.
- Writing integration tests with LocalStack and the Snowflake container.

## Conclusion

Setting up a local development environment with LocalStack and Snowflake emulation simplifies workflows, reduces costs, and ensures consistent results. By leveraging tools like devcontainers and Docker, you can focus on building and testing your applications without worrying about cloud service costs or availability.

Stay tuned for the next installment in this series!
