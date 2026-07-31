## Meta

- **Storage:** GitHub pull request (not a local file)
- **Filename:** N/A — the artifact is the pull request itself
- **Trigger:** When `/pull-request` is invoked and all changes are pushed

## Template

The PR description follows this structure:

```markdown
Closes #<issue-number>

[problem-statement.md](<relative link>) | [solution-statement.md](<relative link>)

## Summary

<1–8 sentence overview of what this change does and why.>

- <Problem:> <brief summary of the problem being solved>
- <Solution:> <brief summary of the approach taken>
- <change description>
- <change description>
- <additional changes as needed>

## Test Plan

- [ ] <verification step>
- [ ] <verification step>
- [ ] <additional steps as needed>

## Known issues

- <unresolved finding, and why it was not addressed>
```

### Section guidance

**Issue links** — Appear first. Use GitHub-recognized resolution keywords (`Closes`, `Resolves`, `Fixes`) followed by the issue number. For external trackers (Linear, Jira), use a markdown link to the ticket instead.

**Artifact links** — Skill outputs are inline by default, so these usually don't exist as files. Only if the project persisted a `problem-statement.md` / `solution-statement.md` as a file, link to it. Omit this line otherwise.

**Summary** — Start with a prose overview (1–8 sentences), then a bulleted list. The first two bullets should summarize the problem and the solution. Remaining bullets describe specific changes.

**Test plan** — A checkbox list of steps a reviewer can follow to verify the changes. Describe what to check, not how the code works.

**Known issues** — Conditional. Include only when the change ships with a problem its author already knows about: a Critical or Major review finding that was not resolved, a deliberate limitation, a deferred edge case. State the issue and why it was left. Omit the section entirely when there is nothing to declare — an empty "Known issues" heading reads as an oversight. This is where `/produce` puts findings that survived its revision cycle.

## Notes

- The description scales with the change — a one-file fix doesn't need eight sentences and six bullets
- If no workstream artifacts exist (problem-statement, solution-statement), skip the artifact links line entirely rather than leaving a placeholder
- Issue links should only be included when there are actual issues to reference — don't fabricate them
