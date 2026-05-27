# Plugin Privacy Audit — 2026-05-23

Read-only audit of the six plugins in `~/dev/claude-plugins/` to assess fitness for external distribution on Anthropic's marketplace. Every file in every plugin was read; flagged items below carry `file:line` references.

## Summary table

| Plugin | Reuse rating | Recommendation | Severity |
|---|---|---|---|
| `dev-tools` | Generally reusable after redaction | Public — after listed redactions | Low-Medium |
| `noah-content-tools` | Generally reusable after redaction | Modify and keep public (heavy rework) OR Private | High |
| `noah-strategy` | Generally reusable as-is | Public — distribute as-is (rename optional) | Low |
| `noah-writing-voice` | Personal — keep private | **Private — keep in personal marketplace only** | Critical |
| `research-tools` | Generally reusable as-is | Public — distribute as-is | Low |
| `token-cost` | Generally reusable as-is | Public — distribute as-is | None |

---

## Per-plugin detail

### `dev-tools`

- **Files scanned:** 10
- **Personal content found:**
  - `dev-tools/.claude-plugin/plugin.json:6` — `"author": "Noah Goodrich"` (standard, but identifies author).
  - `dev-tools/skills/bootstrap-project/SKILL.md:17` — "These templates reflect Noah's actual working setup." Personal attribution inside the skill body.
  - `dev-tools/skills/bootstrap-project/SKILL.md:3, 89, 97-98` — References to `drone up/down/status` and "borg-collective." Internal CLI/dotfiles codenames not shipped with the plugin; external users can't run them.
  - `dev-tools/skills/bootstrap-project/SKILL.md:42, 87` and `references/Dockerfile.template:5` — Hard-coded `~/.config/dotfiles/devcontainer/Dockerfile.base` path. Assumes Noah's dotfiles repo layout.
  - `dev-tools/skills/bootstrap-project/references/docker-compose.template.yml:10, 23` — `# keep in sync with dotfiles/devcontainer/docker-compose.base.yml` comment and `~/.config/borg` mount. Internal codename "borg" surfaces.
  - `dev-tools/skills/store-secret/SKILL.md:51, 63-66` — References `~/.config/dotfiles/zsh/secrets.zsh` and `_keychain_export` helper. Both presume Noah's private dotfiles environment.
  - `dev-tools/skills/store-secret/SKILL.md:92` vs `bootstrap-project/SKILL.md` — `dev up` vs `drone up` inconsistency (mid-rename).
  - `dev-tools/skills/repo-review/references/architecture-template.md:52-57` — Example pipeline names (`GitHubClient`, `PRCrawler`, `SnowflakeLoader`, `raw.github.pr_analysis`) read as real internal modules rather than generic placeholders.

- **Recommendation:** Public — after listed redactions.
- **Specific redactions:**
  1. Drop "Noah's" from `bootstrap-project/SKILL.md:17`; replace with "an opinionated."
  2. Replace `drone` and `borg-collective` references with the standard `devcontainer` CLI, OR document them as optional wrappers requiring Noah's dotfiles.
  3. Swap `~/.config/dotfiles/devcontainer/Dockerfile.base` for a public devcontainer base image (e.g. `mcr.microsoft.com/devcontainers/base`); make the dotfile dependency optional.
  4. Remove or comment-out the `~/.config/borg` mount in `docker-compose.template.yml:23` and the "keep in sync with dotfiles…" comment on L10.
  5. Generalize the `secrets.zsh` / `_keychain_export` block in `store-secret/SKILL.md:49-68` — inline a tiny helper or mark it as "if you have a secrets.zsh pattern."
  6. Resolve `dev up` vs `drone up` naming inconsistency.
  7. Replace `GitHubClient`/`PRCrawler`/`SnowflakeLoader`/`raw.github.pr_analysis` with fully generic placeholders.

---

### `noah-content-tools`

