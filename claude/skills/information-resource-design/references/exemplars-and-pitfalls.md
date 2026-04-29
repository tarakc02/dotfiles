# Exemplars and Pitfalls

Annotated case studies of real information resources, plus a consolidated catalog of anti-patterns. Use as a sanity check against design decisions: "would this system make this choice? does any system make the choice I'm tempted to make?"

## Contents

- [Exemplar systems](#exemplar-systems)
  - [OCCRP Aleph](#occrp-aleph)
  - [ICIJ Offshore Leaks](#icij-offshore-leaks)
  - [ICIJ Datashare](#icij-datashare)
  - [HURIDOCS Uwazi](#huridocs-uwazi)
  - [DocumentCloud](#documentcloud)
  - [Project Blacklight](#project-blacklight)
  - [CourtListener / RECAP](#courtlistener--recap)
  - [Internet Archive collections](#internet-archive-collections)
  - [Europeana](#europeana)
- [Synthesis: shared patterns of strong systems](#synthesis-shared-patterns-of-strong-systems)
- [Anti-pattern catalog](#anti-pattern-catalog)

## Exemplar systems

### OCCRP Aleph

URL: `aleph.occrp.org`. Investigative cross-border data platform.

**Strengths:**
- Type-aware faceting: results split by entity type (companies, people, addresses) before keyword filtering. The corpus-as-map principle in action.
- Schema icons compress entity-type information into a glyph - excellent for heterogeneous result lists.
- Dataset facet shows provenance, essential for journalists who need to cite source.
- Multilingual UI (six languages); OCR makes scanned docs first-class.
- Operators (`AND/OR/NOT`, fuzzy `~3`, proximity, `name:Value` field-scoping) uniformly available across all search surfaces.
- Cross-reference is a separate first-class tool, not buried in search options.
- Networks/timelines are peers of search, not appendages.
- "Investigations" model lets reporters bookmark and tag results into shared workspaces.

**Weaknesses:**
- Pop-up document viewer breaks back-button mental models.
- Faceted sidebar overwhelming on broad queries; long facet lists default expanded.
- Entity disambiguation surfaces too many near-duplicates without merging hints.
- High-confidence (structured leak) and low-confidence (NER from PDFs) values look identical in property tables.
- Advanced query syntax documented but not progressively disclosed in the UI.
- Fully global default scope produces overwhelming, mixed-schema noise for new users.

**Takeaway:** schema icons + dataset badges + cross-reference tool worth emulating. Avoid the pop-up viewer; route to a real URL.

### ICIJ Offshore Leaks

URL: `offshoreleaks.icij.org`. Public-facing investigative database.

**Strengths:**
- Single-input simplicity - exemplary "one box" commitment for a non-expert audience.
- Placeholder-as-grammar-tutorial: `"British Virgin Islands | Entity Name LLC | Lima, Peru"` teaches what tokens the field accepts.
- Type filter (Entities/Officers/Intermediaries/Addresses) on the left + Jurisdiction facet on the right is a clean two-axis split.
- Sigma.js relationship visualization pairs keyword search with browse view.
- Source-leak badges on every row keep provenance visible.
- Explicit data-currency note on every record ("Provider data is current through 2018").
- Sketches were prototyped with international collaborators - genuinely culture-neutral UI.

**Weaknesses:**
- No snippet of *why* a result matched - users must click through to understand context.
- No saved-search functionality.
- English-only UI given globally relevant subject matter.
- Status field plain text, missing color/iconography for sweep-reading.

**Takeaway:** the placeholder tutorial and per-row provenance badges are immediately copyable. The lack of match snippets is the clearest weakness.

### ICIJ Datashare

URL: self-hosted; demo at `datashare-demo.icij.org`. Investigative document search and review.

**Strengths (post-Aug-2025 redesign):**
- Three collapsible filter groups (documents info / user data / entities) - prevents the long-scroll-of-facets default.
- **Exclude** option per filter value, with strikethrough on the breadcrumb chip - unusually honest about negative filtering.
- **Contextualize** option recomputes facet counts against current selections - the right answer to "are these counts pre- or post-filter?"
- Breadcrumb above results carries every applied filter with a single "Clear filters."
- Named entities (people, orgs, locations, emails) highlighted in the document viewer and exposed as facets.
- Batch search has its own page with query-level result counts upfront.
- Dark mode, larger hit targets, keyboard nav and screen-reader labels guided by an accessibility consultant.
- Settings page for choosing which document metadata appears.

**Weaknesses:**
- Self-hosted-only; no canonical hosted instance for newcomers.
- Heavy NER reliance means non-Latin-script and minority-language documents get fewer entity highlights.
- Three filter groups still leaves long inner lists.

**Takeaway:** Datashare's "Exclude + strikethrough chip" and "Contextualize counts" are the two most copyable innovations. Filter grouping (3-4 collapsibles) is the right default for any system with many facets.

### HURIDOCS Uwazi

URL: `huridocs.org/technology/uwazi`. Human rights document management.

**Strengths:**
- Library is the central object with three view toggles: **Cards / Table / Map** (map enabled when entities have geolocation).
- Three-state thesaurus filters: full-group, partial-with-deselects, locked-group-includes-future-terms. Filters that "future-proof" themselves as new terms arrive.
- Per-record translation, not just UI translation. 180+ languages including RTL (Arabic).
- Yellow-as-reference is consistent across viewer and library.
- First-class connections UI: "Information Hub" tree of related entities with collapse/expand. Relationship Types are admin-configurable.
- In-document search with chronologically ordered, clickable hits.
- Wildcards, proximity, boolean ops, exact phrases all supported.
- Right-sidebar peek + full view preserves list context.

**Weaknesses:**
- Filter terminology (Visibility / Permission / Primary / Secondary) has a learning curve.
- Information Hub trees can sprawl on dense investigations.
- Map mode is conditional on geocoding quality.
- No public a11y statement.

**Takeaway:** Uwazi sets the bar for multilingual content (per-record translation). The three-state thesaurus filter is a clever pattern for evolving taxonomies.

### DocumentCloud

URL: `documentcloud.org`. Newsroom-focused document publishing and viewing.

**Strengths:**
- Two-pane viewer: page image left, OCR text right, scrollable in lockstep. OCR pane is *selectable* (copy quotes); image pane is canonical for visual evidence.
- Annotations float over the page as semi-transparent rectangles; clicking opens a sidebar.
- Page navigator filmstrip on the left rail - Tufte-style small multiples doubling as navigation.
- Annotation access tiers (private / collaborator / public) cleanly map to newsroom workflows.
- 2025 update grafts OCR back into the underlying PDF on download - thoughtful provenance/portability.
- Embed-aware: sidebar-hideable, page-embed primitive separate from full-doc embed.
- Single-letter keyboard shortcuts (`A` annotate, `R` redact) for common verbs.
- Saved searches in a left sidebar with rename/edit (April 2026 update).

**Weaknesses:**
- Search results table sparse; only ~10 rows fit. Power users want density.
- No confidence indicator on OCR; users have no signal that page 47's text was poorly recognized.
- Heavy reliance on premium "AI credits" for the better OCR engines.
- Limited faceted browsing compared to peers.
- Annotation styling is dated.

**Takeaway:** the dual-pane viewer with synchronized scroll is the right baseline for any document viewer. The annotation access tiers (exactly three) are the right granularity.

### Project Blacklight

URL: `projectblacklight.org`; instance: `searchworks.stanford.edu` (Stanford library catalog).

**Strengths:**
- Constraint-pill pattern for applied filters with single-click removal - the canonical pattern most others copy.
- Pivot (hierarchical) facets out of the box.
- "Bookmarks" as first-class - users can collect items across sessions.
- Result-context preserved into the record page (Previous/Next within result set).
- Scoped-field dropdown (All / Title / Author / Subject / Call number / Series).
- Long a11y commitment in the issue tracker; semantic landmarks, proper `<nav>`, skip-to-content links in most implementations.

**Weaknesses:**
- Default look is dated without theming.
- Facet sidebars get long without a "more"-with-search affordance.
- Pivot facets visually look like normal facets - hierarchy poorly discoverable.
- Mobile defaults push facets below results, hurting refine-then-browse workflows.

**Takeaway:** Blacklight defined the constraint-pill + Previous/Next-within-result patterns. Both are non-negotiable for any search-result/detail-page combination.

### CourtListener / RECAP

URL: `courtlistener.com`. Free Law Project's open court records platform.

**Strengths:**
- Result-type tabs (Opinions / RECAP / Oral Arguments / Judges / Parties / Citations) make scope unambiguous.
- Durable URL slugs (`/opinion/<id>/<slug>/`) with case names - excellent for citation.
- Docket page mirrors the chronological mental model lawyers use.
- Honest UI: when content isn't available, tells you to go pay PACER.
- Field-level filter inputs (jurisdiction, precedential status, filed date, judge, citation, docket number).
- Operators (`q=` syntax) mirror what the front-end sends - copying GET params is recommended for API users.
- Saved-search alerting model.

**Weaknesses:**
- Visual density borders on overwhelming.
- No in-app PDF viewer with hit highlighting.
- Filter UI is a sidebar of inputs rather than facets-with-counts; harder to graze.
- Sparse use of icons leaves text columns to do all scan-work.

**Takeaway:** durable URL slugs and the chronological docket page are the model for any timeline-shaped corpus.

### Internet Archive collections

URL: `archive.org/details/...`. Vast cross-domain digital library.

**Strengths:**
- "Theater" layout cleanly separates artifact (left, large) from metadata (right sidebar).
- View counts as social-proof metadata.
- BookReader: search-this-book with thumbnail jump-list of hits, full-screen, zoom, share-with-page-anchor.
- Share-with-page-anchor preserves citation depth.
- Mediatype icon strip in top nav acts as scope filter.

**Weaknesses:**
- Mediatype icons inscrutable to first-timers (no labels).
- Facet rail and sort tabs have duplicate-but-non-overlapping responsibilities, confusing users.
- Visual hierarchy on item pages buries crucial metadata below fold.
- BookReader auto-hide toolbar is a known a11y irritant.

**Takeaway:** the theater layout and search-this-book with thumbnails are excellent. Avoid icon-only navigation without text labels.

### Europeana

URL: `europeana.eu`. Aggregated European cultural heritage.

**Strengths:**
- Rights/license is a top-level facet - exemplary for a public archive where re-use status matters.
- Three-view toggle (grid / mosaic / list) lets users self-select an a11y-friendly variant.
- Honest accessibility statement that names specific known issues (Masonry focus order, hover-only quick actions).
- Aggressive multilingual: per-language UI, multi-lingual content fields with language preferences. RTL where source language is RTL.

**Weaknesses:**
- Masonry focus order - explicitly broken (per their own statement).
- Hover-only quick actions in grid/mosaic views - explicitly inaccessible.
- Heavy provider-attribution overhead can crowd metadata.
- Default view varies between visits, hurting muscle memory.

**Takeaway:** rights/license as a first-class facet is uniquely valuable for cultural-heritage and human-rights archives. The honest a11y statement is itself a model for any public system.

## Synthesis: shared patterns of strong systems

1. **Provenance is always visible at the row level.** Aleph (dataset badge), Offshore Leaks (source-leak badge + data-currency stamp), DocumentCloud (annotation access tier), Europeana (provider + rights facet). Systems that bury provenance lose trust quickly.

2. **Heterogeneity is compressed via icons.** Aleph's schema icons, Blacklight's format icons, Internet Archive's mediatype icons. When result lists mix entity/object types, glyphs do triage that text columns can't.

3. **Applied filters are first-class chips with one-click removal.** Blacklight's constraint pills are canonical; Datashare extended with strikethrough for excludes. Systems without this leave users feeling lost.

4. **Counts must be honest.** Datashare's "Contextualize" recomputes facet counts against current selections.

5. **Detail pages preserve list context.** Blacklight's Previous/Next within result set, Datashare's carousel between documents.

6. **OCR text + image, side-by-side, scroll-synced** is the document-viewer baseline (DocumentCloud).

7. **Operators belong in the same input as plain queries** (Aleph, CourtListener), with progressive disclosure of an "advanced" panel that builds on the current query.

8. **Annotations have at most three access tiers** (DocumentCloud: private / collaborator / public). More invites mis-set permissions.

9. **Yellow at 30-50% alpha is the convention** for hit highlighting and reference highlighting (Aleph, Uwazi, DocumentCloud).

10. **Multilingual is content-level, not just UI-level** (Uwazi). Half-translated experiences are worse than unilingual ones.

## Anti-pattern catalog

Distilled from the case studies and the design principles in this skill. Each is a thing you might be tempted to do; don't.

### Search and discovery

1. **Hidden filter state.** Applying a facet but only showing it in the sidebar - users scroll, forget, misread the count. Always render applied filters as chips above results.
2. **"Apply" button when the backend is fast.** Forcing a click after every checkbox doubles interaction cost. Right for slow backends, wrong for fast ones.
3. **Hiding zero-count facets.** Users can't tell whether the dataset has none or just none under their current query. Gray out, keep visible.
4. **Custom non-`<select>` sort.** Inventing a sort dropdown without keyboard support or proper listbox role. Native `<select>` is free, accessible, mobile-correct.
5. **Replacing the search box with the suggestion dropdown.** Picking a suggestion should fill the input AND submit, not navigate while leaving the field empty.
6. **Truncating snippets without context.** Title + generic blurb without the matched terms means users have no idea why a result is in the list.
7. **State only in component memory.** Filters and queries that don't survive refresh, can't be shared, can't be bookmarked. URL is the cheapest, most powerful state store.
8. **Search-within-results that secretly resets.** Always label "Search within these results" and visualize that both queries are now active.
9. **Modal advanced-search.** A `/advanced` page that drops the user's current query when they navigate to it.
10. **Iconography without accessible names.** Magnifier-only button with no `aria-label`; filter-chip × that's a span, not a button.

### Tables and records

11. **Overusing `react-data-grid` / ag-Grid for read-mostly archives.** Optimized for spreadsheet editing; adds ~200KB of JS, complex theming, broken anchor links from virtualization. Plain `<table>` + Tailwind + TanStack Table covers 80%.
12. **Confidence as a single number with no visual encoding.** `0.73` in small gray font is invisible. Use bar + color + number + tier.
13. **Modal dialogs for record detail.** Modals lose URL addressability. Always use a route.
14. **Truncating with ellipsis but no expand affordance.** `John Smit…` with no recovery is hostile.
15. **Sorting that re-fetches and resets scroll position.** Server-side sorting is fine; preserve scroll offset and selection.
16. **Hiding provenance behind an "i" icon.** Provenance is the data; citation chips next to values, always.
17. **Gridlines everywhere.** Heavy 1px borders on every cell create a visual cage. Single hairline below header + whitespace between rows is enough.
18. **Density-toggle that doesn't persist.** Users who pick "compact" once mean it. Persist per-table to localStorage.
19. **Detail pages without breadcrumbs.** Click in, lose collection context. Always render the path.
20. **Conflating "selection" with "navigation."** A checkbox column for bulk operations and a clickable row for navigation should coexist; don't make the whole row a checkbox toggle.

### Visual language

21. **Too many type sizes.** Limit to 5-7 sizes total. If you need a new size, ask whether weight or space changes solve it.
22. **Color as decoration.** Colored row backgrounds, colored icons in nav, accent colors on every card. Reserve color for meaning.
23. **Heavy borders and dividers.** 1px borders on every cell, card, and panel turn the UI into graph paper.
24. **Drop shadows on everything.** Material-style elevation shadows on every card date the UI. Reserve for *truly* floating elements (popovers, modals).
25. **Centered body text and full-bleed columns.** Long lines (>90 characters) and centered prose are unreadable.
26. **Mismatched numerals in tables.** Proportional figures make ones look smaller than zeros. Always `tabular-nums`.
27. **Mixing icon styles.** Line + filled + duotone in the same product. Pick one.
28. **Pure white on pure black (and vice versa).** Halation in dark mode, glare in light mode. Use `oklch(0.985)` light, `oklch(0.94)` dark text.
29. **Status conveyed by color alone.** Always pair color with icon or label.
30. **Animated transitions on data updates.** Sliding rows and fading cells slow scanning. Reserve animation for state changes the user initiated; respect `prefers-reduced-motion`.

### Document viewers

31. **Pop-up viewers that break the back button.** (Aleph's mistake.) Always a route.
32. **Image without OCR text fallback.** Screen readers can't read images.
33. **Pixel-coordinate bbox storage.** Breaks responsive and zoom; use fractional coordinates.
34. **Annotation styles for "public" and "private" that look identical.** Users will mis-set permissions.
35. **Keyboard shortcuts as the only access path.** Every shortcut needs a button.

### Inclusive design

36. `<div>` grids with `role="row"`/`role="cell"` for static tabular data.
37. `aria-live="assertive"` on result counters - interrupts every other announcement.
38. Tab into every checkbox in a 200-item facet panel (use roving tabindex).
39. Removing focus outlines globally (`*:focus { outline: none }`).
40. A single `dir="ltr"` `<html>` with RTL content forced via per-element overrides.
41. Separate stylesheets for RTL - divergence is inevitable.
42. Truncating non-Latin text by character count (`str.slice(0, 40)`) - combining marks break.
43. Flags as language indicators.
44. Hard-coded `MM/DD/YYYY` or `1,234.56` formats.

### Trustworthy display

45. A generic "Sources" footer link instead of per-claim citation.
46. Model-extracted fields presented identically to verified fields.
47. Confidence as a single percentage with two decimal places.
48. "Last updated" with no record of *what* changed.
49. Hiding low-confidence fields to make the dataset "look cleaner."
50. Tooltips as the sole channel for provenance - not keyboard-reachable, invisible on print/export.
51. A single global "show graphic content" gate that, once accepted, reveals everything forever.
52. Decorative photography of suffering on landing pages.
53. Hover-to-reveal as the only mechanism for sensitive content.
54. Notifications that surface graphic content in previews.
55. Achievements/badges for "records reviewed" on volunteer interfaces in atrocity contexts.
56. Heat maps where redder = more deaths, with no legend acknowledging human cost.
