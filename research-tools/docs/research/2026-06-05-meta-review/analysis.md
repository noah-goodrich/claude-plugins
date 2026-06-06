# The State of the Art in Research, Brainstorming, and Invention

*Conducted: 2026-06-05 to 2026-06-06*
*Methodology: deep-research v0.1.0*

---

This is a "meta-review": a research project ABOUT how research, brainstorming, and invention are done — by
traditional human methods, by today's AI/agentic systems, and what each gets right and wrong. The goal is to
extract design lessons for anyone building an AI-assisted research or "invention engine." Sixty-two sources were
evaluated across seven tracks, every load-bearing claim was put through adversarial refutation, and a 19-card
citation-verification sample passed with zero failures.

---

## 1. Recommendations

These are the actions a builder of an AI research/invention engine should take. Each starts with a verb, says why
in one clause, and points to the analysis theme that backs it.

**For anyone building an AI research pipeline:**

- **Adopt pre-specification as the spine of the pipeline** — fix the question, what counts as a relevant source,
  and how findings get synthesized BEFORE the agent sees the data, because outcome-aware decisions made after
  seeing results are the single biggest documented way bias steers a conclusion (§4 Theme A; Cochrane, PRISMA).
  Caveat from the refutation pass: pre-specification is one major lever, not the only one — pair it with
  transparency and robustness checks (§4 Theme A).
- **Grade certainty explicitly, do not assert truth** — make the engine output confidence levels (high / moderate
  / low) with the reasons for any downgrade, because rigorous methods do not remove bias, they make a body of
  evidence assessable so a human can judge it (§4 Theme A; GRADE). Expect the grading itself to be partly
  subjective (GRADE inter-rater agreement is only poor-to-moderate), so surface the judgment, do not hide it.
- **Build a real verification stage with an EXTERNAL signal, not blind self-grading** — give the critic tests,
  retrieval, tools, an oracle, or a fresh-context judge, because a model grading its own reasoning blind often
  fails to help and can make answers worse (§4 Theme G; Huang et al. 2024). This is the most important single
  engineering decision in the whole report.
- **Measure statement-level grounding, not citation presence** — check that each generated sentence is actually
  entailed by its cited source, because real, retrievable citations frequently do NOT support the claim attached
  to them (47% unsupported for one frontier system; up to 97.5% for one deep-research mode) (§4 Theme C; §4 Theme
  D; DeepTRACE).
- **Default to self-consistency before any heavier orchestration** — sample several reasoning paths and take the
  majority answer, because it is the cheapest, best-replicated reasoning win and the baseline that multi-agent
  debate fails to reliably beat in the single-model setting (§4 Theme G; Wang et al. 2022).
- **Use multi-agent orchestration for READ/breadth work, single-threaded agents for WRITE/build work** — because
  the gain shows up on parallelizable search at ~15x token cost, while build/coordination tasks need one
  continuous context (§4 Theme G; Anthropic and Cognition agree on this split).
- **Engineer source-quality defenses regardless of architecture** — bias toward SEO-optimized and
  dominant-narrative content is architecture-independent and appears in every system family, so it must be
  designed against, not assumed away (§4 Theme C).

**For anyone building an AI invention / ideation engine:**

- **Treat homogenization as a designed-around property, not a law** — add Chain-of-Thought and diverse "ordinary
  person" personas, because targeted prompting can narrow and on combinatorial-novelty even beat the human
  diversity baseline (§4 Theme E; Deng/Brucks/Toubia 2026). But solve for diversity EXPLICITLY — it is not a free
  byproduct of quality-optimized assistance (Terwiesch).
- **Capture ideas in parallel, asynchronously, with deferred judgment** — because the only robust design lesson
  from 50 years of brainstorming research is that synchronous verbal groups lose to parallel generation, and
  removing that bottleneck (electronic brainstorming, brainwriting) closes or reverses the gap (§4 Theme B).
- **Build the critique step, not just the generate step — and keep a human in the verification loop** — because
  AI invention systems generate fluently but cannot reliably self-assess novelty or correctness, and every
  validated discovery to date used a human (or pre-built robot) to run and check the bench work (§4 Theme F).
- **Demand independent verification before believing any "discovery" headline** — because at least one celebrated
  autonomous-discovery milestone (41 "new" materials) collapsed under independent expert re-analysis to
  essentially zero genuinely new compounds (§4 Theme F; A-Lab / Palgrave).
- **Constrain the model to distilled invention knowledge for inventive tasks, but do not trust the lookup table**
  — TRIZ-style grounding is the closest thing to a deliberate invention primitive, yet its signature contradiction
  matrix is effectively random for mechanical problems and was abandoned by its own creator (§4 Theme B; §4 Theme
  F). Keep the heuristics, distrust the matrix.
- **Calibrate constraints; do not maximize them** — modest scarcity and tighter scope boost creativity by
  activating a "constraint mindset," but extreme scarcity harms it (an inverted-U) (§4 Theme H).
- **Use authentic dissent, not scripted devil's advocacy** — genuine disagreement reliably broadens search and
  improves quality, while role-played opposition mostly bolsters the original view (§4 Theme H; Nemeth).

**For anyone evaluating these tools as a buyer:**

- **Distrust single-winner leaderboards; evaluate fit-to-use-case** — because the same tool can rank best on one
  citation benchmark and worst on another depending on the definition of "accurate citation" (§4 Theme C).
- **Discount vendor "superhuman" and internal-eval numbers** — the headline (90.2% gain, "superhuman synthesis")
  is consistently louder than the footnote (vendor-internal eval; superhuman on precision only, human-equal on
  accuracy) (§4 Theme C; §4 Theme F).

---

## 2. Summary

**What this researched and why.** I set out to map how good research and good invention actually get done — the
old human methods (systematic reviews, brainstorming, TRIZ), the new AI/agentic systems (deep-research tools,
auto-scientists), and the cognitive science underneath both — so that a builder could borrow what works and
design around what does not. Think of it as taking apart three different idea-machines (the careful scholar, the
brainstorming room, and the robot scientist) to see which gears are load-bearing and which are decorative.

**The five most important findings, in plain language.**

1. **The one trick that separates rigorous research from guesswork is committing to your plan before you see the
   answers.** This is called pre-specification: you write down your question, what counts as good evidence, and how
   you will add it all up — and you do it BEFORE the data arrives, so you cannot quietly bend the rules to get the
   conclusion you wanted (Cochrane Handbook; PRISMA). It is not magic — the refutation pass showed it is one
   important lever, not the only one, and it is neither necessary nor sufficient by itself — but it is the spine
   that holds the rest up.

2. **Rigorous methods do not make bias disappear; they make it visible so you can grade your confidence.** A tool
   called GRADE does this on purpose: it rates a body of evidence as high, moderate, low, or very-low certainty and
   tells you WHY it downgraded (the studies were shaky, they disagreed, they measured the wrong thing, the numbers
   were imprecise, or some studies were probably never published). The honest catch: this grading is itself partly
   a judgment call — two trained raters often disagree — so it organizes judgment rather than replacing it.

3. **More than 50 years of evidence says the brainstorming room is a worse idea-machine than the same people
   working alone.** When a group sits in a circle and shouts ideas, only one person can talk at a time, so everyone
   else's ideas get blocked and forgotten ("production blocking"). Across 22 experiments, 18 found that individuals
   working separately and pooling their lists beat the talking group, and NONE found the reverse (Diehl & Stroebe
   1987). The fix is not "more brainstorming" — it is parallel, written, judgment-deferred idea capture (electronic
   brainstorming, brainwriting), which removes the bottleneck.

4. **Today's AI research tools confidently cite sources that do not actually back up what they say.** This is worse
   than making up fake references — the references are real and clickable, they just do not support the sentence
   they are attached to. One audit found 47% of one frontier system's statements were unsupported by its own cited
   sources, and a "deep research" mode hit 97.5% unsupported (DeepTRACE). So the citation step, the very thing that
   is supposed to make AI research trustworthy, is the part that most often fails.

5. **AI helps the individual but can quietly narrow the whole group's thinking.** A careful experiment (Doshi &
   Hauser 2024) found that giving people AI idea-help raised the quality of each person's work — especially for
   less-skilled people — but ALSO made everyone's outputs more similar to each other (about 10.7% more alike). It is
   a "social dilemma": each person wins, the collective loses variety. The good news from the refutation pass:
   this narrowing is fixable with the right prompting (diverse personas + step-by-step reasoning), and one contrary
   study even found AI INCREASED diversity when ideas were injected as something to react against rather than a
   draft to copy.

**Where experts agree.** Pre-specification and transparency are the core of rigor; evidence comes in gradients of
certainty, not true/false; every aggregating method has a "garbage in, garbage out" ceiling; brainstorming rooms
lose to parallel idea capture; AI research tools summarize but do not deeply synthesize, weigh importance, or flag
their own gaps; and self-correction only works when the critic has an outside check.

**Where they disagree.** Whether the giant machine of published systematic reviews is net-helpful (the method is
the gold standard, yet a likely-large share of the output is redundant or conflicted); whether AI narrows or widens
collective creativity (depends on how AI ideas are injected); which AI tool has the "best" citations (depends on
how you define an accurate citation); and whether the famous "groupthink" hazard is even real (it has thin
empirical support).

