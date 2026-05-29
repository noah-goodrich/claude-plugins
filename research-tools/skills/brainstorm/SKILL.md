---
name: brainstorm
description: "Multi-track design council for open-ended product and UX problems. Decomposes
  the problem into parallel research tracks, synthesizes findings into 3–5 genuinely distinct
  solution options with tradeoffs and visuals, then convenes a 5-persona council that evaluates
  options and makes a recommendation. Use when the implementation approach can't be specified
  before the options are known — when the design space is large and the stakes are high enough
  to warrant structured exploration before committing. Trigger: /brainstorm or when asked to
  ideate, explore approaches, or solve a design problem with no obvious answer."
---

# Brainstorm — Design Council

A structured process for turning vague, high-stakes problems into a concrete recommendation
backed by parallel research and adversarial council review.

## When to use

**Use `/brainstorm` when:** The implementation approach can't be specified before the options
are known. The question is open-ended. The design space is large enough that picking an approach
without research risks building the wrong thing well.

**Use `/borg-plan` instead when:** The approach is already clear and you're planning execution.

Rule of thumb:
- "How do we design a meal planning workflow that does 99% of the work for the user?" → `/brainstorm`
- "Implement a page to manage my grocery list." → `/borg-plan`

**Corollary: the more vague the ask, the more important it is to run this skill.** Vagueness
is a signal that the options haven't been discovered yet, not that the task is simple.

---

## Before You Begin

Before Phase 1, load all available context (in priority order). Read each that exists:

1. `BUSINESS_BRIEF.md` — constraints, ICP, kill criteria, pricing shape, what this product IS NOT
2. `CLAUDE.md` — tech stack, architecture, deployment, conventions
3. Any files passed as arguments (`/brainstorm "question" --context path/to/file.md`)
4. `docs/brainstorms/` — scan for prior brainstorms on related problems (avoid re-solving)
5. `docs/research/` — existing research documents (evaluated via recency gates in Phase 1)

**No project context?** Degrade gracefully — skip steps 1–5, run on the problem statement alone.
Offer to save output to a user-specified path at the end.

---

## Phase 1: Problem Framing + Research Inventory

### 1a. Sharpen the problem statement

Produce:

1. **Problem statement** (2–3 sentences):
   - What pain is being solved?
   - For whom? (Be specific — not "users," but the ICP from the business brief if available)
   - What does success look like from the user's perspective — not the builder's?

2. **Constraint list** (bullets): Derive from business brief, CLAUDE.md, and explicit user input.
   Flag any constraints in tension with each other — those tensions often determine which option
   wins.

### 1b. Research inventory

Scan `docs/research/` for existing research relevant to the problem. For each document found,
apply recency gates:

| Age | Action |
|-----|--------|
| < 45 days | Available for track reuse as-is. Surface at Phase 2 checkpoint. |
| 45–90 days | Flag for evaluation. Track agent reads §4 Analysis headings and checks whether key claims are likely to have shifted. **Tech and competitive tracks**: apply higher scrutiny — frameworks, APIs, and market landscape shift fast. **Behavioral/domain tracks**: more tolerant — cognitive science doesn't change in 6 weeks. |
| > 90 days | Default to re-run. Novelty probe runs first before invoking the full pipeline (see Phase 3). |

Surface the inventory at the Phase 2 checkpoint. Do not silently reuse or silently discard.

---

## Phase 2: Track Decomposition

Break the problem into **2–4 parallel research angles**. Fewer tracks for focused problems;
more for broad ones. Each track gets:

1. **Name** — short label (e.g., "user/behavioral", "competitive", "technical", "domain")
2. **Question** — the specific question this track answers
3. **Depth** — `lightweight` or `evidence-backed` (see classification guide below)
4. **Research source** — `fresh` / `reuse:[path]` / `supplement:[path]`

### Track depth classification

**`lightweight`** — WebSearch/WebFetch/Read, 3–5 key findings, 1–2 cited sources per finding.
Right for:
- Competitive landscape ("what do existing apps do, and where do they fall short?")
- Technical feasibility ("can we build X with the current stack?")
- Current market state ("what tools/frameworks exist for this today?")
- Topics where model knowledge is reliable and a few searches catch any updates

**`evidence-backed`** — Invokes `/deep-research` as a sub-pipeline (with novelty probe
gate — see Phase 3). Right for:
- Behavioral, psychological, or clinical claims where model knowledge is likely confidently wrong
- Any track where a wrong answer would meaningfully mislead the synthesis
- Contested topics where institutional or academic sources are needed to separate signal from noise

**Classification heuristic:** *"If this track's findings are wrong due to outdated or fabricated
model knowledge, does the entire synthesis go in the wrong direction?"* If yes → `evidence-backed`.

