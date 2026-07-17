## Meta

- **Storage:** Inline — output is produced in-context, not saved to a file
- **Filename:** `triage-report.md`
- **Trigger:** When triage groupings are finalized

## Template

```markdown
# Triage Report

**Source:** <PR #N / Review output / Conversational list / Combined>
**Items ingested:** <total count>
**Revisions identified:** <count after grouping>

---

## Critical Revisions

**Revision C1:** <short title>

> **Addresses:**
> - <source ref>: "<quote>"

**What needs to change:** <description>

## Major Revisions

**Revision M1:** <short title>

> **Addresses:**
> - <source ref>: "<quote>"

**What needs to change:** <description>

## Minor Revisions

**Revision m1:** <short title>

> **Addresses:**
> - <source ref>: "<quote>"

**What needs to change:** <description>

## Items Requiring Clarification

- <source ref>: "<quote>"
  - **Why unclear:** <explanation>
  - **Question:** <what needs clarification>

---

| Severity | Revisions |
|---|---|
| Critical | N |
| Major | N |
| Minor | N |
| Needs clarification | N |
| **Total** | **N** |
```

## Notes

- The triage report format mirrors the structure defined in `triage/SKILL.md`
- Revision IDs (C1, M1, m1) are stable identifiers used by `/revise` in commit trailers for traceability