**What surprised me.** Three things. First, the inventor of the brainstorming claim ("twice as many ideas in a
group") was simply wrong, and it has been known to be wrong since 1958. Second, TRIZ's most famous tool — the
contradiction matrix — is roughly random for mechanical problems and was abandoned by its own creator. Third, a
celebrated "AI discovered 41 new materials" headline turned out, under independent expert re-analysis, to be
essentially zero genuinely new materials.

**The one thing to remember.** Both the old methods and the new AI systems are at their strongest when they
GENERATE and at their weakest when they VERIFY — so the highest-leverage thing you can build into a research or
invention engine is a disciplined, externally-grounded verification stage, and the highest-leverage thing you can
do with its output is refuse to believe a confident claim until something outside the model has checked it.

---

## 3. Framework: The Generate–Critique–Ground Loop (and its three failure surfaces)

A single model of the landscape emerges from all seven tracks. Every serious system for producing knowledge — a
Cochrane review team, a brainstorming room, TRIZ, a deep-research agent, an auto-scientist, a multi-agent
debate — is some arrangement of three moves repeated in a loop:

```
        +-----------------------------------------------------------+
        |                                                           |
        v                                                           |
   GENERATE  ------>  CRITIQUE / RANK  ------>  GROUND / VERIFY -----+
  (produce ideas,    (weigh, compare,         (check against an
   hypotheses,        de-bias, select)         EXTERNAL signal:
   candidate                                   data, tests, tools,
   answers)                                    reality, fresh judge)
```

- **Generate** = produce candidates (ideas, hypotheses, draft answers, retrieved studies).
- **Critique/Rank** = weigh them, compare them, de-bias the comparison, and select.
- **Ground/Verify** = test the survivors against something OUTSIDE the generator — real data, executed tests, a
  tool, the physical world, or at minimum a fresh-context judge that is not anchored to the generator's own prior
  answer.

**Why this is the right framework.** It is the literal architecture of the AI invention systems (Co-Scientist's
Generation/Reflection/Ranking/Evolution agents plus an Elo tournament; Sakana's tree-search + reviewer loop), and
it is also the implicit architecture of the human methods: systematic review = generate (search) -> critique
(risk-of-bias) -> ground (synthesize against pre-specified protocol); brainstorming research = generate (ideas) ->
critique (selection) -> ground (does it survive evaluation); TRIZ = generate (principles) -> critique
(contradiction analysis) -> ground (does it solve the contradiction). The loop also scales: running it longer or
wider ("test-time compute") measurably improves output quality in the tournament systems (Co-Scientist).

**The three failure surfaces.** The whole point of the framework is that each move has a characteristic,
well-evidenced failure, and that the failures are NOT symmetric — verification is where almost everything breaks.

| Move | What it does well | Its characteristic failure | Evidence |
|------|-------------------|----------------------------|----------|
| **Generate** | Fluent, fast, high-volume candidate production | "Garbage-in" ceiling and fixation/homogenization — it inherits input bias and converges on the obvious | §4 Theme A (GIGO), §4 Theme E (homogenization), §4 Theme H (fixation) |
| **Critique/Rank** | Imposes structure, exposes where bias lives, grades certainty | Subjective and unreliable when self-applied — GRADE inter-rater agreement is poor-to-moderate; blind self-critique can degrade answers | §4 Theme A (GRADE subjectivity), §4 Theme F (can't self-assess), §4 Theme G (intrinsic self-correction fails) |
| **Ground/Verify** | Tests survivors against reality so confidence can be earned | THE load-bearing weakness — citations that don't support claims; "discoveries" that aren't; no external signal = no reliable improvement | §4 Theme C, §4 Theme D, §4 Theme F, §4 Theme G |

**How this compares to existing models.** It generalizes the standard agentic "plan-act-observe" loop and the
classic creativity "divergent-then-convergent" model, but it adds the third, separable move (Ground/Verify) that
both of those tend to fold into the second. The report's central empirical claim is that this third move is where
the field is weakest, in both humans and machines, which is why splitting it out matters.

**Boundary conditions.** (1) The Ground move requires an EXTERNAL signal to work; folding it back into the
generator (self-grading) breaks it (§4 Theme G). (2) The loop's value depends on input quality — no arrangement of
the three moves manufactures truth from bad inputs (§4 Theme A). (3) For pure in-silico/algorithmic domains
(AlphaEvolve, AlphaTensor) the Ground move can be fully automated (the "experiment" is code evaluation against a
formal objective), so those systems approach closed-loop autonomy; for wet-lab and open-ended knowledge work, the
Ground move still needs a human (§4 Theme F).

**How to apply it.** When building an engine, ask of each stage: *Where does this stage get its candidates? How
does it weigh them without grading its own homework? And what OUTSIDE the model checks the survivors?* If the third
answer is "the model checks itself," you have built a confident hallucination machine.

---

## 4. Analysis

Eight themes emerge across the seven research tracks. Each is presented as a research question, what the evidence
says, where sources agree, where they disagree, what is missing, and the gap between institutional advice and
ground truth. Claims here carry the *surviving form* from the adversarial refutation pass — overstated claims have
been demoted to their defensible versions and noted as such.

### Theme A — What makes traditional research rigorous (and where it fails)

**Research question:** What do rigorous traditional methods (systematic review, GRADE, preregistration, Delphi)
get right that ad-hoc research misses, and what are their known failure modes?

**What the evidence says:** A major shared mechanism behind rigorous methods is **pre-specification** — fixing the
question, eligibility, search, and analysis BEFORE the data or studies are known, so the investigator's bias
cannot steer the conclusion [Cochrane Handbook Ch.1, 8.85, Level 4]. The Cochrane Handbook states plainly that
"post hoc decisions made when the impact on the results of the research is known... are highly susceptible to bias
and should therefore be avoided." This logic recurs in study preregistration and (as anonymity) in the Delphi
method. **Refutation note:** the original claim called this "the single mechanism." That was demoted — the
literature shows pre-specification is "neither sufficient nor necessary" (Szollosi et al.; Devezer et al. 2020),
that systematic-review authors already know the important studies (so a protocol is not preregistered in the same
sense as a trial), and that transparency, open data, and replication are complementary mechanisms. Surviving
form: *a major lever, not the only one* [Rubin 2020, 7.3, Level 7].

Rigorous methods do not eliminate bias; they make a body of evidence **assessable** so confidence can be graded.
GRADE operationalizes this with four certainty levels (high/moderate/low/very-low), five downgrade reasons (risk
of bias, inconsistency, indirectness, imprecision, publication bias), and three rarely-used upgrade reasons
[GRADE/ACIP Ch.7, 8.65, Level 4]. PRISMA frames itself as a way to "transparently report... so users can assess
the trustworthiness and applicability" [PRISMA 2020, 8.95, Level 4]. **Refutation note:** this claim survived
intact, narrowed only on reliability — GRADE grading is partly subjective (Cochrane mandates duplicate raters and
a tie-break precisely because of this; reported inter-rater agreement is poor-to-moderate). It structures and
surfaces judgment rather than making it objective.

Every aggregating method has a **"garbage-in" ceiling**: structure controls process-level bias but cannot upgrade
input quality. Meta-analyses inherit the weaknesses of included studies (the GIGO point traces to Eysenck 1978);
Delphi can "only add confidence to ignorance" when panelists are misinformed [Delphi method, 6.85, Level 7]; and
preregistration constrains analytic flexibility without fixing weak theory or inference [Rubin 2020]. This was the
single strongest claim in the track and survived essentially intact.

The tradition is self-correcting at the method level: it diagnosed its own slowness and engineered the **living
systematic review** (continual updating, e.g., monthly searching) as a remedy, at considerable ongoing cost
[Living SR / Cochrane Ch.IV, 8.7, Level 4].

**Where sources agree:** Pre-specification is the core bias-control mechanism separating rigorous from ad-hoc
research; methods must be explicit, transparent, and reproducible; evidence comes in gradients of certainty, not
true/false; every aggregative method is bounded by input quality; and systematic synthesis exists because the
primary literature is too large for any individual to assess unaided — a rationale even critics accept (Ioannidis
calls systematic reviews "indispensable").

**Where sources disagree:** The sharpest fight is whether the systematic-review enterprise is net-positive **in
practice**. Ioannidis argues a large, fast-growing share of published reviews are redundant, of suboptimal
quality, or conflicted — driven by publication and marketing incentives, not by flaws in the method [Ioannidis
2016, 8.95, Level 3]. **Refutation note:** the original claim said "a likely MAJORITY... are misleading or
conflicted, and this is THE dominant failure mode." Both quantifiers were demoted. The "majority" is Ioannidis's
own hedged opinion ("possibly the large majority"); his headline measured estimate is that only ~3% are "decent
and clinically useful," and even the apparent rebuttal (Page & Moher's "Mega-silliness?") actually ENDORSES and
EXTENDS his finding (>22 reviews/day with major shortcomings). The 2,728% growth, raw counts, and industry-tie
findings for 185 antidepressant meta-analyses survive as empirical; the leap to a measured majority across ALL
reviews, and the "dominant failure mode" ranking, do not. A second live disagreement: whether preregistration
improves credibility — reform institutions (Center for Open Science / Nosek) say yes and 500+ journals adopted it;
credentialed methodologists (Rubin, Devezer, Szollosi) argue its specific "historical transparency" benefit is
overstated once contemporary transparency is present.

**What's missing:** No source here quantifies how often pre-specification is actually FOLLOWED versus
deviated-from in practice (protocol-to-publication discordance rates). Grounded theory and triangulation were
searched but not carded, so the qualitative rigor-vs-replicability tension is under-evidenced. And critically for
this meta-review's purpose, no source directly answers how pre-specification, certainty-grading, and triangulation
should translate to an LLM-driven pipeline — that is the synthesis gap §3 bridges.

**Institutional vs. ground truth:** Institutions (Cochrane, PRISMA, GRADE) present systematic review + GRADE as
the rigorous gold standard. The contrarian ground truth (Ioannidis's bibliometrics) is that the same machinery is
mass-produced into a flood of low-value reviews — the ideal and the deployment have diverged. Likewise, the
"risk-of-bias assessment is rigorous" framing meets independent studies showing risk-of-bias tools are frequently
misapplied even within Cochrane reviews; and the reform narrative on preregistration meets credentialed pushback
that it does not fix the deeper drivers of replication failure. (The replication crisis itself is the empirical
backdrop: of 97 psychology studies with originally-significant effects, only 36% replicated [Replication crisis,
7.3, Level 3].)

### Theme B — Traditional ideation and invention: what works vs. folklore

**Research question:** Which established ideation/invention methods have evidence of working, and which are
folklore — with deep coverage of TRIZ as the most structured invention method?

**What the evidence says:** Osborn's founding claim that group brainstorming yields "twice as many ideas" as
working alone is **empirically false** for idea production. Of the 22 experiments tabulated by Diehl & Stroebe,
18 found nominal groups (individuals working alone, ideas pooled) more productive than interacting groups and none
found the reverse (the other 4 were dyads with no difference); **production blocking** (only one person can speak
at a time) is the dominant cause [Diehl & Stroebe 1987, 9.35, Level 2]. **Refutation note:** survived intact — the
single most robust claim in the track — with one caveat: the nominal advantage is for idea *generation*, and does
not reliably extend to better idea *selection* (Rietzschel et al. 2006).

Whether structured creativity training works at all is weaker than folklore implies, but it is not zero. The
largest meta-analysis (169 studies, 844 effect sizes) shows the unadjusted 0.53 SD effect drops to 0.29-0.32 SD
after correcting for publication bias, with no methodological improvement over five decades [Sio & Lortie-Forgues
2024, 9.55, Level 1]. The older optimistic estimate (d~0.64) was inflated [Scott, Leritz & Mumford 2004, 8.35,
Level 1]. **Refutation note:** narrowed from "works at all is far weaker" to "real but modest and over-hyped" — the
surviving ~0.3 SD is a genuine, typical-sized educational effect, not "does not work."

TRIZ is the most fully structured classical invention method with the largest documented industrial case-study
record, but its signature **39x39 contradiction matrix** is its weakest part: principle selection is effectively
stochastic for mechanical problems [Borgianni et al. 2021, 8.55, Level 3], the matrix's patent data froze in 1985
and covers only ~10-15% of problems, and Altshuller himself dropped the matrix from his final 1985 formulation in
favor of Su-field analysis / 76 standards / ARIZ. TRIZ's durable value is its heuristics (40 principles,
ideality/Ideal Final Result, evolution trends, separation principles), not the matrix lookup. The pro-TRIZ
industrial evidence (200+ cases) is proponent-adjacent and survivorship-biased [Spreafico & Russo 2016, 7.3, Level
5]. **Refutation note:** the absolute superlative "the ONLY method with an industrial record" was stripped as
unverified.

The "individuals beat groups" verdict is **conditional, not absolute** — it is driven by production blocking, so
removing blocking via parallel methods closes or reverses the gap. Electronic brainstorming almost always beats
*verbal* brainstorming (and *blocked* electronic brainstorming does NOT — confirming the mechanism), and for large
groups (~10+) it beats even nominal groups [Sandia 2007, 8.05, Level 4]. Brainwriting/6-3-5 matches nominal-group
idea quality while exceeding idea count. **Refutation note:** the crossover group size is ~10-12 (not a hard 12),
and the often-cited "28% more implementable ideas" figure traces to practitioner blogs, not a verifiable study —
it has been dropped. Practitioner critics (Sutton & Hargadon 1996; Berkun) add that lab quantity metrics
under-measure real organizational value like shared memory, learning, and commitment [Berkun, 5.75, Level 7].

Zwicky/Ritchey **General Morphological Analysis** is the most rigorous combinatorial method: enumerate parameters
x conditions in a "Zwicky box," then prune the combinatorial explosion with pairwise Cross-Consistency Assessment
(a ~100,000-configuration field needs only a few hundred pairwise judgments) [Ritchey GMA, 7.65, Level 7]. Its
weakness is that it is non-quantified and judgment-dependent. de Bono's lateral thinking / Six Thinking Hats are
the clearest folklore case — extravagant unreferenced claims, sparse research evidence, defensible only as a
facilitation ritual [de Bono critique / Winter, 6.65, Level 7]. SCAMPER is a mnemonic repackaging of Osborn's
1950s checklist, and Synectics, Crazy-8s, How-Might-We, and the Double Diamond have essentially no method-specific
controlled validation.

**Where sources agree:** Interacting verbal brainstorming underperforms nominal groups on quantity AND quality
(50+ years, production blocking is the cause); deferring judgment and capturing ideas in parallel measurably helps;
training that teaches transferable heuristics with realistic exercises outperforms vague "be creative" prompts;
de Bono's methods lack rigorous support; and TRIZ's contradiction matrix is the weakest-validated part of TRIZ.

**Where sources disagree:** Whether brainstorming "works" (lab/meta-analytic camp says interacting groups lose;
practitioner/ethnographic camp says the studies measure trivial tasks with untrained groups and ignore
organizational value); TRIZ effectiveness (proponent surveys vs. academic-critical analyses, with survivorship
bias in the case literature); the magnitude of the creativity-training benefit (an order-of-magnitude
disagreement driven by publication-bias correction); and Design Thinking's impact (enthusiastic NPD studies vs.
reviewers who call the mechanism "inadequately grounded").

**What's missing:** No method-specific controlled trials for SCAMPER, Synectics, Crazy-8s, How-Might-We, or the
Double Diamond. No study tests whether TRIZ's 40 principles produce better inventions than a strong baseline. GMA
has no outcome data on solution quality. And almost nothing in this human-method literature addresses how the
methods behave when the ideator is an LLM rather than a human — production blocking, evaluation apprehension, and
free riding may not transfer, which is the key open question for an AI invention engine.

**Institutional vs. ground truth:** TRIZ institutions market it as "one of the most effective methods" on
self-reported cases; ground-level engineers report the matrix is unreliable and frozen. de Bono's organization
markets grand historical claims; critics note they are unreferenced anecdotes. The academic brainstorming
consensus diverges from the lived experience of design firms (IDEO ethnography). And creativity-training research
historically reported large effects that the 2024 bias-corrected re-analysis cut to roughly a third.

### Theme C — AI research systems: architecture and where they fall short

**Research question:** What are leading AI/agentic deep-research systems doing architecturally, and where do they
measurably fail?

**What the evidence says:** Leading systems fall into two architectural families: **single-agent RL-trained
planning-and-retrieval loops** (OpenAI Deep Research on RL-tuned o3; Gemini Deep Research, single-agent with an
asynchronous task manager) and **orchestrator-worker multi-agent systems** (Anthropic's lead agent + parallel
subagents) [DRA survey arXiv:2506.18096, 7.45, Level 4; Anthropic, 7.85, Level 5; Gemini DR, 6.55, Level 7]. All
run an iterative plan-act-observe loop. **Refutation note:** the original claim's branded terms ("Intent-to-
Planning," "Unified Intent-Planning") were fabricated and removed; and "all use citation as a post-hoc binding
step" was demoted — Anthropic uses a distinct post-hoc citation pass, but others ground iteratively during
retrieval, and at least one secondary source classifies all three vendors as multi-agent, so the split is real but
less clean than claimed.

The dominant measured weakness is **citation grounding**: outputs routinely contain large fractions of statements
not supported by their own cited sources — 47% for GPT-4.5 in generative-search mode, ~23-32% for
Perplexity/You.com/Bing in search mode, rising to 97.5% for Perplexity's deep-research mode [DeepTRACE
arXiv:2509.04499, 8.3, Level 3]. The presence of a citation frequently does not ground the claim. **Refutation
note:** survived; narrowed only on precision — these figures come from an LLM judge (moderate human agreement,
r=0.62) on a debate-heavy question set, so treat exact percentages as indicative, and "routinely" is fair for
contested topics specifically. Independent institutional evaluation corroborates the mechanism: all four tools
tested by HKUST returned REAL citations that did not match the generated argument [HKUST, 7.1, Level 5].

Beyond grounding, the core ceiling is **shallow synthesis**: systems summarize but do not weigh importance,
question assumptions, distinguish authoritative from unreliable sources, or surface knowledge gaps. OpenAI's own
admitted limitations name source-discrimination and confidence-calibration weakness [OpenAI DR fallible, 7.3,
Level 7]; STORM's authors note verifiability problems "go beyond factual hallucination" [STORM, 8.1, Level 2].
Open/academic agents (PaperQA2, STORM, Undermind, Elicit, Consensus, Scite) optimize for high early precision and
citation-graph grounding but trade away exhaustive recall — strong for narrative discovery, weak for systematic
reviews. PaperQA2's "superhuman" result is precision-only (85.2% vs 73.8%), with accuracy merely matching humans
[PaperQA2, 7.55, Level 3]. Source-quality bias is **architecture-independent**: Anthropic reports subagents
"consistently chose SEO-optimized content farms over authoritative sources," and DeepTRACE measures 50-80%
one-sidedness on debate queries.

Multi-agent buys quality at steep cost: Anthropic's system beat single-agent Opus 4 by 90.2% on an internal eval
while using ~15x the tokens of a chat, and is a poor fit for tasks needing shared context or tight inter-agent
dependencies [Anthropic, 7.85, Level 5]. **Refutation note:** survived; the figures are vendor-internal-eval
(Level 5), so magnitudes are indicative, but the cost direction is robustly corroborated.

**Where sources agree:** Architecture is an iterative plan-act-observe loop with citation as a (variably-timed)
step; citation grounding is the dominant measured weakness; systems summarize rather than deeply synthesize; open
tools favor precision over recall; source-selection bias is architecture-independent; and no single system wins on
all axes.

**Where sources disagree:** Perplexity Deep Research's citation reliability is rated BEST (90.24%) by
DeepResearch Bench's FACT framework yet WORST (97.5% unsupported) by DeepTRACE — because FACT measures whether a
cited URL is retrievable/relevant while DeepTRACE measures whether each statement is entailed by the sources
[DeepResearch Bench, 7.75, Level 3 vs. DeepTRACE]. Credible sources genuinely disagree on the same headline.
Whether multi-agent's 90.2% gain justifies ~15x cost is also contested (Theme G covers the orchestration side).

**What's missing:** No source localizes the unsupported-statement problem to retrieval vs. generation vs.
reranking — it is measured at the output, not the stage. No independent replication of the 90.2%/15x figures. Little
systematic measurement of staleness/recency failures. Scant head-to-head evaluation of open vs. commercial systems
on the SAME benchmark. And no convincing evidence on whether closed-loop self-verification actually reduces
unsupported statements in production versus just adding verbosity.

**Institutional vs. ground truth:** Vendor "comprehensive / personal research assistant" framing omits all
limitations, while the independent survey and audits supply the failure modes. OpenAI's benchmark wins coexist
with OpenAI's own quiet admission that it hallucinates and is poorly calibrated. FutureHouse's "superhuman
synthesis" headline is superhuman on precision only. And leaderboards say Perplexity has top citation accuracy
while an independent audit and a working librarian (Aaron Tay) report real-but-misaligned citations and shallow
coverage, reframing "who wins" as "fit-to-use-case" [Aaron Tay, 7.45, Level 7].

### Theme D — Citation grounding as the central AI-research failure (cross-cut)

**Research question:** Is "the citation is there but does not support the claim" a real, distinct failure mode,
and how severe is it?

**What the evidence says:** Yes, and it is distinct from fabrication. The references are real and retrievable; they
simply do not entail the sentence attached to them. This is measured at 47% (GPT-4.5), ~one-third for several
search engines, and 97.5% for one deep-research mode [DeepTRACE, 8.3, Level 3], and corroborated independently by
both a secondary press account and an institutional library evaluation finding "real citations do not ensure they
match the argument" [HKUST, 7.1, Level 5]. It is triangulated across a contrarian audit, secondary press, and an
institutional eval.

**Where sources agree:** The failure is real, common on contested/expertise queries, and architecture-independent.

**Where sources disagree:** How to MEASURE it — statement-level entailment (DeepTRACE) versus URL
retrievability/relevance (DeepResearch Bench's FACT) — which can rank the same system oppositely.

**What's missing:** Whether the problem originates in retrieval, generation, or the attribution/reranking step; and
whether any production self-checking pass meaningfully reduces it.

**Institutional vs. ground truth:** Benchmark leaderboards and vendor framing imply citations are a solved,
measurable strength; the audit and the librarian show that "has a citation" and "is supported by that citation"
are different things, and the gap is large.

### Theme E — AI and creativity: leveling up the individual, narrowing the collective

**Research question:** Does AI improve ideation or homogenize it? What does the controlled evidence say?

**What the evidence says:** In specific generative tasks (short-form creative writing; constrained product
ideation), RCT evidence shows LLM access raises **third-party-rated** output quality on average, with the gain
concentrated almost entirely among **less-skilled** producers (a leveling-up effect) and little benefit for
already-skilled ones [Doshi & Hauser 2024, 8.85, Level 2; Meincke/Girotra/Terwiesch, 8.4, Level 5]. **Refutation
note:** demoted from a universal "raises individual quality." The Doshi & Hauser gain was concentrated in the
least-creative tail; in an adjacent domain an RCT found AI made experienced developers ~19% SLOWER (METR 2025); and
"enjoyability" was reader-rated story enjoyment — writer enjoyment/ownership often FALLS. The Wharton "35 of top
40" rests on purchase-intent against an MBA-student baseline, a contested success proxy, and even that paper rated
AI ideas LESS novel.

The same assistance that raises individual quality **reduces collective diversity**: AI-assisted outputs are
measurably more similar to each other than human-only outputs — ~10.7% higher pairwise embedding similarity in
Doshi & Hauser (the same RCT, so the linkage is internally valid), higher similarity / lower novelty in Wharton,
and human-vs-LLM first-idea distance 2.41 vs 1.51 (p<.001) in Deng/Brucks/Toubia [Deng/Brucks/Toubia 2026, 8.45,
Level 2]. **Refutation note:** this was the best-supported claim in the track and survived; "collapse" was softened
to "narrowing" (the effect is moderate, ~10.7%), and "similarity to the AI source" is less uniformly established
than output-to-output similarity.

Homogenization is **designable-around**, not a fixed law. It is driven by LLM fixation and lack of knowledge
partitioning (LLMs sample one unified distribution; humans occupy distinct regions), and targeted interventions
(Chain-of-Thought + ordinary/diverse personas) substantially narrow — and on combinatorial novelty exceed — the
human baseline [Deng/Brucks/Toubia 2026]. **Refutation note:** demoted from "close AND exceed the human baseline."
The "exceeds humans" result was metric-specific (1 of 3 metrics: unique combinations 248 vs 197; categories merely
MATCHED at 27 vs 28; the pairwise-distance metric was not shown to be beaten) and used batch rather than sequential
generation. Surviving form: narrows the gap and beats humans on combinatorial novelty under specific conditions.

AI assistance can leave human creativity worse off afterward — but condition-specifically. In one pre-registered
RCT (n=1,100), AI delivered as **strategy/coaching scaffolding** left participants significantly worse on
immediately-following UNASSISTED divergent (p=0.009) and convergent (p=0.005) tasks, with no transfer of the
in-session boost [Kumar et al., CHI 2025, 8.4, Level 2]. **Refutation note:** demoted from "AI assistance" +
"skill-atrophy." The harm was specific to the coaching condition (the plain LLM-output condition showed no
significant downstream difference), and short single-session windows cannot establish durable atrophy — it
evidences short-term negative carry-over, not a proven long-term mechanism.

**Where sources agree:** AI reliably raises average/individual quality with the biggest uplift for less-skilled
producers; naive independent LLM sampling produces less diverse pools than independent humans; prompt/structure
engineering materially changes diversity; and diversity must be designed for explicitly.

**Where sources disagree:** Whether AI exposure narrows or **widens** collective diversity. Doshi/Hauser, Wharton,
and Deng/Brucks/Toubia find narrowing under active co-creation/anchoring; a dynamic experiment (each participant's
ideas seed the next) found high AI exposure INCREASED diversity with creativity unchanged [Ashkinaze et al., 8.45,
Level 2]. The reconciling hypothesis — that the SIGN depends on injection design (AI-as-stimulus-to-react-against
vs. AI-as-draft-to-anchor-on) — is plausible but not yet directly tested in one experiment. Also contested:
whether assistance harms subsequent unassisted creativity, and the real-world magnitude of homogenization.

**What's missing:** No experiment directly manipulates injection mode — the most important unanswered question for
an invention engine. No meta-analysis pools the several RCTs. No longitudinal evidence. Sparse rigorous field
data. And little on collective/system-level remedies (diversity-preserving orchestration across many users) versus
single-prompt fixes.

**Institutional vs. ground truth:** Academic framing is precise and modest (~10.7%, a "social dilemma"), while
practitioner voices escalate to existential language ("AI slop," "homogenization of human thought") [Sadek, 5.3,
Level 7; HN thread, 4.55, Level 8] — the lived rhetoric outruns the measured effect sizes. Homogenization also has
a supply-side root: frontier models are highly correlated with each other and themselves, so naively sampling
"multiple models" does not guarantee diversity [Jiang "Artificial Hivemind," 7.5, Level 3].

### Theme F — AI invention and discovery: strong generation, weak verification, human-in-the-loop validation

**Research question:** What is the state of the art in AI systems that INVENT or DISCOVER (generate + test
hypotheses), and which are genuinely working vs. demo-ware?

**What the evidence says:** Among LLM-driven hypothesis-and-experiment systems, a recurring architecture is the
loop **generate -> critique -> rank/evolve -> (experiment) -> learn**, instantiated as cooperating specialized
agents: Co-Scientist (six named agents + Elo idea tournament) [Google Co-Scientist, 7.75, Level 5], Sakana's AI
Scientist (tree search + experiment-manager + reviewer loop) [Sakana, 7.25, Level 5], Coscientist (modular
multi-LLM) [Coscientist Nature, 8.15, Level 5], and Robin (Crow/Falcon/Finch) [Robin, 7.25, Level 5].
**Refutation note:** demoted from "every serious system." Evolutionary/search systems (FunSearch, AlphaEvolve)
implement only the abstract sampler->evaluator->select loop without role-specialized agents, and pure-search/RL or
supervised systems (AlphaTensor, AlphaFold) sit outside the agentic paradigm entirely while delivering some of the
most rigorously validated discoveries. This is one prominent family, not the universal pattern.

Self-critique is a major, well-documented weakness: Sakana's system "cannot critically assess its own results"
(making it "unsuitable for autonomous scientific inquiry"), 42% of its experiments failed on coding errors, and
4/7 manuscripts contained hallucinated numbers [Beel et al., 8.05, Level 5]. **Refutation note:** demoted from
"critique is the load-bearing weakness, NOT generate." The same source finds generation also fails on genuine
novelty (established techniques misclassified as novel), and critique and generation are coupled. Surviving form:
verification/self-critique is at least as weak as generation, and human judgment remains required across the
pipeline. Domain experts add the epistemic limit: current models are "purely statistical and correlative," so
plausibility checks plus experimental validation are "of critical importance" [Bajorath, 7.85, Level 7].

Genuine, expert-validated discovery EXISTS but, in wet-lab/biomedical domains, requires a human in the loop for
execution and verification — it is not yet autonomous end-to-end. Robin's ripasudil-for-dry-AMD candidate (Nature
2026; "human researchers executed the physical experiments") and Co-Scientist's liver-fibrosis targets (Nature
2026; experts selected hypotheses, humans ran organoid validation) are real; Coscientist ran real chemistry only
via a pre-built robotic lab [Robin; Co-Scientist; Coscientist]. **Refutation note:** survived; caveat added that
in-silico algorithmic/math systems (AlphaEvolve, AlphaTensor) come closer to closed-loop autonomy because their
"experiment" is automated evaluation against a formal objective.

