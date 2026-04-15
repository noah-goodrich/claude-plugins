# Strategic Brief Analytical Framework

This framework defines the 9-step analysis process for producing strategic technology
assessments. Each step builds on the previous one. Skipping steps produces shallow analysis.

---

## The 9 Steps

### Step 1: Understand the Subject
Read the code, not just the docs. Docs describe intent; code reveals reality. Key questions:
- What problem does this solve?
- Who uses it and how?
- What's the actual complexity (LOC, dependencies, test coverage)?
- What's the maintenance burden?

### Step 2: Identify the Problem It Solves
Separate the problem from the solution. The problem ("Snowflake accounts drift from WAF best
practices") exists independently of any tool. Define it precisely so you can evaluate whether
other solutions address the same problem.

### Step 3: Research Competitive Landscape
Use concentric rings:
1. **Platform-native:** Does the vendor solve this themselves?
2. **Commercial:** Who charges for it? At what price?
3. **Open-source:** Free alternatives?
4. **Adjacent:** Tools that partially overlap?
5. **Emerging:** AI/agent approaches that could disrupt?

For each entry, capture: name, what it does, pricing, deployment model, coverage breadth,
and limitations. Build a comparison matrix.

### Step 4: Analyze Build vs Buy
Calculate total cost of ownership for each path:
- **Build:** Dev time + maintenance + opportunity cost
- **Buy:** License + integration + vendor lock-in + feature gaps
- **Hybrid:** Which parts to build, which to buy?

Use specific numbers. "It depends" is not analysis.

### Step 5: Evaluate Architecture Alternatives
For technology tools, the key architecture question is usually: deterministic code vs
LLM/agent vs hybrid. Evaluate on these axes:
- **Cost per operation** at 1x, 10x, 100x scale
- **Reliability:** Reproducibility, false positive/negative rates
- **Portability:** CI/CD, air-gapped, restricted environments
- **Security:** Data exposure, API dependencies, regulatory compliance
- **Maintenance:** Code maintenance vs prompt drift vs model upgrades

### Step 6: Challenge Assumptions
List every major assumption found in the codebase and docs. For each:
- State the assumption
- Present evidence for it
- Present evidence against it
- Verdict: holds, partially holds, or doesn't hold

This is the intellectual honesty section. It builds trust with the reader.

### Step 7: Present Multiple Reasoning Paths
For the recommendation, show how you got there via at least two independent paths:
- **Path A (cost-driven):** Which option minimizes total cost?
- **Path B (risk-driven):** Which option minimizes risk?
- **Path C (capability-driven):** Which option maximizes capability?
- **Path D (market-driven):** Which option aligns with market direction?

When paths converge, the recommendation is strong. When they diverge, acknowledge the
trade-off and explain which path you weighted more heavily and why.

### Step 8: Make an Unbiased Recommendation
The recommendation should be:
- **Clear:** "Do X" not "consider X"
- **Actionable:** Includes specific next steps
- **Conditional:** Includes "what would change this"
- **Honest:** If the answer is "kill the project," say so

### Step 9: Include Decision Guardrails
Name 3-5 conditions under which the recommendation should be re-evaluated:
- Market changes (new competitor, platform feature release)
- Cost changes (LLM pricing drops 10x)
- Regulatory changes (new compliance requirements)
- Scale changes (10x growth in usage)

These guardrails let the reader know when to revisit the decision rather than treating
the recommendation as permanent truth.

---

## Document Templates

### Full Analysis Template

```
# Strategic Analysis: [Subject]
*Date: [date] | Author: [name] | Status: [Draft/Final]*

## 1. Executive Summary
[1 page. Must work standalone. Problem, finding, recommendation, next steps.]

## 2. Problem Statement & Market Gap
[Define the problem independently of any solution. Quantify the gap.]

## 3. Competitive Landscape
[Narrative summary + reference to Appendix A matrix.]

### 3.1 First-Party / Native
### 3.2 Commercial
### 3.3 Open-Source
### 3.4 Adjacent Tools
### 3.5 Emerging / Agent-Based

## 4. Build vs Buy Analysis
[TCO comparison with specific numbers.]

## 5. Architecture Decision
[Deterministic vs Agent vs Hybrid. Cost, reliability, portability, security.]

## 6. Assumptions Challenged
[Table: Assumption | Evidence For | Evidence Against | Verdict]

## 7. Recommendation & Decision Framework
### Reasoning Paths
### Recommendation
### What Would Change This

## 8. Risk Register
[Table: Risk | Likelihood | Impact | Mitigation]

## Appendix A: Competitive Feature Matrix
## Appendix B: Cost Model Details
## Appendix C: Sources
```

### Executive Summary Template

```
# Executive Summary: [Subject]
*Date: [date]*

## The Problem
[2-3 sentences defining the problem, not the solution.]

## What We Built
[2-3 sentences on current state. Factual, not promotional.]

## Market Position
[Condensed comparison: what exists, what it costs, what gaps remain.]

## Key Decision
[The central question + 3-bullet answer.]

## Recommendation
[1 paragraph. Clear, actionable, conditional.]

## Next Steps
[3-5 bullets with owners and timeframes where possible.]

## Risks
[3 bullets: what could go wrong and how to mitigate.]
```

---

## Quality Checklist

Run this before delivering any strategic brief:

- [ ] Problem is defined independently of the solution
- [ ] Competitive matrix has 15+ entries
- [ ] Every competitor has specific pricing (or "contact sales" if unpublished)
- [ ] Cost models use $/unit, not "cheaper" or "more expensive"
- [ ] At least 3 assumptions challenged with evidence both ways
- [ ] Recommendation uses 2+ independent reasoning paths
- [ ] "What would change this" section has 3-5 concrete conditions
- [ ] Risk register has likelihood + impact + mitigation
- [ ] Sources section has 20+ references
- [ ] Executive summary works standalone
- [ ] All lines <= 120 characters
- [ ] No advocacy language ("our amazing tool," "industry-leading")
- [ ] Honest about limitations and unknowns
