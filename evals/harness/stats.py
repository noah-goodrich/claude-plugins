#!/usr/bin/env python3
"""Interval arithmetic for the ai-scoring evaluation set.

Every rate this harness reports comes from a handful of documents, where the normal approximation
to a binomial proportion is worst: it is undefined at 0 and 1, and it puts interval bounds outside
[0, 1] for the small counts that dominate here. So the Wilson score interval is used in closed
form, which is well behaved at the boundaries and at n below 30.

Standard library only.
"""

from __future__ import annotations

from statistics import NormalDist

MAX_N = 10_000_000


def z_score(confidence: float = 0.95) -> float:
    """Two-sided critical value for a confidence level, e.g. 1.959964 at 0.95."""
    if not 0.0 < confidence < 1.0:
        raise ValueError(f"confidence must be in (0, 1), got {confidence}")
    return NormalDist().inv_cdf(1.0 - (1.0 - confidence) / 2.0)


def wilson(successes: int, n: int, confidence: float = 0.95) -> tuple[float, float]:
    """Wilson score interval for a binomial proportion, returned as (low, high) in [0, 1].

    With no observations the interval is the whole unit interval, which is the honest answer.
    """
    if n < 0 or successes < 0:
        raise ValueError(
            f"successes and n must be non-negative, got successes={successes}, n={n}"
        )
    if successes > n:
        raise ValueError(f"successes ({successes}) cannot exceed n ({n})")
    if n == 0:
        return (0.0, 1.0)

    z = z_score(confidence)
    p = successes / n
    z2 = z * z
    denom = 1.0 + z2 / n
    center = (p + z2 / (2.0 * n)) / denom
    half = (z / denom) * ((p * (1.0 - p) / n + z2 / (4.0 * n * n)) ** 0.5)
    return (max(0.0, center - half), min(1.0, center + half))


def wilson_half_width(successes: int, n: int, confidence: float = 0.95) -> float:
    low, high = wilson(successes, n, confidence)
    return (high - low) / 2.0


def n_for_margin(p: float, margin: float, confidence: float = 0.95) -> int:
    """Smallest n whose Wilson interval around an observed proportion p is no wider than 2*margin.

    p is a proportion in [0, 1] and margin is a half-width in the same units, so a +/-10 point
    interval is margin=0.10. Uses the normal-approximation sample size as a seed and then searches
    on the Wilson width itself, because the two disagree by several documents at the sizes here.
    """
    if not 0.0 <= p <= 1.0:
        raise ValueError(f"p must be in [0, 1], got {p}")
    if not 0.0 < margin < 1.0:
        raise ValueError(f"margin must be in (0, 1), got {margin}")

    z = z_score(confidence)
    seed = int((z * z * p * (1.0 - p)) / (margin * margin)) + 1
    lo, hi = 1, max(2, seed)
    while _half_width_at(p, hi, confidence) > margin:
        hi *= 2
        if hi > MAX_N:
            raise ValueError(
                f"no n below {MAX_N} reaches a margin of {margin} at p={p}"
            )
    while lo < hi:
        mid = (lo + hi) // 2
        if _half_width_at(p, mid, confidence) <= margin:
            hi = mid
        else:
            lo = mid + 1
    return lo


def _half_width_at(p: float, n: int, confidence: float) -> float:
    """Wilson half-width for a proportion p observed at sample size n.

    Rounds p*n to the nearest whole document, since a proportion has to be realisable as a count.
    """
    return wilson_half_width(round(p * n), n, confidence)


def format_rate(successes: int, n: int, confidence: float = 0.95) -> str:
    """Render a rate as 'k/n = X.X% (95% CI: lo-hi)'. The interval is never optional."""
    if n == 0:
        return f"0/0 = n/a ({int(confidence * 100)}% CI: 0.0-100.0)"
    low, high = wilson(successes, n, confidence)
    pct = successes / n * 100.0
    return (
        f"{successes}/{n} = {pct:.1f}% "
        f"({int(confidence * 100)}% CI: {low * 100:.1f}-{high * 100:.1f})"
    )


def main() -> int:
    import argparse

    parser = argparse.ArgumentParser(description="Wilson interval helpers.")
    parser.add_argument("--wilson", nargs=2, type=int, metavar=("SUCCESSES", "N"))
    parser.add_argument("--n-for-margin", nargs=2, type=float, metavar=("P", "MARGIN"))
    parser.add_argument("--confidence", type=float, default=0.95)
    args = parser.parse_args()

    if args.wilson:
        print(format_rate(args.wilson[0], args.wilson[1], args.confidence))
        return 0
    if args.n_for_margin:
        p, margin = args.n_for_margin
        print(n_for_margin(p, margin, args.confidence))
        return 0
    parser.print_help()
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
