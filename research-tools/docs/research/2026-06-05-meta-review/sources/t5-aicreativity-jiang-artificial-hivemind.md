# Source: Jiang et al. — "Artificial Hivemind": Inter-Model and Intra-Model Homogeneity in LLM Creativity

**Full citation:** Jiang, Liwei et al. (University of Washington, Carnegie Mellon University, Allen
Institute for AI). Study on LLM creative homogeneity ("Artificial Hivemind"), as reported by
The Decoder, June 2026.
**URL:** https://the-decoder.com/study-warns-ai-could-homogenize-human-creativity-as-models-converge-on-artificial-hivemind/
**Date accessed:** 2026-06-06
**Evidence level:** 3 (Large-scale observational/benchmark study across 25 models; reported via
secondary tech-press coverage rather than the primary paper)
**Research topic area:** AI + creativity — inter-model + intra-model homogeneity (the supply-side
of homogenization)

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 7/10 | Primary authors are strong NLP researchers (UW/CMU/AI2); but evidence here is via The Decoder, a credible tech outlet, not the paper itself — knocked down for the intermediary. |
| 2 | Evidence Quality | 7/10 | Systematic benchmark across 25 models × 50 responses with embedding-similarity metrics; quality strong, but only as relayed secondhand. |
| 3 | Currency | 10/10 | June 2026; the most current model coverage in the track. |
| 4 | Intent | 8/10 | Academic study; tech-press framing is explanatory, low commercial intent. |
| 5 | Bias & Objectivity | 7/10 | Headline leans alarmist ("hivemind"); underlying metrics appear neutral. Scored harder — I agree with the homogenization thrust. |
| 6 | Logic & Coherence | 7/10 | Similarity clustering → homogenization claim is sound; "homogenization of human thought" is an extrapolation. |
| 7 | Corroboration | 8/10 | Inter-model similarity corroborates Wharton's "same distribution" account and Doshi/Hauser. |
| 8 | Intellectual Honesty | 7/10 | Reports concrete similarity numbers; the human-thought leap is speculative and flagged as a warning. |
| 9 | Specificity | 8/10 | 25 models, 50 responses each; DeepSeek-V3↔GPT-4o 81% similarity; two metaphor clusters ("river"/"weaver"). |
| 10 | Relevance | 9/10 | Establishes that homogenization originates partly on the SUPPLY side — models themselves converge — independent of how humans use them. |

**Composite score:** 7.50

## Bias Guard Check

- [x] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [ ] Neutral / no strong reaction

## Key Findings

- Homogenization exists at TWO levels independent of the user: intra-model (one model repeats
  itself across runs) and inter-model (different vendors' models produce near-identical outputs).
- Across 25 models generating 50 responses each to "write a metaphor about time," only two dominant
  clusters emerged ("time is a river," "time is a weaver") — extreme convergence.
- Cross-vendor similarity is high: DeepSeek-V3 vs GPT-4o ~81% average similarity; DeepSeek-V3 vs
  qwen-max-2025 ~82%; "in nearly four out of five test cases, responses from the same model were so
  similar they were barely distinguishable."
- Authors warn of "gradual homogenization of human thought" if users converge on these outputs,
  potentially suppressing "alternative worldviews and traditions."
- Design lesson: relying on a single model — or even multiple frontier models — does NOT guarantee
  diversity, because the models themselves are correlated. Diversity must be engineered ON TOP of
  the model pool (cf. Deng/Brucks/Toubia personas+CoT; epistemic-diversity-across-models work).

## Verified Quote(s)

**Location reference:** The Decoder article body, paragraphs describing the metaphor test and
product-description similarity.

> in nearly four out of five test cases, responses from the same model were so similar they were
> barely distinguishable

> gradual homogenization of human thought

**Access status:** cached/partial — The Decoder article fetched live; primary paper not directly
accessed, so similarity figures are as reported by the outlet.

## Inclusion Decision

**Decision:** Supporting
**Rationale:** Adds the supply-side dimension (models converge with each other, not just humans
anchoring on models). Strong corroboration for the homogenization mechanism but relayed secondhand,
so Supporting rather than Core.

**Redundancy check:** Not redundant — every other source studies human-AI interaction; this isolates
model-to-model convergence as an upstream cause.

**Perspective category:** Contrarian
