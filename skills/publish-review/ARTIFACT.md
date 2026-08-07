## Meta

- **Storage:** GitHub pull request review (not a local file)
- **Filename:** N/A — the artifact is the GitHub review object
- **Trigger:** Interactive mode — when the user confirms the finding-to-comment mapping and the review is posted. Unattended mode — as soon as the mapping is built.

## Template

### Top-level review body

```markdown
🤖 Claude: technical review of this PR.

**PR:** #N — title
**Round:** 1, or "N — reviewing {anchor_sha}..{head_sha}"
**Recommendation:** Go / No-Go / Go with conditions
**Rationale:** 1-2 sentence assessment.

### Previously Reported

(Re-review only. Omit this whole section on round 1.)

| Severity | Finding | Disposition |
|---|---|---|
| Critical | description | Fixed — `file:line` |
| Major | description | Declined — "author's stated reason" |
| Major | description | Deferred — #48 |

Closed for good; they will not appear in a later review. Open items from earlier rounds are listed with this round's findings below.

---

### Summary

| Severity | Count |
|---|---|
| Critical | N |
| Major | N |
| Minor | N |

**Critical**
- Finding description — `file:line`
- Finding description — `file:line`

**Major**
- Finding description — `file:line`

**Minor**
- Finding description — `file:line`

(Omit severity tiers with zero findings from both the table and the grouped list.)

---

### Findings Not in Diff

(Body-only findings listed here, if any. Each follows the inline format below but without line anchoring.)

- **[Severity]** Finding description — `file:line`

```

The `🤖 Claude:` banner on the first line is mandatory, per the global `CLAUDE.md` GitHub-identity rule — the review posts under Will's account but is not authored by him. It matters most in unattended mode, where nobody reads the body before it goes out. Do not replace it with a trailing "generated with Claude" footer, and do not write the body in Will's voice ("I confirmed", "my call").

### Inline comment format

```markdown
🤖 Claude: **[Severity]** Finding description

_Why it matters:_ Specific risk or consequence.

Suggestion or recommended fix.
```

- "Why it matters" is included for Critical and Major findings only
- Minor findings include severity, description, and suggestion
- Every inline comment carries the `🤖 Claude:` prefix too. Inline comments detach from the review body — they appear alone in the diff view and in email notifications, so the body's banner does not cover them

## Notes

- The review event is `COMMENT`, or `APPROVE` when every Critical and Major carries a disposition per `SKILL.md` → Step 4a — never `REQUEST_CHANGES`
- An approval does not shorten the body. It posts the same full report it would have posted as a comment; the state is an additional signal, not a replacement for the write-up
- On a re-review, the body opens with the prior findings and their dispositions before this round's findings. That table is what tells the author which items are closed for good
- An approval that rests on a declined or deferred finding names it in the body, quoting the author's reason
- All comments are posted as a single atomic review, not as individual comments
- The body template scales with the findings — omit "Findings Not in Diff" if all findings are inline or file-level