### Common track patterns

Most problems fit one of these decompositions:

| Track | Typical depth | Answers |
|-------|--------------|---------|
| User/behavioral | evidence-backed | How do real users behave in this context? What does psychology say? |
| Competitive | lightweight | What do existing products do? Where do they succeed/fail? |
| Technical | lightweight | What's feasible given our stack? What are the known implementation patterns? |
| Domain | evidence-backed | What do subject-matter experts say about this specific problem? |

Not every problem needs all four. Two well-scoped tracks often beat four shallow ones.

### Phase 2 checkpoint

Present the full track plan before proceeding:
- Sharpened problem statement
- Constraint list (with tensions flagged)
- Track table (name, question, depth, research source)
- Research inventory findings (reuse decisions)

**Do not run Phase 3 until this checkpoint is confirmed.** User can adjust track angles, depth
tags, and reuse decisions. This is the cheapest moment to course-correct.

---

## Phase 3: Parallel Track Research

Spawn one agent per track using the Agent tool. Independent tracks run in parallel; only sequence
if one track's findings are needed to frame another (rare — avoid sequencing as a default).

### Lightweight track agents

Each agent receives:
- The track question
- The problem statement and constraints
- Access to: WebSearch, WebFetch, Read

Returns:
```
Track: [name]
Depth: lightweight
Research source: fresh | reused:[date] | supplemented:[date]

Key findings:
- [Finding] — Source: [title, URL, access date]
[3–5 findings]

Confidence note: [one sentence — "findings well-supported" OR "claim X is weakly sourced — flagging"]
```

### Evidence-backed track agents

Before invoking the full `/deep-research` pipeline, every evidence-backed track agent runs a
**novelty probe** — 2–3 targeted searches:

1. `"[topic]" after:[existing-research-date]` — if existing research exists
2. `"[topic]" 2025 OR 2026 new research OR update`
3. One domain-specific probe (framework changelog for tech tracks; new study framing for
   behavioral/domain tracks)

**Early termination:** If the probe finds nothing materially new — same sources surfacing, no
new studies or frameworks, no contradicting findings — terminate the deep-research invocation.
Use existing research (if available) or model knowledge. Note the kill explicitly:

> "Novelty probe: no significant new developments found since [date]. Deep-research terminated
> early. Using [existing doc / model knowledge]."

The track still returns 3–5 key findings; they're drawn from the existing source rather than a
fresh pipeline run.

**Run the full pipeline:** If the probe finds new, updated, or conflicting information, invoke
`/deep-research` with the track question as the research question. The pipeline runs to completion.
The track agent then extracts §1 Recommendations + §2 Summary as its findings input to Phase 4.

Returns the same format as lightweight tracks, with depth noted as `evidence-backed (early-terminated)`
or `evidence-backed (full run)`.

---

## Phase 4: Synthesis — Generate Solution Options

One synthesis pass takes all track findings + loaded context and produces **3–5 genuinely distinct
solution options**.

**"Distinct" means different architectural or interaction approaches** — not variations on the
same idea with different visual treatments. If two options are the same approach with different
labels, merge them. The options should represent meaningfully different bets on how to solve the
problem.

For each option, produce the following block in full:

---

### Option [A/B/C/...]: [Short name — 3–5 words]

**What it is:** [2–3 sentences. The core idea. What makes this option different from the others.]

**How it works:** [Brief flow description. For UI options: what the user does step by step.
For system options: how data moves or how components interact.]

**Pros:**
- [Bullet]

**Cons:**
- [Bullet]

**Key tradeoffs:** [The unavoidable ones — what you concede by choosing this option over
the alternatives. Should be specific, not generic ("it's harder" is not a tradeoff).]

**Feasibility:** High / Medium / Low — [one-line reason grounded in the technical track findings,
not general intuition]

**Estimate:** [Rough size in sessions or engineer-hours. Not a commitment — a planning input.
Note if this is an order-of-magnitude guess vs. a confident estimate.]

**Visual:**

*For UI/UX interaction options — use a Claude Design prompt:*
```
Claude Design prompt:
Design a [component or screen name] for a mobile-first PWA (375px wide).
Context: [where it appears on screen; what surrounds it; what user action triggered this].
State shown: [the specific interaction state this mockup represents — not a generic layout].
Visual language: light bone background (#F5F0E8), Ember accent (#C2571A), Sage for success
states (#6B9B6D), Faience/terracotta for warnings (#C2571A area), Fraunces display font
for headings, Inter for body text, rounded-xl cards with soft box shadows, generous
whitespace.
Shows: [specific elements in priority order, their hierarchy, and any key copy].
Does not include: [navigation chrome, unrelated UI elements, lorem ipsum placeholder text].
Accessibility note: [contrast requirement or interaction consideration if relevant].
```

