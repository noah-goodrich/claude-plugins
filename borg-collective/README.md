# borg-collective

The cognitive-load layer for parallel AI coding — skills and lifecycle hooks for sustainable
AI-assisted development.

This plugin packages the publishable subset of the [borg-collective](https://github.com/noahgoodrich/borg-collective)
workflow: lifecycle skills (plan, review, assimilate, link-up), the always-on `adhd-guardrails` skill
that keeps scope honest, the `simplify` and `borg-collective-review` review skills, and a handful of
lifecycle hooks (bash safety guard, pre-commit reminder, tool-count nudge, desktop notification).

The plugin works standalone — no Cairn, no orchestrator CLI, no daemons required. It can optionally
take advantage of the [Cairn](https://github.com/cairn-knowledge/cairn) knowledge graph for richer
features (semantic search across projects, structured decision queries) when `cairn` is on `PATH`;
the skills detect its absence and degrade gracefully.
