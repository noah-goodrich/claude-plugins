#!/usr/bin/env python3
"""ai-scoring framework operationalized as deterministic checks.

Implements the 8 categories from ai-scoring/SKILL.md as a scoring function.
Each translation decision is documented inline.

Usage:
    python3 ai_score.py <file.md> [<file.md> ...]
    python3 ai_score.py --batch <dir>
    python3 ai_score.py --eval <human_dir> <ai_dir>
"""
from __future__ import annotations
import json
import re
import sys
from pathlib import Path
from statistics import mean, median, stdev

# ---------- Translation decisions documented ----------
# Cat 1 Staccato: "single-sentence paragraph" = paragraph with <=1 sentence
#   enders. Scoring per SKILL: 1-2 -> 0, 3-4 -> -5..-10, 5+ -> -15..-20.
#   Decision: pick midpoints (3-4 = -7, 5-9 = -15, 10+ = -20).
#
# Cat 2 Parallel: detect 3+ consecutive sentences starting with the same
#   leading word (case-insensitive) OR 3+ consecutive paragraphs that begin
#   with "The Nth X" style (numerical-ordinal openers).
#
# Cat 3 Generic transitions: literal phrase list from SKILL. -2 each, capped -15.
#
# Cat 4 Hedging: count phrases like "while X has its merits", "pros and cons",
#   "it depends on", "on the one hand / on the other hand". Cap -10.
#
# Cat 5 Repetitive openings: 3+ consecutive sentences with same first word.
#   We give -5 per cluster, capped at -10.
#
# Cat 6 Lists-as-prose: paragraphs where 3+ consecutive sentences each are short
#   (<=15 words) and the second/third begin with "Also", "Additionally",
#   "Furthermore", "Moreover", or "It also". -3 per instance, capped -10.
#
# Cat 7 Specific detail lack: ratio of "specific tokens" (numbers, proper nouns,
#   currency, percentages, dates) to total words. Below 1.5/100 words -> -10.
#   Below 0.5/100 -> -15. (We sidestep "in my experience without describing it"
#   as that requires semantic understanding.)
#
# Cat 8 Banned words: from voice-rules + AI calling cards in ai-scoring SKILL.
#   Count instances. 1-2 = -3, 3+ = -7, 5+ = -10. Em dashes count toward this
#   bucket (1 point each, capped at -10 contribution).

FRONTMATTER_RE = re.compile(r"^---\n.*?\n---\n", re.DOTALL)


def strip_frontmatter(text: str) -> str:
    return FRONTMATTER_RE.sub("", text, count=1)


def strip_code(text: str) -> str:
    return re.sub(r"```.*?```", "", text, flags=re.DOTALL)


def get_body(text: str) -> str:
    return strip_code(strip_frontmatter(text))


def paragraphs(body: str) -> list[str]:
    paras = []
    for raw in re.split(r"\n\s*\n", body):
        p = raw.strip()
        if not p or p.startswith("#") or p.startswith("!["):
            continue
        paras.append(p)
    return paras


def sentences(body: str) -> list[str]:
    text = re.sub(r"^#.*$", "", body, flags=re.MULTILINE)
    text = re.sub(r"^[>\-\*]\s*", "", text, flags=re.MULTILINE)
    raw = re.split(r"(?<=[.!?])\s+(?=[A-Z\"\'])", text)
    return [s.strip() for s in raw if s.strip() and len(s.strip()) > 3]


def count_sentence_enders(text: str) -> int:
    return len(re.findall(r"(?<![\d])[.!?](?:\s|$)", text))


# --- Categories ---

GENERIC_TRANSITIONS = [
    "here's the thing",
    "let's dive in",
    "that said",
    "but here's the kicker",
    "let me explain",
    "so, what does this mean",
    "the truth is",
    "it's worth noting",
    "at the end of the day",
    "the bottom line",
    "but wait, there's more",
    "in conclusion",
    "moreover",
    "furthermore",
    "in today's fast-paced",
    "it is important to note",
    "it's important to note",
]

