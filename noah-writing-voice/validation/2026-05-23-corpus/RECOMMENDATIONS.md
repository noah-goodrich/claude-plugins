# Validation Recommendations — noah-writing-voice plugin

**Date:** 2026-05-23
**Source reports:** `noah-voice-validation.md`, `ai-scoring-validation.md`
**Corpus:** 10 Medium articles (~13,308 words), Jan 2022 → Mar 2026

## TL;DR (Lead Finding)

**`ai-scoring` has a fundamental design flaw, not just a calibration problem. It flags Noah's own writing as AI 50% of the time, including articles he is publicly proud of (Long Game Part 2 scores 65/100; the SKILL itself sets the publishing threshold at 75).** The Staccato (Cat 1) rule is inverted against Noah's actual rhythm, and em-dash banning (Cat 8) penalizes a punctuation mark he routinely uses. Recalibrating these two categories restores F1 to 1.0 against a hand-rolled AI test set, but the deeper issue — confusing "voice rules" with "AI detection signals" — needs a redesign.

`noah-voice` is mostly aspirationally correct but numerically miscalibrated on three rules (em-dashes, single-sentence-paragraph quotas, blanket bullet ban). It also under-specifies several distinctive structural moves Noah uses repeatedly.

---

## Should `noah-voice` be updated?

**Yes — calibration update, not redesign.** The skill correctly identifies *what makes the voice distinctive* (story-first openings, central metaphor, specific details, confident bold claims, bold flowing into prose). It miscounts on the strict-numerical rules.

See `noah-voice-validation.md` section "Recommended Plugin Updates (Mechanical Edit Instructions)" for the diff-like instructions. Summary of changes:

1. **Em dashes: "Not one. Not ever."** → **"Cap at 3 per article."** (Reality: 46 em-dashes across the corpus, mean 4.6/article.)
2. **Single-sentence paragraphs: "max 2 per article"** → **"a rhythm tool; the constraint is that each one must carry weight, not the count."** (Reality: mean 11.6 per article; minimum 4.)
3. **Bullets: "no bullets in article body"** → **"avoid in essay-format; use freely in tutorials, comparisons, and CTA sections."** (Reality: 7 of 10 articles use mid-body bullets, including tutorials where they are correct.)
4. **Add 5+ new rules** for under-specified patterns: the "I was wrong" opener, the "Origin Story" subhead, the family-anchor pivot, named cultural anchors, "Your move" CTAs, bold-for-phrase-emphasis, AI-disclosure codas.
5. **Update SKILL.md self-check** to grep specifically for "Here's the thing" (it has slipped into recent articles), and to verify family ages are current.

**Effort estimate:** medium. ~30 lines of edits across `voice-rules.md` and `SKILL.md`. A follow-up task can execute the mechanical edits in `noah-voice-validation.md` more or less verbatim.

---

## Should `ai-scoring` be updated?

**Yes — and it needs partial redesign, not just recalibration.** See `ai-scoring-validation.md` section "Fundamental Design Issues" for the full argument. Summary:

### Quick-fix path (recalibration only, ~F1 1.00 against current AI test set)

1. **Rewrite Cat 1 (Staccato)** to count only *empty* single-sentence paragraphs (≤8 words OR matches a known generic-transition phrase, AND no specific tokens), not all of them.
2. **Drop em-dashes from Cat 8 (Banned)** entirely. Track separately as a stylistic preference, not an AI signal.

These two changes alone take F1 from 0.67 to 1.00 against my hand-rolled AI test set, and lift Noah's mean score from 73 to 93.8.

### Right-fix path (redesign)

1. **Split the framework into two layers:**
   - Layer A = *voice compliance* (powered by noah-voice rules; affects whether to publish, not whether it reads AI)
   - Layer B = *AI detection score* (only the signals that genuinely separate human from LLM output)
2. **Replace Cat 7 (Specificity)** numeric-token-density with anecdote-density: count sentences matching `(I|we|my|our) <past-tense verb> … <specific token>`. Token density is currently a dead check; anecdote density would actually do the job.
3. **Add article-type input** (essay / tutorial / opinion / linkedin-post). Tutorials should not be penalized for numbered steps.
4. **Merge Cat 5 (Openings) into Cat 2 (Parallel)** — they're the same concept; Cat 5 barely fires.

### Why I lean toward redesign

The current framework treats "violations of noah-voice" and "reads like AI" as identical concepts. They aren't. Em-dashes are a stylistic-preference issue, not an AI signal. Single-sentence paragraphs are a voice-rhythm tool, not an AI tell. If `ai-scoring` is going to enforce the publication threshold on Snowflake Builders Blog articles (per the `snowflake-article` skill), it cannot fail Noah's own work. The current version does.

**Effort estimate:** quick-fix is small (10–20 lines in `ai-scoring/SKILL.md`). Redesign is medium (rewrite of 3 of the 8 categories + add the layered model). Either way, every output the system produces will need re-baselining.

