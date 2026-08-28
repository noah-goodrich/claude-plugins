# ai-scoring evaluation set

## What this is for

The `ai-scoring` skill decides whether prose reads as machine-written, and it currently flags 5 of Noah's 10
published articles as machine-written. Before anyone can recalibrate it, there has to be something honest to
calibrate against: documents whose authorship is known because it was recorded at generation time, not inferred by
reading them. This directory holds that evaluation set, the generator that produces it, and a harness that reports
against it without overstating what the sample can carry.

Three populations:

- **human** — Noah's 10 published articles at `noah-writing-voice/validation/2026-05-23-corpus/articles/`. These
  are not re-tagged and not modified. The harness treats that directory as `class: human` implicitly.
- **generic** — model prose from several providers under ordinary prompting. No "write like an AI" instruction, no
  seeding from any word list.
- **voiced** — Claude drafting in Noah's voice with the `noah-voice` skill loaded.

Every generated document carries frontmatter recording its class, provider, exact model id, generation date, word
target, the human article it is matched to, and the verbatim prompt that produced it. Provenance here is a record,
not a judgement call.

## Why the old corpus is unusable

The negative half of the 2026-05-23 corpus is five files under `validation/2026-05-23-corpus/ai-samples/`, and no
accuracy number computed against them means anything, because they were written out of the rubric's own
banned-word lists. The contamination is measurable: as measured on 2026-08-26 those five files carry 7.14-8.33
rubric hits per 100 words against 0.00-0.55 in Noah's real articles — an order of magnitude apart with no overlap
at all. That measurement used a wider term list than the rubric prose carries, so this harness reports different
absolute poles (roughly 5.1-6.1 against 0.00-0.28); the separation is the same, the scale is not. Compare like
with like by reading both poles off the same `--contamination` run. An ablation
settles what that buys the scorer. The literal word-matching categories alone separate the two classes at
AUC 1.000, while the structural categories alone reach 0.220, which is worse than a coin flip. So every point of
measured discrimination is keyword lookup, and the reported recall of 1.000 restates how the fixtures were typed
rather than reporting anything about the scorer. Length is a second contamination on top of that: the fixtures run
390-430 words against Noah's 739-2,595, so word count alone also separates the classes at AUC 1.000, and every
unnormalised counter in the rubric inherits it. The old corpus cannot be repaired by adding files to it. It has to
be replaced by one whose provenance was recorded rather than assumed.

## The two negative classes

**`generic`** answers "does the rubric recognise ordinary model prose?" It spans Anthropic, Google, and Snowflake
Cortex, so a result is a property of machine prose rather than of one vendor's house style.

**`voiced`** answers "does the rubric flag Claude writing the way it is actually asked to write here?" This is the
class that matters most, and it is the one the old evidence base has nothing to say about. The gate does not run
on unprompted model prose. It runs inside `snowflake-article` and `linkedin-post`, on Claude drafting in Noah's
voice with `noah-voice` loaded — a population that appears in neither the human corpus nor the old fixtures.
Everything previously measured was measured on documents nobody will ever submit to the gate.

One consequence, stated up front so the report never blurs it: `voiced` is all-Anthropic by construction, because
that is what the deployed population is. That makes it the right evidence about the gate's real workload and the
wrong evidence about machine prose in general. The harness reports the classes separately and never pools them.

## Running generation

Generation is the only part of this directory that touches the network, and the only part that costs money.

```bash
bash evals/generate/generate.sh --help
bash evals/generate/generate.sh
```

`generate.sh` is a dry run by default. Invoked with no arguments it prints the documents it would write and the
volume it would generate, then exits without calling any provider. Writing for real is an explicit flag; the
script's `--help` is the authority on the current flag set.

Providers live in `evals/generate/providers/`, one script per API — `anthropic.sh`, `gemini.sh`, `cortex.sh` —
each reading credentials from the environment. Cortex may not authenticate non-interactively on every machine. If
it does not, the run proceeds with two providers and the provenance check reports two, rather than the provider
count being quietly redefined to whatever succeeded.

