---
name: artifact-annotate
description: |
  Makes a page markable-up by whoever reads it, and delivers it as a standalone HTML file. Supplies the document wrapper, the in-page review layer that exports to the clipboard or a file, and the anchor rule that keeps comments matchable across revisions. `artifact-build` writes the page; this skill turns it into a file someone can open and annotate.
  TRIGGER when: anyone needs to mark up the page — an outside stakeholder who cannot comment in Claude, or the user reading their own copy and wanting to record their thinking on it. Also on any handover of the page as a file, on "send this out for review," "make this commentable," "share a draft with the client," "something I can mark up," and when republishing after a round of comments so prior feedback gets answered on the page. NOT when the user asks to draft, write, or produce a document — that is the content skill's job, and this one runs after it.
---

# Artifact Annotate

A page is **annotatable** when its reader can mark it up, and **final** when they cannot. That is the only difference this skill makes, and it is the whole reason it exists.

The reader is often a stakeholder outside the org, and just as often the user. Someone asking for a concept explained on a page wants to record what they thought about it while reading — where they disagreed, what they want followed up. The mechanism is identical either way, so the audience never decides whether this skill runs; whether anyone marks the page up does.

The workflow it replaces is posting a Markdown file to a shared drive and asking for comments in a thread. Same document, comments anchored to the block they are about, and a return path that lands in a form `/triage` can act on.

**This skill is also the file publisher.** `artifact-build` writes page content and stops there, exactly as it does for a page the Artifact tool publishes. Two things turn that content into something openable: the Artifact tool's publish step, and this skill. Both supply the document wrapper — see **The wrapper** below.

**Final is the same page without this skill.** Same content skill, same `artifact-build` pass, stop before this one. Same `docId`, next `revision` — the final is the revision after the last round of responses, not a new document. Keeping one lineage is what lets `/triage` resolve a late comment against the version the reviewer actually read.

Three skills cooperate on one file:

| Skill | Owns |
|---|---|
| `ideate:ontology`, `ideate:make-prd`, `ideate:make-summary`, … | What the document says |
| `artifact-build` | Treatment, palette, type, layout, voice, theme control, view routing — **and the decision that a deliverable needs commenting at all** |
| **`artifact-annotate`** | The document wrapper, the `data-cid` rule, the feedback component, config and transports, round-two responses, delivery |
| `/triage` | Ingesting feedback once it comes back |

## Goal

Someone opens an HTML file, comments on specific blocks, and gets that feedback back in one action — without an account, an install, or an explanation. It renders correctly on the first open, in any browser, whether it came off a shared drive or a mail attachment.

## Invocation

| Input | Behavior |
|---|---|
| `artifact-build` step 2 determined the page is annotatable | Run it. That determination is the normal entry point. |
| "Send this out for review" / "make this commentable" / "something I can mark up" / "share a draft with the client" | Run it, and load `artifact-build` if it is not already loaded. |
| The page is going to the user as a file, annotation aside | Run it. Delivering a file is this skill's job, and the wrapper it supplies is what makes the file open correctly. |
| "Draft me a PRD" / "draft up the ontology" | **Not this skill.** That is the content skill being asked for a first version. This one runs after there is something to circulate. |
| The deliverable is final — signed off, or never going out for comment | Do not run it. `artifact-build` alone produces the final version. |
| The same asked of a deliverable **already published as an artifact** | The ask is for the **file**, not the URL. Someone who could review it in Claude would use the artifact. Go to **Delivery** and hand over the HTML. |
| Republishing something already reviewed | Skip to **Round two**. |
| Feedback has come back and needs acting on | Hand to `/triage`. This skill's job is done. |

## Gate 0 — arrive before the build, not after

**This skill contributes to `artifact-build`'s build. It does not run a second pass over a finished page.**

Retrofitting is where this goes wrong. If the page is built first and anchors are added afterward, they get assigned by an agent that did not decide the structure, and it does it badly. `artifact-build` decides in step 2 that the deliverable needs commenting, loads this skill before step 3, builds with that known, and pastes the component in at the end.

Arriving after a finished page means going back to step 3 rather than patching what is there.

**The determination itself belongs to `artifact-build`,** including the question it asks when the audience is unclear. That skill runs on every artifact; this one does not. A test that lived only here would never be applied to the artifacts that most need it.

## The build

### 1. Anchors

Every commentable block carries `data-cid`. The rule, the format, and the coupling to content-skill headings are in `components/README.md`. `artifact-build` applies it on every artifact regardless of this skill, so on a reviewable deliverable it should already be done — verify rather than add.

