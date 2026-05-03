#!/usr/bin/env python3
"""
Uncertainty sampling for active learning.

Given a dataset with classifier probabilities, rank examples by uncertainty
and return the top K.

Usage
-----
    # Binary: rank by |p - 0.5|
    python sample_uncertainty.py --input scored.parquet --out hardest.parquet \\
        --prob-col p_positive --k 100

    # Multi-class: rank by margin (top-1 - top-2) or entropy across prob cols
    python sample_uncertainty.py --input scored.parquet --out hardest.parquet \\
        --prob-cols p_a p_b p_c --method margin --k 100

    # Diversity-aware: after uncertainty-ranking, dedupe near-duplicates by a
    # pre-computed embedding column (1-D array per row). Uses simple greedy
    # max-min on cosine distance — not as strong as BADGE but a cheap guard
    # against batch redundancy.
    python sample_uncertainty.py --input scored.parquet --out hardest.parquet \\
        --prob-col p_positive --k 100 --diversity-col embedding --diversity-mult 3

Methods (multi-class)
---------------------
    margin   : 1 - (top1 - top2). Higher = more uncertain.
    entropy  : -sum(p log p). Higher = more uncertain.
    leastconf: 1 - max(p). Higher = more uncertain.

Cold-start warning
------------------
Do not run uncertainty sampling before you have a model that at least beats
random. Early-training uncertainty is largely noise and will concentrate
labels in an uninformative region. Seed with stratified or random first.
"""

import argparse
import sys
from pathlib import Path

import numpy as np
import pandas as pd


def read_any(path: Path) -> pd.DataFrame:
    if path.suffix == ".parquet":
        return pd.read_parquet(path)
    if path.suffix == ".csv":
        return pd.read_csv(path)
    sys.exit(f"Unsupported: {path.suffix}")


def write_any(df: pd.DataFrame, path: Path):
    if path.suffix == ".parquet":
        df.to_parquet(path, index=False)
    elif path.suffix == ".csv":
        df.to_csv(path, index=False)
    else:
        sys.exit(f"Unsupported: {path.suffix}")


def score_binary(p: np.ndarray) -> np.ndarray:
    return 1.0 - 2.0 * np.abs(p - 0.5)  # 1 at p=0.5, 0 at p=0 or 1


def score_multi(P: np.ndarray, method: str) -> np.ndarray:
    eps = 1e-12
    if method == "entropy":
        return -np.sum(P * np.log(P + eps), axis=1)
    if method == "leastconf":
        return 1.0 - np.max(P, axis=1)
    if method == "margin":
        sorted_P = np.sort(P, axis=1)
        return 1.0 - (sorted_P[:, -1] - sorted_P[:, -2])
    sys.exit(f"Unknown method: {method}")


def cosine_distance_matrix(X: np.ndarray) -> np.ndarray:
    norm = np.linalg.norm(X, axis=1, keepdims=True)
    norm = np.where(norm == 0, 1, norm)
    Xn = X / norm
    return 1.0 - Xn @ Xn.T


def greedy_diverse(scores: np.ndarray, X: np.ndarray, k: int) -> list[int]:
    """Greedy max-min diversity on pre-ranked candidates.

    Pick highest-scored first, then iteratively pick the candidate that
    maximizes min(cosine_distance to already-picked).
    """
    order = np.argsort(-scores)
    picked = [int(order[0])]
    remaining = list(order[1:])
    D = cosine_distance_matrix(X)
    while len(picked) < k and remaining:
        best_idx, best_val = None, -1.0
        for cand in remaining:
            d = min(D[cand, p] for p in picked)
            if d > best_val:
                best_val = d
                best_idx = cand
        picked.append(int(best_idx))
        remaining.remove(best_idx)
    return picked


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--prob-col", help="Single probability column (binary).")
    ap.add_argument("--prob-cols", nargs="+", help="Multiple probability columns (multi-class).")
    ap.add_argument("--method", choices=["margin", "entropy", "leastconf"], default="margin",
                    help="Uncertainty method for multi-class (default: margin).")
    ap.add_argument("--k", type=int, required=True)
    ap.add_argument("--diversity-col", default=None,
                    help="Column with per-row embedding (list/array). Enables greedy diversity.")
    ap.add_argument("--diversity-mult", type=int, default=3,
                    help="Candidate pool = k * this, before diversity reranking.")
    args = ap.parse_args()

    df = read_any(Path(args.input))

    if args.prob_col and args.prob_cols:
        sys.exit("Provide --prob-col OR --prob-cols, not both.")
    if args.prob_col:
        if args.prob_col not in df.columns:
            sys.exit(f"Missing column: {args.prob_col}")
        scores = score_binary(df[args.prob_col].to_numpy(dtype=float))
    elif args.prob_cols:
        for c in args.prob_cols:
            if c not in df.columns:
                sys.exit(f"Missing column: {c}")
        P = df[args.prob_cols].to_numpy(dtype=float)
        scores = score_multi(P, args.method)
    else:
        sys.exit("Provide --prob-col or --prob-cols.")

    if args.diversity_col:
        if args.diversity_col not in df.columns:
            sys.exit(f"Missing column: {args.diversity_col}")
        pool_size = min(len(df), args.k * args.diversity_mult)
        top_idx = np.argsort(-scores)[:pool_size]
        X = np.stack([np.asarray(v, dtype=float) for v in df[args.diversity_col].iloc[top_idx]])
        picked_local = greedy_diverse(scores[top_idx], X, args.k)
        picked = top_idx[picked_local]
    else:
        picked = np.argsort(-scores)[:args.k]

    out = df.iloc[picked].copy()
    out["uncertainty"] = scores[picked]
    write_any(out, Path(args.out))
    print(f"Selected {len(out)} most-uncertain rows → {args.out}")
    print(f"  uncertainty range: {out['uncertainty'].min():.3f}–{out['uncertainty'].max():.3f}")


if __name__ == "__main__":
    main()
