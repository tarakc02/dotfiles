#!/usr/bin/env python3
"""
Spreadsheet labeling template
=============================
For tasks where the text is short enough that many rows fit on screen,
and the labeler prefers a spreadsheet app (Excel, Numbers, LibreOffice, Google
Sheets) over a terminal UI.

Usage
-----
    # Step 1: prepare a CSV optimized for labeling.
    python spreadsheet.py prepare --input data.parquet --out to-label.csv

    # Step 2: open to-label.csv in a spreadsheet app, fill in the `label`
    # column (1/0 or y/n), optionally add notes in the `notes` column, save.

    # Step 3: merge labels back into the source dataset.
    python spreadsheet.py merge --source data.parquet --labeled to-label.csv --out labeled.parquet

Customization
-------------
Edit CONFIG below. The column order is chosen so the labeler sees the label
column first, then the evidence, then any context — put the label decision
one cell away from the evidence to minimize eye movement.

When to use
-----------
Good for: short texts (a tweet, an address, a company name), tabular fields,
multi-column label schemas, and when the labeler wants to see many rows at once
to calibrate.

Bad for: long texts (scroll-heavy), span labeling, image/PDF review.
"""

import argparse
import sys
from pathlib import Path

import pandas as pd


# ──────────────────────────────────────────────────────────────────────────────
# CONFIG
# ──────────────────────────────────────────────────────────────────────────────

ID_COL = "id"
TEXT_COL = "text"
PRELABEL_COL = None  # e.g. "llm_prediction"
METADATA_COLS = []   # e.g. ["date", "source"]

# Column order in the labeling CSV. Put `label` first so it's the leftmost
# cell on screen next to the evidence — minimizes eye travel.
# The label column starts blank (or pre-filled from PRELABEL_COL).
LABEL_COL_OUT = "label"
NOTES_COL_OUT = "notes"

# ──────────────────────────────────────────────────────────────────────────────


def read_any(path: Path) -> pd.DataFrame:
    if path.suffix == ".parquet":
        return pd.read_parquet(path)
    if path.suffix == ".csv":
        return pd.read_csv(path)
    sys.exit(f"Unsupported format: {path.suffix}")


def write_any(df: pd.DataFrame, path: Path):
    if path.suffix == ".parquet":
        df.to_parquet(path, index=False)
    elif path.suffix == ".csv":
        df.to_csv(path, index=False)
    else:
        sys.exit(f"Unsupported format: {path.suffix}")


def prepare(args):
    df = read_any(Path(args.input))
    for col in [ID_COL, TEXT_COL]:
        if col not in df.columns:
            sys.exit(f"Missing column: {col}")

    out = pd.DataFrame()
    out[LABEL_COL_OUT] = (
        df[PRELABEL_COL].apply(lambda v: int(bool(v)) if pd.notna(v) else "")
        if PRELABEL_COL and PRELABEL_COL in df.columns
        else ""
    )
    out[NOTES_COL_OUT] = ""
    out[ID_COL] = df[ID_COL]
    out[TEXT_COL] = df[TEXT_COL]
    for col in METADATA_COLS:
        if col in df.columns:
            out[col] = df[col]

    write_any(out, Path(args.out))
    n = len(out)
    n_pre = int((out[LABEL_COL_OUT] != "").sum()) if PRELABEL_COL else 0
    print(f"Wrote {n} rows to {args.out}")
    if n_pre:
        print(f"  {n_pre} pre-filled from {PRELABEL_COL} — review and correct")
    print(f"  Open, fill `{LABEL_COL_OUT}` (1/0 or y/n/blank), save, then run `merge`")


def _parse_label(v):
    if pd.isna(v) or v == "":
        return None
    s = str(v).strip().lower()
    if s in ("1", "y", "yes", "true", "t"):
        return 1
    if s in ("0", "n", "no", "false", "f"):
        return 0
    return None


def merge(args):
    src = read_any(Path(args.source))
    lab = read_any(Path(args.labeled))
    if ID_COL not in lab.columns:
        sys.exit(f"Labeled file missing {ID_COL}")
    if LABEL_COL_OUT not in lab.columns:
        sys.exit(f"Labeled file missing {LABEL_COL_OUT}")

    lab = lab[[ID_COL, LABEL_COL_OUT] + ([NOTES_COL_OUT] if NOTES_COL_OUT in lab.columns else [])]
    lab[LABEL_COL_OUT] = lab[LABEL_COL_OUT].apply(_parse_label)

    # Drop overlapping columns from src so the labeled version wins cleanly.
    drop_cols = [c for c in [LABEL_COL_OUT, NOTES_COL_OUT] if c in src.columns]
    if drop_cols:
        src = src.drop(columns=drop_cols)
    merged = src.merge(lab, on=ID_COL, how="left")
    write_any(merged, Path(args.out))
    n = len(merged)
    labeled = int(merged[LABEL_COL_OUT].notna().sum())
    print(f"Wrote {n} rows to {args.out}   ({labeled} labeled)")


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("prepare")
    p.add_argument("--input", required=True)
    p.add_argument("--out", required=True)
    p.set_defaults(func=prepare)

    m = sub.add_parser("merge")
    m.add_argument("--source", required=True)
    m.add_argument("--labeled", required=True)
    m.add_argument("--out", required=True)
    m.set_defaults(func=merge)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