Topics come from `evals/spec/topics.json`: one entry per human article, carrying a neutral topic string and the
word target taken from that article's actual length. The topic strings describe subject matter and nothing else.
Adding a style instruction to one of them would reintroduce exactly the contamination this directory exists to
remove.

## Running the harness

The harness is Python 3 standard library only, makes zero network calls, and depends on no clock and no global
state. Exit codes are uniform: `0` success, `1` gate failure, `2` usage error.

```bash
python3 evals/harness/split.py --seed 20260827
python3 evals/harness/evaluate.py --contamination
python3 evals/harness/evaluate.py --report
python3 evals/harness/evaluate.py --held-out
bash evals/test/run-tests.sh
```

- **`split.py --seed <int>`** writes `evals/corpus/manifest.json` with the calibration and held-out membership, the
  seed that produced it, and a seal recording a content hash, a use counter, and the date it was sealed.
  Membership is deterministic from the seed, so two runs agree.
- **`evaluate.py --contamination`** prints rubric-term density per class and exits `1` if any class exceeds 1.0
  hits per 100 words. This is the check that would have caught the old corpus.
- **`evaluate.py --report`** prints the calibration-set report. Every rate carries a Wilson 95% interval; the
  harness refuses to report at all if either negative class is missing.
- **`evaluate.py --held-out`** reports the sealed split. It refuses if the seal's use counter is already above
  zero, and refuses if a held-out file's content no longer matches the recorded hash. `--break-seal` overrides,
  deliberately loudly, because a held-out set spent twice is a calibration set.

## LIMITS

What this corpus can and cannot support. Read this before quoting any number out of the report.

- **It cannot give you a false-positive rate to within ±10 points.** That precision needs roughly 35 human
  documents. There are 10, and there is no honest way to get more from this source. On 10 documents, an observed
  1-in-10 false-positive rate has a Wilson 95% interval running from about 2% to about 40%. Nobody should set a
  threshold from that. This is why every rate in the report carries its interval, and why the report states how
  many documents the interval a reader wants would actually require.
- **It cannot tell you whether the rubric detects machine prose in general.** `voiced` is one vendor by design.
  `generic` spans whichever providers authenticated — three when Cortex is available, two when it is not, per the
  note above — at a handful of documents each. Treat both as evidence about this gate on this workload, not as an
  AI-detection benchmark.
- **It cannot use `voiced` to validate the rubric.** The `voiced` prompt injects `noah-voice/SKILL.md` and
  `references/voice-rules.md` verbatim, and those files tell the model much of what the rubric is about to score
  it on. Lexically the overlap is exact: 9 distinct rubric terms appear in `SKILL.md`, 8 in `voice-rules.md`, 9
  across the two, out of the 24 terms the rubric scores on. Structurally it is broader but uncountable — four of
  the six structural categories have a counterpart in the injected text, and category 7 shares two example
  strings with it verbatim. Counting generously, six of the rubric's eight categories are represented in the
  prompt. That is the old corpus's contamination with the sign flipped: the retired fixtures were written *from*
  the answer key, and `voiced` documents are written *against* it. So a near-zero contamination score on `voiced`
  is not independent evidence the sample is clean, because the prompt partly causes it, and any discrimination
  the rubric shows on `voiced` is substantially a measurement of instruction-following rather than a property of
  machine prose. The injection stays, because the deployed path really does load `noah-voice` before gating on
  `ai-scoring`, so this is the population the gate serves. What it costs is stated in full, with the measured
  numbers, the per-category mapping, and a reproduction command, in `evals/generate/prompts.md`.
- **It cannot be mined for a threshold.** The held-out split is sealed for exactly one use. Repeatedly consulting
  it turns it into training data, which is the failure that produced the current situation.
- **It cannot certify the human class as clean of AI influence.** These are Noah's published articles, published
  over four years, some written while using AI tools. "Human" here means "authored and published by Noah", which
  is a provenance claim, not a purity claim.
- **It cannot be grown by collecting suspected-AI writing from the web.** Provenance is unknowable by reading —
  that is the central research finding — so a set built from "this looks AI to me" would bake in the prior this
  work exists to remove. Growing the negative side means generating more and recording it.
