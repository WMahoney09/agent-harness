## Meta

- **Storage:** Inline — output is produced in-context, not saved to a file
- **Filename:** Inline — output is produced in-context, not saved to a file
- **Trigger:** At the end of each pre-flight cycle

## Template

```
## Pre-Flight Findings

### Critical Issues
- **What:** <specific problem>
  - **Where:** <phase/step affected>
  - **Impact:** <why it matters>
  - **Suggestion:** <proposed fix>

### Major Issues
- **What:** <specific problem>
  - **Where:** <phase/step affected>
  - **Impact:** <why it matters>
  - **Suggestion:** <proposed fix>

### Minor Issues
- **What:** <specific problem>
  - **Where:** <phase/step affected>
  - **Suggestion:** <proposed improvement>

### Opportunities Identified
- <improvement with reasoning>

### Confidence Level
Ready / Issues to resolve / Return to Planning
```

## Notes

- Pre-flight findings are always inline — no file is written and the working index stays clean
- Pre-flight's committed artifact is the updated plan file — produced by the reasoning pass that follows and committed as `[plan]`
- In the leeroyyyyy pipeline, pre-flight findings are consumed in-context by the reasoning subagent
