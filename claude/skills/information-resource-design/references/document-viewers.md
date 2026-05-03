# Document Viewers

Patterns for displaying source documents - PDFs, scanned pages, images - with overlays for OCR text, highlights, annotations, and citations.

## Contents

- [Core principles](#core-principles)
- [Pattern 1: Two-layer image + bbox overlay](#pattern-1-two-layer-image--bbox-overlay)
- [Pattern 2: OCR text fallback pane](#pattern-2-ocr-text-fallback-pane)
- [Pattern 3: Synchronized scroll](#pattern-3-synchronized-scroll)
- [Pattern 4: Page-anchor URLs](#pattern-4-page-anchor-urls)
- [Pattern 5: In-document search with thumbnail hits](#pattern-5-in-document-search-with-thumbnail-hits)
- [Pattern 6: Annotations with access tiers](#pattern-6-annotations-with-access-tiers)
- [Pattern 7: Page navigator filmstrip](#pattern-7-page-navigator-filmstrip)
- [Pattern 8: Hideable sidebar for embeds](#pattern-8-hideable-sidebar-for-embeds)
- [Pattern 9: Keyboard shortcuts](#pattern-9-keyboard-shortcuts)
- [Tooling](#tooling)

## Core principles

**Image is canonical, OCR is supplemental.** The document image is the evidentiary artifact; the OCR text is a derived representation. Always provide both, with explicit toggle and labels distinguishing them.

**Coordinates as fractions of page size.** Store bbox coordinates as fractional positions (`{x: 0.12, y: 0.34, w: 0.4, h: 0.05}`), not pixels. Keeps the viewer responsive and zoom-friendly without coordinate recomputation.

**Page-anchor URLs are first-class.** `/doc/d-12#p7` (page) and `/doc/d-12?p=7&hl=4` (page + highlight) must work. Citations require stable, deep-linkable references.

**Don't break the back button.** A document opened from a result list should be a route, not a modal. Modal/pop-up viewers are an anti-pattern in investigative platforms (Aleph's pop-up is a notable mistake).

**Embed-aware.** Document viewers will end up embedded in newsroom CMSs, blog posts, court filings. Sidebar and toolbar must be hideable; page-embeds (single page) are a useful primitive separate from full-doc embeds.

**Accessible parallel text.** Screen readers cannot read images. The OCR text pane must be selectable, semantically structured, and toggleable as the primary view for assistive tech.

## Pattern 1: Two-layer image + bbox overlay

The DocumentCloud model: rendered page image as background, transparent absolutely-positioned interactive elements with bbox coordinates as the foreground.

```tsx
<div className="relative" style={{ aspectRatio: page.width / page.height }}>
  <img src={page.imageUrl} alt={`Page ${page.number}`}
       className="absolute inset-0 w-full h-full" />
  {page.highlights.map(h => (
    <button
      key={h.id}
      type="button"
      className="absolute bg-yellow-300/40 hover:bg-yellow-400/60 cursor-pointer
                 focus-visible:ring-2 focus-visible:ring-sky-500"
      style={{
        left: `${h.x * 100}%`,
        top: `${h.y * 100}%`,
        width: `${h.w * 100}%`,
        height: `${h.h * 100}%`,
      }}
      onClick={() => onHighlightClick(h)}
      aria-label={`Highlight: ${h.label}`}
    />
  ))}
</div>
```

**Highlight color convention.** Yellow at 30-50% alpha is the de facto standard for hit highlighting and reference highlighting (Aleph, Uwazi, DocumentCloud all converge on it). Reserve other colors for distinct meanings: red for redaction; green for verified citation; blue for user-added annotation.

**Multiple highlight layers.** When a page has search hits AND user annotations AND extracted-field citations simultaneously, layer them with distinct colors and let the user toggle each layer on/off.

## Pattern 2: OCR text fallback pane

```tsx
<div className="grid grid-cols-2 gap-4 h-screen">
  <aside aria-label="Page image" className="overflow-auto bg-neutral-50">
    <PageImage page={page} highlights={highlights} />
  </aside>
  <main aria-label="OCR text" className="overflow-auto p-6 prose prose-sm max-w-none">
    {page.ocrParagraphs.map((p, i) => (
      <p key={i} data-page={page.number} data-paragraph={i}>
        {p.spans.map(s => (
          s.highlightId
            ? <mark key={s.id} data-highlight-id={s.highlightId}>{s.text}</mark>
            : <span key={s.id}>{s.text}</span>
        ))}
      </p>
    ))}
  </main>
</div>
```

The OCR pane is selectable so investigators can copy quotes; the image pane stays canonical for visual evidence. DocumentCloud's 2025 update grafts OCR back into the underlying PDF on download, so the file is searchable locally - a thoughtful provenance/portability move.

## Pattern 3: Synchronized scroll

```tsx
function useSyncedScroll(refA, refB) {
  useEffect(() => {
    const a = refA.current, b = refB.current;
    if (!a || !b) return;
    let syncing = false;
    function onScroll(src, dst) {
      if (syncing) return;
      syncing = true;
      const ratio = src.scrollTop / (src.scrollHeight - src.clientHeight);
      dst.scrollTop = ratio * (dst.scrollHeight - dst.clientHeight);
      requestAnimationFrame(() => { syncing = false; });
    }
    const onA = () => onScroll(a, b);
    const onB = () => onScroll(b, a);
    a.addEventListener('scroll', onA);
    b.addEventListener('scroll', onB);
    return () => { a.removeEventListener('scroll', onA); b.removeEventListener('scroll', onB); };
  }, []);
}
```

**Tradeoff:** ratio-based sync is simple but breaks when panes have different aspect ratios. For per-paragraph alignment, use IntersectionObserver on data-page/data-paragraph attributes and scroll the other pane to the matching element.

## Pattern 4: Page-anchor URLs

```
/doc/d-12             → first page, no highlights
/doc/d-12#p7          → page 7
/doc/d-12?p=7&hl=4    → page 7, highlight #4 active
/doc/d-12?p=7&q=foo   → page 7, in-document search for "foo"
```

Implementation:
```tsx
useEffect(() => {
  const params = new URLSearchParams(window.location.search);
  const page = Number(params.get('p') || window.location.hash.replace('#p', '') || 1);
  const hlId = params.get('hl');
  scrollToPage(page);
  if (hlId) activateHighlight(hlId);
}, []);
```

**Share-with-page-anchor button:**
```tsx
<button onClick={() => {
  const url = `${window.location.origin}/doc/${doc.id}?p=${currentPage}`;
  navigator.clipboard.writeText(url);
}}>Copy link to this page</button>
```

Internet Archive's BookReader does this well - shareable URLs preserve citation depth.

## Pattern 5: In-document search with thumbnail hits

A search input scoped to the open document, returning a chronologically-ordered list of hits, each with a page thumbnail and a snippet. Click jumps to that page with the hit highlighted.

```tsx
<aside className="w-72 border-r overflow-auto">
  <input type="search" placeholder="Search this document"
         value={q} onChange={e => setQ(e.target.value)}
         className="w-full px-3 py-2 border-b" />
  <ul className="divide-y">
    {hits.map(h => (
      <li key={h.id}>
        <a href={`?p=${h.page}&hl=${h.id}`}
           className="flex gap-3 p-2 hover:bg-amber-50">
          <img src={h.thumbUrl} alt="" className="w-16 border" />
          <div className="text-xs">
            <p className="font-medium">Page {h.page}</p>
            <p className="text-neutral-600"
               dangerouslySetInnerHTML={{ __html: h.snippet }} />
          </div>
        </a>
      </li>
    ))}
  </ul>
</aside>
```

Internet Archive's BookReader pioneered this pattern; Uwazi's "Search-icon-in-the-document-viewer triggers in-document search returning chronologically ordered, clickable hits" is a clean implementation.

## Pattern 6: Annotations with access tiers

DocumentCloud's three-tier model: **private** (only me), **collaborator** (my org), **public** (anyone with the doc). Use exactly three tiers - more invites mis-set permissions.

```tsx
<form onSubmit={save}>
  <label className="block">
    <span className="text-sm font-medium">Note</span>
    <textarea name="body" className="w-full border rounded p-2" />
  </label>
  <fieldset className="mt-3">
    <legend className="text-sm font-medium">Visibility</legend>
    <label className="flex gap-2 items-center">
      <input type="radio" name="visibility" value="private" defaultChecked />
      <span>Private — only me</span>
    </label>
    <label className="flex gap-2 items-center">
      <input type="radio" name="visibility" value="collaborator" />
      <span>Collaborators — {org.name}</span>
    </label>
    <label className="flex gap-2 items-center">
      <input type="radio" name="visibility" value="public" />
      <span>Public — anyone with this document</span>
    </label>
  </fieldset>
</form>
```

**Visual treatment.** Public annotations get a different border color (e.g. emerald) than private (slate). Show the visibility level on the annotation pin so users don't accidentally share something private.

**Per-page-access** is an additional axis: an annotation may be on a specific page even if the document is broadly accessible. Make this independent of the annotation's own visibility.

## Pattern 7: Page navigator filmstrip

A vertical strip of page thumbnails - small multiples in Tufte's sense, doubling as navigation:

```tsx
<aside aria-label="Pages" className="w-32 overflow-auto border-r">
  <ol>
    {doc.pages.map(p => (
      <li key={p.number}>
        <a href={`?p=${p.number}`}
           aria-current={p.number === currentPage ? 'page' : undefined}
           className={`block p-2 ${p.number === currentPage ? 'bg-sky-100' : 'hover:bg-neutral-100'}`}>
          <img src={p.thumbUrl} alt="" className="w-full border" />
          <span className="block text-xs text-center mt-1">{p.number}</span>
        </a>
      </li>
    ))}
  </ol>
</aside>
```

**A11y:** `aria-current="page"` indicates the active page; the filmstrip is keyboard-navigable as a list of links.

## Pattern 8: Hideable sidebar for embeds

DocumentCloud's pattern: explicit `Customize Appearance → Sidebar behavior: hidden` for narrow embed contexts. Implement via URL param so embed code can set it:

```
<iframe src="/doc/d-12?embed=1&sidebar=hidden&page=4" />
```

Page-embed primitive (single page only, no doc chrome) for newsroom inline contexts:

```
<iframe src="/doc/d-12/page/4?embed=page" />
```

Both should set `aria-label` on the body so screen-reader announcements are sensible inside an iframe.

## Pattern 9: Keyboard shortcuts

Standard shortcuts (DocumentCloud convention plus browser standards):

| Key | Action |
|---|---|
| `j` / `↓` | Next page |
| `k` / `↑` | Previous page |
| `g` then number | Go to page |
| `f` | Fit width |
| `+` / `-` | Zoom in / out |
| `/` | Focus in-document search |
| `n` | Add note (annotate) |
| `r` | Redact (if permitted) |
| `Esc` | Close drawer / dismiss popover |
| `?` | Show keyboard shortcuts panel |

**Critical:** keyboard shortcuts are an *enhancement*, never the only access path. Every shortcut must have a visible button equivalent (WCAG SC 2.1.1).

The shortcuts panel:
```tsx
<dialog aria-labelledby="shortcuts-h" open={showShortcuts}>
  <h2 id="shortcuts-h">Keyboard shortcuts</h2>
  <dl>
    <dt><kbd>j</kbd></dt><dd>Next page</dd>
    <dt><kbd>k</kbd></dt><dd>Previous page</dd>
    {/* ... */}
  </dl>
</dialog>
```

## Tooling

**Don't roll your own PDF rendering.** Use [`pdf.js`](https://mozilla.github.io/pdf.js/) (Mozilla, MIT) or [`react-pdf`](https://github.com/wojtekmaj/react-pdf) (wrapper around pdf.js).

**For OCR text + bbox overlay,** the typical stack is: server-side OCR (Tesseract, Textract, Azure Document Intelligence, docTR) producing word-level bboxes; client-side renders pdf.js page + an absolutely-positioned div per word/span/line.

**For IIIF-served images** (common in libraries and museums), use [Mirador](https://projectmirador.org/) or [OpenSeadragon](https://openseadragon.github.io/) - they handle deep zoom, multi-canvas works, and presentation manifests.

**For annotation persistence,** [Annotorious](https://annotorious.dev/) is a good open-source library (W3C Web Annotation Model compliant). Roll your own only if you need tight integration with structured-extraction fields.