**Verify by hovering.** Turn review mode on and run the cursor down the page. Every paragraph, card, and list item outlines on its own, and each outline hugs that one thing. An outline wrapping several items means a container took the anchor its children should have; prose that never outlines means paragraphs with no cids. Reading the markup does not catch either one, which is how both ship.

### 2. Multi-view deliverables

A deliverable spanning several pages is one file with hash-routed views, via `artifact-build`'s `view-router.html`. Relative links between separate local HTML files are never used; the reasons are in that skill's component README.

One file means one `docId`, one storage bucket, and one submission covering every view. A reviewer who comments across three views presses Send once.

### 3. The wrapper

`artifact-build` hands over page content with no document around it — the same contract it follows for a page the Artifact tool publishes, where the publish step supplies the wrapper. Nothing supplies it here except this skill. Three lines, first in the file, verbatim:

```html
<!doctype html>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
```

The implied `<html>`, `<head>`, and `<body>` make the explicit tags unnecessary; the page's own `<title>` and `<link rel="icon">` follow these three.

**`<meta charset="utf-8">` is the one that bites.** A `file://` page has no HTTP `Content-Type` header, so a document that never declares its encoding falls back to the browser's locale default and every non-ASCII byte renders as mojibake — an em dash arrives as `â€"`, and curly quotes, arrows, and the `○ ◐ ●` theme glyphs break the same way. The bytes on disk are correct UTF-8 and the file passes every check that reads it as text; the missing piece is the line that tells the browser.

This failure is invisible from the authoring side, which is why it is a step rather than a note. A page that was also published looks perfect at its URL, because the Artifact wrapper declares the charset there. Only the file the reader opens is broken, and the reader is the one person who never sees the other copy.

Omitting the doctype costs quirks mode. Omitting the viewport meta renders the page at desktop width on a phone, which for a reviewer reading a deliverable on their phone is most of the reason they give up on it.

### 4. Paste the component

`components/feedback-layer.html`, verbatim, last — after the theme control and the router. Fill in `#feedback-config` and change nothing else.

`#feedback-config` holds four fields — `docId`, `title`, `revision`, `endpoint` — and no address. That is deliberate: a component that knew where feedback should go would ship that address inside a file handed to a client, and would need a per-installation default that anyone installing the skill would inherit.

### 5. Commit the source

**The scratchpad is not enough for a reviewable deliverable.** The source belongs in the engagement repo at `ideate/artifacts/<docId>.html`, committed, with each published revision commitable or taggable.

Ingested feedback resolves its anchors against the exact revision the reviewer read. A client who sits on a file for two weeks and sends comments against revision 2 while we are on revision 4 needs revision 2 to still exist. A file that only ever lived in a session directory leaves round two guessing.

### 6. Delivery — put the file in the user's hands

**The deliverable is the `.html` file on disk. Publishing it as an artifact does not deliver it.**

An artifact URL is an in-org surface: opening it needs a Claude account and a share, and the built-in comments already work there. A reviewer who has that access does not need this skill. The component exists for the reviewer who has none of it — a client VP, an outside contractor, someone who gets a file over mail and opens it in Safari. **That person cannot be handed a link.** Publishing alongside is fine, for the team's own copy. It is never the handover.

**Write it to a real path first**, never the session scratchpad — the engagement repo at `ideate/artifacts/<docId>.html`, and a working copy where the user is if that is elsewhere. Step 5 already requires the committed copy; this is the same file, not a second one.

Then hand it over by the route the surface supports. **Read the surface, do not assume it:**

```
printenv CLAUDE_CODE_ENTRYPOINT
```

| Value | Surface | Handover |
|---|---|---|
| `cli` | A real terminal | `open <abs-path>` to view it, `open -R <abs-path>` to reveal it, print the absolute path on its own line, **and** `SendUserFile` |
| anything else, or unset | Desktop app, web, or an unknown GUI | `SendUserFile` alone — it renders the file inline where the user already is |

Key on `cli` and treat every other value as a GUI surface. The terminal value is known; the others are not worth guessing at, and this rule stays correct whatever they turn out to be.

**Why the split.** `SendUserFile` renders a card the user can open and drag; in the terminal it produces nothing visible, and the statusline shows published artifacts only, so a file delivered that way silently does not arrive. `open` and `open -R` are the reverse — they act on the machine the shell is on, which is the user's machine in a terminal session and nobody's business in a hosted one.

**On the terminal path, do all four without being asked.** The browser is the only place the review mode actually runs, so the user needs to see it before it goes to a client. The handover to that client is an attachment, and attaching means dragging the file out of a window — selecting it in Finder is the difference between "here is where it lives" and "here it is."

