# ai-scoring Validation Report

**Date:** 2026-05-23
**Skill version audited:** `skills/ai-scoring/SKILL.md` at HEAD (commit 84c36b0)
**Harness:** `scripts/ai_score.py` (see file header for per-category translation decisions)
**Samples:** 10 human articles (Noah's full Medium corpus); 5 deliberately AI-flavored articles in the same topic space (`ai-samples/`)

## Translation Decisions (SKILL.md → deterministic checks)

The skill's prose is mostly operationalizable, but several decisions had to be made:

| Cat | SKILL signal (prose) | Operationalization |
|-----|----------------------|--------------------|
| 1 Staccato | "1–2 = fine; 3–4 = noticeable; 5+ = very AI" | Count paragraphs with ≤1 sentence-ender. Apply ranges as -7 (3–4), -15 (5–9), -20 (10+). |
| 2 Parallel | "3+ consecutive sentences/paragraphs same syntactic pattern" | Detect 3+ consecutive sentences with identical first word, AND 3+ consecutive paragraphs starting "The Nth …". -5 per cluster, capped -15. |
| 3 Transitions | List of literal phrases | grep each phrase; -2 each, capped -15. |
| 4 Hedging | "While X has its merits…", "pros and cons", etc. | grep phrase list; -3 each, capped -10. |
| 5 Openings | "3+ consecutive same opening" | Already covered by Cat 2; here we score on opener-distribution entropy: if top opener > 30% of all sentences, -5. |
| 6 Lists-as-prose | Short sentences with "also/additionally/furthermore/moreover" | Paragraphs with ≥3 sentences where ≥2 are short (≤18 words) and start with one of those connectors. -3 per paragraph, capped -10. |
| 7 Specificity | "numbers, names, timeframes, anecdotes" | Specific-token rate = (numbers + currency + % + months + years + mid-sentence proper nouns) / words × 100. <0.5 = -15; <1.5 = -10; <3.0 = -3. |
| 8 Banned | List of words + "em dashes (Noah's specific ban)" | grep word list + count em dashes; sum N. 1–2 = -3, 3–4 = -7, 5+ = -10. |

**Threshold:** SKILL says "Below 75 = needs revision; below 60 = significant rewrite." We treat **score < 75 as a positive "flagged as AI" classification.**

## Headline Results

| Set | n | Mean | Median | Min | Max |
|-----|---|------|--------|-----|-----|
| Human (Noah's actual Medium articles) | 10 | **73.0** | 75.5 | 50 | 93 |
| AI samples (deliberately AI-flavored) | 5 | **52.8** | 51.0 | 46 | 61 |

| Metric | Value |
|--------|-------|
| TP (AI scored <75) | 5 / 5 |
| FN (AI scored ≥75) | 0 / 5 |
| FP (Noah scored <75) | **5 / 10** |
| TN (Noah scored ≥75) | 5 / 10 |
| **Precision** | **0.500** |
| **Recall** | 1.000 |
| **F1** | 0.667 |
| **Accuracy** | 0.667 |

### Per-article scores

**Noah's articles (treated as "human" ground truth):**

| File | Score | Verdict at threshold 75 |
|------|-------|--------------------------|
| `being-told-i-could-be-fired.md` | 93 | ✅ true negative |
| `snowflake-vs-databricks-revisited.md` | 82 | ✅ true negative |
| `snowflake-aws-iac-part1.md` | 80 | ✅ true negative |
| `the-long-game.md` | 78 | ✅ true negative |
| `the-long-game-part3-architects-anchor.md` | 77 | ✅ true negative |
| `snowflake-vs-databricks.md` | 74 | ❌ FALSE POSITIVE |
| `snowflake-aws-iac-part2.md` | 68 | ❌ FALSE POSITIVE |
| `the-long-game-part2-wisdom-gap.md` | 65 | ❌ FALSE POSITIVE |
| `ai-coding-agent-architect.md` | 63 | ❌ FALSE POSITIVE |
| `ai-efficiency-trap.md` | 50 | ❌ FALSE POSITIVE |

**AI samples:**

| File | Score | Verdict |
|------|-------|---------|
| `ai-sample-pipeline-observability.md` | 61 | ✅ true positive |
| `ai-sample-snowflake-cost-optimization.md` | 58 | ✅ true positive |
| `ai-sample-data-mesh-architecture.md` | 51 | ✅ true positive |
| `ai-sample-ai-coding-agents.md` | 48 | ✅ true positive |
| `ai-sample-aws-iac-best-practices.md` | 46 | ✅ true positive |

## Category Contribution Analysis (the key finding)

Sum of penalty points each category contributes across each set:

| Category | Human total | AI total | Verdict |
|----------|-------------|----------|---------|
| **1 Staccato** | **−162** | **−7** | **INVERTED** — single-sentence paragraphs are a feature of Noah's voice, not an AI tell |
| 8 Banned (incl. em-dashes) | −46 | −50 | NOISY — em-dashes dominate the human signal; Noah uses them; treating them as -1 each is wrong |
| 2 Parallel | −40 | −50 | MODESTLY USEFUL — both sets trigger; small separation |
| 3 Transitions | −8 | −75 | **CLEAN SIGNAL** — strong separation, correctly identifies AI |
| 4 Hedging | −9 | −39 | GOOD SIGNAL — modest separation toward AI |
| 6 Lists-as-prose | 0 | −15 | GOOD SIGNAL — only AI samples trigger |
| 5 Openings | −5 | 0 | TRIVIAL — barely contributes |
| 7 Specificity | 0 | 0 | UNUSED — our threshold (<1.5/100w) never triggered for either set |

### What happens if we drop the bad categories

| Categories disabled | Human mean | AI mean | TP | FP | TN | FN | P | R | F1 |
|---------------------|-----------|---------|----|----|----|----|----|----|----|
| none (current SKILL) | 73.0 | 52.8 | 5 | 5 | 5 | 0 | 0.50 | 1.00 | 0.67 |
| drop Cat 1 (Staccato) | 89.2 | 54.2 | 5 | 1 | 9 | 0 | **0.83** | 1.00 | **0.91** |
| drop Cat 1 + Cat 8 | 93.8 | 64.2 | 5 | 0 | 10 | 0 | **1.00** | 1.00 | **1.00** |
| drop Cat 8 only | 77.6 | 62.8 | 5 | 3 | 7 | 0 | 0.62 | 1.00 | 0.77 |

**Cat 1 (Staccato) alone is responsible for 4 of 5 false positives. Cat 8 (banned/em-dashes) accounts for the fifth.**

## Which Signals Work, Which Don't

### Clean, predictive signals (KEEP)
1. **Cat 3 (Generic transitions)** — best separator. Human total −8 vs AI total −75. The phrase list is well-targeted; AI samples are dripping with these and humans rarely use them.
2. **Cat 4 (Hedging)** — good separation (−9 vs −39). The patterns identified ("pros and cons", "it depends on", "while X has its merits") are reliable AI tells.
3. **Cat 6 (Lists-as-prose)** — perfectly clean (0 vs −15). Only AI samples trigger.

### Modestly useful signals (CALIBRATE)
4. **Cat 2 (Parallel structure)** — both sets trigger, but AI more (−40 vs −50). Useful but not decisive; possibly tune the cluster threshold up (require 4+ consecutive rather than 3+).
5. **Cat 5 (Repetitive openings)** — barely fires either way. Either remove or merge into Cat 2.
6. **Cat 7 (Specificity)** — *currently dead*. Our threshold (<1.5 specific tokens/100 words) never triggers for either Noah or my AI samples. Noah's specific-token rate is genuinely high (mean ~4–6/100w) but my AI samples also smuggle in proper nouns ("Snowflake", "Terraform", "AWS"). The rule needs a more discriminating signal — maybe specific *anecdotes* (sentences with first-person past-tense + concrete object) rather than just numeric token density.

### Noisy / inverted signals (FIX OR REMOVE)
7. **Cat 1 (Staccato) — INVERTED.** Single-sentence paragraphs are not an AI tell in Noah's writing; they are the rhythm. Noah averages 11.6 per article (vs the SKILL's "1–2 is fine, 5+ is very AI"). 4 of 5 false positives come from this. **Recommendation: fundamental redesign.** The actual AI tell is "single-sentence paragraph used as an EMPTY transition" (e.g., "But that wasn't the real problem." with no specific content). Counting all single-sentence paragraphs misses this nuance entirely.
8. **Cat 8 (Em-dash counting) — NOISY.** Em-dash counting at -1 each (capped -10) consistently penalizes Noah's actual writing. 7 of 10 of his articles have em-dashes. **Recommendation: drop em-dashes from the banned list entirely (the noah-voice ban itself is overstated per the noah-voice validation report), OR only penalize when em-dash density exceeds 5 per article.**

## Fundamental Design Issues (Not Just Calibration)

This is the lead finding for the cross-cut RECOMMENDATIONS doc.

### Issue 1: The framework treats voice-rules and AI-detection as the same thing

The current ai-scoring SKILL is structured as "violations of noah-voice = AI tells." But these are *different concepts*:

- **noah-voice rules** are prescriptive style preferences (don't use em-dashes, use 'frankly', avoid 'genuinely').
- **AI detection** is about prose patterns that are characteristic of LLM output regardless of the author's style preferences.

When the two overlap (e.g., generic AI transitions are both an LLM tell AND something Noah avoids), the rule works cleanly. When they diverge (e.g., em-dashes are an LLM tell statistically, but Noah uses them anyway), the rule penalizes the author's actual voice. **Cat 1 (Staccato) and Cat 8 (em-dashes) are both this kind of category-error.**

**Recommendation:** split into two layers. Layer A = "voice compliance" (driven by noah-voice rules; affects whether you'd publish, not whether it sounds AI). Layer B = "AI-detection score" (only the patterns that genuinely separate human from LLM text: empty transitions, mechanical parallelism, generic hedging, lists-as-prose, lack of specific anecdote).

### Issue 2: The Cat 1 (Staccato) rule has been validated *against* the wrong target

The SKILL prose treats single-sentence paragraphs as a generic AI tell: "AI loves the dramatic one-liner drop." This is true for some AI output but *not* for Noah's writing. The rule needs to distinguish between:

- **Substantive single-sentence paragraph** (Noah's pattern): contains a specific claim or beat that lands harder by standing alone. Example: "It had knowledge. It didn't have wisdom."
- **Empty single-sentence paragraph** (AI tell): generic transition with no content. Example: "But that wasn't the real problem." "Let's dive in." "Here's the thing."

A simple count cannot distinguish these. The detector should require the paragraph to be **content-free** (matches one of the AI-transition phrases, OR has fewer than ~8 words AND no specific tokens) to count as a tell.

### Issue 3: Specificity (Cat 7) is the most diagnostic signal but is currently dead

Noah's writing's *defining* feature is concrete detail ("twelve and thirteen hours a day"; "STATEMENT_TIMEOUT_IN_SECONDS to 3600"). AI-generated text in the same domain tends to use the same proper nouns (Snowflake, AWS, Python) but lacks specific personal anecdotes. The current numeric-token-density heuristic doesn't catch this because Snowflake/Terraform/AWS count as proper nouns.

**Recommendation:** replace numeric-density check with an *anecdote-density* check: count sentences that contain first-person past-tense verbs ("I worked", "I spent", "I built", "we hit") near a concrete object (number, named person, specific date). This is what AI cannot fake without source material.

### Issue 4: No callibration for article type

Tutorial articles like `snowflake-aws-iac-part1.md` legitimately have 28 single-sentence paragraphs (step instructions) and 22 bullet lines, but no "anecdote density" — and that's correct for the genre. The current SKILL penalizes them as if they were essays. **Recommendation:** add an article-type input to the scoring function (essay / tutorial / opinion / LinkedIn post), with category weights per type.

## Recalibration Recommendations (Mechanical)

If you keep the current 8-category framework instead of redesigning, the minimum changes to get F1 = 1.00 are:

### R1. Cat 1 Staccato — REWRITE
**Current:** count all single-sentence paragraphs; 5+ = -15 to -20.

**Replace with:** count single-sentence paragraphs that match BOTH (a) ≤8 words OR matches a known generic-transition phrase, AND (b) contain no specific tokens (numbers, named entities, currency). Score: 1–2 such "empty landings" = 0; 3+ = −5 each capped −15.

### R2. Cat 8 Banned — REMOVE em-dashes from the banned-word bucket
**Current:** em-dashes counted at 1 point each toward the banned bucket (capped −10).

**Replace with:** drop em-dashes from the deterministic check. (Track separately as a stylistic flag, not an AI signal.) Keep the other 13 banned words.

### R3. Cat 7 Specificity — REPLACE numeric-token density with anecdote density
**Current:** numeric + currency + month + year + proper-noun density per 100 words.

**Replace with:** count sentences that match the pattern `(I|we|my|our) <past-tense verb> ... <specific token>` (i.e., a sentence with a first-person past-tense + a number, named entity, currency, or date). Score: if anecdote density < 1 per 300 words, −10; < 1 per 500 words, −15.

### R4. Cat 5 Openings — MERGE into Cat 2
The two are conceptually the same. Cat 5 contributed −5 total to humans and 0 to AI in our test. Merge to simplify.

### R5. Article-type weighting (optional, larger change)
Accept a `genre` field in the scoring function with values: `essay`, `tutorial`, `opinion`, `linkedin-post`, `documentation`. For `tutorial`, disable Cats 1 and 6 entirely (numbered steps are not AI). For `linkedin-post`, raise the staccato threshold (short posts naturally have more single-sentence paragraphs).

## Verdict Summary

**The current ai-scoring framework has a 50% false positive rate against Noah's actual writing — it flags him as AI as often as it flags actual AI.** Two categories (Staccato and em-dash banning) cause 100% of those false positives. Disabling those two categories cleanly recovers F1 = 1.00 against my hand-rolled AI test set, suggesting the *other six* categories are well-calibrated.

The framework needs **redesign**, not just recalibration, because of category-confusion between "voice rules" and "AI detection." Cat 1 (Staccato) in particular is asking the wrong question — it should be asking "is this paragraph an empty transition?" not "is this paragraph short?". Cat 7 (Specificity) needs an anecdote-density check instead of a token-density check to actually do its job.

**The deepest concern:** if Noah ran his own most recent article (`the-long-game-part2-wisdom-gap.md`, scored 65 by this system) through the SKILL as currently written, the SKILL would tell him to substantially rewrite a piece he is proud of. That's the system silently undermining the writer's own voice. **This is the most urgent thing to fix.**
