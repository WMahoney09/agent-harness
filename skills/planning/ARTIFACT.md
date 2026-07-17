## Meta

- **Storage:** `docs/plans/<work-item>.plan.md` at the nearest project root
- **Filename:** `<work-item>.plan.md`
- **Trigger:** When the plan document is finalized and ready for pre-flight

## Template

```markdown
# <Title>

## Overview
<!-- High-level summary of what will be built -->

## Notes
<!-- Out of scope items, key decisions, design rationale -->

## Progress
- [ ] Phase N: <name>
- [ ] Phase M: <name>

---

## Phase N: <name>
<!-- Brief description of what this phase accomplishes -->

### Step N.N: <name>
<!-- What this step does and its output -->

#### Task N.N.N: <description>
<!-- Atomic unit of work -->
```

The plan follows a Phase → Step → Task breakdown. The Progress section is updated by `produce` at phase boundaries (not by planning itself).

## Notes

- Plan file naming follows `<work-item>.plan.md` where `<work-item>` is a slug derived from the plan title (lowercase, hyphenated, concise)
- The Progress section uses checkbox syntax: `- [ ]` for pending, `- [x]` for complete
- `produce` marks phases complete and commits the plan file update as a `[plan]` commit at each phase boundary
- `/atomize` runs after pre-flight to ensure all plan phases score ≤ LOE 2 before execution begins