- **Files scanned:** 6
- **Personal content found:** Pervasive. Highlights:
  - Plugin name and author: `README.md:1`, `.claude-plugin/plugin.json:2,5-7` — plugin literally named after Noah.
  - `README.md:22` — "Analysis of Noah's top 3 performing LinkedIn posts" — references private engagement data.
  - `skills/linkedin-post/SKILL.md:3, 8, 15, 22, 37, 56, 57, 142, 152, 154` — "Noah" / "Noah's voice" / "Noah's recurring tags" / "Noah's career search post" / "Noah's pytest-coverage-impact post" throughout the skill.
  - `skills/linkedin-post/SKILL.md:24` — "I love using Cursor… noticed it was gaming my system." Personal anecdote.
  - `skills/linkedin-post/SKILL.md:25-26` — Career-search history; "2026 Snowflake Data Superhero" award.
  - `skills/linkedin-post/SKILL.md:37` — Personal hashtag inventory (`#SnowflakeDataSuperhero`, `#TheLongGame`).
  - `skills/linkedin-post/SKILL.md:98` — **"my severance ran out and we were figuring out how to survive until my start date"** — explicit financial-hardship detail.
  - `skills/linkedin-post/references/linkedin-examples.md:1-19` — Entire file is engagement-ranked analysis of Noah's top posts.
  - `skills/linkedin-post/references/linkedin-examples.md:11` — **Names third-party real people from Noah's network** ("Joe Herring, Creed Smith, Morgan Wimmer, etc.") without their consent.
  - `skills/snowflake-article/SKILL.md:3, 14, 21, 25, 36, 44, 55` — Internal codename "snowfort" plus "Snowflake Builders Blog" publication target.
  - `skills/snowflake-article/SKILL.md:28` — References Noah's specific Databricks article and self-correction.
  - `skills/snowflake-article/SKILL.md:55` and `article-conventions.md:19-22` — "CCC mental model (Calm, Connect, Coach)" — Noah's proprietary framework branding.
  - `skills/snowflake-article/SKILL.md:80` — "Noah has a clear preference for Snowflake and isn't shy about it" — opinionated vendor stance baked into the prompt.
  - `skills/snowflake-article/references/article-conventions.md:10` — "draws from parenting and military leadership examples" — personal background.
  - `skills/snowflake-article/references/article-conventions.md:30` — Personal award reference.
  - `skills/snowflake-article/references/article-conventions.md:40` — Noah's idiosyncratic "PoEAA/Rails pattern" naming convention.

- **Recommendation:** Modify and keep public — but rework is substantial. Realistically, fork into a new generic `content-tools` plugin or keep private. The `linkedin-post` skill is salvageable with effort; `snowflake-article` is so coupled to Noah's publication relationships and frameworks that genericizing strips most of the value — recommend keeping `snowflake-article` private and shipping only a genericized `linkedin-post`.
- **Specific redactions:**
  1. Rename plugin from `noah-content-tools` → `content-tools` (plugin.json:2, README.md:1, directory).
  2. Replace `"Noah Goodrich"` author with generic placeholder OR remove.
  3. Strip every "Noah"/"Noah's" reference across SKILL.md files (12+ instances).
  4. **Delete `linkedin-examples.md` entirely**, or rewrite as anonymized pattern examples. Third-party PII (Joe Herring, Creed Smith, Morgan Wimmer) must not ship.
  5. Remove the Cursor anecdote, severance line, Databricks self-correction, 2026 Data Superhero references.
  6. Remove proprietary framework names ("CCC", "The Long Game", "WAF series", "PoEAA/Rails pattern" naming, "fire-warden vs firefighter").
  7. Remove "snowfort" codename throughout (5+ instances).
  8. Generalize "Medium" / "Snowflake Builders Blog" to "technical blogs."
  9. Remove personal hashtag lists.
  10. Remove "parenting and military leadership examples" line.
  11. Replace "Noah has a clear preference for Snowflake and isn't shy about it" with neutral guidance.

---

### `noah-strategy`

