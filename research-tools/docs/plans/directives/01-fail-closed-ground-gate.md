# Directive 01 — Fail-Closed Ground Gate (HALF 1 MVV)

**Priority:** 01 (lead) · **Axis:** (b) Methodological depth — make verify/ground real and fail-closed
**Feasibility:** High · **Status:** Ready for implementation

---

## Goal

Ship a no-model verifier script run by a `Stop` hook that physically blocks a `deep-research` report from being
presented as fact-checked until six falsifiable on-disk integrity facts pass — converting the honor-system
verification manifest into a machine assertion that fails the deliverable when skipped.

---

## Context (why)

The audit's single highest-impact finding is **Pattern 2 — honor-system enforcement: the design cannot tell honored
from skipped** (`audit.md:327-341`). Every gate that matters is self-attested, so under load agents honor the cheap
gates (the §1–§7 file structure, present 5/5) and route around the expensive one (blind verification, honored 0/5).
The Phase 3.5 gate **has never once failed across 7+ runs** (`audit.md:215-225`) — a control that never trips is
either unnecessary or broken, and here it is broken: it is self-certification, not adversarial verification.

The corpus proves the leak is live, not theoretical:

- **troth** (65 cards, the largest deliverable) shipped with **zero** `Verified Quote` sections, **no**
  `verification-report.md` on disk, and **no** failure-rate numbers in §6 — yet wears the full §1–§7 template
  (`audit.md:28-33,128-135`).
- **reveal** scored its s11 card `inaccessible` on the strength of a `cached/partial` flag the card never carried,
  holding the failure rate at 0% when the honest rate is 25% (`audit.md:35-40,146-154`).
- **agent-teams** and **personalization** both openly state verification was self-verification by the card author
  (`audit.md:18-26,113-125`) — a verifier holding the source in its own context cannot catch a quote it paraphrased.

SOTA finding §3 of the analysis names the matching root cause: **"if the model checks itself, you have built a
confident hallucination machine"** — verification requires an **EXTERNAL signal**, and a blind self-grading critic
"often fails to help and can make answers worse" (`analysis.md:33-35,204-206`; Huang et al. 2024, Theme G). This
directive imports that finding as the product spine: the load-bearing adversary is a **no-model script** that sees
on-disk facts an LLM self-check cannot launder into a pass.

This is the audit's recommendation #1 and #2 in one mechanism (`audit.md:404-415`). It is the prerequisite every
other directive depends on — distribution amplifies whatever ships, and invention on a self-certifying substrate
manufactures pseudo-inventions. The foundation must hold first.

