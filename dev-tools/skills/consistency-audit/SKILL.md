---
name: consistency-audit
description: "Audit a project for cross-surface data consistency. Checks whether all surfaces (pages, MCP tools, API routes, chat/ask features) compute derived values from a shared domain layer or independently. Flags bypasses, duplicated computation, and missing tests. Use when: 'audit consistency', 'check if pages agree', 'are the numbers right', 'find data inconsistencies', 'do the surfaces match', or after shipping a feature that touches multiple pages."
---

# Consistency Audit — Cross-Surface Data Agreement

Systematically verify that every surface in a project computes derived values from a single
domain layer, and that all surfaces agree on the same numbers for the same input.

## The Problem This Solves

When multiple surfaces (dashboard, list page, MCP tool, chat feature, API endpoint) each
compute the same value independently, those computations will eventually disagree. This audit
catches that class of bug — the "different numbers on different pages" problem.

## Core Principle

**The "different numbers" bug is a duplication problem, not a sync problem.** Numbers diverge
because they were computed in two places. Fix the duplication; the sync problem disappears.

---

## The Framework

Every project should follow this three-layer pattern. The naming is domain-appropriate:

| Layer | Purpose | Troth example | Ingle example | Reveal example |
|-------|---------|---------------|---------------|----------------|
| **Domain layer** | Owns all derived computations. One function per concept. All surfaces call it. | `ledger.ts` | `kitchen.ts` | `studio.ts` |
| **Fitness functions** | Structural tests in CI that prevent surfaces from bypassing the domain layer. | ArchUnitTS rules | ArchUnitTS rules | ArchUnitTS rules |
| **Golden fixture tests** | Seed a known state, call every surface, assert they agree. | `consistency.test.ts` | `consistency.test.ts` | `consistency.test.ts` |

### Domain Layer Rules

1. **One function per derived concept.** If two surfaces need "what's left," there's one
   `getWhatsLeft()` function, not two inline computations.
2. **Pages call the domain layer, never the database directly for derived state.** Raw data
   queries (list all transactions for display) can still go through a query layer — the domain
   layer owns *computed/derived* values.
3. **MCP tools call the domain layer.** If an MCP tool and a page disagree, the MCP tool is
   broken.
4. **Chat/Ask features call MCP tools, which call the domain layer.** The chain is:
   Ask → MCP tool → domain layer → database. No shortcuts.

### Fitness Function Rules

Fitness functions are structural tests — they enforce that the codebase's import graph follows
architectural rules. They run in the normal test suite (Vitest/Jest).

**Minimum set (2 rules):**
1. Files in `src/app/` must not import from `src/lib/supabase/` directly (pages don't query DB
   for derived state)
2. MCP tool files must import from the domain layer (tools share logic with pages)

**Implementation:** Use ArchUnitTS or a simple custom test that parses import statements:

```typescript
import { projectFiles } from 'archunit-ts';

it('page components must not query the database directly', async () => {
  const rule = projectFiles()
    .inFolder('src/app/**')
    .shouldNot()
    .dependOnFiles()
    .inFolder('src/lib/supabase/**');
  await expect(rule).toPassAsync();
});
```

If ArchUnitTS is not available, a grep-based test works:

```typescript
it('pages do not import supabase client directly', async () => {
  const { stdout } = await exec(
    "grep -rl 'from.*supabase/server' src/app/ || true"
  );
  expect(stdout.trim()).toBe('');
});
```

### Golden Fixture Test Rules

Golden fixtures verify that all surfaces agree on derived values for a known input state.

**Structure:**
1. A `createTestHousehold()` helper that seeds a complete household state: accounts, balances,
   transactions, recurring items, income sources, allocations.
2. For each derived value, call every surface's function and assert they match.
3. Use exact values (not relational assertions) — AI agents write these well and extend them
   reliably.

```typescript
describe('cross-surface consistency', () => {
  const h = createTestHousehold({
    balances: [{ account: 'checking', cents: 500000 }],
    bills: [{ description: 'Rent', amount_cents: -150000, next_due: '2026-06-01' }],
    transactions: [{ payee: 'Grocery', amount_cents: -5000 }],
  });

  it('what\'s-left agrees across all surfaces', async () => {
    const dashboard = await ledger.getWhatsLeft(h.householdId, h.period);
    const mcp = await runFinanceTool('get_whats_left', { household_id: h.householdId });
    expect(dashboard.totalCents).toBe(350000);
    expect(mcp.totalCents).toBe(350000);
  });

  it('unpaid bills agrees across all surfaces', async () => {
    const dashboardBills = await ledger.getUnpaidBills(h.householdId, h.period);
    const billsPage = await ledger.getUnpaidBills(h.householdId, h.period);
    const mcp = await runFinanceTool('list_bills', { household_id: h.householdId });
    expect(dashboardBills.length).toBe(1);
    expect(billsPage.length).toBe(1);
    expect(mcp.length).toBe(1);
  });
});
```

