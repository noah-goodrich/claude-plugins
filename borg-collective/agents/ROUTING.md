# Agent Routing Guide

**Principle: Opus is opt-IN for subagents. Route to the cheapest tier that fits.**

Every unspecified subagent inherits the main session model — usually Opus. Opus subagents cost
~60x more per token than Haiku. Most work does not justify that. Use this matrix to pick the right
tier before spawning.

---

## Routing Matrix

| Agent            | Model  | Effort | Use when                                                      | Do NOT use when                                      |
|------------------|--------|--------|---------------------------------------------------------------|------------------------------------------------------|
| **borg-grunt**   | Haiku  | low    | Executing a fully-specified change: apply an edit, run tests, | The spec is ambiguous, requires judgment, or may      |
|                  |        |        | grep logs, rote refactor. One task, zero judgment calls.       | expand. Escalate to nanoprobe instead.               |
| **borg-scout**   | Haiku  | low    | Read-only locate/search: "where is X?", "does Y exist?",      | You need to write or edit anything. Scout is          |
|                  |        |        | "what naming convention?". Returns locations + excerpts.       | strictly read-only.                                  |
| **borg-nanoprobe** | Sonnet | medium | Single discrete task that requires judgment: implement a      | The task spans multiple unrelated concerns or needs   |
|                  |        |        | feature, fix a bug, write a test, refactor with discretion.   | open-ended exploration. Split it first.              |
| **borg-researcher** | Sonnet | medium | From-zero web research on ONE track. Fetches primary sources, | You already have the answer or can derive it from    |
|                  |        |        | verifies claims, writes a structured findings doc.             | the repo — don't burn web fetches on known facts.   |
| **borg-reviewer** | Sonnet | high   | Independent blind adversarial review of a proposal or         | You want a collaborator. Reviewer arrives cold and   |
|                  |        |        | option-set. Catches what self-review misses.                   | does not see author reasoning — that's the point.   |
| **claude** / general-purpose | Opus | (inherited) | Hard open-ended reasoning with no clear decomposition:  | Any task that fits a specialist above. Opus is the   |
|                  |        |        | novel architecture, complex multi-step inference, tasks where  | EXCEPTION, not the default. Defaulting here for      |
|                  |        |        | the orchestrator cannot write a clear spec.                    | routine work is the primary cost driver.             |

---

## Decision tree

```
Is the task fully specified (no judgment calls)?
├── YES → can a read-only search answer it?
│         ├── YES → borg-scout (Haiku)
│         └── NO  → borg-grunt (Haiku)
└── NO  → does it require web research from zero?
          ├── YES → borg-researcher (Sonnet)
          └── NO  → is it a blind adversarial review?
                    ├── YES → borg-reviewer (Sonnet/high)
                    └── NO  → is it a single-task with judgment?
                              ├── YES → borg-nanoprobe (Sonnet)
                              └── NO  → claude/general-purpose (Opus — LAST RESORT)
```

---

## Cost reference (mid-2025 API rates, per million tokens)

| Model  | Input  | Output  | Cache read |
|--------|--------|---------|------------|
| Haiku  | $0.25  | $1.25   | $0.025     |
| Sonnet | $3.00  | $15.00  | $0.30      |
| Opus   | $15.00 | $75.00  | $1.50      |

A Haiku subagent is ~12x cheaper on input and ~60x cheaper on output than Opus. Routing a
mechanical grep or a read-only search to Opus instead of Haiku is the single most avoidable
cost in a multi-agent session.

---

## Practical tips

- **Grunt before nanoprobe.** If the orchestrator has already written a precise spec, dispatch
  a grunt. If the spec still needs refinement, write the spec first, then dispatch.
- **Scout before reading.** When you need to locate something before editing, send a scout
  rather than reading files in the main loop — keeps the orchestrator context lean.
- **Parallelize grunts and scouts freely.** They are cheap and stateless; fan-out is encouraged.
- **One nanoprobe per concern.** If a task touches unrelated files or systems, split it into
  multiple nanoprobes rather than one large one.
- **Reviewer always arrives cold.** Do not prime the reviewer with the author's reasoning; the
  adversarial value comes from genuine independence.
- **Reserve Opus for genuine need.** If you can write a clear brief for a specialist, you do
  not need Opus. Spawn Opus only when the task is genuinely open-ended and no brief is possible.
