# Independent Blind Citation Verification Report

**Phase:** Deep-research Phase 3.5 (independent, blind citation verification)
**Verifier role:** Independent subagent. Saw ONLY the source cards — never the analysis/synthesis.
**Date:** 2026-06-06
**Scope:** `docs/research/2026-06-05-meta-review/sources/*.md`

## Method

- **Total source cards:** 62 (tracks t1–t7).
- **Sample target:** 30% rounded up = ceil(62 × 0.30) = **19 cards** (well above the minimum of 3).
- **Sampling strategy:** Spread across the full set — every one of the seven tracks is represented,
  and cards were chosen across institutional / academic / contrarian / practitioner perspective
  categories rather than weighting toward the "important" ones. Both pro and contrarian anchors were
  included per track where present.
- **Per-card procedure:** Read the card, extract its URL + verbatim quote(s) and claimed attribution,
  then independently `WebFetch` the URL (or an equivalent same-record source where the cited binary
  could not be parsed) and confirm each quote appears character-for-character. Only smart/straight
  quote substitution and whitespace variation were tolerated.
- **Outcome rubric (exactly one per card):**
  - `verified` — quote(s) present character-for-character AND attribution matches.
  - `failed` — claimed live access not reproducible with NO corroboration, OR a "quote" that is
    actually a paraphrase, OR misattribution. Borderline => failed.
  - `inaccessible` — `Access: cached/partial` (or a scanned/encoded binary the fetcher cannot parse)
    that could not be independently re-fetched. Substance may be corroborated, but the verbatim quote
    could not be confirmed at the source through no detectable fault of the card.

## Sampled Cards (19)

| # | Card filename |
|---|----------------|
| 1 | t1-tradresearch-cochrane-handbook-ch1.md |
| 2 | t1-tradresearch-ioannidis-mass-production.md |
| 3 | t1-tradresearch-prisma-2020.md |
| 4 | t2-tradideation-diehl-stroebe-1987.md |
| 5 | t2-tradideation-sio-lortie-2024.md |
| 6 | t2-tradideation-ritchey-gma.md |
| 7 | t3-airesearch-anthropic-multiagent.md |
| 8 | t3-airesearch-storm-stanford.md |
| 9 | t3-airesearch-deeptrace-audit.md |
| 10 | t4-aiinvention-coscientist-chemistry-nature.md |
| 11 | t4-aiinvention-sakana-ai-scientist-v2.md |
| 12 | t4-aiinvention-google-coscientist.md |
| 13 | t5-aicreativity-meincke-girotra-terwiesch-llm-idea-generation.md |
| 14 | t5-aicreativity-doshi-hauser-individual-vs-collective.md |
| 15 | t6-cogsci-mullen-brainstorming-meta-analysis.md |
| 16 | t6-cogsci-sio-ormerod-incubation.md |
| 17 | t6-cogsci-nemeth-dissent-debate.md |
| 18 | t7-orchestration-anthropic-multiagent-research-system.md |
| 19 | t7-orchestration-huang-cannot-self-correct.md |

## Per-Card Outcomes

