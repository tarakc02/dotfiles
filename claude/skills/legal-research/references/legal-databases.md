# Legal Research Databases and Sources

## Free Case Law Databases

| Database | URL | Coverage | API | Notes |
|----------|-----|----------|-----|-------|
| **Google Scholar** (Case Law) | https://scholar.google.com/ | State appellate/supreme (1950+), federal (1923+), SCOTUS (1791+) | No | "Cited by" and "How cited" features. Broadest free case law search. No citator. |
| **CourtListener** | https://www.courtlistener.com/ | 9M+ opinions from 2,000+ courts. 99%+ of precedential U.S. case law. | REST API, bulk data, semantic search API | Best free legal data ecosystem. Includes RECAP archive of federal filings. |
| **Caselaw Access Project** | https://case.law/ | 6.7M cases, 360 years. Digitized from Harvard Law Library. | REST API, bulk downloads, Hugging Face dataset | Some jurisdictions have restricted access. |
| **Justia** | https://law.justia.com/ | Federal and state case law, codes, regulations. SCOTUS 1791-present. | No | Free case law summaries. Email alerts for new opinions from any court. |
| **FindLaw** | https://caselaw.findlaw.com/ | Federal and state court opinions. CA Court of Appeal since 1934. | No | May not reflect most recent version. |
| **vLex/Fastcase** | https://www.fastcase.com/ | Federal and state cases, statutes, regulations, court rules. | No | **Free via California Lawyers Association membership.** |

## California-Specific Court Resources

| Source | URL | Coverage | Notes |
|--------|-----|----------|-------|
| **CA Appellate Courts Case Info** | https://appellatecases.courtinfo.ca.gov/ | Supreme Court and Court of Appeal: case info, dockets, published/unpublished opinions, briefs | Updated hourly during business days. Search by case number, caption, party, attorney. Email notifications. |
| **CA Official Reports Opinions** | https://courts.ca.gov/opinions | Official opinions 1850-present | Free service via LexisNexis. Post-filing corrections reflected. |
| **CA Judicial Council Forms & Rules** | https://courts.ca.gov/rules-forms | All mandatory/optional forms. California Rules of Court. | Updated Jan 1 and Jul 1. |
| **Justia California Cases** | https://law.justia.com/cases/california/ | Court of Appeal and Supreme Court decisions | Browse chronologically or by citation. |

## Commercial Databases (Subscription)

| Database | Key Features |
|----------|-------------|
| **Westlaw** (westlaw.com) | KeyCite citator, West Key Number System, CoCounsel AI, Practical Law |
| **Lexis+** (lexisnexis.com) | Shepard's citator, Lexis+ AI, Moore's Federal Practice |
| **Bloomberg Law** (bloomberglaw.com) | BCite citator, all-inclusive pricing, docket search |

## Federal Court Systems

| Source | URL | Cost | Coverage |
|--------|-----|------|----------|
| **PACER** | https://pacer.uscourts.gov/ | $0.10/page (max $3/doc; waived under $30/quarter) | 1B+ documents from all federal courts |
| **RECAP Archive** | https://www.courtlistener.com/recap/ | Free | Largest open collection of federal filings. Search alerts for monitoring PACER filings. |
| **UniCourt** | https://unicourt.com/ | Free searches; API from $49/month | 2B+ dockets across 4,000+ state and federal courts |

## Legislative and Statutory Sources

| Source | URL | Cost | Coverage | API |
|--------|-----|------|----------|-----|
| **CA Legislative Information** | https://leginfo.legislature.ca.gov/ | Free | All 29 CA Codes. Bills 1999-present. Committee analyses. Bill tracking with email alerts. | No |
| **CA Penal Code** | leginfo (tocCode=PEN) | Free | Full text including 745 (RJA) | No |
| **LegiScan** | https://legiscan.com/ | Free tier | All 50 states + Congress. Bill text, sponsors, votes. | REST API, 30K queries/month free |
| **Congress.gov** | https://congress.gov/ | Free | Federal legislation, Congressional Record | API with free key |
| **GovInfo** | https://www.govinfo.gov/ | Free | Federal Register, CFR, U.S. Code | API via api.data.gov |
| **Cornell LII** | https://www.law.cornell.edu/ | Free | U.S. Code, CFR, SCOTUS opinions, Wex legal encyclopedia | No |

