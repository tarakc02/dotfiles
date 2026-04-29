# Trustworthy Display

Provenance, confidence, and sensitive-content handling - co-located because all three are about *evidentiary integrity*: helping users assess what they're looking at, where it came from, how certain it is, and how to engage with material that may be graphic or harmful. Users of these systems include researchers, journalists, prosecutors, survivors, and families. The UI's job is to make these judgments easy.

## Contents

- [Core principles](#core-principles)
- [Pattern: Inline source citations](#pattern-inline-source-citations)
- [Pattern: Field-level provenance badges](#pattern-field-level-provenance-badges)
- [Pattern: Confidence indicators](#pattern-confidence-indicators)
- [Pattern: Chain-of-custody timeline](#pattern-chain-of-custody-timeline)
- [Pattern: Versioning with diff affordances](#pattern-versioning-with-diff-affordances)
- [Pattern: Source register pages](#pattern-source-register-pages)
- [Pattern: Content warnings before media](#pattern-content-warnings-before-media)
- [Pattern: User-controlled sensitivity categories](#pattern-user-controlled-sensitivity-categories)
- [Pattern: Redaction display](#pattern-redaction-display)
- [Pattern: Dignified statistics displays](#pattern-dignified-statistics-displays)
- [Pattern: Persistent off-ramp](#pattern-persistent-off-ramp)
- [Microcopy: people first](#microcopy-people-first)

## Core principles

**Every claim is sourced or labeled "unsourced."** A field with no citation is a red flag, not a default state. Hiding low-confidence data looks like cover-up; label it instead.

**Distinguish source-of-truth from extracted/inferred.** Visual treatment - badges, color, confidence bars - not just metadata. A field from structured leak data and one from NER on a scanned passport must look different in the UI.

**Express uncertainty in the units the data has.** Ranges, qualitative bands ("high/medium/low"), or "see methodology" - never invented decimals. "92.7% confidence" on an uncalibrated model misleads.

**Chain of custody is browsable, not buried.** A record's processing history is a timeline, accessible from the record itself.

**Versioning is honest.** When a record changes, the prior version is reachable; substantive changes are flagged with a banner on the record itself.

**Default to safety, not surprise.** Graphic imagery blurred and audio muted by default; warnings present *before* the content, not after.

**Granular, persistent user control.** A single "show all graphic content" toggle is a blunt instrument. Let users choose by category, persist the choice.

**Survivor- and victim-centered language.** Microcopy names people first ("people killed" not "kills"); avoids language that flatters perpetrators or aestheticizes harm.

**Distinguish source redactions from system redactions.** A black bar in the original is not the same as one your platform applied. Users must be able to tell which is which, and why your platform redacted.

**No gamification of violence.** No streaks, badges, "trending atrocities," progress bars on body counts, or animated counters for casualties.

**Make the off-ramp obvious.** A persistent "back to results" / "hide this" affordance on every sensitive view; no autoplay, no auto-advance.

## Pattern: Inline source citations

Footnote-style links that resolve to a source register, with a hover/focus preview:

```html
<p>
  The convoy departed at approximately 14:30 local time<sup>
    <a href="#src-12" id="ref-12-1" aria-describedby="src-12-preview">[12]</a>
  </sup>, arriving at the checkpoint two hours later<sup>
    <a href="#src-13">[13]</a>
  </sup>.
</p>

<aside id="src-12-preview" role="tooltip" hidden>
  Witness statement W-0421, recorded 2014-08-03, Geneva.
  Reliability: corroborated by two independent witnesses.
</aside>
```

The preview must be keyboard-accessible (focus on the link triggers it; `Esc` dismisses), not hover-only.

## Pattern: Field-level provenance badges

Each field shows its origin via a small, consistent badge. Use icon + text, not icon alone. Color carries redundancy with the text label (WCAG SC 1.4.1).

```jsx
<dl>
  <dt>Date of incident</dt>
  <dd>
    2014-08-03
    <ProvBadge kind="source" />        {/* "From source document" */}
  </dd>
  <dt>Estimated casualties</dt>
  <dd>
    120–180
    <ProvBadge kind="extracted" />     {/* "Extracted from text" */}
    <ConfidenceBar level="medium" />
  </dd>
  <dt>Likely responsible unit</dt>
  <dd>
    4th Mechanized Brigade
    <ProvBadge kind="inferred" />      {/* "Inferred by analyst" */}
    <ConfidenceBar level="low" />
  </dd>
</dl>
```

```jsx
function ProvBadge({ kind }) {
  const map = {
    source:    { label: 'From source',      cls: 'bg-emerald-50 text-emerald-900 border-emerald-300' },
    extracted: { label: 'Extracted',        cls: 'bg-sky-50 text-sky-900 border-sky-300' },
    inferred:  { label: 'Analyst inferred', cls: 'bg-amber-50 text-amber-900 border-amber-300' },
    unsourced: { label: 'Unsourced',        cls: 'bg-rose-50 text-rose-900 border-rose-300' },
  };
  const { label, cls } = map[kind];
  return <span className={`text-xs px-1.5 py-0.5 border rounded ${cls}`}>{label}</span>;
}
```

Border + text + icon means it survives in monochrome and high-contrast modes.

## Pattern: Confidence indicators

Three or four bands, named, with definitions linked. Encode redundantly (color + shape + label):

```jsx
function ConfidenceBar({ level }) {
  const map = {
    high:   { dot: 'bg-emerald-500', label: 'High confidence' },
    medium: { dot: 'bg-amber-500',   label: 'Medium confidence' },
    low:    { dot: 'bg-rose-500',    label: 'Low confidence' },
  };
  const { dot, label } = map[level];
  return (
    <span className="inline-flex items-center gap-1.5" title={label}>
      <span className={`w-2 h-2 rounded-full ${dot} ring-1 ring-inset ring-black/10`}
            aria-hidden="true" />
      <span className="text-xs">{label}</span>
      <a href="#methodology-confidence" className="sr-only">
        Read confidence methodology
      </a>
    </span>
  );
}
```

For numeric bars (when the model is calibrated and you can defend the number):
```jsx
<span className="inline-flex items-center gap-1.5">
  <span className="w-8 h-1.5 bg-neutral-200 rounded-full overflow-hidden">
    <span className={`block h-full ${tierColor}`} style={{ width: `${value*100}%` }} />
  </span>
  <span className="text-xs tabular-nums text-neutral-600">{(value*100).toFixed(0)}</span>
</span>
```

For `value < 0.5`, additionally surface a warning icon and require user confirmation before treating the value as canonical.

**Avoid:** percentages with two decimal places. Users will read that as scientific. Bucket into 3 tiers; users don't make decisions on continuous probabilities.

## Pattern: Chain-of-custody timeline

```html
<section aria-labelledby="custody-h">
  <h3 id="custody-h">Processing history</h3>
  <ol class="timeline">
    <li>
      <time datetime="2014-08-04">2014-08-04</time>
      Received from field partner (Org A), encrypted transfer.
    </li>
    <li>
      <time datetime="2014-08-09">2014-08-09</time>
      Translated from Arabic by Translator T-12.
    </li>
    <li>
      <time datetime="2014-08-15">2014-08-15</time>
      Coded against HURIDOCS events schema by Analyst A-03.
    </li>
    <li>
      <time datetime="2024-03-12">2024-03-12</time>
      Re-reviewed; location precision downgraded from village to district.
    </li>
  </ol>
</section>
```

Show the *kind* of step, not just timestamps - users want to see whether a human or a pipeline touched the data, and which.

## Pattern: Versioning with diff affordances

```html
<header class="record-header">
  <h1>Record HRDAG-2014-0182</h1>
  <p>
    Version 4 of 4 (<time datetime="2024-03-12">2024-03-12</time>) ·
    <a href="?version=3">View previous</a> ·
    <a href="?compare=3,4">See changes</a>
  </p>
</header>
```

For substantive changes, show a banner on the record itself:

```html
<div role="note" class="banner banner--correction">
  This record was corrected on 2024-03-12. Location precision was
  reduced from village to district based on re-review.
  <a href="?compare=3,4">See what changed</a>.
</div>
```

## Pattern: Source register pages

Each cited source has a stable URL, a description, a reliability note, and inbound links from records that cite it. From a record, a "Sources used in this record" panel lists them with counts.

This makes the source register a first-class artifact, not a footnote. Investigators use it to evaluate the corpus's evidentiary basis.

## Pattern: Content warnings before media

The warning is *content*, not a tooltip. Reveal is a real button; settings link is adjacent. Be specific: "human remains," "child, visible injuries," "executed individual." Vague "graphic content" is unhelpful.

```jsx
<figure className="border border-slate-300 rounded">
  {revealed ? (
    <img src={src} alt={alt} />
  ) : (
    <div className="p-6 bg-slate-50 text-center">
      <p className="font-semibold">Image withheld by default</p>
      <p className="text-sm text-slate-700 mt-1">
        This photograph depicts {categoriesText}.
        Source: {source}. Date: {date}.
      </p>
      <div className="mt-4 flex gap-3 justify-center">
        <button type="button" onClick={() => setRevealed(true)}>
          Show image
        </button>
        <a href="/settings/sensitive-content" className="underline">
          Change defaults
        </a>
      </div>
    </div>
  )}
</figure>
```

**Blur as a fallback option, not the primary signal.** A blurred thumbnail still conveys composition. Prefer a neutral placeholder with descriptive text; offer blur as a middle option for users who want to scan visually:

```
[ Hidden ]  [ Blurred ]  [ Show ]
```

Persist the choice per category and per session.

## Pattern: User-controlled sensitivity categories

Specific categories, not a single global toggle. Persist per user (localStorage for unauthenticated, profile for authenticated):

```jsx
const CATEGORIES = [
  { id: 'remains',   label: 'Human remains' },
  { id: 'injury',    label: 'Visible serious injury' },
  { id: 'children',  label: 'Children as subjects' },
  { id: 'sexual',    label: 'Sexual violence' },
  { id: 'execution', label: 'Killings shown directly' },
  { id: 'detention', label: 'Detention / restraint' },
];
```

Each piece of content is tagged with applicable categories; the UI checks against user prefs before revealing. Notifications and preview thumbnails respect the same categories - never surface graphic content in a notification preview.

## Pattern: Redaction display

Two visually and semantically distinct treatments:

```html
<!-- Source redaction: present in the original document -->
<span class="redaction redaction--source"
      role="img" aria-label="Redacted in source document">
  ████████
</span>

<!-- System redaction: applied by this platform -->
<span class="redaction redaction--system"
      role="img" aria-label="Redacted by archive: name of minor">
  [name withheld]
  <button type="button" class="redaction__info" aria-label="Why redacted">
    <svg aria-hidden="true">…</svg>
  </button>
</span>
```

```css
.redaction--source {
  background: #000; color: #000; user-select: none;
}
.redaction--system {
  background: repeating-linear-gradient(
    45deg, #fde68a, #fde68a 4px, #fcd34d 4px, #fcd34d 8px);
  padding-inline: 0.25rem; border-radius: 2px;
  font-style: italic;
}
```

Hover/focus on the system redaction reveals reason metadata in a popover: who redacted, when, policy reference, appeal contact. Source redactions get no popover beyond "redacted in source."

## Pattern: Dignified statistics displays

No confetti, no large-number "odometer" animation, no celebratory color. Sober, neutral palette communicates gravity without spectacle.

```html
<section class="stat">
  <p class="stat__value">8,372</p>
  <p class="stat__label">people identified as killed in this dataset</p>
  <p class="stat__provenance">
    As of 2024-03-12. Estimate; see <a href="#methodology">methodology</a>.
    Range: 7,910–9,140.
  </p>
</section>
```

Always show: the number, what it counts (specific, person-first), as-of date, range or uncertainty, link to methodology.

**Avoid:**
- Red-on-black "war room" aesthetics.
- Heat maps where redder = more deaths, with no legend acknowledging human cost.
- Animated counters that climb from zero.
- "Trending" or "leaderboards" of any kind in atrocity contexts.
- Achievements/badges for "records reviewed," "documents tagged" on volunteer interfaces.

## Pattern: Persistent off-ramp

Every record/media page exposes:
- A clearly labeled "Back to results" at the top, not just browser back.
- A "Hide this content" affordance that returns the user *and* updates their category preference if they want.
- No autoplay; no "next record" auto-advance.

## Microcopy: people first

| Avoid | Prefer |
|---|---|
| "Kills," "body count" | "People killed," "deaths recorded" |
| "Victims database" | "Records of people affected" |
| "Top perpetrators" leaderboard | "Reported responsible parties" (no ranking) |
| "Violations trending" | "Recently documented violations" |
| Animated counters | Static counts with last-updated timestamp |
| "Engaging," "compelling" stats | "Documented," "verified" |

## Anti-patterns to avoid

- A generic "Sources" footer link for the whole site instead of per-claim citation.
- Presenting model-extracted fields identically to verified fields, distinguished only by a tooltip.
- Confidence as a single percentage with two decimal places.
- "Last updated" with no record of *what* changed.
- Hiding low-confidence fields to make the dataset "look cleaner."
- Tooltips as the sole channel for provenance - not keyboard-reachable, invisible on print/export.
- A single global "I am over 18 / show graphic content" gate that, once accepted, reveals everything forever.
- Decorative photography of suffering on landing pages.
- Hover-to-reveal as the only mechanism (fails on touch, fails for screen readers, leaks on accidental hover).
- Notifications that surface graphic content in previews.
