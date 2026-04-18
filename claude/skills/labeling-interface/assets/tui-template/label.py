#!/usr/bin/env python3
"""
Text-UI labeling template
=========================
A keyboard-driven, curses-based labeler for binary document classification
with optional pre-labels. Adapted per task by editing the CONFIG block below.

Usage
-----
    python label.py --input data.parquet
    python label.py --input data.csv --db labels.db --out labeled.parquet

Keys
----
    y / 1    → label YES
    n / 0    → label NO
    s        → skip (if pre-label exists, accept it; else leave unlabeled)
    f        → flag for review (label as None, reviewed=2)
    u        → undo last action
    j / ↓    → next
    k / ↑    → previous
    r        → jump to first unlabeled
    ? / h    → toggle help
    q        → quit (exports result)

Customization
-------------
Edit the CONFIG block below. Most tasks only need to change column names,
highlight patterns, and the label question.

For multi-class tasks: run this tool once per category with a different
PRELABEL_COL and LABEL_QUESTION. Decomposing N-way into N binary passes is
faster and more accurate than a single N-way interface.

Dependencies
------------
    pandas (for parquet/CSV I/O)
    pyarrow (for parquet; pip install pyarrow)
    curses (stdlib)
"""

import argparse
import curses
import re
import sqlite3
import sys
import textwrap
from pathlib import Path

import pandas as pd


# ──────────────────────────────────────────────────────────────────────────────
# CONFIG — edit these for your task
# ──────────────────────────────────────────────────────────────────────────────

# Column names in the input dataframe.
ID_COL = "id"
TEXT_COL = "text"

# Optional: set to None if no pre-labels. Pre-label values must be 0/1/True/False.
PRELABEL_COL = None  # e.g. "llm_prediction"

# Additional columns shown in the metadata line above the text. Keep short.
METADATA_COLS = []  # e.g. ["date", "source", "author"]

# Strings (or regex patterns) to highlight in the text. Empty list = no highlighting.
# NOTE: highlighting anchors the annotator — if a keyword is not reliable evidence
# of the positive class, it will bias judgments. Prefer highlighting only when
# you've confirmed the keywords are strong features.
HIGHLIGHT_KEYWORDS = []  # e.g. ["binoculars", "surveillance"]

# The label question shown in the header. Keep it short.
LABEL_QUESTION = "Label this example"

# Names for the two labels (shown in UI). Values stored in DB are always 1/0.
YES_NAME = "YES"
NO_NAME = "NO"

# Sort order when opening. Options: "prelabel_desc" (positives first),
# "prelabel_asc", "random", "original".
SORT_ORDER = "original"

# ──────────────────────────────────────────────────────────────────────────────
# End CONFIG. Below here, you generally shouldn't need to change anything
# unless you want to add a new action (e.g. a third label, a notes field).
# ──────────────────────────────────────────────────────────────────────────────


def _compile_highlight_pattern(keywords):
    if not keywords:
        return None
    return re.compile(r"(" + "|".join(re.escape(k) for k in keywords) + r")", re.IGNORECASE)


_KW_PATTERN = _compile_highlight_pattern(HIGHLIGHT_KEYWORDS)


# ── DB ────────────────────────────────────────────────────────────────────────

def init_db(db_path: str, df: pd.DataFrame) -> sqlite3.Connection:
    conn = sqlite3.connect(db_path)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS labels (
            id        TEXT PRIMARY KEY,
            predicted INTEGER,
            label     INTEGER,       -- NULL = not yet labeled, or flagged
            reviewed  INTEGER DEFAULT 0,  -- 0=no, 1=yes, 2=flagged
            review_ts TEXT DEFAULT (datetime('now'))
        )
    """)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS history (
            id_pk     INTEGER PRIMARY KEY AUTOINCREMENT,
            id        TEXT,
            label     INTEGER,
            reviewed  INTEGER,
            ts        TEXT DEFAULT (datetime('now'))
        )
    """)
    conn.commit()

    existing = {r[0] for r in conn.execute("SELECT id FROM labels")}
    rows = []
    for _, row in df.iterrows():
        rid = str(row[ID_COL])
        if rid in existing:
            continue
        pred = None
        if PRELABEL_COL and PRELABEL_COL in df.columns and pd.notna(row[PRELABEL_COL]):
            pred = int(bool(row[PRELABEL_COL]))
        rows.append((rid, pred, None, 0))
    if rows:
        conn.executemany(
            "INSERT INTO labels (id, predicted, label, reviewed) VALUES (?,?,?,?)",
            rows,
        )
        conn.commit()
    return conn


