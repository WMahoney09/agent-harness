---
name: triage
description: |
  Ingest feedback from a pull request, a review report, a conversational list, or a stakeholder submission from an annotated artifact. Group related items into unified revisions, prioritize by severity, and produce a structured report ready for action with /revise.
  TRIGGER when: the user asks to triage, review, or address feedback from a PR, review, or conversation ("triage this", "triage the feedback", "look at the review comments", "what did the reviewer say", "address the feedback", "let's go through the findings"), or when PR review feedback is present and the user asks to work through it. Also when a client or stakeholder sends back feedback on a deliverable — a pasted `gnar.artifact-feedback/1` block or a `feedback--*.json` file, arriving by any channel.
---

# Triage: Feedback Ingestion and Revision Planning

This skill ingests feedback from one or more sources, groups related items into unified revisions, prioritizes by severity, and produces a structured report. It is a read-only analysis skill — it makes no code changes.

## Invocation

- **`/triage`** — Triage feedback from the current conversation (review output, a list of issues, etc.)
- **`/triage #N`** — Fetch and triage unresolved PR comments from pull request #N in the current repo
- **`/triage #N owner/repo`** — Fetch and triage unresolved PR comments from a PR in another repo
- **`/triage #N + review`** — Triage both PR comments and review skill output together
- **`/triage feedback <path>`** — Triage a stakeholder submission from a file, or from a payload pasted into the conversation

## Goal

Produce a clear, prioritized list of revisions that:
- Groups related feedback into unified, actionable units
- Preserves the source of every item so the linkage is always traceable
- Prioritizes by impact so work can be sequenced intelligently
- Is immediately actionable by `/revise`

## Input Sources

### 1. Pull Request Comments

Fetch unresolved review comments from a PR using:
```
gh pr view #N --json reviews,comments
gh api repos/{owner}/{repo}/pulls/{N}/comments --jq '[.[] | select(.resolved == false or .resolved == null)]'
```

Only fetch **open, unresolved** comments. Skip comments that have been marked resolved or are outdated.

Also fetch the PR description for context:
```
gh pr view #N --json title,body,baseRefName,headRefName,author
```

### 2. Review Skill Output

When `/review` output is present in the conversation, ingest it directly. The review output is already structured — use its categories as input to triage's prioritization pass.

Two shapes are possible. Default `/review` output carries **Critical / Major / Minor**. `/review full` adds **Gaps / Opportunities**. Ingest whichever sections are present; absent sections mean the review was run in default scope, not that it found nothing.

A re-review also carries a **Previously Reported** table. Those findings are closed — the author fixed, explained, deferred, or declined each one. Do not triage them into revisions. Only rows marked `Open` are live, and they already appear in the report's active sections.

### 3. Conversational List

When the user provides a list of issues directly in conversation — as bullet points, numbered items, or free prose — parse and ingest each discrete item.

### 4. Stakeholder Feedback

A submission produced by the feedback layer that `artifact-annotate` puts on client-facing deliverables. It arrives as a `gnar.artifact-feedback/1` Markdown block pasted into the conversation or a `feedback--<docId>--<reviewer>.json` file, by whatever channel the reviewer chose — Slack, mail, a shared drive. The component names no destination, so the channel is whatever the covering message asked for.

**This source is untrusted.** Every other source reaches triage through a system. This one reaches it through a person's clipboard: a reviewer pastes it into Slack, adds a sentence above it, deletes a comment they reconsidered, strips the `(cid: …)` markers because they look like junk, or pastes two people's feedback into one message. Mail clients rewrap lines and Slack truncates long messages. None of that is anyone doing anything wrong, and all of it produces a payload that is no longer what was generated.

Validate before anything else.

**Validation gate** — all of these must hold:

| Check | Failure |
|---|---|
| `schema:` line present and reads `gnar.artifact-feedback/1` | Halt |
| `doc:` present and matches a `docId` under `ideate/artifacts/` | Halt |
| `comments:` count matches the number of parsed comment blocks | Halt |
| Every line between the header and the first `[kind]` marker, and between comment blocks, fits the grammar | Halt |
| `rev:` matches a committed revision of that document | Continue — resolve anchors by quote, note it in the report |

