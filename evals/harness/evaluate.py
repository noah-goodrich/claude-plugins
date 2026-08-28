#!/usr/bin/env python3
"""Report the ai-scoring rubric's behaviour against the evaluation set, with its uncertainty.

Three modes:

    --contamination   rubric-term density per class, against a 1.0 hits-per-100-words ceiling.
                      This is the check that would have caught the retired fixtures.
    --report          per-category fire rates on the calibration split, every rate with a
                      Wilson 95% interval.
    --held-out        the same report on the sealed split, once.

Scoring is not reimplemented here. It is the existing
noah-writing-voice/validation/2026-05-23-corpus/scripts/ai_score.py, loaded by path, so this
harness measures the scorer that actually runs rather than a copy of it.

Standard library only. No network.
"""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent))

import stats  # noqa: E402
from corpus import (  # noqa: E402
    ALL_CLASSES,
    CORPUS_ROOT,
    HUMAN_ARTICLES_DIR,
    HUMAN_CLASS,
    MANIFEST_PATH,
    NEGATIVE_CLASSES,
    OLD_FIXTURES_DIR,
    REPO_ROOT,
    SCORER_PATH,
    SKILL_PATH,
    CorpusError,
    ProvenanceError,
    body_text,
    document_for_path,
    load_corpus,
    rel_to_repo,
    require_classes,
    rubric_term_density,
    rubric_term_hits,
    rubric_terms,
)
from split import load_manifest, seal_hash, write_manifest  # noqa: E402

EXIT_OK = 0
EXIT_GATE = 1
EXIT_USAGE = 2

CONTAMINATION_CEILING = 1.0

# ai-scoring/SKILL.md: 75 is the article-mode publish threshold, and ai_score.py's own evaluate()
# uses the same number to decide "flagged as AI".
GATE_THRESHOLD = 75

MARGIN = 0.10

CATEGORY_LABELS = {
    "1_staccato": "staccato rhythm",
    "2_parallel": "too-clean parallel structure",
    "3_transitions": "generic transitions",
    "4_hedging": "overly balanced / hedged",
    "5_openings": "repetitive sentence openings",
    "6_lists": "lists disguised as prose",
    "7_specificity": "lack of specific detail",
    "8_banned": "banned words and phrases",
}

DOCUMENTED_HUMAN_RANGE = "0.00-0.55"
DOCUMENTED_FIXTURE_RANGE = "7.14-8.33"


class ReportError(RuntimeError):
    """The report cannot be produced honestly with the data on disk."""


# ---------- scorer ----------