- **Files scanned:** 4 (215 total lines).
- **Personal content found:**
  - Plugin name: `README.md:1` and `plugin.json:2` — `noah-strategy` ties to a person (branding choice, not a leak).
  - `plugin.json:5-7` — Standard `"Noah Goodrich"` author attribution.
  - `skills/strategic-brief/references/framework.md:19-20` — Example "Snowflake accounts drift from WAF best practices" — identifiably from Noah's content domain (Snowflake/WAF), though not technically sensitive.
  - `skills/strategic-brief/SKILL.md` — No flagged content. Methodology only.
  - No financial details, no client names, no roadmaps, no quoted writing, no proprietary frameworks.

- **Recommendation:** Public — distribute as-is. The plugin teaches a methodology rather than embedding business context.
- **Optional polish (not required):**
  1. `framework.md:19-20` — Replace Snowflake/WAF example with a domain-neutral one (e.g. "API rate limits constrain enterprise scaling").
  2. Optional rename to `strategic-brief` if Anthropic prefers de-personalized plugin names (many marketplace plugins are author-named, so not required).

---

### `noah-writing-voice`

This plugin is the highest-severity item in the audit. It is by design a reproduction of one named person's voice and ships full published articles as reference material.

- **Files scanned:** 8 (incl. three full Medium articles, ~2,900 words total).
- **Personal content found:**
  - `plugin.json:5-7`, `README.md:3`, `skills/noah-voice/SKILL.md:3, 6` — Plugin, skill, and metadata all named after Noah Goodrich.
  - **`skills/noah-voice/references/voice-rules.md:5`** — Bio includes **"father of three (ages 19, 3, and 6 months)"** — PII about minor children.
  - `voice-rules.md:36` — Prescribes naming kids' ages as a voice technique ("a nineteen-year-old daughter, a three-year-old son, and a six-month-old daughter").
  - `voice-rules.md:10-12` — Banned-words list ("genuinely," "straightforward," "navigate," "landscape," "leverage," "delve," "honestly"); "no em dashes"; "use 'frankly' instead of 'honestly.'" Idiosyncratic personal stylebook.
  - `voice-rules.md:30, 32` — Names "The Long Game," "AI Efficiency Trap," and the Databricks article as canonical references.
  - `skills/ai-scoring/SKILL.md:141` — Cross-references the `snowflake-article` sibling skill and "Snowflake Builders Blog."
  - **`examples/snowflake-vs-databricks-nov2023.txt:1-27`** — Medium "highlight roll" listing real third-party readers ("Jingsonglee," "taiyo," "Niren Kumar," "François Vienneau Binette and Adrian Betanzos Co.," "Aaron Porchia"). Third-party PII that did not consent to redistribution.
  - `examples/snowflake-vs-databricks-nov2023.txt:79` — Childhood financial-circumstance anecdote ("Growing up, my family only owned older, used cars…").
  - `examples/snowflake-vs-databricks-nov2023.txt:111-117` — Identifiable career anecdote about a former employer ("worst three months of my life… working six days a week, twelve and thirteen hours a day").
  - `examples/snowflake-vs-databricks-nov2023.txt:131` — Repeats an interview comment from an unnamed data engineer ("20% of the team's time" on Delta Lake tuning).
  - **`examples/snowflake-vs-databricks-nov2023.txt:133`** — "If Snowflake is the Toyota Hilux of the data world, then exactly how bad is Databricks? Much like the DeLorean DMC-12 it has been vastly over-hyped and under-delivers in pretty much every way possible." — Direct competitor disparagement attributed to Noah by name.
  - `examples/snowflake-vs-databricks-nov2023.txt:77` — "Snowflake is definitely the best in class option." — Strong vendor-preference claim.
  - `examples/long-game-feb2026.txt:57-61` — Parenting anecdotes ("hand-holding my three-year-old…").
  - `examples/long-game-feb2026.txt:109-111` — Noah's "more with more" contrarian AI-efficiency stance.
  - `examples/long-game-feb2026.txt:153` — Series roadmap teaser ("Next Up: Part 2 — The Wisdom Gap").
  - **`examples/ai-efficiency-trap-dec2025.txt:243-249`** — Snowfort product roadmap leak ("a complete rewrite of Snowfort… the new version dropping shortly, it's a massive upgrade").
  - `examples/ai-efficiency-trap-dec2025.txt:263-269` — GitHub repo + PyPI install for `pytest-coverage-impact`. Public, but ties product to person.
  - All three example articles are **complete verbatim Medium articles** including Medium UI scaffolding. Redistribution is questionable under Medium's licensing norms regardless of voice-calibration intent.