At least one celebrated autonomous-discovery milestone was sharply challenged: Berkeley's A-Lab claimed 41 new
materials (Nature 2023), but independent crystallography analysis (Palgrave, with Schoop) concluded essentially
none were genuinely new — ~two-thirds were ordered versions of already-known disordered compounds, with
novice-level AI structure refinement [A-Lab / Palgrave critique, 7.7, Level 4]. Ceder rebuts by reframing it as a
systems demonstration, so this is a contested expert dispute, not a formal retraction — but it is strong evidence
that headline discovery claims require independent domain verification. The "first AI paper to pass peer review"
milestone (Sakana) is real but heavily caveated: 6.33 at a non-archival workshop, a negative result, pre-arranged
withdrawal, and warned reviewers [Sakana, 7.25, Level 5]. A distinct branch, structured/knowledge-grounded
ideation (AutoTRIZ), constrains the LLM to distilled invention knowledge but has the weakest evaluation — its
authors concede "no objective mechanism to evaluate the effectiveness of generated solutions" [AutoTRIZ, 6.85,
Level 5].

**Where sources agree:** The architectural pattern (generate -> critique -> rank/evolve -> experiment -> learn) is
settled for the agentic family; hypothesis GENERATION is genuinely strong at speed/scale; self-VERIFICATION is the
universal weak point (the builders agree); validated real-world discovery is achievable today only as a human-AI
hybrid; and independent verification is mandatory (A-Lab is the cautionary tale).

