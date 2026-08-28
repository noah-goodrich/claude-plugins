#!/usr/bin/env python3
"""Deterministic calibration / held-out split for the ai-scoring evaluation set.

Membership is a pure function of the seed and the file paths, so two runs on the same corpus agree
without storing any random state. Ordering inside a stratum comes from sha256("<seed>:<path>")
rather than the random module, which makes the split reproducible across Python versions.

The split is stratified on class and provider, so every class and every provider appears on both
sides. A stratum holding a single document cannot be split; it goes to calibration and the run
warns rather than silently producing a held-out set that is missing a provider.

The seal is a sha256 over the held-out documents' bytes, concatenated in sorted relative-path
order, plus a use counter. Editing any held-out document changes the hash, so a stale report
cannot be passed off as a fresh one.

Standard library only. No network.

Usage:
    python3 evals/harness/split.py --seed 20260827
    python3 evals/harness/split.py --seed 20260827 --held-out-frac 0.4 --dry-run
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from datetime import date
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent))

from corpus import (  # noqa: E402
    CORPUS_ROOT,
    HUMAN_ARTICLES_DIR,
    MANIFEST_PATH,
    REPO_ROOT,
    CorpusError,
    ProvenanceError,
    load_corpus,
)

EXIT_OK = 0
EXIT_GATE = 1
EXIT_USAGE = 2

DEFAULT_HELD_OUT_FRAC = 0.5


def stratum_order(seed: int, rel_paths: list[str]) -> list[str]:
    """Deterministic shuffle: sort by the digest of the seed and the path."""
    return sorted(
        rel_paths,
        key=lambda p: hashlib.sha256(f"{seed}:{p}".encode("utf-8")).hexdigest(),
    )


def split_stratum(
    seed: int, rel_paths: list[str], held_out_frac: float
) -> tuple[list[str], list[str]]:
    ordered = stratum_order(seed, rel_paths)
    if len(ordered) < 2:
        return ordered, []
    n_held = int(len(ordered) * held_out_frac)
    n_held = max(1, min(len(ordered) - 1, n_held))
    return ordered[n_held:], ordered[:n_held]


def build_split(
    by_class: dict, seed: int, held_out_frac: float
) -> tuple[list[str], list[str], list[str]]:
    strata: dict = {}
    for cls, docs in by_class.items():
        for doc in docs:
            strata.setdefault(f"{cls}/{doc.provider}", []).append(doc.rel_path())

    calibration: list[str] = []
    held_out: list[str] = []
    warnings: list[str] = []
    for name in sorted(strata):
        cal, held = split_stratum(seed, strata[name], held_out_frac)
        if not held:
            warnings.append(
                f"stratum {name} holds {len(strata[name])} document(s) and cannot appear on both "
                "sides; it is assigned to calibration only"
            )
        calibration.extend(cal)
        held_out.extend(held)

    return sorted(calibration), sorted(held_out), warnings


def seal_hash(rel_paths: list[str], root: Path = REPO_ROOT) -> str:
    """sha256 over the held-out documents' bytes, concatenated in sorted relative-path order."""
    digest = hashlib.sha256()
    for rel in sorted(rel_paths):
        digest.update((root / rel).read_bytes())
    return digest.hexdigest()


def load_manifest(path: Path = MANIFEST_PATH) -> dict:
    if not path.is_file():
        raise CorpusError(
            f"{path}: no split manifest. Create one with: python3 evals/harness/split.py --seed <int>"
        )
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise CorpusError(f"{path}: manifest is not valid JSON ({exc})") from None
    for field in ("seed", "calibration", "held_out", "seal"):
        if field not in manifest:
            raise CorpusError(f"{path}: manifest is missing the {field!r} field")
    for field in ("sha256", "uses", "sealed"):
        if field not in manifest["seal"]:
            raise CorpusError(f"{path}: manifest seal is missing the {field!r} field")
    return manifest