---

## Decisions Noah Needs to Make (Each Is Binary or Short-List)

### Decision 1: noah-voice strict-rules — keep aspirational or match practice?
**The choice:** the "Not one. Not ever." em-dash ban (and similar absolutes for single-sentence-paragraph quotas) describes how Noah *wants* to write, but doesn't describe how he *does* write — even in the articles the SKILL holds up as exemplars. Either:
- **(A)** Lock the aspirational version. Re-edit existing articles to comply (significant retroactive work, but the skill stays self-consistent).
- **(B)** Loosen the rules to match observed practice (use my proposed "cap at 3 em-dashes" and "every single-sentence paragraph must carry weight"). This is the validation report's recommendation. Quick to implement; existing articles remain compliant; SKILL becomes descriptive of actual voice.

**Recommended:** (B). The aspirational version flagged Noah's own writing as non-compliant during validation — that's a strong signal the aspiration is too tight.

### Decision 2: ai-scoring — quick-fix calibration or redesign?
**The choice:**
- **(A)** Quick-fix: rewrite Cats 1 and 8, ship in an hour. Restores F1 = 1.0 against current test set but inherits the "voice rules ≡ AI signals" category-error.
- **(B)** Redesign: split into voice-compliance vs AI-detection layers, replace Cat 7 specificity check with anecdote-density, add article-type weighting. Slower (~half a day of skill rewrite + new evals), but solves the root cause.

**Recommended:** (B). (A) leaves the framework one revision away from the next false-positive embarrassment. Specifically: it would not catch a piece where AI-collaboration adds smooth flow without overt transitions (which is exactly the failure mode Noah described in his Long Game Part 2 "Note on Process" — "the AI built a solid strategy to consolidate them into a clean flow. But it didn't notice the problem on its own.").

### Decision 3: Voice eras — lock to current voice or evolve?
**The choice:** the corpus shows three discernible voice eras (pre-Snowfort 2022–2024, tooling-launch Dec 2025–Jan 2026, Long Game Feb–Mar 2026). The latest era has the highest contraction rate (2.4–2.7/100w), shortest mean sentence length (13 words), most family-anchored structure, and explicit AI-disclosure codas. The current voice-rules document doesn't reflect these era shifts.
- **(A)** Lock to the Long Game era as canonical. Update voice-rules to enforce the new patterns (family anchor, "Your move" CTA, AI-disclosure coda, shorter sentences).
- **(B)** Keep voice-rules style-agnostic across eras. Accept that voice evolves; the rules describe persistent characteristics, not specific era patterns.

**Recommended:** (A) if Noah considers the Long Game era his best work and wants to consolidate there. Otherwise (B). This is a personal-taste call Noah needs to make. The validation can't decide it.

### Decision 4: Should ai-scoring enforce a hard publication threshold?
**Context:** the `snowflake-article` skill currently enforces ai-scoring score ≥ 75 for Snowflake Builders Blog articles. As validated, 5 of Noah's actual published Builders Blog and personal Medium articles score below 75. This is a contradiction — the gate is blocking work that already shipped.
- **(A)** Lower the threshold to 65 (would have passed 8 of 10 corpus articles).
- **(B)** Fix the scoring framework first (Decision 2), then re-baseline thresholds against the corpus.
- **(C)** Remove the hard gate and treat the score as advisory only.

**Recommended:** (B). (A) papers over the broken framework. (C) might be the right answer if redesigned scoring still produces variance across legitimate articles.

---

## Sequence of Operations (if Noah approves both updates)

1. **First:** ship Decision 1 (B) — update `noah-voice` rules per the diff in `noah-voice-validation.md`. Low risk, descriptive of actual practice.
2. **Second:** if Decision 2 (B) (redesign), draft the layered scoring model and rerun this validation harness. The harness in `scripts/ai_score.py` is reusable — just point it at a new SKILL implementation.
3. **Third:** once `ai-scoring` is recalibrated, address Decision 4 (publication threshold). The threshold cannot be set until the scoring distribution against the corpus is known under the new framework.
4. **Fourth (optional):** address Decision 3 (voice era lock) as a follow-up. Not urgent.

## Files Produced by This Validation

All under `/Users/noah/dev/claude-plugins/noah-writing-voice/validation/2026-05-23-corpus/`:

- `INDEX.md` — corpus index, 10 articles
- `articles/*.md` — 10 Medium articles with YAML frontmatter
- `ai-samples/*.md` — 5 deliberately AI-flavored articles (reproducible)
- `scripts/voice_audit.py` — rule-by-rule measurement script for noah-voice
- `scripts/ai_score.py` — operationalized ai-scoring harness + evaluation mode
- `noah-voice-validation.md` — per-rule scorecard + mechanical edit instructions
- `ai-scoring-validation.md` — precision/recall + redesign recommendations
- `RECOMMENDATIONS.md` (this file)