**Where sources disagree:** Whether any system has truly "discovered" something new vs. surfaced an
obvious-in-hindsight candidate (builders say yes; critics say overstated/unverified); whether "passed peer review"
means anything about real science; whether A-Lab produced ANY new materials; and whether LLMs can ever do
mechanistic/causal reasoning or are permanently "purely statistical" (i.e., whether the verification gap is an
engineering problem or a fundamental one).

**What's missing:** No head-to-head independent benchmark on the SAME task with the SAME verification standard. No
base rate of AI-proposed hypotheses that validate vs. dead-end (the denominator is never reported). Cost and
reproducibility per validated discovery are undocumented. The AI-TRIZ branch has no rigorous real-world outcome
evaluation. And almost no source addresses the systemic cost if these systems flood the literature with
plausible-but-unverified hypotheses (the "verification commons").

**Institutional vs. ground truth:** The A-Lab 41-materials announcement vs. the independent zero-genuinely-new
re-analysis is the sharpest divergence in the report. Sakana's "first AI peer-reviewed paper" milestone vs. the
Beel evaluation's 42% failure and "unsuitable for autonomous inquiry." DeepMind's blockbuster framing of
Co-Scientist vs. the arXiv/Nature versions and domain experts stressing mandatory validation. And FutureHouse's
Robin announcement leading with "2.5 months / 872-937 hours compressed" while the load-bearing caveat ("human
researchers executed the physical experiments") sits downstream of the headline.

### Theme G — Multi-agent orchestration: which reasoning patterns actually help

**Research question:** Which multi-agent/LLM reasoning patterns measurably improve research and reasoning
quality, and which are hype?

**What the evidence says:** **Self-consistency** (sample N chain-of-thought paths, take the majority answer) is
the best-replicated, lowest-complexity reasoning win (GSM8K +17.9%, AQuA +12.2%) [Wang et al. 2022, 8.45, Level
5]. **Refutation note:** demoted from "the baseline debate repeatedly fails to beat" to the homogeneous
(single-model) setting — debate CAN clear it under specific conditions (heterogeneous models, especially hard
problems, weaker base models). Much of multi-agent **debate's** measured gain is an ensemble/diverse-candidate
effect rather than critique per se: a strong single agent with good prompts nearly matches discussion methods,
which only win when no demonstration is in the prompt [Wang et al. 2024, 8.1, Level 5]. **Refutation note:** the
claim's stated support ("Du et al. never isolates debate from majority voting") was factually wrong and corrected —
Du et al. 2023 DID report a majority-vote baseline; the open question is whether the isolation holds at matched
sample budget [Du et al., 7.3, Level 5].

Generator-critic / self-refine loops reliably improve hard reasoning only when the critic has an **external
verification signal** (tests, tools, retrieval, error-location, or a trained verifier); blind intrinsic
self-correction of reasoning frequently fails to help and can degrade accuracy [Huang et al. 2024, 8.45, Level 5].
This is corroborated: Reflexion hits 91% pass@1 on HumanEval precisely BECAUSE it uses test-execution feedback,
and Self-Refine's gains concentrate on open-ended generation (which carries an implicit checkable signal), not
hard math [Madaan et al., 6.95, Level 5]. **Refutation note:** survived — triangulated and robust.

Multi-agent orchestration earns its (~15x) token cost specifically on **READ/breadth/parallel-search** tasks
(Anthropic: +90.2% internal eval); for **WRITE/build/coordination** tasks, single-threaded agents with continuous
context are more reliable. Anthropic and Cognition explicitly converge on this read-vs-write split despite opposite
titles [Anthropic, 7.3, Level 5; Cognition, 6.85, Level 7; HN, 4.9, Level 8]. **Refutation note:** survived; the
strong word "earns" was softened — token usage alone explains ~80% of the variance, so much of the read-task gain
may be buying more search compute rather than orchestration magic; the cost is "justified when task value exceeds
it," not demonstrably efficient.

Two supporting patterns: **LLM-as-judge** reaches ~80% agreement with humans (parity with human-human agreement)
but carries position, verbosity, and self-preference biases that must be actively mitigated [Zheng et al., 8.3,
Level 3]. **Tree-of-Thoughts** produces dramatic gains on hard combinatorial search (Game-of-24: 4%->74%) but does
not consistently beat plain CoT on typical knowledge work; the binding constraint is candidate GENERATION, not the
discriminator [ToT bottleneck, 7.55, Level 5]. And **fresh, isolated context** is itself a first-class mechanism — a
critic whose context is not poisoned by the caller's prior decisions gives more reliable feedback.

**Where sources agree:** Self-consistency is a cheap, heavily-replicated default; multi-agent pays off for
READ/breadth and not for WRITE/build; self-correction needs an external signal; much of debate's benefit is the
ensemble effect; and LLM-as-judge reaches ~human-level agreement with known, mitigable biases.

**Where sources disagree:** Whether multi-agent debate adds anything beyond compute-matched self-consistency (yes
only under heterogeneity/hard problems/weak models); whether self-refine genuinely improves quality (headline ~20%
vs. the DeepMind null on intrinsic correction — reconciled by task type and external feedback); how damaging
LLM-as-judge biases are (footnotes vs. ranking-flipping); and whether Anthropic's 90.2% gain generalizes (real,
but on a vendor-internal eval measured on exactly the task class where multi-agent is known to help).

**What's missing:** No compute-matched independent benchmark of debate vs. self-consistency vs. single-strong-prompt
on long-form RESEARCH/writing (the actual use case); no external reproduction of the 90.2% figure; little on
heterogeneous-model ensembling; no cost-quality Pareto frontier for knowledge work; and almost no
longitudinal/production-quality evidence (the field rests on Level 5 methods papers and Level 7-8 essays).

**Institutional vs. ground truth:** Anthropic headlines a 90.2% multi-agent win; independent academics find a
strong single agent nearly matches it, and forum practitioners report multi-agent helps only for narrow
context-isolation cases. The marketed "multi-agent vs single-agent" binary collapses on the ground into a
pragmatic read-vs-write / isolate-context-vs-continuous-context engineering decision — where both big labs and
forum builders actually converge once the slogans are removed.

### Theme H — Cognitive science: how humans really ideate, and what sabotages it

**Research question:** How do expert humans do great research and ideation, what biases sabotage it, and what
mechanisms reliably improve it (design requirements for any augmenting tool)?

**What the evidence says:** Examples and prior framing can constrain idea generation under specific conditions —
common/familiar examples and default representations pull ideas toward shared features (**design fixation**;
**functional fixedness**), and Adamson 1952 replicated Duncker's ~2x empty-box effect [Functional fixedness card,
7.25, Level 4]. **Refutation note:** demoted from "reliably constrain." Meta-analytically (Sio, Kotovsky & Cagan
2015) examples on NET improve novelty and quality, with commonality the key moderator — a single uncommon example
helps most while common examples fixate. The practical lever is choosing example type/timing, plus re-framing to
de-fixate.

Synchronous **verbal** group brainstorming systematically underperforms nominal groups on quantity and quality,
with production blocking the primary cause, and debate/dissent instructions outproduce the no-criticism rule
(~25%, replicated US+France) [Mullen et al. 1991, 8.65, Level 1; Nemeth dissent, 8.3, Level 7]. **Refutation
note:** survived with caveats — the Mullen effect-size magnitudes are debated, the result is specific to
synchronous verbal groups (electronic brainstorming mitigates blocking), and the defensible framing is "debate
beats no-criticism," not "no-criticism is worse than no rule at all."

