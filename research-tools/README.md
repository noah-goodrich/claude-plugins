# Research Tools

Research and ideation methodology plugin for Claude Code. Two complementary pipelines covering
the full spectrum from open-ended problem exploration through rigorous evidence synthesis.

## Skills

| Skill | Trigger | When to use |
|-------|---------|-------------|
| `brainstorm` | `/brainstorm` | Open-ended problems where the implementation approach can't be specified before the options are known. Decomposes into parallel research tracks, synthesizes 3–5 distinct solution options, and convenes a 5-persona design council that makes a recommendation. |
| `deep-research` | `/deep-research` | Evidence synthesis with academic rigor. Full pipeline: design, discovery, 10-dimension source evaluation, citation verification, inclusion/exclusion decisions, synthesis, and documentation. Use when you need a defensible evidence base, not just a recommendation. |

## When to use which

```
Need options before you can plan?          → /brainstorm
Need a defensible evidence base?           → /deep-research
Brainstorm track needs academic evidence?  → /brainstorm invokes /deep-research for that track
```

## How they fit together

`/brainstorm` can invoke `/deep-research` for individual tracks that require evidence depth.
The brainstorm output document feeds into `/borg-plan` for implementation planning. The typical
flow for a vague, high-stakes problem is: brainstorm → borg-plan → implementation.

## Prior Art

This plugin synthesizes and extends six established source evaluation and research frameworks:

- **CREDIBLE** — 8-component source evaluation (most comprehensive single framework)
- **CRAAP** — Currency, Relevance, Authority, Accuracy, Purpose (widely taught)
- **SIFT** — Stop, Investigate, Find, Trace (process-oriented, web sources)
- **PRISMA** — Systematic review inclusion/exclusion pre-registration
- **RADAR** — Rationale, Authority, Date, Accuracy, Relevance (academic)
- **DeepTRACE** — AI citation audit, 8 reliability dimensions
