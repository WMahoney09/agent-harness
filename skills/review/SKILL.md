---
name: review
description: |
  Technical peer review of code changes — local diff or a specific pull request. Covers security, architecture, correctness, tests, and accessibility. Produces a severity-graded report with a go/no-go recommendation.
  TRIGGER when: the user asks for a code review ("review this", "review the PR", "review my changes", "can you look over this", "code review"), or references a PR that needs review ("what do you think of PR #N", "check PR #N").
---

# Review: Technical Code Review

This skill conducts a technical peer review of a set of code changes — either against a pull request or against local changes on the current branch. It produces a structured, severity-graded report with a clear go/no-go recommendation.

## Invocation

- **`/review`** — Review local changes (current branch diff against the base branch). Use after `/produce` to verify the result before opening a PR.
- **`/review #N`** — Review pull request #N in the current repo.
- **`/review #N owner/repo`** — Review pull request #N in a different repo.

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

**Recommendation**

**Go** / **No-Go** / **Go with conditions**

[1–3 sentence rationale. For "Go with conditions," list what must be addressed before merge.]

---

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

Presents the review report inline (not written to a file). See `ARTIFACT.md` for the full template. Produced when the review pass is complete.

## Closure Criteria

The review is complete when:

- [ ] All changed files have been evaluated against the in-scope dimensions
- [ ] Findings are categorized by severity
- [ ] Every finding includes location, impact, and a suggestion
- [ ] Gaps and opportunities are documented
- [ ] A go/no-go recommendation is stated with reasoning

## Notes

- You are a peer, not an authority. Be direct and honest, not deferential.
- If the PR description documents a known tradeoff, acknowledge it in your finding — but still surface it.
- "Quick pass" means broad coverage at appropriate depth, not skipping dimensions. If something looks fine, say so briefly and move on.
- If a finding needs deeper investigation, do it. The default depth is a starting point, not a ceiling.
- Drill into any finding that warrants it before closing the report.