- **Recommendation:** **Private — keep in personal marketplace only.** Shipping a "write like Noah" skill externally means strangers produce content stylistically attributable to him, complete with the Databricks attack, the family bio, and the contrarian takes. If you ever want to ship a public version, fork to a generic `personal-voice-skeleton` template that has the user fill in their own bio and examples — but that is a rewrite, not a redaction.

- **Minimum redactions if ever shared:**
  1. `voice-rules.md:5` — Remove "father of three (ages 19, 3, and 6 months)" entirely.
  2. `voice-rules.md:36` — Replace the kids-ages example with a generic specifics demonstration.
  3. `snowflake-vs-databricks-nov2023.txt:1-27` — Strip the Medium highlight-roll naming third-party readers.
  4. `snowflake-vs-databricks-nov2023.txt:133` — Reconsider distributing the Databricks disparagement line in a shareable reference.
  5. `ai-efficiency-trap-dec2025.txt:241-249` — Remove the Snowfort roadmap teaser.
  6. `long-game-feb2026.txt:57` — Strip kids' ages / parenting anecdotes if generalizing.
  7. `ai-scoring/SKILL.md:141` — Generalize the "Snowflake Builders Blog" / `snowflake-article` cross-reference.
  8. Rename plugin / skill / README from `noah-writing-voice` and `noah-voice` to de-personalized names.
  9. Replace three full Medium articles with single-paragraph excerpts or synthesized examples.

---

### `research-tools`

- **Files scanned:** 10.
- **Personal content found:** None substantive. Highlights:
  - `plugin.json:5-7` — Standard `"Noah Goodrich"` author attribution.
  - `skills/deep-research/references/example-evaluation.md` — Worked example uses Morgan Housel's *The Psychology of Money* (public book; not a Noah-private project).
  - `skills/deep-research/references/evidence-hierarchy.md` and `source-evaluation-rubric.md` — All examples cluster in personal/household finance (Mr. Money Mustache, CFPB, AFCPE, envelope budgeting). Reveals domain experience but nothing proprietary.
  - `skills/deep-research/references/research-document-template.md:175-178` — "A family making $60K/year in Salt Lake City…" — geographic tell, innocuous.
  - `skills/deep-research/references/research-document-template.md:63` — "tired dad at 4am" — mild voice flavor.
  - No "troth"/"reveal"/"snowfort"/"WAF series"/"Long Game series" references anywhere.

- **Recommendation:** Public — distribute as-is. Optional polish: diversify examples beyond household finance, neutralize the Salt Lake City / "tired dad" phrasing.

---

### `token-cost`

- **Files scanned:** 3 (56 total lines).
- **Personal content found:**
  - `plugin.json:6` — Standard `"Noah Goodrich"` author attribution.
  - `README.md:19` — Lists "Cowork" as an install target. Cowork is a public Anthropic product; not sensitive.
  - No anecdotes, no codenames, no opinions. Pricing numbers are publicly published Anthropic rates.

- **Recommendation:** Public — distribute as-is. Ship it.

---

## Cross-cutting observations

1. **The `noah-*` naming convention is a problem.** Three plugins (`noah-content-tools`, `noah-strategy`, `noah-writing-voice`) embed Noah's first name in the plugin slug. For external marketplace distribution, this is at minimum a branding awkwardness and at most a signal that the content inside is personal. `noah-strategy` is clean enough that the name can stay; the other two need rethinking before public release.

2. **Internal codename "snowfort"** appears in `noah-content-tools` (snowflake-article skill, ~5 instances) and `noah-writing-voice` (ai-efficiency-trap example article). It is Noah's open-source CLI for Snowflake WAF assessments — public on GitHub but flagged per audit criteria as an identity tell. If `snowfort` is intentionally branded and public, that's fine; if it's still pre-release, the roadmap teaser in `ai-efficiency-trap-dec2025.txt:243-249` is a leak.