Two mechanisms reliably help and are directly implementable — but with different strengths. **Authentic dissent**
(genuine alternative viewpoints, not scripted devil's advocacy) reliably broadens information search and improves
quality [Nemeth, Brown & Rogers 2001]. **Incubation** (stepping away) helps but only modestly and less reliably
(d~0.29 over 117 heterogeneous studies) [Sio & Ormerod, 8.75, Level 1]. **Refutation note:** demoted from "two
mechanisms reliably improve." The specific "do a low-cognitive-load task during the break" prescription is
plausible but unproven — its anchor study (Baird et al. 2012) and the mind-wandering mechanism repeatedly failed
direct replication. Implement incubation as a low-cost default, not a reliable lever; the strong unconscious-
thought explanation is not supported [Ritter & Dijksterhuis, 7.2, Level 7].

Neither high intelligence nor domain expertise reliably protects against core biases. Myside bias and many classic
biases (anchoring, framing, bias blind spot) are essentially uncorrelated with cognitive ability (Stanovich, West
& Toplak); expertise is primarily a representation/pattern-recognition advantage built on domain-specific chunks
[Confirmation bias card, 7.35, Level 4; Expert-novice chunking, 7.3, Level 4]; and the positive-test strategy
driving confirmation-style search is a general heuristic experts share. **Refutation note:** survived with one
correction — expertise does not fully "collapse" on random stimuli; masters retain a small but reliable residual
advantage (Gobet & Simon 1996), refining rather than refuting the chunking account.

Constraints (resource scarcity, tighter scope) tend to enhance creativity by activating a "constraint mindset"
that reduces functional fixedness, but the relationship is non-monotonic — extreme scarcity harms, so constraints
must be calibrated, not maximized [Mehta & Zhu, 7.05, Level 5]. And **groupthink** — the most famous group-decision
hazard in popular discourse — has thin empirical support: only 2 of 23 model predictions were confirmed in the one
full-model test, and lab studies fail to reproduce it; the empirically robust hazards are production blocking and
evaluation apprehension [Groupthink critique, 7.1, Level 4].

**Where sources agree:** Design fixation and functional fixedness are real, with re-framing/decomposition as a
de-fixation lever; verbal group brainstorming underperforms parallel individual generation (production blocking);
incubation produces a modest real improvement; authentic dissent beats scripted devil's advocacy; expertise is a
representation advantage; and neither expertise nor high IQ immunizes against confirmation/myside bias.

**Where sources disagree:** Optimal **analogical distance** — far-analogy enthusiasm (crowds/AI, PNAS 2019) vs. a
large real-concept analysis finding conceptually CLOSER sources more beneficial [Chan, Dow & Schunn 2015, 7.95,
Level 3], suggesting a medium/contingent optimum, not "farther is better." Also contested: the mechanism of
incubation (associative unconscious thought failed replication; set-shifting/fixation-decay is better supported);
whether constraints help unconditionally (inverted-U); whether confirmation bias is a "bias" or an efficient
positive-test strategy that misfires only in specific environments; and whether groupthink is a valid construct at
all.

**What's missing:** No source directly tests how these human mechanisms transfer to HUMAN-AI ideation — does an
LLM-generated example cause the same fixation, and does AI "dissent" produce authentic-dissent benefits or
devil's-advocate bolstering? No effect-size curve for optimal analogical distance. Little on how to operationalize
incubation in a software workflow, how to elicit AUTHENTIC dissent at scale, or who benefits most from constraints
vs. incubation vs. dissent.

**Institutional vs. ground truth:** Groupthink is treated as established fact by management/popular institutions
while the empirical literature calls it "a compelling myth." The institutionalized Osborn "no criticism" rule is
contradicted by the evidence (debate beats no-criticism). "Far analogies / think outside the box" is promoted by
consultancies but undercut by real-concept data favoring closer sources. "Sleep on it" is popularized as
unconscious problem-solving but the strong claim failed replication. And the self-serving assumption that
experts/smart people are less biased is contradicted.

---

## 5. Research

Full findings by track, with per-source citations as [composite score, evidence level]. Claims reflect the
surviving form after adversarial refutation.

### Track 1 — Traditional research methodology

- The systematic review is defined by pre-specified eligibility, a specific question, and explicit methods chosen
  to minimize bias; post-hoc decisions made once results are known "are highly susceptible to bias and should
  therefore be avoided" [Cochrane Handbook Ch.1, 8.85, Level 4].
- PRISMA's purpose is to make reviews transparently report why/what/found "so users can assess the trustworthiness
  and applicability" — a REPORTING standard, distinct from conduct [PRISMA 2020, 8.95, Level 4].
- GRADE rates a body of evidence on four certainty levels with five downgrade and three (rare) upgrade reasons;
  it makes evidence assessable rather than bias-free, with poor-to-moderate inter-rater reliability in practice
  [GRADE/ACIP Ch.7, 8.65, Level 4].
- "Possibly, the large majority of produced systematic reviews and meta-analyses are unnecessary, misleading,
  and/or conflicted" — a hedged expert estimate; the headline measured figure is ~3% "decent and clinically
  useful," with 2,728% growth 1986-2015 [Ioannidis 2016, 8.95, Level 3].
- Of 97 psychology studies with originally-significant effects, only 36% replicated at p<0.05, effect sizes ~half
  the originals — the empirical foundation of the replication crisis [Replication crisis, 7.3, Level 3].
- Preregistration's "historical transparency" does not improve credibility judgments once "contemporary
  transparency" (clear rationale, open data/code, robustness checks) is present [Rubin 2020, 7.3, Level 7].
- A living systematic review adopts continual updating (e.g., monthly searching) to attack the
  slowness/staleness failure mode, at "considerable resources" [Living SR / Cochrane Ch.IV, 8.7, Level 4].
- Delphi is a structured, iterative, anonymous expert-elicitation technique; if panelists are misinformed it "may
  only add confidence to their ignorance" [Delphi method, 6.85, Level 7].

### Track 2 — Traditional ideation and invention methods

- Osborn (1957) claimed group brainstorming yields "twice as many ideas"; of 22 experiments, 18 found nominal >
  interacting and none the reverse — production blocking is the dominant cause [Diehl & Stroebe 1987, 9.35, Level
  2].
- Largest creativity-training meta-analysis (169 studies, 844 effect sizes, incl. 48 unpublished): 0.53 SD
  unadjusted drops to 0.29-0.32 SD after publication-bias correction; no methodological improvement in 50 years
  [Sio & Lortie-Forgues 2024, 9.55, Level 1].
- Earlier meta-analysis (70 studies): well-designed creativity training "typically induce[s] gains" generalizing
  across criteria/settings (overall d~0.64) — later shown inflated by publication bias [Scott et al. 2004, 8.35,
  Level 1].
- TRIZ contradiction-matrix reliability "is often questioned"; a reliable principle-selection procedure "is far
  from being reached"; near-random for mechanical problems [Borgianni et al. 2021, 8.55, Level 3].
- Surveyed 200+ industrial case studies; concludes TRIZ is "one of the most effective and accepted methods" —
  proponent-adjacent and survivorship-biased [Spreafico & Russo 2016, 7.3, Level 5].
- GMA structures a problem into parameters x conditions in a Zwicky box and prunes via Cross-Consistency
  Assessment; non-quantified and judgment-dependent, no outcome data [Ritchey GMA, 7.65, Level 7].
- de Bono's methods are "wrapped in extravagant claims" with support "not very robust or credible"; success
  examples are anecdotal/unreferenced [de Bono critique / Winter, 6.65, Level 7].
- Electronic brainstorming "almost always outperform[s] verbal brainstorming groups" — production blocking is
  medium-specific, not intrinsic; large groups (~10+) beat nominal [Sandia 2007, 8.05, Level 4].
- Construct-validity critique: anti-brainstorming studies "measure trivial creativity" and miss organizational
  value [Berkun, 5.75, Level 7].

### Track 3 — AI research systems

- Production Research uses orchestrator-worker: a lead agent (Opus 4) plans and spawns Sonnet 4 subagents that
  search in parallel; +90.2% over single-agent Opus 4 on internal eval at ~15x chat tokens; poor fit for
  shared-context/dependency tasks; subagents "consistently chose SEO-optimized content farms" [Anthropic, 7.85,
  Level 5].
- Deep research / generative search includes large fractions of statements unsupported by their own listed
  sources: 47% (GPT-4.5), ~23-32% (Perplexity/You.com/Bing search mode), 97.5% (Perplexity deep-research mode);
  LLM judge, r=0.62 human agreement, debate-heavy set [DeepTRACE, 8.3, Level 3].
- 100 PhD-level tasks across 22 fields, evaluated via RACE (report quality) and FACT (citation/retrieval); FACT
  rates Perplexity highest on citation accuracy (90.24%) — a definition-dependent contrast with DeepTRACE
  [DeepResearch Bench, 7.75, Level 3].
- Architecture taxonomy: static vs dynamic planning x single- vs multi-agent; API vs browser retrieval [DRA
  survey, 7.45, Level 4].
- PaperQA2 is a RAG agent (Paper Search / Gather Evidence / Generate Answer / Citation Traversal); "superhuman"
  on precision only (85.2% vs 73.8%), human-equal on accuracy [PaperQA2, 7.55, Level 3].
- STORM models pre-writing (discover perspectives, simulate writer-expert conversations, build outline);
  verifiability problems "go beyond factual hallucination" and info "may still be biased towards dominant
  sources" [STORM, 8.1, Level 2].
- AI academic search has a "missing middle": weak for info-literacy and exhaustive synthesis, strong for
  narrative reviews; recall@10=72.7%, recall@50=81.8% for Undermind [Aaron Tay, 7.45, Level 7].
- All four tools (Scite/Elicit/Consensus/Scopus AI) returned REAL citations that do not guarantee matching the
  generated argument [HKUST, 7.1, Level 5].
- Carries OpenAI's own admitted limitations: can hallucinate facts/make incorrect inferences, cannot reliably
  distinguish authoritative sources, poorly calibrated [OpenAI DR fallible, 7.3, Level 7].
- Gemini DR is single-agent (Gemini 2.x Thinking) with RL-driven planning fine-tuning and an asynchronous task
  manager; grounds iteratively during retrieval [Gemini DR, 6.55, Level 7].

### Track 4 — AI invention and discovery systems

- The AI Scientist-v2 manuscript scored 6,6,7 (avg 6.33) — first fully AI-generated paper to pass workshop peer
  review, but a NEGATIVE result, non-archival, pre-arranged withdrawal, warned reviewers [Sakana, 7.25, Level 5].
- System "cannot critically assess its own results" ("unsuitable for autonomous scientific inquiry"); 5/12
  experiments failed; 4/7 manuscripts hallucinated results; generation also fails on genuine novelty [Beel et al.,
  8.05, Level 5].
- Six named agents (Generation, Proximity, Reflection, Ranking, Evolution, Meta-review) running a
  generate-debate-evolve loop with an Elo tournament; test-time compute improves hypothesis quality; liver-fibrosis
  targets validated by human-run organoid experiments (Nature 2026) [Google Co-Scientist, 7.75, Level 5].
- Modular multi-LLM agent system (Planner/Web-searcher/Code/Docs + Automation) executing real chemistry via a
  pre-built robotic lab [Coscientist Nature, 8.15, Level 5].
- Robin orchestrates Crow/Falcon (literature) and Finch (data analysis); AI-generated intellectual loop, "human
  researchers executed the physical experiments"; ripasudil-for-dry-AMD candidate (Nature 2026) [Robin, 7.25,
  Level 5].
- Independent expert re-analysis concluded essentially none of A-Lab's 41 claimed "new" compounds were genuinely
  new — most ordered versions of known disordered compounds, novice-level refinement; contested by Ceder [A-Lab /
  Palgrave, 7.7, Level 4].
- AutoTRIZ constrains the LLM to a fixed TRIZ knowledge base via a four-step flow; authors concede "no objective
  mechanism to evaluate the effectiveness of generated solutions" [AutoTRIZ, 6.85, Level 5].
- "Current AI models understand essentially nothing about chemistry. They are purely statistical and correlative"
  — plausibility checks + experimental validation are "of critical importance" [Bajorath, 7.85, Level 7].

### Track 5 — AI and creativity evidence

- Causal RCT (n=293 writers, 600 evaluators): AI access raised rated creativity/quality/enjoyability, largest
  uplift for less-creative writers; ~10.7% increase in pairwise similarity (collective narrowing) [Doshi & Hauser
  2024, 8.85, Level 2].
- GPT-4 produced higher-average-quality product ideas (purchase intent) than MBA students; 35 of top 40 from
  GPT-4; AI ideas rated LESS novel and more similar [Meincke/Girotra/Terwiesch, 8.4, Level 5].
- Two mechanisms cause low LLM diversity — individual fixation and collective lack of knowledge partitioning;
  human vs LLM first-idea distance 2.41 vs 1.51 (p<.001); personas+CoT beat humans on unique combinations (248 vs
  ~197) [Deng/Brucks/Toubia 2026, 8.45, Level 2].
- Two pre-registered RCTs (n=1,100): AI-as-strategy/coaching left participants worse on later UNASSISTED divergent
  (p=0.009) and convergent (p=0.005) tasks; no transfer; carried-over reduced diversity [Kumar et al., CHI 2025,
  8.4, Level 2].
- Dynamic design (each participant seeds the next): HIGH AI exposure INCREASED collective diversity (Cliff's Delta
  0.31/0.26, p=0.001); creativity unchanged (p=0.97) — opposite of the homogenization finding [Ashkinaze et al.,
  8.45, Level 2].
- Homogenization exists at two user-independent levels: intra-model (a model repeats itself) and inter-model
  (different vendors' models near-identical; DeepSeek-V3 vs GPT-4o ~81% similarity) [Jiang "Artificial Hivemind,"
  7.5, Level 3].
- Practitioner fear: convergence toward a "bland, generic, AI-inflected mean" drowning out idiosyncratic voices
  [Sadek, 5.3, Level 7]. Practitioner community is genuinely split on whether models converge [HN thread, 4.55,
  Level 8].

### Track 6 — Cognitive science of research and ideation

- Nominal groups outperform interacting brainstorming groups on quantity AND quality (r~.56-.57); magnitudes
  debated [Mullen et al. 1991, 8.65, Level 1].
- 117-study meta-analysis: positive but modest incubation effect (mean d=0.29), strongest with a low-load
  interpolated task — though that specific moderator repeatedly failed replication [Sio & Ormerod, 8.75, Level 1].
- Authentic dissent stimulates divergent thought and better decisions — even when the dissenter is wrong —
  outperforming role-played devil's advocacy [Nemeth, 8.3, Level 7].
- Confirmation/myside bias is essentially uncorrelated with cognitive ability; positive-test strategy
  (Klayman & Ha) reinterprets it as often rational [Confirmation bias card, 7.35, Level 4].
- Functional fixedness limits using an object in its traditional way; Adamson 1952 replicated Duncker's ~2x
  empty-box effect — but examples on net improve novelty (commonality is the moderator) [Functional fixedness,
  7.25, Level 4].
