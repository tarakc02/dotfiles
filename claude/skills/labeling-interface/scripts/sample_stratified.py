#!/usr/bin/env python3
"""
Stratified sampling.

Takes a dataset, groups by one or more stratum columns, and samples a fixed
number per stratum (equal allocation) or a share proportional to stratum size.

Usage
-----
    # 20 per stratum (equal allocation — good for seeing variation)
    python sample_stratified.py --input data.parquet --out sample.parquet \\
        --by predicted_class --n-per-stratum 20

    # Proportional sample of total size 200
    python sample_stratified.py --input data.parquet --out sample.parquet \\
        --by source region --n-total 200 --proportional

    # Stratify by a binned numeric column (quartiles)
    python sample_stratified.py --input data.parquet --out sample.parquet \\
        --by-bin score:4 --n-per-stratum 25

Notes
-----
Equal allocation is the default because adhoc labeling usually wants to see
variation across strata, not a representative sample. Use --proportional when
you need the sample distribution to match the population.
"""

import argparse
import sys
from pathlib import Path

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


def apply_bins(df: pd.DataFrame, bin_specs: list[str]) -> tuple[pd.DataFrame, list[str]]:
    """Convert --by-bin specs like 'score:4' into a new column 'score_bin'."""
    out_cols = []
    for spec in bin_specs:
        if ":" not in spec:
            sys.exit(f"--by-bin expects 'col:n_bins', got {spec!r}")
        col, n_str = spec.rsplit(":", 1)
        try:
            n = int(n_str)
        except ValueError:
            sys.exit(f"--by-bin n must be int, got {n_str!r}")
        if col not in df.columns:
            sys.exit(f"--by-bin column not found: {col}")
        new_col = f"{col}_bin"
        df[new_col] = pd.qcut(df[col], q=n, labels=False, duplicates="drop")
        out_cols.append(new_col)
    return df, out_cols


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--by", nargs="+", default=[], help="Stratum columns (categorical).")
    ap.add_argument("--by-bin", nargs="+", default=[],
                    help="Numeric cols to bin, as 'col:n_bins'. Adds <col>_bin.")
    ap.add_argument("--n-per-stratum", type=int, default=None,
                    help="Equal allocation: N per stratum.")
    ap.add_argument("--n-total", type=int, default=None,
                    help="Total size (required when --proportional).")
    ap.add_argument("--proportional", action="store_true",
                    help="Proportional allocation (requires --n-total).")
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--replace", action="store_true",
                    help="Sample with replacement if stratum is smaller than quota.")
    args = ap.parse_args()

    df = read_any(Path(args.input))
    df, binned = apply_bins(df, args.by_bin)
    strat_cols = list(args.by) + binned
    if not strat_cols:
        sys.exit("Provide --by and/or --by-bin.")

    for c in strat_cols:
        if c not in df.columns:
            sys.exit(f"Stratum column not found: {c}")

    rng_seed = args.seed
    groups = df.groupby(strat_cols, dropna=False, sort=False)

    pieces = []
    if args.proportional:
        if args.n_total is None:
            sys.exit("--proportional requires --n-total")
        total = len(df)
        for key, g in groups:
            frac = len(g) / total
            n = max(1, round(args.n_total * frac))
            n = min(n, len(g)) if not args.replace else n
            pieces.append(g.sample(n=n, random_state=rng_seed, replace=args.replace))
            rng_seed += 1
    else:
        if args.n_per_stratum is None:
            sys.exit("Provide --n-per-stratum or --proportional+--n-total")
        for key, g in groups:
            n = args.n_per_stratum if args.replace else min(args.n_per_stratum, len(g))
            pieces.append(g.sample(n=n, random_state=rng_seed, replace=args.replace))
            rng_seed += 1

    out = pd.concat(pieces, ignore_index=True)
    write_any(out, Path(args.out))
    print(f"Sampled {len(out)} rows across {len(pieces)} strata → {args.out}")
    counts = out.groupby(strat_cols, dropna=False).size().reset_index(name="n")
    print(counts.to_string(index=False))


if __name__ == "__main__":
    main()
