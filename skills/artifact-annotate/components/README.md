# Feedback layer

A fixed, versioned block pasted into an artifact verbatim. It is a utility, not design surface — do not restyle it to match the page, and do not regenerate it per artifact. Every deliverable carrying a different feedback format means the ingest side has to guess.

| File | Role |
|---|---|
| `feedback-layer.html` | The component. ~350 lines, pasted last. |
| `feedback-schema.json` | `gnar.artifact-feedback/1`. The contract between capture and ingest. |

---

## `data-cid` — the anchor rule

**Every commentable block carries `data-cid`, on every artifact, whether or not the feedback layer ships with it.** `artifact-craft` applies the rule as part of every build; this skill defines it.

A commentable block is one a reader would have an opinion about — a paragraph, a card, a table, a milestone, a diagram. Not every `<div>`. Sixty comment targets on a page is worse than fifteen.

**Never put `data-cid` on a `<table>`, `<thead>`, `<tbody>`, `<tr>`, or `<td>`.** The layer appends its marker as a child of the anchored element, and a `<button>` inside table markup renders badly. Put it on the `overflow-x: auto` wrapper the table already needs — which is also the thing a reader means when they comment on "the table."

Format is nearest-heading slug plus an ordinal within that heading: `milestones-3`, `risks-1`. In a multi-view file the heading slug picks up the view name on its own — `typography-scale-2` — so ids stay unique file-wide with no extra rule.

It is deterministic, so a regenerated revision produces matching ids for unchanged structure with nobody tracking anything. Ids shift when a block is inserted mid-section; the quote fallback exists for that, so do not build machinery to prevent it.

Emitting cids always costs a few tokens per block and no discipline, and it is the one property that is expensive to retrofit. A plain artifact carrying cids can accept feedback later by any route and still resolve anchors.

**The heading a comment records is the block's own, when it has one.** `headingFor` takes a heading contained in the commented block first, then walks back through *sibling* headings, then up a level. Checking the block's own heading first is what stops a run of sibling cards each recording its neighbour's; counting only sibling headings on the walk is what makes a note following those cards record the section heading above them rather than the last card's.

`data-fbk-heading="…"` overrides the result on a block where it still reads wrong.

**Stability is shared with the content skill.** Cids derive from headings, and headings come from the ontology, PRD, or exec-summary skill that authored the content. Renaming a section moves every cid under it. Once a deliverable has been reviewed, section names are an interface.

---

## The marker colour

The component runs on **Hot Slate** — the named tool-chrome ramp in `docs/reference/hot-slate.md`, which carries the full palette, the contrast table, and the techniques. What follows is only what the feedback layer does with it.

| Token | Light | Dark | Used for |
|---|---|---|---|
| `--fbk-heat-0` | `#6B7285` | `#6B7285` | Ramp cool end |
| `--fbk-heat-1` | `#B04A3A` | `#B04A3A` | Ramp middle |
| `--fbk-heat-2` | `#C27620` | `#C27620` | Ramp warm end — rings, glows, rules only |
| `--fbk-accent` | `#B04A3A` | `#D06A55` | Solid outlines, focus rings, accent text, cursor stroke |
| `--fbk-ink-0` | `#C1341F` | `#C1341F` | Filled-control gradient start |
| `--fbk-accent-ink` | `#D84025` | `#D84025` | Solid fill under white text |
| `--fbk-warm-ink` | `#B05F16` | `#B05F16` | Filled-control gradient end |

Ramp stops clear 3:1 on both grounds, so the ramp itself needs no theme split. Only `--fbk-accent` does — the brick drops to 3.5:1 as text on a dark ground.

**The ramp has two warm terminals.** `--fbk-heat-2` wherever it is a ring, glow, or rule. `--fbk-warm-ink` wherever text sits on it — white on `#C27620` is 3.6:1, and `#B05F16` is the same amber pulled down to 4.65:1. Send feedback, the Reviewing toggle, and the three kind selectors are all filled controls and all terminate at the ink value.

Where the ramp appears: marker rings and their glow, the panel header rule, the region wash, and the filled controls as narrow bands — blocking at the ramp's middle, suggestion at the warm end, question at the cool end. Solid `--fbk-accent` handles anything a gradient cannot be, which is outlines and text.

It is the component's colour, not the page's, and that is the point. The tooling should read as one system across every deliverable, so a reviewer who has commented on one artifact recognises the affordance on the next. Reading the page's accent instead would also require a token-naming convention no artifact is obliged to follow.

A deliverable that does want its markers in its own palette overrides the one token from its own stylesheet, after the component:

```css
:root { --fbk-pin: var(--accent); }
```

That moves the pin and the glow together. **The cursor does not follow it** — a `data:` URI cannot read a custom property, so the stroke colour is `--fbk-accent` written out as a literal in each theme block. Changing the primary means editing those two hexes as well.