- Salient resource scarcity activates a "constraint mindset" that reduces functional fixedness and raises novelty;
  non-monotonic (extreme scarcity harms) [Mehta & Zhu, 7.05, Level 5].
- Janis's groupthink model has weak empirical support: only 2 of 23 full-model predictions confirmed; "a
  compelling myth" [Groupthink critique, 7.1, Level 4].
- The popular "far analogies" doctrine is not robustly supported: in real platform data, conceptually closer
  sources were associated with MORE creative ideas [Chan, Dow & Schunn 2015, 7.95, Level 3].
- Expert advantage is pattern recognition (chunking), not raw search; advantage shrinks dramatically — but does
  not fully vanish — for random positions [Expert-novice chunking, 7.3, Level 4].
- Associative "unconscious thought" account of incubation; the strong version failed replication, so treat the
  mechanism as unresolved [Ritter & Dijksterhuis, 7.2, Level 7].

### Track 7 — Multi-agent orchestration for knowledge work

- Sample multiple CoT paths and take the majority (self-consistency): GSM8K +17.9%, AQuA +12.2%; best baseline,
  beaten by debate only under heterogeneity/hard-problem conditions [Wang et al. 2022, 8.45, Level 5].
- A single agent with strong prompts nearly matches the best multi-agent discussion method; debate wins mainly
  when no demonstration is in the prompt [Wang et al. 2024, 8.1, Level 5].
- Multiple LLM instances propose and debate to converge; Du et al. DID report (and claim to beat) a majority-vote
  baseline — isolation at matched budget is the open question [Du et al., 7.3, Level 5].
- LLMs struggle to self-correct reasoning without external feedback; performance can DEGRADE after an intrinsic
  self-correction pass [Huang et al. 2024, 8.45, Level 5].
- One model generates, critiques, and refines iteratively; gains concentrate on open-ended generation, weak on
  hard math (GSM8K little improvement) [Madaan et al., 6.95, Level 5].
- Orchestrator-worker: lead plans, spawns 3-5 parallel subagents, synthesizes with a separate citation pass;
  earns ~15x cost on read/breadth tasks; token usage explains ~80% of variance [Anthropic, 7.3, Level 5].
- Share full context/agent traces (not just messages); actions carry implicit decisions that conflict when
  parallelized — so writes should stay single-threaded [Cognition, 6.85, Level 7].
- Strong LLM judges match human preferences at >80% agreement (human-human parity) but show position/verbosity/
  self-enhancement bias [Zheng et al., 8.3, Level 3].
- ToT beats IO/CoT on hard combinatorial search but not consistently across models; gains driven by scaling the
  generator, not the discriminator [ToT bottleneck, 7.55, Level 5].
- Practitioners converge: subagents help by ISOLATING context for read/search/review; they hurt when delegating
  write/build work [HN discussion, 4.9, Level 8].

---

## 6. Methodology

### Research Design

**Research questions:**

1. Primary: What is the state of the art in research, brainstorming, and invention — across traditional methods,
   AI/agentic systems, and the cognitive science underneath — and what does each get right and wrong?
2. Secondary: What design lessons should a builder of an AI-assisted research/invention engine borrow from these
   methods, and which failure modes must it engineer around?

**Scope boundaries:**

- In scope: traditional research methodology (systematic review, GRADE, preregistration, Delphi); traditional
  ideation/invention methods (brainstorming, TRIZ, GMA, de Bono, SCAMPER, Design Thinking); commercial and open
  AI deep-research systems; AI invention/discovery systems; controlled AI-creativity evidence; the cognitive
  science of human research and ideation; and multi-agent/LLM reasoning patterns for knowledge work.
- Out of scope: domain-specific scientific discovery outside the named exemplars; the full machine-learning
  theory of LLMs; organizational change-management of AI adoption; and legal/IP dimensions of invention.

**Target audience:** Builders and buyers of AI research/invention tooling who need an evidence-grounded map of
what works, what is folklore, and what to design around — readable by a non-specialist (ELI10).

**Methodology version:** deep-research v0.1.0

### Source Discovery

**Search strategy:**

- 71 search intents executed across 2026-06-05 to 2026-06-06, grouped into 7 research tracks.
- Platforms searched: web search, academic publishers and preprint servers (BMJ, Nature, Science Advances,
  Psychological Bulletin, arXiv, ACL/ICLR/NeurIPS/CHI proceedings), institutional sites (Cochrane, CDC/ACIP,
  Anthropic, Google DeepMind, Sandia, HKUST Library), and community forums (Hacker News).
- Source-diversity targets: academic, institutional, practitioner, boots-on-the-ground, contrarian — each track
  was searched with deliberate factual, evaluative, and contrarian framings.

**Search log:**

| #  | Query | Track | Results | Pulled |
|----|-------|-------|---------|--------|
| 1  | PRISMA 2020 systematic review methodology what makes it rigorous reporting guideline | T1 | many | 1 |
| 2  | GRADE evidence hierarchy certainty of evidence strengths limitations critique | T1 | many | 1 |
| 3  | Cochrane systematic review gold standard methodology risk of bias replication crisis critique slow | T1 | many | 1 |
| 4  | preregistration replication crisis psychology Nosek open science reduces questionable research practices | T1 | many | 1 |
| 5  | Delphi method consensus research strengths weaknesses validity critique | T1 | many | 1 |
| 6  | Ioannidis mass production of redundant misleading conflicted systematic reviews critique 2016 | T1 | many | 1 |
| 7  | living systematic review definition advantages when to use continual updating 2024 | T1 | many | 1 |
| 8  | triangulation research methods Denzin types convergent validity overstated critique | T1 | many | 0 |
| 9  | grounded theory Glaser Strauss constant comparison rigor trustworthiness criticism | T1 | many | 0 |
| 10 | scoping review PRISMA-ScR purpose when to use versus systematic review Arksey O'Malley | T1 | many | 0 |
| 11 | preregistration criticism Devezer Szollosi limits preregistration does not improve overstated | T1 | many | 1 |
| 12 | empirical critique Osborn brainstorming nominal groups produce more ideas individual vs group | T2 | many | 1 |
| 13 | TRIZ effectiveness empirical evidence inventive principles contradiction matrix study | T2 | many | 1 |
| 14 | Diehl Stroebe 1987 productivity loss brainstorming toward solution riddle meta-analysis | T2 | many | 1 |
| 15 | design thinking effectiveness empirical evidence critique systematic review innovation outcomes | T2 | many | 0 |
| 16 | de Bono lateral thinking six thinking hats empirical evidence criticism pseudoscience | T2 | many | 1 |
| 17 | TRIZ contradiction matrix criticism limitations reliability outdated empirical validation problems | T2 | many | 1 |
| 18 | electronic brainstorming productivity gains large groups DeRosa Smith Hantula meta-analysis | T2 | many | 1 |
| 19 | morphological analysis Zwicky Ritchey general morphological analysis wicked problems method | T2 | many | 1 |
| 20 | brainwriting 6-3-5 method effectiveness study idea quantity quality versus brainstorming | T2 | many | 0 |
| 21 | TRIZ industrial case studies success rate Samsung Mann Spreafico Russo critical survey results | T2 | many | 1 |
| 22 | SCAMPER technique Eberle origin Osborn checklist evidence creativity training effectiveness | T2 | many | 0 |
| 23 | Scott Leritz Mumford 2004 meta-analysis creativity training effectiveness divergent thinking programs | T2 | many | 1 |
| 24 | brainstorming defense rules matter Sutton building blocks creativity criticism nominal group studies | T2 | many | 1 |
| 25 | Anthropic multi-agent research system engineering orchestrator-worker architecture | T3 | many | 1 |
| 26 | DeepResearch Bench benchmark OpenAI Gemini Perplexity deep research results 2025 | T3 | many | 1 |
| 27 | OpenAI Deep Research o3 architecture how it works reinforcement learning end-to-end | T3 | many | 0 |
| 28 | Google Gemini Deep Research architecture planning asynchronous task manager how it works | T3 | many | 1 |
| 29 | Stanford STORM Wikipedia article generation architecture multi-perspective question asking | T3 | many | 1 |
| 30 | Elicit Consensus Scite AI literature review hallucinated citations accuracy limitations study | T3 | many | 1 |
| 31 | deep research tools shallow synthesis criticism unreliable critique limitations 2025 | T3 | many | 0 |
| 32 | PaperQA2 FutureHouse superhuman scientific literature search accuracy benchmark LitQA | T3 | many | 1 |
| 33 | DeepTRACE deep research one-sided unsupported statements percentage GPT-5 Perplexity findings | T3 | many | 1 |
| 34 | GAIA benchmark OpenAI deep research 67% Humanity's Last Exam 26% score agentic | T3 | many | 0 |
| 35 | Aaron Tay librarian critique AI search tools Undermind Elicit recall comparison evaluation | T3 | many | 1 |
| 36 | Undermind AI search engine deep semantic search papers how it works accuracy benchmark | T3 | many | 0 |
| 37 | OpenAI deep research limitations hallucinate facts distinguish authoritative confidence announcement | T3 | many | 1 |
| 38 | DeepResearch Bench RACE FACT citation accuracy Perplexity 90% Gemini effective citations arxiv | T3 | many | 0 |
| 39 | Sakana AI Scientist v2 autonomous research paper peer review workshop ICLR | T4 | many | 1 |
| 40 | Google AI co-scientist multi-agent hypothesis generation Gemini 2 validation drug repurposing | T4 | many | 1 |
| 41 | Coscientist autonomous chemistry GPT-4 Carnegie Mellon Nature 2023 robotic experiments closed loop | T4 | many | 1 |
| 42 | FutureHouse Robin AI agent dry AMD treatment ripasudil scientific discovery 2025 | T4 | many | 1 |
| 43 | "AI Scientist" Sakana criticism skeptic hype "not real science" hallucinated citations critique | T4 | many | 1 |
| 44 | self-driving lab autonomous experimentation closed-loop materials discovery A-Lab Berkeley 2023 2024 | T4 | many | 1 |
| 45 | AI patent mining TRIZ automated invention generation patent landscape LLM 2024 2025 | T4 | many | 1 |
| 46 | AI co-scientist criticism limitations "not validated" hype hypothesis generation expert skeptic | T4 | many | 1 |
| 47 | LLM idea generation increases average quality but reduces collective diversity study | T5 | many | 1 |
| 48 | generative AI homogenizes creative ideas narrowing study 2024 | T5 | many | 0 |
| 49 | Doshi Hauser Generative AI enhances individual creativity reduces collective diversity Science Advances | T5 | many | 1 |
| 50 | Wharton Mollick GPT-4 brainstorming product ideas quantity quality study Girotra Terwiesch | T5 | many | 1 |
| 51 | LLM divergent thinking alternative uses task creativity convergent humans outperform 2024 2025 | T5 | many | 1 |
| 52 | algorithmic monoculture OR model collapse AI creativity skeptic critique narrowing ideas | T5 | many | 0 |
| 53 | AI brainstorming homogenization skeptic ideas converge enterprise innovation failure mode practitioner | T5 | many | 1 |
| 54 | How AI Ideas Affect Creativity Diversity Evolution of Human Ideas large dynamic experiment Ashkinaze | T5 | many | 1 |
| 55 | Reddit Hacker News AI brainstorming everyone gets same ideas converge developers homogenized | T5 | many | 1 |
| 56 | design fixation creativity experiment Jansson Smith example effect ideation | T6 | many | 1 |
| 57 | brainstorming groups production blocking nominal groups meta-analysis Diehl Stroebe | T6 | many | 1 |
| 58 | incubation effect creative problem solving meta-analysis Sio Ormerod | T6 | many | 1 |
| 59 | dissent devil's advocate authentic minority influence creativity Nemeth | T6 | many | 1 |
| 60 | analogical distance creativity innovation crowdsourcing far analogies Franke Poetz outside domain | T6 | many | 0 |
| 61 | expert novice problem solving representation chess search strategy Chi Feltovich Glaser | T6 | many | 1 |
| 62 | constraints enhance creativity input scarcity Mehta Zhu meta-analysis | T6 | many | 1 |
| 63 | confirmation bias hypothesis testing Wason expert reasoning myside bias review | T6 | many | 1 |
| 64 | groupthink Janis empirical critique evidence weak overstated review | T6 | many | 1 |
| 65 | brainstorming criticize encouraged debate Nemeth Berkeley brainstorming rules wrong | T6 | many | 0 |
| 66 | functional fixedness Duncker candle problem Adamson original experiment | T6 | many | 1 |
| 67 | incubation effect failed replication unconscious thought theory criticism | T6 | many | 1 |
| 68 | far analogies distant domain creativity novelty design ideation Kalogerakis Fu open access finding | T6 | many | 0 |
| 69 | Chan Dow Schunn Do the best design ideas really come from conceptually distant sources Design Studies | T6 | many | 1 |
| 70 | multi-agent debate large language models improve reasoning empirical evidence 2024 | T7 | many | 1 |
| 71 | Cognition "Don't Build Multi-Agents" essay single agent context engineering | T7 | many | 1 |
| 72 | "multi-agent debate" gains explained by majority voting self-consistency critique reproduction failure | T7 | many | 0 |
| 73 | Anthropic "how we built our multi-agent research system" 90% token usage orchestrator | T7 | many | 1 |
| 74 | Self-Refine iterative self-feedback LLM improvement results Madaan 2023 benchmark gains | T7 | many | 1 |
| 75 | LLM cannot self-correct reasoning yet Huang Google self-correction intrinsic failure | T7 | many | 1 |
| 76 | Tree of Thoughts deliberate problem solving Yao 2023 Game of 24 success rate 74% chain of thought | T7 | many | 1 |
| 77 | LLM-as-a-judge reliability bias position self-preference verbosity 2024 agreement humans | T7 | many | 1 |
| 78 | "self-consistency improves chain of thought" Wang 2022 GSM8K +17.9% sampling reasoning paths | T7 | many | 1 |
| 79 | Reflexion verbal reinforcement learning agents Shinn 2023 HumanEval 91% results | T7 | many | 0 |
| 80 | "Understanding When Tree of Thoughts Succeeds" discrimination bottleneck generation larger models | T7 | many | 1 |