def save_label(conn, rid, label, reviewed):
    conn.execute(
        "UPDATE labels SET label=?, reviewed=?, review_ts=datetime('now') WHERE id=?",
        (label, reviewed, str(rid)),
    )
    conn.execute(
        "INSERT INTO history (id, label, reviewed) VALUES (?,?,?)",
        (str(rid), label, reviewed),
    )
    conn.commit()


def get_labels(conn) -> dict:
    rows = conn.execute("SELECT id, label, reviewed FROM labels").fetchall()
    return {r[0]: {"label": r[1], "reviewed": r[2]} for r in rows}


def undo_last(conn):
    row = conn.execute(
        "SELECT id_pk, id FROM history ORDER BY id_pk DESC LIMIT 1"
    ).fetchone()
    if not row:
        return None
    pk, rid = row
    conn.execute("DELETE FROM history WHERE id_pk=?", (pk,))
    prior = conn.execute(
        "SELECT label, reviewed FROM history WHERE id=? ORDER BY id_pk DESC LIMIT 1",
        (rid,),
    ).fetchone()
    if prior:
        label, reviewed = prior
    else:
        label, reviewed = None, 0
    conn.execute(
        "UPDATE labels SET label=?, reviewed=?, review_ts=datetime('now') WHERE id=?",
        (label, reviewed, rid),
    )
    conn.commit()
    return rid


# ── TUI drawing ──────────────────────────────────────────────────────────────

HELP_TEXT = [
    f"  y / 1   → {YES_NAME}",
    f"  n / 0   → {NO_NAME}",
    "  s       → skip (accept pre-label if any)",
    "  f       → flag for review",
    "  u       → undo",
    "  j / ↓   → next",
    "  k / ↑   → prev",
    "  r       → first unlabeled",
    "  ? / h   → toggle this help",
    "  q       → quit (exports)",
]


def _addstr_highlighted(stdscr, y, x, text, max_w):
    """Write text with keyword highlighting, bounded by max_w."""
    if _KW_PATTERN is None:
        try:
            stdscr.addstr(y, x, text[:max_w])
        except curses.error:
            pass
        return
    parts = _KW_PATTERN.split(text)
    col = x
    for part in parts:
        if not part:
            continue
        remaining = max_w - (col - x)
        if remaining <= 0:
            break
        chunk = part[:remaining]
        try:
            if _KW_PATTERN.fullmatch(part):
                stdscr.attron(curses.color_pair(7) | curses.A_BOLD)
                stdscr.addstr(y, col, chunk)
                stdscr.attroff(curses.color_pair(7) | curses.A_BOLD)
            else:
                stdscr.addstr(y, col, chunk)
        except curses.error:
            pass
        col += len(chunk)


def progress_bar(done, total, width=24):
    filled = int(width * done / max(total, 1))
    bar = "█" * filled + "░" * (width - filled)
    pct = 100 * done / max(total, 1)
    return f"[{bar}] {done}/{total} ({pct:.0f}%)"


