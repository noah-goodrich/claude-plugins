---
title: "The AI Efficiency Trap: Why I Built a Tool to Tell Cursor What to Test"
url: https://medium.com/@noah.goodrich/the-ai-efficiency-trap-why-i-built-a-tool-to-tell-cursor-what-to-test-4fecb95da925
date: 2025-12-15
publication: personal
reading_time_min: 5
claps_response_count: 0
tags: [python, software-testing, artificial-intelligence, software-engineering, machine-learning]
subtitle: "I've always been a testing pragmatist. But when I started using AI to write tests, I realized it was prioritizing vanity metrics over structural integrity."
---

# The AI Efficiency Trap: Why I Built a Tool to Tell Cursor What to Test

I have always been a testing pragmatist.

I don't lose sleep if my coverage drops below 100%. I prioritize critical paths. I test the code that handles money, data integrity, and complex logic. I have never been the type to waste billable hours writing unit tests for getter/setter methods or boiler-plate `__str__` representations just to see a green badge on a repo.

But then came the AI revolution.

Like many of you, I started using tools like **Cursor** to accelerate my workflow. Suddenly, the cost of writing tests dropped to near zero. I got greedy. I started firing off prompts like "improve test coverage" and "get us to 85%."

The AI happily obliged. It churned out tests at a speed I could never match. I watched the coverage percentage tick up and up. It felt productive.

**But then I looked at the code.**

The AI was gaming the system. It had instinctively found the path of least resistance. It was writing hundreds of tests for the low-hanging fruit — the utility functions, the config parsers, the trivial code — because those were easy to verify.

Meanwhile, the complex, high-risk business logic — the stuff that actually breaks production — was being skipped because the heuristics the AI used deemed it "too hard" or "low priority" compared to the easy wins.

I found myself spending hours supervising the AI, waiting through long cycles of implementation and refactoring, only to find that my application's structural integrity hadn't actually improved. I was just drowning in "Green Build" vanity metrics.

I needed a way to force the AI to think like a Senior Engineer. I needed a scoring system that could say: **"Ignore the easy stuff. Focus on what is High Impact and Low Complexity."**

That is why I built `pytest-coverage-impact`.

## The Logic: ROI over Vanity

`pytest-coverage-impact` is a plugin that brings ROI (Return on Investment) logic to your test suite. It parses your code's Abstract Syntax Tree (AST), builds a call graph, and uses Machine Learning to score every function in your codebase based on two factors:

1. **Impact (The Blast Radius):** How many other functions depend on this? If `process_payment()` breaks, the app dies. If `get_pretty_name()` breaks, a log looks ugly.
2. **Complexity (The Friction):** How hard will it be to write a test for this?

The plugin generates a **Priority Score** using this formula:

*A modified version of the RICE scoring model, emphasizing complexity and effort as the denominators for prioritization.*

This score gives me (and my AI assistant) a prioritized hit-list. Instead of asking Cursor to "increase coverage," I can paste the top 5 functions from the Impact Report and say, **"Write tests for these specific functions."**

## Under the Hood: Machine Learning for Code

Most tools measure "complexity" by just counting nested if-statements (Cyclomatic Complexity). I wanted something smarter.

I trained a Random Forest model to predict **"Test Pain."** The model analyzes static code features to guess how annoying a function will be to test:

- **Side Effects:** Does it touch the filesystem, network, or external APIs (like Snowflake)?
- **Test Anatomy:** Does testing this usually require mocks, fixtures, or integration markers?

The tool predicts — on a scale of 0.0 to 1.0 — how complex the testing effort will be.

- **High Priority:** High Impact + Low Complexity (The "Must Haves")
- **Low Priority:** Low Impact + High Complexity (The "Time Sinks")

It even calculates the **variance** between the trees in the Random Forest. If the model isn't confident in its prediction (wide confidence interval), it automatically deprioritizes that function. We only want to chase sure things.

## The Killer Feature: Train It on YOUR Code

Every codebase is different. What counts as "complex" in a monolithic web app is different from a Data Engineering repo.

I included a training pipeline directly into the CLI so the tool can learn from *your* existing tests.

```
# Combined command - collects data and trains model
pytest --coverage-impact-train
```

This command maps your existing functions to their tests, extracts the features, and trains a bespoke Random Forest model (`complexity_model_v1.1.pkl`) on your specific coding style. As your codebase evolves, your testing strategy evolves with it.

## How to use it

I designed this to plug directly into your existing workflow.

**Installation:**

```
pip install pytest-coverage-impact
```

Running the analysis:

You run pytest just like you normally would, but add the — coverage-impact flag.

```
pytest --cov=my_project --coverage-impact
```

The Output:

Instead of a wall of text, you get a prioritized backlog:

```
Top Functions by Priority (Impact / Complexity)
┏━━━━━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━┓
┃ Priority ┃ Score ┃ Impact ┃ Complexity    ┃ Function         ┃
┡━━━━━━━━━━╇━━━━━━━╇━━━━━━━━╇━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━┩
│        1 │  2.45 │   12.5 │  0.65 [±0.15] │ auth.py::login   │
│        2 │  1.80 │    8.0 │  0.20 [±0.05] │ utils.py::parser │
```

In this example, `auth.py::login` is the winner. It has high impact, and the model is confident that it's testable. This allows me to point Cursor exactly where it needs to go.

## The Origin Story

I didn't actually set out to build a standalone pytest plugin.

I was in the middle of a complete rewrite of **Snowfort** (my Snowflake management tool — keep an eye out for the new version dropping shortly, it's a massive upgrade).

I was staring at a blank slate of code and realized I needed a way to keep my testing focused as I built out the new features. I created these scripts to help me prioritize the Snowfort rewrite, and then realized this logic could help any Python developer who is tired of their AI writing useless tests.

## Summary

In the age of AI, code generation is cheap, but **strategy is expensive**.

`pytest-coverage-impact` acts as a targeting system for your AI coding assistant. It stops the AI from padding your stats with low-value tests and forces it to tackle the structural integrity of your application.

- **GitHub Repo:** <https://github.com/noah-goodrich/pytest-coverage-impact>
- **PyPI:** `pip install pytest-coverage-impact`

Let me know if you find any "hidden dragons" in your code using this. I certainly did.
