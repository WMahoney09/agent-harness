---
name: tea
description: |
  Tea — Terse, ELIF, Artifact. Turn a topic or a project's real state into a plain-language page, delivered as a self-contained HTML file carrying its own review layer for comments. Two modes: concept tea makes an unfamiliar idea land; project tea researches an engagement across meetings, Slack, Runn, mail, Drive, and delivery artifacts, then reports where it stands.
  TRIGGER when: the user sends `/tea` after an agent response (turn that topic into a page), `/tea <concept>` (explain that concept as a page), or `/tea <project>` / "give me the tea on <project>" (research that engagement and report its state). Also natural language: "put that on a page", "I'm still not getting this", "what's the state of <project>", "where does <project> stand", "give me a pulse on <project>".
---

# Tea

`terse` decides what goes on the page. `elif` decides how it reads. `artifact-build` decides how it looks. `artifact-annotate` decides how it reaches the reader and how their comments get back. Tea composes the four in that order and hands over a file.

## Goal

The reader finishes in a couple of minutes, can restate the subject in their own words, knows what they have to decide, and can leave a question on the page at the place that raised it.

## Your Role

Open the file. Click **Review**, comment on whatever didn't land, then **Send feedback** and either copy it or download it. Paste or hand that back and `/triage` turns it into the next round.

Every block on the page is a comment target, and each comment comes back carrying its heading, its anchor id, and the text it was left on — so the answer can address what was asked without a round of "which part do you mean?"

## Agent's Role

Pick the mode, gather what the page needs, run the three passes in order, commit the source, hand over the file.

Never drop a pass. Terse without ELIF produces a dense page carrying the same jargon that caused the confusion. ELIF without terse produces a plain-language wall. Either one without `artifact-build` produces a chat message. Any of them without `artifact-annotate`'s delivery produces a page the reader cannot mark up.

## Invocation

| Input | Behavior |
|---|---|
| Bare `/tea` after an agent response | Concept tea on the thread's load-bearing topic. Name the topic in one line before building, so a wrong read is cheap to correct. |
| `/tea <concept>` | Concept tea on that subject. Research it first when the thread doesn't already carry the answer. |
| `/tea <project>`, "give me the tea on <project>" | Project tea. Research the engagement, then report. |
| Natural language ("put that on a page", "where does <project> stand") | Same routing as above: a subject selects concept, an engagement selects project. |

**Disambiguation.** An engagement, client, or repo name selects project mode. An idea, technology, pattern, or acronym selects concept mode. When a name reads as both, ask one question and wait. Do not build both.

**Up front or mid-thread.** Tea works as the opening move on an exploratory question and as an interrupt when an exchange isn't landing. Mid-thread, the preceding response stays in history — the page serves the moment, the precise version is still there to return to.

## The Three Passes

Fixed order. Each pass takes the previous one's output.

### 1. Terse — what goes on the page

Run the selection discipline from `terse`: verdict first, one fact per unit, concrete identifiers verbatim, narrative and rationale essays cut. The result is the page's spine.

The 30-second bound in `terse` governs a chat message. A page's bound is a couple of minutes, and its structure carries the scan. What carries over is the selection, not the length.

### 2. ELIF — how it reads

Run `elif` over the spine: swap the vocabulary, define each term of art once in place, keep every fact, identifier, number, and caveat verbatim. Calibrate to the reader `elif` describes — an experienced technologist and PM who is outside their depth on one subject. Do not re-teach APIs, deploys, branches, or tickets.

The page is terse-selected content written in plain words. It is not a bullet list.

### 3. Artifact — how it looks

Run `artifact-build` in full: treatment read, written design plan, then code, then the pre-delivery check. The treatment is utilitarian in nearly every case — this is a reference someone reads, and an oversized hero on it reads as unserious.

`data-cid` on every commentable block, since comments are the return path and this page exists to be argued with. **Anchor the section heads too** — the block holding the eyebrow and the `h2` is what a reader clicks when the question is about a whole section, and a page that only anchors paragraphs and tables leaves that click with nothing to attach to.

**The page heading starts with ☕, and the favicon is ☕.** `<h1>☕ Halo OMS</h1>`, with an inline `<link rel="icon">` carrying the cup so a local file shows it too, and `favicon: "☕"` on any published copy. The heading is the one the reader sees on the page; the favicon is the one they find in a row of tabs. Both mark the page as a tea at a glance.

