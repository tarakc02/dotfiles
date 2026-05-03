# Inclusive Design

Accessibility for complex information UIs (tables, faceted search, document viewers, dialogs) plus multilingual and non-Latin script display. Both concerns are co-located here because they reinforce each other - language tagging is an accessibility feature, and proper ARIA semantics survive translation.

## Contents

- [Accessibility principles](#accessibility-principles)
- [Pattern: Complex tables with header associations](#pattern-complex-tables-with-header-associations)
- [Pattern: Faceted search with batched live updates](#pattern-faceted-search-with-batched-live-updates)
- [Pattern: Roving tabindex for composite widgets](#pattern-roving-tabindex-for-composite-widgets)
- [Pattern: Focus management in record drawers](#pattern-focus-management-in-record-drawers)
- [Contrast for dense interfaces](#contrast-for-dense-interfaces)
- [Multilingual principles](#multilingual-principles)
- [Pattern: Root and per-element direction and language](#pattern-root-and-per-element-direction-and-language)
- [Pattern: Logical CSS properties](#pattern-logical-css-properties)
- [Pattern: Mixed-direction inline content](#pattern-mixed-direction-inline-content)
- [Pattern: Language switcher](#pattern-language-switcher)
- [Pattern: Script-aware font stack](#pattern-script-aware-font-stack)
- [Pattern: Locale-correct formatting](#pattern-locale-correct-formatting)
- [Pattern: Original + translation in record cards](#pattern-original--translation-in-record-cards)

## Accessibility principles

**Native semantics before ARIA.** A real `<table>` with `<th scope>` outperforms any `role="grid"` retrofit for static data. Use `role="grid"` only when cells are interactive (focusable, editable, selectable).

**Announce state changes politely, not constantly.** Faceted search produces a stream of updates; batch and debounce them into a single live-region message ~500ms after the last change.

**One tab stop per composite widget.** A results table, a filter panel, a viewer toolbar - each should be a single tab stop with internal arrow-key navigation (the "roving tabindex" pattern).

**Visible focus is non-negotiable in dense UIs.** WCAG 2.2 SC 2.4.11 (Focus Not Obscured) and 2.4.13 (Focus Appearance) explicitly target dense layouts where sticky headers, drawers, and modals hide focus.

**Contrast for non-text UI.** SC 1.4.11 requires 3:1 for icons, focus rings, and form borders - easy to fail in muted "archive" aesthetics.

**Modal viewers trap focus and restore it.** When a record drawer opens, focus moves in; on close, returns to the trigger row.

**Keyboard shortcuts are enhancements, never the only access path.** Every shortcut must have a visible button equivalent (SC 2.1.1).

## Pattern: Complex tables with header associations

Use `scope` for simple grids and `headers`/`id` only when headers span irregularly.

```html
<table class="w-full text-sm">
  <caption class="text-left font-semibold mb-2">
    Reported incidents, Aleppo Governorate, 2012–2016
    <span class="block text-xs text-slate-600">
      Source: VDC dataset, last updated 2024-03-12. 1,284 rows.
    </span>
  </caption>
  <thead>
    <tr>
      <th scope="col">Date</th>
      <th scope="col">Location</th>
      <th scope="col">Casualties (low)</th>
      <th scope="col">Casualties (high)</th>
      <th scope="col">Confidence</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">2013-08-21</th>
      <td>Eastern Ghouta</td>
      <td>734</td>
      <td>1,729</td>
      <td><span aria-label="Medium confidence">Medium</span></td>
    </tr>
  </tbody>
</table>
```

A `<caption>` is announced as the table's accessible name; never replace it with a styled `<h3>` above the table.

## Pattern: Faceted search with batched live updates

One live region per search context, polite, debounced.

```jsx
<div role="search" aria-label="Filter records">
  <div role="group" aria-labelledby="facet-region-h">
    <h2 id="facet-region-h" className="sr-only">Region</h2>
    {regions.map(r => (
      <label key={r.id} className="flex items-center gap-2">
        <input type="checkbox" checked={selected.has(r.id)}
               onChange={() => toggle(r.id)} />
        <span>{r.label}</span>
        <span className="text-xs text-slate-500">({r.count})</span>
      </label>
    ))}
  </div>
</div>

{/* Single live region, updated after debounce */}
<div aria-live="polite" aria-atomic="true" className="sr-only">
  {liveMessage /* "412 records. Filters: Region Aleppo, Year 2013." */}
</div>
```

Update `liveMessage` ~500ms after the last change. Include the active filters in the announcement so screen-reader users know what changed without re-reading the panel.

**Applied-filter chips** as a list of removable buttons:

```html
<ul aria-label="Applied filters" class="flex flex-wrap gap-2">
  <li>
    <button type="button" class="chip">
      Region: Aleppo
      <span class="sr-only">remove filter</span>
      <svg aria-hidden="true">…</svg>
    </button>
  </li>
</ul>
```

## Pattern: Roving tabindex for composite widgets

In a 200-item facet panel, don't tab into every checkbox. Make the panel one tab stop and use arrow keys for internal navigation:

```jsx
function FacetGroup({ items, selected, onToggle }) {
  const [focusIdx, setFocusIdx] = useState(0);
  function handleKey(e) {
    if (e.key === 'ArrowDown') { setFocusIdx(i => Math.min(i+1, items.length-1)); e.preventDefault(); }
    if (e.key === 'ArrowUp')   { setFocusIdx(i => Math.max(i-1, 0)); e.preventDefault(); }
    if (e.key === ' ' || e.key === 'Enter') { onToggle(items[focusIdx].id); e.preventDefault(); }
  }
  return (
    <ul role="group" onKeyDown={handleKey}>
      {items.map((it, i) => (
        <li key={it.id}>
          <button
            tabIndex={i === focusIdx ? 0 : -1}
            ref={el => i === focusIdx && el?.focus()}
            aria-pressed={selected.has(it.id)}
            onClick={() => onToggle(it.id)}>
            {it.label} <span className="text-xs">({it.count})</span>
          </button>
        </li>
      ))}
    </ul>
  );
}
```

Use this for: facet panels with >20 items, document page filmstrips, results-list keyboard navigation.

## Pattern: Focus management in record drawers

```jsx
useEffect(() => {
  if (!open) return;
  const previouslyFocused = document.activeElement;
  drawerRef.current?.focus();
  return () => previouslyFocused?.focus?.();
}, [open]);

return (
  <div role="dialog" aria-modal="true" aria-labelledby="rec-title"
       tabIndex={-1} ref={drawerRef}>
    <h2 id="rec-title">Record {id}</h2>
    …
  </div>
);
```

Combine with focus-trap (e.g. `focus-trap-react`) and `inert` on the page background. WCAG 2.2 SC 2.4.11: when a drawer pins to bottom, ensure the focused row in the table behind it is not fully hidden - or move focus into the drawer immediately.

## Contrast for dense interfaces

- **Body text:** 4.5:1 minimum (7:1 preferred for long sessions and outdoor environments).
- **Large/bold text:** 3:1 minimum.
- **UI components and graphical objects:** 3:1.

For "muted" archival palettes, test the focus ring against *both* the background and the adjacent component - a 3:1 ring on white can vanish against a `slate-100` row stripe. Tools: WebAIM Contrast Checker, axe DevTools, browser devtools accessibility pane.

## Multilingual principles

**Direction is a document property, not a class.** Set `dir` and `lang` on the element whose *content* is in that language; let CSS logical properties handle layout.

**Mirror layout, not content.** Arrows, progress, and alignment mirror in RTL. Numerals, code, and identifiers do not.

**Use logical properties everywhere.** `margin-inline-start`, `padding-inline-end`, `border-inline-start`, `text-align: start`. Avoid `left`/`right` outside genuinely physical contexts.

**Tag every language span.** `lang` attributes drive screen-reader voice switching, hyphenation, font selection, and search.

**Ship a script-aware font stack.** One UI family will not cover Arabic + Devanagari + CJK. Plan a stack and let the browser pick.

**Format dates, numbers, and names per locale.** Use `Intl` APIs, not string concatenation.

## Pattern: Root and per-element direction and language

```html
<html lang="ar" dir="rtl">
```

For a multilingual app, set this dynamically on language change AND per-section when content language differs from UI:

```html
<article lang="en">
  <h1>Witness statement, 14 June 2014</h1>
  <p>Original Arabic:
    <q lang="ar" dir="rtl">كنّا في السوق عندما بدأ القصف.</q>
  </p>
  <p>Translation:
    <q lang="en">We were at the market when the shelling started.</q>
  </p>
  <p>Transliteration:
    <span lang="ar-Latn">kunnā fī al-sūq ʿindamā badaʾa al-qaṣf.</span>
  </p>
</article>
```

`lang="ar-Latn"` (BCP 47) signals "Arabic in Latin script" - important for screen readers and search.

## Pattern: Logical CSS properties

Tailwind v3+ supports `ms-`, `me-`, `ps-`, `pe-`, `start-`, `end-`:

```html
<aside class="ms-4 ps-4 border-s border-slate-300">
  <h2 class="text-start">Filters</h2>
</aside>
```

Avoid `ml-4 pl-4 border-l text-left` - these don't mirror.

## Pattern: Mixed-direction inline content

Use Unicode bidi isolate via `<bdi>` or CSS `unicode-bidi: isolate`:

```html
<li>
  Name: <bdi>محمد علي</bdi> (case <bdi>HRDAG-2014-0182</bdi>)
</li>
```

Without isolation, an LTR identifier next to RTL text can reorder unpredictably. `<bdi>` prevents the surrounding paragraph's direction from leaking in.

## Pattern: Language switcher

Each option labeled in *its own* language, with `lang` and `hreflang`:

```html
<nav aria-label="Language">
  <ul class="flex gap-3">
    <li><a href="/en/…" hreflang="en" lang="en">English</a></li>
    <li><a href="/ar/…" hreflang="ar" lang="ar">العربية</a></li>
    <li><a href="/es/…" hreflang="es" lang="es">Español</a></li>
    <li><a href="/zh-Hans/…" hreflang="zh-Hans" lang="zh-Hans">简体中文</a></li>
  </ul>
</nav>
```

**Don't render languages as flags** - flags are countries, not languages.

## Pattern: Script-aware font stack

Group by script; let the browser fall back per-glyph:

```css
:root {
  --font-ui: "Inter", "Noto Sans", "Noto Sans Arabic",
             "Noto Sans Hebrew", "Noto Sans Devanagari",
             "Noto Sans CJK SC", "Noto Sans CJK JP",
             system-ui, sans-serif;
}
body { font-family: var(--font-ui); line-height: 1.6; }

:lang(ar), :lang(fa), :lang(ur) { line-height: 1.9; font-size: 1.05em; }
:lang(hi), :lang(bn), :lang(ta)  { line-height: 1.8; }
:lang(zh), :lang(ja), :lang(ko)  { line-height: 1.7; letter-spacing: 0; }
```

Arabic and Indic scripts have taller diacritics and ligatures; Latin-tuned 1.4-1.5 line-height truncates marks. CJK needs slightly looser leading and zero letter-spacing.

## Pattern: Locale-correct formatting

```js
const fmt = new Intl.DateTimeFormat(locale, {
  year: 'numeric', month: 'long', day: 'numeric'
});
fmt.format(new Date(record.date));

new Intl.NumberFormat(locale).format(record.casualties);
new Intl.RelativeTimeFormat(locale, { numeric: 'auto' }).format(-3, 'day');
```

For names, never split on whitespace into "first/last." Display the name as a single field with `lang` on the element; if you need a sortable form, store it separately as `nameSort`.

## Pattern: Original + translation in record cards

Place original first, with translation visually subordinate but not hidden. Mark translations explicitly:

```html
<dl>
  <dt>Statement</dt>
  <dd lang="ar" dir="rtl" class="text-lg">
    كنّا في السوق…
  </dd>
  <dd lang="en" class="text-sm text-slate-600 mt-1">
    <span class="sr-only">Translation: </span>
    We were at the market…
  </dd>
</dl>
```

## Anti-patterns to avoid

- `<div>` grids with `role="row"`/`role="cell"` for static tabular data.
- `aria-live="assertive"` on result counters - interrupts every other announcement.
- Tab into every checkbox in a 200-item facet panel.
- Removing focus outlines globally (`*:focus { outline: none }`).
- Sticky toolbars that obscure the focused row when scrolling with the keyboard.
- A single `dir="ltr"` `<html>` with RTL content forced via per-element overrides.
- Separate stylesheets for RTL - divergence is inevitable.
- `font-family: "MyBrand", sans-serif` only - non-Latin falls to whatever the OS provides, often inconsistent.
- Truncating non-Latin text by character count (`str.slice(0, 40)`) - combining marks and surrogates break.
- Flags as language indicators.
- Hard-coded `MM/DD/YYYY` or `1,234.56` formats.

## Sources

- WCAG 2.2 (W3C Recommendation, 2023) - especially SC 1.3.1, 1.4.11, 2.4.11, 2.4.13, 4.1.3.
- WAI-ARIA Authoring Practices Guide - patterns for *Grid*, *Disclosure*, *Dialog (Modal)*, *Listbox*, *Combobox*.
- Heydon Pickering, *Inclusive Components* - Data Tables and Tab Interfaces.
- W3C Internationalization Activity, *Internationalization Best Practices for HTML/CSS*.
- Mozilla MDN on `<bdi>` and CSS logical properties.