def write_manifest(manifest: dict, path: Path = MANIFEST_PATH) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")


def run(args: argparse.Namespace) -> int:
    try:
        by_class = load_corpus(args.corpus_root, args.articles_dir)
    except (ProvenanceError, CorpusError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return EXIT_GATE

    total = sum(len(docs) for docs in by_class.values())
    if total == 0:
        print(
            "error: no documents found.\n"
            f"  human articles: {args.articles_dir}\n"
            f"  generated documents: {args.corpus_root} (searched recursively for *.md)",
            file=sys.stderr,
        )
        return EXIT_GATE

    calibration, held_out, warnings = build_split(
        by_class, args.seed, args.held_out_frac
    )
    if not held_out:
        print(
            "error: the split produced an empty held-out set; every stratum holds a single "
            "document. Generate more documents before sealing a split.",
            file=sys.stderr,
        )
        return EXIT_GATE

    manifest = {
        "seed": args.seed,
        "calibration": calibration,
        "held_out": held_out,
        "seal": {
            "sha256": seal_hash(held_out),
            "uses": 0,
            "sealed": args.sealed_date or date.today().isoformat(),
        },
    }

    for warning in warnings:
        print(f"warning: {warning}", file=sys.stderr)

    if args.dry_run:
        print(json.dumps(manifest, indent=2))
        return EXIT_OK

    if args.manifest.is_file() and not args.force:
        existing = load_manifest(args.manifest)
        if existing["seal"].get("uses", 0) > 0:
            print(
                f"error: {args.manifest} records a seal that has been spent "
                f"({existing['seal']['uses']} use(s)). Re-splitting would recycle documents that "
                "have already been reported on. Pass --force if that is what you intend.",
                file=sys.stderr,
            )
            return EXIT_GATE

    write_manifest(manifest, args.manifest)

    counts: dict = {}
    for cls, docs in by_class.items():
        for doc in docs:
            side = "held_out" if doc.rel_path() in set(held_out) else "calibration"
            counts.setdefault(doc.stratum, {"calibration": 0, "held_out": 0})[side] += 1

    print(f"wrote {args.manifest}")
    print(f"  seed:        {args.seed}")
    print(f"  calibration: {len(calibration)} documents")
    print(f"  held out:    {len(held_out)} documents")
    print(
        f"  seal:        {manifest['seal']['sha256'][:16]}... uses=0 sealed={manifest['seal']['sealed']}"
    )
    print("  strata (calibration / held out):")
    for name in sorted(counts):
        print(
            f"    {name:24s} {counts[name]['calibration']:3d} / {counts[name]['held_out']:3d}"
        )
    return EXIT_OK


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="split.py",
        description="Write a deterministic, stratified, sealed calibration/held-out split.",
    )
    parser.add_argument(
        "--seed",
        type=int,
        required=True,
        help="integer seed; the split is a pure function of it",
    )
    parser.add_argument(
        "--held-out-frac",
        type=float,
        default=DEFAULT_HELD_OUT_FRAC,
        help=f"fraction of each stratum held out (default {DEFAULT_HELD_OUT_FRAC})",
    )
    parser.add_argument(
        "--corpus-root", type=Path, default=CORPUS_ROOT, help="generated documents root"
    )
    parser.add_argument(
        "--articles-dir",
        type=Path,
        default=HUMAN_ARTICLES_DIR,
        help="human articles directory",
    )
    parser.add_argument(
        "--manifest", type=Path, default=MANIFEST_PATH, help="manifest path to write"
    )
    parser.add_argument(
        "--sealed-date",
        help="override the seal date (YYYY-MM-DD) instead of using today",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="re-split even if the existing seal has been spent",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="print the manifest instead of writing it",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if not 0.0 < args.held_out_frac < 1.0:
        parser.error(f"--held-out-frac must be in (0, 1), got {args.held_out_frac}")
    return run(args)


if __name__ == "__main__":
    raise SystemExit(main())