**The `<title>` tag stays clean** — `<title>Halo OMS</title>`. The browser tab already shows the favicon beside the title, so an emoji there is the same mark twice.

This is the one place the no-emoji rule is set aside deliberately, and it reaches the h1 and the favicon only — never section headings, never body copy. Emoji as a page marker is an AI tell, and here it is a useful one: a knowing exception, not an oversight.

The favicon is fixed at ☕ across every tea, which overrides the usual subject-derived choice. `artifact-build`'s stability rule still holds within a page's life: a tea keeps ☕ on every redeploy.

**Load `artifact-annotate` and run it in full — the delivery model and the feedback layer both.** It is loaded before the code is written, not bolted onto a finished page; that skill's Gate 0 applies here as written.

Paste the feedback layer last, verbatim, after the theme control. Fill in `#feedback-config` and nothing else:

- `docId` — the page slug, matching the filename: `tea--<slug>`.
- `title` — the page title without the ☕.
- `revision` — the build timestamp.
- `endpoint` — `null`. Export is the return path.

The built-in artifact comments still work and are still there. They anchor by DOM position and carry neither the heading nor the text they were left on, so a comment on section two arrives as `section:nth-of-type(2) > div:nth-of-type(1)` and an agent without the source file cannot say what it refers to. The feedback layer's payload carries the `cid`, the heading, the quoted block, and the kind of comment, which is what makes a reply possible without interrogating the reader.

### Delivery — the file is the deliverable

`artifact-annotate`'s delivery model applies to every tea, both modes, with no carve-out. The deliverable is the `.html` file on disk. **A published artifact URL is not a handover.**

**Never write a tea to the session scratchpad.** It goes to a real path, which is also the committed one:

| The tea is about | Path |
|---|---|
| An engagement with a repo | `<repo>/ideate/artifacts/tea--<slug>.html` |
| Anything else | `<workspace>/.tea/tea--<slug>.html`, beside its source map |

Commit it. That is what lets a comment arriving next week resolve its anchors against the revision the reader actually read, and it is what makes `revision` in the config mean something.

**When the destination is not under version control, say so in the handover.** Some workspaces are plain directories. The file still goes there and still gets delivered; what is lost is recoverability, so the next run overwriting that path destroys the revision a reader may still be holding. Name that out loud rather than skipping the step silently, and offer to `git init` the workspace if teas are going to keep landing there.

Then hand it over by the route the surface supports, reading the surface rather than assuming it — `printenv CLAUDE_CODE_ENTRYPOINT`, `cli` means a real terminal and everything else means a GUI. The table, the SSH guard, and the Linux fallback are in `artifact-annotate`; follow them as written.

**All three export paths work on a local file**, which is the point of delivering one. Copy, download, and any onward channel the reader picks are all live. Say which one you want it back through.

**Publishing is optional and never the handover.** A tea may also be published as an Artifact for the team's own copy — useful when the page is worth keeping in the gallery or when the reader is inside Claude anyway. When you do, the file still goes over first, and the URL is mentioned second. When you don't, nothing is lost.

## Concept Tea

The subject is one idea the reader needs to hold: a protocol, an architecture pattern, a financial mechanic, an infrastructure layer, a vendor's model.

1. **Name the load-bearing unknown.** The one term the rest of the answer rests on. Everything else is scaffolding around it.
2. **Get the facts right first.** When the thread already carries the answer, use it. When it doesn't, research before writing — `context7` for library and framework documentation, web search for everything else. A plain-language page built on a wrong fact is worse than a jargon-heavy correct one.
3. **Run the three passes.**
4. **Let the subject pick the sections.** A page about a protocol wants the message sequence. A page about a tradeoff wants the two positions and what separates them. A fixed template would flatten both.
5. **Mark what's inference.** When part of the explanation is a reading rather than a documented fact, say so on the page in one line.

A diagram earns its place when the mechanism is spatial or sequential — a request path, a data flow, a state machine. Load `artifact-diagramming` before drawing one, and skip it when prose already carries the idea.

## Project Tea

The subject is an engagement's real state. The reader is accountable for the project delivering on budget with a healthy margin, and reads this to find out whether it is and what needs them.

### 1. Locate

Look for a source map at `<workspace>/.tea/<slug>.md` first. When one exists, use it and skip to the sweep.

With no map, run a locate pass before any sweeping:

- **Slack** — search for the project's channels, internal and shared/client. Read the channel bookmarks and any canvas; the Google Drive folder for an engagement is usually bookmarked there.
- **Runn** — resolve the client and project, and note the project id.
- **Delivery** — the local discovery or ideate directory under the working tree, and the GitHub repo when one exists.
- **Circleback** — the meeting series and the recurring calendar event.
- **Gmail** — the thread pattern, usually a client domain plus the project name.

Report what resolved and what didn't in one line each, then proceed. A missing source is a finding, not a blocker.

### 2. Sweep

Fan out one agent per source family, in parallel, in a single message. Each returns findings — claims with dates and attribution — never transcripts or file dumps.

| Agent | Reads | Returns |
|---|---|---|
| Meetings | Circleback meetings, transcripts, action items, emails | Decisions made, commitments given, action items with owner and age |
| Slack | Project channels internal and shared, bookmarks, canvases | Blockers, escalations, unanswered client questions, tone shifts |
| Commercial | Runn project, assignments, actuals, project totals, milestones, phases | Hours burned against planned, run rate, who is assigned and at what allocation, forecast to milestone |
| Delivery | Local discovery/ideate files, GitHub issues, milestones, PRs, recent commits | What shipped, what's in flight, what's slipped, deliverable state against the roadmap |
| Google | Gmail threads, the Drive folder found in the channel bookmarks | Contract and scope documents, client-facing docs changed in the window, anything sent that never got a reply |

The MCP tools for Circleback, Slack, Runn, Gmail, and Drive are deferred. Each agent loads its own with `ToolSearch` before calling — tell it so in the prompt, or it will report the source as unavailable.

### 3. Window

Default to the period since the last tea on that project, recorded in the source map. With no prior run, use **14 days** — the usual question is what moved in the last two weeks. Widen it when the user asks, in the invocation ("`/tea <project>`, last quarter") or conversationally.

Two things ignore the window: anything still open carries regardless of age, and the commercial position is always current-state rather than a delta.

State the window on the page.

### 4. Reconcile

Sources disagree, and the disagreement is usually the story. When the channel says a milestone landed and Runn shows the hours still burning against it, put both readings on the page and name the conflict. Do not average them into a comfortable middle.

Separate what was observed from what was inferred, and mark the inferences on the page as `artifact-build` requires.

### 5. Grade

One health verdict — **on track**, **at risk**, or **off track** — with the reason in the same sentence and the evidence under it.

- Grade from evidence, not from the tone in the channel. A calm channel over an overrun budget is at risk.
- Burn running ahead of delivered scope is at risk even when nobody has said so.
- A quiet channel is a signal. Two weeks of silence on an active engagement goes on the page.
- Name the one thing that would change the grade.

### 6. Deliver and offer the map

Compose through the three passes, commit the source, hand over the file. Then offer to save the source map for next time, and write nothing until that is approved.

### Handling

Project tea is an internal artifact and carries hours, dollars, margin, and allocation. The Money Rule that strips those from client artifacts governs client artifacts; the inverse governs this one. It never goes to a client, and the page says so near the title.

## Source Map

`<workspace>/.tea/<slug>.md`, written only on approval. It holds where a project's sources live so later runs are fast and consistent:

```
# Tea source map — <Project>

Aliases: <names the user calls it>
Slack: #<channel>, #<shared-channel>
Runn: <client> / <project> (id <n>)
Drive: <folder name and link>
GitHub: <owner/repo>
Local: <path>
Circleback: <meeting series name>
Gmail: <search that finds the threads>

Last tea: YYYY-MM-DD → <path to the committed file> [→ <artifact URL>, when one was published]
```

Update `Last tea` on each run so the next window starts where this one stopped. The path is what a later run reads to resolve feedback anchors and what it overwrites on a refresh; the URL is recorded only when a copy was published, and only so a redeploy can keep that link. Keep credentials out of it; it holds names, ids, and paths only.

## Artifact

A self-contained HTML file at a real, committed path, handed to the user by `artifact-annotate`'s delivery route. It carries that skill's feedback layer, so the page a reader comments on and the page they read are the same page. See `ARTIFACT.md` for the content template.

Refreshing a tea overwrites the same path and commits again — same `docId`, new `revision`. That keeps one lineage, which is what lets late feedback against an older revision still resolve.

When a copy was also published, republish that same file path to keep the URL within a conversation, or pass the URL from the source map's `Last tea` line from a new one.

