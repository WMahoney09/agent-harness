---
name: artifact-build
description: |
  The build sequence for a page deliverable — treatment read, written design plan, then code, then a pre-delivery check. Produces page content; the document wrapper around it comes from whatever delivers the page, so this skill runs the same whether the page is published, handed over as a file, or both. Wraps the built-in `artifact-design` skill with the gates and house rules that keep output from drifting toward generic.
  TRIGGER when: building any page with an audience — a report, map, dashboard, plan, memo, reference, or deliverable — however it ships. Also when revising an existing one, and when the user asks why an artifact "looks generated" or wants a previous artifact's quality repeated.
---

# Artifact Build

The discipline around building a page deliverable. The output is page content — no `<!doctype>`, `<html>`, `<head>`, or `<body>` of its own. Whatever delivers the page supplies those: the Artifact tool's publish step for a published page, `artifact-annotate` for a file. This skill runs identically either way, and never needs to know which. `artifact-design` (built-in, ships with the Artifact tool) supplies the fundamentals — theme tokens, CSP constraints, layout mechanics, the list of AI-default looks to avoid. This skill supplies the **sequence**, the **gates**, and the **house rules**, and it does not repeat what the built-in already covers.

One rule sits above all others: **derive the design from the subject.** Everything that makes a page feel considered comes from choices traceable to what the page is about. Everything that makes a page feel generated comes from choices inherited by default.

## Goal

A page that answers its question at a glance, holds up in both themes, opens correctly wherever the reader opens it, and could not be mistaken for a page about a different subject.

## Invocation

| Input | Behavior |
|---|---|
| A new artifact to build | Run the full sequence below, in order. Do not skip to code. |
| A revision to an existing artifact | Skip steps 1–2 if the plan still holds. Re-run step 5 before every handover or redeploy. |
| "Make this look better" / "this looks generated" | Diagnose against step 2's avoid-list and step 3's derivation test first. The problem is almost always an inherited default, not a missing flourish. |

## The Sequence

Each step is a gate. Do not start the next one until the current one is done.

### 1. Load the built-in

Call `artifact-design` **before writing any file** — HTML and Markdown alike, published or not. The Artifact tool's own description mandates it when publishing, and the fundamentals it carries — CSP rules, theme-state mechanics, the avoid-list — apply just as much to a file that never gets published. Those change independently of this skill.

If the page needs live data, shared state, file downloads, or self-updating, also load `artifact-capabilities` before writing. If it needs diagrams, load `artifact-diagramming`.

Two fixed components live in `components/` next to this file — a theme control and a view router. They are pasted verbatim, never regenerated. Read `components/README.md` before using either.

**Whether the page is annotatable is decided here, in step 2.** `artifact-annotate` supplies the commenting and the document wrapper; this skill decides the page needs them and loads it. That split matters because this skill runs on every artifact and that one does not — a determination that lived only in `artifact-annotate` would never get made on the artifacts that most need it.

### 2. Read the request and calibrate the treatment

Decide, explicitly, which register the work calls for:

- **Utilitarian** — a plan, memo, report, reference, internal doc. Polished, real hierarchy, considered spacing and palette. **No oversized hero.** Most requests land here.
- **Editorial** — a landing page, a pitch, something kept or shared outward. Opinionated, one real aesthetic risk, motion where it serves the subject.
- **UI** — a dashboard or tool. Scanned and operated, not read. Information design over typography: summary before detail, state encoded in form as well as number.

Format is part of this decision, not a shortcut. Choose Markdown only when the user asked for it or the destination is Markdown-native — never to save time.

Getting this wrong is the most expensive error available. An editorial treatment on an internal reference reads as unserious; a utilitarian treatment on a pitch reads as unfinished.

**Two structural questions belong in the same breath.**

*Does this deliverable span several pages?* If so it is one file with hash-routed views — see step 3. Never a set of local HTML files linking to each other.

*Does anyone need to mark this page up?* **Answer this on every artifact, and answer it here.**

If yes, load `artifact-annotate` now, before step 3, because its answer changes what gets built. If no, this skill alone produces the page.

**The reader who marks it up is often the user.** Someone who asks for a concept on a page usually wants to record what they thought while reading it. That counts, exactly as a client stakeholder counts. The question is whether anyone wants to write on the page, never whose org they are in.

Two cases where the answer is yes without anyone saying so: the page goes over as a file, since `artifact-annotate` is what supplies the document wrapper that makes a file open correctly; and the reader cannot comment inside Claude but their comments are still wanted. The answer is no for an internal reference nobody will annotate, and for a deliverable already signed off and going out for the record.

**When it is genuinely unclear, ask.** One question, before any file is written:

