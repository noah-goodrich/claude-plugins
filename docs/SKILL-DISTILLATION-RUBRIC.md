# Skill Distillation Rubric

Generated: 2026-07-07 · Author: Fable 5 · Purpose: cut token weight from heavy `SKILL.md` files without
weakening a single enforcement gate. A skill is loaded into context every session that triggers it (cost) AND
obeyed by whatever model is running (behavior). Bloat is paid twice — in load cost and in the over-generation
that vague prose invites. This rubric is the durable method; the worked application to `research/SKILL.md`
(the 1001-line elephant, ~27% of all skill content) is at the bottom.

## The method

### Cut (dev-history + redundancy — pure token weight, zero operational value to the running agent)

1. **Provenance citations.** `(audit.md:175-181)`, `Directive 01/02/03/04`, `(troth: 65 cards, no verification)`,
   `personalization's 9% sample`, `eating-out (27:3)`. These explain WHY a rule exists to a maintainer. The
   running agent needs the RULE, not its genealogy. Move rationale to a `CHANGELOG.md` / `docs/` if it must live
   somewhere; delete it from the skill.
2. **Repeated re-explanation.** If the same rule is stated in the phase, again in an "executable gate"
   subsection, again in the manifest, and again in a fallback note, keep ONE canonical statement and reference
   it. The citation gate in `research/SKILL.md` is explained ~4 times.
3. **Meta-commentary about the framework.** "Promotion path (documented, not done here)", "ground-ledger-shaped
   input contract", "why the ledger, not just the gates" essays. Design notes, not agent instructions.
4. **Hedge and throat-clearing.** "It is worth noting that", "deliberately", "importantly", "as a rule of
   thumb" — delete; state the rule flatly.
5. **Motivational narration.** Prose that sells the reader on why the discipline matters. One line max; the
   agent already decided to run the skill.

### Preserve (load-bearing — cutting these weakens a gate or breaks a hook)

1. **Exact strings a hook/matcher checks** — verbatim, character-for-character. These are contracts, not prose.
2. **Operational instructions** — the actual steps, thresholds, and structures the agent must produce.
3. **Enumerations a validator checks** — field names, section orderings, allowed values.
4. **Numeric thresholds and their direction** — `≥30%`, `≤5%`, `min 3`, `≥75`.
5. **The one canonical statement** of each rule (after de-duping the repeats).

### Precision principles (make what remains deterministic)

- **Imperative, not discursive.** "Write N. Verify M. Gate at ≤5%." not "You will want to make sure that you
  verify roughly a third of the cards."
- **Tables and lists over paragraphs** for any enumerable rule — cheaper to load, harder to misread.
- **State thresholds as numbers with a comparator**, never "a handful" / "most" / "a reasonable sample".
- **One instruction per line** where a validator or gate reads it.
- **Name the exact-string contracts as quoted literals** so a distiller (or a future editor) sees they are
  untouchable.

## Safety protocol (mandatory for any hook-coupled skill)

A skill wired to an executable hook (like `research/SKILL.md` ↔ `hooks/deep-research-verify.sh`) MUST be
distilled against a **preserve-verbatim list** extracted from the hook. Procedure:

1. Read the hook; list every literal string and every assertion's required field/threshold.
2. That list is the preserve-verbatim set — each item must survive the rewrite unchanged.
3. After rewriting, **grep the distilled file for every preserve-verbatim item**; a missing item is a failure,
   fix before shipping. This is the gate-4 check for a distillation.
4. Ship the distilled version as a `*.distilled.md` proposal first; swap it in only after the grep passes and a
   diff review confirms no operational instruction was dropped. The live skill is not clobbered on faith.

---

## Worked application — `research/SKILL.md` (1001 → target ~450 lines)

### Bloat inventory (CUT)
- Every `(audit.md:NNN)` / `Directive NN` / named-example provenance tag throughout (dozens of instances).
- The 3 repeat explanations of the citation gate — keep the Phase 3.5 statement, delete the restatements in the
  "executable gate" essay, the manifest, and the honest-fallback preamble (keep the fallback RULE, cut its
  re-explanation).
- The "Promotion path (documented, not done here)", "Ground-ledger-shaped input contract", "Anti-gaming note",
  and "Boundaries" essays — these describe the hook's internals; the agent doesn't act on them.
- The W1/W2 promotion-path narration — keep the W1 banner rule + W2 skew rule, cut the "stays advisory until…"
  history.
- Motivational lines throughout ("A defensible-but-unreadable report is a failed deliverable" can stay as one
  line; the surrounding sell can go).

### PRESERVE-VERBATIM list (these exact strings/rules MUST survive unchanged — the hook checks them)
- Banner, exact: `NO PRIMARY EVIDENCE — all findings are literature-derived predictions`
- Card field label, exact: `Access status:` (value ∈ `live` / `cached/partial` / `inaccessible`)
- Card heading, exact: `## Verified Quote(s)`
- Card field, exact: `Perspective category:` with value ∈ {`Academic`, `Institutional`, `Practitioner`,
  `Boots-on-the-ground`, `Contrarian`} (no hybrids)
- Failure-rate band, canonical trio: `<=5%` / `>5%-10%` / `>10%`
- Report IDs, both required and distinct: `Synthesis agent ID:` and `Verifier agent ID:`
- Sampling rule: `≥30%` of cards, `rounded up`, `min 3`; all cards if `< 10` total
- Verification gate threshold: failure rate `>5%` blocks Phase 4
- Fallback stamps, exact: `UNVERIFIED — self-check only` and `NOT INDEPENDENTLY VERIFIED`
- §6 must report the three numbers: sample `N of M (%)`, failure count, band string
- Inclusion cut rule: exclude `≥1` source OR name the lowest-scoring source that cleared the bar
- Inaccessible cap: `~30%` of sample → else stamp `low-confidence`
- Corrected-then-verified is forbidden (a corrected card counts as `failed`)
- Gate-arm marker: write the deliverable dir abs-path to `docs/research/.gate-armed` (Phase 3.1); NOT on rapid
- Deliverable structure, exact order + headings: `## 1. Recommendations` · `## 2. Summary` · `## 3.` (framework,
  optional) · `## 4. Analysis` · `## 5. Research` · `## 6. Methodology` · `## 7. Bibliography`
- Reading-Deliverable Standard, all four clauses: first line `Generated: YYYY-MM-DD`; ELI10 + Glossary +
  `noah-voice` then `ai-scoring` ≥ `75` (record `AI-scoring: NN/100`); epub by default via pandoc; markdown in
  repo, epub to `~/Documents/Claude/<Project>/`
- Mode router: `evidence` / `decision-design` / `hybrid` + Phase 0 selection
- Rapid vs full tier: rapid = `§1 + §2 + §5 + short methodology`, stamped `UNVERIFIED — self-check only`; full =
  §1–§7 + independent Phase 3.5 verifier
- Decision-design D1–D6, incl. the blind `borg-reviewer` review and the `NOT design-reviewed` stamp rule
- The card-field skeleton and the lazy-load reference map (as tables)
- Confirmation-skew rule: `>3:1` agree:disagree → falsification query (Phase 2) + `### Steel-man the contrarian`
  (Phase 4)

### Verification (gate 4 for this distillation)
After the distilled draft exists, grep it for each preserve-verbatim literal above; every one must be present.
Then diff against the original section-by-section confirming no operational STEP was dropped (only rationale /
repetition). Only then swap `SKILL.distilled.md` → `SKILL.md`.
