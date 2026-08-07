## Meta

- **Storage:** Inline — output is produced in-context, not saved to a file
- **Filename:** N/A
- **Trigger:** When the review pass is complete

## Scope Variants

Two shapes, selected by the invocation:

- **Default (`/review`)** — Header → Previously Reported → Critical → Major → Minor → Recommendation. Gaps & Inconsistencies and Opportunities are omitted entirely, headings included.
- **Full (`/review full`)** — the complete template below.

**Previously Reported** appears on a re-review only. On round 1 it is omitted entirely, heading included.

## Template (full)

```markdown
# Review Issues

**Pull Request:** <title and number or "Local changes on [branch]">
**Author:** <name or "you">
**Round:** <1, or "N — reviewing {anchor_sha}..{head_sha}">
**Summary:** <1–3 sentence description of what this change does>

---

> **Formatting note:** Number top-level issues within each section using explicit sequential numbers (`1.`, `2.`, `3.`, …) — do not rely on markdown auto-numbering, since the output may be read in a TUI that doesn't auto-number.

## Previously Reported
> Re-review only. Every Critical and Major from earlier rounds, with exactly one disposition each.

| # | Severity | Finding | Disposition | Detail |
|---|---|---|---|---|
| 1 | Critical | <short description> | Fixed | <what changed, file:line> |
| 2 | Major | <short description> | Intentional | <author's stated reason> |
| 3 | Major | <short description> | Deferred | <where the work went> |
| 4 | Major | <short description> | Declined | <author's stated reason> |
| 5 | Major | <short description> | **Open** | <no response; carried forward as Major #1> |

Dispositions: **Fixed**, **Intentional**, **Deferred**, **Declined**, **Open**. The first four close the finding permanently — it does not repeat below and does not gate the approval. Open findings carry forward at their original severity.

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
- The **Previously Reported** table is the input `/publish-review` reads to resolve threads and to decide the review state. Dropping it on a re-review strands both.
- Minor Issues is a default section. It publishes and never gates an approval.
