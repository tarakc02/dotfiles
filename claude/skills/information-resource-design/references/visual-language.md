# Visual Language

Typography, color, spacing, iconography, and microcopy for content-first information UIs.

## Contents

- [Core principles](#core-principles)
- [Type system](#type-system)
- [Color system](#color-system)
- [Spacing and density](#spacing-and-density)
- [Iconography](#iconography)
- [Microcopy](#microcopy)
- [Quick-start tokens](#quick-start-tokens)

## Core principles

**Content is the figure; chrome is the ground.** Good typography is invisible - readers notice only when something goes wrong. Strip dividers, drop shadows, and gradients until removing one more would break the layout.

**Hierarchy through weight and space, not size.** Differences in whitespace communicate grouping more cleanly than borders or background fills. Combined with two or three weights (regular / medium / semibold), this carries 90% of hierarchy needs.

**Restrained palette, semantic color reserved.** Neutrals do the structural work; a small set of semantic colors (status, category, link) carries meaning. If everything is colored, nothing is.

**Density is a feature, not a flaw.** Investigators reading 800-row evidence tables need information per scroll. Maximize content per square inch by removing non-data ink.

**Tabular and proportional numerals are different tools.** Numbers in running prose use proportional figures; numbers in columns must align. `font-variant-numeric: tabular-nums` is non-negotiable for any tabular data view.

**Multilingual by default.** Pick faces with broad script coverage from day one. Retrofitting is painful and produces visible style breaks.

**Two density modes, not five.** "Comfortable" for reading and onboarding; "compact" for power users in tables and lists. More modes confuse; fewer underserve.

## Type system

### Font recommendations

**Body / UI sans (primary):** **Inter** - designed for screen UI, excellent hinting, Latin + Cyrillic + Greek + Vietnamese + Latin Extended. For broader coverage, pair with **Noto Sans CJK** (`SC`/`TC`/`JP`/`KR`) and **IBM Plex Sans Arabic** or **Noto Sans Arabic**.

**Alternative:** **IBM Plex Sans** (Carbon) - more character, excellent script coverage via the Plex family.

**Civic alternative:** **Public Sans** (USWDS) - neutral, smaller file size. Pair with Noto for non-Latin.

**Long-form reading (case files, narrative reports):** **Source Serif 4** or **EB Garamond**. Serif faces measurably improve sustained reading at 14-18px.

**Monospace (IDs, hashes, code):** **JetBrains Mono** or **IBM Plex Mono**. Disable ligatures for IDs and code that shouldn't merge symbols.

**System stack fallback** (zero-network, instant):
```css
font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI",
             Roboto, "Helvetica Neue", Arial, "Noto Sans",
             "Apple Color Emoji", "Segoe UI Emoji", sans-serif;
```

### Type scale

Modular scale at 1.125 (major second) - tight enough for dense UI, varied enough for hierarchy. Avoid scales above 1.25; they create big jumps that read as marketing.

| Token | Size | Line-height | Use |
|---|---|---|---|
| `text-2xs` | 11px / 0.6875rem | 16px | Metadata labels, badges |
| `text-xs` | 12px / 0.75rem | 16px | Table cells (compact), captions |
| `text-sm` | 13px / 0.8125rem | 20px | UI default, table cells (comfortable) |
| `text-base` | 15px / 0.9375rem | 24px | Body prose, form inputs |
| `text-md` | 17px / 1.0625rem | 26px | Long-form reading |
| `text-lg` | 19px / 1.1875rem | 28px | Section headings |
| `text-xl` | 22px / 1.375rem | 30px | Page titles |
| `text-2xl` | 26px / 1.625rem | 34px | Major page titles (rare) |

**Line-heights:** 1.5-1.6 for body prose; 1.25-1.4 for UI; 1.1-1.2 for large headings.

**Weights:** Regular (400), Medium (500), Semibold (600). Avoid Bold (700) in UI.

### Body vs UI vs data type

- **Body (prose):** 15-17px, regular, line-height 1.6, max-width 65-75ch.
- **UI (controls, navigation, labels):** 13-14px, medium for active/selected, regular otherwise. Line-height 1.3.
- **Data (tables, code, IDs):** 12-13px, tabular-nums, slightly tighter line-height (1.4). Monospace only for hashes, IDs, and code - not for general numbers.

### Tabular numerals

```css
.tabular {
  font-variant-numeric: tabular-nums lining-nums;
  font-feature-settings: "tnum" 1, "lnum" 1;
}

/* Mixed contexts in prose */
.prose { font-variant-numeric: oldstyle-nums proportional-nums; }
```

Inter, IBM Plex Sans, Source Sans 3, Public Sans, and most Noto faces support `tnum`. EB Garamond defaults to oldstyle figures (correct for prose) and supports `lnum` for tabular contexts.

### Tailwind config

```js
module.exports = {
  theme: {
    fontFamily: {
      sans: ['Inter var', 'Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
      serif: ['"Source Serif 4"', 'ui-serif', 'Georgia', 'serif'],
      mono: ['"JetBrains Mono"', 'ui-monospace', 'Menlo', 'monospace'],
      arabic: ['"IBM Plex Sans Arabic"', 'Inter', 'sans-serif'],
      cjk: ['"Noto Sans SC"', 'Inter', 'sans-serif'],
    },
    fontSize: {
      '2xs': ['0.6875rem', { lineHeight: '1rem' }],
      xs:    ['0.75rem',   { lineHeight: '1rem' }],
      sm:    ['0.8125rem', { lineHeight: '1.25rem' }],
      base:  ['0.9375rem', { lineHeight: '1.5rem' }],
      md:    ['1.0625rem', { lineHeight: '1.625rem' }],
      lg:    ['1.1875rem', { lineHeight: '1.75rem' }],
      xl:    ['1.375rem',  { lineHeight: '1.875rem' }],
      '2xl': ['1.625rem',  { lineHeight: '2.125rem' }],
    },
    fontWeight: { normal: '400', medium: '500', semibold: '600' },
  },
  plugins: [
    function({ addUtilities }) {
      addUtilities({
        '.nums-tabular': { fontVariantNumeric: 'tabular-nums lining-nums' },
        '.nums-prose':   { fontVariantNumeric: 'oldstyle-nums proportional-nums' },
      });
    },
  ],
};
```

## Color system

Two scales do the heavy lifting:

1. A **12-step neutral gray** (Radix's model) - surface, border, text, hover/active.
2. A small set of **semantic accents** - primary, success, warning, danger, info - each as a 12-step scale.

Optionally, a **categorical palette** of 6-10 hues for tags, entity types, jurisdictions - used sparingly.

### Neutrals (warm gray, OKLCH)

Slightly warm grays read more humane than pure neutral on long sessions.

```css
:root {
  --gray-1:  oklch(0.992 0.002 75);  /* page bg */
  --gray-2:  oklch(0.978 0.003 75);  /* panel bg */
  --gray-3:  oklch(0.955 0.004 75);  /* subtle bg, hover */
  --gray-4:  oklch(0.930 0.005 75);  /* element bg */
  --gray-5:  oklch(0.908 0.006 75);  /* element hover */
  --gray-6:  oklch(0.880 0.007 75);  /* element active */
  --gray-7:  oklch(0.840 0.008 75);  /* subtle border */
  --gray-8:  oklch(0.770 0.010 75);  /* border */
  --gray-9:  oklch(0.620 0.011 75);  /* solid bg, muted text */
  --gray-10: oklch(0.560 0.011 75);  /* solid hover */
  --gray-11: oklch(0.460 0.011 75);  /* secondary text */
  --gray-12: oklch(0.180 0.010 75);  /* primary text */
}
```

### Semantic accents

Restrained, civic - closer to GOV.UK / Carbon than Material's bright defaults.

```css
:root {
  --primary-9:  oklch(0.50 0.18 255);  /* solid */
  --primary-11: oklch(0.45 0.19 255);  /* text on light */
  --success-9:  oklch(0.55 0.14 155);
  --warning-9:  oklch(0.70 0.16 75);
  --danger-9:   oklch(0.55 0.20 25);
  --info-9:     oklch(0.60 0.10 230);
}
```

### Contrast rules

- **Body text:** ≥ 7:1 (AAA) for primary content; AA (4.5:1) is the floor.
- **Secondary text / labels:** ≥ 4.5:1.
- **Disabled / placeholder:** ≥ 3:1, but never use color alone to indicate state.
- **UI borders:** ≥ 3:1 against adjacent background for inputs and focus rings.
- **Focus rings:** 2px solid ring, ≥ 3:1 against background, plus 2px offset. Never remove `:focus-visible`.

### Dark mode

Don't simply invert. Surfaces lift via lighter grays, not shadows. Reduce saturation of accents by ~10-20% to avoid vibration.

```css
@media (prefers-color-scheme: dark) {
  :root {
    --gray-1:  oklch(0.150 0.005 75);
    --gray-2:  oklch(0.180 0.005 75);
    --gray-12: oklch(0.960 0.005 75);
    --primary-9: oklch(0.65 0.15 255);
  }
}
```

Body text in dark mode at full white is too harsh - use `~oklch(0.94)`. Pure black backgrounds cause halation; use `~oklch(0.15)` as the darkest surface.

### When color carries meaning vs decoration

- **Meaning:** status (open/closed/redacted), severity, category (entity-type tags), link affordance.
- **Decoration (avoid):** alternating row backgrounds purely for visual rhythm, full-color icons in navigation, colored section headers without semantic purpose, branded accents on every card.

Always pair color with a non-color cue: an icon, a text label, or a shape. Critical for color-blind users (and for print/export).

## Spacing and density

### Scale

4px base, with 2px half-step for fine UI:

```js
spacing: {
  px: '1px',
  0.5: '2px', 1: '4px', 1.5: '6px',
  2: '8px',   3: '12px', 4: '16px',
  5: '20px',  6: '24px', 8: '32px',
  10: '40px', 12: '48px', 16: '64px',
  20: '80px', 24: '96px',
}
```

### Density modes

```css
:root[data-density="comfortable"] {
  --row-height: 40px;
  --cell-pad-y: 10px;
  --cell-pad-x: 16px;
  --control-height: 36px;
}
:root[data-density="compact"] {
  --row-height: 28px;
  --cell-pad-y: 4px;
  --cell-pad-x: 10px;
  --control-height: 28px;
}
```

For tables specifically, also offer a "dense" option (24px rows) for scanning hundreds of records.

### Grid

12-column grid with fluid gutters (16-24px). For records-and-detail layouts, prefer fixed sidebars (240-320px) + fluid main + optional context panel (320-400px). Cap reading content at 65-75ch. Use CSS subgrid for tables and form rows so labels and values align across siblings.

## Iconography

### When to use icons

- **Use:** repeated actions in toolbars, indicator of state (locked, redacted, verified), navigation when paired with a text label, affordance hints.
- **Don't use:** as decoration in headings, alongside every list item, in place of text labels for primary actions.

For first-time users and accessibility, **always pair icons with text labels** in primary navigation. Tooltip-only icons fail keyboard and screen-reader users.

### Style

Pick one style and stick to it. **Line icons** (1.5-2px stroke) read as restrained and pair well with text. **Filled icons** carry more weight; reserve for active/selected states or critical alerts.

**Size:** match cap-height of adjacent text. At 14px text, use 16px icons. At 13px text, 14px. Optical alignment matters more than mathematical centering.

### Libraries

- **Lucide** - open-source fork of Feather, ~1500 icons, MIT, line style. Best default.
- **Phosphor** - multiple weights (thin, light, regular, bold, fill, duotone), MIT.
- **Tabler Icons** - large set, MIT, slightly more decorative.
- **Heroicons** - pairs with Tailwind, smaller set, two weights.
- **Carbon Icons** - IBM, restrained, excellent for enterprise/data.

Avoid mixing libraries. If Lucide doesn't have an icon, draw a matching one rather than importing a different family.

## Microcopy

- **Labels:** sentence case, not Title Case ("Date filed", not "Date Filed").
- **Buttons:** verbs, not nouns ("Add document", "Export results"). Avoid "Submit" - say what it does.
- **Empty states:** explain *what* should be here, *why* it's empty, and *how* to populate it. "No documents match these filters. Try removing the date range or [clear all filters]."
- **Errors:** plain language, no codes in the primary message ("Couldn't load this record. The server didn't respond - retry."). Codes in secondary text for support.
- **Loading:** skeleton screens for predictable layouts, spinners only when duration is unpredictable. Never block the whole page if part is ready.
- **Counts:** "1,247 records" not "1247 records" - thousands separators always. Localize.
- **Dates:** ISO format (`2026-04-27`) for filenames and exports; localized format with explicit month name (`27 Apr 2026`) for UI to avoid US/EU ambiguity.
- **Truncation:** "…" only when the full value is accessible elsewhere (tooltip, detail page). Never truncate IDs, hashes, or anything the user might need to copy.

**Survivor- and victim-centered language** (see also [trustworthy-display.md](trustworthy-display.md)):

| Avoid | Prefer |
|---|---|
| "Kills," "body count" | "People killed," "deaths recorded" |
| "Victims database" | "Records of people affected" |
| "Top perpetrators" leaderboard | "Reported responsible parties" (no ranking) |
| "Engaging," "compelling" stats | "Documented," "verified" |

## Quick-start tokens

```css
:root {
  --font-sans: 'Inter var', ui-sans-serif, system-ui, sans-serif;
  --font-serif: 'Source Serif 4', ui-serif, Georgia, serif;
  --font-mono: 'JetBrains Mono', ui-monospace, Menlo, monospace;

  --text-body: 15px / 1.6 var(--font-sans);
  --text-ui:   13px / 1.3 var(--font-sans);
  --text-data: 13px / 1.4 var(--font-mono);

  --bg:           oklch(0.992 0.002 75);
  --surface:      oklch(0.978 0.003 75);
  --border:       oklch(0.840 0.008 75);
  --text:         oklch(0.180 0.010 75);
  --text-muted:   oklch(0.460 0.011 75);
  --primary:      oklch(0.50 0.18 255);
  --danger:       oklch(0.55 0.20 25);
  --focus-ring:   oklch(0.50 0.18 255 / 0.5);
}
```

Start here. Tighten as the product reveals what it actually needs - and remove anything you added "just in case." The data is the star.
