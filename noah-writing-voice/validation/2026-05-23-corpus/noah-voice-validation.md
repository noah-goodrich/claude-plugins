# noah-voice Validation Report

**Date:** 2026-05-23
**Corpus:** 10 Medium articles, ~13,308 words, spanning Jan 2022 → Mar 2026
**Audit script:** `scripts/voice_audit.py`
**Skill version audited:** `skills/noah-voice/SKILL.md` and `references/voice-rules.md` at HEAD (commit 84c36b0)

## Methodology

For each rule the skill asserts, I either:
1. **Pattern-counted** via the audit script (em dashes, banned words, AI-transitions, bullets, single-sentence paragraphs, contractions, first-person, mean sentence length, bold standalone definitions)
2. **Hand-read** for rules requiring judgment (metaphor consistency, "set the scene before bold claims", "rhythm that breathes")

Code blocks were stripped before counting (so banned words inside code samples don't pollute prose stats). Frontmatter was also stripped.

## Per-Rule Scorecard

Legend: ✅ holds, 🟡 partial, ❌ violated, ⚠️ inverted (rule contradicts evidence)

| # | Rule | Expected | Observed | Verdict | Evidence |
|---|------|----------|----------|---------|----------|
| 1 | **No em dashes. "Not one. Not ever."** | 0 across all corpus | 46 em dashes in 7 of 10 articles | ❌ violated | `ai-efficiency-trap.md` has 16 (`writing hundreds of tests for the low-hanging fruit — the utility functions, the config parsers, the trivial code —`); `the-long-game.md` has 6 (`grueling labor of stewardship — the trials, the bond of love, and the difficult reality...`). Only `being-told-i-could-be-fired.md` (2022), `snowflake-aws-iac-part1.md`, and `the-long-game-part2-wisdom-gap.md` (the most recent self-conscious-of-AI article) are em-dash-free. |
| 2 | **Banned: "genuinely"** | 0 uses | 2 uses | ❌ violated | "genuinely impressive" (`long-game-part2-wisdom-gap.md` L30); "genuinely needs the keys to the kingdom" (`long-game-part3.md` L70) |
| 3 | **Banned: "straightforward"** | 0 uses | 2 uses | ❌ violated | "Testing is straightforward since each system is isolated" (`snowflake-aws-iac-part2.md` L53); "remain Pythonic and straightforward to implement" (L128) |
| 4 | **Banned: "delve"** | 0 uses | 1 use | ❌ violated | "Part 3 will delve into testing strategies" (`snowflake-aws-iac-part2.md` L136) |
| 5 | **Banned: "honestly", "to be honest", "navigate", "landscape", "leverage"** | 0 uses each | 0 uses each | ✅ confirmed | True zero across all 13,308 words. (Strongest holding ban.) |
| 6 | **Use "frankly" when you need "honestly"** | Present where appropriate | Only 2 uses corpus-wide | 🟡 weak | Only `being-told-i-could-be-fired.md` (2022) and `long-game-part2.md` use it. The other 8 articles never need either word. Not a strong stylistic signature — more a "if you're tempted to say honestly, say frankly instead" guard than a hallmark. |
| 7 | **No standalone punchy one-liners as transitions** | Rare; embedded inside paragraphs | 116 single-sentence paragraphs across 10 articles (mean 11.6/article) | ❌ violated systematically | `ai-efficiency-trap.md` has 23; `snowflake-aws-iac-part1.md` has 28; even the SKILL's exemplar `snowflake-vs-databricks.md` has 5. Example single-sentence paragraphs that ARE landing/transition lines: "**But then I looked at the code.**", "Then the project got complex.", "It had knowledge. It didn't have wisdom." |
| 8 | **Single-sentence paragraphs max 2/article** | ≤2/article | Mean 11.6/article; min 4, max 28 | ❌ violated by every article | Not a single article comes in under 4. The rule as stated is roughly 5× too strict. The actual practice is "use single-sentence paragraphs liberally for landings". |
| 9 | **No bullet lists in article body** | Only in CTA sections | 83 bullet lines total; mean 8.3/article; 7 of 10 articles use bullets mid-body | ❌ violated | `snowflake-aws-iac-part2.md` has 25 mid-body bullet lines (Options 1/2/3 are bulleted Pros/Cons); `snowflake-aws-iac-part1.md` has 22; `ai-coding-agent-architect.md` has 14 (e.g., the "Phase 1/2/3" list and consequences-of-structural-chaos list). The 3 articles with zero mid-body bullets are `snowflake-vs-databricks.md`, `long-game-part2.md`, `long-game-part3.md`. |
| 10 | **Bold terms flow into sentences (no standalone definitions)** | 0 standalone bold definitions | 3 total across corpus (all in `snowflake-aws-iac-part2.md`) | ✅ mostly confirmed | Only `iac-part2` has the pattern (`**Modular Design:** Each Snow Fort manages...`). Latest 4 articles (long-game series + ai-coding-agent) consistently flow bold into prose. |
| 11 | **AI-tells: "here's the thing", "let's dive in", "that said", "moreover", "furthermore", "in conclusion", "it's worth noting"** | 0 uses | 3 uses (2× "here's the thing", 1× "let's dive in") | 🟡 partial | "Here's the thing, though" in `long-game-part2.md` "Note on Process" coda (L114); "Here's the thing that anyone who has ever tried to scale a product already knows" in `long-game-part3.md` (L68); "Let's dive into the code" in `snowflake-aws-iac-part2.md`. Both "here's the thing" uses are in the most recent, most polished articles — i.e., the phrase has crept back in. |
| 12 | **Every piece needs a central metaphor running through it** | Metaphor spine in each article | Strong yes in 7/10; weak/multiple in 3/10 | ✅ mostly confirmed | Strong spine: cars/Top Gear (Snowflake vs Databricks both), Toyota Hilux (revisited), Forts (iac-part2), Scrapyard Satellite vs Modular Station (ai-coding-agent), Fire-warden/Steward (long-game), Tornado/Felt Consequences (long-game-part2), NICU/Calm Connect Coach + Rails-as-shared-context (long-game-part3). Weak: `iac-part1` is pure tutorial. `ai-efficiency-trap` has "blast radius" but it's a single phrase, not a spine. `being-told-i-could-be-fired` has Sheldon Cooper Syndrome + Navy SEALs, not a single spine. |
| 13 | **Don't mix metaphors within an article** | Single coherent metaphor family | 8/10 hold; 2 mix | ✅ mostly confirmed | Mixers: `long-game-part3.md` (NICU + spirited child + Rails/Fowler — three distinct domains, but they're chained to support the "shared context" thesis rather than competing); `being-told-i-could-be-fired.md` (Sheldon Cooper + Navy SEALs + The Apprentice). Both still feel coherent because they all serve one thesis. |
| 14 | **Set the scene before bold claims (foreshadow)** | Story-first opens | 8/10 articles open with story or personal hook | ✅ confirmed | Strong: `snowflake-vs-databricks-revisited.md` opens "A few weeks ago, I published an essay...I was wrong. On two counts."; `ai-efficiency-trap.md` opens "I have always been a testing pragmatist."; `long-game-part2.md` opens "I was going to write a very different article." Counter-examples: `iac-part1.md` (opens with abstract complaint about Terraform); `the-long-game.md` (opens with the news of the Data Superhero announcement, then dives right into the abstract "Hypothesis" — but this works because the news IS the hook). |
| 15 | **Specific details over vague claims** | Numbers, names, timeframes throughout | Consistent | ✅ strongly confirmed | "Three pounds, fourteen ounces" (NICU baby); "billions of rows and terabytes of data"; "twelve and thirteen hours a day"; "$50,000 Snowflake bill"; "STATEMENT_TIMEOUT_IN_SECONDS to 3600"; "600 seconds (the default)"; "nineteen-year-old daughter, a three-year-old son, and a six-month-old daughter" — this rule holds beautifully and is one of Noah's most distinctive moves. |
| 16 | **Vary sentence length / rhythm that breathes** | Mixed sentence lengths | Mean sentence length 13.0–26.7 words/article, corpus mean 21.0 | ✅ confirmed | Long-game series has shorter average sentences (13.0–13.4); pre-2026 articles run longer (18.7–26.7). Articles do mix punchy short sentences ("I was wrong.", "It didn't have wisdom.") with longer narrative ones, regardless of overall mean. |

