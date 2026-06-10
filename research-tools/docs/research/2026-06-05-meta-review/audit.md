# Internal Audit: deep-research + brainstorm (right / wrong / ugly)

*Date: 2026-06-05 | Scope: `skills/deep-research/SKILL.md`, `skills/brainstorm/SKILL.md`, their references, and
the 21-artifact corpus they produced across borg-collective, ingle, reveal, and troth | Method: five independent
review lenses (pipeline rigor, corpus empirical, ergonomics/ADHD-fit, competitive gap, ugly-adversary), findings
merged and cross-checked against skill source and corpus files.*

This is the brutally honest workup. The headline: the methodology is genuinely excellent on paper and rare for
LLM-generated research — and its single most important control is defeated in every shipped deliverable we sampled.
The gap between the spec and the artifacts is the whole story.

---

## Executive summary

Ranked by impact. Each takeaway carries its load-bearing citation; full evidence is in the sections below.

1. **The flagship anti-fabrication control is not actually running.** Phase 3.5 mandates a *blind* re-read by a
   fresh subagent with no synthesis context (`deep-research/SKILL.md:192-201`). In every report we sampled it was
   self-verification by the card author: agent-teams admits it plainly
   (`borg-collective/.../2026-05-23-agent-teams/verification-report.md:31-35`), personalization admits it
   (`ingle/.../2026-05-25-personalization-mechanics/verification-report.md:11`), and reveal merely labels itself
   "independent" with no evidence of a fresh agent
   (`reveal/.../2026-05-31-portrait-pipeline/verification-report.md:2`). A verifier holding the source in context
   from its own fetches cannot catch a quote it paraphrased. This appeared in all five lenses; it is the single
   most important finding.

2. **The gates are honor-system and the corpus proves they leak.** The largest deliverable — troth, 65 cards, ~92KB
   — shipped with **zero** `Verified Quote` sections across all 65 cards, **no** `verification-report.md` on disk,
   and **no** failure-rate numbers in §6, yet wears the full §1–§7 template
   (`troth/docs/research/household-finance-research.md`; verified: 65 cards, 0 quote sections, no report). Every
   manifest checkbox (`deep-research/SKILL.md:375-399`) is self-attested; nothing reads the references or confirms a
   quote exists before the document is presented.

