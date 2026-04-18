#!/usr/bin/env python3
"""
LLM pre-labeling (provider-agnostic).

Calls an LLM once per row to produce a binary pre-label. The output column
can then be used by label.py as a pre-label, or evaluated with
eval_prelabeler.py against gold labels.

SENSITIVE DATA WARNING
----------------------
Check with the user before sending data to any external provider. Some
datasets cannot leave local infrastructure. When in doubt, use a local
OpenAI-compatible endpoint (vLLM, Ollama, llama.cpp server) and never pass
--provider anthropic / openai without explicit authorization.

Usage
-----
    # Local OpenAI-compatible endpoint (default). Works for vLLM, Ollama, etc.
    python llm_prelabel.py --input sample.parquet --out prelabeled.parquet \\
        --text-col text --prompt-file prompt.txt --out-col llm_label \\
        --provider openai-compat --base-url http://localhost:8000/v1 \\
        --model Qwen3.5-72B-Instruct

    # Anthropic SDK (non-sensitive data only)
    python llm_prelabel.py --input sample.parquet --out prelabeled.parquet \\
        --text-col text --prompt-file prompt.txt --out-col llm_label \\
        --provider anthropic --model claude-haiku-4-5-20251001

Prompt file
-----------
A plain-text file with the prompt. Use {text} as the placeholder for the
row's text. The prompt should instruct the model to answer "yes" or "no" as
the first word of its response. Example:

    You are labeling police reports. A "spotting operation" is when officers
    observe suspected drug dealing from a concealed position.

    Report:
    ---
    {text}
    ---

    Is this report describing a spotting operation? Answer with exactly one
    word: "yes" or "no".

Parsing
-------
The first alphabetic token in the model's response is parsed. "yes"/"y"/"true"
→ 1, "no"/"n"/"false" → 0. Anything else → NaN (flagged for review).
"""

import argparse
import os
import re
import sys
import time
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


_TOKEN_RE = re.compile(r"[a-zA-Z]+")


def parse_label(text: str):
    m = _TOKEN_RE.search(text or "")
    if not m:
        return None
    word = m.group(0).lower()
    if word in ("yes", "y", "true", "t", "1"):
        return 1
    if word in ("no", "n", "false", "f", "0"):
        return 0
    return None


def call_openai_compat(client, model, prompt):
    resp = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        temperature=0,
        max_tokens=16,
    )
    return resp.choices[0].message.content or ""


def call_anthropic(client, model, prompt):
    resp = client.messages.create(
        model=model,
        max_tokens=16,
        messages=[{"role": "user", "content": prompt}],
    )
    parts = [b.text for b in resp.content if getattr(b, "type", "") == "text"]
    return "".join(parts)


def make_client(provider, base_url, api_key_env):
    if provider == "openai-compat":
        try:
            from openai import OpenAI
        except ImportError:
            sys.exit("pip install openai")
        api_key = os.environ.get(api_key_env or "OPENAI_API_KEY", "not-needed")
        return OpenAI(base_url=base_url, api_key=api_key), call_openai_compat
    if provider == "anthropic":
        try:
            from anthropic import Anthropic
        except ImportError:
            sys.exit("pip install anthropic")
        return Anthropic(), call_anthropic
    sys.exit(f"Unknown provider: {provider}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--text-col", required=True)
    ap.add_argument("--prompt-file", required=True)
    ap.add_argument("--out-col", default="llm_label")
    ap.add_argument("--raw-col", default=None,
                    help="Also store raw model output in this column (useful for debugging).")
    ap.add_argument("--provider", choices=["openai-compat", "anthropic"], default="openai-compat")
    ap.add_argument("--base-url", default="http://localhost:8000/v1",
                    help="For openai-compat only.")
    ap.add_argument("--api-key-env", default=None,
                    help="Env var to read API key from. Default OPENAI_API_KEY.")
    ap.add_argument("--model", required=True)
    ap.add_argument("--limit", type=int, default=None,
                    help="Label only the first N rows (useful for testing).")
    ap.add_argument("--sleep", type=float, default=0.0,
                    help="Sleep N seconds between calls (rate-limit friendly).")
    args = ap.parse_args()

    df = read_any(Path(args.input))
    if args.text_col not in df.columns:
        sys.exit(f"Missing column: {args.text_col}")

    prompt_template = Path(args.prompt_file).read_text()
    if "{text}" not in prompt_template:
        sys.exit("prompt-file must contain the literal {text} placeholder.")

    sensitive_note = {
        "openai-compat": f"Endpoint: {args.base_url}. Ensure data may be sent there.",
        "anthropic": "Sending to Anthropic API — NOT for sensitive data without authorization.",
    }[args.provider]
    print(f"[warning] {sensitive_note}", file=sys.stderr)

    client, caller = make_client(args.provider, args.base_url, args.api_key_env)

    labels = []
    raws = []
    rows = df.head(args.limit) if args.limit else df
    n = len(rows)
    for i, (_, row) in enumerate(rows.iterrows(), 1):
        prompt = prompt_template.replace("{text}", str(row[args.text_col]))
        try:
            raw = caller(client, args.model, prompt)
        except Exception as e:
            print(f"[error] row {i}: {e}", file=sys.stderr)
            raw = ""
        lab = parse_label(raw)
        labels.append(lab)
        raws.append(raw)
        if i % 10 == 0 or i == n:
            print(f"  {i}/{n}", file=sys.stderr)
        if args.sleep:
            time.sleep(args.sleep)

    if args.limit:
        out = df.copy()
        out[args.out_col] = pd.NA
        out.loc[out.index[:args.limit], args.out_col] = labels
        if args.raw_col:
            out[args.raw_col] = pd.NA
            out.loc[out.index[:args.limit], args.raw_col] = raws
    else:
        out = df.copy()
        out[args.out_col] = labels
        if args.raw_col:
            out[args.raw_col] = raws

    write_any(out, Path(args.out))
    yes = sum(1 for x in labels if x == 1)
    no = sum(1 for x in labels if x == 0)
    unk = sum(1 for x in labels if x is None)
    print(f"Labeled {len(labels)} rows: {yes} yes, {no} no, {unk} unparseable → {args.out}")


if __name__ == "__main__":
    main()
