---
name: publish-review
description: |
  Publish review findings as a structured GitHub PR review with inline comments anchored to diff lines. Use after /review to deliver findings directly on the pull request.
  TRIGGER when: review output exists in the conversation and the user asks to publish or post findings to the PR ("publish the review", "post the findings", "put the review on the PR", "share the review").
---

# Publish Review: Deliver Findings as Inline PR Comments

This skill takes `/review` findings from conversation context and posts them as a structured GitHub review with inline comments anchored to the actual diff lines. Reviewers see each finding in context without navigating away from the diff.

## Invocation

- **`/publish-review #N`** — Post findings to PR #N in the current repo
- **`/publish-review #N owner/repo`** — Post findings to PR #N in another repo

## Modes

### Interactive (default)

Direct invocation by the user. Step 5 presents the full mapping and waits for confirmation before posting. This is the mode for any hand-driven publish.

### Unattended

Invoked as the delivery step of `/review`, which is a send-it-and-walk-away command. **Skip Step 5 entirely** — no mapping presentation, no confirmation, no questions. Run Steps 1–4, then post in Step 6 and report in Step 7.

Every branch that would have prompted the user resolves to a fixed default instead:

| Situation | Interactive | Unattended |
|---|---|---|
| Finding already covered by an existing comment | Ask, default skip | Skip silently, count it in the Step 7 report |
| Review output targets a different PR than the publish target | Warn, ask to proceed | **Abort.** Post nothing and report the mismatch |
| Thread matched as dispositioned by a re-review | Show, then resolve | Resolve |
| API 422 on a comment | Retry at a coarser anchor | Retry at a coarser anchor |
| Every Critical and Major is dispositioned (meets the approve gate) | Show the approval, then post it | Post the `APPROVE` review |
| Nothing to post and a blocking finding is still open | Report, post nothing | Report, post nothing |
| A finding's disposition is a judgment call | Ask | **Read it as dispositioned** if the author responded at all; otherwise open |

The cross-PR mismatch is the one hard stop. Cross-posting a review onto the wrong pull request is the failure that is loud, public, and confusing to unwind — never guess it right. In the normal `/review #N` → `/publish-review #N` handoff the numbers come from the same invocation, so this should not fire; if it does, something upstream is wrong and stopping is correct.

The last row leans toward closing rather than toward blocking, which is the opposite of the usual safe-default instinct and is deliberate. An author who wrote a reply has engaged with the finding; holding it open because the reply was terse or informal restarts the loop over a formatting judgment. An approval posted a round early costs one follow-up review. A finding held open on a technicality costs the author another round.

If any *other* situation arises with no safe default, stop and report. Do not post a partial or speculative review.

## Goal

Deliver `/review` findings directly onto a pull request as a single GitHub review with inline comments anchored to diff lines, so reviewers see each finding in the context where it matters.

## Agent's Role

### Step 1: Extract Findings from Conversation

Read back through the conversation to find the most recent `/review` output. For each finding, extract:

- **Severity** (Critical, Major, Minor)
- **Description** (the issue)
- **File and line** (`file:line` reference)
- **Why it matters** (Critical/Major only)
- **Suggestion** (recommended fix or direction)

Also read the **Previously Reported** table if the report has one. Its presence means this is a re-review. For each row, extract the finding description, its prior severity, and its disposition — `Fixed`, `Intentional`, `Deferred`, `Declined`, or `Open`. Rows carrying one of the first four are closed findings: they drive thread resolution in Step 3 and the state gate in Step 4a, and they are not posted again as comments. `Open` rows already appear in the report's active sections and are handled as ordinary findings.

Extract the **recommendation** verbatim too (`Go`, `Go with conditions`, `No-Go`). Report it in Step 7; the state gate reads dispositions, not the recommendation.

If the report has no Previously Reported table, treat it as round 1 — every Critical and Major in it is open.

If no `/review` output is found in the conversation, stop and report:

```
No review findings in this conversation. Run /review or /review #N first, then /publish-review #N to post the findings.
```

### Step 2: Fetch PR Diff and Map Findings

Fetch the PR diff and metadata. Derive `{owner}/{repo}` from the git remote origin (e.g., `gh repo view --json nameWithOwner`), or from the `owner/repo` argument if the user provided one.

```
gh pr diff #N
gh pr view #N --json number,title,author,url
```

**Reconciliation check:** If the `/review` output targeted a specific PR (e.g., "Pull Request: #5"), compare it against the target PR number. If they differ, surface a warning before proceeding:

```
⚠ Review findings are from PR #5, but you're publishing to PR #7. Proceed anyway?
```

This preserves flexibility for intentional cross-posting while preventing accidental mismatch.

Classify each finding into one of three buckets:

| Bucket | Condition | Result |
|---|---|---|
| **Inline** | File is in the diff AND line falls within a hunk | Comment anchored at that line |
| **File-level** | File is in the diff BUT line is outside any hunk | Comment with `subject_type: "file"` |
| **Body-only** | File not in the diff OR no `file:line` reference | Included in the top-level review body |

