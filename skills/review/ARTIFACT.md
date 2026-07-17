## Meta

- **Storage:** Inline — output is produced in-context, not saved to a file
- **Filename:** N/A
- **Trigger:** When the review pass is complete

## Template

```markdown
# Review Issues

**Pull Request:** <title and number or "Local changes on [branch]">
**Author:** <name or "you">
**Summary:** <1–3 sentence description of what this change does>

---

> **Formatting note:** Number top-level issues within each section using explicit sequential numbers (`1.`, `2.`, `3.`, …) — do not rely on markdown auto-numbering, since the output may be read in a TUI that doesn't auto-number.

## Critical Issues
> Must be resolved before merge.

1. <issue description>
   - **Where:** <file:line or area>
   - **Why it matters:** <specific risk or consequence>
   - **Suggestion:** <recommended fix>
2. <next issue description>
   - **Where:** …
   - **Why it matters:** …
   - **Suggestion:** …

## Major Issues
> Significant problems that should be resolved.

1. <issue description>
   - **Where:** <file:line or area>
   - **Why it matters:** <specific risk or consequence>
   - **Suggestion:** <recommended fix>
2. <next issue description>
   - **Where:** …
   - **Why it matters:** …
   - **Suggestion:** …

## Minor Issues
> Non-blocking. Worth addressing but won't hold up a merge.

1. <issue description>
   - **Where:** <file:line or area>
   - **Suggestion:** <recommended improvement>
2. <next issue description>
   - **Where:** …
   - **Suggestion:** …

## Gaps & Inconsistencies

1. <gap description>
   - **Where:** <location>
   - **Detail:** <what's missing or inconsistent>
2. <next gap description>
   - **Where:** …
   - **Detail:** …

## Opportunities

1. <opportunity description>
2. <next opportunity description>

---

**Recommendation:** Go / No-Go / Go with conditions

<1–3 sentence rationale>
```

## Notes

- This ARTIFACT.md defines the format for the review report, which is presented inline in the conversation — the same structure defined in `review/SKILL.md`.
- When review feeds triage, the report is handed off in-context.
