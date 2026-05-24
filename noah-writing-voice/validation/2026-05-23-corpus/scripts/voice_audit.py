#!/usr/bin/env python3
"""Voice-rule audit: quantify how each noah-voice rule holds across the Medium corpus.

Outputs a TSV-ish summary and per-article breakdown to stdout, plus prints
JSON for machine consumption.

Usage:
    python3 voice_audit.py <corpus_dir>
"""
from __future__ import annotations
import json
import os
import re
import sys
from pathlib import Path
from statistics import mean, median

BANNED_WORDS = [
    "genuinely",
    "straightforward",
    "honestly",
    "to be honest",
    "navigate",
    "landscape",
    "leverage",
    "delve",
]

# AI-tell transitions per voice-rules.md
AI_TRANSITIONS = [
    "here's the thing",
    "let's dive in",
    "that said",
    "but that's not all",
    "in conclusion",
    "moreover",
    "furthermore",
    "it's worth noting",
    "it is worth noting",
    "diving in",
]

CONTRACTIONS_RE = re.compile(
    r"\b(?:I'm|you're|he's|she's|it's|we're|they're|I've|you've|we've|they've|"
    r"isn't|aren't|wasn't|weren't|don't|doesn't|didn't|won't|wouldn't|can't|"
    r"couldn't|shouldn't|haven't|hasn't|hadn't|I'd|you'd|he'd|she'd|we'd|they'd|"
    r"I'll|you'll|he'll|she'll|we'll|they'll|that's|there's|here's|what's|let's|"
    r"who's|how's|wasn't)\b",
    re.IGNORECASE,
)

FRONTMATTER_RE = re.compile(r"^---\n.*?\n---\n", re.DOTALL)


def strip_frontmatter(text: str) -> str:
    return FRONTMATTER_RE.sub("", text, count=1)


def strip_code_blocks(text: str) -> str:
    return re.sub(r"```.*?```", "", text, flags=re.DOTALL)


def extract_body(text: str) -> str:
    """Body = everything after frontmatter, with code blocks removed (so we
    don't count tokens inside code samples)."""
    return strip_code_blocks(strip_frontmatter(text))


def split_paragraphs(body: str) -> list[str]:
    paras = []
    for raw in re.split(r"\n\s*\n", body):
        p = raw.strip()
        # skip headings
        if not p or p.startswith("#"):
            continue
        # skip pure image markdown
        if p.startswith("!["):
            continue
        # skip pure blockquote lines that are just captions if needed - keep them
        paras.append(p)
    return paras


def is_single_sentence_para(para: str) -> bool:
    """Heuristic: count sentence-terminator marks (.,!,?) inside the para; if 1 (or 0 with words), single."""
    # strip leading list/blockquote markers
    cleaned = re.sub(r"^[>\-\*\d+\.]+\s*", "", para).strip()
    # don't count if it's a list line
    if cleaned.startswith(("- ", "* ")):
        return False
    # collapse whitespace
    txt = re.sub(r"\s+", " ", cleaned)
    # count sentence enders (period/!/? not in numbers like 5.4)
    enders = re.findall(r"(?<![\d])[.!?](?:\s|$)", txt)
    return len(enders) <= 1


def split_sentences(body: str) -> list[str]:
    # remove headings, bullets markers, blockquotes
    text = re.sub(r"^#.*$", "", body, flags=re.MULTILINE)
    text = re.sub(r"^[>\-\*]\s*", "", text, flags=re.MULTILINE)
    # crude sentence splitter
    raw = re.split(r"(?<=[.!?])\s+(?=[A-Z\"\'])", text)
    return [s.strip() for s in raw if s.strip() and len(s.strip()) > 3]


def count_em_dashes(body: str) -> int:
    return body.count("—") + body.count("—")


def count_word_occurrences(body: str, word: str) -> int:
    # case-insensitive word boundary; allow multi-word phrases
    pattern = r"\b" + re.escape(word) + r"\b"
    return len(re.findall(pattern, body, flags=re.IGNORECASE))


def count_phrase(body: str, phrase: str) -> int:
    return len(re.findall(re.escape(phrase), body, flags=re.IGNORECASE))


def has_frankly(body: str) -> int:
    return count_word_occurrences(body, "frankly")


def bullet_lines(body: str) -> int:
    """Count lines that are bullet items (-, *, or numbered)."""
    return sum(1 for line in body.splitlines() if re.match(r"^\s*([-*]|\d+\.)\s+", line))


def word_count(body: str) -> int:
    return len(re.findall(r"\b\w+\b", body))


def bold_terms(body: str) -> list[str]:
    return re.findall(r"\*\*([^*]+)\*\*", body)


