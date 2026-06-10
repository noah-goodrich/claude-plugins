# Source: STORM — Assisting in Writing Wikipedia-like Articles From Scratch with LLMs

**Full citation:** Shao, Yijia, et al. (Stanford OVAL). "Assisting in Writing Wikipedia-like Articles From
Scratch with Large Language Models." arXiv:2402.14207 (NAACL 2024). 2024.
**URL:** https://arxiv.org/html/2402.14207v1
**Date accessed:** 2026-06-06
**Evidence level:** 2 (Peer-reviewed conference paper with controlled human + automated evaluation on FreshWiki)
**Research topic area:** Architecture (multi-perspective question asking, outline-first) + verifiability limits

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 9/10 | Stanford OVAL; peer-reviewed at NAACL 2024; recognized academic lab. |
| 2 | Evidence Quality | 7/10 | Controlled FreshWiki eval + expert Wikipedia-editor study; new-task generation is hard to score perfectly. |
| 3 | Currency | 8/10 | Feb 2024; foundational method still actively used (>70k preview users), pre-dates 2025 commercial cohort. |
| 4 | Intent | 9/10 | Academic open-source research; system is free/open. |
| 5 | Bias & Objectivity | 9/10 | Explicit Limitations section; candid that source bias and verifiability are unsolved. |
| 6 | Logic & Coherence | 8/10 | Two-stage decomposition argument is clean and well-motivated. |
| 7 | Corroboration | 7/10 | Multi-perspective + outline-first approach echoed by later systems; FreshWiki widely reused. |
| 8 | Intellectual Honesty | 9/10 | States verifiability issues "go beyond factual hallucination" and names the red-herring failure. |
| 9 | Specificity | 8/10 | Named stages, FreshWiki (100 articles), concrete failure categories. |
| 10 | Relevance | 8/10 | Canonical open research-report-generation architecture; report-quality limits transfer to commercial DR. |

**Composite score:** 8.10

## Bias Guard Check

- [ ] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [x] Neutral / no strong reaction

## Key Findings

- STORM (Synthesis of Topic Outlines through Retrieval and Multi-perspective Question Asking) models the
  PRE-writing stage: discover perspectives by surveying similar articles, simulate writer-expert conversations
  grounded in web search, then build an outline before writing the full article.
- Architecture is a two-stage pipeline (pre-writing → writing), not an orchestrator-worker multi-agent system —
  a distinct, simpler-to-reason-about design point.
- Authors are explicit that verifiability problems "go beyond factual hallucination": red-herring fallacies and
  unverifiable connections between facts are a separate, harder class of error.
- Collected information "may still be biased towards dominant sources on the Internet and may contain
  promotional content" — the same source-quality failure mode found in commercial systems.
- Scope is limited to free-form text; no multimodal grounding.

## Verified Quote(s)

**Location reference:** Section 3.1 (perspective-guided question asking); Section 6 / Limitations section.

> "STORM discovers different perspectives by surveying existing articles from similar topics and uses these
> perspectives to control the question asking process."

> "The verifiability issues identified in this work go beyond factual hallucination... addressing such
> verifiability issues is more nuanced, surpassing basic fact-checking."

> "The collected information may still be biased towards dominant sources on the Internet and may contain
> promotional content."

**Access status:** live

## Inclusion Decision

**Decision:** Core
**Rationale:** Highest-evidence academic architecture source; its candid verifiability/source-bias limitations
corroborate DeepTRACE from the open-systems side, strengthening the cross-category triangulation.

**Redundancy check:** Unique outline-first / multi-perspective architecture; independent corroboration of
source-bias and verifiability limits.

**Perspective category:** Academic
