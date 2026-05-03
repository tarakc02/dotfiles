# Tables and Record Detail Pages

Patterns for displaying tabular data and individual record pages where structured fields meet source documents.

## Contents

- [Core principles](#core-principles)
- [Pattern 1: Dense scannable table](#pattern-1-dense-scannable-table)
- [Pattern 2: Sortable headers](#pattern-2-sortable-headers)
- [Pattern 3: Sticky headers and first column](#pattern-3-sticky-headers-and-first-column)
- [Pattern 4: Column show/hide](#pattern-4-column-showhide)
- [Pattern 5: Density toggle](#pattern-5-density-toggle)
- [Pattern 6: Inline row expansion](#pattern-6-inline-row-expansion)
- [Pattern 7: Row-to-detail navigation with list context](#pattern-7-row-to-detail-navigation-with-list-context)
- [Pattern 8: Side-by-side source and extracted fields](#pattern-8-side-by-side-source-and-extracted-fields)
- [Pattern 9: Citation chips with hover preview](#pattern-9-citation-chips-with-hover-preview)
- [Pattern 10: Related-records sidebar](#pattern-10-related-records-sidebar)
- [Pattern 11: Breadcrumb provenance](#pattern-11-breadcrumb-provenance)
- [Typography for tabular data](#typography-for-tabular-data)
- [Build order](#build-order)

## Core principles

**Maximize data-ink, minimize chartjunk (Tufte).** Every pixel of border, shadow, and zebra stripe must justify itself. Prefer a single 1px hairline below the header and whitespace between rows. Zebra striping is appropriate only when row width exceeds ~10 columns or when rows wrap.

**Scan-first, then read (Few).** Users do not read top-to-bottom; they scan a column for outliers, then jump to a row. Left-align text, right-align numbers/counts/dates-as-numbers, and use tabular numerals so digits form a vertical grid.

**Density is a setting, not a default.** Material Design's 48px row height is wrong for archival work. Provide compact (28-32px), comfortable (40px), and spacious modes; persist the choice.

**Progressive disclosure of columns.** Show 5-8 columns by default - those that answer "is this the row I want?" Everything else lives behind a column-visibility menu, an inline expansion row, or the detail page.

**Sortability and stickiness are table stakes.** Every column header is sortable unless explicitly inappropriate (free-text notes). Header sticks on vertical scroll; the leftmost identifier column sticks on horizontal scroll.

**Source and extraction are co-equal on detail pages.** A detail page is not a form view of fields. It is a side-by-side or tabbed pairing of structured fields and source document, with bidirectional links: clicking a field highlights its provenance in the source; clicking a span in the source surfaces the field it populated.

**Detail pages are navigation hubs, not dead ends.** Same-source siblings, same-entity mentions, similar records, parent collection - the right-rail "related records" panel is how investigators move through the archive. Preserve list context: previous/next within the result set, plus a "back to results" that restores scroll and applied filters.

**No modal record detail pages.** A URL is the unit of citation in investigative work. Always use a route. Even when the visual treatment is a slide-over panel, the URL must update.

## Pattern 1: Dense scannable table

```tsx
<table className="w-full text-sm border-collapse">
  <thead>
    <tr className="border-b border-neutral-300 text-left">
      <th className="py-2 px-3 font-medium text-neutral-700">ID</th>
      <th className="py-2 px-3 font-medium text-neutral-700">Name</th>
      <th className="py-2 px-3 font-medium text-neutral-700 text-right">Date</th>
      <th className="py-2 px-3 font-medium text-neutral-700 text-right tabular-nums">Pages</th>
    </tr>
  </thead>
  <tbody>
    {rows.map(r => (
      <tr key={r.id} className="border-b border-neutral-100 hover:bg-amber-50">
        <td className="py-1.5 px-3 font-mono text-xs text-neutral-500">{r.id}</td>
        <td className="py-1.5 px-3">{r.name}</td>
        <td className="py-1.5 px-3 text-right tabular-nums">{r.date}</td>
        <td className="py-1.5 px-3 text-right tabular-nums">{r.pages}</td>
      </tr>
    ))}
  </tbody>
</table>
```

**A11y:** real `<table>`, `<th scope="col">`, `aria-sort` on sortable headers. Don't use `role="grid"` unless you implement full keyboard grid navigation - semantics must match implementation.

## Pattern 2: Sortable headers

```tsx
<th
  scope="col"
  aria-sort={sortKey === 'date' ? sortDir : 'none'}
  onClick={() => toggleSort('date')}
  className="cursor-pointer select-none hover:text-black"
>
  Date {sortKey === 'date' && (sortDir === 'ascending' ? '↑' : '↓')}
</th>
```

The entire header must be a `<button>` or have `role="button"` + `tabIndex={0}` + key handler for Enter/Space. Use real Unicode arrows or icon-font with `aria-hidden`; never communicate sort direction by color alone.

## Pattern 3: Sticky headers and first column

```css
.evidence-table thead th {
  position: sticky;
  top: 0;
  background: white;
  box-shadow: 0 1px 0 rgb(0 0 0 / 0.1);  /* sticky breaks border-bottom rendering */
  z-index: 2;
}
.evidence-table td:first-child,
.evidence-table th:first-child {
  position: sticky;
  left: 0;
  background: white;
  z-index: 1;
}
.evidence-table thead th:first-child { z-index: 3; }
```

## Pattern 4: Column show/hide

Use a popover anchored to a "Columns" button (Radix Popover + checkbox list):

```tsx
<Popover>
  <PopoverTrigger className="text-sm border px-2 py-1">Columns</PopoverTrigger>
  <PopoverContent className="w-56 p-2">
    {allColumns.map(c => (
      <label key={c.id} className="flex items-center gap-2 py-1 text-sm">
        <input
          type="checkbox"
          checked={visible.has(c.id)}
          onChange={() => toggle(c.id)}
        />
        {c.label}
      </label>
    ))}
  </PopoverContent>
</Popover>
```

**A11y:** label text wraps the input so the click target is the full row; Radix handles focus trap.

## Pattern 5: Density toggle

```tsx
const densityClass = {
  compact: 'py-0.5 text-xs',
  comfortable: 'py-1.5 text-sm',
  spacious: 'py-3 text-sm',
}[density];
```

Persist to `localStorage`, per-table-per-user. Don't animate the transition - instant change feels more responsive and avoids relayout jank with sticky headers.

## Pattern 6: Inline row expansion

```tsx
<tr onClick={() => toggle(r.id)} className="cursor-pointer">
  <td>{expanded.has(r.id) ? '▼' : '▶'}</td>
  <td>{r.name}</td>
</tr>
{expanded.has(r.id) && (
  <tr className="bg-neutral-50">
    <td colSpan={cols.length} className="p-4">
      <DetailPreview record={r} />
    </td>
  </tr>
)}
```

**When:** for "preview" affordances - show ~5 secondary fields and a thumbnail. Don't try to fit the full detail page inline.

**A11y:** the toggle row needs `aria-expanded`; chevron should have `aria-label="Expand row"` if it is the only label.

## Pattern 7: Row-to-detail navigation with list context

The whole row should be a link target, but use a real `<a>` on the primary identifier cell with the rest of the row carrying `onClick`. This preserves middle-click-to-open-in-new-tab on the identifier:

```tsx
<tr onClick={() => router.push(`/r/${r.id}`)}>
  <td><a href={`/r/${r.id}`} className="font-mono">{r.id}</a></td>
  ...
</tr>
```

**Preserve list context on the detail page:**
```tsx
<header className="flex items-center justify-between border-b py-3">
  <a href={listUrl} className="text-sm underline">← Back to results</a>
  <nav aria-label="Record navigation" className="flex gap-3 text-sm">
    <a href={prevId ? `/r/${prevId}?list=${listToken}` : undefined}
       className={prevId ? 'underline' : 'text-slate-400 pointer-events-none'}>
      ← Previous ({position}/{total})
    </a>
    <a href={nextId ? `/r/${nextId}?list=${listToken}` : undefined}>Next →</a>
  </nav>
</header>
```

The `listToken` param encodes the result-set query so back-to-results restores scroll and filters. Blacklight's Previous/Next-within-result is the canonical pattern.

## Pattern 8: Side-by-side source and extracted fields

```tsx
<div className="grid grid-cols-2 gap-4 h-screen">
  <aside className="overflow-auto border-r">
    <DocumentViewer
      doc={record.source}
      activeSpan={hoveredField?.span}
      onSpanClick={span => setActiveField(span.fieldId)}
    />
  </aside>
  <main className="overflow-auto p-6">
    <FieldList
      fields={record.fields}
      activeField={activeField}
      onFieldHover={f => setHoveredField(f)}
    />
  </main>
</div>
```

**Tradeoff:** on screens <1280px wide, collapse to tabs. Don't try to fit two columns on a 13" laptop - neither pane gets enough width for legibility.

**Field list with origin badges:**
```tsx
<dl className="space-y-3">
  <dt className="text-xs uppercase tracking-wide text-neutral-500">Date of incident</dt>
  <dd className="flex items-baseline gap-2">
    <span className="font-medium">2014-08-03</span>
    <ProvBadge kind="source" />
    <CitationChip docId="d-12" page={4} />
  </dd>
  <dt className="text-xs uppercase tracking-wide text-neutral-500">Estimated casualties</dt>
  <dd className="flex items-baseline gap-2">
    <span className="font-medium">120–180</span>
    <ProvBadge kind="extracted" />
    <ConfidenceBar level="medium" />
  </dd>
</dl>
```

(See [trustworthy-display.md](trustworthy-display.md) for `ProvBadge` and `ConfidenceBar` implementation.)

## Pattern 9: Citation chips with hover preview

```tsx
<span className="inline-flex items-center gap-1">
  {field.value}
  <a
    href={`/doc/${field.docId}#p${field.page}`}
    className="inline-flex items-center px-1.5 py-0.5 text-xs font-mono
               bg-neutral-100 hover:bg-amber-100 rounded border border-neutral-200"
    onMouseEnter={() => prefetchPreview(field.docId, field.page)}
  >
    p.{field.page}
  </a>
</span>
```

Preview-on-hover should be a debounced ~300ms fetch of a thumbnail of the cited page (Radix Tooltip with `delayDuration={300}`). The tooltip must also open on focus, not just hover.

## Pattern 10: Related-records sidebar

```tsx
<aside className="w-72 border-l p-4 text-sm space-y-6">
  <section>
    <h3 className="text-xs uppercase tracking-wide text-neutral-500 mb-2">Same source</h3>
    <ul className="space-y-1">
      {related.sameSource.map(r => (
        <li key={r.id}><a href={`/r/${r.id}`} className="hover:underline">{r.name}</a></li>
      ))}
    </ul>
  </section>
  <section>
    <h3 className="text-xs uppercase tracking-wide text-neutral-500 mb-2">Mentions same entity</h3>
    {/* ... */}
  </section>
</aside>
```

Group by relationship type (same-source, same-entity, similar-content, parent-collection). Limit each group to 5-7; "see all" link for overflow. ICIJ's Offshore Leaks profile pages model this well.

## Pattern 11: Breadcrumb provenance

```tsx
<nav aria-label="Breadcrumb" className="text-sm text-neutral-600">
  <ol className="flex items-center gap-1.5">
    <li><a href="/c/truth-commission">Truth Commission Archive</a></li>
    <li aria-hidden>›</li>
    <li><a href="/d/0042">Statement #0042</a></li>
    <li aria-hidden>›</li>
    <li><a href="/d/0042/p7">p.7</a></li>
    <li aria-hidden>›</li>
    <li className="text-black font-medium" aria-current="page">Victim record V-118</li>
  </ol>
</nav>
```

Breadcrumb encodes the archive's logical structure: Collection → Document → Page → Extracted Record.

## Typography for tabular data

```css
:root {
  --font-data: ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif;
  --font-mono: ui-monospace, SFMono-Regular, "JetBrains Mono", Consolas, monospace;
}

.evidence-table {
  font-family: var(--font-data);
  font-size: 13px;        /* 14 comfortable, 12 compact */
  line-height: 1.4;
  font-variant-numeric: tabular-nums lining-nums;
}

.evidence-table td.num,
.evidence-table th.num {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

.evidence-table td.id {
  font-family: var(--font-mono);
  font-size: 0.85em;
  color: rgb(100 116 139);
  letter-spacing: -0.01em;
}

.evidence-table td.date {
  font-variant-numeric: tabular-nums;
  text-align: right;
  white-space: nowrap;
}

.evidence-table td.text {
  text-align: left;
  max-width: 32ch;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
```

**Alignment rules (Few):**
- Numbers: right-align, decimal-aligned, tabular numerals.
- Dates: right-align if sortable; left-align if mixed with prose.
- IDs/hashes/codes: left-align, monospace - they are not numbers (no arithmetic).
- Currency: right-align, currency symbol always-shown left-aligned in same cell, or as separate column.
- Booleans/status: center, with text label not just an icon.

**Line-height:** 1.3-1.45 for table rows. Below 1.3, descenders touch borders; above 1.5, scanning slows.

**Tailwind:** `tabular-nums` utility class applies `font-variant-numeric: tabular-nums`. Always apply to columns containing numbers, dates, page counts, file sizes.

**Truncation rules.** `text-overflow: ellipsis` alone is hostile. Either: (a) wrap the text, (b) show a tooltip on hover/focus after 200ms, or (c) make the cell click-to-expand. Never truncate IDs, hashes, or anything the user might need to copy.

## Build order

1. Plain `<table>` + Tailwind + TanStack Table for sorting/filtering/pagination (no virtualization until >500 rows).
2. Density toggle, sticky header, sticky first column.
3. Detail page route with side-by-side document viewer + fields, citation chips inline.
4. Two-layer document viewer (image + bbox overlay) using fractional coordinates - see [document-viewers.md](document-viewers.md).
5. Related-records sidebar with grouped relationships.
6. Confidence and provenance indicators - see [trustworthy-display.md](trustworthy-display.md).

Ship in this order; each layer is usable on its own.