3. **Series/publication references** — "The Long Game," "AI Efficiency Trap," "WAF series," "Snowflake Builders Blog" appear across multiple plugins and act as Noah-identifiers. They aren't sensitive but they tie any external user back to Noah's specific publication footprint.

4. **Personal stylebook leaks into prescriptive rules.** `noah-writing-voice` is the obvious case, but `noah-content-tools/skills/snowflake-article` also encodes opinions ("Noah has a clear preference for Snowflake and isn't shy about it") as prompt instructions. A stranger installing the plugin would be told to argue Noah's positions.

5. **Third-party PII risk.** Two distinct spots: `noah-content-tools/skills/linkedin-post/references/linkedin-examples.md:11` (Joe Herring, Creed Smith, Morgan Wimmer) and `noah-writing-voice/examples/snowflake-vs-databricks-nov2023.txt:1-27` (Medium highlight-roll readers). Neither group consented to being part of a redistributable plugin payload. Both should be scrubbed regardless of whether the plugins ship publicly.

6. **Family / financial anecdotes concentrate in `noah-writing-voice`.** Kids' ages in the bio, severance-running-out in the LinkedIn skill, childhood-poverty anecdote in the Databricks article, three-year-old parenting stories in the Long Game article. These cross the line from "voice training data" into PII.

7. **Dotfile assumptions in `dev-tools`.** The plugin presumes Noah's private dotfiles repo (`~/.config/dotfiles/...`, `~/.config/borg`) and CLI wrappers (`drone`, `_keychain_export`) that aren't shipped with the plugin. External users would hit broken paths. This is a usability problem more than a privacy problem, but it needs fixing before publish.

8. **`noah-strategy`, `research-tools`, and `token-cost` are clean.** Methodology plugins that don't embed Noah-specific content. These three could ship today.

---

## Pre-publish checklist

Before any of these plugins are distributed externally:

1. **`noah-writing-voice` → do not publish.** Keep in personal marketplace. If you ever want a public version, fork it to a generic stylebook template (rename, strip the bio, replace example articles with single-paragraph excerpts or synthesized samples, remove third-party highlight-roll PII, remove the Snowfort roadmap line).

2. **`noah-content-tools` → either heavy rework or keep private.** If you publish, rename to `content-tools`, strip every Noah/family/career reference, delete `linkedin-examples.md` or fully anonymize it, remove proprietary framework names ("CCC", "The Long Game", "PoEAA/Rails pattern"), and reconsider whether `snowflake-article` should ship at all (it's deeply tied to your publication footprint). Realistic minimum: ship only a genericized `linkedin-post`, keep `snowflake-article` private.

3. **`dev-tools` → safe to publish with the listed redactions.** Resolve the `drone` vs `dev up` naming inconsistency, swap dotfile paths for public defaults (or document the dependency clearly as optional), and genericize the architecture-template module names. ~30 min of work.

4. **`noah-strategy` → safe to publish as-is.** Optional: rename to `strategic-brief` and swap the Snowflake/WAF example for a domain-neutral one. Otherwise ship today.

5. **`research-tools` → safe to publish as-is.** Optional: add a non-finance worked example and neutralize the Salt Lake City / "tired dad" phrasing if you want broader marketplace appeal. Otherwise ship today.

6. **`token-cost` → safe to publish as-is.** No changes required.

7. **Third-party PII sweep.** Before anything ships, scrub:
   - `noah-content-tools/skills/linkedin-post/references/linkedin-examples.md:11` (real network names)
   - `noah-writing-voice/examples/snowflake-vs-databricks-nov2023.txt:1-27` (Medium highlight-roll readers)

8. **Decide on the `noah-*` naming pattern.** If marketplace listings should look like products rather than personal repos, rename to de-personalized slugs. `noah-strategy` is borderline; `noah-content-tools` and `noah-writing-voice` should definitely lose the prefix if they go public.

9. **Snowfort roadmap leak.** Decide whether the "complete rewrite of Snowfort… new version dropping shortly" line in `ai-efficiency-trap-dec2025.txt:243-249` is intentional public messaging. If not, it must be stripped before that file ships in any form.