3. **The 5% failure gate is gameable, and the corpus contains a live instance of the game being played.** The reveal
   s11 card was scored `inaccessible` (excluded from the failure denominator) on the strength of a
   `cached/partial` flag the card never carried — the s11 card on disk has no `Access status:` field at all
   (`reveal/.../sources/s11-stable-diffusion-art.md:73`; the file ends with a freeform "Last Fetched / Assessment
   Confidence" line, not the canonical enum). Scored correctly as `failed`, the reveal rate is 25%, not 0%. The
   skill itself sanctions exactly this maneuver as remediation path #3 (`deep-research/SKILL.md:250-253`).

4. **The whole corpus is built on the bottom half of its own evidence ladder.** True primary experimental evidence
   (Level 1 meta-analysis + Level 2 RCT) is 9/65 (troth), 8/53 (personalization), 0/40 (eating-out), 0/16
   (agent-teams) per the §6 distribution tables. The only original ground-truth observation in the entire sampled
   corpus is a single n=1 informal test (`reveal/.../portrait-pipeline/analysis.md:124,547`). The skill names this
   as a limitation but does nothing to force a researcher out of the literature.

5. **The methodology is real where the agent chooses to honor it.** Where Phase 3.5 actually ran with discipline —
   agent-teams re-checking against original fetch output, eating-out using a seeded `random.sample` and catching a
   genuine misattribution (`ingle/.../eating-out-family-equipment/verification-report.md:11,46`) — it produced real,
   defensible verification. The bones are sound; the problem is enforcement, not design.

6. **We genuinely lead the field on a defensible triad — but it is currently 2-of-3 in practice.** On-disk scored
   source cards, a blind adversarial verification gate, and a vendor-neutral council are a combination no commercial
   tool (OpenAI/Gemini/Perplexity Deep Research, Elicit, Consensus, STORM, Google co-scientist) offers together. The
   moat is real in the spec; the "adversarial" leg is partly fictional in the artifacts because blind verification
   isn't being achieved.

7. **Ceremony is paid up-front and uniformly, so the skill performs a rigor it cannot sustain.** ~14k tokens of
   mandatory reference pre-load before a single search (`deep-research/SKILL.md:21-42`), a fixed per-source cost of
   10 justified scores (≈650 justifications on troth), and no lightweight tier mean tired agents route around the
   *expensive* gates (independent verification) while honoring the *cheap* ones (file manifest). The best artifact in
   the corpus got there by abandoning the ceremony and measuring instead.

---

## What we're doing RIGHT

These are genuine strengths worth protecting. Do not refactor them away.

**The pipeline architecture is methodologically correct.** PRISMA-style pre-registration of inclusion criteria
before searching (`deep-research/SKILL.md:60-65`) is the right defense against post-hoc rationalization. Anchored
scoring with an explicit "do not score intuitively" mandate (`source-evaluation-rubric.md`) plus per-source batch
evaluation to avoid cross-source anchoring (`deep-research/SKILL.md:176-178`) is sound. Phase 3.5's core insight —
that source cards are fabricable and need an adversary who re-reads the *source*, not the *analysis*
(`deep-research/SKILL.md:186-190`) — is exactly right. The fix below is enforcement, not redesign.

**When the verification gate actually runs independently, it works and catches real problems.** The eating-out
verifier used a seeded `random.sample` (`ingle/.../eating-out-family-equipment/verification-report.md:11`) and caught
a genuine misattribution — a "go easy on yourself" quote sourced to the wrong blog — then remediated and logged it
rather than burying it (`...:46`). The agent-teams self-verification, despite not being blind, re-checked against the
original `web_fetch` output and got genuine character-for-character matches
(`borg-collective/.../2026-05-23-agent-teams/verification-report.md:37-39`). The gate is not vaporware; it is
under-enforced.

**Structural and evidentiary discipline is genuinely rare for LLM-generated research.** All five sampled analyses
ship the §1–§7 structure with real on-disk source-card directories (8–65 cards each), bias-guard summaries,
evidence-level tables, and perspective-balance matrices. Source-count reconciliation is honest and exact where run
(16/16 agent-teams, 8/8 reveal). Every analysis distinguishes consensus vs. contested vs. gap zones and includes an
institutional-vs-ground-truth lens. These are deviations from a high bar, not the absence of one.

**The council and the answer-first output earn their cost in every artifact.** The two elements present, complete,
and useful in *every* deliverable are the council/Recommender verdict (`brainstorm/SKILL.md:254-296`) and the
front-loaded verb-led §1 Recommendations + "tired dad at 4am" §2 Summary (`deep-research/SKILL.md:326-329`). These
are cheap relative to their value and are exactly the right ADHD-aware design instinct: put the answer first, make it
scannable. They are the load-bearing core that must survive any future "rapid" tier.

**The reveal portrait brainstorm is the model the rest should follow.** Every option was tested in-environment on the
real photo, not web-searched: 21 live Claude calls, MAE measured to 3.32/255, scripts committed
(`reveal/.../2026-06-05-family-photo-print-resolution.md:20,48`). Critically, its verification found something real
and uncomfortable — the shipped file used a different path than the prototype and had to be independently re-measured
(`...:95-98`), and it caught a genuine defect ("PNG carries no DPI tag"). This is what Phase 3.5 is *supposed* to do:
surface that the deliverable diverged from what the research claimed. It got there by *abbreviating* the council
(`...:69`, "Council Review (abbreviated)") and dropping the depth-tagging ceremony — proof the value is in the
thinking, not the protocol.

---

## What we're doing WRONG

Substantive methodological and process defects. These are real-but-fixable contract violations.

**Phase 3.5 "blind verification" is not blind — self-verification by the card author in every sampled report.** This
is the single highest-stakes leak and it surfaced in all five lenses, so it is reported once here as the merged
finding. `deep-research/SKILL.md:192-201` mandates a fresh Task-tool agent with no shared context and explicitly
forbids giving it the analysis. In practice: agent-teams states "this verification was performed as self-verification
by the same agent that authored the cards" and re-checked quotes "already in its context"
(`borg-collective/.../2026-05-23-agent-teams/verification-report.md:31-35`); personalization repeats the identical
limitation (`ingle/.../2026-05-25-personalization-mechanics/verification-report.md:11`); reveal labels itself
"Phase 3.5 independent verification" with zero mention of a fresh/blind subagent
(`reveal/.../2026-05-31-portrait-pipeline/verification-report.md:2`). The adversarial property the gate depends on is
destroyed: a verifier cannot detect a quote it itself paraphrased. *Fix:* make blindness machine-checkable — require
the report to record a verifier session/agent ID distinct from the synthesis agent, and HARD-BLOCK with a
"verification-deferred — do not treat as fact-checked" stamp when Task-tool spawning is unavailable, instead of
silently downgrading to self-verification.

**The Phase 3.5 gate is bypassed entirely in at least one shipped deliverable.** `deep-research/SKILL.md:396-399`
makes the verification report a hard manifest item. The troth deliverable (65 source cards, the largest in the
corpus) has **no** `verification-report.md` on disk (directory contains only the analysis, `sources/`, `drafts/`,
and an unrelated subdir; confirmed), and its §6 reports a bias-guard summary with zero verification numbers. Per the
skill's own rule (`deep-research/SKILL.md:259-266`), a methodology that omits the three numbers has not satisfied the
gate "even if the verification report file exists" — here the file does not even exist. The gate is structurally
unenforced; nothing stops a synthesis agent from declaring done. *Fix:* an executable post-check that fails the
deliverable if `verification-report.md` is absent or §6 lacks sample-size/failure-rate numbers; backfill troth before
its research justifies product decisions.

**Verification "independence" is violated and the failure-rate band is reported in non-compliant formats and
under-sampled.** Personalization openly states verification was by the same agent
(`...:11`), reports the band as "≤20% partial-or-failed at sample size 5" — *not* one of the three legal bands
(`≤5%` / `>5%–10%` / `>10%`, `deep-research/SKILL.md:238`) and 4× the ship threshold — yet shipped anyway, and
sampled only 5/53 ≈ 9% when the skill mandates 30% rounded up, i.e. 16 cards (`deep-research/SKILL.md:204-207`). It
also explicitly sampled "cards backing the highest-leverage claims," the exact weighting the skill forbids because
important sources are the ones most worth fabricating (`...:206-207`). *Fix:* a band/threshold assertion in a
validator that hard-fails a non-canonical band string or a sample below 30%.

**The 5% failure gate is gameable by reclassifying failed cards as inaccessible — and the reveal report did exactly
this.** Inaccessible cards are excluded from the denominator (`deep-research/SKILL.md:235-237`). The reveal s11 card
carries **no** `Access status:` enum at all (`reveal/.../sources/s11-stable-diffusion-art.md:73`); the verification
report nonetheless claims "Card flagged as `cached/partial`" — false — and scores it `inaccessible`
(`reveal/.../verification-report.md:20`), holding the rate at 0/3 = 0%. Scored correctly as `failed`, it is 1/4 =
25%, which blows the gate. The skill blesses the maneuver as remediation path #3
(`deep-research/SKILL.md:250-253`). *Fix:* a card may be `cached/partial` only if that flag existed at synthesis time
(verifiable from git history/mtime), never set retroactively; cap inaccessible exclusions (e.g., >30% → deliverable
is "low-confidence," not "passed"); treat a card lacking the canonical enum as `failed`.

**Source-card template compliance is unverified — non-canonical Access fields and quote headings ship.** The template
defines `Access status:` as exactly one of `live`/`cached/partial`/`inaccessible`
(`source-card-template.md:65-72`) and mandates the `## Verified Quote(s)` heading (`...:45`). In reveal, only 4 of 8
cards carry any `Access status:` field (confirmed), and s11 substitutes a freeform "Last Fetched / Assessment
Confidence 75%" line (`s11...:73`) plus a singular `## Verified Quote` heading (`s11...:41`). The missing enum is not
cosmetic — it is load-bearing for the failure-rate denominator and is exactly what let the s11 mis-classification
slip through. *Fix:* a linter asserting every card has the literal `Access status:` enum line and the literal
`## Verified Quote(s)` heading; fail the manifest on any deviation.

**Source-count reconciliation and template conformance break down at small scale.** The portrait analysis has 8 cards
on disk, evaluates 8, then appends a "Search Sources (External References, Not Directly Evaluated)" block naming
Anthropic's vision policy and arXiv papers as load-bearing context that was never carded
(`reveal/.../portrait-pipeline/analysis.md:605-611`) — including the very "Claude vision safety policy" that drives
Research Question 5. Its §6 also uses bespoke perspective categories ("Technical Documentation / Commercial Product
Analysis / Regulatory") that are not the five enum values the template mandates (`source-card-template.md:83-87`). It
is the smallest corpus yet the loosest on conformance — exactly the "feels small, skip the structure" failure mode
the skill warns against (`deep-research/SKILL.md:22-26`). *Fix:* enforce the perspective enum at card-write time;
require any source named in a recommendation or research-question framing to be carded.

**The mandatory 14k-token reference pre-load is a wall, not an on-ramp.** Before Phase 1, the skill demands all seven
references loaded with a checkbox list and anti-skip language (`deep-research/SKILL.md:19-42`; ≈10,586 words across 7
refs + SKILL.md). A 4-source product question and a 65-source clinical synthesis pay the identical entry tax. For the
project's stated ADHD user model, the undifferentiated up-front load is the activation-energy spike that kills task
initiation — the skill is most off-putting at the moment of least commitment. *Fix:* lazy, proportional loading —
carry card fields and the §1–§7 skeleton inline; load each reference at the phase that consumes it (the Quick
Reference table at `deep-research/SKILL.md:423-434` already maps this).

**No lightweight mode and no honest escape valve under time pressure.** deep-research has exactly one off-ramp
("return to the relevant phase and fix the gap," `:401-405`) and 23 MUST/Gate/non-negotiable instances across 433
lines; brainstorm's only graceful-degradation clause is "No project context?" (`brainstorm/SKILL.md:44`), which
addresses missing inputs, not a 30-minute budget. An all-or-nothing protocol under pressure does not produce a
smaller *compliant* artifact — it produces a quietly non-compliant one (troth: 65 cards, no verification) or a
non-start. *Fix:* a documented "rapid" tier with HONEST reduced guarantees and a self-acknowledged "not independently
verified" stamp, so the artifact wears its rigor level on its face.

**brainstorm re-implements a parallel mini-pipeline that diverges from the real one.** The two skills are sold as a
clean split, but brainstorm's lightweight tracks run a second, lower-rigor research process whose findings are
free-form ("Source: [title, URL, access date]," `brainstorm/SKILL.md:146-155`) — no cards, no scoring — so a single
brainstorm carries two incompatible evidentiary standards side by side, with council prose treating verified and
unverified claims as equally settled. The genuinely good novelty-probe early-termination
(`brainstorm/SKILL.md:160-176`) is a research-governance control living in the wrong skill: deep-research itself has
no "should I even run this?" gate, so a direct `/deep-research` always runs the full heavy pipeline. *Fix:* promote
the novelty probe into deep-research Phase 1; unify the brainstorm-track finding shape with deep-research's minimal
source record; document the redundancy in the README.

**No web-scale corpus.** Discovery rides the host's general WebSearch/WebFetch (`deep-research/SKILL.md:79-103`),
bounded to hundreds of consumer-web results, while Elicit indexes 138M+ papers and Consensus runs quality-filtered
academic search. The paywall-surfacing protocol (`deep-research/SKILL.md:104-130`) is an honest admission of this
limit — we ask the human to buy what we cannot reach. *Fix:* do not try to out-index Elicit; add an optional MCP
adapter for a free scholarly source (Semantic Scholar, 200M+ papers) so Phase 2 can pull abstracts into the same card
pipeline — academic reach plus inspectable cards.

---

## What's just plain UGLY

Over-engineering, ceremony, performative rigor, and self-deception — places where the apparatus produces a green
checkmark or a confident verdict by construction rather than by earning it.

**The Phase 3.5 gate has never failed — it is self-certification, not adversarial verification.** Across the sampled
corpus every verification report reports a 0% (or 0/5) failure rate. The reason is structural: the "independent blind
subagent" requirement is universally violated (above), AND failures get "corrected before final tally" instead of
counted. The troth/categorizer report shows the mechanism in miniature — cards that *did* contain a paraphrase or an
extra word ("Quote 2 had one extra word," "Quote 2 was a synthesized paraphrase") were repaired and then counted as
verified (`troth/workers/categorizer/docs/research/2026-05-29/verification-report.md:15-17`). A gate where the
verifier silently fixes what it finds and then reports zero failures is a ritual that launders the synthesis agent's
own output into a "verified" stamp; the failure-rate math can only ever be 0 if you repair-then-recount. *Fix:* forbid
correct-then-recount — a card that needed correction during verification counts as a FAILURE for rate purposes; track
and surface a "gate-never-fired" metric (a control that has never tripped across 7+ runs is either unnecessary or
broken).

**The verbatim-quote gate caught nothing — reveal s11 ships an unverifiable, misattributed quote with a passing
grade.** The s11 card presents a "Verified Quote" under a Cloudflare-blocked URL (never verified live, by the card's
own admission) and attributes it to "Lavivienpost.net / Stable Diffusion Art ecosystem documentation" — a *different*
domain than the card's URL, stable-diffusion-art.com (`reveal/.../sources/s11-stable-diffusion-art.md:41-44`). This is
precisely the URL-resolves-to-unrelated-page + misattribution scenario Phase 3.5 exists to catch
(`deep-research/SKILL.md:186-190`). It passed, because the agent that wrote the bad card also graded it. *Fix:* a
quote attributed to a domain other than the card URL is automatic `failed` regardless of access status; a blocked card
whose quote could not be fetched live gets its supported claim marked "unverified-source" and down-ranked, not passed.

**The 5-persona council produces scripted consensus, not dissent — and the Pragmatist pre-decides every review.**
Across the brainstorm corpus the council never splits on the actual decision. In troth account-earmarking all five
personas independently name Option A, the cheapest (~40-line) option
(`troth/.../2026-05-29-account-earmarking-disposable-income.md:137-154`). The onboarding brainstorm is honest that its
four "options" are sequential phases, not competing alternatives (`ingle/.../2026-05-29-onboarding-ux.md:147`), so the
council is ordering a backlog, not choosing bets. The structural cause is in the skill: the Pragmatist is hard-wired
to ask "80% of value for 20% of work" (`brainstorm/SKILL.md:283-288`) and every option carries an Estimate field
(`:220-221`), so the lowest-estimate option enters council pre-blessed and the User Advocate never wins against the
effort argument. A council that always ratifies the cheapest option is a cost-estimator with four extra paragraphs of
prose. *Fix:* require at least one persona to formally DISAGREE with the Recommender (logged as a risk) or to kill an
option for a reason other than effort/feasibility; add a non-empty "Dissent" field to the output template.

**Bias-guard summaries honestly expose a confirmation skew the methodology cannot correct.** To the skill's credit
the summary surfaces the asymmetry instead of hiding it (`deep-research/SKILL.md:363-369`) — but the numbers are
heavily and consistently skewed toward agreement: agent-teams 10:2 (`...agent-teams/analysis.md:489-495`), eating-out
27:3, personalization 26:12 (down from a prior 16:1, `...personalization/verification-report.md:113-121`), troth
19:8. Eating-out names the mechanism itself: "the questions extend an already-believed framework rather than testing
it." The only correction is per-dimension score-hardening on dims 5/6/8, which cannot fix a corpus selected to confirm
a thesis — especially when each project starts from a "carry-forward" of the previous one's conclusions
(`personalization/analysis.md:100-104`), so priors compound across the corpus. Because the same agent both scores the
source AND decides whether it "agreed," the guard is self-graded confirmation bias with a paper trail. *Fix:* treat a
>3:1 agree:disagree ratio as a gate, not a footnote — require a falsification query in the Phase 2 search plan and a
mandatory "steel-man the contrarian" subsection in Phase 4; have the (actually blind) verifier independently judge
whether a sampled card's agree/disagree classification was honest.

**The §1–§7 manifest reliably produces 650–1350-line documents for decisions that resolve to ~40 lines of code.**
eating-out is 691 lines to conclude the feature needs an "editorial-default selector"; troth household-finance is
1350+ lines; the account-earmarking brainstorm runs a full council to land on "a role column and a $X/day subtitle,"
self-described as "~40 lines across 3 files" (`troth/.../account-earmarking...:56,154`). The manifest enforces
completeness, not proportionality — and for an ADHD-typed solo developer a 700-line read to extract a 40-line change
is the exact cognitive-load anti-pattern the borg project elsewhere fights. *Fix:* a stakes gate at Phase 1 —
"lightweight" caps the deliverable at §1 + §2 + §5 + a short methodology note; the full manifest fires only for
high-stakes/external-publication runs. Tie document size to the size of the decision it informs.

**The 10-dimension weighted rubric implies a precision a single LLM scoring prose cannot deliver, and never rejects
anything.** Composite scores to two decimals (7.95, 6.85) are false precision; the tell is that across agent-teams 16
of 16 sources were INCLUDED and 0 excluded, every score landing in a comfortable 5.5–8.65 band
(`borg-collective/.../agent-teams/analysis.md:513-516`). A rubric whose elaborate arithmetic never once produces a
"throw it out" is decorative — the inclusion decision is made on vibes and the score is back-filled to justify it.
*Fix:* replace the 2-decimal composite with a 3-bucket band (keep / borderline / reject); require every run to either
exclude at least one source or explicitly name the lowest-scoring source that cleared the bar.

**brainstorm's evidence-backed track machinery is dead weight — never exercised once.** Phases 2–3 spend ~85
lines on evidence-backed tracks, a 3-query novelty probe, recency bands, early-termination, and a recursive
`/deep-research` invocation (`brainstorm/SKILL.md:98-183`). Across all four brainstorms every track was tagged
`lightweight` and zero
invoked deep-research; the one "evidence-backed" track is "reused: 2026-05-23"
(`troth/.../account-earmarking...:37`), i.e. it reuses prior research rather than running fresh. The most elaborate
sub-system in the skill has a 0% utilization rate and taxes every read. *Fix:* demote it to a one-line escape hatch
("if a track's correctness is load-bearing and your model knowledge is stale, run `/deep-research` separately and feed
its §1–§2 back in") and delete the inline novelty-probe/recency apparatus from brainstorm; let deep-research own
evidence rigor and brainstorm stay fast.

**Brainstorm councils render confident product verdicts on near-zero fresh evidence.** The behavioral/UX claims the
councils adjudicate — onboarding abandonment, witching-hour decision load, spouse rage-quit risk — are precisely the
kind the skill's own classifier says are "likely confidently wrong" from model knowledge
(`brainstorm/SKILL.md:100-101`), yet the evidence-backed escalation that exists for them almost never fires. The
result is confident-sounding recommendations resting on the same thin secondary-evidence base as the deep-research
corpus, now one layer further removed. *Fix:* if zero tracks are evidence-backed AND the problem involves
behavioral/psychological/clinical claims, require the Phase 2 checkpoint to justify the all-lightweight decision to
the user, and surface each track's evidence depth in the final council so the reader sees the verdict rests on
lightweight search.

---

## The systematic weakness

Two cross-cutting patterns connect nearly every finding above. They are reported here as the unifying diagnosis.

### Pattern 1 — Thin primary evidence: a literature-and-blog machine, not an observation machine

The corpus is built almost entirely on secondary and tertiary evidence — published literature, vendor blogs, and
practitioner essays — with near-zero direct observation or experiment. Quantified from the §6 evidence-level
distribution tables, true primary experimental evidence (Level 1 meta-analysis + Level 2 RCT) is: troth 9/65 (14%),
personalization 8/53 (15%), eating-out 0/40 (0%), agent-teams 0/16 (0%). The mass sits at Level 3 (observational),
Level 5 (practitioner case study), Level 6 (qualitative), and especially Level 7 (expert opinion) — agent-teams alone
has 9 of 16 cards at Level 7. Even the high-scoring "case study WITH DATA" cards are vendor self-reports: the
top-scored agent-teams card (Anthropic's own multi-agent post, composite 7.95) is Anthropic's engineering blog
reporting its own un-replicated internal evals, with Evidence Quality scored 7/10 on the justification "Not
peer-reviewed, no external replication"
(`borg-collective/.../agent-teams/sources/T1-architecture-anthropic-multi-agent-research.md:12-16`). The single
instance of original ground-truth in the entire sampled corpus is the n=1 "Serena Williams oil-painting" Gemini run in
the portrait analysis, which the doc itself leans on as "ground truth" while admitting it is "single prompt, single
subject" (`reveal/.../portrait-pipeline/analysis.md:124,547`). The corpus consistently sources from the bottom half of
its own quality ladder while presenting composite scores in the 6.0–9.6 range that read as high-confidence. And the
portrait analysis proves the value of breaking the pattern: its one n=1 test reframed the entire recommendation away
from the published-consensus default. *Fix:* a Phase 2 "evidence-floor" gate — for any question cheaply testable
(UX flows, prompt behavior, API output, the household's own data), require at least one direct-observation artifact
before synthesis, or force a "No primary evidence collected — all findings are literature-derived predictions" banner
in §2.

### Pattern 2 — Honor-system enforcement: the design cannot tell honored from skipped

Every gate that matters is self-attested, so under load agents honor the cheap gates (the file manifest) and route
around the expensive ones (independent verification). The evidence is the inverse correlation between a gate's cost
and its observed compliance: the cheap §1–§7 structure is present in 5/5 analyses; the expensive blind-verification
requirement is honored in 0/5; troth skipped verification entirely under the load of 65 cards. Nothing downstream
reads the references, confirms a quote exists, confirms a verification report was produced, or confirms the verifier
was a distinct agent — every manifest checkbox is the synthesis agent grading itself. This pattern *is* the mechanism
behind findings 1–3 in the executive summary, the never-failing gate, the scripted council, and the unverified
template conformance. The single highest-leverage fix in this entire audit is to convert the prose manifest
(`deep-research/SKILL.md:375-399`) into an executable post-check (a hook or `deep-research --verify` script) that
fails the deliverable if: any card lacks a `## Verified Quote(s)` section, any card lacks the canonical
`Access status:` enum, no `verification-report.md` exists, §6 omits the sample-size/failure-rate numbers, the
verifier's agent ID matches the synthesis agent's, the failure-rate band is non-canonical, or the verification sample
is below 30%. Honor-system checklists inside a prompt do not survive contact with a busy agent — the corpus proves it.

### Resolving the lens contradiction on the reveal verification pass

Two lenses disagreed about reveal. The corpus-empirical lens credited it as the rare compliant run ("50% sample,
honestly flagged the 403 inaccessible"); the pipeline-rigor and ugly-adversary lenses called its "independent" label
unearned and caught it mis-applying the cached/partial flag to s11. Both are correct on different axes, and the
resolution is: reveal is the **best-executed verification in the corpus on the dimensions it honored** (it sampled at
a compliant 50%, it honestly flagged the genuine HTTP 403 on the arXiv/SD-art source) and **still failed on the two
that matter most** (it was not demonstrably blind — the cards and report were authored the same session with no
fresh-agent evidence at `verification-report.md:2`, and it retroactively asserted a `cached/partial` flag that the
s11 card never carried in order to score a failure as inaccessible). The lesson is not that reveal is good or bad; it
is that even the *most disciplined* verification pass in the corpus could not be both blind and honestly-gated under
honor-system enforcement. That strengthens, rather than complicates, the systematic finding.

---

## Where we genuinely lead the field

From the competitive lens, benchmarked against OpenAI/Gemini/Perplexity Deep Research, Stanford STORM, Elicit,
Consensus, Google AI co-scientist, and AutoTRIZ.

**On-disk scored source cards are a defensible moat no commercial tool offers.** Every commercial Deep Research
product emits a prose report with inline citations but no inspectable per-source artifact you can audit, diff, or
reuse; Elicit's extraction table lives in a SaaS account, not as forkable markdown in your repo. Our Phase 3 gate
forces one card per source with a 10-dimension weighted rubric and a justification per score
(`deep-research/SKILL.md:136-155`; `source-card-template.md:17-32`), reconciling exactly against methodology counts
(53 cards in `ingle/.../personalization-mechanics/sources/`). A black-box tool structurally cannot replicate
portable, git-tracked, human-auditable evidence that survives the vendor.

**Blind adversarial citation verification with a hard failure gate is ahead of the entire field — on paper.**
Commercial deep-research tools self-cite (the same model that wrote the claim attaches the link); DeepTRACE-style
audits show they routinely mis-cite. STORM grounds against snippets but does no adversarial re-check; Elicit's ~81%
extraction accuracy is a self-assessment; Google co-scientist's Reflection agent reviews hypotheses, not citation
fidelity. Our Phase 3.5 mandates a fresh agent given only the cards, matching character-for-character, borderline →
failed, hard >5% gate (`deep-research/SKILL.md:182-257`), paired with an adversarial council on the design side
(`brainstorm/SKILL.md:254-296`). No single competitor bundles adversarial layers on both evidence and design.
**Caveat, stated plainly:** this is the leg of the moat that is partly fictional in execution — see the systematic
weakness. A competitor could fairly call the current artifacts verification theater. The differentiator is real in
the spec; protecting it means making it fail-closed.

**Vendor-neutral, portable, runs-anywhere — a structural advantage commercial tools cannot copy.** OpenAI/Gemini/
Perplexity lock you to a model and subscription; Elicit/Consensus to a SaaS corpus; STORM to Stanford-hosted
GPT-4+Bing. Our pipeline is markdown + prompts grounded in six published frameworks (`README.md` Prior Art), runs on
whatever model the harness provides, writes to the user's own repo, and degrades gracefully with zero project context
(`brainstorm/SKILL.md:44`). The methodology outlives any single vendor's model deprecation. Combined with on-disk
cards and (once-fixed) blind verification, this is the third leg of a genuinely defensible triad: inspectable,
adversarial, AND portable.

**Where we are behind (so we do not overclaim):** no web-scale corpus (we ride consumer WebSearch vs. Elicit's
138M papers); no closed-loop experimentation or hypothesis tournament (Google co-scientist runs
generate→debate→rank→evolve, lab-confirmed in Nature — our council is one-shot, `brainstorm/SKILL.md:256`); no
invention/contradiction primitive
(AutoTRIZ maps a contradiction to inventive principles to synthesize *new* options — brainstorm even flags constraint
tensions at `:61` and then trades them off instead of resolving them). The reveal portrait brainstorm is the lone
counterexample that closed the empirical loop — by hand, because the skill never asks for it.

---

## Recommendations

Ranked by impact. Each is tied to the finding(s) it resolves.

1. **Convert the prose manifest into an executable post-check.** [Resolves the systematic honor-system weakness, the
   troth bypass, the never-failing gate, and unverified template conformance.] Ship a hook or `deep-research --verify`
   script that fails the deliverable if any card lacks `## Verified Quote(s)`, any card lacks the canonical
   `Access status:` enum, `verification-report.md` is absent, §6 omits sample-size/failure-rate, the failure-rate band
   is non-canonical, or the verification sample is <30% (`deep-research/SKILL.md:375-399`). This single change does
   more than any prose edit.

2. **Make blind verification machine-checkable and fail-closed.** [Resolves the highest-stakes finding — non-blind
   verification in 3/3 reports.] Require the report to record a verifier agent/session ID distinct from the synthesis
   agent; the validator rejects a matching ID. If Task-tool spawning is unavailable, the skill HARD-BLOCKS and stamps
   the deliverable "UNVERIFIED — self-check only" in §6 and the manifest, never printing "Gate result: PASS"
   (`deep-research/SKILL.md:192-201`).

3. **Close the inaccessible-reclassification loophole.** [Resolves the gameable 5% gate and the reveal s11 instance.]
   A card may be `cached/partial` only if that flag existed at synthesis time (verifiable from git/mtime), never set
   retroactively; treat a card lacking the canonical enum as `failed`; treat a quote attributed to a domain other than
   the card URL as automatic `failed`; cap inaccessible exclusions at ~30% before downgrading to "low-confidence"
   (`deep-research/SKILL.md:235-237,250-253`; `reveal/.../sources/s11-stable-diffusion-art.md:41,73`).

4. **Add a Phase 2 evidence-floor gate.** [Resolves thin-primary-evidence.] For any cheaply testable question,
   require ≥1 direct-observation artifact before synthesis, or force a "No primary evidence collected" banner in §2.
   Codify the reveal portrait pattern — where a claim is testable in-environment, the pipeline PREFERS measurement
   over source-scoring and commits the harness that produced the numbers
   (`reveal/.../2026-06-05-family-photo-print-resolution.md:48`).

5. **Treat confirmation skew as a gate, not a footnote.** [Resolves the asymmetric bias guard.] A >3:1 agree:disagree
   ratio requires a falsification query in the Phase 2 plan and a mandatory "steel-man the contrarian" subsection;
   once blind, the verifier independently judges the honesty of a sampled card's agree/disagree label
   (`deep-research/SKILL.md:166-170,363-369`).

6. **Introduce a triage tier and a documented rapid mode in both skills.** [Resolves the fixed per-source cost, the
   14k-token wall, and all-or-nothing.] Apply a fast keep/cut screen to all discovered sources first, full 10-dim
   cards only to those that pass; move the inclusion cut before the expensive scoring. Add a "rapid" tier with HONEST
   reduced guarantees and a "not independently verified" stamp. Load references lazily at the phase that consumes them
   (`deep-research/SKILL.md:21-42,164,270`).

7. **Force council dissent.** [Resolves scripted consensus.] Require ≥1 persona to formally disagree with the
   Recommender (logged as a risk) or to kill an option for a non-effort reason; add a non-empty "Dissent" field to the
   output template (`brainstorm/SKILL.md:283-296`).

8. **De-duplicate the two skills.** [Resolves the parallel mini-pipeline.] Promote the novelty probe into
   deep-research Phase 1 as a universal "is this worth a full run?" gate; unify brainstorm-track findings with
   deep-research's minimal source record; demote brainstorm's evidence-backed apparatus to a one-line escape hatch;
   document the redundancy in the README (`brainstorm/SKILL.md:98-183`).

9. **Replace the 2-decimal composite with a 3-bucket band and require a real cut.** [Resolves false precision and
   the never-rejecting rubric.] Keep / borderline / reject; every run must exclude ≥1 source or name the lowest that
   cleared the bar (`source-evaluation-rubric.md`; `borg-collective/.../agent-teams/analysis.md:513-516`).

10. **Add an optional scholarly-source MCP adapter, and state the boundary honestly in the README.** [Resolves the
    no-web-scale-corpus gap without an unwinnable indexing war.] Wire Semantic Scholar (free, 200M+ papers) into
    Phase 2 so abstracts and open-access PDFs flow into the same card pipeline; document that we are not Elicit-scale
    (`deep-research/SKILL.md:79-103,104-130`).

11. **Add an optional brainstorm Phase 4.5 empirical probe and a lightweight inventive-principles step.** [Resolves
    the no-closed-loop and no-invention competitive gaps.] For options with a cheap real-world test, spawn an agent to
    run it and feed the result into the council (as reveal did by hand); when Phase 1 flags constraints in genuine
    tension, route them through an inventive-principles prompt to force at least one option that *resolves* rather than
    trades off the contradiction (`brainstorm/SKILL.md:61,187-296`).

12. **Lean into the moat in positioning — after fixing #2.** [Protects the competitive edge.] State once in the
    README: "The only research+ideation pipeline that is inspectable (scored cards on disk), adversarial (blind
    verification + council), and portable (vendor-neutral markdown)." The triad is the whole moat; make the
    adversarial leg true so the claim holds (`README.md`; `deep-research/SKILL.md:182-257`).

---

*Bottom line: the intellectual content of these skills is already strong enough to defend mechanically. Invest the
next iteration almost entirely in enforcement — an executable manifest, a runtime-detected blind verifier, fail-closed
ship semantics, and an evidence floor. Keep the methodology verbatim; make the design unable to lie about whether it
was honored.*
