#!/usr/bin/env python3
"""
Evaluate a pre-labeler (LLM, rule, weak classifier) against gold labels.

Prints confusion matrix, precision / recall / F1, accuracy, and Cohen's
kappa. Works for binary labels.

Usage
-----
    python eval_prelabeler.py --input labeled.parquet \\
        --gold-col label --pred-col llm_label

    # Restrict to rows where gold exists (flagged/skipped excluded)
    python eval_prelabeler.py --input labeled.parquet \\
        --gold-col label --pred-col llm_label --drop-na
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


def cohen_kappa(y_true, y_pred):
    """Cohen's kappa for binary 0/1 labels."""
    if len(y_true) == 0:
        return float("nan")
    po = sum(1 for a, b in zip(y_true, y_pred) if a == b) / len(y_true)
    p_pos = sum(y_true) / len(y_true)
    q_pos = sum(y_pred) / len(y_pred)
    pe = p_pos * q_pos + (1 - p_pos) * (1 - q_pos)
    if pe == 1:
        return float("nan")
    return (po - pe) / (1 - pe)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True)
    ap.add_argument("--gold-col", required=True)
    ap.add_argument("--pred-col", required=True)
    ap.add_argument("--drop-na", action="store_true",
                    help="Drop rows where gold or pred is NA.")
    args = ap.parse_args()

    df = read_any(Path(args.input))
    for c in [args.gold_col, args.pred_col]:
        if c not in df.columns:
            sys.exit(f"Missing column: {c}")

    mask = df[args.gold_col].notna() & df[args.pred_col].notna()
    if args.drop_na:
        df = df[mask]
    elif not mask.all():
        n_drop = int((~mask).sum())
        print(f"Warning: {n_drop} rows have NA in gold or pred. Use --drop-na to skip.",
              file=sys.stderr)
        df = df[mask]

    y_true = df[args.gold_col].astype(int).tolist()
    y_pred = df[args.pred_col].astype(int).tolist()
    n = len(y_true)
    if n == 0:
        sys.exit("No comparable rows.")

    tp = sum(1 for a, b in zip(y_true, y_pred) if a == 1 and b == 1)
    fp = sum(1 for a, b in zip(y_true, y_pred) if a == 0 and b == 1)
    tn = sum(1 for a, b in zip(y_true, y_pred) if a == 0 and b == 0)
    fn = sum(1 for a, b in zip(y_true, y_pred) if a == 1 and b == 0)

    acc = (tp + tn) / n
    prec = tp / (tp + fp) if (tp + fp) else float("nan")
    rec = tp / (tp + fn) if (tp + fn) else float("nan")
    f1 = (2 * prec * rec / (prec + rec)) if (prec + rec) else float("nan")
    kappa = cohen_kappa(y_true, y_pred)

    print(f"N = {n}")
    print(f"               pred=0   pred=1")
    print(f"  gold=0       {tn:6d}   {fp:6d}")
    print(f"  gold=1       {fn:6d}   {tp:6d}")
    print()
    print(f"  accuracy  = {acc:.3f}")
    print(f"  precision = {prec:.3f}   (pred=1)")
    print(f"  recall    = {rec:.3f}   (pred=1)")
    print(f"  F1        = {f1:.3f}")
    print(f"  kappa     = {kappa:.3f}")
    print()
    if kappa < 0.667:
        print("  [kappa below 0.667 — Krippendorff's threshold for tentative use]")
    elif kappa < 0.80:
        print("  [kappa in 0.667–0.80 — tentative use only]")
    else:
        print("  [kappa ≥ 0.80 — suitable for reliable use]")


if __name__ == "__main__":
    main()
