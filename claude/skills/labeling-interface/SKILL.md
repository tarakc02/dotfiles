---
name: labeling-interface
description: Design and build adhoc, ephemeral labeling/annotation interfaces for ML classification and extraction tasks. Use when the user wants to label or annotate a dataset, build a quick labeling tool, create ground-truth for a classifier, review LLM predictions, or run iterative labeling with active learning. Covers text-UI (curses), spreadsheet, and web-based interfaces, plus sampling (random, stratified, uncertainty), LLM pre-labeling, and pre-labeler evaluation.
---

# Labeling Interface

Build a throwaway labeling UI optimized for *this* task — fast to set up, fast to use, discarded when done. Do not build a generalizable tool. Every labeling task is a little different; lean on the patterns and templates here, but customize per task.

## Core principles

(These come from research; see `references/research.md` for evidence. Apply them without re-reading unless you hit a judgment call.)

1. **Binary-decompose when possible.** A stream of y/n decisions is faster and more accurate than an N-way menu. For multi-class, run binary passes in sequence.
2. **Model-in-the-loop (carefully).** LLM or rule pre-labels let the human correct rather than label from scratch. But pre-labels *anchor* — show them as a "skip = accept" action, not as the pre-filled answer.
3. **Keyboard-only for the hot path.** Every action in the labeling loop (label, skip, undo, navigate, flag) must be one keystroke.
4. **Highlight evidence, not answers.** Highlighting keywords can speed reading but biases judgments toward the highlighted evidence. Highlight only when the features are known-reliable.
5. **Show progress + pre-label agreement.** Keeps the labeler motivated and surfaces calibration problems.
6. **SQLite for working state, parquet/CSV for I/O.** Persistent, supports undo, no server.
7. **Easy undo + easy revision.** Data-centric labeling is iterative; make it cheap to change your mind.
8. **Explicit "no data" action for extraction tasks.** Distinguish "read, found nothing" from "skipped".
9. **Cold-start with random/stratified sampling.** Active learning fails on cold starts and imbalanced classes. Seed first.
10. **Flag, don't slide.** A single "flag for review" action beats confidence sliders, which annotators collapse to extremes.

## Workflow

### Step 1: Understand the task

Before writing code, ask the user — whichever of these are unclear:

- **What are you classifying or extracting?** (document classification, span extraction, image review, …)
- **What are the categories / output schema?**
- **Is the data sensitive?** This gates LLM pre-labeling choice (local vs. API).
- **How many items need labeling?** (dozens, hundreds, thousands?)
- **What format is the input?** (parquet, CSV, jsonl, folder of images/PDFs?)
- **Is there any existing signal?** (pre-labels, predictions, probabilities, regex patterns?)
- **Who's labeling?** (user alone, a collaborator, a team?) — affects single-vs-double annotation.

Do not skip the sensitive-data question. It determines whether LLM pre-labeling can use a third-party API.

### Step 2: Pick a pattern

Use the decision tree in `references/patterns.md`. Summary:

- **Binary text classification, longer texts** → TUI (`assets/tui-template/label.py`)
- **Multi-class text classification** → TUI, run once per category (decomposed)
- **Short texts, many rows fit on screen** → spreadsheet (`assets/spreadsheet-template/spreadsheet.py`)
- **Span extraction** → TUI with per-span y/n stream if candidates can be pre-extracted; otherwise web UI (write fresh)
- **Images / PDFs / scans** → minimal Streamlit, write fresh (recipe in `references/patterns.md`)
- **Pool mostly covered by simple rules** → consider weak supervision instead of per-example labeling (see `references/patterns.md`)

Don't force a pattern. If none fits, read `references/patterns.md` for the principles and write something minimal from scratch.

### Step 3: Sample

Pick the right slice to label. See `references/sampling.md` for the full decision tree; summary:

- **Cold start** (no labels yet) → `scripts/sample_stratified.py` with equal allocation across a known or suspected stratum (e.g. predicted class from a weak signal). If fully cold, random.
- **Have a weak classifier/LLM with probs** → `scripts/sample_uncertainty.py` after seeding with 100–300 random/stratified labels. Use `--diversity-col` for batch redundancy control.
- **Targeted debug** → hand-write the filter; keep a random control slice alongside.

### Step 4: Pre-label (optional but often worth it)

If an LLM or simple rule can pre-label at ≥50% accuracy, it saves meaningful time.

**Before using an LLM pre-labeler, confirm with the user:**

