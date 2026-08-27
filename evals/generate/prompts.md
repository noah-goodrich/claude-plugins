# Generation prompts

This file is the source of truth for the two prompt templates. `generate.sh` extracts them from here at run
time — it does not carry its own copy — so editing a template here changes what gets generated, and the exact
rendered text is recorded verbatim in each document's frontmatter.

## Extraction contract

Each template sits between an HTML comment pair and inside a fenced block:

```
<!-- BEGIN TEMPLATE <name> -->
```text
…template body…
```
<!-- END TEMPLATE <name> -->
```

`generate.sh` keeps every line between the markers except lines beginning with a code fence. A template
therefore may not contain a line that starts with three backticks.

## Placeholders

Substitution is literal string replacement, applied in this order. A placeholder that does not appear in a
template is simply not substituted.

| Placeholder        | Source                                                                       |
| ------------------ | ---------------------------------------------------------------------------- |
| `{{TITLE}}`        | `title` from `evals/spec/topics.json`                                        |
| `{{TOPIC}}`        | `topic` from `evals/spec/topics.json`                                        |
| `{{TARGET_WORDS}}` | `target_words` from `evals/spec/topics.json`                                 |
| `{{VOICE_SKILL}}`  | `noah-writing-voice/skills/noah-voice/SKILL.md`, verbatim                     |
| `{{VOICE_RULES}}`  | `noah-writing-voice/skills/noah-voice/references/voice-rules.md`, verbatim    |

## The two classes

**`generic`** is normal prompting and nothing else. It names the title, the topic, the word target, and the
audience. It says nothing about style, voice, punctuation, paragraph shape, or sounding human, because a
prompt that coaches the model away from its own defaults would produce a sample of our coaching rather than a
sample of machine prose. This class is the control.

**`voiced`** is the same request plus the `noah-voice` rules, reproduced verbatim in the prompt. This models
the population the ai-scoring gate actually runs against: Claude drafting an article with `noah-voice`
loaded. It is deliberately all-Anthropic — that is what the deployed path is — so it is evidence about the
gate's live workload, not evidence about machine prose in general.

## Two judgement calls, stated plainly

### 1. The output-format instruction

Both templates end with an output-format instruction ("return the article body, no preamble"). Without it,
chat-tuned models open with scaffolding like "Certainly! Here's a technical blog post:" — text no author would
publish and no human article contains. Scoring that scaffolding would measure chat framing rather than prose,
and it would flatter the rubric for the wrong reason. The instruction constrains the envelope, not the prose
inside it: it says nothing about diction, rhythm, punctuation, or structure. It is the only instruction in the
`generic` template that is not title, topic, length, or audience, and it is called out here so a reviewer can
contest it rather than discover it.

### 2. The `voiced` prompt contains part of the answer key

The `voiced` template injects `noah-voice/SKILL.md` and `references/voice-rules.md` verbatim, and both files
carry an explicit avoid-list. `voice-rules.md:11` names "genuinely", "straightforward", "honestly", "to be
honest", "navigate", "landscape", "leverage", and "delve"; lines 42-46 quote "Here's the thing" and "Let's dive
in" as examples of bad writing, and gloss "navigate" and "landscape" as buzzwords. Some of those terms are also
terms the `ai-scoring` rubric scores on, so the prompt tells the model part of what it is about to be graded on.

The overlap is measured, not asserted. Against the rubric's own lists, read live by the harness's extractor:

| Injected file               | Distinct rubric terms present |
| --------------------------- | ----------------------------- |
| `noah-voice/SKILL.md`       | 9                             |
| `references/voice-rules.md` | 8                             |
| union of the two            | 9 of the rubric's 24          |

The nine are "delve", "genuinely", "here's the thing", "landscape", "let's dive in", "leverage", "navigate",
"straightforward", and "that said". By rubric category the union is 3 of the 11 category-3 banned transitions and
6 of the 13 category-8 banned words. Reproduce it from the repo root:

```bash
python3 -c '
import sys
sys.path.insert(0, "evals/harness")
from pathlib import Path
import corpus
voice = Path("noah-writing-voice/skills/noah-voice")
for p in (voice / "SKILL.md", voice / "references/voice-rules.md"):
    print(p, sorted(corpus.rubric_term_hits(p.read_text())))
'
```

The word lists are the part that can be counted, but they are not the whole overlap. Four of the rubric's six
structural categories also have a counterpart in the injected text:

- **Category 1, Staccato Rhythm (-20).** The rubric looks for "excessive single-sentence paragraphs, especially
  used as transitions". `voice-rules.md:15` caps an article at two single-sentence paragraphs, and `:16` bans
  "standalone punchy one-liners as transitions" while calling that habit "a classic AI tell". The rubric's
  heaviest category and the voice rule are the same rule, stated twice.
