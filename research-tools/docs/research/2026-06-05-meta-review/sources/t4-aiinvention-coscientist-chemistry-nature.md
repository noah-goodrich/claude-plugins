# Source: Coscientist — autonomous chemistry with LLMs (Boiko et al., Nature 2023)

**Full citation:** Boiko, D.A., MacKnight, R., Kline, B., Gomes, G. "Autonomous chemical research with
large language models." Nature 624, 570-578. December 2023. (PMC10733136)
**URL:** https://pmc.ncbi.nlm.nih.gov/articles/PMC10733136/ (also techxplore/CMU coverage)
**Date accessed:** 2026-06-06
**Evidence level:** 5 (Practitioner case study with data, in a top peer-reviewed venue — closest to
Level 3 of the track because of robotic execution and reproducible tasks, but it is a system demo)
**Research topic area:** AI invention & discovery systems — closed-loop autonomous chemistry / self-
driving lab with physical robotic execution

## Credibility Scores

| # | Dimension | Score | Justification |
|---|-----------|-------|---------------|
| 1 | Authority | 9 | Carnegie Mellon (Gomes lab); published in Nature; rigorous review. |
| 2 | Evidence Quality | 8 | Actual robotic experiments executed (Emerald Cloud Lab + Opentrons), six diverse tasks, real chemistry endpoints. |
| 3 | Currency | 7 | Dec 2023, on GPT-4 era; architecture still relevant but base models have moved on. |
| 4 | Intent | 8 | Academic; advances the field; modest commercial angle. |
| 5 | Bias & Objectivity | 7 | Honest about scope; includes a safety/dual-use discussion. |
| 6 | Logic & Coherence | 8 | Modular architecture maps cleanly to tasks; claims are bounded to what was run. |
| 7 | Corroboration | 8 | Coverage by Chemistry World, CMU, Synced; methodology reproducible from SI. |
| 8 | Intellectual Honesty | 8 | Explicitly discusses dual-use/safety risks and limits of autonomy. |
| 9 | Specificity | 9 | Named modules, named reactions (Suzuki, Sonogashira), measurable optimization outcomes. |
| 10 | Relevance | 9 | The canonical physical closed-loop (generate -> design -> execute -> measure) demonstration. |

**Composite score:** 8.15

## Bias Guard Check

- [ ] I agree with this source's conclusions → scored harder on dims 5, 6, 8
- [ ] I disagree with this source's conclusions → scored more generously on dims 5, 6, 8
- [x] Neutral / no strong reaction

## Key Findings

- Coscientist is a modular multi-LLM agent system (Planner/Web-searcher/Code-execution/Docs +
  Automation modules) that integrates internet search, documentation retrieval, code execution, and
  robotic experimentation APIs into one end-to-end pipeline.
- It autonomously planned and executed palladium-catalysed cross-couplings (Suzuki and Sonogashira),
  optimizing reaction conditions on physical robotic hardware — the field's clearest physical closed
  loop (hypothesis -> design -> execute -> measure -> learn).
- Demonstrated across six diverse tasks with minimal human intervention, executed partly on a real
  cloud robotic lab (Emerald Cloud Lab).
- The authors explicitly address dual-use / safety concerns of autonomous chemical agents — a notable
  honesty signal for an invention system that touches the physical world.

## Verified Quote(s)

**Location reference:** Abstract and "Suzuki and Sonogashira reactions" results section (Nature article /
PMC10733136). Quote drawn from the abstract as reproduced in PMC and corroborating CMU/techxplore
coverage; full-text fetch was intermittently blocked, see access status.

> Here we show the development and capabilities of Coscientist, an artificial intelligence system driven
> by GPT-4 that autonomously designs, plans and performs complex experiments by incorporating large
> language models empowered by tools.

> Coscientist showcases its potential for accelerating research across six diverse tasks [...] including
> the successful reaction optimization of palladium-catalysed cross-couplings.

**Access status:** cached/partial
(Abstract verified via PMC + multiple independent reproductions of the abstract text; full-text PMC
fetch returned ECONNREFUSED/redirect at access time, so deep-section quotes were not re-verified
in-place. The quoted abstract text is consistent across PMC, CMU, and Synced reproductions.)

## Inclusion Decision

**Decision:** Core
**Rationale:** The strongest *peer-reviewed* physical-world closed-loop demo in the track. Distinguishes
"computational hypothesis generation" from "actually runs the experiment on robots."

**Redundancy check:** Unique — the only source with robotic execution of real synthetic chemistry.

**Perspective category:** Academic