## Legal Scholarship

| Source | URL | Cost | Notes |
|--------|-----|------|-------|
| **SSRN Legal Scholarship** | https://www.ssrn.com/index.cfm/en/lsn/ | Free | 750K+ abstracts, most with free PDF. Primary legal preprint venue. |
| **Law Review Commons** | https://lawreviewcommons.com/ | Free | Largest free law review collection. |
| **Google Scholar** | https://scholar.google.com/ | Free | Law reviews and legal scholarship. "Cited by" tracking. |
| **HeinOnline** | https://heinonline.org/ | Institutional | 1,700+ law journals. Historical legal materials. Most comprehensive. |

## Police Accountability and Criminal Justice Data

| Source | URL | Cost | Notes |
|--------|-----|------|-------|
| **National Police Index** | https://invisible.institute/national-police-index | Free | Employment histories from 23 states. Identifies wandering officers. Led by Invisible Institute, Innocence Project NOLA, and HRDAG. |
| **Police Records Access Project** | https://bids.berkeley.edu/california-police-records-access-project | Free | 1.5M pages from ~700 CA agencies. SB-1421/SB-16 records. UC Berkeley + Stanford. |
| **CA OpenJustice** | https://openjustice.doj.ca.gov/ | Free | CA DOJ criminal justice data. Arrests, use of force, deaths in custody. Downloadable datasets. |
| **RIPA Stop Data** | https://oag.ca.gov/ab953/board | Free | ~5.1M police stops from 533 agencies. Racial profiling analysis. |
| **Mapping Police Violence** | https://mappingpoliceviolence.org/ | Free | Police killings data. Updated weekly. Downloadable. |
| **POST Decertification List** | https://post.ca.gov/Decertification-List | Free | Officers decertified under SB 2. |
| **Civil Rights Litigation Clearinghouse** | https://clearinghouse.net/ | Free | U Michigan database of large-scale civil rights cases. Consent decrees, reform cases. |
| **Paper Prisons RJA Data Tool** | https://rja.paperprisons.org/ | Free | CA DOJ CORI data. Racial disparities by county, charge, year. |

## Open Source Tools

| Tool | URL | Notes |
|------|-----|-------|
| **Juriscraper** | https://github.com/freelawproject/juriscraper | Python library for scraping court websites. `pip install juriscraper`. BSD license. |
| **CourtListener API** | https://www.courtlistener.com/help/api/ | REST API. Semantic search (2025). Bulk data. Webhooks. No auth for basic. |
| **CAP API** | https://api.case.law/ | REST API for 6.7M cases. Bulk downloads. |

## Legal Blogs and Commentary

| Source | URL | Focus |
|--------|-----|-------|
| **SCOTUSblog** | https://www.scotusblog.com/ | U.S. Supreme Court coverage and analysis |
| **The Appeal** | https://theappeal.org/ | Criminal justice reform news and analysis |
| **Lawfare** | https://www.lawfaremedia.org/ | National security, law, and policy |
| **EFF** | https://www.eff.org/ | Digital privacy, surveillance, 4th Amendment |
| **EPIC** | https://epic.org/ | Privacy law, FOIA, 4th Amendment |
| **ACLU NorCal** | https://www.aclunc.org/ | California civil liberties, police accountability |

## Recommended Search Order

1. **Identify the statute** on leginfo.legislature.ca.gov
2. **Search for interpreting cases** on Google Scholar Case Law (free, broadest coverage)
3. **Supplement with CourtListener** (stronger semantic search, RECAP filings)
4. **Check CA official opinions** at courts.ca.gov/opinions for recent CA appellate decisions
5. **Use Fastcase** (free via CLA) for additional coverage
6. **Citation chain** from key cases using Google Scholar "Cited by"
7. **Search legal scholarship** on SSRN and Google Scholar for law review analysis
8. **Check specialized databases** for focus area data (OpenJustice, Police Records Access Project, etc.)
