---
title: "Snowflake & AWS Infrastructure as Code (Part 2)"
url: https://medium.com/@noah.goodrich/snowflake-aws-infrastructure-as-code-b436d30b8a34
date: 2024-12-28
publication: personal
reading_time_min: 5
claps_response_count: 1
tags: [snowflake, snowflake-data-superhero, data-superhero]
subtitle: "Part 2: Ditching CDK for Snow Forts"
---

# Snowflake & AWS Infrastructure as Code

## Part 2: Ditching CDK for Snow Forts

*In the first part of this series, we embarked on a journey to build a scalable, robust data platform using Snowflake. We discussed leveraging AWS CDK to manage Snowflake assets. However, as with any good adventure, we encountered unexpected twists and turns. In this article, we'll pivot from CDK and introduce a new concept: Snow Forts, while diving deeper into the implementation details.*

## **Rethinking My Approach**

I have a confession to make: my initial approach with the Snowflake Python APIs and AWS CDK didn't work quite like I had hoped. The fault was mine — I didn't spend the time I should have understanding how CDK worked. But hey, lessons learned, right?

Once I had my development environment set up and running, I needed to decide **how** I wanted to manage the configuration of all the resources in my application. Before tackling the "how," I needed to first document **what** resources I needed.

### **What We Needed**

At a minimum, I knew I needed a basic data engineering environment for pipelines, which would consist of:

- **Administrative resources:** An admin database, role, and user for automated deployments and other administrative tasks.
- **Medallion databases:** A set of databases: Bronze, Silver, Gold, and Platinum.
- **Data pipelines:** Pipelines for ingest, cleaning & transformation, analytics, and machine learning (ML).
- **Storage integrations:** One or more storage integrations between S3 and Snowflake.

It was also a given that we'd be deploying machine-learning solutions into the cloud, involving some blend of Snowflake and AWS services.

### **The Problem With My Initial Approach**

I had managed to get everything working for creating the admin resources and medallion databases, so I figured it was time to fully test my solution by bootstrapping my CDK app and deploying it. That's when I ran into some major issues:

1. Upon bootstrapping the CDK app, I noticed that all of my Snowflake code had already run and deployed.
2. I still hadn't figured out how to hook into the CDK destroy lifecycle, which meant I couldn't reliably spin down all my Snowflake resources.

It became clear that my approach wasn't going to work the way I had envisioned.

### **Options for Moving Forward**

After reading the CDK documentation and exploring approaches online, three main options emerged:

**Option 1: AWS Lambdas and CloudFormation**
- Pros: Leverages CDK and CloudFormation as intended. Snowflake resources are defined using configuration objects and deployed via Lambda.
- Cons: Complexity: Forces Snowflake changes through standardized configurations or custom Lambda code. Testing Challenges: Separates testing for deployment code versus configuration changes, making it more cumbersome.

**Option 2: Separate Codebases for Snowflake and AWS Infrastructure**
- Pros: CDK handles AWS infrastructure while Snowflake Python APIs manage Snowflake resources. Testing is straightforward since each system is isolated.
- Cons: Cross-platform resources (e.g., storage integrations) are harder to manage. May require custom deployment processes for sequential dependencies.

**Option 3: A Middle-Road Approach**
- Pros: Combines AWS and Snowflake management in one process.
- Cons: Violates expectations of CDK lifecycle management. Risks creating a messy, hacky solution. Ignores the destroy lifecycle, potentially leaving orphaned resources.

**Why I Chose Option 3**

Ultimately, we chose **Option 3: A Middle-Road Approach**. Using tools like boto3 to handle AWS resources ensured we could manage cross-platform dependencies seamlessly.

While this approach introduces challenges — like ensuring resources are properly destroyed — we expect these issues to be minimal with good management practices. By combining the Snowflake APIs with AWS infrastructure tools, we struck a balance between simplicity and functionality.

## **Introducing Snow Forts**

Enter **Snow Forts**, a custom implementation for managing Snowflake resources. Inspired by Snowflake's playful naming conventions (Snowpipe, Snowpark, etc.), Snow Forts embody the idea of building modular, reusable, and robust "forts" to manage Snowflake assets.

### **Core Principles**

1. **Modular Design:** Each Snow Fort manages a specific domain — administration, data pipelines, or medallion architecture.
2. **Python First:** Leveraging Python directly, we sidestep CDK's abstraction layers and retain flexibility.
3. **Scalable and Maintainable:** Each fort evolves independently while adhering to shared conventions.

### **A Tour of the Snow Forts Implementation**

Let's dive into the code and structure that brings Snow Forts to life. You can follow along with the full implementation in the [snowflake-examples](https://github.com/noah-goodrich/snowflake-examples/tree/snowforts/snowflake-deployments). repository.

**Directory Structure**

```
snow-forts/
├── deploy.py                # Main deployment orchestrator
├── forts/                   # Snow Forts modules
│   ├── __init__.py
│   ├── admin.py             # Admin-focused fort
│   └── medallion.py         # Medallion architecture fort
├── libs/                    # Shared utilities
│   ├── __init__.py
│   └── crypt.py             # Encryption and security
└── tests/                   # Test cases
    ├── integration/         # Fort-specific integration tests
    └── unit/                # Unit tests
```

**Deploy Script (deploy.py)**

The deploy.py script serves as the mission control, orchestrating the deployment of all Snowflake assets by invoking the relevant Snow Forts.

**Admin Fort (admin.py)**

The Admin Fort is responsible for setting up Snowflake administrative resources while following best practices:

1. **AccountAdmin Isolation:** Limit the use of the AccountAdmin role to a few users. Create a separate deployment role (HOID) with SYSADMIN and USERADMIN privileges to minimize the impact of potential security breaches.
2. **Service Users:** Utilize Snowflake's service users with key pair authentication for secure, passwordless deployments.
3. **Admin Database:** Create a dedicated database, COSMERE, to store all administrative resources, ensuring they remain organized and easily accessible.

**Medallion Fort (medallion.py)**

The Medallion Fort implements the **medallion architecture**, organizing data into distinct layers for processing:

1. **Bronze:** Raw data ingestion.
2. **Silver:** Data transformations and cleansing.
3. **Gold:** Query-optimized data.
4. **Platinum:** AI/ML-ready datasets.

**Encryption Library (libs/crypt.py)**

The crypt.py module provides cryptographic utilities to ensure the secure handling of sensitive credentials and secrets.

**Testing and Validation**

Snow Forts include unit and integration tests to validate functionality. These tests ensure each fort behaves as expected, even as the system evolves.

### **Why Snow Forts Work**

1. **Simplicity with Python:** By using Snowflake's APIs directly, Snow Forts remain Pythonic and straightforward to implement.
2. **Flexibility:** The modular design allows for fine-grained control over Snowflake assets, without the constraints of template-driven systems.
3. **Scalability:** As new requirements emerge, additional forts can be added with minimal impact on the existing framework.

## Conclusion

In this installment, we navigated the challenges of integrating Snowflake with AWS and introduced **Snow Forts** as a streamlined, Python-centric solution for managing Snowflake resources. By adopting a middle-road approach, we combined the strengths of both platforms, achieving a balance between flexibility and functionality.

Looking ahead, Part 3 will delve into testing strategies for Snow Forts, ensuring their robustness and reliability. Additionally, we'll explore constructing a Storage Integration as a Snow Fort, further enhancing our data platform's capabilities.

Stay tuned as we continue to build and fortify our Snowflake infrastructure, one Snow Fort at a time.
