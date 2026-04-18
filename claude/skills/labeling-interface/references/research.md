# Research Synthesis: Efficient Human Labeling for Machine Learning

A principles-level synthesis for designing ad-hoc labeling interfaces. The goal is to compress the research and practitioner literature into decisions and tradeoffs, not feature walkthroughs of specific tools.

## 1. The Prodigy / Explosion AI School: Binary Decisions and Model-in-the-Loop

**Finding.** Matthew Honnibal and Ines Montani (Explosion AI) argue that the dominant bottleneck in applied ML is human attention, and that annotation interfaces should be designed to minimize the cognitive work per decision — typically by decomposing complex multi-class or span tasks into streams of binary (accept/reject) judgments on model suggestions. There is no formal peer-reviewed "Fast and effective machine teaching" paper; this position is articulated in talks, blog posts, and Prodigy documentation.

**Evidence.** In the talk "Rapid NLP Annotation Through Binary Decisions, Pattern Bootstrapping, and Active Learning" (Honnibal, 2018, https://www.youtube.com/watch?v=59BKHO_xBPA) and Montani's PyData talks (e.g., "Prodigy: A new tool for radically efficient machine teaching", 2017), the argument is roughly: humans are much faster at confirming a yes/no than choosing from a dropdown, so put the model in the loop, have it propose, and have the annotator arbitrate. Explosion's blog (https://explosion.ai/blog/) and Prodigy documentation articulate the corollary principles: (a) stream tasks one at a time rather than a form full of fields; (b) pre-populate with model or pattern-matcher suggestions; (c) use uncertainty-based sampling so the human sees examples that actually move the decision boundary; (d) keep the annotator keyboard-bound. Attribute these to the talks/blog, not a paper.

**Caveats.** Binary decomposition only wins when the underlying model is good enough to make reasonable suggestions. Cold-start on a novel schema with no patterns and a weak zero-shot model will surface mostly noise, and reject-heavy streams are demoralizing and uninformative. The "binary reduction" also hides inter-category confusions that a full multi-label UI would expose — if the annotator never sees that class A and class B overlap, the schema drift stays invisible.

## 2. The Active Learning Canon

**Finding.** Active learning can reduce labeling cost substantially when the pool contains redundant easy examples, but classical single-point uncertainty sampling fails or underperforms random sampling in several practical regimes: severe class imbalance, cold-start, noisy oracles, and when the downstream model is deep and retrained from scratch each round.

**Evidence.** Burr Settles' "Active Learning Literature Survey" (2009, CS Technical Report, University of Wisconsin–Madison, https://minds.wisconsin.edu/handle/1793/60660) remains the canonical taxonomy: pool-based vs. stream-based, uncertainty sampling (Lewis & Gale, "A Sequential Algorithm for Training Text Classifiers", SIGIR 1994), query-by-committee (Seung, Opper, Sompolinsky, "Query by Committee", COLT 1992), expected model change, expected error reduction, and variance reduction. Margin sampling (Scheffer et al., 2001) and entropy sampling are the ubiquitous drop-in heuristics.

The canonical failure modes are well-documented. In deeply imbalanced pools, uncertainty sampling often revisits the dense majority region near the current boundary and never discovers the rare class — an issue addressed by cluster- or density-weighted variants (Settles & Craven, EMNLP 2008). Cold-start is problematic because an untrained model's uncertainties are essentially noise; several papers recommend seeding with random or diverse samples before switching to uncertainty (e.g., Zhu et al., "Active learning with sampling by uncertainty and density", COLING 2008).

BADGE (Ash, Zhang, Krishnamurthy, Langford, Agarwal, "Deep Batch Active Learning by Diverse, Uncertain Gradient Lower Bounds", ICLR 2020, https://arxiv.org/abs/1906.03671) is the key modern correction: it selects batches using k-means++ seeding in the gradient embedding space, simultaneously enforcing uncertainty (large gradient magnitude) and diversity (spread across the embedding). This addresses the batch-mode redundancy problem where a pure top-k uncertainty query returns a clump of near-duplicate hard examples. Core-set approaches (Sener & Savarese, "Active Learning for Convolutional Neural Networks: A Core-Set Approach", ICLR 2018, https://arxiv.org/abs/1708.00489) take the diversity-first route.

There is also a skeptical literature: Lowell, Lipton, Wallace ("Practical Obstacles to Deploying Active Learning", EMNLP 2019, https://arxiv.org/abs/1807.04801) show that data collected via one acquisition strategy for one model often fails to transfer to a successor model — i.e., the labeled corpus is biased toward the original acquirer.

**Takeaway.** Active learning is not free lunch. For ad-hoc labeling, the safe default is: start with random or stratified-diverse seeds; add uncertainty-based queries once a weak model exists; in batch mode prefer a diversity-aware selector (BADGE-style) over top-k uncertainty; and monitor for class collapse.

## 3. Monarch, "Human-in-the-Loop Machine Learning"

**Finding.** Robert Monarch's *Human-in-the-Loop Machine Learning* (Manning, 2021) is the most practitioner-oriented synthesis and emphasizes that the sampling strategy, the quality-control strategy, and the interface are one system — optimizing any one in isolation usually doesn't help.

**Evidence.** Key practical takeaways from the book: (1) combine uncertainty sampling with diversity sampling (clustering in representation space, outlier detection, representative sampling) rather than picking one; (2) track annotator-level agreement over time, not just pairwise kappa on a one-shot calibration set; (3) route disagreements back to adjudication rather than majority-voting them away silently; (4) design the interface so a skilled annotator is at least 2x faster than a naive dropdown form (via hotkeys, pre-population, keyboard navigation); (5) treat annotators as domain experts who can update the schema, not as interchangeable labor.

Monarch also emphasizes transfer learning and representation-based sampling: since modern practice uses pretrained encoders, diversity sampling should be done in embedding space, not raw feature space. He is careful about when to use weak supervision (large unlabeled pools, rules exist) vs. active learning (model exists, uncertainty signal meaningful) vs. random sampling (cold-start, high class imbalance unknown).

## 4. Snorkel and Weak Supervision

**Finding.** When the schema can be expressed as programmatic rules ("labeling functions") — keyword matches, regex, distant supervision from a knowledge base, heuristics on metadata — weak supervision with a label model (denoising multiple noisy LFs) generally beats per-example human labeling on throughput and often matches it on downstream model accuracy for high-volume tasks. When the schema is genuinely subjective or linguistically subtle and no concise rule captures it, per-example human labels win.

**Evidence.** Ratner, Bach, Ehrenberg, Fries, Wu, Ré, "Snorkel: Rapid Training Data Creation with Weak Supervision" (VLDB 2018, https://arxiv.org/abs/1711.10160) presents the generative label model that aggregates LFs of varying accuracy and correlation, producing probabilistic labels. Follow-ups (Ratner et al., "Training Complex Models with Multi-Task Weak Supervision", AAAI 2019) extend this. Empirically, Snorkel-style pipelines match or exceed hand-labeled baselines on relation extraction and document classification when a handful of reasonable LFs exist.

**When weak supervision loses.** (a) When writing a good LF is as hard as labeling — subtle entailment, nuanced sentiment, safety judgments. (b) When LF coverage is low and the uncovered tail is exactly where the interesting examples live. (c) When LFs are highly correlated (all fire on the same easy cases), because the label model can underestimate correlation and become overconfident. (d) In low-volume regimes (hundreds to low thousands of examples), the fixed cost of writing and debugging LFs often exceeds the cost of just labeling.

**Hybrid.** The productive pattern for ad-hoc labeling is often: LFs to pre-label the bulk, humans to adjudicate LF-disagreement cases and the uncovered tail. This is also the Prodigy school's "pattern bootstrapping" in a different dialect.

## 5. Data-Centric AI: Label Quality Over Quantity

**Finding.** For small-to-medium datasets typical of ad-hoc labeling, improving label quality and consistency yields larger accuracy gains than scaling either the model or the label count. Andrew Ng has been the most visible proponent of this reframing since ~2021.

**Evidence.** Ng's "MLOps: From Model-centric to Data-centric AI" talk (2021, https://www.deeplearning.ai/) and the NeurIPS 2021 Data-Centric AI Workshop organized by Ng, Mazumder, and others established the framing. The accompanying case studies (steel defect detection, solar panel inspection) reported that systematically cleaning labels on a small dataset outperformed doubling the dataset size with the original noisy labels — though exact numbers vary across talks and should be treated as illustrative rather than benchmark-precise.

The broader evidence base: Northcutt, Athalye, Mueller, "Pervasive Label Errors in Test Sets Destabilize Machine Learning Benchmarks" (NeurIPS Track on Datasets and Benchmarks 2021, https://arxiv.org/abs/2103.14749) found average label error rates of ~3.3% across ten canonical ML test sets, with ImageNet at ~6%. Correcting these labels can flip model rankings — implying that perceived model gains on noisy benchmarks can be artifacts of label noise.

**Implication for interface design.** A labeling interface should expose consistency: make it easy to jump back to prior decisions, surface "you labeled this similar example X", support schema revision without a full relabel, and make disagreement visible rather than hide it behind majority vote.

## 6. Inter-Annotator Agreement

**Finding.** Report chance-corrected agreement (Cohen's kappa for two annotators, Krippendorff's alpha for n annotators or missing data), with the commonly cited thresholds of 0.667 as the minimum for tentative conclusions and 0.80 as the standard for reliable data — both from Krippendorff's own guidance. But for span/extraction tasks, kappa is a poor fit; use F1-over-spans (treating one annotator's spans as gold) or a specialized measure.

**Evidence.** Cohen, "A Coefficient of Agreement for Nominal Scales" (Educational and Psychological Measurement, 1960) introduced kappa for two raters on nominal categories. Krippendorff's alpha (Krippendorff, *Content Analysis: An Introduction to Its Methodology*, multiple editions; the cutoff discussion is explicit in Krippendorff, "Reliability in Content Analysis: Some Common Misconceptions and Recommendations", Human Communication Research 2004) generalizes to any number of raters, handles missing ratings, and adapts to nominal/ordinal/interval data. The 0.667/0.80 thresholds are stated directly by Krippendorff as pragmatic rather than theoretical — "variables with reliabilities between α=.667 and α=.800 may be used only for drawing tentative conclusions."

For span tasks (NER, event extraction), kappa requires defining the unit of analysis; token-level kappa is dominated by the "O" (outside) class and becomes meaninglessly high. The standard practitioner choice is span-level F1 with one annotator as reference, sometimes averaged symmetrically — this is reviewed in Hripcsak & Rothschild, "Agreement, the F-Measure, and Reliability in Information Retrieval" (Journal of the American Medical Informatics Association, 2005, https://academic.oup.com/jamia/article/12/3/296/812057), which derives the relationship between F1 and chance-corrected agreement.

**When single vs. multiple annotators.** Multiple annotators are justified when (a) the task is subjective or genuinely ambiguous, (b) you need to quantify uncertainty in the labels themselves, (c) you're producing a benchmark. Single annotator is appropriate when (a) the task is mostly objective, (b) the annotator is a domain expert, (c) you're producing training data and the model can tolerate label noise below the disagreement rate. Even with a single annotator, a small double-annotated calibration set (say, 100 items) is cheap insurance — it quantifies noise in the training labels, which matters for interpreting downstream eval.

## 7. Label Noise Literature

**Finding.** Modern classifiers are surprisingly robust to symmetric random label noise at moderate rates, but are hurt meaningfully by systematic (class-conditional) noise and by noise in the evaluation set. Confident Learning provides a principled way to identify likely-mislabeled examples.

**Evidence.** Rolnick, Veit, Belongie, Shavit, "Deep Learning is Robust to Massive Label Noise" (arXiv 2017, https://arxiv.org/abs/1705.10694) showed that even with 10-20x more mislabeled than correct examples, deep networks can still generalize, provided enough data and the noise is roughly symmetric. Song, Kim, Park, Shin, Lee, "Learning from Noisy Labels with Deep Neural Networks: A Survey" (IEEE TNNLS 2022, https://arxiv.org/abs/2007.08199) reviews robust loss functions, sample-reweighting, and noise-transition-matrix methods.

Northcutt, Jiang, Chuang, "Confident Learning: Estimating Uncertainty in Dataset Labels" (JAIR 2021, https://arxiv.org/abs/1911.00068) and Northcutt et al. (2021, cited above) show that out-of-sample predicted probabilities plus class-conditional thresholds can rank examples by likelihood of being mislabeled, letting you re-examine a small high-yield subset.

**When to redo vs. tolerate.** Redo when (a) noise is class-conditional (e.g., one class is systematically confused for another), (b) the evaluation set is affected, (c) the error rate is high enough that it exceeds the signal-to-noise of the feature you're trying to learn. Tolerate when (a) noise is symmetric and moderate, (b) the downstream use is robust (ranking rather than point classification), (c) the budget for relabel is better spent labeling new diverse examples.

## 8. Interface Design Factors

**Finding.** Keyboard-first, one-decision-at-a-time, with constant progress visibility consistently outperforms form-heavy, mouse-driven designs on throughput and (in some studies) accuracy. Annotator fatigue is real and measurable; batch length should be finite and interruptible.

**Evidence.** The HCI literature on annotation UI is scattered across CHI, CSCW, and ML venues. Neves & Ševa, "An extensive review of tools for manual annotation of documents" (Briefings in Bioinformatics, 2021, https://doi.org/10.1093/bib/bbz130) surveys tools and notes that hotkey-driven, model-in-the-loop interfaces dominate on reported annotator satisfaction. The broader HCI principles (Fitts's law for pointing time, the documented advantage of keyboard shortcuts for expert users; Nielsen on "visibility of system status") apply directly: showing progress, remaining queue, and estimated time reduces dropout.

Fatigue effects: studies on crowdsourced labeling (e.g., Kazai, Kamps, Milic-Frayling, various between 2011-2015) report accuracy declines after extended sessions and advocate for session caps and forced breaks. The specific numbers vary by task and should be treated as "well-documented in direction, not precise in magnitude."

Highlighting and pre-population: for span tasks, pre-highlighted candidate spans reduce time but introduce anchoring (see Section 9). For classification, showing the raw text without bolded "hints" avoids leading the annotator; for extraction, some visual scaffolding is near-mandatory because unaided span selection is slow and error-prone.

Other robust findings: (a) confidence/uncertainty sliders are rarely used well — annotators collapse to extremes; prefer a binary plus a separate "flag for review" action; (b) undo and easy revision reduce rushed misclicks; (c) reason-codes (free-text "why") are invaluable for schema debugging but should be optional to avoid slowing the main stream.

## 9. LLM Pre-Labeling

**Finding.** LLMs can label many NLP tasks at or above crowdworker quality and at a fraction of the cost, but naively using LLM labels has three documented failure modes: (a) instability across prompts and models, which propagates to flipped downstream conclusions; (b) anchoring bias when LLM guesses are shown as defaults in a human-in-the-loop UI; (c) systematic blind spots that correlate across examples, inflating apparent model accuracy.

**Evidence for the upside.** Gilardi, Alizadeh, Kubli, "ChatGPT outperforms crowd workers for text-annotation tasks" (PNAS 2023, https://www.pnas.org/doi/10.1073/pnas.2305016120) reported GPT-4 exceeding MTurk accuracy on several political-text classification tasks, with inter-coder agreement comparable to or higher than crowdworkers and per-label cost dramatically lower.

**Evidence for the downsides.** Emerging work documents that different prompts and different LLMs applied to the same corpus can produce labels that, when fed into downstream statistical analyses, yield flipped signs on substantive conclusions — a reproducibility risk invisible to a single-run evaluation. Wang, Gooch, Shi, Zhang et al., "Human-LLM Collaborative Annotation Through Effective Verification of LLM Labels" (CHI 2024, https://dl.acm.org/doi/10.1145/3613904.3641960) documents anchoring: when the UI shows the LLM's guess as the default, human accept-rates are systematically biased toward the LLM, even when the LLM is wrong, and even when annotators are warned. Verification UIs that hide the LLM guess until the human commits reduce this, at the cost of throughput.

Also relevant: Pangakis, Wolken, Fasching, "Automated Annotation with Generative AI Requires Validation" (arXiv 2023, https://arxiv.org/abs/2306.00176) emphasizes that per-dataset human validation is still required — LLM accuracy varies substantially across tasks and generalizing from one reported result is unsafe.

**Design implications.** If using LLM pre-labels: (a) validate on a held-out human-labeled sample for *this* task, not a neighboring benchmark; (b) consider whether to show the LLM label as a suggestion (fast, biased) or only post-hoc as a cross-check (slower, unbiased); (c) for downstream statistical use, report sensitivity of conclusions to prompt and model choice; (d) budget human adjudication for the cases where the LLM disagrees with itself across prompts/temperature or where confidence is low.

## 10. Span/Extraction vs. Document Classification

**Finding.** Document-level classification and span-level extraction are meaningfully different annotation problems, with different throughputs, error modes, agreement measures, and interface affordances. Conflating them in interface design hurts both.

**Evidence and design implications.** Document classification decisions are small (one label per item), fast (seconds), and amenable to binary decomposition and keyboard hotkeys. Agreement is measured with kappa/alpha. The dominant error mode is inconsistent application of a fuzzy category boundary — addressable by calibration rounds and exemplars.

Span extraction decisions are variable-size (zero to many spans per item), slow (tens of seconds to minutes for long documents), and dominated by attention/selection mechanics. Agreement should use F1-over-spans with a defined matching criterion (exact, overlap, or head-matching), not kappa. Dominant error modes are (a) boundary disagreements (does the span include the determiner? the trailing punctuation?), (b) missed spans (recall errors from skim-reading), and (c) schema drift on nested/overlapping spans. Interface affordances that matter most: keyboard-driven span selection, pre-highlighted candidates from a weak model or pattern matcher (with anchoring risk), explicit "I read the whole document and there are no spans" affirmative action (to distinguish empty from skipped), and visual encoding of span type.

Relation and event extraction add a further dimension — pairs or tuples of spans — and typically need a different UI paradigm (two-pass: spans then relations; or graph-style connection).

## Practical Implications for Designing a Labeling Interface

- **Start with the decision grain.** Document classification, span extraction, and relation/tuple extraction are distinct UI problems; pick one primary mode and resist mixing. A "do everything" form is worse than focused modes per phase.
- **Binary-decompose when the model is good enough.** Accept/reject streams on model suggestions are fastest when the model's hit rate is reasonable (say, above ~50% correct). When it is much lower, reject-heavy streams are demoralizing and under-informative; fall back to fresh labeling.
- **Don't start with active learning.** Cold-start with random or diversity-based sampling. Switch to uncertainty-aware selection only after a weak model exists. In batch mode, prefer a diversity-aware selector (BADGE-style) to top-k uncertainty to avoid redundant hard cases.
- **Assume class imbalance until proven otherwise.** Track positive-class rate in the stream. If it collapses, inject random or targeted positive-seeded examples.
- **Build in double-annotation for a calibration subset.** Even a small (~100-item) doubly-annotated slice lets you report kappa or span-F1 and catch schema drift, without the cost of full redundancy.
- **Use the right agreement metric.** Kappa/alpha for categorical decisions; span-F1 for extraction. Do not report token-level kappa for span tasks.
- **Make decisions revisable.** Easy undo, jump-to-prior-similar, and schema-aware bulk relabel are high-leverage. Data-centric work requires iteration on labels, not just models.
- **Track annotator-level metrics over time.** Per-annotator accuracy on calibration items, throughput, and drift. Fatigue is real — cap sessions and show progress.
- **Be careful with LLM pre-labels.** If shown as suggestions they anchor humans, even when warned. Prefer post-hoc cross-check, or hide the suggestion until the human commits. Validate LLM label quality on a human-labeled sample for the specific task.
- **Separate "flag" from "label."** A single flag/review action for hard or schema-challenging cases is more useful than multi-level confidence sliders, which annotators collapse to extremes.
- **Make negatives explicit.** For extraction tasks, require an affirmative "no spans present" action; otherwise you cannot distinguish empty from skipped, and recall evaluation becomes unreliable.
- **Treat weak supervision and per-example labeling as complements.** If cheap rules cover most of the pool, use them to pre-label and route disagreements to humans. If rules are hard to write, label directly. The hybrid is usually the right operating point for ad-hoc work.