### Step 3: Check for Existing Feedback

Fetch existing review comments on the PR:

```
gh api repos/{owner}/{repo}/pulls/{N}/comments
```

Build a location index: `file:line → comment[]`. For each finding:

- If the finding's `file:line` matches an existing comment on the same file at the same source line (or within ±3 source lines) **and** the comment content overlaps in topic (similar keywords or issue description), flag it as "already covered". Proximity alone is not sufficient — both location and content must suggest the same issue.
- Record the existing comment's author and a snippet for the confirmation step

**Thread resolution (re-review only):** If Step 1 identified closed prior findings — any disposition other than `Open` — fetch review threads via GraphQL:

```
gh api graphql -f query='query { repository(owner: "{owner}", name: "{repo}") {
  pullRequest(number: N) {
    reviewThreads(first: 50) {
      nodes { id isResolved comments(first: 1) { nodes { body } } }
    }
  }
} }'
```

Match each closed finding to an unresolved thread by comparing the finding description against the thread's first comment body. The match should be based on content similarity (severity tag, key phrases, file reference) — not position alone. Flag matched threads for resolution in Step 5.

Resolve the thread whatever the disposition. A finding the author declined is as closed as one they fixed, and leaving its thread open leaves the PR looking like it still has outstanding work. The disposition and the author's reasoning stay visible in the thread's own comments.

### Step 4: Format Comments

**Inline comment format:**

```
🤖 Claude: **[Severity]** Finding description

_Why it matters:_ Specific risk or consequence.

Suggestion or recommended fix.
```

- Include "Why it matters" for Critical and Major findings only
- Keep each comment self-contained — a reviewer should understand the issue without seeing the full report
- The `🤖 Claude:` prefix is required on every comment and on the review body, per the global `CLAUDE.md` GitHub-identity rule. In unattended mode nobody proofreads the post before it goes out, so this is not optional

**Top-level body format:**

Follow the template defined in `ARTIFACT.md`.

### Step 4a: Determine the Review State

Two states are reachable. `REQUEST_CHANGES` is not one of them, in either mode, for any report — the global `CLAUDE.md` rule has no exception for it.

**`APPROVE`** when every Critical and Major finding on this PR carries a disposition. Count both sources:

- Prior findings, from the Previously Reported table. Anything marked `Fixed`, `Intentional`, `Deferred`, or `Declined` is dispositioned. Anything marked `Open` is not.
- This round's findings, from the report's Critical and Major sections. These are being posted now, so none of them is dispositioned.

The gate reduces to: **no Critical or Major is open.** A round-1 report with no Critical or Major findings passes on its face.

**`COMMENT`** whenever any Critical or Major is open.

Four notes on applying this:

- **Minor findings never count.** Neither do gaps or opportunities. A report with twelve Minors and no open blockers approves.
- **A declined finding closes the gate the same as a fixed one.** The four dispositions are equal by design. The engineer who owns the code owns the call; the review's job was to make sure the call was informed. The approval body names what was declined or deferred so the record shows what shipped knowingly.
- **The gate reads the report as written.** Do not re-grade a finding or re-read a disposition while deciding the state. Both were settled with the code in front of you and no green check riding on the answer.
- **Approving does not mean saying less.** An approving review still posts its full body and every inline comment it has. The state is a signal alongside the report, not a substitute for it.

When the state is `APPROVE` and there are no inline comments to anchor, the review is a body-only approval — post it rather than skipping the review entirely. That case is the happy path for a re-review where everything got answered, and it is what makes the approval visible on the PR.

### Step 5: Present Mapping for Confirmation

**Interactive mode only.** In unattended mode, skip this step entirely and go straight to Step 6 using the defaults in the Modes table.

Present the full plan before posting. Show:

- Each finding with its bucket assignment (inline / file-level / body-only)
- Any findings flagged as already covered, with existing comment details
- Threads to be resolved (re-review only), with the matched finding description
- Counts by bucket
- **The review state from Step 4a, with the disposition tally behind it** — this is the one part to read carefully, since it is the only part of the post that changes the PR's status rather than adding to its conversation

For a state of `APPROVE`:

```
✓ STATE: APPROVE — no open Critical or Major
  Prior:  2 Fixed, 1 Declined ("perf is acceptable here, measured"), 1 Deferred (→ #48)
  New:    0 Critical, 0 Major, 5 Minor
  → Approve / Downgrade to comment?
```

Name every declined and deferred finding explicitly. An approval resting on a decline is the case the user most needs to see before it posts.

For findings flagged as already covered:

```
⚠ ALREADY COVERED:
  [Major] src/service.ts:42 — Missing null check
  Existing comment by @reviewer on line 42: "This needs a null check"
  → Skip (default) / Include anyway?
```

For threads to be resolved (re-review only):

```
✓ RESOLVED (will resolve thread):
  [Major] No guard against PR number mismatch — Fixed in latest push
  Thread: PRRT_kwDO... (comment by @reviewer)
  [Major] Retry loop has no ceiling — Declined ("bounded by the queue TTL upstream")
  Thread: PRRT_kwDO... (comment by @reviewer)
```

