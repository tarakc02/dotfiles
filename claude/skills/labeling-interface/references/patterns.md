# Interface patterns

A catalog of interface shapes for adhoc labeling, with tradeoffs and short
vignettes. Pick the shape that fits the *decision grain* and the *evidence
medium*, then adapt a template or write fresh.

## Binary text-classification TUI (the default pattern)

**Use when.** The unit is a chunk of text (document, paragraph, sentence)
and the label is one of two categories. Throughput matters (hundreds to
low thousands of items). LLM or rule pre-labels exist or are cheap to get.

**Shape.** One item at a time, full-screen terminal. Header shows progress
and the question. Text body wraps. Keyboard shortcuts: y/n to label, s to
accept pre-label, u to undo, j/k to navigate, f to flag. SQLite as working
state, parquet/csv as I/O.

**Template.** `assets/tui-template/label.py`.

**Vignette.** Labeling 500 police reports for whether they describe a
specific tactical pattern. Pre-labeled by an LLM. Labeler confirms or
overrides with y/n; flags weird edge cases. ~30 items/minute after warmup.

---

## Decomposed multi-class

**Use when.** The schema has 3+ mutually exclusive categories, OR the
schema has multiple non-exclusive tags. A single N-way menu is slower and
more error-prone than a sequence of y/n questions.

**Shape — exclusive N-way.** Run the binary TUI once per category, in
priority order. The label column becomes `is_category_A` → `is_category_B`
→ ... Mark the residual (everything labeled "no" across all passes) as
"other". An LLM pre-labels each pass.

**Shape — multi-label (non-exclusive).** Same as above, but each pass is
independent; an item can be labeled yes across multiple passes.

**Pitfall.** If the categories are subtle and overlap, binary decomposition
hides the overlap from the annotator. For schema calibration, use a
multi-select UI (spreadsheet mode works well) for the first ~50 items,
then switch to binary decomposition once the schema is stable.

**Vignette.** Classifying social media posts as {threat, insult, satire,
benign}. First pass: "is this a threat?" Second pass on remaining:
"is this an insult?" Third on remaining: "is this satire?" Everything
else → benign. ~4x the keystrokes per item but 2x the throughput of
4-way mouse-menu labeling because decisions are trivially binary.

---

## Span / extraction (character- or token-level)

**Use when.** The unit of labeling is a span inside a document — named
entity, event trigger, clause boundary, quote attribution.

**Key difference from classification.** Annotator must (a) read the whole
document (recall matters), (b) select a span precisely (boundary disputes
matter), (c) distinguish "no spans" from "skipped" (an affirmative "none"
action is mandatory).

**Shape options.**
- **Pre-highlighted + confirm/edit.** A weak model or regex proposes
  candidate spans; annotator confirms, rejects, or adjusts boundaries.
  Fastest when the weak model has decent recall. Anchoring risk: the
  annotator may miss spans the model didn't propose.
- **Fresh selection.** Annotator selects spans from the raw text. Slower,
  no anchoring. Usually requires a web UI with mouse selection.
- **Question-per-span.** Decompose: "is 'X' in this document a named
  entity of type Y?" — a binary stream, like the classification pattern,
  but the spans come from a pre-extractor (regex, NER model, gazetteer).

**Agreement metric.** Span-level F1 with a matching rule (exact, overlap,
or head-match). **Do not** use token-level kappa — the "O" class dominates.

**Vignette.** Extracting named people from court documents. Pre-extractor:
spaCy NER + a person-name gazetteer. Interface: the binary TUI pattern, one
question per candidate span. A final pass on a sample of documents checks
for false negatives (spans the pre-extractor missed) — usually a web UI
with the document and highlighted found-spans, "missed any?" prompt.

---

## Spreadsheet (CSV in Excel / Sheets / LibreOffice)

**Use when.** Texts are short (name, address, tweet, single sentence) and
the labeler benefits from seeing many rows at once for calibration. Also
good for multi-column label schemas (e.g. "type" + "severity" + "notes"
filled in one row).

**Shape.** Generate a CSV with the `label` column first, `text` next, then
context columns. Pre-label column pre-fills `label`. Labeler edits in
their spreadsheet tool, saves, runs a merge script to join back.

**Template.** `assets/spreadsheet-template/spreadsheet.py`.

