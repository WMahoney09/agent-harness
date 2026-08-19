# Artifact components

Fixed, versioned blocks pasted into an artifact verbatim. They are utilities, not design surface — do not restyle them to match the page, and do not regenerate them per artifact.

| File | When |
|---|---|
| `theme-toggle.html` | Every artifact, unless the design deliberately commits to a single look |
| `view-router.html` | Any deliverable spanning several pages |

The feedback layer lives in the `artifact-annotate` skill, which owns reviewability. This skill's only obligations toward it are `data-cid` on commentable blocks and leaving the right-hand screen corners free.

---

## Theme control

Three states behind `○ ◐ ●` — white circle, half-filled, filled. Fill encodes brightness.

The glyphs are Geometric Shapes (U+25CB, U+25D0, U+25CF), which no platform substitutes into a colour emoji font. Do not swap them for `☀`/`☾`: U+2600 gets emoji-substituted on iOS and some Android builds despite its text default, and U+263E has spotty font coverage on Windows and lands at the wrong optical size.

It writes and removes `data-theme` on `<html>`, which is what the Artifact contract's three-block token structure already responds to. It adds no selectors to the page palette and needs no changes to it.

It also sets `color-scheme` — `light dark` on auto, the explicit value otherwise. This is not optional. The Artifact wrapper's reset pins `:root{color-scheme:light}`, and without overriding it the caret, text selection, scrollbars, and form controls render light on a dark page. Token colours alone do not reach native UA surfaces.

Printing forces light via `beforeprint`, which excludes the dark media block and falls through to the base `:root` tokens. No print-specific palette needed.

**The host stamps the same attribute, confirmed.** The frame runtime sets and removes `data-theme` on `<html>` and manages `style.colorScheme` alongside it, driven by a `__frame_theme` message from the shell. A page-level choice holds until the reader changes theme in the Claude UI, at which point the host overwrites it. That is acceptable and not worth working around — the alternative is a private `data-ui-theme` attribute and a third copy of every token block.

**The wrapper's reset, for reference.** Five declarations, and the standalone copy should replicate only the first two:

```css
:root { color-scheme: light }                          /* do not copy — breaks dark */
body  { margin:0; padding:0; font:14px -apple-system,BlinkMacSystemFont,sans-serif;
        background:#faf9f5; color:#141413 }            /* copy margin/padding only */
img   { max-width:100% }                               /* copy */
```

The hardcoded background and colour are pointless to replicate since the page's own tokens override both, and copying `color-scheme: light` would reintroduce the bug this component exists to avoid.

---

## View router

**Any deliverable spanning several pages is one file with hash-routed views.** Relative links between separate local HTML files are never used.

They work only when the whole set lands in one folder with filenames matching the hrefs, and delivery breaks that routinely: Slack downloads attachments one at a time and suffixes on collision, mail clients open attachments from per-file temp directories, and Windows Explorer lets a reader browse *inside* a zip and open a page from there — which copies that one file to a temp directory and kills every link with no visible sign anything went wrong.

The component is the router plus four lines of CSS. The nav is design surface and gets styled with the page; style `aria-current="page"` rather than adding a class.

Deep links into a view work — `href="#type-scale"` pointing at a heading inside the typography view opens that view and scrolls to the heading. An overview that cross-references other sections should use them. A router that only handles top-level view ids drops every deep link silently, which is the failure worth spending the `closest()` call to avoid.

Two properties worth knowing. Views are visible by default and hidden by script, so with JS disabled the file degrades to one long document rather than a blank page. Print does the same deliberately: the reader gets the complete deliverable as a PDF from a single Cmd-P, which a set of separate files cannot do.

### Size

Inlining is the constraint, and mockup imagery is the only thing that usually threatens it. A full-page desktop PNG at 1440px runs 300KB–1.5MB, and base64 adds about a third. A dozen mockups can reach 10–20MB. Slack carries that; Gmail cuts off at 25MB and plenty of corporate systems sit at 10.

Three levers, in order of return: WebP instead of PNG cuts screenshot weight 40–70%; downscale to twice the displayed size rather than native retina; SVG for anything vector — type specimens, colour swatches, logos, icons — which costs almost nothing. Add `loading="lazy"` so the browser defers decoding views nobody has opened.

If it still won't fit, split by weight rather than by topic — mockups in their own file, everything else together — and accept that the two halves have no links between them.
