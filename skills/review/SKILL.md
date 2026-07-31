---
name: review
description: |
  Technical peer review of code changes — local diff or a specific pull request. Covers security, architecture, correctness, tests, and accessibility. Reports Critical and Major findings with a go/no-go recommendation, then publishes to the PR when one exists. `/review full` adds Minor, Gaps, and Opportunities; `/review local` keeps the report inline.
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

**Default: Critical and Major only.** The report is Summary → Critical → Major → Recommendation. Minor findings, Gaps & Inconsistencies, and Opportunities are omitted.

This is a **reporting** filter, not an **analysis** filter. Still evaluate every in-scope dimension across every changed file — severity grading is only meaningful if everything was looked at, and a finding that appears cosmetic on first read is often Major once traced. Suppress at the point of writing, not the point of looking.

Genuine gaps do not vanish, they get graded. Missing test coverage on changed behavior is already defined as Major (see Severity Definitions) — it belongs in **Major**, not in a separate bucket. A gap that grades below Major is omitted along with the other Minor findings.

**`full`** restores all sections, matching the historical output.

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

- The review event is always `COMMENT` — never approve or request-changes. The `block-pr-review-state.sh` hook enforces this independently.
- Findings already covered by an existing comment are skipped, which is the documented default anyway.
- PR review comments are deletable and resolvable, so a bad post is recoverable.

Every ambiguity that would have been a question becomes a documented default — see `/publish-review` → Unattended Mode. If a situation arises that has no safe default, stop and report rather than guess; do not post a partial review.

`local` is the escape hatch. If the user wants to read findings before anything reaches GitHub, that is what `/review local #N` is for.

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
- Use `gh pr view #N --json title,body,author,baseRefName,headRefName` to get PR metadata
- Use `gh pr diff #N` to get the full diff
- Read the PR description for documented context, known tradeoffs, and intent

**For local changes (`/review`):**
- Use `git diff $(git merge-base HEAD origin/HEAD) HEAD` to get all changes on the current branch
- If the base branch is unclear, use `git diff main...HEAD` or `git diff master...HEAD`

### Step 2: Understand the Change

Before evaluating, orient yourself:
- What is the purpose of this change? (from PR title, description, or commit messages)
- What parts of the codebase are touched?
- Are there documented tradeoffs or known limitations in the PR description?
- What is the scope — small patch, large feature, refactor?

Use local codebase knowledge to understand context: existing patterns, surrounding code, architectural conventions.

### Step 3: Conduct the Review

Work through each in-scope dimension for every changed file:

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

### Step 4: Produce the Report

#### Report Format

**Pull Request:** [title and number or "Local changes on [branch]"]
**Author:** [name or "you"]
**Summary:** [1–3 sentence plain-language description of what this change does]

---

> **Formatting note:** Within each section below, number top-level issues with explicit sequential numbers (`1.`, `2.`, `3.`, …) rather than relying on markdown auto-numbering — the output may be rendered in a TUI that doesn't auto-number. Sub-bullets (Where / Why it matters / Suggestion) stay as indented bullets.

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

#### Full Scope Only

The three sections below are included **only** when the invocation carries `full`. In default scope, omit them entirely — no headings, no "None found" placeholders.

**Minor Issues**
> Non-blocking. Worth addressing but won't hold up a merge.

1. [Issue description]
   - **Where:** [file:line or area of the diff]
   - **Suggestion:** [recommended improvement]
2. [Next issue description]
   - **Where:** …
   - **Suggestion:** …

*(If none: "None found.")*

---

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

---

### Step 5: Deliver

Follow the delivery rules in **Modes → Delivery** above.

- `local` in the invocation, or no open PR for the target → stop here. The inline report is the deliverable.
- Otherwise → invoke `/publish-review #N` in unattended mode. Post without confirmation.

Do not re-derive or re-summarize the findings for the handoff. `/publish-review` reads the report out of conversation context (its Step 1), so the inline report above is the input it consumes.

Close by reporting what was posted — counts by bucket and the review URL — so the outcome is visible on return.

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

- [ ] All changed files have been evaluated against the in-scope dimensions
- [ ] Findings are categorized by severity
- [ ] Every finding includes location, impact, and a suggestion
- [ ] A go/no-go recommendation is stated with reasoning
- [ ] `full` only — gaps and opportunities are documented
- [ ] Delivery is resolved: handed off to `/publish-review`, or explicitly reported as inline-only

## Notes

- You are a peer, not an authority. Be direct and honest, not deferential.
- If the PR description documents a known tradeoff, acknowledge it in your finding — but still surface it.
- "Quick pass" means broad coverage at appropriate depth, not skipping dimensions. If something looks fine, say so briefly and move on.
- If a finding needs deeper investigation, do it. The default depth is a starting point, not a ceiling.
- Drill into any finding that warrants it before closing the report.
- Default scope hides Minor findings; it does not license grading a Major down to Minor to shorten the report. Grade honestly, then filter.
- Never post to GitHub from this skill directly. Delivery goes through `/publish-review` so the confirmation gate and comment-mode-only rule are enforced in one place.
