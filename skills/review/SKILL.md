---
name: review
description: |
  Technical peer review of code changes — local diff or a specific pull request. Covers security, architecture, correctness, tests, and accessibility. Reports Critical, Major, and Minor findings with a go/no-go recommendation, then publishes to the PR when one exists. Re-reviews scope to what changed since the last round and reconcile prior findings against the author's response. `/review full` adds Gaps and Opportunities; `/review local` keeps the report inline.
  TRIGGER when: the user asks for a code review ("review this", "review the PR", "review my changes", "can you look over this", "code review"), or references a PR that needs review ("what do you think of PR #N", "check PR #N").
---

# Review: Technical Code Review

This skill conducts a technical peer review of a set of code changes — either against a pull request or against local changes on the current branch. It produces a structured, severity-graded report with a clear go/no-go recommendation.

## Invocation

- **`/review`** — Review local changes (current branch diff against the base branch). Use after `/produce` to verify the result before opening a PR.
- **`/review #N`** — Review pull request #N in the current repo.
- **`/review #N owner/repo`** — Review pull request #N in a different repo.

Two optional keywords modify the run. Both are positional and may appear in any order alongside the target (`/review full #12`, `/review #12 local`, `/review local full`):

- **`full`** — Report all sections, including Minor, Gaps & Inconsistencies, and Opportunities.
- **`local`** — Keep the report inline in the conversation. Never publish to GitHub.

## Modes

Two independent axes. Parse them separately.

### Report scope — what reaches the page

**Default: Critical, Major, and Minor.** The report is Summary → Previously Reported → Critical → Major → Minor → Recommendation.

Report everything you find, ordered by severity. Severity is a **priority signal for the author**, not a filter on what gets said — it tells them what to read first and what has to be dealt with before merge. Withholding a real finding to shorten the report just moves the work to a later round.

Genuine gaps get graded, not bucketed separately. Missing test coverage on changed behavior is already defined as Major (see Severity Definitions) — it belongs in **Major**.

**`full`** adds **Gaps & Inconsistencies** and **Opportunities** on top of the default sections.

Only Critical and Major findings gate an approval (see **Review State**). Minor findings publish so the author can pick them up, and never hold up a merge.

### Delivery — where the report goes

**Default: publish when a pull request exists.**

- **`/review #N`** — After presenting the report inline, hand off to `/publish-review #N` to post the findings to the PR.
- **`/review` (no target)** — After presenting the report inline, check whether the current branch has an open PR:
  ```
  gh pr view --json number,url
  ```
  If a PR exists, hand off to `/publish-review` with that number. If the command fails or reports no PR, the review stays inline — say so in one line (`No open PR for this branch — review is inline only.`) and stop. Do not offer to open one; `/pull-request` owns that.
- **`local`** — Skip the delivery step entirely, whatever the target. `/review local #12` reviews PR #12 and reports inline without posting.

**The handoff is unattended.** `/review` is a send-it-and-walk-away command. Invoke `/publish-review` in its unattended mode: it skips the confirmation gate and posts directly. Do not ask whether to publish, do not ask which findings to include, do not present the mapping for approval. The user invoked `/review #N` expecting to come back to a review sitting on the PR.

This is safe by construction, not by supervision:

- The review event is `COMMENT` while any blocking finding is open, and `APPROVE` once they are all dispositioned — never `REQUEST_CHANGES`, which has no exception. See **Review State** below for the gate.
- Findings already covered by an existing comment are skipped, which is the documented default anyway.
- PR review comments are deletable and resolvable, and an approval is superseded by the next review and dismissed by the next push, so a bad post is recoverable either way.

Every ambiguity that would have been a question becomes a documented default — see `/publish-review` → Unattended Mode. If a situation arises that has no safe default, stop and report rather than guess; do not post a partial review.

`local` is the escape hatch. If the user wants to read findings before anything reaches GitHub, that is what `/review local #N` is for.

### Review State — comment or approve

**Approve when every Critical and Major finding on the PR carries a disposition.** That is the whole gate. It covers findings from prior rounds and the findings this round is about to post — a finding raised in this review has no disposition yet by definition, so any new Critical or Major means `COMMENT`.

A first review that turns up no Critical or Major findings clears the gate on its face and approves.

Minor findings never count. Neither do gaps or opportunities. They publish, the author picks them up or doesn't, and the merge is not held for them.

#### Dispositions

A finding closes when the author deals with it. Four ways, all equal, all permanent:

