# Search and Discovery

UI/UX patterns for searching and browsing unstructured document collections.

## Contents

- [Core principles](#core-principles)
- [Pattern 1: Search box and scope](#pattern-1-search-box-and-scope)
- [Pattern 2: Faceted sidebar](#pattern-2-faceted-sidebar)
- [Pattern 3: Applied-filter chips](#pattern-3-applied-filter-chips)
- [Pattern 4: Results list with snippets](#pattern-4-results-list-with-snippets)
- [Pattern 5: Result density toggle](#pattern-5-result-density-toggle)
- [Pattern 6: Zero-result state](#pattern-6-zero-result-state)
- [Pattern 7: Query autocomplete](#pattern-7-query-autocomplete)
- [Pattern 8: Sort controls](#pattern-8-sort-controls)
- [Pattern 9: Saved and shareable queries](#pattern-9-saved-and-shareable-queries)
- [Pattern 10: Search within results](#pattern-10-search-within-results)
- [Pattern 11: Mobile search tray](#pattern-11-mobile-search-tray)

## Core principles

**One box by default, with progressive power.** Users arrive with a name, a date, or a fuzzy phrase, not a structured query. A single prominent input outperforms multi-field forms for first contact. Power features (phrase quotes, boolean operators, field-scoped queries like `name:Roldugin`, date ranges) live behind an "Advanced" affordance that builds onto the current query, not a separate page that resets it.

**Facets are filters, but they are also a map of the corpus.** A count next to "Companies (12,431)" is itself a research finding. Show counts beside every facet value; gray out (don't hide) facets with zero matches in current results - hiding loses the sense that the facet exists at all.

**Show why each result matched.** A 2-3 line snippet with query terms in `<mark>` plus a "Matched in: body, attachments[2].txt" line builds trust. Without that, users click every result defensively.

**Counts must be honest.** Static counts that don't reflect applied filters mislead. Default behavior: facet counts recompute against current selections ("contextual counts"). When filters are exclusive of each other, expose this with an "Exclude" affordance and visual strikethrough on the chip.

**Lookup vs exploration are different jobs.** Lookup wants fast answer + ranked list. Exploration wants browse-able structure: timelines, entity lists, filter combinations the user didn't anticipate. Pair the result list with at least one orthogonal view (facet sidebar always; map/timeline/graph when data justifies it).

**Zero results is a UX problem, not an error.** Always recover: spelling correction, drop the most restrictive filter (with preview count), broaden scope, show recent or popular queries.

**Speed perception > raw speed.** Fake responsiveness with optimistic UI: skeleton rows immediately, debounce real queries at ~250ms, surface the active query state in the URL bar before results arrive.

## Pattern 1: Search box and scope

**When:** always - the primary entry point. Add a scope selector only when the corpus has clearly distinct subsets the user might pre-filter (Aleph: Datasets/Entities/Documents; ICIJ: Entities/Officers/Intermediaries/Addresses) AND scopes are mutually exclusive AND default "All" is sane.

```jsx
<form role="search" className="flex w-full max-w-3xl rounded-md border border-slate-300 focus-within:ring-2 focus-within:ring-sky-500">
  <label htmlFor="scope" className="sr-only">Search scope</label>
  <select id="scope" name="scope" defaultValue="all"
    className="border-r border-slate-300 bg-slate-50 px-3 text-sm">
    <option value="all">All</option>
    <option value="entities">Entities</option>
    <option value="documents">Documents</option>
  </select>
  <label htmlFor="q" className="sr-only">Search</label>
  <input id="q" name="q" type="search" placeholder="Search names, companies, places…"
    className="flex-1 px-3 py-2 outline-none" />
  <button type="submit" className="bg-slate-900 px-4 text-white">
    <SearchIcon aria-hidden="true" /><span className="sr-only">Search</span>
  </button>
</form>
```

**Placeholder as grammar tutorial.** ICIJ Offshore Leaks uses `"British Virgin Islands | Entity Name LLC | Lima, Peru"` to teach the user what tokens the field accepts. Worth adopting when the input handles multiple kinds of values.

**A11y:** `role="search"` on the form, visible-or-`sr-only` label per input, default scope = "All", scope dropdown reachable via Tab.

## Pattern 2: Faceted sidebar

**When:** corpus has 3+ structured fields users will combine (country, document type, date, entity type). Default position: left sidebar on desktop, bottom-sheet drawer on mobile.

Behavior rules:
- Each value toggles independently; toggling one never undoes another (the "cherry-pick" pattern).
- Show counts; show top N (5-8) per facet with a "Show more" expander.
- Numeric and date facets get a slider or two date inputs, not a long checkbox list.
- Apply on click for fast backends; for slow ones, batch with an "Apply" button.
- For long facet lists (countries, languages), include a search-within-facet input.
- Group facets into 2-4 collapsible categories rather than one long scroll. Datashare's pattern: "Documents info / User data / Entities".
- Support an **Exclude** option per value (Datashare). Excluded values appear in the chip row with strikethrough.

**A11y:** facet group is `<fieldset><legend>Country</legend>`; checkboxes have visible labels including counts; `aria-live="polite"` announces "1,243 results" after a debounce.

## Pattern 3: Applied-filter chips

**When:** any time more than zero filters or query are active. Render directly under the search box, above the result list - never only in the sidebar.

```jsx
function FilterChips({ filters, onRemove, onClear }) {
  if (filters.length === 0) return null;
  return (
    <div className="flex flex-wrap items-center gap-2 py-2" aria-label="Applied filters">
      {filters.map(f => (
        <button key={f.id} onClick={() => onRemove(f.id)}
          className="inline-flex items-center gap-1 rounded-full bg-sky-100 px-3 py-1 text-sm text-sky-900 hover:bg-sky-200">
          <span className="font-medium">{f.label}:</span> {f.value}
          <span aria-hidden>×</span>
          <span className="sr-only">Remove filter {f.label} {f.value}</span>
        </button>
      ))}
      <button onClick={onClear} className="text-sm underline text-slate-600">Clear all</button>
    </div>
  );
}
```

For excluded values, render with strikethrough and a different background:
```jsx
<button className="... bg-rose-50 text-rose-900 line-through">
  Country: Russia (excluded)
</button>
```

**A11y:** chip is a real `<button>`, `aria-label` reads "Remove filter Country Cayman", "Clear all" is a sibling button, not nested.

## Pattern 4: Results list with snippets

**When:** always, for the primary list view. Each row is a self-contained citation.

```jsx
<li className="border-b border-slate-200 py-4">
  <div className="flex items-baseline gap-2 text-xs text-slate-500">
    <span className="rounded bg-slate-100 px-2 py-0.5">PDF</span>
    <span>Panama Papers</span>
    <span>·</span>
    <time dateTime="2016-04-03">3 Apr 2016</time>
  </div>
  <h3 className="mt-1 text-lg">
    <a href={r.url} className="text-sky-700 hover:underline">{r.title}</a>
  </h3>
  <p className="mt-1 text-sm text-slate-700"
     dangerouslySetInnerHTML={{ __html: r.snippet }} />  {/* contains <mark> */}
  <p className="mt-1 text-xs text-slate-500">
    Matched in: body, attachments (2)
  </p>
</li>
```

Snippet rules:
- 2-3 lines max; ellipses around the matched sentence.
- Wrap matched terms in `<mark>` (semantic, themable).
- Show source/dataset, type icon, date - the metadata investigators triage on.
- "Matched in" line builds trust when the title alone doesn't contain the query.

**Heterogeneous result lists** (mixed entity types and documents): use schema icons as the leftmost element of each row to compress type information into a glyph (Aleph pattern). Also use icons for format - PDF, audio, video - in archive-style results (Internet Archive pattern).

**Source-of-truth badge per row.** A small dataset/leak/collection name keeps provenance visible without a click. Critical for investigative work.

**A11y:** `<mark>` is announced as "highlighted" by some screen readers; ensure it has both color and weight contrast (don't rely on yellow background alone).

## Pattern 5: Result density toggle

**When:** corpus rows have variable richness, or users alternate between scanning and reading.

Three modes: **Compact** (title + 1-line snippet), **Comfortable** (default: title + metadata + snippet), **Detailed** (adds full metadata, thumbnail/preview). Persist in `localStorage`; expose via icon group in toolbar.

```jsx
<div role="group" aria-label="Result density" className="flex rounded border border-slate-300">
  {['compact', 'comfortable', 'detailed'].map(d => (
    <button key={d} aria-pressed={density === d}
      onClick={() => setDensity(d)}
      className={`px-3 py-1 text-sm ${density===d ? 'bg-slate-900 text-white' : ''}`}>
      {d}
    </button>
  ))}
</div>
```

**A11y:** `aria-pressed` rather than `aria-selected` (toggle group, not tablist).

## Pattern 6: Zero-result state

Components, in order:
1. Empathetic statement that names the query: "No results for **'Roldogin'** in Country: Russia."
2. Spelling/typo suggestion if available: "Did you mean *Roldugin*?"
3. The most restrictive filter offered for removal with preview count: "[Remove filter: Country = Russia → 14 results]".
4. Broaden scope: "[Search all datasets]".
5. Recovery affordances: "[Clear search]" plus popular or recent queries.

```jsx
<div className="mx-auto max-w-xl py-12 text-center">
  <h2 className="text-xl font-medium">No results for "{q}"</h2>
  {suggestion && (
    <p className="mt-2">
      Did you mean{' '}
      <button className="underline" onClick={() => setQ(suggestion)}>{suggestion}</button>?
    </p>
  )}
  <ul className="mt-4 space-y-2 text-sm">
    {removableFilters.map(f => (
      <li key={f.id}>
        Remove filter <code className="rounded bg-slate-100 px-1">{f.label}</code>
        <button className="ml-2 underline" onClick={() => removeFilter(f.id)}>
          → {f.previewCount} results
        </button>
      </li>
    ))}
  </ul>
</div>
```

**A11y:** `<h2>` so screen-reader users land on the message; suggestion is a real `<button>` not a span.

## Pattern 7: Query autocomplete

**When:** corpus has a stable vocabulary worth suggesting (entity names, place names, document titles). Open dropdown on first keystroke; debounce ~150ms.

Dropdown structure:
- 6-8 items max.
- Mix of types if useful: entity matches, recent searches, popular queries, scoped suggestions ("Search 'Mossack' in Documents").
- "Inverted highlighting": bold the part the user hasn't typed yet.
- Keyboard: ↑/↓ navigate, Enter selects, Esc dismisses, Tab does NOT close.
- Picking a suggestion fills the input AND submits - never navigate away while leaving the field empty.

```jsx
<div role="combobox" aria-expanded={open} aria-owns="sugg-list" aria-haspopup="listbox">
  <input aria-autocomplete="list" aria-controls="sugg-list"
         aria-activedescendant={`sugg-${active}`} ... />
  {open && (
    <ul id="sugg-list" role="listbox" className="absolute mt-1 w-full rounded-md border bg-white shadow-lg">
      {suggestions.map((s, i) => (
        <li id={`sugg-${i}`} key={s.id} role="option" aria-selected={i===active}
            className={`cursor-pointer px-3 py-2 ${i===active ? 'bg-sky-50' : ''}`}>
          <span className="text-slate-500">{s.prefix}</span><strong>{s.suffix}</strong>
          <span className="ml-2 text-xs text-slate-400">{s.type}</span>
        </li>
      ))}
    </ul>
  )}
</div>
```

**A11y:** Follow the WAI-ARIA combobox pattern - `aria-activedescendant` tracks highlight without moving focus.

## Pattern 8: Sort controls

Place at top-right of the result list. Keep options short (3-5). Common axes for document corpora: Relevance (default), Date (newest/oldest), Title A-Z, Source/dataset, plus domain-specific options ("Most cited", "Most connected").

```jsx
<label className="text-sm text-slate-600">
  Sort by
  <select value={sort} onChange={e => setSort(e.target.value)}
    className="ml-2 rounded border-slate-300">
    <option value="relevance">Relevance</option>
    <option value="date_desc">Newest</option>
    <option value="date_asc">Oldest</option>
    <option value="title">Title A–Z</option>
  </select>
</label>
```

Native `<select>` is the cheapest accessible option. Don't replace with a custom listbox unless you need icons or grouping.

**Server-side sorting must preserve scroll position and selection.** Re-fetching is fine; resetting scroll is not.

## Pattern 9: Saved and shareable queries

**Tier 1 - free, no auth:** the URL is the saved search. Add a "Copy link" button to the toolbar.

**Tier 2 - logged in:** "Save this search" stores `{name, url, createdAt}`; a left-sidebar "Saved searches" panel lists them with rename/edit/delete; optional "Email me when there are new results" toggle (CourtListener's alerting model).

```jsx
<div className="flex gap-2">
  <button onClick={() => navigator.clipboard.writeText(window.location.href)}
    className="text-sm underline">Copy link</button>
  {user && (
    <button onClick={() => saveSearch({ name: q, url: window.location.search })}
      className="text-sm underline">Save search</button>
  )}
</div>
```

**A11y:** announce "Search saved" via `aria-live="polite"` toast; saved-search list is a `<nav aria-label="Saved searches">`.

## Pattern 10: Search within results

**When:** initial result set is still too big after faceting (>50 results) and the user has a refinement term that may not match a facet field.

Two valid placements:
1. **Sidebar input** above facets, labeled "Search within results" - clearest.
2. **Pinned chip in main search box**: `Search: "Mossack" + within "shell company"`, with × to drop the inner term.

The inner query is *additional*, not replacement. Placeholder must say "Search within these results" so the user doesn't think they reset.

## Pattern 11: Mobile search tray

**When:** viewport < 768px.

- Search box: full-width, sticky to top.
- Filters: bottom-sheet tray triggered by a "Filter (3)" button at the top of results.
- Tray: partial overlay with a dim behind, so results stay visible for context.
- Apply button at the bottom; "Clear all" top-right.
- Sort surfaces as a separate small button next to Filter, opening its own short bottom-sheet.

```
┌──────────────┐
│ [Search...] X│   ← sticky
├──────────────┤
│[Filter (3)][Sort]│
├──────────────┤
│ Result 1     │
│ Result 2     │
└──────────────┘
       ↓ tap Filter
┌──────────────┐
│ (results dim)│
│ ┌──────────┐ │
│ │ Filters  │ │  ← bottom sheet
│ │ ☐ ...    │ │
│ │ [Apply]  │ │
│ └──────────┘ │
└──────────────┘
```

**A11y:** sheet uses `role="dialog" aria-modal="true"`, traps focus, Esc closes, "Apply" returns focus to the trigger.
