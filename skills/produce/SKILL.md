---
name: produce
description: |
  Execute the implementation plan autonomously with a build team, a review team, and intelligent atomic commits. Orchestrates implementation → review → revision → pull request without pausing for the user.
  TRIGGER when: a plan exists and the user wants autonomous execution ("produce this", "build it", "execute the plan", "go ahead and implement", "run produce", "start building", "implement the plan"), or when the user signals they want the agent to take over implementation without step-by-step pairing.
---

# Produce: Orchestrated Implementation to Pull Request

Execute the implementation plan end to end. The invoked agent acts as **orchestrator**: it delegates implementation to a build team, delegates review to an independent review team, routes findings back to the builders who wrote the code, and opens the pull request once the work has settled.

## Goal

Take a committed plan from unstarted to a pull request awaiting human review, managing:

- **Delegation** — which work goes to which agent, and what each one is told
- **Work order** — which units execute, in what order, and what may run concurrently
- **Commit strategy** — atomic, semantically coherent commits owned solely by the orchestrator
- **Quality gate** — an independent review pass and a bounded revision cycle before delivery

The user's next interaction should be reading a pull request, not answering a question.

## Orchestration Model

### Roles

| Role | Who | Responsibility |
|---|---|---|
| **Orchestrator** | The agent that received `/produce` | Reads the plan, delegates, owns all git operations, opens the PR |
| **Build team** | Named subagents, one per concurrent unit | Write code. Never commit, never push |
| **Review team** | Independent subagents, one per review dimension | Find problems in what the build team produced. Never write code |

The build and review teams must be **separate agents**. An agent that reviews its own work grades its own homework — the independence is the point of running a second team rather than asking the builders to double-check.

### The orchestrator owns git

**Build agents never run `git add`, `git commit`, `git push`, or `/commit`.** They write files and report what they changed. The orchestrator stages and commits.

This is non-negotiable for two reasons:

1. **The index is shared mutable state.** Concurrent `git add` from several agents races — one agent stages another's half-written work, and the resulting commits are neither atomic nor coherent.
2. **The git history is the primary deliverable** (see Commit Semantics below). Semantic grouping is a whole-picture judgment. An agent that sees only its own slice cannot make it.

Build agents report changed paths and a one-line description of the unit. The orchestrator decides what that means for commit boundaries.

### When to fan out

Fanning out costs real tokens and setup latency. Match the shape of the team to the shape of the plan.

| Plan shape | Approach |
|---|---|
| Single phase, few files, LOE 1–2 | **Run inline.** No build team. The orchestrator implements directly, exactly as this skill worked before. |
| Multiple phases, or a phase with independent steps | Fan out **within** each phase, one agent per independent step |
| Any plan reaching the review stage | Always fan out the review team — independence is the value |

Do not spawn a build team to write three lines in one file. State the choice in one line (`Plan is single-phase and touches 2 files — implementing inline.`) and proceed.

### Concurrency rule: disjoint files only

Two build agents may run concurrently **only if their file sets do not intersect.** Derive each step's file set from the plan before delegating.

- **Disjoint** → run concurrently in a single message with multiple `Agent` calls.
- **Overlapping** → run sequentially, in dependency order, one agent at a time.
- **Overlapping and genuinely independent** → still sequential. Do not reach for `isolation: "worktree"`; merging divergent worktrees back together is a harder problem than waiting.

Phases are always sequential — a later phase may depend on an earlier phase's output. This replaces the previous blanket "never simultaneously" rule with a narrower one that protects the same thing: never let two writers touch one file.

### Name every agent

Spawn build agents with an explicit `name` (`build-auth`, `build-migrations`, `build-ui`). Names make them addressable via `SendMessage`, which is what makes Stage 3 possible — a named agent still holds the context of why it wrote the code that way. A fresh `Agent` call does not.

Keep a roster mapping each build agent's name to the files it owns. Stage 3 depends on it.

## Stage 0: Plan Analysis

Before delegating anything:

- Read the full plan file
- Identify phase dependencies and execution order
- For each phase, determine which steps are independent and what files each touches
- Decide inline vs. fan-out per the table above
- Confirm the working tree is clean; if not, stop and report rather than commingling unrelated changes

## Stage 1: Build

For each phase, in order:

1. Determine the phase's independent steps and their file sets.
2. Spawn one named build agent per step, concurrently where file sets are disjoint.
3. Each build agent's brief must contain:
   - The specific plan steps and tasks it owns, quoted from the plan
   - The exact files it is permitted to modify, and an instruction to touch nothing else
   - Relevant codebase conventions and patterns to follow
   - **An explicit instruction not to commit, stage, or push** — it reports changed paths instead
   - An instruction to report blockers rather than inventing scope
4. Wait for the phase's agents to finish.
5. Review the reported changes as a whole, group them semantically, and commit via `/commit`.
6. Update the plan file's Progress section and commit that separately as a `[plan]` commit.

Every phase completes — code committed, plan updated — before the next begins.

## Stage 2: Review

Once all phases are built and committed, spawn the review team against the accumulated branch diff.

Fan out one reviewer per `/review` dimension, concurrently — they only read, so there is no write conflict:

- Security
- Architecture
- Correctness
- Tests
- Accessibility (skip when the diff touches no UI-producing files)

Each reviewer invokes **`/review local`**. The `local` keyword is mandatory here: no pull request exists yet, and review findings must not reach GitHub mid-flight. The orchestrator opens the PR later, in Stage 4, once the code has settled.

Collect the reviewers' reports and merge them:

