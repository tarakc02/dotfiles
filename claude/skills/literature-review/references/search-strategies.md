# Search Strategies for Literature Review

This reference covers how to construct effective, systematic search strategies for finding relevant literature.

## Step 1: Decompose the Research Question

Break the research question into 2-4 core concepts. Each concept becomes one dimension of your search.

**Example**: "What statistical methods have been used to estimate civilian casualties in armed conflict?"
- Concept 1: Statistical methods / estimation
- Concept 2: Civilian casualties / fatalities / deaths
- Concept 3: Armed conflict / war / violence

## Step 2: Generate Search Terms

For each concept, list:

| Term Type | Description | Example (for "civilian casualties") |
|-----------|-------------|--------------------------------------|
| **Primary terms** | Most direct terms | civilian casualties, civilian deaths |
| **Synonyms** | Alternative phrasings | fatalities, mortality, killings, body count |
| **Broader terms** | More general concepts | conflict deaths, war deaths, violence-related mortality |
| **Narrower terms** | More specific concepts | extrajudicial killings, mass atrocity deaths, collateral damage |
| **Related terms** | Adjacent concepts | casualty recording, death tolls, conflict mortality |
| **Disciplinary variants** | Field-specific terminology | excess mortality (epidemiology), lethal violence (criminology), civilian harm (IHL) |
| **Controlled vocabulary** | Database-specific indexed terms | MeSH: "Mortality"; JEL: C13 (estimation) |

### Tips for term generation
- Check how key authors in the field describe the topic
- Look at subject headings assigned to known relevant papers in databases
- Use thesaurus features in databases (PubMed MeSH browser, ERIC thesaurus)
- Consider both U.S. and British spellings (behavior/behaviour, labor/labour)

## Step 3: Construct Boolean Queries

### Boolean operators

| Operator | Effect | Usage |
|----------|--------|-------|
| **AND** | Narrows — requires ALL terms | Connect different concepts |
| **OR** | Broadens — requires ANY term | Connect synonyms within a concept |
| **NOT** | Excludes — removes results with term | Use sparingly; can remove relevant results |
| **" "** | Exact phrase | "multiple systems estimation" |
| ***** | Truncation / wildcard | estimat* → estimate, estimation, estimating, estimator |
| **( )** | Grouping | Group OR-connected synonyms before ANDing with other concepts |

### Query construction pattern

```
(Concept1_term1 OR Concept1_term2 OR Concept1_term3)
AND
(Concept2_term1 OR Concept2_term2 OR Concept2_term3)
AND
(Concept3_term1 OR Concept3_term2 OR Concept3_term3)
```

### Example query

```
("multiple systems estimation" OR "capture-recapture" OR "statistical estimation" OR "casualty estimation")
AND
("civilian casualties" OR "civilian deaths" OR "conflict mortality" OR "excess mortality" OR "fatalities")
AND
("armed conflict" OR "war" OR "violence" OR "mass atrocity" OR "human rights violations")
```

### Common mistakes to avoid
- Using AND when you mean OR (unnecessarily narrows results)
- Forgetting synonyms (misses relevant literature using different terms)
- Over-using NOT (removes potentially relevant results)
- Not using phrase searching for multi-word concepts
- Not using truncation for word variants

## Step 4: Select Databases

Choose databases based on the disciplines involved. See `references/academic-databases.md` for the full list.

**General rule**: Search at least 2-3 databases to ensure coverage. Different databases index different journals and use different algorithms.

### Adapting queries across databases
Each database has its own syntax. Common differences:
- Truncation symbol: `*` (most), `$` (some EBSCO), `?` (ProQuest for single character)
- Phrase searching: `" "` (most), some require specific field tags
- Proximity searching: `NEAR/n`, `W/n`, `ADJ` (varies by database)
- Field-specific searching: `[ti]` (PubMed), `TI=` (Web of Science), `title:` (various)
- Controlled vocabulary: MeSH (PubMed), Thesaurus (PsycINFO), Descriptors (ERIC)

## Step 5: Apply Filters and Limits

Use database filters judiciously:
- **Date range**: Match your scope (e.g., 2015-present, or no limit for seminal works)
- **Language**: English default, but note this introduces bias
- **Publication type**: Journal articles, reviews, conference papers, etc.
- **Subject area**: When databases span many fields

**Caution**: Apply filters AFTER running the initial search to see total results. Over-filtering misses relevant work.

## Step 6: Supplementary Search Methods

### Citation chaining
The single most effective way to find relevant literature beyond database searching.

**Backward chaining** (references):
- Review the reference lists of your most relevant papers
- Identify frequently cited foundational works
- Look for cited works that appear across multiple papers

**Forward chaining** (citing articles):
- Find papers that cite your key sources
- Use Semantic Scholar, Google Scholar "Cited by", or OpenAlex citation data
- Especially valuable for finding recent work that builds on established findings

### Hand searching key journals
For highly specialized topics, browse recent issues (last 2-3 years) of the 3-5 most relevant journals.

### Expert/author searching
- Search for recent publications by key authors in the field
- Check author profiles on Google Scholar, ORCID, or institutional pages

### Grey literature searching
For topics with significant policy or practice dimensions:
- Search specific organization websites (WHO, World Bank, RAND, relevant NGOs)
- Use `site:` operator in Google: `site:hrdag.org "multiple systems estimation"`
- Check Policy Commons and JSTOR Research Reports
- Search government document repositories (NCJRS for criminal justice, GPO for U.S. government)

## Step 7: Document Your Search

Record for each database searched:

| Field | What to Record |
|-------|----------------|
| Database name | e.g., PubMed, Scopus, Web of Science |
| Date of search | When the search was executed |
| Search string | Exact query as entered |
| Filters applied | Date range, language, publication type, etc. |
| Number of results | Total hits returned |
| Results exported | How many were screened |

This documentation is essential for:
- Reproducibility (especially for systematic reviews)
- Explaining the scope and limitations of the review
- Updating the review later

## Step 8: Screen Results

### Two-stage screening (for formal reviews)

**Title/abstract screening**:
- Apply inclusion/exclusion criteria to titles and abstracts
- When in doubt, include for full-text review
- Track reasons for exclusion

**Full-text screening**:
- Read full text of remaining candidates
- Apply inclusion/exclusion criteria more rigorously
- Track reasons for exclusion
- Extract key data for the synthesis matrix

### For less formal reviews
- Prioritize by relevance (title/abstract scan)
- Start with the most cited and most recent papers
- Follow citation chains from the best papers
- Stop when you reach saturation

## Iterative Refinement

Searching is iterative, not linear:
1. Run initial searches
2. Review results — too many? Too few? Wrong focus?
3. Adjust terms: add synonyms if too few results, add specificity if too many
4. Discover new terminology from relevant papers and incorporate it
5. Repeat until searches are stable and comprehensive

## Quick Reference: Search Strategy Checklist

- [ ] Research question decomposed into core concepts
- [ ] Synonyms and related terms identified for each concept
- [ ] Controlled vocabulary checked (MeSH, thesaurus terms)
- [ ] Boolean query constructed with proper grouping
- [ ] Multiple databases selected appropriate to discipline
- [ ] Query adapted for each database's syntax
- [ ] Filters applied judiciously (dates, language, type)
- [ ] Citation chaining from key papers (backward and forward)
- [ ] Grey literature sources searched if relevant
- [ ] Search documented (databases, dates, strings, results)
- [ ] Saturation assessed — are new searches yielding new relevant sources?