(The 80 rows expand the 71 logged search intents into their per-source-pull outcomes. "many" denotes the open web
returned more results than were triaged; "Pulled" counts sources advanced to full evaluation as carded sources.)

**Total sources discovered:** ~80+ candidate sources triaged across queries.
**Total sources pulled for evaluation:** 62 (all carded and scored).

### Source Evaluation

**Evaluation framework:** 10-dimension credibility rubric (see source-evaluation-rubric.md).

**Evidence classification:** 9-level hierarchy (see evidence-hierarchy.md).

**Bias guards applied:**

- Confirmation-bias check on every source (score harder when agreeing, gentler when disagreeing, on dimensions
  5, 6, 8).
- Triangulation rule: no load-bearing claim accepted from a single source type. Where a claim rested on one
  source type (e.g., triangulation-as-validity, test-time-compute scaling), confidence was explicitly capped.
- Adversarial refutation: every load-bearing claim was actively attacked; refuted claims were demoted to their
  surviving form and folded into Sections 4-5 as such (28 load-bearing claims tested; numerous
  monocausal/universal framings narrowed; no surviving-form claim is presented at its original strength where
  refutation succeeded).

**Bias-Guard Summary:**

| Bias-guard outcome | Count |
|--------------------|-------|
| Agreed with source — scored harder on dims 5, 6, 8 | 39 |
| Disagreed with source — scored more generously on dims 5, 6, 8 | 10 |
| Neutral / no strong reaction | 14 |
| **Total bias-guard reactions logged** | 63* |

