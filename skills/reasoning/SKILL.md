---
name: reasoning
description: |
  Reason through a problem to extract truths, conditionals, and a directional vector.
  TRIGGER when: the user wants collaborative help thinking through something complex ("help me think about this", "what do you think?", "let's hash this out", "help me reason through this"), or when a problem needs directional clarity before jumping to solutions.
---

# Reasoning: Developing Directional Clarity

This skill guides you through reasoning about a problem to extract what's fundamentally true, what's conditionally true, and from that, a direction to aim toward.

## Goal

Develop principled clarity by:
- **Validating the problem** - Is this the real problem? What are its actual impacts?
- **Extracting truths** - What holds no matter what? Guiding principles that constrain all solutions.
- **Identifying conditionals** - What becomes true if we make certain choices?
- **Deriving a vector** - A directional aim that constrains the solution space

The output is not a solution — it's a direction that constrains the solution space.

## Critical Boundary: Direction, Not Routes

**This skill produces a vector, not concrete solutions.** You're answering "which way should we aim?" not "which path should we take?"

**However, this is a soft boundary.** Sometimes you need specificity to validate a vector. Saying "if we go north, we'd hit the mountains -- is that acceptable?" is using specificity to test the direction, not to propose a route. That's valid reasoning.

The distinction:
- **Specificity to test a direction** -- valid here. "If we solve this at the API layer, we'd need to handle X and Y -- does that fit our constraints?"
- **Specificity to propose a route** -- solution territory. "Let's solve this at the API layer using approach Z."

## Structure of Reasoning

### 1. Problem Validation

Before reasoning deeply, validate the problem statement:
- Is this the real problem, or a symptom of something deeper?
- What are the actual impacts if this isn't solved?
- What are the impacts if it's solved poorly?
- Are there assumptions in the problem statement that should be questioned?

### 2. Truths (Guiding Principles)

Extract statements that hold no matter what solution we choose:

**Format:** Clear declarative statements about the problem domain.

Examples:
- "Any solution must maintain backward compatibility with the existing API"
- "User data integrity cannot be compromised during migration"
- "The system must remain available during the change"
- "This affects three downstream teams who consume this interface"

**How to find truths:**
- What constraints are non-negotiable?
- What properties must be preserved?
- What would make any solution invalid?
- What do we know for certain about the problem space?

### 3. Conditionals

Identify what becomes true based on choices we might make:

**Format:** If-then statements that show how choices create new realities.

Examples:
- "If we change the data model, then all consumers need migration paths"
- "If we prioritize speed, then we accept higher technical debt"
- "If we solve this at the API layer, then the database stays unchanged"
- "If we break backward compatibility, then we need a deprecation strategy"

**How to find conditionals:**
- What are the key decision points?
- What does each choice enable or foreclose?
- What tradeoffs emerge from different directions?
- What becomes easier or harder based on early choices?

### 4. The Vector

From truths and conditionals, derive a directional statement:

**Format:** A clear statement of aim that constrains the solution space without prescribing specific solutions.

Examples:
- "We should aim for a solution that preserves the existing interface while enabling the new capability behind it"
- "The direction is toward simplification—reducing moving parts rather than adding abstraction"
- "We need to solve this at the data layer; API-level fixes would be treating symptoms"
- "The vector points toward gradual migration rather than big-bang replacement"

**A good vector:**
- Eliminates solution directions that violate truths
- Accounts for the most important conditionals
- Provides meaningful constraint on the solution space
- Feels like shared conviction, not arbitrary choice

## Grounding in Reality

Reasoning should stay grounded. When helpful:
- Investigate how the codebase actually works
- Reference concrete code, patterns, or constraints discovered earlier

Abstract reasoning disconnected from the codebase tends to drift. Keep pulling back to what's actually true in the system.

## Artifact

Presents the truth-and-vector output inline (not written to a file). See `ARTIFACT.md` for the full template. Produced when the reasoning pass is complete and a direction has been established.

## Closure Criteria

Reasoning is complete when:

- [ ] The problem has been validated (it's real, impacts are understood)
- [ ] You've surfaced key truths that constrain all solutions
- [ ] You've identified important conditionals and their implications
- [ ] There's a clear vector — a direction that feels right to both of you
- [ ] The vector meaningfully constrains the solution space
- [ ] You both have conviction about the direction, not just agreement

## Notes

- This skill is about developing conviction through reasoning, not just listing facts
- Truths should feel inevitable -- things that anyone reasoning clearly would recognize
- Conditionals reveal the shape of the decision space
- The vector should feel like a natural conclusion from the truths and conditionals
- If you can't derive a clear vector, the problem may need more understanding first
- Good reasoning makes the next step dramatically clearer