def draw(stdscr, df, idx, labels_map, show_help, status_msg):
    stdscr.erase()
    H, W = stdscr.getmaxyx()

    row = df.iloc[idx]
    rid = str(row[ID_COL])
    info = labels_map.get(rid, {})
    current_label = info.get("label")
    reviewed = info.get("reviewed", 0)

    predicted = None
    if PRELABEL_COL and PRELABEL_COL in df.columns and pd.notna(row[PRELABEL_COL]):
        predicted = int(bool(row[PRELABEL_COL]))

    done = sum(1 for v in labels_map.values() if v.get("reviewed"))
    total = len(df)

    # Header
    header = f" LABELER  [{idx+1}/{total}]  {progress_bar(done, total)}  {LABEL_QUESTION} "
    stdscr.attron(curses.color_pair(1) | curses.A_BOLD)
    stdscr.addstr(0, 0, header[:W].ljust(W))
    stdscr.attroff(curses.color_pair(1) | curses.A_BOLD)

    # Metadata line
    meta_parts = [f"{ID_COL}: {rid}"]
    for col in METADATA_COLS:
        if col in df.columns:
            val = row[col]
            if pd.notna(val):
                meta_parts.append(f"{col}: {val}")
    meta_line = "  ".join(meta_parts)
    try:
        stdscr.addstr(1, 0, meta_line[:W])
    except curses.error:
        pass

    # Label status line
    pred_str = ("—" if predicted is None else (YES_NAME if predicted == 1 else NO_NAME))
    if current_label == 1:
        label_str, label_color = YES_NAME, curses.color_pair(3)
    elif current_label == 0:
        label_str, label_color = NO_NAME, curses.color_pair(4)
    elif reviewed == 2:
        label_str, label_color = "FLAG", curses.color_pair(5)
    else:
        label_str, label_color = "—", curses.color_pair(5)
    status_line = f"  pre-label: {pred_str}    your label: "
    try:
        stdscr.addstr(2, 0, status_line)
        stdscr.attron(label_color | curses.A_BOLD)
        stdscr.addstr(label_str + ("  ✓" if reviewed else "  ·"))
        stdscr.attroff(label_color | curses.A_BOLD)
    except curses.error:
        pass

    # Divider
    stdscr.attron(curses.color_pair(6))
    try:
        stdscr.addstr(3, 0, "─" * W)
    except curses.error:
        pass
    stdscr.attroff(curses.color_pair(6))

    # Text body
    text = str(row[TEXT_COL]) if pd.notna(row[TEXT_COL]) else "(empty)"
    avail_lines = H - 7
    wrap_width = W - 2
    wrapped = []
    for para in text.splitlines():
        if para.strip():
            wrapped.extend(textwrap.wrap(para, wrap_width) or [""])
        else:
            wrapped.append("")

    if show_help:
        help_w = max(len(l) for l in HELP_TEXT) + 4
        help_x = max(0, W - help_w - 2)
        for i, line in enumerate(HELP_TEXT[:avail_lines]):
            try:
                stdscr.attron(curses.color_pair(1))
                stdscr.addstr(4 + i, help_x, f"  {line:<{help_w}}")
                stdscr.attroff(curses.color_pair(1))
            except curses.error:
                pass
        text_w = help_x - 2
    else:
        text_w = wrap_width

    for i, line in enumerate(wrapped[:avail_lines]):
        _addstr_highlighted(stdscr, 4 + i, 1, line, text_w)

    # Footer divider
    stdscr.attron(curses.color_pair(6))
    try:
        stdscr.addstr(H - 4, 0, "─" * W)
    except curses.error:
        pass
    stdscr.attroff(curses.color_pair(6))

    if status_msg:
        stdscr.attron(curses.color_pair(5) | curses.A_BOLD)
        try:
            stdscr.addstr(H - 3, 1, status_msg[:W - 2])
        except curses.error:
            pass
        stdscr.attroff(curses.color_pair(5) | curses.A_BOLD)

    keys = f" y={YES_NAME}  n={NO_NAME}  s=skip  f=flag  u=undo  j/k=nav  r=first-unlabeled  ?=help  q=quit "
    stdscr.attron(curses.color_pair(2))
    try:
        stdscr.addstr(H - 2, 0, keys[:W].ljust(W))
    except curses.error:
        pass
    stdscr.attroff(curses.color_pair(2))

    stdscr.refresh()


def first_unlabeled(df, labels_map):
    for i in range(len(df)):
        rid = str(df.iloc[i][ID_COL])
        if not labels_map.get(rid, {}).get("reviewed"):
            return i
    return len(df) - 1


def main_loop(stdscr, df, conn):
    curses.curs_set(0)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_CYAN)    # header
    curses.init_pair(2, curses.COLOR_BLACK, curses.COLOR_WHITE)   # footer
    curses.init_pair(3, curses.COLOR_GREEN, -1)                   # yes
    curses.init_pair(4, curses.COLOR_RED, -1)                     # no
    curses.init_pair(5, curses.COLOR_YELLOW, -1)                  # neutral/status
    curses.init_pair(6, curses.COLOR_CYAN, -1)                    # divider
    curses.init_pair(7, curses.COLOR_MAGENTA, -1)                 # highlights

    labels_map = get_labels(conn)
    idx = first_unlabeled(df, labels_map)
    show_help = False
    status_msg = ""

    while True:
        draw(stdscr, df, idx, labels_map, show_help, status_msg)
        status_msg = ""
        key = stdscr.getch()
        rid = str(df.iloc[idx][ID_COL])

        if key in (ord('q'), ord('Q')):
            break

        elif key in (ord('y'), ord('Y'), ord('1')):
            save_label(conn, rid, 1, 1)
            labels_map[rid] = {"label": 1, "reviewed": 1}
            status_msg = f"✓ {rid} → {YES_NAME}"
            idx = min(idx + 1, len(df) - 1)

        elif key in (ord('n'), ord('N'), ord('0')):
            save_label(conn, rid, 0, 1)
            labels_map[rid] = {"label": 0, "reviewed": 1}
            status_msg = f"✓ {rid} → {NO_NAME}"
            idx = min(idx + 1, len(df) - 1)

        elif key in (ord('s'), ord('S')):
            # Accept pre-label if present; otherwise mark unlabeled+skipped (no progress).
            predicted = None
            if PRELABEL_COL and PRELABEL_COL in df.columns:
                val = df.iloc[idx][PRELABEL_COL]
                if pd.notna(val):
                    predicted = int(bool(val))
            if predicted is not None:
                save_label(conn, rid, predicted, 1)
                labels_map[rid] = {"label": predicted, "reviewed": 1}
                name = YES_NAME if predicted == 1 else NO_NAME
                status_msg = f"→ {rid} accepted pre-label: {name}"
                idx = min(idx + 1, len(df) - 1)
            else:
                status_msg = "No pre-label to skip with; use j to move without labeling"

        elif key in (ord('f'), ord('F')):
            save_label(conn, rid, None, 2)
            labels_map[rid] = {"label": None, "reviewed": 2}
            status_msg = f"⚑ {rid} flagged"
            idx = min(idx + 1, len(df) - 1)

        elif key in (ord('u'), ord('U')):
            restored = undo_last(conn)
            if restored:
                labels_map = get_labels(conn)
                for i in range(len(df)):
                    if str(df.iloc[i][ID_COL]) == restored:
                        idx = i
                        break
                status_msg = f"↩ undid {restored}"
            else:
                status_msg = "nothing to undo"

        elif key in (ord('j'), curses.KEY_DOWN):
            idx = min(idx + 1, len(df) - 1)

        elif key in (ord('k'), curses.KEY_UP):
            idx = max(idx - 1, 0)

        elif key in (ord('r'), ord('R')):
            idx = first_unlabeled(df, labels_map)
            status_msg = "→ first unlabeled"

        elif key in (ord('?'), ord('h'), ord('H')):
            show_help = not show_help

    return get_labels(conn)