BANNED_WORDS = [
    "genuinely",
    "straightforward",
    "honestly",
    "to be honest",
    "navigate",
    "landscape",
    "leverage",
    "delve",
    "game-changer",
    "cutting-edge",
    "revolutionary",
    "synergy",
    "paradigm shift",
]

HEDGE_PHRASES = [
    "while.*has its merits",
    "pros and cons",
    "it depends on your",
    "on the one hand",
    "on the other hand",
    "both approaches have",
    "there are benefits to both",
]


def score_staccato(paras: list[str]) -> tuple[int, list[str]]:
    flagged = []
    single_count = 0
    for p in paras:
        cleaned = re.sub(r"^[>\-\*\d+\.]+\s*", "", p).strip()
        if cleaned.startswith(("- ", "* ")):
            continue
        enders = count_sentence_enders(cleaned)
        if enders <= 1 and len(cleaned.split()) > 2:
            single_count += 1
            if len(flagged) < 6:
                flagged.append(cleaned[:120])
    if single_count <= 2:
        return 0, flagged
    if single_count <= 4:
        return -7, flagged
    if single_count <= 9:
        return -15, flagged
    return -20, flagged


def score_parallel(paras: list[str], sents: list[str]) -> tuple[int, list[str]]:
    """Detect 3+ consecutive sentences with identical first word, or 3+
    consecutive paragraphs starting with 'The Nth ...'."""
    flagged = []
    # 3+ consec sentences with same opening word
    penalty = 0
    run = 0
    last_word = None
    for s in sents:
        first = re.match(r"^[\W_]*([\w']+)", s)
        word = first.group(1).lower() if first else ""
        if word and word == last_word:
            run += 1
        else:
            if run >= 3 and last_word not in {"the", "a", "an", "i"}:
                penalty -= 5
                flagged.append(f"{run+1} consecutive sentences starting with '{last_word}'")
            elif run >= 4:
                penalty -= 5
                flagged.append(f"{run+1} consecutive sentences starting with '{last_word}'")
            run = 1
        last_word = word
    if run >= 3 and last_word not in {"the", "a", "an", "i"}:
        penalty -= 5
        flagged.append(f"{run+1} consecutive sentences starting with '{last_word}'")

    # "The first / second / third X" ordinal openers
    ordinals = ["first", "second", "third", "fourth", "fifth", "1st", "2nd", "3rd"]
    para_openers = [
        re.match(r"^[\W_]*the\s+(\w+)", p, re.IGNORECASE) for p in paras
    ]
    consec = 0
    for m in para_openers:
        if m and m.group(1).lower() in ordinals:
            consec += 1
        else:
            if consec >= 3:
                penalty -= 10
                flagged.append("3+ consecutive 'The Nth …' paragraph openers")
            consec = 0
    if consec >= 3:
        penalty -= 10
        flagged.append("3+ consecutive 'The Nth …' paragraph openers")

    return max(penalty, -15), flagged


def score_transitions(body: str) -> tuple[int, list[str]]:
    flagged = []
    n = 0
    for t in GENERIC_TRANSITIONS:
        c = len(re.findall(re.escape(t), body, re.IGNORECASE))
        if c > 0:
            n += c
            flagged.append(f"'{t}' x{c}")
    if n == 0:
        return 0, flagged
    return max(-2 * n, -15), flagged


def score_hedging(body: str) -> tuple[int, list[str]]:
    flagged = []
    n = 0
    for h in HEDGE_PHRASES:
        c = len(re.findall(h, body, re.IGNORECASE))
        if c > 0:
            n += c
            flagged.append(f"hedge '{h}' x{c}")
    if n == 0:
        return 0, flagged
    return max(-3 * n, -10), flagged