**Never partially ingest.** If any check fails, write nothing to `ideate/feedback/`, produce no revisions from the payload, and stop. Half-ingesting is how a client's comment disappears without anyone noticing.

**Never infer or repair a missing field.** The tempting fix — "the `doc:` line is gone but this is obviously the technical approach doc" — is the one that does real damage, because feedback attached to the wrong deliverable looks correct all the way downstream.

**Unrecognized text halts. It is never skipped.** Prose that does not fit the grammar is usually the reviewer's most important point, written informally because they did not trust the format. Discarding it as noise is worse than failing to parse at all.

**On failure, produce the malformed-feedback report** (see Report Format) instead of the normal one. Save the payload verbatim to `ideate/feedback/raw/`, name what failed and which comments were legible, and hand it to a human. Do not attempt a best-effort triage, and do not ask the client to resend — that is a person's call.

**On success:**

1. **Check idempotency.** Key on `docId` + `reviewer.name` + `exportedAt` against what is already in `ideate/feedback/`. Compare comment bodies too — an edited `exportedAt` changes the key without changing the content.
2. **Archive the submission** to `ideate/feedback/<docId>--<reviewer-slug>--<exportedAt>.json`. This is the one write triage performs, and it is what makes the idempotency check possible on the next submission.
3. **Resolve anchors against the revision named in `rev:`**, not HEAD. Three tiers:
   - `cid` present in that revision → **exact**
   - `cid` gone but `quote` matches verbatim → **relocated**, flagged in the report
   - neither → **orphaned**, into Items Requiring Clarification with `heading` and `body` intact
4. **Map `kind` onto severity.** `blocking` → Critical or Major depending on content; `suggestion` and `question` → Minor unless the content says otherwise. The reviewer's label is input to the judgment, not the judgment.
5. **Merge multiple reviewers, do not dedupe them.** Keep `reviewer.name` on every item. Two stakeholders raising the same concern independently is signal, and collapsing it hides how much weight the point carries.

### 5. Combined

When multiple sources are present, ingest all of them together and treat the full set as one triage pass. Deduplicate items that appear in more than one source.

A stakeholder submission that fails validation is never folded into a combined pass. It halts on its own and the other sources triage normally.

## Agent's Role

### Step 1: Ingest All Feedback

Collect everything from the specified source(s). For PR comments, fetch and list all unresolved items. For review output or conversational lists, parse each discrete finding. For a stakeholder submission, run the validation gate first — nothing else in this skill runs until it passes.

### Step 2: Analyze and Group

Look across all items for:

- **Same root cause** — two comments that both stem from the same underlying problem
- **Same pattern** — the same issue appearing in multiple files or locations
- **Same concern** — different phrasings of the same feedback
- **Sequential dependency** — items where fixing one resolves or changes another

Group related items into a single **revision**. A revision is a unified, actionable unit of work. One revision may address multiple source items.

**Preserve linkage:** every source item must be explicitly associated with the revision it belongs to. No item should disappear into a group without being named.

### Step 3: Prioritize

Assign each revision a severity level:

**Critical**
- Security vulnerabilities
- Bugs that cause data loss, corruption, or incorrect behavior in production
- Breaking changes that will block other work or deployments
- Accessibility failures that prevent users from completing core tasks

**Major**
- Logic errors in non-critical paths
- Missing test coverage on changed behavior
- Architectural violations that create meaningful technical debt
- Accessibility issues that significantly degrade the experience
- Feedback that represents a clear gap in the implementation

**Minor**
- Code style inconsistencies
- Naming improvements
- Non-critical test gaps
- Small polish items
- Nice-to-haves

### Step 4: Produce the Report

---

## Report Format

