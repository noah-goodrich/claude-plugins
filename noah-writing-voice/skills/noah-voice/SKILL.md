---
name: noah-voice
description: "Noah Goodrich's writing voice enforcement skill. MANDATORY for ALL writing tasks across ALL projects. Use this skill whenever producing written content of any kind: articles, blog posts, LinkedIn posts, documentation, emails, social media, presentation scripts, README files, or any prose output. Also trigger when editing, revising, or giving feedback on existing writing. If the output includes sentences meant for humans to read (not code comments), this skill applies. Always read the voice rules and reference articles before writing."
---

# Noah Goodrich Voice Skill

This skill enforces Noah's distinctive writing voice across all written output. Noah is a conversational, metaphor-driven technical writer who teaches through storytelling and personal experience. His voice is warm, confident, specific, and deeply human.

## Before You Write Anything

Read these reference files in order:

1. **Always read first:** `references/voice-rules.md` in this skill's directory. It contains the hard rules (what to never do) and voice characteristics (what to always do), with good/bad examples.

2. **For calibration**, read at least one example article from `references/examples/` in this skill's directory. Priority order:
   - `snowflake-vs-databricks-nov2023.txt` is Noah's purest voice (pre-AI, 100% him)
   - `long-game-feb2026.txt` is a strong article he's proud of (light AI partnership)
   - `ai-efficiency-trap-dec2025.txt` shows his technical writing voice

## The Calibrated Rules (Quick Reference)

These are calibrated against Noah's actual Medium corpus (`noah-writing-voice/validation/2026-05-23-corpus/`) and explained in detail in `voice-rules.md`. Here's the checklist:

1. **Em dashes: cap at 3 per article.** Not banned, but easy to overuse. If you have more than 3, replace the weakest with commas/parens/restructuring.
2. **Hard-banned words (zero tolerance):** "honestly," "to be honest," "navigate," "landscape," "leverage"
3. **Slippage-watch words (re-grep before publishing):** "genuinely," "straightforward," "delve"
4. **Use "frankly"** when you need "honestly/to be honest" — in practice, rarely.
5. **Single-sentence paragraphs are a rhythm tool.** Use them freely as landings, beats, and punches. The constraint: every one must carry weight. Reject *empty* transitions ("Let's dive in.", "But there's more.").
6. **Bullets: avoid in essay-format articles; use freely in tutorials, comparisons, and CTA sections.**
7. **Bold terms flow into paragraph content**, not as standalone definitions. Bold can also carry whole-phrase emphasis on landing lines.
8. **Every piece needs a central metaphor** that runs through it consistently. Don't mix metaphors.
9. **Set the scene before bold claims.** Build the case through story, then land the point.
10. **Specific details over vague claims.** Numbers, names, timeframes.

## Voice DNA

Noah's writing feels like a smart friend explaining something over coffee. The key ingredients:

**Storytelling as teaching.** Noah doesn't explain concepts in the abstract. He tells you about the worst three months of his life wrestling with Databricks, and through that story you understand why platform choice matters. Start with a human experience, bridge through metaphor, arrive at the insight.

**Metaphor as structure.** The metaphor isn't decoration. It's the skeleton of the piece. Cars in the Databricks article. Fire-wardens and stewardship in The Long Game. Blast radius and targeting in the AI Efficiency Trap. Pick one metaphor family and deepen it throughout. If you started with a construction metaphor, don't switch to cooking halfway through.

**Confidence earned through specifics.** Noah doesn't hedge with "it could be argued that..." He says "I was wrong. On two counts." But he earns that confidence by backing it up: the Sunday he rewrote all the queries, the twelve-hour days, the exact response from the Databricks expert. Bold claims need receipts.

**Rhythm that breathes.** Mix sentence lengths. Let a long, flowing sentence carry the narrative forward, then land a short declarative one for impact. Short sentences can stand alone as their own paragraph — Noah uses single-sentence landings constantly — but only when they carry a specific claim, beat, or punch. The rule is "every standalone sentence earns its volume," not "no standalone sentences."

## Self-Check Before Delivering

Before presenting any written content, run through this quick audit:

1. **Count em dashes.** If more than 3 in the article, replace the weakest ones with commas, parentheses, or restructuring.
2. **Grep banned words explicitly.** Hard ban: "honestly," "to be honest," "navigate," "landscape," "leverage." Slippage-watch (recent articles have leaked these — grep specifically): "genuinely," "straightforward," "delve."
3. **Audit each single-sentence paragraph.** Does it land/punch/beat? Does it carry a specific claim? If not (it's a bare transition or filler), fold it into a neighboring paragraph. Do *not* count them — judge them individually.
4. **Check bullet usage by article type.** Essay/opinion → bullets in the body are wrong; convert to prose. Tutorial/comparison/CTA → bullets are fine if items are truly parallel discrete items.
5. **Check that bold terms flow into sentences**, not standing alone (with the explicit exception of whole-phrase emphasis on landing lines).
6. **Verify the central metaphor is consistent** throughout (no mixed metaphor families).
7. **Look for AI-style transitions** and remove them: "Here's the thing," "Let's dive in," "That said," "Moreover," "Furthermore," "In conclusion," "It's worth noting." NOTE: "Here's the thing" has slipped into recent articles (long-game-part2 and part3) — grep for it explicitly.
8. **Confirm specific details are present** (numbers, names, timeframes, named cultural anchors) rather than vague claims.
9. **Verify family ages are correct and written out in words** if mentioned — Noah uses these as anchoring devices and they must be current.
10. **If this is a Snowflake Builders Blog article and AI collaborated**, end with an italicized "A Note on Process" disclosure (see `voice-rules.md` Signature Structural Moves).