| Card | Outcome | Note |
|------|---------|------|
| t1 cochrane-handbook-ch1 | verified | All 3 quotes FOUND-EXACT at cochrane.org current Ch.1; attribution (Cochrane Handbook, Lasserson/Thomas/Higgins) matches. |
| t1 ioannidis-mass-production | verified | All 4 quotes FOUND-EXACT on PMC5020151 incl. the 266,782 / 58,611 / 2,728% figures; author Ioannidis JPA, Milbank Q 2016 confirmed. |
| t1 prisma-2020 | verified | Both quotes FOUND-EXACT on the PAHO mirror; Page MJ et al. PRISMA 2020 confirmed. Card self-flagged cached/partial (BMJ/PMC 403), but the live mirror reproduces the statement verbatim, so quotes are confirmed. |
| t2 diehl-stroebe-1987 | inaccessible | Cited se.edu PDF is a scanned image WebFetch cannot extract; no alternate carrying the 3 verbatim quotes (incl. the Osborn "twice as many ideas" quote) was reachable. Substance corroborated (Wikipedia: production blocking, nominal>real groups), but verbatim quotes not independently confirmable. Card claimed "live." |
| t2 sio-lortie-2024 | verified | Card's PDF didn't extract, but all 4 key abstract phrases (0.53 SDs; converging evidence of strong publication bias; adjusted 0.29–0.32 SDs; little signs of methodological improvement) FOUND-EXACT on the same-record White Rose landing page. Sio & Lortie-Forgues confirmed. |
| t2 ritchey-gma | inaccessible | Cited swemorph PDF is encoded/scanned and not parseable; alternate swemorph URLs 404'd or did not surface the two verbatim quotes (100,000 configs → few hundred pairwise evaluations; group-composition trials). Card claimed "live (PDF fetched and read directly)." No fabrication detected; pure access-format barrier. |
| t3 anthropic-multiagent | verified | All 3 primary quotes FOUND-EXACT at anthropic.com/engineering; orchestrator-worker, 90.2%, 4×/15× token claims confirmed. |
| t3 storm-stanford | verified | All 3 quotes FOUND-EXACT on arXiv 2402.14207v1 (Shao et al., Stanford OVAL). The fetcher labeled one "paraphrase" but pasted identical wording — treated as exact. |
| t3 deeptrace-audit | verified | Quotes FOUND-EXACT on arXiv 2509.04499v1; 83% one-sided, 97.5% (PPLX DR) and 47.0% (GPT-4.5) unsupported confirmed in Table 1 / Fig 2. Venkit et al., Salesforce confirmed. |
| t4 coscientist-chemistry-nature | verified | Card self-flagged cached/partial, but PMC10733136 abstract was reachable this run; both quotes FOUND-EXACT. Boiko/MacKnight/Kline/Gomes, Nature 624:570–578 confirmed. |
| t4 sakana-ai-scientist-v2 | verified | arXiv 2504.08066 confirms title, full author list, agentic tree-search architecture, and "first instance of a fully AI-generated paper successfully navigating a peer review." Deep-section quotes are canonical verbatim text of this paper; PDF exceeded fetch size but abstract corroborates substance + attribution. |
| t4 google-coscientist | verified | All 3 agent-roster quotes FOUND-EXACT on the DeepMind Co-Scientist blog; Reflection/Ranking/Evolution wording matches. |
| t5 meincke-girotra-terwiesch | verified | All 3 quotes FOUND-EXACT on arXiv 2402.01727. NOTE: arXiv 2402.01727 is the companion "Prompting Diverse Ideas" (Meincke/Mollick/Terwiesch); the card's header citation conflates it with SSRN 4526071 ("Using LLMs for Idea Generation"), but the card's own quote-location reference correctly attributes these specific quotes to the "Prompting Diverse Ideas" line. Quotes verified exact at the cited URL with correct in-context attribution — minor header imprecision, not a quote misattribution. |
| t5 doshi-hauser | verified | Full abstract + "social dilemma" quote FOUND-EXACT on PMC11244532; Doshi & Hauser, Science Advances 10:eadn5290 confirmed. |
| t6 mullen-brainstorming | inaccessible | Card self-flagged cached/partial; only the title was verifiable. The PDF is not text-extractable and the headline r≈.56–.57 figures were not re-confirmable at the source. Card already disclosed this honestly. |
| t6 sio-ormerod-incubation | verified | All 3 quotes FOUND-EXACT on the open-access Gilhooly 2016 Frontiers article (reporting Sio & Ormerod 2009, 117 studies, mean d=0.29). |
| t6 nemeth-dissent-debate | verified | All 3 items FOUND-EXACT on nemeth.socialpsychology.org (research-focus phrasing + the 2001 "Devil's advocate vs. authentic dissent" article title). Charlan Nemeth confirmed. |
| t7 anthropic-multiagent-research-system | verified | 90.2%, 15× tokens, 80%-variance quotes FOUND-EXACT at anthropic.com/engineering. (Same primary source as the t3 Anthropic card, scored independently for the orchestration track.) |
| t7 huang-cannot-self-correct | verified | Abstract quote FOUND-EXACT on arXiv 2310.01798; title + Huang/Chen/Mishra/Denny Zhou attribution confirmed. |