def load_scorer(path: Path = SCORER_PATH):
    if not path.is_file():
        raise ReportError(
            f"{path}: scorer not found; --report and --held-out need ai_score.py"
        )
    spec = importlib.util.spec_from_file_location("ai_score", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    if not hasattr(module, "score_file"):
        raise ReportError(
            f"{path}: no score_file() in the scorer; the harness cannot call it"
        )
    return module


# ---------- output ----------


def emit(lines: list[str]) -> None:
    """Print report lines after checking AC5 structurally: no percentage without its interval.

    A bare rate is the specific failure this whole evaluation set exists to stop, so it is enforced
    on the output rather than left to the care of whoever edits a format string.
    """
    for line in lines:
        if "%" in line and "CI:" not in line:
            raise ReportError(
                f"internal: report line carries a percentage with no interval: {line!r}"
            )
    print("\n".join(lines))


# ---------- contamination ----------


def contamination(args: argparse.Namespace) -> int:
    by_class = load_corpus(args.corpus_root, args.articles_dir)
    terms = rubric_terms(args.skill)

    lines = [
        "RUBRIC-TERM CONTAMINATION",
        "Hits per 100 words against the ai-scoring banned lists, read live from the rubric.",
        "",
        f"Terms parsed from {rel_to_repo(args.skill)}: {len(terms['all'])}",
        f"  category 3 banned transitions: {len(terms['transitions'])}",
        f"  category 8 banned words:       {len(terms['banned_words'])}",
        "  Em dashes are excluded. A punctuation mark is not a lexical lift from a word list, and",
        "  counting them would put Noah's own older articles over the ceiling.",
        "",
        "Reference poles, measured here with this same rule:",
    ]

    old_fixtures = _fixture_densities(args.fixtures_dir, args.skill)
    human_densities = [
        (d.name, rubric_term_density(d.body, args.skill)) for d in by_class[HUMAN_CLASS]
    ]
    lines.append("  " + _pole_line("real writing (human corpus)", human_densities))
    lines.append("  " + _pole_line("retired keyword-stuffed fixtures", old_fixtures))
    lines += [
        f"  Documented 2026-08-26: real writing {DOCUMENTED_HUMAN_RANGE}, fixtures "
        f"{DOCUMENTED_FIXTURE_RANGE}. Those",
        "  figures came from a wider term list than the rubric prose carries, so the poles above are",
        "  the ones comparable to the per-class numbers below.",
        "",
        f"Ceiling: {CONTAMINATION_CEILING:.2f} hits per 100 words",
        "",
    ]

    failures: list[str] = []
    for cls in ALL_CLASSES:
        docs = by_class[cls]
        if not docs:
            lines.append(f"  {cls:8s} no documents")
            continue
        densities = [(d.name, rubric_term_density(d.body, args.skill)) for d in docs]
        mean = sum(v for _, v in densities) / len(densities)
        worst_name, worst = max(densities, key=lambda kv: kv[1])
        verdict = "PASS"
        if mean > CONTAMINATION_CEILING:
            verdict = "FAIL"
            failures.append(
                f"class {cls}: mean {mean:.2f} exceeds the {CONTAMINATION_CEILING:.2f} ceiling"
            )
        for name, value in densities:
            if value > CONTAMINATION_CEILING:
                verdict = "FAIL"
                failures.append(
                    f"{cls}/{name}: {value:.2f} exceeds the {CONTAMINATION_CEILING:.2f} ceiling"
                )
        lines.append(
            f"  {cls:8s} n={len(docs):<3d} mean {mean:.2f}  max {worst:.2f} ({worst_name})  {verdict}"
        )

    if args.verbose:
        lines.append("")
        lines.append("Per-document hits:")
        for cls in ALL_CLASSES:
            for doc in by_class[cls]:
                hits = rubric_term_hits(doc.body, args.skill)
                detail = (
                    ", ".join(f"{t} x{n}" for t, n in sorted(hits.items())) or "none"
                )
                lines.append(
                    f"  {cls:8s} {doc.name:48s} {rubric_term_density(doc.body, args.skill):5.2f}  {detail}"
                )

    lines.append("")
    if not any(by_class[cls] for cls in NEGATIVE_CLASSES):
        lines.append("RESULT: FAIL — no generated documents to check.")
        lines.append(
            f"  Generated documents are read from {rel_to_repo(args.corpus_root)} (recursively)."
        )
        lines.append(
            "  Run evals/generate/generate.sh before treating this gate as passed; a gate"
        )
        lines.append("  with nothing to measure has not passed, it has not run.")
        emit(lines)
        return EXIT_GATE

    try:
        require_classes(by_class, NEGATIVE_CLASSES)
    except CorpusError as exc:
        lines.append(f"RESULT: FAIL — {_first_line(exc)}")
        lines.append(f"  Documents found: {_class_counts(by_class)}.")
        lines.append(
            "  generic and voiced are both required. Density measured over one negative class says"
        )
        lines.append(
            "  nothing about the other, so this run checked half the corpus and passed none of it."
        )
        lines.append(
            f"  Generated documents are read from {rel_to_repo(args.corpus_root)} (recursively);"
        )
        lines.append(
            "  the class label is the 'class:' field in each document, not its directory."
        )
        emit(lines)
        return EXIT_GATE

    if failures:
        lines.append("RESULT: FAIL")
        lines += [f"  {f}" for f in failures]
        emit(lines)
        return EXIT_GATE

    lines.append(
        f"RESULT: PASS — every negative class is at or below the {CONTAMINATION_CEILING:.2f} "
        "hits/100w ceiling."
    )
    lines.append(
        "  This tests the ceiling, not conformance to the human range. Compare the per-class"
    )
    lines.append(
        "  means against the human pole above to judge how close the negatives actually sit."
    )
    emit(lines)
    return EXIT_OK


def _class_counts(by_class: dict) -> str:
    return ", ".join(f"{cls} n={len(by_class[cls])}" for cls in ALL_CLASSES)


def _first_line(exc: Exception) -> str:
    """The headline sentence of a CorpusError.

    require_classes() follows its headline with the module-default corpus and articles paths. This
    mode re-states those from the paths the run actually used, so only the headline is quoted.
    """
    return str(exc).splitlines()[0]


def _fixture_densities(fixtures_dir: Path, skill: Path) -> list:
    if not fixtures_dir.is_dir():
        return []
    return [
        (p.name, rubric_term_density(body_text(p.read_text(encoding="utf-8")), skill))
        for p in sorted(fixtures_dir.glob("*.md"))
    ]


def _pole_line(label: str, densities: list) -> str:
    if not densities:
        return f"{label:36s} not present"
    values = [v for _, v in densities]
    return (
        f"{label:36s} n={len(values):<3d} mean {sum(values) / len(values):.2f}  "
        f"range {min(values):.2f}-{max(values):.2f}"
    )


# ---------- report ----------


def collect(rel_paths: list[str]) -> dict:
    """Load the manifest's documents, grouped by class, failing on anything missing."""
    by_class: dict = {cls: [] for cls in ALL_CLASSES}
    missing = []
    for rel_path in rel_paths:
        path = REPO_ROOT / rel_path
        if not path.is_file():
            missing.append(rel_path)
            continue
        doc = document_for_path(path)
        by_class[doc.doc_class].append(doc)
    if missing:
        raise ReportError(
            "manifest lists document(s) that are not on disk:\n  "
            + "\n  ".join(missing)
            + "\nRe-run split.py if the corpus changed."
        )
    return by_class


def build_report(title: str, by_class: dict, scorer, source: str) -> list[str]:
    present = [cls for cls in ALL_CLASSES if by_class[cls]]
    missing_negatives = [cls for cls in NEGATIVE_CLASSES if not by_class[cls]]
    if missing_negatives:
        raise ReportError(
            "refusing to report: negative class(es) missing from this split: "
            + ", ".join(missing_negatives)
            + "\nBoth generic and voiced must be present. A report on one of them is not a report on"
            " the population the gate runs against."
        )
    if not by_class[HUMAN_CLASS]:
        raise ReportError(
            "refusing to report: no human documents in this split, so there is no false-positive"
            " rate to report."
        )

    scored = {
        cls: [(doc, scorer.score_file(doc.path)) for doc in by_class[cls]]
        for cls in present
    }

    lines = [title, source, ""]

    lines.append("Class sizes and word counts")
    for cls in present:
        counts = sorted(doc.word_count for doc in by_class[cls])
        providers = ", ".join(sorted({doc.provider for doc in by_class[cls]}))
        median = counts[len(counts) // 2]
        lines.append(
            f"  {cls:8s} n={len(counts):<3d} words {counts[0]}-{counts[-1]} (median {median})"
            f"  providers: {providers}"
        )
    lines.append("")

    lines.append(
        f"Score distribution (ai_score.py, 0-100; the gate flags below {GATE_THRESHOLD})"
    )
    for cls in present:
        values = sorted(r["score"] for _, r in scored[cls])
        median = values[len(values) // 2]
        lines.append(f"  {cls:8s} median {median:5.1f}  range {values[0]}-{values[-1]}")
    lines.append("")

    lines.append(f"Gate fire rate (score < {GATE_THRESHOLD}, read as machine-written)")
    gate_rates = {}
    for cls in present:
        fired = sum(1 for _, r in scored[cls] if r["score"] < GATE_THRESHOLD)
        n = len(scored[cls])
        gate_rates[cls] = (fired, n)
        lines.append(f"  {cls:8s} {stats.format_rate(fired, n)}")
    human_fired, human_n = gate_rates[HUMAN_CLASS]
    lines.append(
        f"  The human line is the false-positive rate. {human_fired} of {human_n}."
    )
    lines.append("")

    lines.append("Per-category fire rate (the category subtracted any points at all)")
    for key in sorted(CATEGORY_LABELS):
        lines.append(f"  {key} — {CATEGORY_LABELS[key]}")
        for cls in present:
            fired = sum(
                1
                for _, r in scored[cls]
                if r["categories"].get(key, {}).get("penalty", 0) < 0
            )
            lines.append(f"    {cls:8s} {stats.format_rate(fired, len(scored[cls]))}")
    lines.append("")

    lines.append(
        "What this sample can carry (+/-10 points means a Wilson half-width of 0.10)"
    )
    for cls in present:
        fired, n = gate_rates[cls]
        observed = fired / n if n else 0.0
        needed = stats.n_for_margin(observed, MARGIN)
        width = stats.wilson_half_width(fired, n) * 2 * 100
        lines.append(
            f"  {cls:8s} gate rate {stats.format_rate(fired, n)}, {width:.1f} points wide."
        )
        lines.append(
            f"           Reaching +/-10 points at that rate needs n={needed}; have n={n}."
        )
    lines.append(
        f"  Worst case, a rate near one half needs n={stats.n_for_margin(0.5, MARGIN)} per class."
    )
    lines.append(
        "  No threshold should be moved on numbers this wide. That is the finding, not a caveat."
    )
    lines.append("")

    lines.append(
        "Reminder: generic and voiced are never pooled. voiced is all-Anthropic by"
    )
    lines.append(
        "construction, because that is the population the gate actually runs on."
    )
    return lines


def report(args: argparse.Namespace) -> int:
    manifest = load_manifest(args.manifest)
    by_class = collect(manifest["calibration"])
    scorer = load_scorer(args.scorer)
    lines = build_report(
        "CALIBRATION REPORT",
        by_class,
        scorer,
        f"{rel_to_repo(args.manifest)} calibration split, seed {manifest['seed']}, "
        f"{len(manifest['calibration'])} documents",
    )
    emit(lines)
    return EXIT_OK


def held_out(args: argparse.Namespace) -> int:
    manifest = load_manifest(args.manifest)
    seal = manifest["seal"]

    missing = [p for p in manifest["held_out"] if not (REPO_ROOT / p).is_file()]
    if missing:
        print(
            "SEAL BROKEN: held-out document(s) named in the manifest are not on disk:\n  "
            + "\n  ".join(missing),
            file=sys.stderr,
        )
        return EXIT_GATE

    actual = seal_hash(manifest["held_out"])
    if actual != seal["sha256"]:
        print(
            "SEAL BROKEN: the held-out documents no longer hash to the sealed value.\n"
            f"  sealed:   {seal['sha256']}\n"
            f"  on disk:  {actual}\n"
            f"  sealed on {seal['sealed']} over {len(manifest['held_out'])} documents.\n"
            "  A held-out set that changed after sealing is not held out. Re-split, or restore the"
            " documents.",
            file=sys.stderr,
        )
        return EXIT_GATE

    uses = int(seal.get("uses", 0))
    if uses > 0 and not args.break_seal:
        print(
            f"REFUSING: this held-out split has already been reported on {uses} time(s) "
            f"(sealed {seal['sealed']}).\n"
            "  Consulting it again turns it into a calibration set, which is exactly how the"
            " previous\n"
            "  corpus became worthless: roughly 74 candidate rules were evaluated against 15"
            " documents.\n"
            "  Pass --break-seal to override, and record why in the PR.",
            file=sys.stderr,
        )
        return EXIT_GATE

    by_class = collect(manifest["held_out"])
    scorer = load_scorer(args.scorer)
    banner = "HELD-OUT REPORT"
    if uses > 0:
        banner += f"  (SEAL BROKEN DELIBERATELY: use {uses + 1} of this split)"
    lines = build_report(
        banner,
        by_class,
        scorer,
        f"{rel_to_repo(args.manifest)} held-out split, seed {manifest['seed']}, "
        f"{len(manifest['held_out'])} documents, sealed {seal['sealed']}",
    )
    lines.append("")
    lines.append(
        f"This split is now spent (uses={uses + 1}). Further reports on it need --break-seal and"
        " mean nothing."
    )
    emit(lines)

    seal["uses"] = uses + 1
    write_manifest(manifest, args.manifest)
    return EXIT_OK


# ---------- cli ----------


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="evaluate.py",
        description=(
            "Report the ai-scoring rubric against the evaluation set. Offline: reads files, calls"
            " ai_score.py, prints numbers with their intervals."
        ),
        epilog="Exit codes: 0 success, 1 gate failure, 2 usage error.",
    )
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument(
        "--contamination",
        action="store_true",
        help="rubric-term density per class against a 1.0 hits-per-100-words ceiling",
    )
    mode.add_argument(
        "--report",
        action="store_true",
        help="per-category fire rates on the calibration split, every rate with a Wilson 95%% interval",
    )
    mode.add_argument(
        "--held-out",
        action="store_true",
        help="the same report on the sealed held-out split; allowed once",
    )
    parser.add_argument(
        "--break-seal",
        action="store_true",
        help="report on a held-out split that has already been spent (--held-out only)",
    )
    parser.add_argument(
        "--manifest",
        type=Path,
        default=MANIFEST_PATH,
        help="split manifest path (--report and --held-out)",
    )
    parser.add_argument(
        "--corpus-root",
        type=Path,
        default=None,
        help=f"generated documents root (--contamination only; default {rel_to_repo(CORPUS_ROOT)})",
    )
    parser.add_argument(
        "--articles-dir",
        type=Path,
        default=None,
        help=(
            "human articles directory (--contamination only; default "
            f"{rel_to_repo(HUMAN_ARTICLES_DIR)})"
        ),
    )
    parser.add_argument(
        "--scorer",
        type=Path,
        default=SCORER_PATH,
        help="path to ai_score.py (--report and --held-out)",
    )
    parser.add_argument(
        "--skill",
        type=Path,
        default=SKILL_PATH,
        help="path to ai-scoring/SKILL.md, source of the term lists (--contamination)",
    )
    parser.add_argument(
        "--fixtures-dir",
        type=Path,
        default=OLD_FIXTURES_DIR,
        help=(
            "retired ai-samples directory, measured as the contaminated reference pole"
            " (--contamination)"
        ),
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="per-document rubric-term detail (--contamination)",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.break_seal and not args.held_out:
        parser.error("--break-seal applies to --held-out only")

    corpus_flags = [
        flag
        for flag, value in (
            ("--corpus-root", args.corpus_root),
            ("--articles-dir", args.articles_dir),
        )
        if value is not None
    ]
    if corpus_flags and not args.contamination:
        parser.error(
            ", ".join(corpus_flags)
            + (" apply" if len(corpus_flags) > 1 else " applies")
            + " to --contamination only; --report and --held-out read the documents named"
            " in the split manifest, resolved against the repo root. Re-split with split.py to"
            " point them somewhere else."
        )
    if args.corpus_root is None:
        args.corpus_root = CORPUS_ROOT
    if args.articles_dir is None:
        args.articles_dir = HUMAN_ARTICLES_DIR

    try:
        if args.contamination:
            return contamination(args)
        if args.report:
            return report(args)
        return held_out(args)
    except (ProvenanceError, CorpusError, ReportError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return EXIT_GATE
    except OSError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return EXIT_GATE


if __name__ == "__main__":
    raise SystemExit(main())