**When to add a fixture test:** Every time a new surface is added that shows a derived value,
add a line to the consistency test. PR checklist item: "If this page/widget/tool shows derived
data, I added it to the consistency test suite."

---

## Running the Audit

### Phase 1: Discover Surfaces

Scan the project for all surfaces that show data to users:

1. **Pages**: `find src/app -name 'page.tsx' -o -name 'page.ts'`
2. **MCP tools**: `grep -rl 'tools/call\|runFinanceTool\|tool_call' src/`
3. **API routes**: `find src/app/api -name 'route.ts'`
4. **Chat/Ask**: `find src/app -path '*/ask/*'`
5. **Workers**: `find workers/ -name '*.js' -o -name '*.ts'`

For each surface, note what derived values it displays or returns.

### Phase 2: Map Derived Values

Identify every value that is *computed* (not just read from a column):

- Aggregates: totals, counts, averages
- Period-scoped values: "this period's spend," "unpaid bills this period"
- Status computations: "is this bill paid?", "is this alert active?"
- Projections: trajectory, goal progress

For each derived value, trace which surfaces compute it and whether they call the same function.

### Phase 3: Check for Domain Layer

Look for a canonical computation module:
- Does `src/lib/<domain>/` contain a file that exports derived-value functions?
- Do pages import from it, or do they query the database directly?
- Do MCP tools import from it, or do they reimplement the computation?

**Score:**
- **Green**: All surfaces call the same function for the same derived value
- **Yellow**: Most surfaces share, but 1-2 bypass (e.g., alerts.ts queries directly)
- **Red**: Multiple surfaces compute the same value independently (Ingle's MCP pattern)

### Phase 4: Check for Fitness Functions

- Are there structural tests that prevent pages from importing the DB client directly?
- Are there tests that enforce MCP tools import from the domain layer?
- If not: **flag as gap**, propose the minimum 2-rule set.

### Phase 5: Check for Golden Fixtures

- Is there a test that seeds a household and asserts cross-surface agreement?
- If not: **flag as gap**, propose the minimum 5-test set.

### Phase 6: Report

```
## Consistency Audit: [Project Name]

### Surfaces Found
- [N] pages showing derived values
- [N] MCP tools returning derived values
- [N] API routes returning derived values
- [N] other surfaces (chat, workers)

### Derived Values Traced
| Value | Surfaces | Shared function? | Status |
|-------|----------|-------------------|--------|
| what's-left | dashboard, MCP, ask | ledger.getWhatsLeft() | 🟢 |
| unpaid bills | dashboard, bills page, MCP | DIFFERENT functions | 🔴 |

### Domain Layer: [Green/Yellow/Red]
[One paragraph: what exists, what's missing]

### Fitness Functions: [Present/Missing]
[What rules exist, what's needed]

### Golden Fixtures: [Present/Missing]
[What tests exist, what's needed]

### Action Items
1. [Highest priority gap]
2. [Next priority]
3. [...]
```

---

## When to Run This Audit

- **After shipping a feature** that touches multiple pages or adds a new surface
- **Before a plan** that involves derived financial/inventory/scoring data
- **When users report** "different numbers on different pages"
- **Periodically** as a hygiene check (quarterly or after N features shipped)

## AI Agent Integration

This audit is designed to be run by Claude Code. The key design decisions for AI legibility:

- **Exact-value assertions** in golden fixtures (agents write these well: 33-41% of assertions)
- **Structural fitness functions** that produce build failures (agents self-correct on failures)
- **Grep-based checks** for import violations (no special tooling needed)
- **One fixture factory** with a clear interface (agents extend by adding parameters)

Avoid:
- Relational assertions (`A === B`) without exact expected values — agents may satisfy by
  making both wrong
- Complex property-based testing unless the domain arbitrary is well-defined
- Documentation-only rules ("please don't bypass the domain layer") — agents respond to
  build failures, not prose

---

## References

- Brainstorm: `docs/brainstorms/2026-05-29-consistency-verification-framework.md` (Troth)
- Research: Agoda FINUDP (canonical computation layer), arXiv 2602.07900 (AI test patterns),
  ArchUnitTS (fitness functions), Slack Engineering (golden testing)
