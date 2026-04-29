---
name: information-resource-design
description: UI/UX design patterns for information-dense, content-first applications - searchable archives, document collections, record databases, investigative platforms, evidence repositories, and human rights data resources. Use when designing or building front-ends where the data is central and the UI supports searching, browsing, viewing tables of records, exploring extracted/structured fields, or reviewing source documents. Covers faceted search, dense data tables, document viewers, record detail pages, typography for data, accessibility for complex UIs, multilingual/RTL display, sensitive-content handling, and provenance/confidence indicators. Prefer this over generic frontend design guidance when the application is content-first (records, documents, evidence, archives) rather than marketing/transactional. Triggers include phrases like "search interface", "record database", "document archive", "faceted search", "data table for records", "evidence viewer", "investigative platform", "human rights archive".
---

# Information Resource Design

Design guidance for front-ends over unstructured document collections and structured-extraction archives. The data is the product; the UI's job is to make it findable, scannable, citable, and trustworthy.

## When to apply this skill

Apply when building any of:
- A search interface over a document/record corpus (10s to millions of items)
- A record-detail page that pairs structured fields with source documents
- A data table for browsing extracted fields, victims/incidents, cases, entities
- A document viewer with OCR text, annotations, or citations
- An archive landing page that supports both lookup and exploration

Skip this skill for marketing pages, transactional checkouts, generic CRUD admin panels, or single-record forms - those are better served by general frontend guidance.

## Top-level principles

These eight principles are the trunk; every reference file is a branch.

**1. The data is the figure; chrome is the ground.** Strip dividers, shadows, gradients, decorative color until removing one more would break the layout. Hierarchy through whitespace and weight, not borders and color.

**2. URL is the source of truth for query state.** Search query, applied filters, sort, page, density - all in the URL. This gives free saved searches, free sharing, free back-button. State trapped in component memory is hostile to investigative work where citation matters.

**3. Provenance is always visible at the row level.** Source dataset, last-updated date, citation chips next to extracted values. Never make users open a record to learn where data came from. If something is unsourced, label it "unsourced" - silence reads as cover-up.

**4. Lookup and exploration are different jobs; design for both.** Casual users arrive with a name and want a ranked list; investigators want to browse the corpus's structure (facets as a map, timelines, entity graphs). Pair every result list with at least one orthogonal view.

**5. Density is a setting, not a default.** Provide compact/comfortable/spacious modes for tables and result lists; persist the choice. Default comfortable for newcomers, let power users opt into compact.

**6. Distinguish source-of-truth from extracted/inferred values.** A `birthDate` from a structured leak and one from NER on a scanned passport must look different in the UI. Visual treatment - badges, color, confidence bars - not just metadata.

**7. Default to safety, control, and dignity for sensitive content.** Graphic media blurred by default; warnings describe specifically what is shown ("human remains" not "graphic content"); user can set per-category preferences and they persist; no gamification of harm; survivor-centered microcopy ("people killed" not "kills").

**8. Multilingual and accessible from day one.** Human rights collections are rarely monolingual. Pick fonts with broad script coverage, use logical CSS properties, tag every language span. Native HTML semantics outperform ARIA retrofits; visible focus is non-negotiable in dense UIs.

## Recommended stack

Framework-agnostic principles, but when implementing, prefer lightweight and flexible over heavy:

- **HTML/CSS first, framework second.** A real `<table>`, `<form role="search">`, `<details>`, `<dialog>` carry semantics for free. Reach for ARIA only when native semantics don't exist.
- **React or any modern framework is fine.** Examples in this skill use React + Tailwind because they're the lowest-friction path; the patterns translate to Vue, Svelte, plain HTML, or server-rendered templates.
- **Tables: TanStack Table** (sort/filter/pagination logic, headless) over heavy data-grid suites (ag-Grid, react-data-grid). Skip virtualization until rows >500.
- **Components: shadcn/ui or Radix primitives** for accessible popovers, dialogs, comboboxes. Avoid component libraries that ship a strong visual identity (Material-UI, Ant Design) - they fight the "chrome disappears" principle.
- **Styling: Tailwind** for utility-first CSS, or plain CSS with custom properties. Avoid CSS-in-JS for runtime overhead.
- **Icons: Lucide or Heroicons** (line-style, MIT). Carbon Icons for more restrained civic/data work.
- **Fonts: Inter** (UI), **Source Serif 4** (long-form), **JetBrains Mono** (IDs/code), with **Noto** family for non-Latin scripts. System stack as zero-network fallback.
- **No URL-state library needed.** Plain `URLSearchParams` + framework router covers it.

## How to approach a new design task

1. **Identify the corpus shape** - how many records, how heterogeneous, how structured, how sensitive, what languages, what user goals (lookup vs exploration).
2. **Sketch the URL schema before any visuals.** What goes in the query string? `?q=...&type=...&country=...&sort=...&page=...&density=...`
3. **Build the search/results path first.** Search box, facets, results list with snippets, applied-filter chips, zero-result state. URL-driven from the start.
4. **Build the record detail page second.** Side-by-side source + extracted fields, citation chips, related-records sidebar, breadcrumb.
5. **Add the document viewer if needed.** Image + bbox overlay; OCR text fallback; page-anchor URLs; in-document search.
6. **Layer on cross-cutting concerns throughout, not at the end** - keyboard nav, screen-reader semantics, content warnings, confidence indicators, language tagging.
7. **Test by actually using it.** Browse 20 records. Search for a known item and one you don't know. Apply 3 filters and bookmark the URL. Open in a screen reader. View on a phone. Switch to Arabic if relevant.

## Reference files - load as needed

Each reference file is focused enough to load only when actively working in that area. Files have tables of contents at the top.

| When you're working on... | Read |
|---|---|
| Search box, facets, filter UI, results list, autocomplete, mobile search tray | [search-and-discovery.md](references/search-and-discovery.md) |
| Data tables, sortable headers, density toggle, record detail pages, related-records sidebar, citation chips | [tables-and-records.md](references/tables-and-records.md) |
| PDF/image document viewer, OCR text overlay, highlights, annotations, page-anchor URLs | [document-viewers.md](references/document-viewers.md) |
| Typography (type scale, fonts, tabular nums), color (neutral + semantic palettes, dark mode), spacing/density tokens, iconography, microcopy | [visual-language.md](references/visual-language.md) |
| Accessibility for complex UIs (tables, faceted search, dialogs), keyboard navigation, screen-reader semantics, multilingual layout, RTL, non-Latin script display | [inclusive-design.md](references/inclusive-design.md) |
| Provenance display, source citations, confidence indicators, chain-of-custody UI, versioning, sensitive-content warnings, redaction display, dignified statistics | [trustworthy-display.md](references/trustworthy-display.md) |
| Annotated case studies of real systems (Aleph, ICIJ, Uwazi, DocumentCloud, Blacklight, Internet Archive, Europeana) and a catalog of anti-patterns | [exemplars-and-pitfalls.md](references/exemplars-and-pitfalls.md) |

When in doubt about a specific decision, the order of consultation is: top-level principle → relevant reference file → exemplar systems → ask the user.
