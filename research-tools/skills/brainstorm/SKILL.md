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
5. `docs/research/` — existing research documents to reuse as track input

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

Scan `docs/research/` for existing research relevant to the problem. List what you find and note
whether each document looks reusable as track input. Surface the inventory at the Phase 2
checkpoint — do not silently reuse or silently discard.

**Stale evidence is deep-research's job, not brainstorm's.** If a track's correctness is
load-bearing and your model knowledge (or the existing research) is stale, run `/deep-research`
separately and feed its §1–§2 back in as that track's findings. Brainstorm stays fast; deep-
research owns evidence rigor and freshness checks (its Phase 1.0 novelty probe gates whether a
full run is even warranted).

---

## Phase 2: Track Decomposition

Break the problem into **2–4 parallel research angles**. Fewer tracks for focused problems;
more for broad ones. Each track gets:

1. **Name** — short label (e.g., "user/behavioral", "competitive", "technical", "domain")
2. **Question** — the specific question this track answers
3. **Research source** — `fresh` / `reuse:[path]` / `supplement:[path]`

### One evidentiary standard, one escape hatch (Directive 04)

Every track runs the SAME lightweight research and returns the SAME unified finding shape (see
Phase 3) — a single brainstorm no longer carries two incompatible evidentiary standards side by
side. There is no `lightweight` vs `evidence-backed` depth tag and no inline novelty-probe /
recency-band / recursive-`/deep-research` machinery: that ~85-line apparatus had a 0% utilization
rate across the corpus and taxed every read (`audit.md:278-287`), so it is replaced by one line:

> **Escape hatch:** if a track's correctness is load-bearing and your model knowledge is stale,
> run `/deep-research` separately and feed its §1–§2 back in as that track's findings.

deep-research owns evidence rigor; brainstorm stays fast.

### Common track patterns

Most problems fit one of these decompositions:

| Track | Answers |
|-------|---------|
| User/behavioral | How do real users behave in this context? What does psychology say? |
| Competitive | What do existing products do? Where do they succeed/fail? |
| Technical | What's feasible given our stack? What are the known implementation patterns? |
| Domain | What do subject-matter experts say about this specific problem? |

Not every problem needs all four. Two well-scoped tracks often beat four shallow ones. For any
track whose correctness is load-bearing, use the escape hatch above rather than trusting model
knowledge.

### Phase 2 checkpoint

Present the full track plan before proceeding:
- Sharpened problem statement
- Constraint list (with tensions flagged)
- Track table (name, question, research source)
- Research inventory findings (reuse decisions)
- Any track flagged for the `/deep-research` escape hatch (load-bearing + stale knowledge)

**Do not run Phase 3 until this checkpoint is confirmed.** User can adjust track angles, reuse
decisions, and which tracks warrant the escape hatch. This is the cheapest moment to course-correct.

---

## Phase 3: Parallel Track Research

Spawn one agent per track using the Agent tool. Independent tracks run in parallel; only sequence
if one track's findings are needed to frame another (rare — avoid sequencing as a default).

Every track runs the SAME lightweight research and returns the SAME unified finding shape. Each
agent receives:
- The track question
- The problem statement and constraints
- Access to: WebSearch, WebFetch, Read

### Unified finding shape (Directive 04)

Each finding carries a **minimal source record** — the same minimal evidentiary fields a
`/deep-research` source card front-matter carries (full citation, URL, access date), so brainstorm
findings and deep-research findings speak one evidentiary language. A finding is NOT a free-form
"the source basically says X"; it is a discrete claim with a citable source attached.

Returns:
```
Track: [name]
Research source: fresh | reused:[date] | supplemented:[date]

Key findings (each a discrete claim + minimal source record):
- [Finding claim] — Source: [author/outlet, title, URL, access date YYYY-MM-DD]
[3–5 findings]

Confidence note: [one sentence — "findings well-supported" OR "claim X is weakly sourced — flagging"]
```

**Escape hatch (the only path to deeper rigor).** If a track's correctness is load-bearing and
your model knowledge is stale, run `/deep-research` separately and feed its §1–§2 back in as that
track's Key findings (keeping the same minimal-source-record shape). Brainstorm itself runs no
second, lower-rigor research pipeline — there is one evidentiary standard here, and deep-research
is where evidence rigor lives.

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

### Track 1: [Name] ([fresh/reused:[date]/supplemented:[date]])
- [Finding claim] — Source: [author/outlet, title, URL, access date]
- [Finding claim] — Source: [author/outlet, title, URL, access date]
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
| Get deeper evidence for a track | Escape hatch: run `/deep-research` separately, feed its §1–§2 back in |
| Shape a track finding | One unified shape: a discrete claim + minimal source record (author, title, URL, date) |
| Choose visual format | UI/interaction pattern → Claude Design prompt. Flow/architecture/journey → Mermaid |
| Handle no project context | Skip context loading, degrade gracefully, offer to save output to user-specified path |
| Move from brainstorm to implementation | Feed output document into /borg-plan as context |
| Validate "distinct" options | If two options are the same approach with different labels, merge them |
