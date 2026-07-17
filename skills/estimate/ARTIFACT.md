## Meta

- **Storage:** Inline — output is produced in-context, not saved to a file
- **Filename:** Inline — output is produced in-context, not saved to a file
- **Trigger:** Whenever an estimate is requested

## Template

```
LOE: <1–5>
Complexity: <Low|Medium|High> | Impact: <Low|Medium|High>
<1–5 sentence rationale explaining the synthesis, especially when dimensions diverge>
```

## Notes

- No file is written — estimate's artifact is its formatted output
- Within the pipeline, estimate is used by `/atomize` to enforce plan-phase decomposition: `/atomize` calls estimate per plan phase and decomposes anything > LOE 2 until all plan phases are ≤ 2
- The synthesis matrix and scoring dimensions are defined in `estimate/SKILL.md`