> Do you want to be able to mark this up, or is it the final version?

Do not guess, and do not build both ways. Asking costs one turn. Guessing wrong costs either a stripped-down rebuild or a reader with no way to respond. Overridable both directions on request: "make it markable," "this one is final."

### 3. Write the design plan before any code

Write it out. Not in your head — in the response, so the choices are inspectable and you can be held to them.

**Color** — 4–6 named hex values. Then apply the derivation test:

> Name the subject's world. Does this palette come from it, or would it work equally well on any other page?

Bias neutrals slightly toward the accent hue rather than using a pure grey. A pure mid-grey reads as unconsidered; a grey with a hue bias reads as chosen. Where color carries meaning (ownership, severity, state), assign it semantically and keep semantic color separate from the accent.

**Type** — faces for two or more roles.

The CSP blocks font CDNs, so a linked webfont fails silently to an arbitrary fallback. Either inline a face as a data URI or use system stacks deliberately. **A well-used system stack beats a broken webfont every time**, and the personality can live in the pairing rather than in the faces themselves.

Give every role a job. A useful default for technical subjects: monospace carries all identifiers — repo names, env vars, ticket prefixes, IDs, file paths — while the sans carries prose. That split is itself a design idea and it costs nothing.

**Layout** — one or two sentences naming the organizing concept.

The strongest layouts make position mean something. If the page answers "which of these is which," let an axis encode the answer. If it answers "what happens in what order," let the sequence be the structure.

**A deliverable spanning several pages is one file with hash-routed views.** This is a rule, not an option. Paste `view-router.html`, mark each view with `data-view` and an id, and link between them with ordinary anchors. Deep links into a view work, so the overview can cross-reference a heading three views away.

Relative links between separate local HTML files are never used. They need the whole set to land in one folder with filenames matching the hrefs, and delivery breaks that routinely — Slack downloads attachments one at a time and suffixes on collision, mail clients open them from per-file temp directories, and Windows Explorer will open a page from inside a zip, which copies that one file to a temp directory and kills every link with nothing visible to the reader.

The nav is design surface and gets styled with the page; style `aria-current="page"` rather than adding a class. The router itself, and the size arithmetic for a mockup-heavy deliverable, are in `components/README.md`.

**The components claim fixed screen corners** — theme control top-right, and, when `artifact-annotate` is in play, a feedback bar bottom-right with a drawer along the right edge. Leave those corners free of anything the reader needs. Do not restyle the components to match the palette: they are tooling, and staying visually neutral is what lets a reader tell the deliverable from the controls.

### 4. Build from the plan

Follow the plan you wrote. If you find yourself deviating, revise the plan first and say why.

**Write page content only** — no `<!doctype>`, `<html>`, `<head>`, or `<body>`. The Artifact tool's contract requires this on a published page, and `artifact-annotate` supplies the same wrapper on a file, so the rule holds either way. Start at `<title>`.

**The one case you own it.** If you write the page to a file on disk and `artifact-annotate` is not in play, nothing supplies the wrapper and you write it yourself — doctype, `<meta charset="utf-8">`, viewport, first in the file. A file without the charset line renders every em dash as `â€"` on first open. The reasoning is in `artifact-annotate` step 3; this is the fallback for a final deliverable going out as a file with no annotation layer.

**Structure must encode something true.** This is the check most often skipped. Numbered markers (01 / 02 / 03), eyebrows, dividers, and tiers are information, not decoration:

- Number a list only when order carries meaning the reader needs — a real sequence, a ranked tier, a timeline.
- Do **not** number a set of peers. A people table, a set of open questions, and a feature list are unordered; numbering them asserts a rank that doesn't exist.

**Give every commentable block a `data-cid`. Every artifact, always.**

**Anchor what the reader can point at.** If someone can put a finger on it and call it one thing, it carries a cid — every paragraph, every card in a row, every list item carrying a claim, every table wrapper, diagram, callout, and heading group. The ceiling is visual identity: a `<span>` mid-sentence, a layout wrapper with no appearance of its own, and anything hidden all get nothing. Density is fine. Forty paragraphs take forty anchors, and a reviewer who cannot reach the paragraph they disagree with usually says nothing instead. The format is nearest-heading slug plus an ordinal within that heading: `milestones-3`, `risks-1`.

**A container of peers is never the anchor — each peer is.** A row of cards, a list of items, a set of numbered principles: the cid goes on every card, never only on the grid that holds them. Anchor the container alone and a reviewer commenting on the third card selects all three and gets it labelled with the first one's heading. This is the granularity mistake that actually happens, and numbered peers make it plain in the export — a comment on `02` recorded against `01`.