Two guards on the terminal path:

- **`SSH_CONNECTION` or `SSH_TTY` set** — skip `open` and `open -R` entirely. They would act on the remote host, opening a browser nobody is looking at. Print the path and say which machine the file is on.
- **Linux** — `xdg-open <abs-path>` to view, `xdg-open "$(dirname <abs-path>)"` to reveal. Where neither exists, print the path and stop.

Then two lines in the message, not on the page:

> Click Review, comment on anything, then hit Send feedback and copy it. Paste it back to me here.

**Name the destination in that message.** The component holds no address — nothing about where feedback should go ships inside a file handed to a client — so the covering note is the only place a reviewer learns where to send it.

A reviewer who does not know the review mode exists will read the whole document and reply with a paragraph in Slack.

Say which return paths work where the file is going. `<a download>` is inert inside the claude.ai artifact viewer and works on a local file, so the same page has different capabilities depending on how it was opened — nobody should have to discover that by trying it.

## Round two

Republishing after feedback embeds `#feedback-responses` so the reviewer sees what happened to each item where they raised it. Format and dispositions are in `components/README.md`.

The four dispositions — `fixed`, `intentional`, `deferred`, `declined` — are equal, and any of them closes an item. A declined comment is answered, not pending. This is the same rule that governs code review findings in `user/CLAUDE.md`, and it is what keeps a review loop finite.

Preserve cids for surviving blocks, or the responses lose their anchors along with any feedback still in flight.

## Handing off

Feedback comes back as a Markdown paste, a JSON file, or an email body. `/triage` owns everything from there — validation, anchor resolution, and what happens to a payload that does not parse.

This skill's obligation to that handoff is the format and the source. `gnar.artifact-feedback/1` and the Markdown grammar in `components/README.md` are what the ingest side parses against, and the committed revision in `ideate/artifacts/` is what it resolves anchors against. Changing either is a coordinated change, not a local one.

## Closure Criteria

- [ ] Loaded before `artifact-build` step 3, not retrofitted onto a finished page
- [ ] Every visually distinct block carries `data-cid` — paragraphs, cards, and list items each on their own, rows anchored as well as their cards — confirmed by hovering the page rather than reading it; ids preserved from the prior revision
- [ ] Multi-view deliverables use hash routing in one file; no relative links between local files
- [ ] `feedback-layer.html` pasted verbatim, last, unrestyled
- [ ] `#feedback-config` fully filled in — no `REPLACE-` strings survive
- [ ] `to` is the engagement address, not a personal one
- [ ] Source committed to `ideate/artifacts/<docId>.html` with the revision recoverable
- [ ] Review mode exercised once end to end: comment, Send, all three export paths reachable
- [ ] **Wrapper present and verified in a browser** — doctype, `charset`, viewport, first in the file; confirmed by opening it and reading a line with an em dash, never by reading the source, which is correct in the failing case
- [ ] **The surface was read** (`printenv CLAUDE_CODE_ENTRYPOINT`), not assumed
- [ ] **Handed over by the matching route** — terminal: opened, revealed, path printed, `SendUserFile`; GUI: `SendUserFile` alone. An artifact URL is not a handover on either.
- [ ] Handover message tells the reviewer the review mode exists, and which return paths work where the file is going
- [ ] Round two only: `#feedback-responses` present, every prior item carries a disposition

## Notes

**Why the component is fixed rather than authored per page.** Every deliverable carrying a slightly different feedback format means the ingest side has to guess at parse time. The schema is the seam: `gnar.artifact-feedback/1` lets one triage path handle a Slack paste, an email body, a downloaded file, and eventually an API result without caring which it got. A component regenerated per artifact breaks that seam quietly, and the breakage surfaces weeks later when a client's feedback will not parse.

**The transport is pluggable on purpose.** `endpoint: null` today means export only. Setting it turns the primary action into a direct submit and demotes export to a fallback, with no other change to the component or the ingest path. That is what keeps a hosted review platform — Spacebase or otherwise, with real identity, live threads, and an MCP surface agents can watch — an addition rather than a migration.

**Why this is a separate skill from `artifact-build`.** They change for different reasons. `artifact-build` changes when house style changes. This changes when delivery mechanics change — a new transport, a hosted platform, a different anchor scheme. Keeping the feedback layer inside the style skill would couple two things that have never moved together.

**Identity is self-declared until a platform vouches for it.** `reviewer.verified` is `false` on every export transport and the field exists from v1 so the hosted path needs no schema bump. The trust model in the meantime is that we know who we sent the file to.
