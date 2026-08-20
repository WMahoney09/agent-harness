# Hot Slate

A three-stop heat ramp for tool chrome — the interface a Gnar tool wraps around someone else's content. Named so it can be asked for by name across projects.

Derived from the blackbody progression in `gnar-statusline.sh` (`gradient_at`), truncated before the ramp reaches white and lifted at the cool end so it holds on a light ground as well as a dark one.

## The palette

| Token | Hex | Role |
|---|---|---|
| `--hs-cool` | `#6B7285` | Ramp start. Cool slate. |
| `--hs-mid` | `#B04A3A` | Ramp middle, and the solid accent on light grounds. Brick. |
| `--hs-warm` | `#C27620` | Ramp end. Amber. **Never carries text.** |
| `--hs-warm-ink` | `#B05F16` | The same amber at text-safe luminance. Warm terminus of any *filled* control. |
| `--hs-lift` | `#D06A55` | The mid, lifted. Solid accent on dark grounds, where the brick is too dark for text. |
| `--hs-ink-0` | `#C1341F` | Filled-control gradient start. |
| `--hs-ink-1` | `#D84025` | Solid fill under white text. |

**The ramp has two warm terminals.** `--hs-warm` wherever the gradient is a ring, glow, or rule. `--hs-warm-ink` wherever text sits on it — white on `#C27620` is 3.6:1, under the 4.5:1 text bar, and `#B05F16` is the same amber pulled down to 4.65:1. A filled control running the ramp ends at the ink value; everything else ends at the true amber.

```css
--hs-ramp: linear-gradient(120deg, #6B7285, #B04A3A, #C27620);
--hs-ramp: linear-gradient(120deg in oklab, #6B7285, #B04A3A, #C27620);
```

Declare the sRGB version first as a fallback — a browser without `in oklab` drops the whole declaration, and sRGB interpolation across this ramp is muddier but serviceable.

## Contrast

Two AA thresholds apply and the ramp straddles them. Text needs 4.5:1 against its ground. A border, ring, rule, or glow is a non-text UI component and needs 3:1 against what sits beside it.

Grounds assumed: light `#F5F6F7`, dark `#101114`.

| Stop | White text | On light | On dark | Cleared for |
|---|---|---|---|---|
| `#6B7285` cool | 4.8 | 4.4 | 3.9 | Text and non-text, both themes |
| `#B04A3A` mid | 5.4 | 5.0 | 3.5 | Text on light; non-text everywhere |
| `#C27620` warm | 3.6 | 3.3 | 5.3 | **Non-text only** |
| `#B05F16` warm-ink | 4.7 | 4.2 | 3.9 | Text and non-text, both themes |
| `#D06A55` lift | 3.6 | 3.0 | 5.3 | Text on dark; non-text everywhere |
| `#C1341F` ink-0 | 5.6 | 5.2 | 2.9 | Fills under white text |
| `#D84025` ink-1 | 4.5 | 4.1 | 3.3 | Fills under white text |

Every ramp stop clears 3:1 on both grounds, so the ramp itself needs no theme split. Only the solid accent does — `#B04A3A` on light, `#D06A55` on dark — because the brick drops to 3.5:1 as text on a dark ground.

Ratios are hand-computed from sRGB relative luminance. Re-run them through a checker before shipping to a client.

## Rules

**The warm end never sits under text.** White on `#C27620` is 3.6:1. A filled control that wants the ramp's warm end terminates at `--hs-warm-ink` instead — same hue, text-safe luminance.

**The ramp goes on rings, glows, rules, and region borders.** Those carry no text, they are where a gradient actually reads, and they are what makes the tooling recognisable across deliverables.

**Solid accent for focus rings, hover borders, and accent text.** A gradient cannot be an `outline`, and text on a gradient is a legibility problem regardless.

## Techniques

**Gradient ring with a transparent interior.** The two-layer `padding-box` / `border-box` background cannot do this — its ramp layer paints across the whole element, so a low-alpha fill over it tints a solid gradient rather than washing the content underneath. `border-image` gives a real ring but squares off rounded corners. Use a masked pseudo-element:

```css
.thing { position: relative; border-radius: 8px; }
.thing::before {
  content: "";
  position: absolute;
  inset: 0;
  padding: 2px;                 /* ring thickness */
  border-radius: inherit;
  pointer-events: none;
  background: var(--hs-ramp);
  -webkit-mask: linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0);
  -webkit-mask-composite: xor;
  mask: linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0);
  mask-composite: exclude;
}
```

**Region wash.** The element's own background runs the same ramp at 13–15% alpha, in the same direction as the ring. The highlight is one object, so the ring and the wash agree.

**Glow.** Layer three shadows in the ramp's colours rather than one — a tight halo, a mid bloom, a wide falloff. Stacking is what makes it read as a gradient rather than a flat ring, and box-shadows follow `border-radius` so the glow takes the shape.

**Filled controls.** `linear-gradient(135deg in oklab, #C1341F, #B05F16)` for the hot end, `#6B7285 → #B04A3A` for a cool-skewed one. A set of related controls reads best as narrow bands at different positions on the ramp rather than as separate colours — one scale, several points on it.

## Where it came from

The comparison that settled it weighed this against a teal-start variant on the real surfaces of `artifact-draft`'s chrome. Slate won on being neutral at the cool end — a teal start reads as its own brand colour and competes with the deliverable's palette, which is the one thing tool chrome must not do.