- Deduplicate findings that several reviewers raised about the same `file:line`
- Keep the highest severity assigned to any duplicate
- Discard findings about code the plan did not touch — note them in the summary as out-of-scope observations rather than acting on them

Only **Critical** and **Major** findings enter Stage 3. Minor findings go in the final summary for the user to judge.

## Stage 3: Revise

Route each Critical and Major finding back to the build agent that owns the file, using `SendMessage` with that agent's name. It still holds the context of the original decision, which a fresh agent would have to reconstruct — and often reconstructs wrongly.

- Finding in a file with a known owner → `SendMessage` to that owner
- Finding spanning several owners → send to the owner of the file where the fix belongs, and tell it which other agents' code is involved
- Finding in a file with no owner (inline-built work) → the orchestrator fixes it directly

Revisions follow the same rules as the build stage: agents edit, the orchestrator commits. Group revision commits semantically like any other.

### Bounded loop

After revisions land, re-run the review team against the updated diff.

**Cap the cycle at two revision rounds.** If Critical or Major findings survive two full rounds, stop revising and carry them into the PR description under a "Known issues" heading. An unbounded review–revise loop can oscillate — two agents disagreeing about the right fix will happily trade edits until the budget is gone.

Proceed to Stage 4 when either no Critical or Major findings remain, or the cap is reached.

## Stage 4: Deliver

**The pull request is this skill's artifact.** `/produce` has no `ARTIFACT.md` of its own by design — `/pull-request` owns the PR format, and duplicating it here would create two specs to keep in sync. The commits along the way are intermediate state; the PR is what the user comes back to.

The orchestrator opens it itself — do not delegate this.

1. Confirm the working tree is clean and all work is committed
2. Invoke `/pull-request`, which supplies the description structure
3. Fold the review cycle into that structure: what was found and fixed belongs in the Summary bullets, and any surviving Critical or Major findings go under a `## Known issues` section

Note the interaction with `/review`: once the PR exists, a later `/review #N` will post its findings to it unattended. That is the intended follow-up, not part of this skill. `/produce` finishes at an open PR with no review posted on it.

## Commit Semantics

These rules govern the orchestrator's commits at every stage.

### Core principle: semantic coherence

Each commit should represent a **logically coherent unit of work**. Files changed in a commit should be related by:

- **Feature/domain**: All parts of a User feature together, all parts of an Order feature separately
- **Concern/layer**: All API changes together, all UI changes together, all migrations together
- **Functional completeness**: Changes that must work together to provide a feature

Agent boundaries are not commit boundaries. If two build agents each produced half of one coherent feature, that is one commit. If one agent produced two unrelated concerns, that is two.

### Commit grouping examples

**Good** — cohesive units:
- Login screen + login API route + session migration = **1 commit** (one feature end-to-end)
- All database migrations for a release = **1 commit** (single infrastructure concern)
- All UI component updates = **1 commit** (single layer)

**Bad** — unrelated domains mixed:
- Order UI change + User API change = **do not combine**
- User authentication + unrelated table cleanup = **do not combine**

### Atomicity rules

- **One logical concern per commit**: Changes are all related by domain, layer, or feature
- **Commit when a unit is complete**: After a phase or revision produces a coherent unit
- **Don't batch unrelated changes**: Work sitting in the working directory does not thereby belong together
- **Preserve logical narrative**: Someone reading the commits should understand the progression of work

**Commit if** the unit is complete, the files share a domain/feature/concern, and the code works.
**Don't commit if** the unit is incomplete, the changes span unrelated concerns, or a dependency is still uncommitted.

After staging files, **invoke the `/commit` skill**. Never run `git commit` directly. The orchestrator decides **when** to commit and **what to stage**; `/commit` handles type classification, message formatting, and the commit itself.

### Phase-boundary progress tracking

After each plan phase:

1. Mark the phase row complete: `- [x] Phase N: <name>`
2. Add a brief inline deviation note if the phase diverged from the plan
3. Invoke `/commit` for the plan file update before starting the next phase

This produces code commits for the implementation followed by a `[plan]` commit marking the phase complete, repeated per phase.

## Deviation Handling

- **A build agent reports a blocker** — do not silently reassign. Note it, skip that unit, continue with the others, and surface it in the final summary and the PR description.
- **A build agent exceeds its file scope** — treat the extra changes as suspect. Review them directly before committing, or revert them and re-delegate with a tighter brief.
- **A build agent returns null or dies** — its work is lost, not partially applied. Re-delegate the same brief once; if it fails again, implement that unit inline.
- **Plan deviation** — document it and explain the reasoning in the final summary.
- **Ambiguous grouping** — choose the most logical grouping and note the decision.

## Completion

When the PR is open, summarize:

- The commits made, grouped by concern/domain
- Which agents built what
- What the review team found, by severity, and what was fixed
- Any surviving Critical/Major findings and why they were not resolved
- Minor findings, for the user to triage
- Any plan deviations
- The PR URL

## Notes

- This is autopilot mode. The orchestrator has full autonomy over delegation, work order, and commits, and should not stop to ask the user between stages.
- Autonomy is not silence. Report stage transitions as they happen so a returning user can see where things stand.
- The git history is the primary deliverable — it should be clean and navigable regardless of how many agents contributed to it.
- Build and review teams stay separate. Never ask a build agent to review its own output.
- Semantic coherence matters more than batch size; a 5-file commit is fine if the files are related.
- Nothing posts to GitHub before Stage 4. Reviewers use `/review local`, and the PR is the first outward-facing artifact.