Give the container one **as well**, which is how a reviewer comments on the set as a whole: the layer anchors to the innermost cid under the click, so a card catches a click on the card and the row catches a click in the gap between them.

`artifact-annotate` owns the rule and the stability discipline; this skill applies it unconditionally. It costs a few tokens per block and no thought, and it is the one property that is expensive to retrofit — an artifact carrying cids can accept feedback later by any route and still resolve anchors.

**Paste the components in, last, verbatim.** Theme control, then the view router if the deliverable spans views, then `artifact-annotate`'s feedback layer if step 2 called for it.

**Write the copy as content, not filler.** Verdict first — the opening sentence carries the answer, support follows. Real content throughout, never lorem. Name things the way a reader recognizes them, not the way the system is built.

**State uncertainty once, plainly, and in the artifact.** If a claim is inference rather than fact, say so on the page — a short note near the end naming what wasn't verified. A deliverable that distinguishes what it knows from what it inferred is more useful than one that flattens both into confident prose, and it protects whoever reads it next.

### 5. Self-check before delivery

Walk it. Every item, every time — before a handover and before a redeploy alike.

**Theme.** Scan the stylesheet for any color whose only definition sits inside a media query or a `[data-theme]` block. That is the classic unreadable-artifact bug: it renders one theme's text on the other theme's ground for every viewer on the default "system" setting. `body` must set an explicit background from a token.

**Theme control.** Present and working in all three states — `○` light, `◐` auto, `●` dark. Toggling to each one and back must change the page, which is the fastest way to catch a token defined in only one block.

**Anchors.** Turn review mode on and run the cursor down the page rather than reading the markup. Every paragraph, card, and list item outlines on its own, and each outline hugs that one thing. An outline wrapping several items is a container anchored where its children should be; a stretch of prose that never outlines is a run of paragraphs with no cids. On a redeploy, spot-check that surviving blocks kept the ids they had, or any feedback already in hand is orphaned.

**Views.** On a multi-view file: every nav link resolves, deep links open the right view and scroll, the back button works, and printing shows all views rather than one.

**Overflow.** Tables, code blocks, and diagrams each scroll inside their own `overflow-x: auto` container. The page body never scrolls sideways.

**Cascade.** Check for selectors that cancel each other out — a type-based class fighting an element-based one over the same spacing.

**Wrapper.** Page content carries no document tags of its own. `artifact-annotate` adds them on a file and the publish step adds them on a URL, so the only case to check here is a file written without `artifact-annotate` — then the doctype, `charset`, and viewport are yours, and you confirm them by opening the file rather than by reading the source.

**Title.** A short noun phrase, two to four words, specific enough to pick out of a gallery of many. Not a category label. Not a name with an explainer bolted on after a dash or colon. The explanation goes in the `description` parameter, which becomes the gallery subtitle.

**Favicon.** Required. One or two emoji, and **stable across redeploys** — users find the tab by its icon. Change it only on a hard pivot in subject.

**Derivation.** Re-run the test from step 3. Could this palette, this type pairing, and this layout sit unchanged on a page about something else? If yes, one of them is inherited and should be replaced.

**Prose.** Run the house rules below over every line.

## House Prose Rules

Repeated here deliberately. `user/CLAUDE.md` does not load on claude.ai or Cowork, and artifact copy is exactly where these rules get forgotten — headings and card text feel like design surface rather than writing, and drift first.

**The one that matters most: no antithesis.** Never set up a wrong answer to knock down. State what is true and stop.

> "This isn't a refactor, it's a rewrite." → "This is a rewrite."
> "Not a config problem — a timing problem." → "The cause is timing."

The pattern also hides in softer forms: "less about X, more about Y," "what this really is," "rather than X, this Y." Same rule.

Also banned:

1. **Rhetorical question then answer.** "The problem? Two callers share the mutex."
2. **Participial tails.** "…ensuring maintainability," "…allowing for cleaner separation."
3. **Punchline endings.** No closing aphorism, no one-line zinger paragraph.
4. **Aphoristic pairs.** A second sentence that rewords the first. Keep the first, cut the second.
5. **Self-explanation tails.** "That's why X," "That's how Y" bolted onto an observation.
6. **Framing prefixes.** "The rhythm:", "The bill:", "The result:", "The bridge:". Delete the prefix, keep the sentence.
7. **Parallel triplets.** Three items in the same shape read as rhythm, not content. Use however many are true.
8. **Pace, scale, and altitude metaphors.** "30,000 feet," "same territory different altitude."
9. **Emoji in prose.** Section-marker emoji are a generated-design tell. The favicon is the exception.

