---
class: generic
provider: google
model: gemini-3.7-flash
generated: 2026-08-28
target_words: 998
source_article: being-told-i-could-be-fired.md
prompt: |
  Write a technical blog post titled "Being Told I Could Be Fired Was the Best Thing for My Career" about What a manager's warning that an engineer could be fired changed about that engineer's teamwork, and what it implies about delivering hard feedback.. Aim for about 998 words. The audience is working data engineers.

  Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
---

# Being Told I Could Be Fired Was the Best Thing for My Career

Four years ago, I thought I was untouchable. 

I was the senior data engineer on a high-throughput clickstream platform. I spent my days tuning Spark executor memory, rewriting unoptimized SQL queries to save thousands in monthly Snowflake compute, and building complex PySpark frameworks from scratch. In my mind, engineering value was a pure function of code volume, query execution speed, and uptime.

Then came a routine Tuesday one-on-one with my engineering manager. 

He didn't open with small talk. He shut his laptop, looked at me, and said: *"You’re one of the sharpest engineers on this floor, but if your behavior doesn't fundamentally change over the next ninety days, I am going to fire you."*

The room went cold. My initial reaction was pure, defensive indignation. My pipelines didn't break. My SLAs were green. How could a company fire an engineer who had just shaved 40% off the daily batch ETL window?

What followed was the most uncomfortable forty-five minutes of my professional life. It was also the turning point that reshaped not only how I build distributed systems, but how I understand the entire discipline of software and data engineering.

---

## The "Brilliant Jerk" Trap in Data Engineering

My manager laid out the evidence with surgical precision. None of it was about my code syntax; all of it was about my blast radius on the team.

*   **PR Gatekeeping:** I treated pull requests like academic defenses. I left fifty-comment reviews nitpicking variable names and rewriting working logic in custom, esoteric paradigms because "it was more elegant." Junior engineers were terrified of submitting PRs to my repositories.
*   **Architectural Isolation:** When building a new ingestion engine using Kafka and Iceberg, I designed it entirely in a silo. I didn't write design docs, didn't solicit feedback, and didn't consult the platform team. I built a cathedral that only I knew how to maintain.
*   **On-Call Hostility:** When downstream analytics engineers broke a dashboard due to a missing partition or a schema mismatch, I openly expressed frustration about their lack of understanding of distributed storage, rather than building resilient schema contracts and defensive metadata validation.

I had optimized for my own individual throughput at the absolute expense of the team’s collective velocity. I was creating single points of failure—not in our Airflow DAGs, but in our human workflows.

---

## Refactoring My Engineering Operating System

Being handed an explicit ultimatum stripped away my ego. If I wanted to stay, I had to treat my interpersonal workflow with the same rigor I applied to debugging memory leaks in JVM processes. 

Over the next three months, I forced myself to make three concrete operational shifts:

### 1. Designing for the 2:00 AM On-Call Engineer
I stopped writing clever, hyper-condensed metaprogramming tricks in Python and began writing boring, readable, maintainable code. 

Data engineering is uniquely prone to midnight incidents when upstream schemas drift or network partitions occur. If a mid-level engineer cannot read my pipeline code, understand the lineage, and patch it while half-asleep during a P1 incident, then that code is bad—regardless of how performant it is. Maintainability is an engineering constraint, not a stylistic preference.

### 2. Treating Pull Requests as Asynchronous Mentoring
I rewrote my mental model of the PR process. Instead of using reviews to showcase domain dominance, I instituted a personal rule: for every piece of critical feedback, I had to provide an explanation of the *why* (e.g., "Using `repartition()` here causes a full shuffle across the cluster; `coalesce()` avoids the network overhead") and include a link to documentation or a benchmark. 

If a PR required more than five inline comments, I stopped typing and hopped on a ten-minute huddle. Code review is a teaching tool, not a moat.

### 3. Building Bridges Across the Data Lifecycle
Data engineering does not exist in a vacuum; it sits between transactional software engineers upstream and analysts, data scientists, and product managers downstream. 

I started hosting weekly office hours for analytics engineers to co-design dbt models. I partnered with backend teams to implement Protobuf-based event contracts at the source, preventing schema drift before it ever reached the raw bronze lakehouse layer. I realized that 80% of data quality issues aren't fixed with better regex in Spark—they are fixed through better communication across team boundaries.

---

## What This Implies About Hard Feedback

Looking back, the easiest thing for my manager to do would have been to give me vague, sugar-coated feedback during quarterly reviews: *"Try to be more collaborative,"* or *"Work on cross-functional communication."* 

Had he done that, I would have ignored it. High-performing individual contributors often dismiss soft feedback because they believe their technical output insulates them from consequence.

By putting my job on the line explicitly and linking my survival to team cohesion, my manager did something rare: he delivered **unambiguous, high-stakes clarity**.

Delivering hard feedback requires two distinct components:
1. **Radical Directness:** State the problem without corporate euphemisms. If someone's interpersonal friction outweighs their technical contribution, tell them plainly that their trajectory leads out the door.
2. **Actionable Remediation:** Don't just condemn the behavior; provide the blueprint for recovery. My manager outlined specific metrics: PR turnaround sentiment, collaborative architectural RFCs, and feedback from the downstream analytics team.

Direct feedback isn't cruelty; it is the highest form of professional respect. Letting an engineer plateau—or quietly managing them out without ever giving them the raw truth—is the real failure of leadership.

---

## The Measure of a Senior Engineer

Today, when I evaluate senior and staff data engineers, I rarely care about who can write the most complex custom Spark streaming operator from memory. The industry is full of developers who can write fast code but slow down everyone around them.

True seniority is measured by how much you elevate the engineering ceiling of the people sharing your codebase. It’s measured by clear documentation, fault-tolerant architectures that empower juniors, empathetic code reviews, and robust contracts that bridge technical silos.

Getting told I was on the verge of being fired was terrifying. But it broke the illusion that technical skill alone makes an engineer valuable—and that realization saved my career.