def bold_standalone(body: str) -> int:
    """A 'standalone bold definition' = a paragraph that BEGINS with **Term**[.:]
    followed by a definition-like clause (not flowing into the sentence).
    Heuristic: paragraph starts with **X**[.:] and the first letter after is uppercase, or
    it's followed by 'is/are/means/represents'."""
    paras = split_paragraphs(body)
    count = 0
    for p in paras:
        m = re.match(r"^\s*\*\*([^*]+)\*\*\s*[:.\-]\s*([A-Z]|is\b|are\b|means\b|represents\b)", p)
        if m:
            count += 1
    return count


def first_person_count(body: str) -> int:
    return len(re.findall(r"\b(I|I'm|I've|I'll|I'd|me|my|mine|myself|we|our|us)\b", body))


def audit_article(path: Path) -> dict:
    raw = path.read_text()
    body = extract_body(raw)
    paras = split_paragraphs(body)
    sentences = split_sentences(body)
    wc = word_count(body)
    sent_lens = [len(re.findall(r"\b\w+\b", s)) for s in sentences]
    contractions = len(CONTRACTIONS_RE.findall(body))

    result = {
        "file": path.name,
        "word_count": wc,
        "paragraph_count": len(paras),
        "sentence_count": len(sentences),
        "mean_sentence_words": round(mean(sent_lens), 1) if sent_lens else 0,
        "median_sentence_words": round(median(sent_lens), 1) if sent_lens else 0,
        "em_dashes": count_em_dashes(body),
        "banned_words": {w: count_word_occurrences(body, w) for w in BANNED_WORDS},
        "banned_total": sum(count_word_occurrences(body, w) for w in BANNED_WORDS),
        "ai_transitions": {t: count_phrase(body, t) for t in AI_TRANSITIONS},
        "ai_transitions_total": sum(count_phrase(body, t) for t in AI_TRANSITIONS),
        "frankly_uses": has_frankly(body),
        "single_sentence_paras": sum(1 for p in paras if is_single_sentence_para(p)),
        "bullet_lines": bullet_lines(body),
        "bold_terms_count": len(bold_terms(body)),
        "bold_standalone_definitions": bold_standalone(body),
        "first_person_pronoun_count": first_person_count(body),
        "first_person_per_100w": round(first_person_count(body) / max(wc, 1) * 100, 2),
        "contractions_count": contractions,
        "contractions_per_100w": round(contractions / max(wc, 1) * 100, 2),
    }
    return result


def main() -> int:
    corpus_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
    article_dir = corpus_dir / "articles" if (corpus_dir / "articles").exists() else corpus_dir
    files = sorted(article_dir.glob("*.md"))
    if not files:
        print(f"No .md files under {article_dir}", file=sys.stderr)
        return 1

    results = [audit_article(f) for f in files]

    # Aggregate
    agg = {
        "n_articles": len(results),
        "total_words": sum(r["word_count"] for r in results),
        "em_dashes_total": sum(r["em_dashes"] for r in results),
        "em_dashes_per_article_mean": round(mean(r["em_dashes"] for r in results), 2),
        "banned_total": sum(r["banned_total"] for r in results),
        "banned_breakdown": {
            w: sum(r["banned_words"][w] for r in results) for w in BANNED_WORDS
        },
        "ai_transitions_total": sum(r["ai_transitions_total"] for r in results),
        "ai_transitions_breakdown": {
            t: sum(r["ai_transitions"][t] for r in results) for t in AI_TRANSITIONS
        },
        "frankly_uses_total": sum(r["frankly_uses"] for r in results),
        "single_sentence_paras_total": sum(r["single_sentence_paras"] for r in results),
        "single_sentence_paras_per_article": round(
            mean(r["single_sentence_paras"] for r in results), 2
        ),
        "bullet_lines_total": sum(r["bullet_lines"] for r in results),
        "bullet_lines_per_article_mean": round(
            mean(r["bullet_lines"] for r in results), 2
        ),
        "bold_standalone_definitions_total": sum(
            r["bold_standalone_definitions"] for r in results
        ),
        "mean_sentence_words_corpus": round(
            mean(r["mean_sentence_words"] for r in results if r["mean_sentence_words"]), 1
        ),
        "first_person_per_100w_mean": round(
            mean(r["first_person_per_100w"] for r in results), 2
        ),
        "contractions_per_100w_mean": round(
            mean(r["contractions_per_100w"] for r in results), 2
        ),
    }

    print("=== PER-ARTICLE ===")
    for r in results:
        print(json.dumps(r, indent=2))
    print("\n=== AGGREGATE ===")
    print(json.dumps(agg, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