## Patterns the Skill Misses (Should Become Rules)

These appeared as strong, repeatable signatures in the corpus that **aren't currently codified**:

### M1. The "I was wrong" / self-correction opener
Multiple articles begin by undermining the author's prior position: `snowflake-vs-databricks-revisited.md` opens "I was wrong. On two counts." `long-game-part2.md` opens "I was going to write a very different article." `ai-coding-agent-architect.md` Origin Story section: "I didn't actually set out to build a standalone architectural linter." `ai-efficiency-trap.md` Origin Story: "I didn't actually set out to build a standalone pytest plugin." This is a high-frequency, signature move worth naming explicitly.

### M2. The "Origin Story" sub-section
Three articles (`ai-efficiency-trap.md`, `ai-coding-agent-architect.md`, and implicitly `long-game-part2.md`) include a literal subhead called "The Origin Story" or "The Hypothesis". The shape is: "I built X because I needed Y for Z. Then Z broke. So I built X." This is a structural pattern worth recognizing.

### M3. Bold for emphasis WITHIN flowing sentences (not just on terms)
The current rule says bold should be "key terms as visual landmarks." Actual practice: Noah also bolds **whole phrases** for emphasis inside sentences ("**But then I looked at the code.**", "**So here's your move.**", "**Take command of your AI agent today:**"). This is a separate use of bold and currently uncovered.