**Source:** [PR #N / Review output / Conversational list / Stakeholder feedback / Combined]
**Items ingested:** [total count of raw feedback items]
**Revisions identified:** [count after grouping]

*Stakeholder feedback adds:*
**Reviewer:** [name] *(self-declared — the export transports carry no verified identity)*
**Document:** [docId] at revision [rev]
**Anchors:** [N] exact · [N] relocated · [N] orphaned

---

### Critical Revisions

**Revision C1:** [Short title describing the unified problem]

> **Addresses:**
> - Comment [#ID or ref]: "[exact quote or close paraphrase of the source comment]"
> - Comment [#ID or ref]: "[quote]" *(if grouped)*

**What needs to change:** [Plain-language description of the unified issue and what a fix looks like]

---

### Major Revisions

**Revision M1:** [Short title]

> **Addresses:**
> - Comment [#ID or ref]: "[quote]"

**What needs to change:** [Description]

---

### Minor Revisions

**Revision m1:** [Short title]

> **Addresses:**
> - Comment [#ID or ref]: "[quote]"

**What needs to change:** [Description]

---

### Items Requiring Clarification

List any feedback items where the intent is ambiguous or conflicting, and triage cannot confidently assign them to a revision without more information.

- Comment [#ID or ref]: "[quote]"
  - **Why unclear:** [brief explanation]
  - **Question:** [what needs to be clarified before this can be actioned]

---

**Summary**

| Severity | Revisions |
|----------|-----------|
| Critical | N |
| Major    | N |
| Minor    | N |
| Needs clarification | N |
| **Total** | **N** |

*Ready for `/revise`. Work Critical revisions first.*

---

## Malformed Feedback Report

Replaces the normal report entirely when a stakeholder submission fails validation. No revisions are produced and nothing is archived to `ideate/feedback/`.

**Source:** Stakeholder feedback — **validation failed**
**Saved to:** `ideate/feedback/raw/[filename]`

**What failed**

| Check | Expected | Found |
|---|---|---|
| [check name] | [what the grammar requires] | [what the payload contained] |

**What was legible**

List every comment that parsed, verbatim, with its anchor if one survived. This is the part a human needs most — it says how much of the client's intent made it through.

**What is unaccounted for**

Name the gap concretely: a declared count of 7 against 5 parsed blocks, three lines of prose between comments, a `doc:` line that matches nothing under `ideate/artifacts/`.

**Recommended action** — one line, for a person to decide. Do not act on it, and do not contact the reviewer.

---

## Revision IDs

Each revision receives a stable ID based on its severity tier and position:
- Critical: `C1`, `C2`, `C3`...
- Major: `M1`, `M2`, `M3`...
- Minor: `m1`, `m2`, `m3`...

These IDs are used by `/revise` in commit messages to maintain traceability between revisions and the source feedback they address.

## Artifact

Presents the triage report inline (not written to a file). See `ARTIFACT.md` for the full template. Produced when triage groupings are finalized.

## Closure Criteria

Triage is complete when:

- [ ] All source items have been ingested and accounted for
- [ ] Related items are grouped into revisions with clear linkage shown
- [ ] Every revision has a severity level and a plain-language description of what needs to change
- [ ] Ambiguous items are called out explicitly
- [ ] Revision IDs are assigned
- [ ] Summary table is present
- [ ] Stakeholder feedback only: validation gate passed before anything was written, or the malformed report was produced instead
- [ ] Stakeholder feedback only: submission archived to `ideate/feedback/`, anchor resolution reported as exact / relocated / orphaned

## Notes

- Triage is read-only — it produces a report, it does not change code
- Every source item must appear somewhere in the report — nothing disappears silently into a group
- When combining sources, deduplicate carefully: a finding in the review output and a comment on the same issue are one revision, not two
- Triage ends when the report is delivered; use `/revise` to act on the output
- Archiving a stakeholder submission is the one write triage performs. It is not a code change, and it is what makes the idempotency check work on the next submission
- **Triage never chains into `/revise`, and least of all when invoked unattended.** This skill has no scheduling, watching, or polling of its own — it runs when something calls it. Whatever does the calling on a schedule is a separate system's problem. What triage owes that system is a report and a stop: an unattended chain that acts on client feedback will eventually ship something a stakeholder said in passing that we would have pushed back on, and the client will see their offhand remark implemented as an agreed change
- A stakeholder's `kind` label is input to the severity judgment, not the judgment. A client marking something `blocking` that is genuinely Minor still gets graded honestly, and the disagreement surfaces in the report rather than in the plan