Check contrast against the page ground before overriding. The marker is the only way a reviewer finds their own comments again.

**The page can leak into the component.** A deliverable that sets a bare `:focus-visible` rule — common, and correct for its own content — reaches into this component's fields and buttons and paints the focus ring in the page's accent. The component defends itself with one scoped rule, `.fbk-root :focus-visible`, which outranks the unscoped selector. Any future styling that a page might set globally on elements rather than classes deserves the same treatment.

## Configuration

Fill in `#feedback-config` and nothing else:

```json
{
  "docId": "platform-tech-approach",
  "title": "Platform Technical Approach",
  "revision": "2026-08-19T14:02:00Z",
  "endpoint": null
}
```

- `docId` — matches the source filename in `ideate/artifacts/`. Also namespaces localStorage, which matters because Chrome puts every `file://` page on one shared origin and two deliverables on the same laptop would otherwise collide.
- `revision` — the publish timestamp. Ingestion resolves anchors against *this* revision's HTML, not current HEAD. A client who sits on a file for two weeks still gets exact anchors.
- `endpoint` — `null` today. When set, the sheet gains a Submit button that POSTs the record directly and export becomes the fallback. The transport is pluggable so a hosted platform adds a route rather than changing the component.

**No address is configured, deliberately.** Nothing in the component knows where feedback should go, so nothing about where it should go ships inside a file handed to a client. A reviewer sends their export wherever the covering message told them to.

A multi-view deliverable is one file and therefore one `docId`, one storage bucket, and one submission covering every view.

---

## The two return paths

| Path | Reviewer effort | Ceiling | Ingest |
|---|---|---|---|
| Copy → paste | Two steps, any channel | None | Wherever they pasted |
| Download → send | Highest | None | Whatever channel they chose |

**Copy emits Markdown, not JSON.** It reads in a Slack message unaided and parses just as reliably from a fixed grammar. Download emits JSON.

**There is no email button.** A `mailto:` path existed and was removed. It carried no attachments, the OS handoff truncated past roughly 2,048 characters so it disabled itself on any substantial review, it was dead on a machine with no mail client configured, and it was the only part of the component needing a per-installation address — which meant an example address in this file, which meant that address getting copied into artifacts by whoever installed the skill next.

A reviewer who wants to email their feedback copies it and pastes it into their own message, which is what they were doing above the character ceiling anyway.

**The automation hook lives in the body, not the subject.** Every payload carries `schema: gnar.artifact-feedback/1` on line five. A mail search on that string finds every submission and survives a reviewer editing their subject line, which a subject-based hook does not.

### Markdown grammar

Stable. The ingest side parses it; changing it is a schema bump.

```
Feedback — Platform Technical Approach
doc: platform-tech-approach · rev: 2026-08-19T14:02:00Z
reviewer: Dana Ruiz
comments: 2
schema: gnar.artifact-feedback/1

[blocking] Milestone 2 — Order ingestion  (cid: milestones-3)
> cutover happens in a single weekend window
We can't do a weekend cutover — the warehouse runs Saturday.

[question] Data migration  (cid: migration-1)
> incremental backfill over two weeks
How is reconciliation handled?
```

Header block, blank line, then one comment per block: a `[kind] heading  (cid: …)` line, an optional `> quote` line, then the body. Comments separated by a blank line.

`comments:` is an integrity check for the ingest side, and it exists only in the Markdown form. A truncated or hand-edited Markdown payload still parses cleanly and just comes out shorter, so a declared count is the only detector for it. JSON needs no equivalent — truncation makes it invalid JSON, and the array length is the count.

---

## Republishing with responses

Round two embeds `#feedback-responses` in the regenerated page so the reviewer sees what happened to each item where they raised it:

```json
[{ "commentId": "c1", "cid": "milestones-3", "reviewer": "Dana Ruiz",
   "disposition": "fixed", "note": "Cutover moved to a Tuesday window." }]
```

Dispositions are `fixed` / `intentional` / `deferred` / `declined` — the same four that close a finding in a code review, and equal in the same way. A declined item is closed, not pending.

`docId` stays constant across revisions; `revision` changes. Preserve cids for surviving blocks so responses stay anchored.

---

## Open questions

Untested, and worth resolving before this is relied on for a live engagement:

1. Does `localStorage` work on `file://` in Safari? If not, the storage warning banner and the unload guard are the whole safety net, and "send before you close" becomes a hard instruction rather than a nicety.
2. Chrome shares one `localStorage` origin across all `file://` pages, which is why `docId` namespaces the key. Firefox and Safari differ; the namespacing makes the difference irrelevant, but confirm no collision before relying on two deliverables coexisting.
3. `<a download>` is inert inside the claude.ai artifact viewer. The component is built for local files, where it works; if a hosted copy is ever the primary path, the download option needs the `downloads` capability and it is unknown whether read-only viewers are granted it.
