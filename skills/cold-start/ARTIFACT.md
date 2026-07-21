# ARTIFACT.md — Cold-Start Outputs

## Meta

- **Storage:** `Inline` — output is produced in-context, not saved to a file
- **Filename:** Inline — output is produced in-context, not saved to a file
- **Trigger:** Setup Proposal at the end of Step 2 (sign-off gate, before any GitHub writes); Completion Report at the end of Step 5

## Template

### Setup Proposal

```
## Cold-Start Proposal: {owner}/{repo}

### Label taxonomy

**Value streams** (color family: <hex range>)
| Label | Meaning |
|---|---|
| stream-name | one-line meaning |

**Components** (color family: <hex range>)
| Label | Meaning |
|---|---|
| component-name | one-line meaning |

[Brownfield only] **Existing labels adopted / left alone:** ...

### Roadmap

**Release <version> — "<name>"**
Promise: <one-sentence outcome statement>

| Milestone | Ships |
|---|---|
| <version>: <increment> | one-line scope |

[Repeat for at most one more release.]

### Bucket map — existing issues

| Issue | Labels | Milestone |
|---|---|---|
| #N title | a, b | <version>: <name> — or "backlog (unscheduled)" |

### New issues to file

| Title | Labels | Milestone | Scope |
|---|---|---|---|
| ... | ... | ... | one line |

### Open calls for you
- <borderline bucketing decisions, pull-forward candidates, project create/reuse>
```

### Completion Report

```
## Cold-Start Complete: {owner}/{repo}

- Labels: <created N / adopted M>
- Milestones: <list with issue counts>
- Issues: <N existing labeled/bucketed, M new filed (#x–#y)>
- Project: <linked project name/number, N items added>
- Verified: <what the verification pass confirmed>

### Left for you
- Auto-add workflow (UI-only): Project → ⋯ → Workflows → Auto-add to project → select repo, filter `is:issue`, enable
- <any deferred decisions or skipped items>
```

## Notes

- The Setup Proposal is a hard gate: no `gh` write commands before the user signs off on it.
- Every row in the bucket map must resolve to an explicit milestone or an explicit "backlog (unscheduled)" — no blank cells; deliberate unscheduling is the healthy state for far-future work.
