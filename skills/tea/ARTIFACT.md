# Tea Artifact

## Meta

- **Storage:** A committed HTML file — `<repo>/ideate/artifacts/` for an engagement, `<workspace>/.tea/` otherwise. Never the session scratchpad. The file is the deliverable; a published copy is optional and never the handover.
- **Filename:** `tea--<slug>.html` — `<slug>` is the concept or project, hyphenated. It is also the `docId`. Stable across runs, so a refresh overwrites one path and keeps one lineage.
- **Favicon:** `☕` on every tea, no exceptions. The format is the identity here, not the subject.
- **Trigger:** Every `/tea` run, both modes. The page is the output; there is no inline version.

## Template

Design comes from `artifact-build` and derives from the subject each time. This template fixes **what the page carries**, not how it looks. Sections in the stated order.

### Both modes

- **Heading** — `☕` then two to four words, specific enough to pick out of a gallery. The concept or the project name. The `<title>` tag carries the same words without the cup, since the tab already shows the favicon beside it.
- **Subhead** — one line: what this page answers.
- **Window and date** — project mode states the period read. Concept mode states the date only.
- **Sources and confidence** — last section on the page. What was read, what could not be reached, and which claims are inference rather than observation.

### Concept tea

| Section | Content |
|---|---|
| **The answer** | The subject in everyday words, one short paragraph. The reader can stop here and be correct. |
| **The term** | The load-bearing jargon, named once and attached to its plain wording. Acronyms spelled out. |
| **How it works** | The mechanism, in plain vocabulary. A diagram when the mechanism is spatial or sequential. |
| **In our case** | The real values — the actual file, service, number, error, or decision from the thread that prompted this. |
| **What it costs you** | What changes for the reader: what breaks, what it constrains, what they now have to decide. |
| **Edges** | Where the plain version stops being complete, in one or two lines. |

Sections beyond these come from the subject. A page about a tradeoff wants the two positions; a page about a protocol wants the message sequence. Drop any section the subject doesn't fill rather than padding it.

### Project tea

| Section | Content |
|---|---|
| **Health** | One verdict — on track / at risk / off track — with the reason in the same sentence. Under it, the evidence, and the one thing that would change the grade. |
| **What needs you** | At most five items. Each: the decision, who is blocked, what waiting costs, and a recommendation. Empty is a valid and good answer, stated as such. |
| **Commercial** | Hours burned against planned, run rate, forecast to the next milestone, who is assigned and at what allocation. Current state, not a delta. |
| **Delivery** | Deliverables against the roadmap — landed, in flight, slipped. Milestone dates and what moved them. |
| **Since <date>** | The catch-up: decisions made, commitments given, escalations, client questions still unanswered. Terse, chronological. |
| **Open threads** | Action items with owner and age. Sort by age; a stale item is the finding. |
| **Conflicts** | Where sources disagree, both readings side by side with attribution. Omit the section when nothing conflicts. |

**Internal marking.** Project tea carries hours, dollars, margin, and allocation. A visible marker near the title says internal, and never goes to a client.

**Structure encodes truth.** Number the milestone sequence; do not number the open threads. Color carries state — health grade, milestone status, burn against plan — assigned semantically and kept separate from the accent.

## Side Effects

- **Source map** — project mode offers to write `<workspace>/.tea/<slug>.md` after handing the file over, and writes it only on approval. On a later run, its `Last tea` line supplies the window start and the path to overwrite.

## Notes

**Why the sources section sits last and always appears.** The page compresses meetings, channels, and a commercial system into a couple of minutes of reading, which is exactly the shape that invites over-trust. Naming what was read, what was missed, and what is inference lets the reader weight it. On project tea an unreachable source frequently matters more than anything that was reachable.

**Why concept tea's template is partial.** A fixed six-section shape applied to every idea produces the templated sameness `artifact-build` exists to prevent. These are the sections a concept page usually needs; the subject decides the rest.

**Why "what needs you" sits second.** The reader is accountable for several engagements at once and reads this to find their own exposure. Burying the asks under the commercial detail means they get read last, or not at all.