**Pitfall.** Spreadsheets tempt the labeler into free-text labels.
Constrain the label column to a finite vocabulary via data validation in
the spreadsheet, and reject unparseable values during merge.

**Vignette.** Labeling 300 business names as {nonprofit, government,
private, unknown}. Spreadsheet shows 30 rows at a time; labeler notices
patterns ("all names ending in 'Foundation' are nonprofits") and speeds
through.

---

## Web viewer (for images / PDFs / scans)

**Use when.** The evidence is not pure text — scans, photos, form images,
documents where layout matters. A TUI cannot render these.

**Shape.** A minimal local web app (Streamlit, Gradio, Flask). One item
per page, image viewer on one side, keyboard shortcuts bound to label
buttons on the other. SQLite for working state, same as TUI. Keep it
minimal — this is ephemeral, not a product.

**Minimal Streamlit recipe (write fresh per task, don't generalize too
early):**

```python
import sqlite3, streamlit as st, pandas as pd
from pathlib import Path

df = pd.read_parquet("sample.parquet")
conn = sqlite3.connect("labels.db")
conn.execute("CREATE TABLE IF NOT EXISTS labels (id TEXT PRIMARY KEY, label INTEGER)")

if "i" not in st.session_state:
    st.session_state.i = 0

row = df.iloc[st.session_state.i]
st.image(row["image_path"])
st.write(row["metadata"])

col1, col2, col3 = st.columns(3)
if col1.button("Yes (y)"):
    conn.execute("INSERT OR REPLACE INTO labels VALUES (?,?)", (row["id"], 1))
    conn.commit()
    st.session_state.i += 1
    st.rerun()
if col2.button("No (n)"):
    conn.execute("INSERT OR REPLACE INTO labels VALUES (?,?)", (row["id"], 0))
    conn.commit()
    st.session_state.i += 1
    st.rerun()
if col3.button("Flag"):
    st.session_state.i += 1
    st.rerun()

st.progress(st.session_state.i / len(df))
```

Streamlit doesn't support true hotkeys without a component; on Mac/Linux
`tab`-to-button + space is usually good enough. For hotkey-critical
workflows, Gradio or a custom HTML page is better.

**Vignette.** Labeling ~400 scanned invoices as {complete, partial,
unreadable}. Streamlit viewer with the image left, three buttons right.
~8 items/minute — slower than text-only because reading the scan itself
takes time, but much faster than opening files one at a time.

---

## Weak-supervision / labeling-functions (alternative to per-example labeling)

**Use when.** You have a large unlabeled pool, and the schema can be
expressed as a handful of rules: keyword regexes, metadata heuristics,
distant-supervision lookups, patterns over a parsed dependency tree.

**Shape.** Write 5–20 labeling functions (small Python functions that
return `1`, `0`, or abstain), apply to the pool, aggregate with a label
model (Snorkel, or a hand-rolled majority-vote with coverage weights).
Humans spot-check the result on a labeled sample, adjudicate the
LF-disagreement cases, iterate on the LFs.

**When this wins over per-example labeling.** High-volume tasks where
rules capture most of the pool, and the remaining tail is small enough to
label by hand.

**When this loses.** Tasks where the decision is genuinely subjective or
where rules have low coverage — you end up writing and debugging LFs that
are as hard as labeling, and the rare/interesting cases are in the
uncovered tail.

**This skill does not ship a Snorkel template.** The pattern is usually
written fresh with a handful of `def lf_xxx(row): ...` functions, applied
with `df.apply`. Combine with the binary TUI to adjudicate disagreements.

---

## Which pattern? A short decision tree

```
What's the evidence medium?
├─ Text only
│   ├─ Short (a sentence, a name) AND many items fit on screen?
│   │   → spreadsheet
│   └─ Longer text OR need highlighting / context?
│       ├─ Binary (or decomposable)? → TUI (tui-template)
│       └─ Extraction (spans)?
│           ├─ Web selection tolerable? → web UI with span tool
│           └─ Can pre-extract candidates? → TUI as per-span y/n stream
└─ Image / PDF / scan?
    → web viewer (Streamlit or Gradio, write fresh)

Is most of the pool well-covered by simple rules?
    → weak supervision + human adjudication on disagreements
```
