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

Format is nearest-heading slug plus an ordinal within that heading: `milestones-3`, `risks-1`. In a multi-view file the heading slug picks up the view name on its own — `typography-scale-2` — so ids stay unique file-wide with no extra rule.

It is deterministic, so a regenerated revision produces matching ids for unchanged structure with nobody tracking anything. Ids shift when a block is inserted mid-section; the quote fallback exists for that, so do not build machinery to prevent it.

Emitting cids always costs a few tokens per block and no discipline, and it is the one property that is expensive to retrofit. A plain artifact carrying cids can accept feedback later by any route and still resolve anchors.

`data-fbk-heading="…"` overrides the auto-detected heading on a block whose nearest heading reads wrong.

**Stability is shared with the content skill.** Cids derive from headings, and headings come from the ontology, PRD, or exec-summary skill that authored the content. Renaming a section moves every cid under it. Once a deliverable has been reviewed, section names are an interface.

---

## The pin colour

Markers, the review-mode cursor, and the glow under both come from one token, `--fbk-pin` — `#0F7C77` light, `#5CCFC6` dark. It is the component's own colour, not the page's, and that is deliberate: token names differ on every deliverable, so a component that read the page's accent would have to know a naming convention no artifact is required to follow.

A deliverable that wants its markers to match its own palette overrides the token from its own stylesheet, after the component:

```css
:root { --fbk-pin: var(--accent); }
```

Nothing else needs changing — the cursor and the glow both derive from it. Overriding it with a colour that has poor contrast against the page ground is the one thing to check, since the marker is the only way a reviewer finds their own comments again.

## Configuration

Fill in `#feedback-config` and nothing else:

```json
{
  "docId": "halo-oms-tech-approach",
  "title": "Halo OMS Technical Approach",
  "revision": "2026-08-19T14:02:00Z",
  "to": "will@gnar.dog",
  "cc": [],
  "endpoint": null
}
```

- `docId` — matches the source filename in `ideate/artifacts/`. Also namespaces localStorage, which matters because Chrome puts every `file://` page on one shared origin and two deliverables on the same laptop would otherwise collide.
- `revision` — the publish timestamp. Ingestion resolves anchors against *this* revision's HTML, not current HEAD. A client who sits on a file for two weeks still gets exact anchors.
- `to` / `cc` — **engagement address, never a personal one.** This ships inside a file handed to a client.
- `endpoint` — `null` today. When set, the sheet gains a Submit button that POSTs the record directly and export becomes the fallback. The transport is pluggable so a hosted platform adds a route rather than changing the component.

A multi-view deliverable is one file and therefore one `docId`, one storage bucket, and one submission covering every view.

---

## The three return paths

| Path | Reviewer effort | Ceiling | Ingest |
|---|---|---|---|
| Email | One click | ~1,900 chars of URL | Deterministic subject, Gmail connector |
| Copy → paste | Two steps, any channel | None | Wherever they pasted |
| Download → send | Highest | None | Whatever channel they chose |

**Email is length-guarded.** `mailto:` carries no attachments — RFC 6068 supports subject and body only, and the non-standard `attachment=` that old Windows clients honoured is closed off everywhere. The OS handoff truncates past roughly 2,048 characters, so the component builds the URL, measures it, and disables the email option with an explanation when it would not survive. Silent truncation is the failure mode worth spending code to prevent: the client hits send believing they submitted everything.

The subject line is the automation hook:

```
Feedback: halo-oms-tech-approach 2026-08-19T14:02:00Z — Dana Ruiz
```

Nothing in this skill watches for those emails. The format exists so that something else can — a scheduled agent searching Gmail on `subject:"Feedback: halo-oms-tech-approach"` finds every submission with no ambiguity. Where that watcher lives is a separate decision.

**Copy emits Markdown, not JSON.** It reads in a Slack message unaided and parses just as reliably from a fixed grammar. Download emits JSON.

### Markdown grammar

Stable. The ingest side parses it; changing it is a schema bump.

```
Feedback — Halo OMS Technical Approach
doc: halo-oms-tech-approach · rev: 2026-08-19T14:02:00Z
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
