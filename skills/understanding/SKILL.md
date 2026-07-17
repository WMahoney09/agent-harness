---
name: understanding
description: |
  Build shared understanding of a problem through discovery. Use when starting new work to clarify what's being solved, why it matters, and what constraints exist.
  TRIGGER when: the user describes a problem they want solved and it implies new work (e.g., "X doesn't work, I want it to work", "I need to add Y", "we should fix Z"), the user mentions a new workstream, or references /understanding conversationally ("our shared understanding", "build understanding").
---

# Understanding: Problem Discovery

This skill guides you through building a shared understanding of the problem before exploring solutions.

## Goal

Develop a complete, mutual understanding of:
- What problem is being solved
- Why it matters
- What constraints or context exist
- What success looks like
- What's already been tried or considered

## Project Context

If the project has a `docs/reference/` directory, consult it for existing context — architecture decisions, ontology, topology, or other reference material that informs the problem space.

## Key Questions to Explore

**The Problem:**
- What exactly is the problem we're solving?
- Why is this a problem right now?
- What happens if we don't solve it?

**Context & Constraints:**
- What constraints are we working within? (technical, organizational, time, etc.)
- What context matters? (existing codebase, team size, dependencies)
- Are there things we *cannot* do or change?

**Success Criteria:**
- How will we know this is solved?
- What does success look like?
- Are there acceptance criteria or must-haves?

**Prior Work:**
- What has the person already tried?
- What worked and what didn't?
- Are there related problems that have been solved?

**Tradeoffs:**
- What matters most? (simplicity, performance, flexibility, etc.)
- What can we compromise on?
- Are there hidden tradeoffs we should discuss?

## Artifact

Presents a problem statement inline (not written to a file). See `ARTIFACT.md` for the full template. Produced when understanding closes and mutual alignment is confirmed.

## Closure Criteria

Understanding is complete when:

- [ ] You have a clear statement of what the problem is
- [ ] You understand why it matters and why now
- [ ] You've identified key constraints and context
- [ ] You both agree on what success looks like
- [ ] Assumptions have been surfaced and discussed
- [ ] The person feels heard and understood

## Notes

- This skill is about listening and asking good questions
- The quality of downstream work depends on getting this right
- It's better to spend extra time here than to discover misalignment later
