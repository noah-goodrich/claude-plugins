# noah-writing-voice

Noah Goodrich's foundational writing skills. Enforces voice consistency and scores all written output for AI tells before delivery.

## Components

| Component | Type | Purpose |
|-----------|------|---------|
| noah-voice | Skill | Writing voice enforcement: tone, rhythm, metaphor structure, formatting rules |
| ai-scoring | Skill | 0-100 AI detection scoring with flagged passages and suggested rewrites |

## Skills

### noah-voice
Triggers on all writing tasks. Enforces Noah's conversational, metaphor-driven voice with hard rules (no em dashes, banned words, limited single-sentence paragraphs) and reference articles for calibration.

Includes reference files:
- `voice-rules.md` with detailed rules and good/bad examples
- Three of Noah's articles as voice calibration examples

### ai-scoring
Runs automatically before presenting any written content. Scores on 8 categories: staccato rhythm, parallel structure, generic transitions, hedging, repetitive openings, lists-as-prose, missing specifics, and banned words.

## Usage

These skills trigger automatically on writing tasks. No commands needed. Other plugins (noah-content-tools) depend on this plugin being installed.