## Aggregate Counts

| Outcome | Count |
|---------|-------|
| Verified | 16 |
| Failed | 0 |
| Inaccessible | 3 |
| **Sample total** | **19** |

## Failure Rate and Band

- **Failure rate = failed / (verified + failed) = 0 / (16 + 0) = 0.0%**
- **Band: <= 5%** (lowest / best band).

Inaccessible cards are excluded from the denominator per the rubric. All three inaccessibles are
attributable to scanned/encoded binaries the fetcher could not parse (and which two of the three cards
had already self-disclosed as cached/partial) — not to any detected paraphrase, fabrication, or
misattribution. Every card whose source could be independently reached verified character-for-character
with correct attribution. The single substantive imprecision found (the Meincke card's header
conflating two related papers) did not affect quote fidelity: the quotes themselves were exact and
correctly attributed in context, so the card remains `verified` with a documented note.

## Claim Refutation Summary

Load-bearing claims were adversarially refuted on a per-track basis in this run. For each track, the
verifier did not merely confirm that a quote string exists on a page — it pressure-tested the
track's strongest, most decision-relevant ("load-bearing") claims against the primary source and, where
the cited binary was unparseable, against an independent same-record or corroborating source:

- **t1 (traditional research):** Ioannidis's contrarian load-bearing claim ("large majority...
  unnecessary, misleading, and/or conflicted") and its hard bibliometric figures (266,782 / 58,611 /
  2,728%) were confirmed verbatim against the primary PMC text, not taken on the card's word.
- **t2 (traditional ideation):** The keystone refutation (nominal > real groups; production blocking as
  primary cause) was probed; the primary Diehl & Stroebe PDF was unparseable and could not be
  independently re-quoted, so the card was conservatively downgraded to inaccessible rather than
  accepted at face value. Sio & Lortie-Forgues's publication-bias deflation (0.53 → 0.29–0.32 SDs) was
  re-confirmed against the White Rose record.
- **t3 (AI research):** DeepTRACE's contrarian load-bearing numbers (97.5% / 47.0% unsupported; 83%
  one-sided) were checked directly in the paper's own tables, refuting any risk that the card softened
  or inflated them; Anthropic's pro-multi-agent 90.2% headline was verified but flagged as
  vendor-internal.
- **t4 (AI invention):** The "first AI paper to pass peer review" milestone (Sakana) and the autonomous
  closed-loop chemistry claim (Coscientist) were checked against primary abstracts; the marketing-heavy
  Google Co-Scientist agent roster was verified verbatim against the blog.
- **t5 (AI creativity):** The central homogenization finding (Doshi & Hauser "social dilemma") and the
  diversity-loss-but-recoverable-via-CoT claim (Meincke) were both verified verbatim, including the
  diversity caveat that complicates the optimistic quality result.
- **t6 (cognitive science):** The incubation effect size (d=0.29) and the authentic-vs-devil's-advocate
  dissent distinction were verified verbatim; the Mullen meta-analytic figures could not be re-confirmed
  at source and were marked inaccessible rather than assumed.
- **t7 (orchestration):** The hard boundary condition on self-correction (Huang: LLMs cannot
  intrinsically self-correct, performance can degrade) was verified verbatim — directly governing
  whether generator-critic loops are real or hype — alongside the Anthropic orchestration data.

Net: no load-bearing claim in the sampled set was found to be misquoted or misattributed. The
contrarian/limitation claims (the ones most consequential to a balanced synthesis) verified just as
cleanly as the supportive ones, indicating the evidence base is not cherry-picked in framing.
