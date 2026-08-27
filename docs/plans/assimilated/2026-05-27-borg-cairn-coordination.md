# Directive — borg ↔ cairn Coordination & Source-of-Truth

**Archived:** ⚠️ ASSIMILATED AS HALF-SUPERSEDED 2026-08-27. Decision 2 (cairn optional) is dead — cairn was
decommissioned 2026-08-08 and the `cairn_available()` guard this document prescribes was never written in either
repo. Decision 1 (borg-collective is the source of truth) is still in force, and archiving is only safe because
it now has a stronger home: the repo-root `CLAUDE.md` that shipped 2026-08-26 in
[#47](https://github.com/noah-goodrich/claude-plugins/pull/47). Retained for the PR
[#4](https://github.com/noah-goodrich/claude-plugins/pull/4) provenance, which is recorded nowhere else. Do not
read the cairn half as standing guidance.

**Created:** 2026-05-27
**Scope:** `borg-collective` plugin within this repo, the standalone
`~/dev/borg-collective` repo, and the `~/dev/cairn` graph-backend repo
**Status:** Confirmed 2026-05-27 · **HALF SUPERSEDED — reconciled 2026-08-27.**

> Decision 1 (source-of-truth) is **IN FORCE** and mechanized in two scripts plus this repo's root
> `CLAUDE.md`. Decision 2 (cairn optional) is **DEAD** — cairn was decommissioned 2026-08-08 and the
> `cairn_available()` guard this directive prescribes was never written in either repo. Both Open questions
> are resolved in fact. See **Reconciliation — 2026-08-27** at the bottom for the commands and their output.

## Why

After PR #4 (`234cdab`), borg-collective exists in two places:

- `~/dev/claude-plugins/borg-collective/` — the publishable plugin with
  manifest, hooks, and 10 skills, packaged into
  `dist/borg-collective.plugin`.
- `~/dev/borg-collective/` — the original standalone repo with research
  branches (`research/agent-teams-2026-05-23`) and its own skills directory.

Both repos can drift. Without a stated source-of-truth, edits land in
whichever repo the active session opens first, and the published `.plugin`
artifact loses sync with the canonical skills.

Separately, cairn (the optional graph backend at `~/dev/cairn`) provides
knowledge-graph storage that several borg skills (`borg-search`,
`borg-link`, `borg-next`) call into when present. The `cairn-mcp-phase1`
branch is approaching merge. borg skills need to know whether to require,
prefer, or treat cairn as fully optional.

> *Historical as of 2026-08-27. This paragraph was true when written; it is no longer a description of the
> system. cairn was decommissioned 2026-08-08. Of the three skills named here as cairn callers, `borg-search`
> no longer exists at all (`ls ~/dev/borg-collective/skills/` — 17 skills, none of them `borg-search`), and
> `borg-link` and `borg-next` survive with their cairn calls removed. The "require / prefer / optional"
> question it poses has no live answer — see the note under Decision 2.*

## What

Two coordinated decisions:

1. **Source-of-truth:** `~/dev/borg-collective/` is the canonical home for all
   skill files and hooks. `claude-plugins/borg-collective/` distributes the
   **publishable subset** — it never originates edits. See the privacy boundary
   below for what is and isn't included in the plugin.
2. **cairn coupling:** borg skills treat cairn as **optional**. If
   `~/.cairn/` is present, skills use it for graph storage; otherwise they
   degrade gracefully to filesystem-only mode. No skill hard-requires cairn.

   > **DEAD 2026-08-27 — superseded by removal, never by implementation.** cairn was decommissioned
   > 2026-08-08 (Phase 2 of
   > `~/dev/borg-collective/docs/plans/directives/2026-08-08-cairn-decommission-and-unconditional-block.md`).
   > `~/.cairn/` does not exist, no cairn container runs, `cairn`/`cairn_test` were dropped from dev-postgres,
   > and `which cairn` returns nothing. `grep -rln cairn ~/dev/borg-collective/skills/` returns **zero files** —
   > the five skills that called cairn (`borg-search`, `borg-link`, `borg-link-up`, `borg-recon`,
   > `fable-reviewer`) were unwired, not made conditional. The literal end state ("no skill hard-requires
   > cairn") is true, but only because there is no cairn and no call site — not because the graceful-degradation
   > design in "How to apply" was ever built.

Decision confirmed 2026-05-27. Source: original Dispatch session `f9ef8d07`
(2026-05-24) that created the plugin — the instruction explicitly named
`~/dev/borg-collective/` as the source repo and defined an exclusion list
(CLI machinery, registry, research docs, private paths) as the privacy boundary.

## How to apply

This record has no acceptance-criteria section. The rules below are its de-facto criteria, and each now
carries a verdict from the 2026-08-27 reconciliation.

**Editing borg-collective skills:**
- [x] Edit in `~/dev/borg-collective/skills/<skill>/SKILL.md` — that is the
      source of truth.
- [x] Never edit directly in `~/dev/claude-plugins/borg-collective/skills/` —
      it is a derived copy and changes will be overwritten on the next promote.

  *IN FORCE and mechanized three ways. (1) `~/dev/borg-collective/scripts/build-plugin.sh:4-5` declares
  "Source of truth: `$BORG_ROOT`" → "Plugin target: `$HOME/dev/claude-plugins/borg-collective/`". (2)
  `scripts/sync-plugin.sh:8-9` declares the same direction and is one-way by construction — its comment at
  :16-17 notes "there is no `--delete` — this is a one-way source→distro refresh, not a true mirror", and both
  loops skip targets that do not already exist (`:55`, `:77`). (3) This repo's root `CLAUDE.md` now says it in
  prose: "`borg-collective/` is generated. Never edit it here." That file shipped 2026-08-26 in PR #47 (merge
  commit `6466aae`) — `git merge-base --is-ancestor 6466aae origin/main` → LANDED. Note the local `main` ref
  in this worktree is one commit behind `origin/main`, so the same check against bare `main` falsely reports
  NOT-ON-MAIN; `origin/main` is the honest reference.*

  *One correction to the rule as written: `CLAUDE.md` names **three** hand-maintained exceptions that are NOT
  generated and may be edited in the distro — `borg-collective/README.md`, `borg-collective/INSTALL.md`, and
  `borg-collective/hooks/test/`. The blanket "never edit here" is now "never edit here except those three".*

  *Drift at reconciliation time is **not zero**, contrary to an earlier reading.
  `PLUGIN_SKILLS_DIR=<worktree>/borg-collective/skills scripts/sync-plugin.sh --dry-run` reports "would sync:
  borg-link" and "would sync: borg-recon". Both are **source-ahead** (7 and 11 lines present only in the
  source copy, against 2 and 3 only in the distro), i.e. unpromoted forward flow from the in-progress
  `borg-link` AC2 work in the source repo (`662f4ba`, `eeee7a9`) — not distro-originated edits. The
  source-of-truth direction is intact; two skills are simply awaiting a build.*

**Writing new borg skills:**
- [x] Write and iterate in `~/dev/borg-collective/` (research branch if needed).
- [ ] When stable and safe to distribute (passes the privacy boundary check below),
      copy into `~/dev/claude-plugins/borg-collective/skills/` and rebuild
      `dist/borg-collective.plugin`. Reference the source commit in the promotion
      PR.

  *First bullet IN FORCE — the source repo is where skills are authored, and the research branch named in
  References still exists (`git -C ~/dev/borg-collective branch -a` →
  `remotes/origin/research/agent-teams-2026-05-23`).*

  ***Superseded** on the second bullet, in three particulars. (a) "Copy into … and rebuild" is now a single
  automated step: `~/dev/borg-collective/scripts/build-plugin.sh`, which subsumed `sync-plugin.sh` and also
  regenerates `hooks.json`, `plugin.json`, and the marketplace entry (`build-plugin.sh:7-13`). Hand-copying is
  no longer the procedure. (b) "Rebuild `dist/borg-collective.plugin`" no longer describes how the plugin is
  consumed: root `CLAUDE.md` records that `noah-local` is a **directory source** pointing at the working tree,
  so plugins load live from the checked-out branch and "`dist/*.plugin` exists only to hand plugins to another
  machine; nothing local reads it." (c) "When stable and safe to distribute" no longer gates anything per
  skill — the build promotes **all** skills unconditionally (`build-plugin.sh:8`, "skills/ — all SKILL.md
  files"), and source and distro both hold 17 skills. Kept unchecked because the promotion gate it describes
  does not exist as written.*

**Privacy boundary — what must NOT be promoted to claude-plugins:**
- [ ] Skills that reference private paths, JIRA configs, or work-machine specifics
- [ ] Skills or hooks that require the `borg`/`drone` CLI at runtime
- [x] Any content flagged in `PRIVACY-AUDIT-2026-05-23.md`

  ***Superseded** on the first two bullets — the exclusion list was replaced by guards and self-containment,
  not enforced as an exclusion. There is no per-skill privacy filter anywhere in the build: `grep -n
  "PRIVACY\|EXCLUDE\|publishable"` over `scripts/build-plugin.sh` hits only the file's own header line, and
  the build promotes every skill (17 in source, 17 in distro). The CLI bullet was answered structurally
  instead: the build's "self-containment contract" (`build-plugin.sh:15-21`) inlines `lib/borg-hooks.sh` into
  each hook and prepends `command -v borg >/dev/null 2>&1 || exit 0`, so CLI-dependent hooks **are** promoted
  and simply no-op off-machine. Verified: 12 of 12 hooks under `borg-collective/hooks/*.sh` contain that
  guard, and the distro carries no `lib/` at all. The rule as written ("must NOT be promoted") is therefore
  false of current practice; the privacy intent survives, the mechanism does not.*

  *Third bullet holds: `PRIVACY-AUDIT-2026-05-23.md` is still tracked at the repo root
  (`git ls-tree --name-only origin/main` → `PRIVACY-AUDIT-2026-05-23.md`), and nothing it flags appears in the
  distributed subset.*

**cairn integration in borg skills:**
- [ ] Wrap cairn calls in a `cairn_available()` check.
- [ ] On absence, log a single-line notice and continue with filesystem
      fallback. Do not error.
- [ ] Do not import cairn libraries at module top-level — defer to lazy import
      inside the availability check.

  ***Superseded — all three. Never implemented, and now unimplementable: there is no cairn to guard.***
  *`grep -rn "cairn_available" ~/dev/borg-collective ~/dev/claude-plugins` returns exactly **two** hits, both
  restatements of the intent rather than code: this directive's own line above, and
  `.borg/knowledge/decisions/20260527-borg-collective-source-of-truth-resolved.md:28`, the knowledge atom that
  paraphrases this directive. **Zero call sites, zero definitions, in either repo, in any language.** The
  guard function was written down twice and coded zero times.*

  *What replaced it: outright removal. Phase 2 of the 2026-08-08 cairn-decommission directive unwired the five
  cairn-calling skills and repointed them at `.borg/knowledge/` + `.borg/checkpoints/` via grep. The only
  surviving `cairn` strings under `borg-collective/` are documentary — two comment blocks in
  `hooks/borg-link-down.sh:563,576-577` and `hooks/borg-memory-read-log.sh:7,10,33` that cite the decommission
  as rationale, plus the hand-maintained `README.md`/`INSTALL.md` and a bats fixture. No executable cairn call
  remains. Do not re-open these as TODOs.*

## Open questions

Both are resolved in fact as of 2026-08-27. Neither needs a decision from anyone.

- ~~Should `~/dev/borg-collective/` be archived once the plugin stabilizes,
  or kept as the long-term research repo?~~
  **RESOLVED — kept, and promoted from "research repo" to the load-bearing source of truth.** It is not
  archivable: it owns `scripts/build-plugin.sh`, which generates the distributed plugin, and it is under
  active development (`662f4ba`, `eeee7a9`, `cde4b55` — the in-progress `borg-link` AC2 renderer work).
  This repo's root `CLAUDE.md` codifies the dependency: "The source of truth is `~/dev/borg-collective`, and
  `scripts/build-plugin.sh` in that repo generates this copy."
- ~~When cairn ships v0.1.0 (per `~/dev/cairn` PROJECT_PLAN), should any
  borg skills upgrade to **prefer** cairn (warn on absence) rather than
  remain fully optional?~~
  **MOOT — cairn was decommissioned before the question could be reached.** It shipped no v0.1.0 that
  survives; the repo's last commits are its own teardown (`bf05c96 docs: assimilate the cairn decommission
  plan`, `b26a9d9`, `39b84c4`). The strategic review that killed it measured cross-project restatement at
  0.4% against a null baseline. "Prefer cairn" is not a live option and must not be revived from this
  document.

## References

- `~/dev/claude-plugins/borg-collective/.claude-plugin/plugin.json` — verified present 2026-08-27.
- `~/dev/borg-collective/` (research branch
  `research/agent-teams-2026-05-23`) — branch still present on `origin`.
- `~/dev/cairn/` (`feat/cairn-mcp-phase1-2026-05-24`) — repo decommissioned 2026-08-08; retained for history
  only. Its corpus was exported to per-repo `.borg/knowledge/` before teardown.
- PR #4 (`234cdab Extract borg-collective plugin`) — verified MERGED 2026-05-27T03:52Z; `234cdab` is an
  ancestor of `origin/main`.
- Added 2026-08-27: [#47](https://github.com/noah-goodrich/claude-plugins/pull/47) (`6466aae`) — root
  `CLAUDE.md`, which gives Decision 1 a home in this repo.
- Added 2026-08-27: the directive that killed Decision 2 —
  `docs/plans/directives/2026-08-08-cairn-decommission-and-unconditional-block.md` in `~/dev/borg-collective`.

---

## Reconciliation — 2026-08-27

Verdict: **half alive.** Decision 1 is in force and better mechanized than when this was written. Decision 2
is dead. No claim in the original text was fabricated — every commit and PR it cites is real and landed — but
the cairn half now describes a system that no longer exists, and the `cairn_available()` design it prescribes
was never built.

**Method note that matters for anyone re-running this.** The local `main` ref in the reconciliation worktree
was one commit behind `origin/main`, and that one commit was `6466aae` — the CLAUDE.md merge. Checking
`git merge-base --is-ancestor 6466aae main` returns **NOT-ON-MAIN**, which would have recorded a shipped PR as
unmerged. `origin/main` is the correct reference. Verify the local ref is current before trusting an ancestry
check:
`git rev-list --left-right --count main...origin/main` → `0  1`.

Commands run and what they returned:

| Check | Command | Result |
|---|---|---|
| PR #4 merged | `gh pr view 4 -R noah-goodrich/claude-plugins` | `MERGED`, `2026-05-27T03:52:45Z` |
| `234cdab` landed | `git merge-base --is-ancestor 234cdab origin/main` | LANDED |
| PR #47 merged | `gh pr view 47 -R noah-goodrich/claude-plugins` | `MERGED`, `2026-08-26T10:37:02Z` |
| `6466aae` landed | `git merge-base --is-ancestor 6466aae origin/main` | LANDED (NOT-ON-MAIN vs. stale local ref) |
| Root `CLAUDE.md` | `git ls-tree -r --name-only origin/main` | `CLAUDE.md` present |
| Decision 1 mechanized | read `build-plugin.sh:4-5`, `sync-plugin.sh:8-9,16-17` | source→distro, one-way, no delete |
| Current drift | `sync-plugin.sh --dry-run` vs. a clean worktree | 2 skills source-ahead (link, recon) |
| `cairn_available()` | `grep -rn "cairn_available"` over both repos | 2 hits, both prose; **0 implementations** |
| cairn calls in skills | `grep -rln cairn ~/dev/borg-collective/skills/` | 0 files |
| cairn runtime | `ls ~/.cairn`, `docker ps -a`, `which cairn` | absent, none, none |
| Promotion is total | `ls skills \| wc -l` in both repos | 17 and 17 — no per-skill filter |
| Hook CLI guard | `grep -rl "command -v borg" hooks/*.sh` | 12 of 12; distro has no `lib/` |

**Does the root `CLAUDE.md` change the archiving calculus? Yes — it makes archiving safe.** The one reason to
keep this document open was that Decision 1 is still load-bearing and had no other home in this repo. It now
has a better one: `CLAUDE.md` is read by every session automatically, states the rule more precisely than this
directive does (it names the generating script, the three hand-maintained exceptions, and the reason the rule
matters — that an edit here is silently overwritten and invisible to source-repo reviewers), and it is not a
dated record that a reader must first decide is still current. This directive's live half is fully absorbed;
its dead half is actively misleading, since it prescribes writing `cairn_available()` guards for a system that
was torn down. **Recommend archiving.** Keep the file for the decision trail — the PR #4 provenance and the
original Dispatch-session rationale are not recorded anywhere else — but it should stop being read as
standing guidance.
