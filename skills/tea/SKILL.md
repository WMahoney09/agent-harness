---
name: tea
description: |
  Tea — Terse, ELIF, Artifact. Turn a topic or a project's real state into a plain-language page, published as an Artifact and commentable in place. Two modes: concept tea makes an unfamiliar idea land; project tea researches an engagement across meetings, Slack, Runn, mail, Drive, and delivery artifacts, then reports where it stands.
  TRIGGER when: the user sends `/tea` after an agent response (turn that topic into a page), `/tea <concept>` (explain that concept as a page), or `/tea <project>` / "give me the tea on <project>" (research that engagement and report its state). Also natural language: "put that on a page", "I'm still not getting this", "what's the state of <project>", "where does <project> stand", "give me a pulse on <project>".
---

# Tea

`terse` decides what goes on the page. `elif` decides how it reads. `artifact-craft` decides how it looks and publishes it. Tea composes the three in that order and hands back a URL.

## Goal

The reader finishes in a couple of minutes, can restate the subject in their own words, knows what they have to decide, and can leave a question on the page at the place that raised it.

## Your Role

Read the page. Annotate what didn't land — Artifacts published from this machine carry comments out of the box, and every block on the page is a comment target. Send the comments back and `/triage` turns them into the next round.

## Agent's Role

Pick the mode, gather what the page needs, run the three passes in order, publish, hand back the URL.

Never drop a pass. Terse without ELIF produces a dense page carrying the same jargon that caused the confusion. ELIF without terse produces a plain-language wall. Either one without `artifact-craft` produces a chat message.

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

Run `artifact-craft` in full: treatment read, written design plan, then code, then the pre-publish check. The treatment is utilitarian in nearly every case — this is a reference someone reads, and an oversized hero on it reads as unserious.

`data-cid` on every commentable block, since comments are the return path and this page exists to be argued with.

**The title starts with 🍵, and the favicon is 🍵.** `<title>🍵 Halo OMS</title>`, published with `favicon: "🍵"` — the tea, then the two-to-four-word name. Both mark the page as a tea at a glance, in a gallery of dozens of artifacts and in a row of browser tabs. This is the one place the no-emoji-in-prose rule is set aside deliberately; it does not extend to headings, section markers, or body copy. Emoji in a title is an AI tell, and here it is a useful one — a knowing exception, not an oversight.

The favicon is fixed at 🍵 across every tea, which overrides the usual subject-derived choice. `artifact-craft`'s stability rule still holds within a page's life: a tea keeps 🍵 on every redeploy.

Skip `artifact-annotate`. The reader is inside Claude, where built-in comments already work.

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

Separate what was observed from what was inferred, and mark the inferences on the page as `artifact-craft` requires.

### 5. Grade

One health verdict — **on track**, **at risk**, or **off track** — with the reason in the same sentence and the evidence under it.

- Grade from evidence, not from the tone in the channel. A calm channel over an overrun budget is at risk.
- Burn running ahead of delivered scope is at risk even when nobody has said so.
- A quiet channel is a signal. Two weeks of silence on an active engagement goes on the page.
- Name the one thing that would change the grade.

### 6. Publish and offer the map

Compose through the three passes, publish, hand back the URL. Then offer to save the source map for next time, and write nothing until that is approved.

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

Last tea: YYYY-MM-DD → <artifact URL>
```

Update `Last tea` on each run so the next window starts where this one stopped. Keep credentials out of it; it holds names and ids only.

## Artifact

A published Artifact — HTML written to the session scratchpad, then published with the Artifact tool. See `ARTIFACT.md` for the content template.

Republish the same file path to keep the URL when refreshing a project within a conversation. From a new conversation, pass the prior URL from the source map's `Last tea` line so the link survives.

## Closure Criteria

- [ ] Mode chosen, and the subject named back to the user before building
- [ ] Terse pass ran first and produced the page's spine
- [ ] ELIF pass ran over the spine; every term of art is defined in place or gone
- [ ] Every fact, identifier, number, and caveat survived both passes verbatim
- [ ] `artifact-craft` ran in full, including the pre-publish self-check
- [ ] Every commentable block carries `data-cid`
- [ ] Inferences marked as inferences on the page
- [ ] Project tea: health verdict leads, and what-needs-you sits directly under it
- [ ] Project tea: sources read and sources unreachable both listed, with the window stated
- [ ] Project tea: page marked internal
- [ ] Source map offered, and written only after approval
- [ ] URL handed back, with the note that artifacts stay private until shared

## Notes

**A tea is not a record.** It is read once, over a cup of tea, and acted on by going and talking to people. It is not shared, not sent to a client, not committed anywhere, and nothing downstream depends on it. Two consequences: publish it rather than gating it behind a review pass — the comment loop is the correction, and it works. And do not build durability into it. No versioning ceremony, no approval state, no archive. The next run replaces it.

**Why terse runs first.** ELIF over unselected content produces a plain-language wall, and then the cutting has to happen anyway — against prose that now takes more words to say the same thing. Selecting first means ELIF translates a spine.

**Why it always publishes.** The point of the invocation is a change of format. A terse-plus-plain answer in the chat is `/terse` then `/elif`, which already exist. Tea is those two composed onto a page the reader can scan, keep, and annotate.

**Why project mode fans out.** One agent reading five source families in sequence spends its context on transcripts and Slack scrollback and arrives at synthesis with nothing left. Five agents each return a page of findings, and the synthesis happens against findings.

**On the health verdict.** The grade is the reason the page exists, and softening it defeats the purpose. An engagement graded on track every week until the month it fails was never being graded.

**Concept tea and project tea share only the passes.** They gather differently, they are shaped differently, and the only thing they hold in common is terse-then-ELIF-then-publish. Keeping them one skill is deliberate: the invocation is the same instinct — hand me this in a form I can absorb.