### M4. The "Family/Personal anchor → professional pivot" structure
Every Long Game article uses this: opens with a family/parenting story (tornado, NICU, spirited child), pivots to a professional/architectural lesson. Even `being-told-i-could-be-fired.md` (2022) uses Sheldon Cooper Syndrome as the anchor. The pattern is: lived experience → metaphor bridge → professional insight → CTA. Worth naming.

### M5. The "Your move" CTA pattern
Both `long-game-part2.md` ("**So here's your move.**") and `long-game-part3.md` ("**Your move:** In Part 2, I asked you...") use the literal "your move" CTA framing. This is a more specific and recognizable signature than "have a CTA" generically.

### M6. References to specific cultural artifacts and characters by name
Noah names specific shows/books/movies that anchor metaphors: Top Gear, The Wild Robot, Turn the Ship Around, Big Bang Theory's Sheldon Cooper, Toyota Hilux, DeLorean DMC-12, Captain Marquet/USS Santa Fe, Matt Shumer, DHH/Rails, Martin Fowler, Mary Sheedy Kurcinka, Roz/Brightbill, Capital One. This specificity is signature. The voice-rules document mentions "ELI5 without condescending" but doesn't name this concrete-cultural-anchor pattern.

### M7. Family ages are repeated verbatim across articles
"a nineteen-year-old daughter, a three-year-old son, and a six-month-old daughter" appears nearly verbatim in `long-game.md`, `long-game-part2.md`, and the framing of `long-game-part3.md`. This is a deliberate anchoring device. Worth codifying as: "family ages are part of your byline, write them out in words, keep them current."

### M8. Em dashes ARE actually present and tolerated in real writing
The data is unambiguous: 46 em dashes across 7 of 10 articles, including in articles Noah is proud of and in the SKILL's own exemplar (`snowflake-vs-databricks.md` has 2). The "Not one. Not ever." formulation is aspirational, not descriptive of actual practice. (See "Top 5 rules that don't hold" below.)

### M9. Italic body text for "Note on Process" disclosures
The Long Game Part 2 and Part 3 both end with an italicized "A Note on Process" / process disclosure naming Claude. This is a distinctive recent pattern (the AI-disclosure norm) and not covered.

### M10. Numbered step instructions in tutorial articles
`snowflake-aws-iac-part1.md` and `iac-part2.md` are step-by-step tutorials with numbered headers (Step 1, Step 2…). The "no bullets" rule shouldn't apply to tutorial-style articles. The rule needs a genre split.

## Top 5 Rules That Hold Strongly

1. **Banned words "honestly / to be honest / navigate / landscape / leverage"** — 0 uses across 13k words. This ban is fully internalized.
2. **Specific details (numbers, names, timeframes)** — Pervasive. The strongest single signature of the voice.
3. **Bold flows into sentence content (no standalone definitions)** — 0 violations in the 4 most recent articles; only 3 violations corpus-wide, all in one tutorial.
4. **Central metaphor spine per article** — 7 of 10 articles have a clearly identifiable spine. Even when not perfect, the intent is clearly present.
5. **Story-first / set the scene before bold claims** — 8 of 10 open with a personal hook or narrative.

## Top 5 Rules That Don't Hold (Concrete Edits Proposed)

### V1. "No em dashes. Not one. Not ever." → REWRITE
**Reality:** 46 em dashes across the corpus, in articles Noah explicitly endorses as exemplars.