# ── I/O ───────────────────────────────────────────────────────────────────────

def read_input(path: Path) -> pd.DataFrame:
    if path.suffix == ".parquet":
        return pd.read_parquet(path)
    elif path.suffix == ".csv":
        return pd.read_csv(path)
    else:
        sys.exit(f"Unsupported input format: {path.suffix} (use .parquet or .csv)")


def write_output(df: pd.DataFrame, path: Path):
    if path.suffix == ".parquet":
        df.to_parquet(path, index=False)
    elif path.suffix == ".csv":
        df.to_csv(path, index=False)
    else:
        sys.exit(f"Unsupported output format: {path.suffix}")


def export_results(df: pd.DataFrame, labels_map: dict, out_path: Path):
    df = df.copy()
    df["label"] = df[ID_COL].astype(str).map(lambda r: labels_map.get(r, {}).get("label"))
    df["reviewed"] = df[ID_COL].astype(str).map(lambda r: labels_map.get(r, {}).get("reviewed", 0))
    write_output(df, out_path)
    total = len(df)
    reviewed = int((df["reviewed"] > 0).sum())
    labeled = int(df["label"].notna().sum())
    flagged = int((df["reviewed"] == 2).sum())
    print(f"Exported {total} rows to {out_path}")
    print(f"  reviewed: {reviewed}/{total}   labeled: {labeled}   flagged: {flagged}")
    if PRELABEL_COL and PRELABEL_COL in df.columns and labeled:
        m = df["label"].notna() & df[PRELABEL_COL].notna()
        if m.any():
            agree = int((df.loc[m, "label"] == df.loc[m, PRELABEL_COL].astype(int)).sum())
            n = int(m.sum())
            print(f"  agreement with pre-label: {agree}/{n} ({100*agree/n:.1f}%)")


def sort_df(df: pd.DataFrame) -> pd.DataFrame:
    if SORT_ORDER == "prelabel_desc" and PRELABEL_COL in df.columns:
        return df.sort_values(PRELABEL_COL, ascending=False).reset_index(drop=True)
    if SORT_ORDER == "prelabel_asc" and PRELABEL_COL in df.columns:
        return df.sort_values(PRELABEL_COL, ascending=True).reset_index(drop=True)
    if SORT_ORDER == "random":
        return df.sample(frac=1, random_state=0).reset_index(drop=True)
    return df.reset_index(drop=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True, help="Input .parquet or .csv")
    ap.add_argument("--db", default="labels.db", help="SQLite working state")
    ap.add_argument("--out", default=None, help="Output file; defaults to <input>-labeled.<ext>")
    args = ap.parse_args()

    in_path = Path(args.input)
    if not in_path.exists():
        sys.exit(f"Not found: {in_path}")

    df = read_input(in_path)
    for col in [ID_COL, TEXT_COL]:
        if col not in df.columns:
            sys.exit(f"Input is missing required column: {col!r}")
    df = sort_df(df)

    out_path = Path(args.out) if args.out else in_path.with_name(
        in_path.stem + "-labeled" + in_path.suffix
    )

    conn = init_db(args.db, df)
    labels_map = curses.wrapper(main_loop, df, conn)
    conn.close()
    export_results(df, labels_map, out_path)


if __name__ == "__main__":
    main()