def score_openings(sents: list[str]) -> tuple[int, list[str]]:
    """3+ consecutive sentences with same opening word — already counted in
    parallel, but the SKILL lists this as a separate category. We'll also
    count overall opening-word entropy."""
    flagged = []
    openers = []
    for s in sents:
        m = re.match(r"^[\W_]*([\w']+)", s)
        if m:
            openers.append(m.group(1).lower())
    if not openers:
        return 0, flagged
    # check if dominant opener > 30% of sentences
    from collections import Counter
    c = Counter(openers)
    top, n = c.most_common(1)[0]
    if n / len(openers) > 0.30 and top in {"the", "i", "it", "this", "but", "and"}:
        flagged.append(f"'{top}' opens {n}/{len(openers)} ({n/len(openers)*100:.0f}%) sentences")
        return -5, flagged
    return 0, flagged


def score_lists_as_prose(paras: list[str]) -> tuple[int, list[str]]:
    flagged = []
    penalty = 0
    list_markers = re.compile(r"\b(also|additionally|furthermore|moreover|it also)\b", re.IGNORECASE)
    for p in paras:
        sents_in_p = re.split(r"(?<=[.!?])\s+", p)
        if len(sents_in_p) < 3:
            continue
        short_and_marked = 0
        for s in sents_in_p:
            w = len(s.split())
            if w <= 18 and list_markers.search(s):
                short_and_marked += 1
        if short_and_marked >= 2:
            penalty -= 3
            flagged.append(p[:100])
    return max(penalty, -10), flagged


def score_specificity(body: str) -> tuple[int, list[str]]:
    flagged = []
    words = re.findall(r"\b\w+\b", body)
    wc = len(words)
    if wc == 0:
        return 0, flagged
    # specific tokens: numbers, currency, percent, dates, proper nouns (capitalized mid-sentence)
    numbers = len(re.findall(r"\b\d+(?:[.,]\d+)?\b", body))
    currency = len(re.findall(r"\$[\d,]+", body))
    pct = len(re.findall(r"\d+%", body))
    months = len(re.findall(r"\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\b", body))
    years = len(re.findall(r"\b(?:19|20)\d{2}\b", body))
    # Proper nouns: capitalized words not at sentence start
    proper = len(re.findall(r"(?<![\.!\?]\s)\b[A-Z][a-z]{2,}\b", body))
    specific = numbers + currency + pct + months + years + proper
    rate = specific / wc * 100
    if rate < 0.5:
        flagged.append(f"specific tokens {rate:.2f}/100w — very low")
        return -15, flagged
    if rate < 1.5:
        flagged.append(f"specific tokens {rate:.2f}/100w — low")
        return -10, flagged
    if rate < 3.0:
        flagged.append(f"specific tokens {rate:.2f}/100w — moderate")
        return -3, flagged
    return 0, flagged


def score_banned(body: str) -> tuple[int, list[str]]:
    flagged = []
    n = 0
    for w in BANNED_WORDS:
        c = len(re.findall(r"\b" + re.escape(w) + r"\b", body, re.IGNORECASE))
        if c > 0:
            n += c
            flagged.append(f"'{w}' x{c}")
    # em dashes
    em = body.count("—")
    if em > 0:
        n += em
        flagged.append(f"em-dash x{em}")
    if n == 0:
        return 0, flagged
    if n <= 2:
        return -3, flagged
    if n <= 4:
        return -7, flagged
    return -10, flagged


def score_file(path: Path) -> dict:
    raw = path.read_text()
    body = get_body(raw)
    paras = paragraphs(body)
    sents = sentences(body)
    wc = len(re.findall(r"\b\w+\b", body))

    cats = {}
    p, f = score_staccato(paras); cats["1_staccato"] = {"penalty": p, "flags": f}
    p, f = score_parallel(paras, sents); cats["2_parallel"] = {"penalty": p, "flags": f}
    p, f = score_transitions(body); cats["3_transitions"] = {"penalty": p, "flags": f}
    p, f = score_hedging(body); cats["4_hedging"] = {"penalty": p, "flags": f}
    p, f = score_openings(sents); cats["5_openings"] = {"penalty": p, "flags": f}
    p, f = score_lists_as_prose(paras); cats["6_lists"] = {"penalty": p, "flags": f}
    p, f = score_specificity(body); cats["7_specificity"] = {"penalty": p, "flags": f}
    p, f = score_banned(body); cats["8_banned"] = {"penalty": p, "flags": f}

    total_penalty = sum(c["penalty"] for c in cats.values())
    score = max(0, 100 + total_penalty)

    return {
        "file": path.name,
        "word_count": wc,
        "score": score,
        "total_penalty": total_penalty,
        "categories": cats,
        "flag_count": sum(len(c["flags"]) for c in cats.values() if c["penalty"] < 0),
    }