**Proposed rewrite (for `voice-rules.md`):**
> ### Em dashes: use sparingly, never as a substitute for clearer punctuation
> Em dashes (—) are not banned, but they are easy to overuse and a common AI tell. Cap at 3 per article. Prefer commas, colons, or restructuring. If you find yourself using an em dash to chain a parenthetical, ask whether a comma pair or parentheses would work first. The em dash is for genuine interruption (`I realized — too late — that...`), not for everything.

### V2. "Single-sentence paragraphs max 2 per article" → REWRITE
**Reality:** Mean 11.6/article; minimum 4. Single-sentence paragraphs are a *load-bearing* part of the voice, not a guarded resource.

**Proposed rewrite:**
> ### Single-sentence paragraphs are a tool, not a luxury
> Noah uses single-sentence paragraphs liberally as landings, beats, and rhythm-breakers. Use them whenever a sentence needs to land harder than its neighbors would let it. The actual restraint is on *empty* single-sentence paragraphs — bare transitions like "Let's dive in." or "But there's more." The rule isn't "max 2 per article"; it's "every single-sentence paragraph must carry weight."

### V3. "No bullet lists in article body" → SCOPE BY ARTICLE TYPE
**Reality:** 83 bullet lines across 10 articles; 7 articles use mid-body bullets. Tutorial articles depend on them.

**Proposed rewrite:**
> ### Bullets: avoid in essay-style articles; use freely in tutorials and lists of discrete items
> For essay-format pieces (Long Game series, opinion articles, "why I built X"), avoid bullets in the article body. Convert lists into flowing prose. For tutorial articles, how-tos, comparison articles with discrete option-sets, or explicit CTA sections, bullets are fine. The test: if the items have narrative connective tissue between them, write prose. If they're truly parallel discrete items (commands, settings, options), bullets are clearer.

### V4. "Use 'frankly' instead of 'honestly/to be honest'" → KEEP BUT SOFTEN
**Reality:** "Frankly" appears only twice corpus-wide; "honestly"/"to be honest" appear zero times. The replacement rule is essentially never triggered in practice.