**Word level.** Cut inflation: robust, comprehensive, seamless, powerful, crucial, leverage, streamline, elevate, unlock, "deep dive," "under the hood." Cut empty intensifiers: actually, precisely, genuinely, truly, real. Prefer `is` over "serves as." Bold is for labels in lists and tables, not emphasis mid-sentence.

**Em dashes are house style.** Do not ration them and do not rewrite them out. The `deck-voice` ban is scoped to presentation content only and does not apply to artifacts.

## Artifact

Page content as `.html` (or `.md` when the treatment read calls for it), with no document wrapper of its own. What happens to it next belongs to the delivery route: the Artifact tool publishes it, or `artifact-annotate` wraps it and hands over the file.

**The session scratchpad holds it only until then.** Anything going over as a file lands at a real path the user can find again, and **when `artifact-annotate` is in play the source has to be committed** so feedback resolves against the exact revision the reviewer read. That skill owns where it goes.

No co-located `ARTIFACT.md` exists for this skill, deliberately. A fixed output template would produce exactly the templated sameness the skill is written to prevent — the structure must come from the subject each time.

## Closure Criteria

- [ ] `artifact-design` was loaded before any file was written
- [ ] Treatment named explicitly — utilitarian, editorial, or UI
- [ ] Design plan written down before code, with color, type, and layout each stated
- [ ] Derivation test passed: palette, type, and layout are traceable to the subject
- [ ] Structural devices encode real information; nothing is numbered that isn't a sequence or a rank
- [ ] Both themes verified; no color defined only inside a media or `[data-theme]` block
- [ ] Theme control pasted in and cycles through `○ ◐ ●` correctly
- [ ] Every visually distinct block carries `data-cid` — paragraphs and list items included; peers anchored individually as well as their row; verified by hovering, not by reading the source; ids preserved on a redeploy
- [ ] Multi-view deliverables use hash routing in one file; nav, deep links, back button, and print all verified
- [ ] Whether anyone marks the page up was answered explicitly — asked when unclear, never guessed
- [ ] `artifact-annotate` loaded when the answer was yes, before step 3
- [ ] Page content carries no document tags of its own — unless it is a file written without `artifact-annotate`, in which case the wrapper is present and verified in a browser
- [ ] Wide content scrolls in its own container; page body does not scroll sideways
- [ ] Title is a specific two-to-four-word name; `description` and `favicon` set
- [ ] House prose rules run over every line, headings and card copy included
- [ ] Inferences and unverified claims are marked as such on the page
- [ ] Delivered — `artifact-annotate` handed over the file, or the URL went to the user with a note that artifacts are private until shared

## Notes

**Why this wraps the built-in instead of replacing it.** `artifact-design` ships with the Artifact tool and is maintained upstream; its CSP rules and theme mechanics change without notice. Duplicating it here would guarantee drift. This skill adds only what the built-in cannot know: the sequence discipline, the gates, and house voice.

**No house palette is defined, on purpose.** Locking one set of brand colors would make every artifact a sibling in the wrong way — visually consistent and subject-blind. The consistency worth having is consistency of *method*. If a fixed Gnar identity is ever wanted for client-facing work, it belongs in a separate skill that loads after this one and narrows step 3, rather than replacing it.

**The most common failure is skipping step 3.** Writing CSS directly, with the plan implicit, is how pages drift toward the defaults — warm cream and a serif, or near-black with one acid accent, or a purple gradient hero. The plan takes two minutes and is the difference.

**On updating an existing artifact.** A file is updated by overwriting the same path, which keeps one lineage and lets `artifact-annotate` resolve feedback anchors against the revision the reviewer read. For a published copy, republish the same file path from the same conversation to keep the URL. From a different conversation, pass the artifact's URL as `url` — publishing without it creates a separate artifact and strands the original link. Recover the URL with `action: "list"` or by asking, never by guessing.

**Why the components are fixed rather than authored per page.** A theme control that behaves differently on every deliverable is a bug surface, and a router regenerated each time will drop deep links about half the time. They are small enough to paste and stable enough to trust.

**Where the boundary with `artifact-annotate` sits.** This skill owns how the page looks, reads, and navigates, and it owns the decision that a deliverable needs commenting. That one owns the commenting itself — the component, the anchor rule, the transports, the round-two responses.

The decision lives here because this skill runs on every artifact and that one does not. A determination made only inside `artifact-annotate` would never be reached on an artifact where nobody thought to load it, which is exactly the artifact that ships to a client with no way to respond.

They meet at two points and no others: `data-cid` on commentable blocks, and the right-hand screen corners staying free. Keeping the component here would couple two things that have never changed for the same reason.
