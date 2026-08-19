---
name: artifact-annotate
description: |
  Adds commenting to a deliverable that leaves the org — an in-page review layer with three return paths, plus the anchor rule that keeps comments matchable across revisions. `artifact-craft` decides that a deliverable needs this; this skill supplies it.
  TRIGGER when: `artifact-craft` determines a deliverable will be read by someone who cannot comment on it in Claude, or when the user asks directly for something reviewable, annotatable, or "something they can leave feedback on." Also when republishing a deliverable that has already been reviewed, so prior feedback gets answered on the page.
---

# Artifact Annotate

Reviewability for a deliverable that leaves the organization. Three skills cooperate on one file:

| Skill | Owns |
|---|---|
| `ideate:ontology`, `ideate:make-prd`, `ideate:make-summary`, … | What the document says |
| `artifact-craft` | Treatment, palette, type, layout, voice, theme control, view routing — **and the decision that a deliverable needs commenting at all** |
| **`artifact-annotate`** | The `data-cid` rule, the feedback component, config and transports, round-two responses |
| `/triage` | Ingesting feedback once it comes back |

## Goal

A stakeholder outside the org opens an HTML file, comments on specific blocks, and gets that feedback back to us in one action — without an account, an install, or an explanation.

## Invocation

| Input | Behavior |
|---|---|
| `artifact-craft` step 2 determined the deliverable leaves our control | Run it. That determination is the normal entry point. |
| "Make this reviewable" / "annotatable" / "something they can leave feedback on" | Run it, and load `artifact-craft` if it is not already loaded. |
| Republishing something already reviewed | Skip to **Round two**. |
| Feedback has come back and needs acting on | Hand to `/triage`. This skill's job is done. |

## Gate 0 — arrive before the build, not after

**This skill contributes to `artifact-craft`'s build. It does not run a second pass over a finished page.**

Retrofitting is where this goes wrong. If the page is built first and anchors are added afterward, they get assigned by an agent that did not decide the structure, and it does it badly. `artifact-craft` decides in step 2 that the deliverable needs commenting, loads this skill before step 3, builds with that known, and pastes the component in at the end.

Arriving after a finished page means going back to step 3 rather than patching what is there.

**The determination itself belongs to `artifact-craft`,** including the question it asks when the audience is unclear. That skill runs on every artifact; this one does not. A test that lived only here would never be applied to the artifacts that most need it.

## The build

### 1. Anchors

Every commentable block carries `data-cid`. The rule, the format, and the coupling to content-skill headings are in `components/README.md`. `artifact-craft` applies it on every artifact regardless of this skill, so on a reviewable deliverable it should already be done — verify rather than add.

### 2. Multi-view deliverables

A deliverable spanning several pages is one file with hash-routed views, via `artifact-craft`'s `view-router.html`. Relative links between separate local HTML files are never used; the reasons are in that skill's component README.

One file means one `docId`, one storage bucket, and one submission covering every view. A reviewer who comments across three views presses Send once.

### 3. Paste the component

`components/feedback-layer.html`, verbatim, last — after the theme control and the router. Fill in `#feedback-config` and change nothing else.

The address in `to` is the engagement address, never a personal one. It ships inside a file handed to a client.

### 4. Commit the source

**The scratchpad is not enough for a reviewable deliverable.** The source belongs in the engagement repo at `ideate/artifacts/<docId>.html`, committed, with each published revision commitable or taggable.

Ingested feedback resolves its anchors against the exact revision the reviewer read. A client who sits on a file for two weeks and sends comments against revision 2 while we are on revision 4 needs revision 2 to still exist. A file that only ever lived in a session directory leaves round two guessing.

### 5. Say what the reviewer should do

When handing over the file, one line in the message — not on the page:

> Click Review, comment on anything, then hit Send feedback. Email is one click and needs no editing.

A reviewer who does not know the review mode exists will read the whole document and reply with a paragraph in Slack.

## Round two

Republishing after feedback embeds `#feedback-responses` so the reviewer sees what happened to each item where they raised it. Format and dispositions are in `components/README.md`.

The four dispositions — `fixed`, `intentional`, `deferred`, `declined` — are equal, and any of them closes an item. A declined comment is answered, not pending. This is the same rule that governs code review findings in `user/CLAUDE.md`, and it is what keeps a review loop finite.

Preserve cids for surviving blocks, or the responses lose their anchors along with any feedback still in flight.

## Handing off

Feedback comes back as a Markdown paste, a JSON file, or an email body. `/triage` owns everything from there — validation, anchor resolution, and what happens to a payload that does not parse.

This skill's obligation to that handoff is the format and the source. `gnar.artifact-feedback/1` and the Markdown grammar in `components/README.md` are what the ingest side parses against, and the committed revision in `ideate/artifacts/` is what it resolves anchors against. Changing either is a coordinated change, not a local one.

## Closure Criteria

- [ ] Loaded before `artifact-craft` step 3, not retrofitted onto a finished page
- [ ] Every commentable block carries `data-cid`; ids preserved from the prior revision
- [ ] Multi-view deliverables use hash routing in one file; no relative links between local files
- [ ] `feedback-layer.html` pasted verbatim, last, unrestyled
- [ ] `#feedback-config` fully filled in — no `REPLACE-` strings survive
- [ ] `to` is the engagement address, not a personal one
- [ ] Source committed to `ideate/artifacts/<docId>.html` with the revision recoverable
- [ ] Review mode exercised once end to end: comment, Send, all three export paths reachable
- [ ] Handover message tells the reviewer the review mode exists
- [ ] Round two only: `#feedback-responses` present, every prior item carries a disposition

## Notes

**Why the component is fixed rather than authored per page.** Every deliverable carrying a slightly different feedback format means the ingest side has to guess at parse time. The schema is the seam: `gnar.artifact-feedback/1` lets one triage path handle a Slack paste, an email body, a downloaded file, and eventually an API result without caring which it got. A component regenerated per artifact breaks that seam quietly, and the breakage surfaces weeks later when a client's feedback will not parse.

**The transport is pluggable on purpose.** `endpoint: null` today means export only. Setting it turns the primary action into a direct submit and demotes export to a fallback, with no other change to the component or the ingest path. That is what keeps a hosted review platform — Spacebase or otherwise, with real identity, live threads, and an MCP surface agents can watch — an addition rather than a migration.

**Why this is a separate skill from `artifact-craft`.** They change for different reasons. `artifact-craft` changes when house style changes. This changes when delivery mechanics change — a new transport, a hosted platform, a different anchor scheme. Keeping the feedback layer inside the style skill would couple two things that have never moved together.

**Identity is self-declared until a platform vouches for it.** `reviewer.verified` is `false` on every export transport and the field exists from v1 so the hosted path needs no schema bump. The trust model in the meantime is that we know who we sent the file to.
