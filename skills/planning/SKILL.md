---
name: planning
description: |
  Design and document the implementation approach. Creates a detailed step-by-step plan with phase right-sizing.
  TRIGGER when: the user asks to create an implementation plan ("plan this out", "make a plan", "let's plan", "how should we implement this"), or when a solution direction exists and the user signals readiness to plan.
---

# Planning

Transform a goal or solution direction into a concrete, step-by-step implementation plan.

## Process

### 1. Gather Information

Before writing any plan, understand the work:

- What files/systems will be touched and where they live
- What dependencies exist (internal, external, organizational)
- What constraints apply (timing, scope, approach)
- What testing, documentation, or review processes are needed
- What "done" looks like in concrete terms

Ask clarifying questions. Iterate until you have enough information to write a sound plan.

### 2. Synthesize and Plan

1. Identify the logical phases of work
2. Break each phase into concrete steps
3. Identify blockers, risks, and dependencies
4. Estimate scope (files touched, complexity — not time)

### 3. Right-Size Phases

After drafting the plan, estimate each phase using the `/estimate` LOE framework. **Decompose any phase scoring LOE > 2** into subphases, then re-estimate. Repeat until every phase scores <= 2.

This prevents oversized phases that are hard to implement atomically and surfaces hidden complexity early.

### 4. Present the Plan

Save the plan to `docs/plans/<work-item>.plan.md` at the nearest project root.

The plan uses a **Phase > Step > Task** breakdown:

```
# <Title>

## Overview
## Notes
## Progress
- [ ] Phase N: <name>

---

## Phase N: <name>
### Step N.N: <name>
#### Task N.N.N: <description>
```

The **Progress** section uses checkbox syntax (`- [ ]` / `- [x]`). Planning creates it with all phases unchecked — `/produce` owns updating it at phase boundaries.

The plan must include:

- **Overview**: High-level summary of what will be built
- **Notes**: Out of scope items, key decisions, design rationale
- **Progress**: Checkbox list of all phases
- **Phases**: Logical groupings of work with steps and tasks
- **Critical Files**: Which files will be created, modified, or removed
- **Gotchas & Risks**: Potential problems and how to mitigate them
- **Success Criteria**: How you'll know the plan is complete

## Key Principles

- **Information comes first** — Don't guess. Ask until you understand.
- **No implementation yet** — Describe *what* and *why*, not the code.
- **Identify critical paths** — Make dependencies and ordering explicit.
- **Surface assumptions** — Call out assumptions so they can be validated.
- **Scope clarity** — Be explicit about what's included and what's not.
- **The plan is project-local** — Save to `docs/plans/<work-item>.plan.md`, never to tool-specific directories.

## Artifact

Produces `<work-item>.plan.md` in `docs/plans/`.