**Proposed rewrite:**
> ### "Frankly" is the only acceptable hedge word
> Drop "honestly" and "to be honest" entirely. If the sentiment is genuinely needed, "frankly" is the only word for it. (In practice you'll rarely need any of them.)

### V5. Banned words "genuinely / straightforward / delve" → KEEP THE BAN, ADD SELF-CHECK STEP
**Reality:** 5 total uses of these three words. The ban is *mostly* working, but slippage exists.

**Proposed rewrite:** keep the rule as-is, but add to the SKILL.md self-check step: "explicitly grep for each banned word before delivering — recent articles have leaked 'genuinely' and 'straightforward' through."

## Recommended Plugin Updates (Mechanical Edit Instructions)

These are pasted as instructions a follow-up task can execute against `noah-writing-voice/skills/noah-voice/references/voice-rules.md` and `SKILL.md`. Line numbers refer to the file at HEAD (commit 84c36b0).

### Edit A — Replace em-dash absolutism (voice-rules.md L10)

```
OLD: - **No em dashes.** Not one. Not ever. Use commas, colons, semicolons, parentheses, or restructure the sentence. If you catch yourself reaching for an em dash, stop and rewrite.
NEW: - **Em dashes: cap at 3 per article.** Em dashes (—) are a common AI tell and easy to overuse. Prefer commas, colons, or restructuring. Use only for genuine interruption ("I realized — too late — that..."), never to chain parentheticals.
```

Also update SKILL.md L25 from `1. **No em dashes.**` to `1. **Em dashes: cap at 3 per article.**` and L52 from `1. Search for em dashes and replace them` to `1. Count em dashes; if more than 3, replace the weakest ones with commas/parens.`

### Edit B — Loosen single-sentence-paragraph limits (voice-rules.md L15)

```
OLD: - **Single-sentence paragraphs are expensive.** An article gets at most 2. A LinkedIn post gets at most 1. Spend them only on lines that genuinely earn the pause. If a sentence doesn't land harder by standing alone, fold it into its neighbors.
NEW: - **Single-sentence paragraphs are a rhythm tool.** Use them freely as landings and beats — Noah averages 11 per article. The actual constraint: every single-sentence paragraph must carry weight (a landing, a punchline, a beat). Reject *empty* single-sentence paragraphs that exist only to transition ("Let's dive in." "But there's more.").
```

Also update SKILL.md L30 and L54 to match.

### Edit C — Scope the bullet ban by article type (voice-rules.md L17)

```
OLD: - **No bullet-point lists in article body.** The only exception is explicit CTA (Call to Action) sections at the end of a piece. If you're tempted to use bullets mid-article, convert to flowing prose.
NEW: - **Bullets: avoid in essay-format articles; use freely in tutorials, comparisons, and CTA sections.** For Long-Game-style essays, opinion pieces, and "why I built X" narratives, convert mid-article lists to prose. For step-by-step tutorials, option/comparison breakdowns, or explicit CTA blocks, bullets are clearer than prose. Test: do the items have narrative connective tissue (yes → prose) or are they truly parallel discrete items (yes → bullets)?
```

### Edit D — Add 5 new rules (append to voice-rules.md after L37)

```
### Signature Structural Moves

- **The "I was wrong" / self-correction opener.** Many of Noah's strongest articles begin by undermining a prior position: "I was wrong. On two counts." (Databricks Revisited); "I was going to write a very different article." (Wisdom Gap); "I didn't actually set out to build a standalone X." (Efficiency Trap, Architect). This builds trust before any claim.

- **The "Origin Story" sub-section.** When introducing a tool or framework, name a subhead "The Origin Story" or "The Hypothesis" and follow the shape: "I built X because I needed Y for project Z. Then Z broke. So I built X."

- **Family anchor → professional pivot.** Open with a parenting/family story, bridge through a metaphor, land on a professional insight. The Long Game series does this every article. Family ages should be current and written out: "a nineteen-year-old daughter, a three-year-old son, and a six-month-old daughter."

- **Concrete cultural anchors.** Name specific shows, books, characters, vehicles, people — Top Gear, The Wild Robot, Toyota Hilux, DHH/Rails, Captain Marquet, Sheldon Cooper. Generic "many leaders" or "popular culture" doesn't land; named references do.

- **"Your move" CTAs.** When closing with a call to action, the bolded phrase "**So here's your move.**" or "**Your move:**" is a recognizable signature. Use it when the CTA is a single concrete ask.

### Bold for Emphasis (not just terms)

- **Bold can carry whole phrase emphasis, not just term-labeling.** "**But then I looked at the code.**" "**So here's your move.**" "**Take command of your AI agent today:**" These are landing-phrase emphasis, distinct from the "**Term**, defined inline" pattern. Both uses are valid.

### AI-disclosure coda (Snowflake Builders Blog articles)

- **End with an italicized "A Note on Process" or process disclosure** when AI collaborated on the piece. Long Game Part 2 and Part 3 both close with this. Format: italicize, name the collaborator (Claude), state what came from you vs what came from the partnership.
```

### Edit E — Update SKILL.md Self-Check Before Delivering (SKILL.md L48–58)

```
OLD: 1. Search for em dashes and replace them
NEW: 1. Count em dashes; if more than 3 in the article, replace the weakest ones

OLD: 3. Count single-sentence paragraphs (max 2 for articles, 1 for posts)
NEW: 3. Audit each single-sentence paragraph: does it land/punch/beat? If not (it's a transition or filler), fold it into a neighbor.

OLD: 6. Look for AI-style transitions ("Here's the thing," "Let's dive in," "That said") and remove them
NEW: 6. Look for AI-style transitions ("Here's the thing," "Let's dive in," "That said," "Moreover," "Furthermore," "In conclusion," "It's worth noting") and remove them. NOTE: "Here's the thing" has slipped into recent articles — grep for it explicitly.

ADD as step 8: 8. Verify family ages are correct and written out in words if mentioned.
ADD as step 9: 9. If this is a Snowflake Builders Blog article and AI collaborated, end with an italicized "A Note on Process" disclosure.
```

## Verdict Summary

The skill captures Noah's voice well at the **structural** level (story-first, metaphor spine, specific details, confidence with receipts) and well on **most banned words** (honestly, navigate, landscape, leverage, delve — strong holds). It fails at the **micro-rule absolutism** level: em-dash zero-tolerance, single-sentence-paragraph quotas, and blanket bullet bans don't reflect actual practice. It also **under-specifies** several distinctive moves Noah uses repeatedly (the "I was wrong" opener, the family-to-professional pivot structure, the "Your move" CTA, the AI-disclosure coda).

**Recommendation:** the skill needs calibration on the strict-numerical rules and *additions* for the missed structural patterns. The aesthetic intent of the existing rules is right — they correctly identify what makes the voice distinctive. The numbers are just wrong, and several patterns are missing.