def evaluate(human_dir: Path, ai_dir: Path) -> dict:
    human_files = sorted(human_dir.glob("*.md"))
    ai_files = sorted(ai_dir.glob("*.md"))
    human_results = [score_file(f) for f in human_files]
    ai_results = [score_file(f) for f in ai_files]

    # Treat "flagged as AI" as score < 75 (matches SKILL threshold)
    THRESHOLD = 75

    tp = sum(1 for r in ai_results if r["score"] < THRESHOLD)
    fn = sum(1 for r in ai_results if r["score"] >= THRESHOLD)
    fp = sum(1 for r in human_results if r["score"] < THRESHOLD)
    tn = sum(1 for r in human_results if r["score"] >= THRESHOLD)

    precision = tp / (tp + fp) if (tp + fp) else 0.0
    recall = tp / (tp + fn) if (tp + fn) else 0.0
    f1 = 2 * precision * recall / (precision + recall) if (precision + recall) else 0.0
    accuracy = (tp + tn) / (tp + fp + tn + fn) if (tp + fp + tn + fn) else 0.0

    # which categories contribute most to AI flagging vs false positives
    def total_by_cat(results, neg_only=True):
        out = {}
        for r in results:
            for cat, v in r["categories"].items():
                out.setdefault(cat, 0)
                out[cat] += v["penalty"]
        return out

    return {
        "threshold": THRESHOLD,
        "human_scores": [{"file": r["file"], "score": r["score"]} for r in human_results],
        "ai_scores": [{"file": r["file"], "score": r["score"]} for r in ai_results],
        "human_score_mean": round(mean(r["score"] for r in human_results), 1),
        "human_score_median": round(median(r["score"] for r in human_results), 1),
        "human_score_min": min(r["score"] for r in human_results),
        "human_score_max": max(r["score"] for r in human_results),
        "ai_score_mean": round(mean(r["score"] for r in ai_results), 1) if ai_results else None,
        "ai_score_median": round(median(r["score"] for r in ai_results), 1) if ai_results else None,
        "ai_score_min": min(r["score"] for r in ai_results) if ai_results else None,
        "ai_score_max": max(r["score"] for r in ai_results) if ai_results else None,
        "confusion": {"tp": tp, "fp": fp, "tn": tn, "fn": fn},
        "precision": round(precision, 3),
        "recall": round(recall, 3),
        "f1": round(f1, 3),
        "accuracy": round(accuracy, 3),
        "cat_contributions_human": total_by_cat(human_results),
        "cat_contributions_ai": total_by_cat(ai_results),
        "human_details": human_results,
        "ai_details": ai_results,
    }


def main() -> int:
    args = sys.argv[1:]
    if not args:
        print(__doc__, file=sys.stderr)
        return 1
    if args[0] == "--eval":
        if len(args) != 3:
            print("Usage: --eval <human_dir> <ai_dir>", file=sys.stderr)
            return 1
        res = evaluate(Path(args[1]), Path(args[2]))
        print(json.dumps(res, indent=2))
        return 0
    if args[0] == "--batch":
        for p in sorted(Path(args[1]).glob("*.md")):
            print(json.dumps(score_file(p), indent=2))
        return 0
    for arg in args:
        print(json.dumps(score_file(Path(arg)), indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
