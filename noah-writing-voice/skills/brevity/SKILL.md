---
name: brevity
description: "Brevity and structure for scanning documents: design docs, PR bodies, directives, status updates, and chat replies. Use whenever writing something a reader triages in under two minutes rather than reads start to finish, or when reviewing such a document for length, structure, or tl;dr placement. Carries the portable voice spine extracted from noah-voice. Articles, blog posts, and LinkedIn posts are not scanning documents and use noah-voice instead."
---

# Brevity

**tl;dr** — A scanning document is triaged, not read. Front-load the one thing, put depth behind a link, and place
the tl;dr where the medium delivers it: top for documents, bottom for chat.

## Scope

This skill covers five artifacts: design docs, PR bodies, directives, status updates, and chat replies. It does
not cover articles, blog posts, or LinkedIn posts. Those are reading documents and they load `noah-voice`
unchanged.

Read `references/portable-voice.md` before drafting. It is the prose spine for this genre: the eighteen
`noah-voice` rules that survive the genre change, plus the seven article-only rules that are excluded and why.
This file governs structure; that file governs sentences.

## Mode: document or chat

One mechanical rule, no judgment call. **Content being written to a file path is a document. Everything else is
chat.**

- **Document.** The tl;dr goes at the **TOP**, above any evidence: two lines, one sentence of problem and one of
  solution, readable with no prior context.
- **Chat.** The tl;dr goes at the **BOTTOM**, two lines, after the work.

Two named exceptions, because they are the ambiguous cases:

- A PR or issue body is a **document** even when you paste it rather than write it to disk. It renders as a
  scrolled page.
- A code comment is neither. It is code.

Why the split: documents are scanned top-down and abandoned early, so the conclusion has to be above the fold.
Chat streams, so the reader consumes the work as it arrives and needs the summary last — "he waits for streaming
to finish, skims up to find the start, reads down typing feedback, and loses his place if he submits early"
(borg-collective/docs/plans/directives/2026-08-20-communication-program.md:15-17).

## The rules

**Front-load the one thing.** The single most important fact goes first. If the reader stops after the tl;dr,
they still know what you decided and why it matters.

**One explicit why-it-matters line.** Exactly one, stated outright rather than implied, and it names who is
affected or what breaks without it. Not three, not zero.

**Depth goes to a linked "go deeper," never the body.** Benchmarks, transcripts, full option matrices, and long
evidence get a link or a sibling file. The body carries the decision and the receipt, not the derivation. The
length cap and its measured word target are `references/portable-voice.md` rule 12.

**Bullets over prose past two facts.** Two facts can be a sentence; three or more get promoted to real bullets.
Full rule, and why it inverts the article rule: `references/portable-voice.md` rule 11.

**Bold labels and load-bearing figures. Never bold for mere emphasis.** A bold span must be doing structural work.
Full rule and the corpus detail behind it: `references/portable-voice.md` rule 10.

**Conditions before instructions.** Write "If the build is red, revert first." Never "Revert first, if the build
is red." The reader who does not meet the condition stops at word three instead of executing the instruction and
then discovering it did not apply.

**Never flatten a real trade-off into a bullet.** This is the documented failure mode of every brevity method. A
genuine two-sided decision gets prose, both sides, and the verdict. Compression is for facts. It is not for
disagreements, and a bullet that hides a contested call costs more than the lines it saved.

## Self-audit checklist

Run all fourteen before delivering, and report what fired: the quoted passage, why it fired, and a concrete
suggested rewrite.

1. **tl;dr placement matches the mode.** Document at the top, chat at the bottom.
2. **tl;dr is two lines or fewer** and is readable with no prior context.
3. **Exactly one why-it-matters line exists**, and it names who is affected or what breaks.
4. **No body section exists only to add depth.** Every one of them changes a decision, or it moves behind a link.
5. **Every run of three or more discrete facts is bulleted**, not stacked in prose with additive connectors.
6. **Every bold span is a label, a field name, a decision, or a figure.** No bold-for-emphasis survives.
7. **Every conditional instruction states its condition first.**
8. **Every rejected alternative ends in a verdict plus the trade-off that killed it.** No "pros and cons," no "it
   depends on your use case."
9. **No real trade-off has been compressed into a single bullet.** Two-sided decisions get prose.
10. **Every claim carries a receipt, or is explicitly labelled as observed.** An unlabelled unreceipted claim is
    the defect; a labelled observation is not.
11. **Banned-word grep is clean.** Command below.
12. **Announced-transition grep is clean.** Command below.
13. **No line exceeds 120 characters** except a URL or an unbreakable code span.
14. **Score with the reduced rubric.** Run `ai-scoring` in **scanning mode**. That skill owns the mode: which
    categories are scored, which are off and why, and how to read the number. Do not restate its thresholds here.
    Treat any nonzero penalty as a review trigger, never a refusal.

Steps 11, 12, 13 and the length cap are mechanical. Run them:

```bash
FILE=path/to/doc.md && \
grep -nEi "genuinely|straightforward|honestly|to be honest|navigate|landscape|leverage|delve|game-changer|cutting-edge|revolutionary|fast-paced world|important to note|synergy|paradigm shift" "$FILE" ; \
grep -nEi "here's the thing|let's dive in|that said|here's the kicker|let me explain|what does this mean|the truth is|worth noting|at the end of the day|the bottom line|but wait, there's more|moreover|furthermore|in conclusion" "$FILE" ; \
awk 'length > 120 {print FILENAME":"FNR" is "length" chars"}' "$FILE" ; \
wc -w "$FILE"
```

Any hit from the first two greps is a defect: delete or replace it. Any hit from `awk` is a wrap violation unless
the line is a URL or an unbreakable code span. `wc -w` over roughly 1,500 words means the document is past the
length cap in `references/portable-voice.md` rule 12 and depth needs to move behind a link.

## Sources

Google developer documentation style guide, `developers.google.com/style/tone` and `/style/highlights`; the Smart
Brevity method and the Columbia Journalism Review critique of it, which is where the flattened-trade-off failure
mode is documented. These names are recorded here for provenance only. Branded lingo never appears in generated
output.