## Closure Criteria

- [ ] Mode chosen, and the subject named back to the user before building
- [ ] Terse pass ran first and produced the page's spine
- [ ] ELIF pass ran over the spine; every term of art is defined in place or gone
- [ ] Every fact, identifier, number, and caveat survived both passes verbatim
- [ ] `artifact-build` ran in full, including the pre-delivery self-check
- [ ] Every commentable block carries `data-cid`, section heads included
- [ ] `artifact-annotate` loaded before the code was written, not retrofitted
- [ ] `artifact-annotate`'s feedback layer pasted in last, verbatim, with `#feedback-config` filled and no `REPLACE-` strings left
- [ ] File written to a real path, never the scratchpad, and committed
- [ ] **The surface was read** (`printenv CLAUDE_CODE_ENTRYPOINT`), not assumed
- [ ] Handed over by the matching route — terminal: opened, revealed, path printed, `SendUserFile`; GUI: `SendUserFile` alone
- [ ] Inferences marked as inferences on the page
- [ ] Project tea: health verdict leads, and what-needs-you sits directly under it
- [ ] Project tea: sources read and sources unreachable both listed, with the window stated
- [ ] Project tea: page marked internal
- [ ] Source map offered, and written only after approval
- [ ] Handover message tells the reader the review mode exists, and names the channel the feedback should come back through

## Notes

**A tea is not a record.** It is read once, over a cup of tea, and acted on by going and talking to people. It is not sent to a client, and nothing downstream depends on it. Two consequences: hand it over rather than gating it behind a review pass — the comment loop is the correction, and it works. And do not build ceremony around it. No approval state, no archive, no version picker. The next run overwrites the same path.

The commit is not ceremony. It costs one command and it is the only thing that makes a comment arriving after the next run still resolvable — the reader read revision 2, the path now holds revision 3, and the anchors only line up if revision 2 is still recoverable. An earlier version of this skill waived the commit on the argument that a tea has no weeks-later to plan for. Readers sit on pages.

**Why the feedback layer, when the reader is inside Claude.** The built-in comments work, and for a while this skill used them on exactly that reasoning. What they do not carry is what the comment was left *on*. A thread arrives anchored as `section:nth-of-type(2) > div:nth-of-type(1)` with the comment text and nothing else — no heading, no quote, no stable id. That path is resolvable against the source file, and an agent holding the file should resolve it rather than asking. An agent without the file cannot, and asking the reader which section they meant, on a page they are looking at, reads as broken.

The DOM path has a second problem the feedback layer does not: it is positional. Insert a section, republish, and every prior thread silently points one section off, with no error anywhere. A `cid` plus a quoted excerpt survives that.

The cost is a manual return trip — Review, comment, Send, copy, paste — where the built-in comments arrive on their own. That trade is deliberate: a comment that arrives instantly and cannot be answered is worth less than one that takes two clicks and can.

**Why terse runs first.** ELIF over unselected content produces a plain-language wall, and then the cutting has to happen anyway — against prose that now takes more words to say the same thing. Selecting first means ELIF translates a spine.

**Why it always produces a page.** The point of the invocation is a change of format. A terse-plus-plain answer in the chat is `/terse` then `/elif`, which already exist. Tea is those two composed onto a page the reader can scan, keep, and annotate.

**Why the page is a file and not a URL.** Both carry the same content and the same feedback layer, so the choice comes down to what the reader can do with it. A file opens in their own browser, where all three export paths fire and the page is theirs to keep. A URL opens in the artifact viewer, where `<a download>` is inert and the page belongs to the gallery. The reader also frequently wants to forward a tea to someone who has no Claude account, and a file survives that trip. Publishing alongside stays available for the team's own copy; it is an addition to the handover, never a substitute for it.

**Why project mode fans out.** One agent reading five source families in sequence spends its context on transcripts and Slack scrollback and arrives at synthesis with nothing left. Five agents each return a page of findings, and the synthesis happens against findings.

**On the health verdict.** The grade is the reason the page exists, and softening it defeats the purpose. An engagement graded on track every week until the month it fails was never being graded.

**Concept tea and project tea share only the passes.** They gather differently, they are shaped differently, and the only thing they hold in common is terse-then-ELIF-then-page. Keeping them one skill is deliberate: the invocation is the same instinct — hand me this in a form I can absorb.