| Disposition | Signal |
|---|---|
| **Fixed** | The code at the finding's location changed and the change addresses it. Verify by reading the current code — an author claim of "fixed" with no matching change is not fixed. |
| **Intentional** | Author reply explaining why the code is the way it is. |
| **Deferred** | Author reply pointing the work at another PR, issue, or follow-up fix. |
| **Declined** | Author reply saying they are not doing it. |

Anything else leaves the finding **open**: no reply and no change, or a reply that asks a question rather than answering one. An author question is not a disposition — answer it in this round's report and leave the finding open.

**A closed finding is closed for good.** It does not appear in a later report, it does not get re-raised in different words, and it does not block the approval. Disagreeing with a decline is not grounds for raising it again — say so once to the user and leave it on the PR.

#### Grading honesty

Grade the code, then read the gate. Two pressures push the other way and both are worth naming: a Major downgraded to Minor buys a green check, and a finding raised late buys another round. Neither is a reason to move a severity. The gate is worth having only if the report feeding it is the report you would have written with no gate attached.

This gate applies in both delivery modes. A `/review #N` that clears it approves unattended; `local` posts nothing at all, state included.

## Goal

Provide an honest technical peer assessment of the changes, surfacing problems and opportunities so the author can make an informed decision about whether the code is ready to merge.

## Scope

### In Scope — Technical Best Practices

- **Security** — vulnerabilities, exposed secrets, insecure data handling, auth/permissions issues
- **Architecture** — consistency with existing design patterns, coupling, boundaries, structural fit with the codebase
- **Correctness** — logic errors, edge cases, off-by-ones, incorrect assumptions
- **Tests** — coverage gaps on critical paths, test quality, missing edge case coverage
- **Accessibility** — any change to an HTML, JSX, or TSX file; JS/TS files that produce UI (infer contextually from imports, exports, and rendering patterns)

### Out of Scope