- Is the data sensitive? If yes, use a local OpenAI-compatible endpoint (vLLM, Ollama, llama.cpp server pointing at HRDAG's Qwen or similar). **Do not** send sensitive data to Anthropic, OpenAI, or any third party without explicit authorization.
- Which model? Let the user pick — don't default.

Then use `scripts/llm_prelabel.py`. Supports:
- `--provider openai-compat` with any OpenAI-compatible endpoint (local models, OpenAI, OpenRouter)
- `--provider anthropic` for Claude via the Anthropic SDK

After running, **always validate the pre-labeler on a small human-labeled sample** (`scripts/eval_prelabeler.py`). Gilardi et al. 2023 claimed GPT-4 beats crowdworkers; Pangakis et al. 2023 showed that claim doesn't generalize task-to-task. Verify for *your* task.

### Step 5: Customize the template

Most tasks need only small edits to the template's CONFIG block at the top of `assets/tui-template/label.py`:

- `ID_COL`, `TEXT_COL` — column names in the input
- `PRELABEL_COL` — `None` or the pre-label column name
- `METADATA_COLS` — list of columns to display in the metadata line
- `HIGHLIGHT_KEYWORDS` — keywords to highlight in the text (often `[]`)
- `LABEL_QUESTION`, `YES_NAME`, `NO_NAME` — UI labels
- `SORT_ORDER` — usually `"prelabel_desc"` (positives first) or `"original"`

Copy the template into the user's project (their task directory — typically `src/` or `analysis/.../src/`). Don't edit the skill's template in place.

For the spreadsheet template, edit the CONFIG at the top of `spreadsheet.py` similarly.

### Step 6: Label

Let the user run it. Make sure they know:
- The keystrokes (these are printed at the bottom of the TUI).
- Where labels land (the SQLite DB; exports on quit).
- That they can quit and resume — state persists.

### Step 7: Evaluate + iterate

After ~50–100 labels, evaluate. If there's a pre-labeler, run `scripts/eval_prelabeler.py` to compare. Look at:

- **Kappa** — Krippendorff's thresholds: ≥0.80 reliable, 0.667–0.80 tentative, <0.667 rework.
- **Confusion matrix** — which direction are the errors? Systematic errors (class-conditional noise) are worse than symmetric noise.
- **Positive rate in sample** — if it collapsed, the sampling strategy is biased.

Then decide: another round (uncertainty-sampled this time), schema revision, or done.

## What to include in the user's project

When building a labeling interface for a user, copy into their project:

- The adapted `label.py` (or `spreadsheet.py`, or a fresh web UI).
- The sampling script used, if any (so the sampling is reproducible).
- The LLM pre-label prompt file, if any.
- A short `README.md` at the labeling directory explaining how to run it.

Do **not** copy the research/patterns/sampling reference files — they're for designing the interface, not for the user's project.

## When to write fresh instead of adapting

The template is a starting point, not a requirement. Write fresh when:

- The pattern isn't classification (e.g. ranking, pairwise comparison, span extraction with rich context).
- The UI needs non-text rendering (images, maps, audio).
- The keyboard/interaction flow is fundamentally different.

In those cases, read `references/patterns.md` for the principles (keyboard-only hot path, SQLite state, undo, progress, flag action, binary decomposition) and implement the minimum needed. Don't port unused template code.

## Do not

- Build a reusable annotation platform. This is adhoc — every task is its own tool.
- Use Anthropic / OpenAI APIs for sensitive data without explicit user authorization.
- Default to a framework (Label Studio, Prodigy, etc.). A hundred lines of Python is usually faster to set up and faster to use.
- Skip the cold-start stratified seed in favor of immediate uncertainty sampling.
- Pre-fill the label as the LLM's guess. Present as "press s to accept pre-label" instead, to reduce anchoring.
- Show confidence sliders. Offer a single "flag for review" action.

## References

- `references/research.md` — the evidence base for these principles (Prodigy/Explosion, active learning canon, Monarch's HITL book, Snorkel/weak supervision, data-centric AI, inter-annotator agreement, label noise, LLM pre-labeling). Read when making non-obvious design choices or when the user asks "why this way".
- `references/patterns.md` — catalog of interface shapes (binary TUI, decomposed multi-class, span extraction, spreadsheet, web viewer, weak supervision) with tradeoffs and minimal Streamlit recipe.
- `references/sampling.md` — full decision tree for sampling strategies, iterative active-learning loop, pitfalls.

## Assets & scripts

- `assets/tui-template/label.py` — curses binary labeler, parameterized via CONFIG block.
- `assets/spreadsheet-template/spreadsheet.py` — CSV prepare/merge for spreadsheet labeling.
- `scripts/sample_stratified.py` — equal or proportional stratified sampling.
- `scripts/sample_uncertainty.py` — uncertainty ranking (margin / entropy / least-confidence) with optional greedy diversity.
- `scripts/llm_prelabel.py` — provider-agnostic LLM pre-labeling (OpenAI-compatible endpoints for local models, Anthropic SDK).
- `scripts/eval_prelabeler.py` — confusion matrix + precision/recall/F1 + Cohen's kappa with Krippendorff thresholds.