*For system architecture, data flow, or user journey options — use Mermaid:*
```mermaid
[diagram — flowchart, sequence, or erDiagram as appropriate]
```

---

### Minimum viable version note

For each option, add one sentence: *"The smallest version that delivers the core value is: [X]."*
This is the Pragmatist's input point and feeds directly into the council review.

---

## Phase 5: Council Review

Five personas evaluate the options. Each voice speaks once, references options by letter, and
cites specific findings from the track research. No hand-waving. Keep each voice to one focused
paragraph — the Adult in the Collective model; these personas have a different job.

---

**The Product Strategist**
Domain: Does this solve the right problem? Does it fit the business shape (pricing tier,
ICP constraints, lifestyle product vs. venture-scale, known kill criteria)?
Voice: Strategic, direct. References the business brief if available.
Ask: "Does Option X create a new problem the brief explicitly flags? Does it serve the actual
ICP or a hypothetical user?"

**The Technical Realist**
Domain: Can we actually build this? What's the hidden complexity? What breaks first under
production load or at the edges of the happy path?
Voice: Specific, grounded in the current stack. References the technical track findings.
Ask: "What does Option X require that the current architecture doesn't support? What's the
delta and is it worth it?"

**The User Advocate**
Domain: Will real users benefit — specifically the users described in the problem statement,
with their actual constraints, cognitive load, stress level, and time available?
Voice: Empathetic, concrete. References the user/behavioral track findings.
Ask: "Does Option X match how the target user actually behaves, or does it assume a more
capable/patient/focused user than the problem statement describes?"

**The Pragmatist**
Domain: Effort-to-impact ratio. What option gets 80% of the value for 20% of the work? Can
any option be safely reduced to its minimum viable version without losing its core bet?
Voice: Numbers-oriented, unsentimental. References the estimate field for each option.
Ask: "Is the full version of Option X actually necessary to test the hypothesis, or does the
minimum viable version suffice for an initial ship?"

**The Recommender**
Domain: Synthesizes all four voices. Names one option (or one option with a specific scope
constraint). States the reasoning in 2–3 sentences. Does not equivocate or list multiple
"it depends" paths.
Voice: Decisive. "The recommendation is Option [X] because [specific reason it beats the
alternatives given the constraints]. The minimum viable version to ship first is [Y]."

---

## Phase 6: Output Document

Save to `docs/brainstorms/YYYY-MM-DD-[slug].md` in the current project. Slug is 3–5 words
from the problem statement, hyphenated. If no project context, offer to save to a
user-specified path or present inline.

```markdown
# Brainstorm: [Problem Statement]
*Date: YYYY-MM-DD | Tracks: N | Options: N*

## Problem Definition

[Sharpened 2–3 sentence problem statement]

### Constraints
- [Constraint]
- [Constraint — note any in tension with each other]

## Research Summary

### Track 1: [Name] ([depth] — [fresh/reused:[date]/supplemented:[date]])
- [Finding] — [source]
- [Finding] — [source]
[Confidence note if anything flagged]

### Track 2: [Name] (...)
...

## Solution Options

### Option A: [Name]
[Full option block per Phase 4 format, including visual]

### Option B: [Name]
...

## Council Review

**The Product Strategist:** "[prose]"

**The Technical Realist:** "[prose]"

**The User Advocate:** "[prose]"

**The Pragmatist:** "[prose]"

**The Recommender:** "[prose — names Option X, states why it beats alternatives, names
minimum viable version]"

## Recommendation

**Option [X]** — [1–2 sentence restatement of the Recommender's reasoning]

**Minimum viable ship:** [What to build first to test the core bet]

## Next Steps

- [ ] [If recommendation approved: run /borg-plan with this document as context]
- [ ] [Any research track flagged for follow-up]
- [ ] [Any constraint tension that needs resolution before implementation]
```

---

## Quick Reference

| I need to... | Do this |
|---|---|
| Decide whether to run this skill | Ask: "Can I specify the implementation before knowing the options?" No → brainstorm |
| Classify track depth | "If this track is wrong, does it sink the synthesis?" Yes → evidence-backed |
| Reuse existing research | < 45 days: reuse. 45–90 days: evaluate (tech: high scrutiny; domain: lenient). > 90 days: novelty probe first |
| Kill deep-research early | Probe finds nothing new → terminate, note the kill, use existing or model knowledge |
| Choose visual format | UI/interaction pattern → Claude Design prompt. Flow/architecture/journey → Mermaid |
| Handle no project context | Skip context loading, degrade gracefully, offer to save output to user-specified path |
| Move from brainstorm to implementation | Feed output document into /borg-plan as context |
| Validate "distinct" options | If two options are the same approach with different labels, merge them |
