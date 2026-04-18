# Sampling strategies

Which examples to label, in which order. Sampling decisions compound:
early-round choices bias the labeled pool for the rest of the project.

See `research.md` §2 for the active-learning literature and §5 for
data-centric motivations.

## Decision tree for picking a strategy

```
Have any labels yet?
├─ No (cold start)
│   ├─ Class distribution known or suspected balanced?
│   │   → random sample
│   └─ Class imbalance known or suspected? (most "interesting" tasks)
│       → stratified sample by a proxy for the rare class
└─ Yes
    ├─ Do you have a model with probabilities?
    │   ├─ Above random performance? → uncertainty sampling (maybe + diversity)
    │   └─ No (cold/weak) → keep random/stratified a few rounds more
    └─ No model yet, but you've spotted patterns?
        → targeted sampling on those patterns + random control
```

## Random

The baseline. Always include a random slice — it's the only sample that
gives you honest estimates of population-level quantities (class
prevalence, label-model precision) and the only one that isn't subject to
acquisition bias (Lowell et al., EMNLP 2019).

- Use for: the first 50–200 items, and as a standing control slice across
  rounds.
- Pitfall: on rare-class tasks, random returns almost no positives. Pair
  with a targeted/stratified sample that oversamples the likely-positive
  region.

## Stratified

Group by a variable, sample within groups. Two modes:

- **Equal allocation** (N per stratum). The default for adhoc labeling,
  because you usually want to *see variation* across strata, not match the
  population. Quality > representativeness when the goal is to discover
  schema edge cases and train a model.
- **Proportional allocation** (total N, split by stratum size). Use when
  the sample needs to represent the population — e.g. estimating an
  overall rate.

Good stratification variables:

- Known strata of interest (jurisdiction, time period, source).
- Binned continuous predictors (quartile of a score, length buckets).
- Coarse pre-labels from a weak model or rule (stratify by predicted
  class to avoid class collapse when the positive rate is low).

**Script:** `scripts/sample_stratified.py`.

## Uncertainty (active learning)

Once you have a model that beats random, it can flag the examples it's
least sure about. These are high-information: labeling them most moves the
decision boundary.

Methods:

- **Binary.** Score = `1 - 2 * |p - 0.5|`. Pick the top K.
- **Multi-class margin.** `1 - (p_top1 - p_top2)`. The "is it A or B?"
  case. Generally the best default for multi-class.
- **Multi-class entropy.** `-Σ p log p`. Sensitive to tails of the
  distribution; tends to pick "confused across everything" rather than
  "confused between two".
- **Least confidence.** `1 - max(p)`. Simple, OK for calibration-heavy
  tasks.

**Cold-start warning.** Do not use uncertainty sampling before the model
beats random by a meaningful margin. Early-training uncertainties are
noise, and concentrating labels in a noisy region wastes effort. Canonical
heuristic: seed with ~100–300 random/stratified labels first.

**Imbalance warning.** On rare-class pools, naive uncertainty sampling
sits near the current boundary and never finds the rare class — the
boundary doesn't move because the rare class isn't there. Fixes:
stratified sample within uncertainty (take top K per predicted class), or
combine with targeted positive-seeking sampling.

**Batch redundancy warning.** Top-K uncertainty often returns clusters of
near-duplicate hard examples. A cluster of 20 slightly-different versions
of the same edge case teaches the model less than 20 genuinely different
hard cases. Mitigations:

- BADGE-style (Ash et al., ICLR 2020) — gradient-embedding k-means++.
  More accurate but harder to implement.
- Greedy diversity: take a larger pool by uncertainty (3K items), then
  max-min by cosine distance in an embedding. Cheap, reasonable.

**Script:** `scripts/sample_uncertainty.py`, with optional
`--diversity-col` for the greedy max-min pass.

## Targeted

Hand-curated queries that oversample specific conditions — a keyword
match, a date range, rows where two LFs disagree, rows where an LLM and a
classifier disagree.

When useful:

- Early rounds, to bootstrap positive examples of a rare class.
- Late rounds, to debug specific failure modes identified in eval.
- Ever: as a complement to random/uncertainty, not a replacement.

Keep it transparent — write down what each targeted slice is selecting for
and preserve a random control slice so you can detect when targeted
labeling is distorting your evaluation.

## Diversity / representative

Cluster the pool in an embedding (TF-IDF, sentence-transformer), sample N
per cluster. Good for seed rounds when nothing is labeled and you want
coverage. Also useful combined with uncertainty (see BADGE above).

Weakness: cluster quality depends on the embedding. For text with
pretrained encoders this is usually fine; for custom domains (logs, legal
jargon) the embedding may not separate the classes of interest.

## The iterative active-learning loop

The productive rhythm for adhoc labeling:

1. **Seed (round 0).** Random + stratified, ~50–200 items. No model yet.
2. **Bootstrap classifier.** Train a weak baseline — often an LLM
   pre-labeler, sometimes a TF-IDF + logistic regression, sometimes a
   small fine-tuned transformer. Evaluate on the seed's holdout.
3. **Targeted round.** Uncertainty + diversity, 50–200 more items, heavy
   on model-uncertain cases. Retrain.
4. **Evaluate.** Check agreement with pre-labeler (if any), per-class
   recall, calibration of the model. Look at where it's wrong.
5. **Repeat 3–4** until the marginal value of a new label is small.
6. **Final pass.** Double-annotate a calibration slice (~50–100 items) to
   quantify label noise for downstream evaluation.

Each round is small (< an hour of labeling) so you can react quickly to
what the model is learning and adjust the schema or sampling strategy.

## Pitfalls

- **Acquisition bias.** Labels gathered via one strategy for one model may
  not transfer to a successor. Preserve metadata about how each example
  was selected.
- **Class collapse.** Uncertainty sampling on an imbalanced pool can
  return 100% majority-class; track positive rate per round.
- **Over-sampling the easy.** Targeted queries that match obvious
  patterns oversample what the model already knows. Rotate in random.
- **Calibration drift.** The `uncertainty` threshold that was right in
  round 2 may select too-easy cases in round 5 as the model improves.
  Re-inspect the uncertainty distribution each round.
- **Annotator drift.** The annotator's bar for "yes" can drift across a
  session or across days. A small double-annotated consistency check each
  round catches this.