The verifier MUST be written to read a **ground-ledger-shaped artifact** so it becomes the seed of a future shared
grounding substrate (Option E's `ground-gate.sh`) without a big-bang rewrite.

---

## Commands / Interfaces (what gets built)

### New files

- **`hooks/deep-research-verify.sh`** — net-new (no `hooks/` directory exists yet; this is the first). A no-model
  bash script. Zero model calls, deterministic. Takes a research-output directory (or discovers the most recent
  `docs/research/` deliverable in the repo). Reads source cards + `verification-report.md` and asserts the six facts
  below. Exits **non-zero** on any failure. Follows the borg-collective hook convention (executable, `set -euo
  pipefail`, no `$()` in compound one-liners per project style). Emits machine-readable status lines so the Stop hook
  can compose a blocking message.
- **`hooks/deep-research-stop.sh`** — net-new. A `Stop` hook that invokes the verifier; on non-zero exit it injects a
  blocking message — `NOT fact-checked — verification gate failed: <reason>` — and refuses to let the deliverable
  be presented as `PASS`. On zero exit it permits presentation and prints the honest badge string (see Boundaries).
- Hook registration wired into the plugin's hook config (the `.claude-plugin/` plugin manifest) so the `Stop` hook
  fires for `deep-research` runs.

### The six falsifiable assertions (the MVV core)

The verifier MUST assert exactly these, and fail non-zero on any:

1. **`verification-report.md` exists** at `docs/research/[date]/verification-report.md`
   (resolves the troth no-report bypass, `audit.md:128-135`).
2. **§6 carries three numbers** — sample N (out of M total, with %), failure count, and a band string
   (`SKILL.md:259-266`, `audit.md:137-144`).
3. **The band string is canonical** — exactly one of `≤5%` / `>5%–10%` / `>10%`; a non-canonical band such as
   personalization's `≤20% partial-or-failed at sample size 5` fails (`SKILL.md:238`, `audit.md:137-144`).
4. **Recorded verifier agent/session ID != synthesis agent ID** — the report must record a distinct verifier ID; a
   matching or absent ID fails (resolves non-blind verification in 3/3 reports, `audit.md:113-125`).
5. **Every card has the literal `Access status:` enum line AND a `## Verified Quote(s)` heading** — a card missing
   either auto-fails; a freeform "Last Fetched / Assessment Confidence" line (reveal s11) does not satisfy the enum
   (`source-card-template.md:45,65-72`; `audit.md:156-163`).
6. **A card corrected during verification counts as a FAILURE** — correction-then-recount is forbidden; the report's
   per-card outcome table must not record "corrected then verified" as `verified`
   (resolves the never-failing gate, `audit.md:215-225`).

### Ground-ledger shaping (forward-compat requirement)

The verifier's **input contract** MUST be modeled as a ground-ledger-shaped artifact: it reads per-card grounding
records (claim/quote hash, access status, verifier ID, outcome, timestamp) as if from a `ground.jsonl`-style ledger,
even when those facts are sourced from the existing report + cards today. This is a load-bearing requirement, not a
nicety: it is what lets Directive 04 evolve the script into a shared substrate without a rewrite.

### Skill changes (`deep-research/SKILL.md`)

- Phase 3.5 records a **verifier agent/session ID distinct from the synthesis agent** in the report header
  (`SKILL.md:192-201,229-238`).
- Manifest item for the verification report (`SKILL.md:396-399`) is annotated to note the gate is now executable —
  the box is checked by the script, not the agent.
- **Honest fallback:** if Task-tool spawning is unavailable, the skill stamps the deliverable `UNVERIFIED — self-check
  only` in §6 and the manifest, and the script exits non-zero on any attempt to print `Gate result: PASS` without a
  distinct verifier ID (`audit.md:122-125,411-415`).

---

## Testing (how to verify it works)

Use the existing corpus as fixtures — these are real artifacts the gate MUST catch:

1. **troth** (`troth/docs/research/household-finance-research.md`, 65 cards, 0 quote sections, no report) → the gate
   MUST fail on assertion 1 (no report) and assertion 5 (no quote headings).
2. **reveal** (`reveal/.../2026-05-31-portrait-pipeline/`) → the gate MUST fail on assertion 4 (no fresh-agent ID),
   assertion 5 (s11 missing the `Access status:` enum), and the retroactive `cached/partial` reclassification.
3. **A synthetic PASS fixture** — a small deliverable with a real report, a distinct verifier ID, canonical band,
   enum + quote heading on every card, and no corrected-then-recounted card → the gate MUST exit 0 and emit the
   honest badge.
4. **Cosmetic-nit negative test** — a deliverable that is genuinely sound but has a trivially-different enum
   *spacing/casing* that is still semantically the literal enum → the gate MUST **NOT** reject (see Boundaries).
5. **Stop-hook integration test** — confirm that on a non-zero verifier exit, the Stop hook injects the blocking
   `NOT fact-checked` message and the run cannot present as `PASS`.
6. **Honest-fallback test** — simulate Task-tool unavailable → confirm the deliverable is stamped `UNVERIFIED —
   self-check only` and never prints `Gate result: PASS`.

All testing/linting runs inside the devcontainer via `drone exec`, never natively on the host.

---

## Boundaries (what must never happen / out of scope)

- **NEVER reject on cosmetic enum-format nits.** Hard-cap rejection to the six genuine integrity facts. A single
  false-positive rejection on a cosmetic detail trains permanent bypass at the moment of least commitment (User
  Advocate's lethal-failure-mode guard). When in doubt, the script passes.
- **NEVER oversell the badge.** The badge MUST read `a distinct verifier agent ran and the files prove it` —
  explicitly **NOT** "blind," **NOT** "true," **NOT** "cannot lie." The script is **context-blind, not model-blind**:
  it proves a distinct agent ID was recorded and a quote exists on the page; it cannot prove the agent's mind was
  uninfluenced (out-of-band hint-feeding survives). Honest public framing of this limit is a **ship requirement**,
  not optional.
- **HALF 2 is OUT OF SCOPE for this directive.** No testability classifier, no evidence-floor blocking, no §2
  NO-PRIMARY-EVIDENCE banner, no confirmation-skew gate — those ship as a **non-blocking banner first** under
  Directive 03. The six deterministic file facts are the only thing that blocks initially.
- **The git/mtime cached/partial provenance check is OUT OF SCOPE** — brittle on rebased/squashed/fresh histories.
  The reveal-s11 reclassification game is closed probabilistically later (Directive 02), not here.
- **No statement-level entailment (MiniCheck) in the MVV** — deferred to a later increment so "verified" eventually
  means grounding, not citation presence; the six-assertion core ships first.
- **No methodology rewrite.** Keep the Phase 3.5 prose verbatim; the change is enforcement, not redesign
  (`audit.md:471-474`).
- **No new runtime, model, or MCP.** Pure markdown + bash + the existing Task tool. Fully portable.

---

## Acceptance Criteria

- [ ] `hooks/deep-research-verify.sh` exists, is executable, makes zero model calls, and exits non-zero on any of the
      six assertion failures.
- [ ] Assertion 1: fails when `verification-report.md` is absent.
- [ ] Assertion 2: fails when §6 omits any of sample N, failure count, or band string.
- [ ] Assertion 3: fails on a non-canonical band string; passes only on `≤5%` / `>5%–10%` / `>10%`.
- [ ] Assertion 4: fails when the verifier agent/session ID is absent or equals the synthesis agent ID.
- [ ] Assertion 5: fails when any card lacks the literal `Access status:` enum line OR the `## Verified Quote(s)`
      heading.
- [ ] Assertion 6: a card recorded as corrected-then-verified counts as a FAILURE for the rate.
- [ ] `hooks/deep-research-stop.sh` (`Stop` hook) injects a blocking `NOT fact-checked` message on non-zero exit and
      refuses `PASS`; the hook is registered in the plugin manifest.
- [ ] Run against troth → FAILS (assertions 1 and 5).
- [ ] Run against reveal → FAILS (assertions 4 and 5, plus retroactive reclassification).
- [ ] Run against a synthetic compliant fixture → PASSES and emits the honest badge.
- [ ] Cosmetic-nit fixture → does NOT reject.
- [ ] Honest-fallback: Task-tool-unavailable run stamps `UNVERIFIED — self-check only` and never prints `Gate result:
      PASS`.
- [ ] The badge string certifies `a distinct verifier agent ran and the files prove it` and explicitly disclaims
      "blind" / "true" — verified by the badge text and a README note.
- [ ] The verifier reads its inputs through a ground-ledger-shaped contract (per-card records: hash, access status,
      verifier ID, outcome, timestamp), documented in a comment header as the seed of the future shared substrate.
- [ ] `deep-research/SKILL.md` Phase 3.5 records a distinct verifier ID and documents the executable gate + honest
      fallback.
- [ ] All tests pass inside the devcontainer via `drone exec`.

---

## Estimate

**1.5–2 sessions.** ~1 session: the no-model verify script + Stop hook + exit-code semantics + ground-ledger-shaped
input contract. ~0.5–1 session: SKILL.md Phase 3.5 verifier-ID recording + honest fallback, plus backfilling and
testing against the troth/reveal fixtures.

---

## MVV (minimum viable value)

The no-model verifier run by a `Stop` hook asserting **just the six things**: (1) `verification-report.md` exists,
(2) §6 has the three numbers, (3) the band string is canonical, (4) recorded verifier ID != synthesis ID, (5) every
card has the enum + Verified Quote heading, (6) a card corrected during verification counts as a failure. Hard-capped
to these genuine integrity facts — never rejecting on cosmetic nits.

That single artifact would have **FAILED troth** (no report) **and reveal** (no fresh agent, missing s11 enum,
retroactive `cached/partial`) on the day they shipped — felt value on real corpus fixtures, not theater. Written to
read a ground-ledger-shaped input so it becomes Directive 04's ground-gate later without a rewrite.