Default to skipping flagged findings, but the user can override.

Wait for user confirmation before posting.

### Step 6: Post Review and Resolve Threads

**Post new findings** (if any):

Build the review payload as a JSON object:

- `event`: the state decided in Step 4a — `"COMMENT"` or `"APPROVE"`. Never `REQUEST_CHANGES`.
- `body`: the top-level review body (recommendation + rationale + body-only findings)
- `comments`: array of inline and file-level comment objects — omit or pass `[]` on a body-only approval

Write the payload to `/tmp/pr_review_payload.json` using the Write tool, then post:

```
gh api repos/{owner}/{repo}/pulls/{N}/reviews --input /tmp/pr_review_payload.json
```

**Resolve addressed threads** (re-review only):

For each thread flagged for resolution in Step 3, resolve it via GraphQL:

```
gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { id isResolved } } }'
```

Only resolve threads whose corresponding findings the `/review` output gave a disposition other than `Open`. The Previously Reported table is the authority — do not resolve a thread on your own reading of the conversation.

### Step 7: Report Completion

Report:
- **The review state posted, and the reason for it** — `APPROVE` with the disposition tally behind it, or `COMMENT` with what is still open (e.g. "one open Major: unbounded retry loop"). Never let an approval land without saying so; it changes the PR's status and the user needs to know it happened without opening GitHub.
- **Every declined and deferred finding the approval rests on**, quoted from the author's stated reason. This is the record of what shipped knowingly.
- Counts by bucket (inline / file-level / body-only / skipped)
- Threads resolved (re-review only)
- Review URL from the API response (if a review was posted)

## Edge Cases

**No review in conversation:**
Stop with guidance to run `/review` first. Do not attempt to generate findings.

**All findings outside diff:**
Post a body-only review. Warn in the confirmation step that no inline comments will be anchored to the diff.

**All findings already covered:**
If a blocking finding is still open, report "nothing new to post" and do not create an empty review. If the gate is met, post the body-only `APPROVE` anyway — the approval is the new information even when none of the findings are.

**Re-review with every prior finding dispositioned, nothing new:**
The happy path, and the case the approve gate was built for. Resolve the closed threads, then post a body-only `APPROVE` whose body lists each prior finding and its disposition. Do not skip the review — an approval that never gets posted leaves the PR looking unreviewed, which is the opposite of what the author earned by answering everything.

**Gate met, but the PR has already been approved by this account:**
Post the approval again. GitHub supersedes the earlier one, and a second approval on a later commit is meaningful — the first one covered different code.

**A prior finding's thread was deleted, or its code was deleted outright:**
Treat it as `Fixed` if the code it referenced is gone, and as `Open` if the thread vanished but the code stands. Do not carry a finding forward against code that no longer exists.

**The author disputes a finding and you still think it is right:**
The finding is `Declined` and closes. Say so once in the completion report to the user, who can raise it on the PR in their own voice. Do not re-post it, do not re-word it, and do not hold the state at `COMMENT` over it.

**API 422 errors:**
If the API rejects a comment (e.g., invalid line position), retry with the offending comment moved from inline to file-level, or from file-level to body-only.

**PR has no diff:**
Report and stop — there is nothing to annotate.

## Artifact

The GitHub review object is the artifact. `ARTIFACT.md` documents the body template and inline comment format. Generated when the user confirms and the review is posted.

## Closure Criteria

The publish-review is complete when:

- [ ] Findings have been extracted from the most recent `/review` output, recommendation and Previously Reported dispositions included
- [ ] The PR diff has been fetched and findings mapped to buckets
- [ ] Existing PR comments have been checked for overlap
- [ ] The review state was decided against the Step 4a gate, without re-grading a finding or re-reading a disposition
- [ ] Interactive mode only — the full mapping and the state have been presented and confirmed by the user
- [ ] The review has been posted as a single atomic GitHub review with event type `COMMENT` or `APPROVE`
- [ ] Closed threads have been resolved via GraphQL, whatever their disposition (re-review only)
- [ ] Completion has been reported with the state, its reason, any declines or deferrals it rests on, counts, and review URL

## Notes

- This skill never requests changes — that one stays a human decision, and blocking someone else's work under Will's name is not delegable. It does approve, through the Step 4a gate.
- `COMMENT` is what an open blocking finding produces. `APPROVE` is what a fully dispositioned PR produces. Neither is a judgment call at publish time; both are readings of the report.
- Closed findings are never re-posted. A finding the author answered has left the review's scope permanently, and posting it again is the behavior that turns a review into a loop.
- All comments are posted as a single grouped review — one notification, dismissable as a unit.
- The confirmation gate is mandatory in interactive mode. Never post without user confirmation when invoked directly.
- Unattended mode exists because `/review` is a walk-away command, not because confirmation is optional in general. Do not skip the gate on a direct `/publish-review` invocation just because the user seems in a hurry.
- This skill only publishes findings — it does not generate them. `/review` is the upstream skill.