- **Category 2, Too-Clean Parallel Structure (-15).** Its stated fix is "Vary sentence openings"
  (`ai-scoring/SKILL.md:93`); `voice-rules.md:35` is "Vary sentence length".
- **Category 6, Lists Disguised as Prose (-10).** `voice-rules.md:17` bans bullet lists in the article body and
  tells the writer to "convert to flowing prose", which is the conversion category 6 penalises when it is done
  mechanically.
- **Category 7, Lack of Specific/Personal Detail (-15).** `voice-rules.md:36-37` are "Specific details anchor
  credibility" and "Personal stakes matter". These two documents share example strings verbatim: both
  `ai-scoring/SKILL.md:149` and `voice-rules.md:36` use "twelve and thirteen hours a day" and "billions of rows
  and terabytes of data" as the model of a specific detail.

That last pair is the clearest evidence that the rubric and the voice skill are not independent documents.
Categories 4 and 5 are the nearest to untouched, and even category 4 has a loose analogue in the voice text's
"Confident but not arrogant" (`voice-rules.md:27`). Counting generously, six of the rubric's eight categories are
represented in the prompt in some form.

Only categories 3 and 8 can be measured exactly, because only they are word lists. The structural coupling is
real but invisible to the harness's contamination check, which counts lexical lifts and nothing else. The
contamination number therefore understates the coupling on `voiced` by construction, and should not be read as
an all-clear.

**This is the old corpus's contamination with the sign flipped.** The retired fixtures were written *from* the
answer key. `voiced` documents are written *against* it. Two consequences follow, and neither is hypothetical:

- A near-zero contamination score on the `voiced` class is not independent evidence that the sample is clean. The
  prompt partly causes it. The contamination check still earns its keep on `generic`, where nothing in the prompt
  names any term; on `voiced` a low number partly confirms the model followed instructions.
- Any discrimination the rubric shows on `voiced` through the banned-word or banned-transition categories measures
  instruction-following, not a property of machine prose. Those two categories are compromised on this class
  specifically, and that is exactly the failure mode the old fixtures had. Categories 1, 2, 6, and 7 are coupled
  the same way, less exactly and less visibly.

The judgement is to keep the injection anyway, and it is defensible rather than convenient. `voiced` exists to
model the population the gate actually runs against, and the deployed path really does load the voice skill:
`snowflake-article` and `linkedin-post` both load `noah-voice` and then gate on `ai-scoring` at a hard threshold.
Stripping the avoid-list out of the injected text would buy a cleaner measurement of a population that does not
exist. The cost is that `voiced` supports a narrower set of claims than it appears to, so here is the boundary:

- **`voiced` can support** whether the gate, as deployed, flags the drafts the deployed pipeline actually
  produces. That question takes the coupling as part of the system under test rather than as noise, and it is
  the question the gate's owner needs answered. A `voiced` document that still trips the rubric is a real
  finding, because the model was told to avoid the thing and failed.
- **`voiced` cannot support** any claim that the rubric detects machine prose. Six of its eight categories are
  represented in the prompt, so on this class a good score is substantially a compliance measurement. A clean
  `voiced` result is the weakest kind of evidence here, and should never be reported as the rubric working.
- **`voiced` cannot support** a `generic` vs `voiced` gap read as "voice coaching makes prose read as more human".
  The two prompts differ by an instruction that directly names scored terms, so part of any gap is the avoid-list
  being obeyed, and this design cannot separate that part from a genuine change in the prose.

## Templates

<!-- BEGIN TEMPLATE generic -->
```text
Write a technical blog post titled "{{TITLE}}" about {{TOPIC}}. Aim for about {{TARGET_WORDS}} words. The audience is working data engineers.

Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
```
<!-- END TEMPLATE generic -->

<!-- BEGIN TEMPLATE voiced -->
```text
Write a technical blog post titled "{{TITLE}}" about {{TOPIC}}. Aim for about {{TARGET_WORDS}} words. The audience is working data engineers.

Write it in Noah Goodrich's voice, following the rules below. They are the contents of noah-writing-voice/skills/noah-voice/SKILL.md and its references/voice-rules.md, reproduced verbatim.

===== BEGIN noah-voice/SKILL.md =====
{{VOICE_SKILL}}
===== END noah-voice/SKILL.md =====

===== BEGIN noah-voice/references/voice-rules.md =====
{{VOICE_RULES}}
===== END noah-voice/references/voice-rules.md =====

Return the article body as Markdown, starting with the title as an H1. Do not add a preamble, a note about what you are about to write, or any commentary outside the article itself.
```
<!-- END TEMPLATE voiced -->
