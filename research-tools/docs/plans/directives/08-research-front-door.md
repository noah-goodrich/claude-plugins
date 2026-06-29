# Directive 08: Research Front Door (`/research` mode router)
*Parent plan: 2026-05-27-plugin-marketplace-consolidation*
*Filed: 2026-06-29*

## Objective

Make `research` the single research front door. The former `deep-research` skill is renamed to
`research` and gains a Phase-0 **mode selector** — **evidence | decision-design | hybrid**.
`deep-research` and `brainstorm` survive as thin alias skills so their slash commands keep working.
This is a router plus three self-contained mode sections — **not** one merged pipeline.

- **evidence** — the original deep-research citation-synthesis pipeline, UNCHANGED. Only mode that
  arms the executable citation gate.
- **decision-design** — NEW. Walled-off prior-work catalog (don't anchor) → parallel from-zero
  research tracks (delegate to `borg-researcher`) → neutral candidate options → contradiction forge
  → 5-persona council → BLIND adversarial review of the recommendation (delegate to `borg-reviewer`,
  no-refeed) → recommendation. Self-enforced honest gate: if the blind review did not run, stamp
  `NOT design-reviewed`.
- **hybrid** — evidence then decision-design, evidence synthesis fed in as load-bearing input.

The former `brainstorm` council/option/contradiction-forge logic is absorbed as decision-design's
internal evaluation step. `brainstorm` is deprecated to a thin alias.

## Acceptance Criteria

1. **One front door, aliases preserved.** `skills/research/SKILL.md` has `name: research`;
   `skills/deep-research/SKILL.md` and `skills/brainstorm/SKILL.md` are thin aliases that delegate
   into it. — Verify: `ls skills/research/SKILL.md`; `wc -l` of each alias < 30 lines.
2. **Phase-0 mode selector.** Evidence | decision-design | hybrid chosen before any other work. —
   Verify: `grep -n 'Phase 0: Mode Selection' skills/research/SKILL.md`.
3. **Evidence pipeline untouched (regression).** Evidence phases + citation gate substantively
   unchanged. — Verify: `bash hooks/test/run-tests.sh` passes (all sections, including the new §5).
4. **Citation gate scoped (key regression).** Evidence/hybrid arm `.gate-armed` and pass the
   verifier; decision-design (no marker) is NOT killed; the Stop-hook transcript regex matches
   `research`. — Verify: §5 of `run-tests.sh` (transcript-armed `research`, no marker → rc=0,
   no block decision).
5. **decision-design delegates + honest gate.** Research → `borg-researcher`; recommendation →
   blind `borg-reviewer`; `NOT design-reviewed` stamp on a missed review. — Verify: `grep -n
   'borg-researcher\|borg-reviewer\|NOT design-reviewed' skills/research/SKILL.md`.
6. **Builds clean.** `./build-plugins.sh` produces `dist/research-tools.plugin`; version bumped. —
   Verify: build output lists research-tools at the bumped version.

## Scope Boundaries
- NOT touching evidence-pipeline internals or migrating its Phase 3.5 verifier to `borg-reviewer`.
- NOT merging the two pipelines — router + distinct sections reusing the agents.
- NOT renaming the hook files (only the regex inside `deep-research-stop.sh`).

## Ship Definition
Branch → PR → `hooks/test/run-tests.sh` green → version bump → `./build-plugins.sh` → merge.
Cowork UI reinstall of `dist/research-tools.plugin` remains a manual human step.