- **Business/functional correctness** — whether the feature does what the product requires (author's responsibility)
- **UX behavior** — visual design, interaction patterns, responsiveness (reviewer's manual responsibility)

## Context

This is a **peer review between equals**. Treat the PR author as a fellow contributor regardless of whether they are a colleague or the person who invoked this skill. Do not suppress findings because the author has already acknowledged a tradeoff — if it is worth saying, say it. The PR description provides context to inform your findings, not to silence them.

## Depth

**Default: quick pass.** Scan all changes, identify the landscape of issues, then drill into anything that warrants closer inspection.

If the user specifies depth in the invocation (e.g., "thorough review of PR #3"), adjust accordingly.

Depth is independent of report scope. `full` widens what gets reported, not how hard you look — a default-scope review is just as thorough, it simply prints less. "Thorough" widens how hard you look and can apply to either scope.

## Workflow

### Step 1: Fetch the Changes

**For a PR (`/review #N`):**
- Use `gh pr view #N --json title,body,author,baseRefName,headRefName,headRefOid` to get PR metadata
- Use `gh pr diff #N` to get the full diff
- Read the PR description for documented context, known tradeoffs, and intent

**For local changes (`/review`):**
- Use `git diff $(git merge-base HEAD origin/HEAD) HEAD` to get all changes on the current branch
- If the base branch is unclear, use `git diff main...HEAD` or `git diff master...HEAD`

### Step 2: Check for Prior Rounds

**PR targets only.** Local reviews have no prior state — skip to Step 3.

Fetch every review already posted on this PR by the authenticated account (`gh api user --jq .login`):

```
gh api repos/{owner}/{repo}/pulls/{N}/reviews
gh api repos/{owner}/{repo}/pulls/{N}/comments
```

If none are by this account, this is **round 1**: review the full diff and skip the rest of this step.

Otherwise this is a **re-review**. Two things follow.

#### Scope to the delta

The most recent prior review's `commit_id` is the anchor. Everything up to that SHA has already been reviewed at full depth, and its findings are already on the PR carrying whatever disposition they have. Review the delta only:

```
gh api repos/{owner}/{repo}/compare/{anchor_sha}...{head_sha}
```

Treat those files and hunks as the change under review for Steps 3 and 4, at full depth across every in-scope dimension. Code that has not moved since the anchor is out of scope — do not re-scan it and do not raise new findings against it.

If the compare call fails because the anchor is unreachable (force-push, rebase, squash), fall back to the full diff and say so in one line at the top of the report: `Prior review anchor unreachable after a force-push — this round re-reviewed the full diff.`

#### Reconcile prior findings

Prior findings are the inline comments and review bodies posted by this account, stamped `🤖 Claude: **[Severity]**`. For each one, determine its disposition per the table in **Review State**:

```
gh api graphql -f query='query { repository(owner: "{owner}", name: "{repo}") {
  pullRequest(number: N) {
    reviewThreads(first: 100) {
      nodes { id isResolved isOutdated
        comments(first: 20) { nodes { author { login } body } } }
    }
  }
} }'
```

- A reply from anyone other than the reviewer account is a disposition — read it and classify as Intentional, Deferred, or Declined. Be generous: any substantive response counts. Nobody should have to argue with a bot to close an item.
- A resolved thread is a disposition even with no reply.
- For a finding with no reply, read the current code at that location. Changed and addressed → **Fixed**. Unchanged → **open**.
- A reply that asks a question is not a disposition. Answer it in this round's report and leave the finding open.

Findings that resolve to any disposition are reported in **Previously Reported** with that disposition and then dropped from the active sections — they are closed permanently. Open findings carry forward into this round's Critical/Major/Minor sections at their original severity, restated verbatim rather than reworded.

Body-only findings from a prior round have no thread to reply to, so they can only be dispositioned by a code change. If one is still open, anchor it inline this round if the delta makes that possible, so the author has somewhere to answer.

### Step 3: Understand the Change

Before evaluating, orient yourself:
- What is the purpose of this change? (from PR title, description, or commit messages)
- What parts of the codebase are touched?
- Are there documented tradeoffs or known limitations in the PR description?
- What is the scope — small patch, large feature, refactor?

Use local codebase knowledge to understand context: existing patterns, surrounding code, architectural conventions.

### Step 4: Conduct the Review

Work through each in-scope dimension for every changed file — on a re-review, "changed" means the delta scoped in Step 2:

#### Security
- Unsanitized inputs, SQL injection, XSS vectors
- Hardcoded secrets or credentials
- Auth checks missing or bypassable
- Sensitive data exposed in logs, errors, or responses

#### Architecture
- Does this fit the existing pattern for this type of change?
- New abstractions that duplicate existing ones
- Coupling between modules that should be independent
- Boundary violations (e.g., UI logic in a service layer)

#### Correctness
- Logic that doesn't handle the described intent correctly
- Edge cases not covered (null, empty, boundary values, concurrent access)
- Incorrect assumptions about external behavior (APIs, libraries, browser APIs)

#### Tests
- Are the changed paths covered by tests?
- Are new behaviors tested?
- Are tests testing behavior or implementation details?
- Are edge cases represented in tests?

#### Accessibility
Applies to any HTML, JSX, TSX file, and JS/TS files that render UI:
- Interactive elements missing keyboard access or focus management
- Images missing alt text
- Form inputs missing labels
- Color contrast or reliance on color alone to convey meaning
- ARIA roles or attributes misused or missing
- Screen reader announcements for dynamic content

### Step 5: Produce the Report

#### Report Format

**Pull Request:** [title and number or "Local changes on [branch]"]
**Author:** [name or "you"]
**Round:** [1, or "N — reviewing {anchor_sha}..{head_sha}"]
**Summary:** [1–3 sentence plain-language description of what this change does]

---

> **Formatting note:** Within each section below, number top-level issues with explicit sequential numbers (`1.`, `2.`, `3.`, …) rather than relying on markdown auto-numbering — the output may be rendered in a TUI that doesn't auto-number. Sub-bullets (Where / Why it matters / Suggestion) stay as indented bullets.

**Previously Reported**
> Re-review only. Findings from earlier rounds and what became of them. Omit this section entirely on round 1.

| # | Severity | Finding | Disposition | Detail |
|---|---|---|---|---|
| 1 | Critical | [short description] | Fixed | [what changed, file:line] |
| 2 | Major | [short description] | Declined | [author's stated reason] |
| 3 | Major | [short description] | **Open** | [no response; carried forward as Major #1 below] |

Every prior Critical and Major appears here with exactly one disposition. Dispositioned findings are closed and are not repeated below. Open ones carry forward into the sections below at their original severity.

---

**Critical Issues**
> Must be resolved before merge. These are blockers.

1. [Issue description]
   - **Where:** [file:line or area of the diff]
   - **Why it matters:** [specific risk or consequence]
   - **Suggestion:** [recommended fix or direction]
2. [Next issue description]
   - **Where:** …
   - **Why it matters:** …
   - **Suggestion:** …

*(If none: "None found.")*

---

**Major Issues**
> Significant problems that should be resolved. May be blocking depending on risk tolerance.

1. [Issue description]
   - **Where:** [file:line or area of the diff]
   - **Why it matters:** [specific risk or consequence]
   - **Suggestion:** [recommended fix or direction]
2. [Next issue description]
   - **Where:** …
   - **Why it matters:** …
   - **Suggestion:** …

*(If none: "None found.")*

---

**Minor Issues**
> Non-blocking. Worth addressing but won't hold up a merge, and never gates the approval.

1. [Issue description]
   - **Where:** [file:line or area of the diff]
   - **Suggestion:** [recommended improvement]
2. [Next issue description]
   - **Where:** …
   - **Suggestion:** …

*(If none: "None found.")*

---

#### Full Scope Only

The two sections below are included **only** when the invocation carries `full`. In default scope, omit them entirely — no headings, no "None found" placeholders.

**Gaps & Inconsistencies**
> Missing tests, undocumented behavior, pattern divergence, or things that don't quite add up.

1. [Gap description]
   - **Where:** [location]
   - **Detail:** [what's missing or inconsistent]
2. [Next gap description]
   - **Where:** …
   - **Detail:** …

*(If none: "None found.")*

---

**Opportunities**
> Improvements that go beyond the current change but are worth noting.

1. [Opportunity description]
2. [Next opportunity description]

*(If none: "None identified.")*

---

#### Always Included

**Recommendation**

**Go** / **No-Go** / **Go with conditions**

[1–3 sentence rationale. For "Go with conditions," list what must be addressed before merge.]

The recommendation follows the disposition state and does not contradict it. Every Critical and Major dispositioned → **Go**. Anything open → name what is open. An approval rides on the gate in **Review State**, so the recommendation is a summary for the author rather than a second, independent verdict.

---

### Step 6: Deliver

Follow the delivery rules in **Modes → Delivery** above.

- `local` in the invocation, or no open PR for the target → stop here. The inline report is the deliverable.
- Otherwise → invoke `/publish-review #N` in unattended mode. Post without confirmation.

Do not re-derive or re-summarize the findings for the handoff. `/publish-review` reads the report out of conversation context (its Step 1), so the inline report above is the input it consumes — including the **Previously Reported** table, which is what drives thread resolution and the state gate.

Close by reporting what was posted — counts by bucket, the review state (`COMMENT` or `APPROVE`) and why that state was chosen, and the review URL — so the outcome is visible on return and an approval is never a silent side effect.

## Severity Definitions

**Critical:**
- Security vulnerabilities (injection, auth bypass, exposed secrets)
- Correctness bugs that will cause data loss, corruption, or incorrect behavior in production
- Accessibility failures that prevent users from completing core tasks

**Major:**
- Logic errors in non-critical paths
- Missing test coverage on changed behavior
- Architectural violations that create meaningful technical debt
- Accessibility issues that significantly degrade the experience

**Minor:**
- Code style inconsistencies
- Improvements to clarity or naming
- Non-critical test gaps
- Small accessibility polish items

## Artifact

Presents the review report inline (not written to a file). See `ARTIFACT.md` for the full template and the default-scope variant. Produced when the review pass is complete.

When delivery is in play, the GitHub review object is a second artifact — owned and documented by `/publish-review`.

## Closure Criteria

The review is complete when:

- [ ] Prior rounds have been checked; a re-review is scoped to the delta and every prior Critical and Major has exactly one disposition
- [ ] All in-scope changed files have been evaluated against the in-scope dimensions
- [ ] Findings are categorized by severity
- [ ] Every finding includes location, impact, and a suggestion
- [ ] A go/no-go recommendation is stated with reasoning, consistent with the disposition state
- [ ] `full` only — gaps and opportunities are documented
- [ ] Delivery is resolved: handed off to `/publish-review`, or explicitly reported as inline-only
- [ ] The review state was determined by the disposition gate and reported with its reason

## Notes

- You are a peer, not an authority. Be direct and honest, not deferential.
- If the PR description documents a known tradeoff, acknowledge it in your finding — but still surface it.
- "Quick pass" means broad coverage at appropriate depth, not skipping dimensions. If something looks fine, say so briefly and move on.
- If a finding needs deeper investigation, do it. The default depth is a starting point, not a ceiling.
- Drill into any finding that warrants it before closing the report.
- Report everything you find at its honest severity. Severity ranks the author's work queue; it is not a filter on what gets said.
- The approve gate is a reason not to shade a severity: a downgraded Major buys a green check. Grade the code, not the outcome.
- Each line of code is reviewed once. A re-review that re-scans settled code produces a different slice of findings every round and gives the author no path to done — that is the failure this skill is built to avoid.
- The author closes findings, and a closed finding stays closed. If you disagree with a decline, say so once to the user and leave the PR alone.
- Never post to GitHub from this skill directly. Delivery goes through `/publish-review` so the state gate, the confirmation gate, and the never-request-changes rule are enforced in one place.