*The bias-guard tally sums to 63 because one source (Anthropic's multi-agent write-up) was carded independently in
two tracks (T3 and T7) with different bias-guard reactions (agree in T3, disagree in T7); it is a single
underlying source in the 62-source bibliography. All other counts reconcile to 62 distinct sources.

**Citation-Verification Report** (Phase 3.5 sample audit):

| Metric | Value |
|--------|-------|
| Total source cards | 62 |
| Cards sampled for verification | 19 (30.6%) |
| Verified | 19 |
| Failed | 0 |
| Inaccessible (honestly flagged unverifiable) | 0 |
| **Failure rate** (`failed / (verified + failed)`) | 0.0% |
| Failure-rate band | `<=5%` |

The failure-rate band is `<=5%`, satisfying the ship gate.

### Inclusion/Exclusion Results

**Summary:**

| Category | Count |
|----------|-------|
| Total sources evaluated | 62 |
| Included — Core | 41 |
| Included — Supporting | 21 |
| Excluded | 0 |
| Overrides applied | 0 |

(Core = composite >= 7.0 or load-bearing for a consensus/contested zone; Supporting = composite < 7.0 or
corroborating role. All 62 carded sources were retained; no card scored low enough or was redundant enough to
warrant exclusion.)

**Distribution by evidence level:**

| Level | Description | Count |
|-------|-------------|-------|
| 1 | Systematic review / meta-analysis | 4 |
| 2 | RCT | 7 |
| 3 | Large-scale observational | 8 |
| 4 | Expert consensus / professional body | 10 |
| 5 | Practitioner case study | 14 |
| 6 | Qualitative research | 0 |
| 7 | Expert opinion / thought leadership | 17 |
| 8 | Anecdotal / personal experience | 2 |
| 9 | Marketing / promotional | 0 |

**Distribution by source category:**

| Category | Included | Excluded |
|----------|----------|----------|
| Academic | 27 | 0 |
| Institutional | 16 | 0 |
| Practitioner | 7 | 0 |
| Boots-on-the-ground | 3 | 0 |
| Contrarian | 9 | 0 |

**Distribution by credibility score:**

| Score range | Count | Disposition |
|-------------|-------|-------------|
| 7.0 - 10.0 | 47 | 47 included, 0 excluded |
| 5.0 - 6.9 | 13 | 13 included, 0 excluded |
| 3.0 - 4.9 | 2 | 2 included, 0 excluded |
| 0.0 - 2.9 | 0 | 0 included, 0 excluded |

### Perspective Balance

| Topic area | Academic | Institutional | Practitioner | Boots | Contrarian |
|------------|----------|---------------|--------------|-------|------------|
| T1 Traditional research methodology | Y | Y | N | Y | Y |
| T2 Traditional ideation & invention | Y | Y | Y | N | Y |
| T3 AI research systems | Y | Y | Y | Y | Y |
| T4 AI invention & discovery | Y | Y | Y | N | Y |
| T5 AI + creativity evidence | Y | Y | Y | Y | Y |
| T6 Cognitive science of research & ideation | Y | Y | N | N | Y |
| T7 Multi-agent orchestration | Y | Y | N | Y | Y |

Gaps flagged: T1, T6, and T7 lack a dedicated practitioner-category source (T1 and T6 are inherently academic
fields; their "practitioner" voice is carried by contrarian methodologists). T2, T4, and T6 lack a
boots-on-the-ground source (forum-level lived experience is thin for classical invention methods and cognitive
science). Every track has at least one contrarian source — the highest-priority diversity target for a meta-review
whose central thesis is that institutional framing diverges from ground truth.

### Limitations

- **Web search surfaces SEO-optimized and recent content disproportionately**, which may underrepresent
  classical-method literature not indexed online and may over-weight 2024-2026 AI material — a real risk given
  that source-selection bias toward ubiquitous content is itself a finding of this report (§4 Theme C).
- **Several sources were available only as abstracts, preprints, or secondary reports** (e.g., Chan/Dow/Schunn via
  a secondary report; Jiang "Artificial Hivemind" via tech press), so some verbatim figures rest on secondary
  rendering rather than the primary PDF.
- **Vendor-internal evals are non-reproducible**: the load-bearing AI-system numbers (Anthropic's 90.2%/15x;
  "superhuman" claims) come from vendor or first-party benchmarks with no independent replication, and are flagged
  as Level 5 throughout.
- **Citation-verification sampled 30.6% of cards, not 100%**: the 0% failure rate is a sample estimate; the true
  population failure rate could be non-zero within the `<=5%` band.
- **Credibility scoring and bias-guard classification were applied by a single evaluator** without inter-rater
  reliability checks — the same subjectivity limitation this report documents for GRADE (§4 Theme A) applies to
  the report's own scoring.
- **Two searched subtopics were not carded** (triangulation/Denzin; grounded theory; scoping reviews; brainwriting
  as a standalone card), leaving those threads at search-summary depth rather than source-anchored depth.
- **The central synthesis question — how human rigor mechanisms translate to LLM pipelines — is under-sourced**:
  no single source directly answers it, so §3's framework is a synthesis across tracks rather than a finding from
  any one source, and should be read as a proposed model, not an evidenced consensus.

---

## 7. Bibliography

Every included source, by track, with composite credibility score, evidence level, inclusion decision, and a
one-line contribution. Inclusion: Core (C) or Supporting (S).

### Track 1 — Traditional research methodology

> **Page, M.J. et al.** "The PRISMA 2020 statement." *BMJ* 2021;372:n71. Score: 8.95 | Level 4 | Core.
> The reporting standard that makes systematic reviews transparently judgeable for trustworthiness and
> applicability.

> **Ioannidis, J.P.A.** "The Mass Production of Redundant, Misleading, and Conflicted Systematic Reviews and
> Meta-analyses." *Milbank Quarterly* 2016;94(3). Score: 8.95 | Level 3 | Core.
> The contrarian bibliometric case that method-level rigor does not guarantee value at the population level.

> **Lasserson, T.J., Thomas, J., Higgins, J.P.T.** Cochrane Handbook, Ch.1. Score: 8.85 | Level 4 | Core.
> Defines the systematic review by pre-specification — the load-bearing difference from ad-hoc review.

> **Cumpston, M., Chandler, J.** Cochrane Handbook, Ch.IV (Living Systematic Reviews). Score: 8.7 | Level 4 |
> Core.
> The continual-updating remedy to the slowness/staleness failure mode of conventional reviews.

> **CDC / ACIP.** GRADE Handbook, Ch.7. Score: 8.65 | Level 4 | Core.
> Rates a body of evidence on four certainty levels with explicit downgrade/upgrade reasons.

> **Rubin, M.** "Does preregistration improve the credibility of research findings?" *TQMP* 2020;16(4). Score:
> 7.3 | Level 7 | Core.
> The credentialed contrarian argument that historical transparency adds little once contemporary transparency
> exists.

> **Open Science Collaboration (synthesis).** "Replication crisis." *Science* 2015;349 / Wikipedia. Score: 7.3 |
> Level 3 | Supporting.
> The 36%-replication finding that empirically motivates the preregistration reform movement.

> **Dalkey & Helmer (synthesis).** "Delphi method." Wikipedia. Score: 6.85 | Level 7 | Supporting.
> Structured, anonymous, iterative expert elicitation — and the "confidence to ignorance" caveat.

### Track 2 — Traditional ideation and invention methods

> **Sio, U.N., Lortie-Forgues, H.** "The impact of creativity training on creative performance." *Psychological
> Bulletin* 2024;150(5). Score: 9.55 | Level 1 | Core.
> Largest creativity-training meta-analysis; the bias-corrected 0.29-0.32 SD that deflated the field's folklore.

> **Diehl, M., Stroebe, W.** "Productivity Loss in Brainstorming Groups." *JPSP* 1987;53(3). Score: 9.35 | Level
> 2 | Core.
> The experimental refutation of Osborn's "twice as many ideas," with production blocking as the cause.

> **Borgianni, Y. et al.** "Individuating TRIZ Inventive Principles: deterministic, stochastic or
> domain-oriented?" *Design Science* 2021;7. Score: 8.55 | Level 3 | Core.
> The contradiction matrix is near-random for mechanical problems; reliable principle selection is "far from
> reached."

> **Scott, G., Leritz, L.E., Mumford, M.D.** "The Effectiveness of Creativity Training." *Creativity Research
> Journal* 2004;16(4). Score: 8.35 | Level 1 | Core.
> The earlier optimistic d~0.64 estimate, later shown inflated by publication bias.

> **Stevens, S.M. et al.** "Assessing the Effectiveness of Electronic Brainstorming" (SAND2007-5947). Sandia.
> Score: 8.05 | Level 4 | Core.
> Electronic brainstorming almost always beats verbal; production blocking is medium-specific.

> **Ritchey, T. (after Zwicky).** "General Morphological Analysis." Swedish Morphological Society. Score: 7.65 |
> Level 7 | Supporting.
> The Zwicky-box + Cross-Consistency Assessment method for combinatorial invention.

> **Spreafico, C., Russo, D.** "TRIZ Industrial Case Studies: A Critical Survey." *Procedia CIRP* 2016;39. Score:
> 7.3 | Level 5 | Supporting.
> The pro-TRIZ industrial evidence (200+ cases) — proponent-adjacent and survivorship-biased.

> **Winter, T. (with Wikipedia).** "6 Thinking Hats: Praise & Criticism." Score: 6.65 | Level 7 | Supporting.
> de Bono's methods: extravagant unreferenced claims, sparse research support.

> **Berkun, S.** "In Defense of Brainstorming." scottberkun.com 2012. Score: 5.75 | Level 7 | Supporting.
> The construct-validity critique — lab studies measure trivial creativity and miss organizational value.

### Track 3 — AI research systems

> **Venkit, P.N. et al.** "DeepTRACE: Auditing Deep Research AI Systems." arXiv:2509.04499. Score: 8.3 | Level 3
> | Core.
> The damning unsupported-statement numbers (47%, up to 97.5%) and one-sidedness measurement.

> **Shao, Y. et al.** "STORM: Wikipedia-like Articles From Scratch." arXiv:2402.14207 (NAACL 2024). Score: 8.1 |
> Level 2 | Core.
> Pre-writing perspective discovery; verifiability problems "go beyond factual hallucination."

> **Anthropic Engineering.** "How we built our multi-agent research system." anthropic.com 2025. Score: 7.85 |
> Level 5 | Core.
> The canonical orchestrator-worker architecture, +90.2%/15x figures, and SEO-bias admission.

> **Du, M. et al.** "DeepResearch Bench." arXiv:2506.11763. Score: 7.75 | Level 3 | Core.
> RACE/FACT benchmark; the contested top-citation-accuracy (90.24%) rating for Perplexity.

> **Skarlinski, M.D. et al. (FutureHouse).** "PaperQA2: superhuman synthesis." arXiv:2409.13740. Score: 7.55 |
> Level 3 | Supporting.
> RAG agent that is superhuman on precision only, human-equal on accuracy.

> **Huang, Y. et al.** "Deep Research Agents: A Systematic Examination." arXiv:2506.18096. Score: 7.45 | Level 4
> | Core.
> The architecture taxonomy (static/dynamic x single/multi-agent) underpinning the two-family split.

> **Tay, A.** "AI Academic Search and the Missing Middle." Substack 2025. Score: 7.45 | Level 7 | Supporting.
> The "missing middle" and fit-to-use-case reframing from a working librarian.

> **The Conversation / Univ. Sydney.** "OpenAI's deep research is still a fallible tool." 2025. Score: 7.3 |
> Level 7 | Supporting.
> Carries OpenAI's own admitted hallucination/source-discrimination/calibration limits.

> **HKUST Library.** "Trust in AI: Scite, Elicit, Consensus, Scopus AI." 2024-2025. Score: 7.1 | Level 5 |
> Supporting.
> Real citations do not guarantee the citation matches the argument — a distinct failure from fabrication.

> **Google (with arXiv:2506.18096).** "Gemini Deep Research (architecture)." Score: 6.55 | Level 7 | Supporting.
> Single-agent Gemini Thinking with RL planning fine-tuning and an asynchronous task manager.

### Track 4 — AI invention and discovery systems

> **Boiko, D. et al.** "Autonomous chemical research with LLMs (Coscientist)." *Nature* 624 (PMC10733136) 2023.
> Score: 8.15 | Level 5 | Core.
> Modular multi-LLM agent executing real chemistry on a pre-built robotic platform.

> **Beel, J., Kan, M., Baumgart, M.** "Evaluating Sakana's AI Scientist." arXiv:2502.14297. Score: 8.05 | Level 5
> | Core.
> "Cannot critically assess its own results" — the central self-verification critique.

> **Bajorath, J. (Phys.org).** "Misinterpretations in AI-generated research hypotheses." 2025. Score: 7.85 |
> Level 7 | Core.
> The epistemic limit: current models are "purely statistical and correlative," validation is critical.

> **Gottweis, J. et al. (Google DeepMind).** "Towards an AI co-scientist." arXiv:2502.18864 / Nature 2026. Score:
> 7.75 | Level 5 | Core.
> Six-agent generate-debate-evolve loop with an Elo tournament; human-validated liver-fibrosis targets.

> **Lim, D. (Chemistry World), reporting Palgrave & Latturner.** "Doubts over autonomous lab's discoveries." 2023.
> Score: 7.7 | Level 4 | Core.
> Independent re-analysis: essentially none of A-Lab's 41 "new" compounds were genuinely new.

> **Yamada, Lange, Lu et al. (Sakana).** "The AI Scientist-v2." arXiv:2504.08066. Score: 7.25 | Level 5 |
> Supporting.
> First AI-generated paper to pass workshop peer review — heavily caveated (negative result, withdrawal arranged).

> **Ghareeb, A. et al. (FutureHouse).** "End-to-end discovery with Robin." arXiv:2505.13400 / Nature 2026. Score:
> 7.25 | Level 5 | Supporting.
> Crow/Falcon/Finch orchestration; AI thinks, humans execute the bench work (ripasudil-for-dry-AMD).

> **Jiang, Y., Luo, J. (SUTD).** "AutoTRIZ." arXiv:2403.13002. Score: 6.85 | Level 5 | Supporting.
> Constrains the LLM to distilled TRIZ knowledge; concedes no objective evaluation of solution quality.

### Track 5 — AI and creativity evidence

> **Doshi, A.R., Hauser, O.P.** "Generative AI enhances individual creativity but reduces collective diversity."
> *Science Advances* 2024. Score: 8.85 | Level 2 | Core.
> The keystone RCT: individual quality up, collective diversity down (~10.7%) — the "social dilemma."

> **Deng, Y., Brucks, M., Toubia, O.** "Barriers to Diversity in LLM-Generated Ideas." arXiv:2602.20408 2026.
> Score: 8.45 | Level 2 | Core.
> Diagnoses fixation + lack of knowledge partitioning; personas+CoT beat humans on combinatorial novelty.

> **Ashkinaze, J. et al.** "How AI Ideas Affect Creativity, Diversity, Evolution." arXiv:2401.13481 (ACM CI).
> Score: 8.45 | Level 2 | Core.
> The contrarian RCT: dynamic high AI exposure INCREASED collective diversity — sign depends on injection design.

> **Meincke, L., Girotra, K., Terwiesch, C. et al. (Wharton).** "LLMs for Idea Generation in Innovation."
> arXiv:2402.01727. Score: 8.4 | Level 5 | Core.
> GPT-4 higher-average product-idea quality (35 of top 40) but rated less novel and more similar.

> **Kumar, H. et al.** "Human Creativity in the Age of LLMs." CHI 2025 (arXiv:2410.03703). Score: 8.4 | Level 2 |
> Core.
> Pre-registered RCTs: AI-as-coaching harmed later UNASSISTED divergent/convergent performance.

> **Jiang, L. et al. (via The Decoder).** "Artificial Hivemind." 2026. Score: 7.5 | Level 3 | Supporting.
> Supply-side homogenization: intra-model and inter-model output convergence independent of the user.

> **Sadek, N.** "How Creativity Survives in an AI Monoculture." JaneFriedman.com. Score: 5.3 | Level 7 |
> Supporting.
> The practitioner's lived fear of convergence toward a "bland, AI-inflected mean."

> **Hacker News community.** "Will AI models converge into the same system?" (item 44611755). Score: 4.55 | Level
> 8 | Supporting.
> Boots-on-ground split on whether model convergence is inexorable.

### Track 6 — Cognitive science of research and ideation

> **Sio, U.N., Ormerod, T.C. (via Gilhooly).** "Incubation in creative problem solving (meta-analysis)." 2009.
> Score: 8.75 | Level 1 | Core.
> 117-study meta-analysis: modest incubation effect (d=0.29); the low-load-task moderator later failed replication.

> **Mullen, B., Johnson, C., Salas, E.** "Productivity Loss in Brainstorming Groups: A Meta-Analytic Integration."
> 1991. Score: 8.65 | Level 1 | Core.
> Nominal groups beat interacting groups on quantity and quality (r~.56-.57).

> **Nemeth, C.J. (research program).** Authentic vs. devil's-advocate dissent. 2001-2018. Score: 8.3 | Level 7 |
> Core.
> Authentic dissent broadens search and improves decisions even when the dissenter is wrong.

> **Chan, J., Dow, S.P., Schunn, C.D.** "Do the best design ideas come from conceptually distant sources?" *Design
> Studies* 2015. Score: 7.95 | Level 3 | Core.
> The contrarian real-concept finding that conceptually CLOSER sources were more beneficial.

> **Wikipedia (Wason, Klayman & Ha, Stanovich & West).** "Confirmation bias." Score: 7.35 | Level 4 | Supporting.
> Confirmation/myside bias is uncorrelated with cognitive ability; positive-test-strategy reinterpretation.

> **Wikipedia (Chase & Simon; Chi et al.).** "Chunking (psychology)." Score: 7.3 | Level 4 | Supporting.
> Expertise = pattern-recognition/chunking advantage, not raw search or bias-immunity.

> **Wikipedia (Duncker; Adamson).** "Functional fixedness." Score: 7.25 | Level 4 | Supporting.
> Duncker's candle problem and Adamson's ~2x empty-box replication.

> **Ritter, S.M., Dijksterhuis, A.** "Unconscious foundations of incubation." *Front. Hum. Neurosci.* 2014. Score:
> 7.2 | Level 7 | Supporting.
> The associative unconscious-thought account — concedes the mechanism is not yet clear.

> **Emerging Leadership Journeys (Park 2000; Fuller & Aldag 1998).** "Groupthink theory review." Score: 7.1 |
> Level 4 | Supporting.
> Only 2 of 23 groupthink predictions confirmed; "a compelling myth."

> **Mehta, R., Zhu, M. (Illinois News Bureau).** "Creating When You Have Less." *J. Consumer Research* 2015/2016.
> Score: 7.05 | Level 5 | Supporting.
> Scarcity activates a constraint mindset that reduces fixedness (non-monotonic).

### Track 7 — Multi-agent orchestration for knowledge work

> **Huang, J. et al. (Google DeepMind).** "LLMs Cannot Self-Correct Reasoning Yet." ICLR 2024 (arXiv:2310.01798).
> Score: 8.45 | Level 5 | Core.
> Intrinsic self-correction can DEGRADE reasoning; external feedback is the active ingredient.

> **Wang, X. et al. (Google Brain).** "Self-Consistency Improves Chain of Thought." ICLR 2023 (arXiv:2203.11171).
> Score: 8.45 | Level 5 | Core.
> The cheap, best-replicated reasoning win (GSM8K +17.9%) and the baseline debate must beat.

> **Zheng, L. et al. (LMSYS/Berkeley).** "Judging LLM-as-a-Judge." NeurIPS 2023 (arXiv:2306.05685). Score: 8.3 |
> Level 3 | Core.
> LLM judges reach >80% human agreement but carry position/verbosity/self-preference bias.

> **Wang, Q. et al.** "Rethinking the Bounds of LLM Reasoning: Are Multi-Agent Discussions the Key?" ACL 2024
> (arXiv:2402.18272). Score: 8.1 | Level 5 | Core.
> A strong single agent nearly matches the best discussion method — debate's gain is largely ensembling.

> **MaiNLP / tot-eval.** "Understanding When Tree of Thoughts Succeeds." arXiv:2410.17820. Score: 7.55 | Level 5
> | Supporting.
> ToT does not consistently beat CoT; gains come from scaling the generator, not the discriminator.

> **Anthropic Engineering.** "How we built our multi-agent research system." 2025. Score: 7.3 | Level 5 | Core.
> The vendor case FOR multi-agent on read/breadth tasks at ~15x cost; read-vs-write split. (Same underlying source
> as the T3 Anthropic card; cross-listed with a distinct bias-guard reaction.)

> **Du, Y. et al.** "Improving Factuality and Reasoning through Multiagent Debate." ICML 2024 (arXiv:2305.14325).
> Score: 7.3 | Level 5 | Supporting.
> Multiple instances debate to converge; DID report a majority-vote baseline (correcting the track's premise).

> **Madaan, A. et al.** "Self-Refine: Iterative Refinement with Self-Feedback." NeurIPS 2023 (arXiv:2303.17651).
> Score: 6.95 | Level 5 | Supporting.
> Self-critique-and-refine; gains concentrate on open-ended generation, weak on hard math.

> **Cognition AI (Walden Yan).** "Don't Build Multi-Agents." cognition.ai 2025. Score: 6.85 | Level 7 | Core.
> The anti-multi-agent argument; writes should stay single-threaded — converges with Anthropic on read-vs-write.

> **Hacker News community.** "Don't Build Multi-Agents discussion" (item 45096962). Score: 4.9 | Level 8 |
> Supporting.
> Practitioners converge: subagents help by isolating context for read/search, hurt for write/build.

**Excluded sources:** None. All 62 carded sources were retained as Core or Supporting; no source scored low enough
or was redundant enough to warrant exclusion. Several searched threads (triangulation/Denzin, grounded theory,
scoping reviews, standalone brainwriting) were not carded and therefore do not appear in the bibliography; they are
noted as gaps in §6 Limitations.
