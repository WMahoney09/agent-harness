---
name: triage
description: |
  Ingest feedback from a pull request, a review report, or a conversational list. Group related items into unified revisions, prioritize by severity, and produce a structured report ready for action with /revise.
  TRIGGER when: the user asks to triage, review, or address feedback from a PR, review, or conversation ("triage this", "triage the feedback", "look at the review comments", "what did the reviewer say", "address the feedback", "let's go through the findings"), or when PR review feedback is present and the user asks to work through it.
---

# Triage: Feedback Ingestion and Revision Planning

This skill ingests feedback from one or more sources, groups related items into unified revisions, prioritizes by severity, and produces a structured report. It is a read-only analysis skill — it makes no code changes.

## Invocation

- **`/triage`** — Triage feedback from the current conversation (review output, a list of issues, etc.)
- **`/triage #N`** — Fetch and triage unresolved PR comments from pull request #N in the current repo
- **`/triage #N owner/repo`** — Fetch and triage unresolved PR comments from a PR in another repo
- **`/triage #N + review`** — Triage both PR comments and review skill output together

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

Two shapes are possible. Default `/review` output carries **Critical / Major** only. `/review full` adds **Minor / Gaps / Opportunities**. Ingest whichever sections are present; absent sections mean the review was run in default scope, not that it found nothing. Do not treat a missing Minor section as "no minor issues" — if the user needs that granularity, they can re-run `/review full`.

### 3. Conversational List

When the user provides a list of issues directly in conversation — as bullet points, numbered items, or free prose — parse and ingest each discrete item.

### 4. Combined

When multiple sources are present, ingest all of them together and treat the full set as one triage pass. Deduplicate items that appear in more than one source.

## Agent's Role

### Step 1: Ingest All Feedback

Collect everything from the specified source(s). For PR comments, fetch and list all unresolved items. For review output or conversational lists, parse each discrete finding.

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

**Source:** [PR #N / Review output / Conversational list / Combined]
**Items ingested:** [total count of raw feedback items]
**Revisions identified:** [count after grouping]

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

## Notes

- Triage is read-only — it produces a report, it does not change code
- Every source item must appear somewhere in the report — nothing disappears silently into a group
- When combining sources, deduplicate carefully: a finding in the review output and a comment on the same issue are one revision, not two
- Triage ends when the report is delivered; use `/revise` to act on the output
