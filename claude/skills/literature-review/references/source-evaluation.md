# Source Evaluation Framework

Use this framework to assess the quality and trustworthiness of sources identified during a literature review. No single criterion is definitive — evaluate sources holistically and in context.

## The CRAAP+ Framework

An extended version of the CRAAP test (Blakeslee, CSU Chico) with additional criteria for research contexts.

### 1. Currency
- When was it published or last updated?
- Is it current enough for the field? (ML/AI: 1-2 years may be outdated; legal theory: 10+ years may be fine)
- Has the evidence base changed since publication?
- For preprints: has a peer-reviewed version been published since?

### 2. Relevance
- Does it directly address the research question?
- Is the depth appropriate (not too superficial, not tangential)?
- Does it cover the right population, geography, or context?
- Does it use methods relevant to our methodological interest?

### 3. Authority
- **Author credentials**: Institutional affiliation, publication record, h-index, domain expertise
- **Publisher/venue**: Reputable academic press or journal? Impact factor? (Use cautiously — impact factor measures journal-level, not article-level quality)
- **Peer review**: Has it undergone formal peer review?
- **Predatory journal check**: Is the journal indexed in DOAJ, Scopus, or Web of Science? If not, verify legitimacy. Watch for hallmarks of predatory publishing: aggressive solicitation, rapid "peer review" (days), broad unfocused scope, opaque editorial board.

### 4. Accuracy
- Are claims supported by evidence (data, citations)?
- Is the methodology sound? (See Methodological Rigor below)
- Can key findings be corroborated by other independent sources?
- Are there factual errors, logical fallacies, or unsupported claims?
- Are limitations acknowledged?

### 5. Purpose and Bias
- Why was this produced? To inform, persuade, sell, advocate?
- **Funding sources**: Who funded the research? Any conflicts of interest?
- **Ideological framing**: Does the source take a strong advocacy position? Is evidence presented selectively?
- **Publication bias**: Positive/significant results are more likely to be published. Consider the file-drawer problem.
- Is the framing balanced, or does it systematically favor one interpretation?

## Methodological Rigor Assessment

For empirical studies, assess:

| Criterion | Questions to Ask |
|-----------|-----------------|
| **Study design** | Is it appropriate for the research question? (RCT, quasi-experimental, observational, qualitative, mixed methods) |
| **Sample** | Adequate size? Representative? How was it selected? Response rate (for surveys)? |
| **Data quality** | Reliable instruments? Validated measures? Clear operationalization of concepts? |
| **Analysis** | Appropriate statistical or analytical methods? Pre-registered? Multiple testing corrections? |
| **Confounders** | Are alternative explanations addressed? Are there obvious uncontrolled confounders? |
| **Limitations** | Are limitations honestly acknowledged? Are conclusions proportionate to the evidence? |
| **Reproducibility** | Is the methodology described in sufficient detail to replicate? Data and code available? |
| **Ethics** | IRB/ethics approval? Informed consent? Appropriate protections for vulnerable populations? |

## Source Type Trustworthiness Guide

Sources are listed roughly from strongest to weakest established quality controls. Within each level, individual sources vary widely.

### Tier 1: Highest Established Quality Controls
- **Well-conducted systematic reviews and meta-analyses** following PRISMA guidelines
- **Peer-reviewed empirical studies** in established, indexed journals with transparent methods

### Tier 2: Strong but Variable Quality Controls
- **Peer-reviewed theoretical/conceptual papers** in established journals
- **Books from academic presses** (typically editor-reviewed and sometimes peer-reviewed)
- **Government statistical publications** from established statistical agencies (BJS, Census, ONS, etc.)

### Tier 3: Moderate Quality Controls
- **Preprints** from established researchers in recognized servers (arXiv, SSRN, medRxiv)
  - Note: research shows preprint findings correlate 0.99 with final published versions on average, but individual papers may change substantially
  - Always check for a published version and cite that preferentially
- **Conference proceedings** from top venues (varies: NeurIPS is rigorous; some conferences have minimal review)
- **Theses and dissertations** (committee review, but rigor varies by institution)
- **Reports from major IGOs** (WHO, World Bank, UN agencies) — undergo internal review

### Tier 4: Limited Quality Controls
- **Working papers and technical reports** from research institutions
- **Reports from credible NGOs** (HRDAG, Amnesty, HRW) — typically have internal review and methodological rigor but are not peer-reviewed
- **Policy briefs from think tanks** — evaluate the think tank's reputation and ideological orientation

### Tier 5: Minimal Formal Quality Controls
- **News articles** from reputable outlets — useful for context, not primary evidence
- **Blog posts by domain experts** — may contain valuable insights but need corroboration
- **Organizational websites and press releases** — treat as primary sources about the organization, not as evidence

### Tier 6: Use with Extreme Caution
- **Social media posts** — only for documenting public discourse or as leads
- **Opinion pieces and editorials** — represent viewpoints, not evidence
- **Sources from predatory journals** — do not include unless critically analyzed as an example of poor scholarship

## Practical Decision Rules

1. **When in doubt, include with caveats rather than exclude**: Note the source's limitations rather than silently omitting potentially relevant work. The user can decide.

2. **Always prefer the peer-reviewed version**: If both a preprint and published version exist, cite the published version but note if significant changes occurred.

3. **Triangulate**: A finding supported by multiple independent sources using different methods is more trustworthy than any single study, regardless of where it was published.

4. **Context matters**: A well-conducted NGO report with transparent methodology may be more trustworthy than a peer-reviewed paper in a low-quality journal. Evaluate the actual work, not just the venue.

5. **Be especially critical of**:
   - Studies whose conclusions perfectly align with funder interests
   - Extraordinary claims supported by a single study
   - Studies with very small samples making broad generalizations
   - Papers with methodological choices that consistently favor a particular outcome
   - Sources that do not acknowledge any limitations

6. **For human rights documentation**: Reports from organizations with established documentation methodologies (HRDAG, Amnesty, HRW, truth commissions) carry substantial weight even though they are not peer-reviewed, because they often apply rigorous evidence standards developed for legal and forensic contexts.

## Red Flags

Automatically flag sources that exhibit:
- No author attribution or anonymous authorship without justification
- No references or citations
- Published in a suspected predatory journal
- Makes extraordinary claims without proportionate evidence
- Contains logical fallacies or misrepresents cited sources
- Funded by parties with direct financial interest in the outcome
- Cannot be found in any recognized index or database
- URL or publication venue has changed or disappeared
