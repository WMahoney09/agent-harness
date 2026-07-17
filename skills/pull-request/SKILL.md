---
name: pull-request
description: |
  Open a pull request for local changes. Handles commit verification, push, and structured PR description. First skill in the Deliver stage.
  TRIGGER when: the user asks to open a pull request ("open a PR", "create a pull request", "PR this", "let's PR"), or when the user accepts an agent's offer to open a PR ("yes" in response to "want me to open a PR?" or similar).
agent-invocation: user-invoked-and-referenced
agent-note: "User-invoked directly or invoked by reference from orchestration skills. Not auto-invoked by /produce or other Implement skills."
---

# Pull Request: Open a PR for Local Changes

This skill handles the full flow of opening a pull request — from verifying local state through pushing and creating the PR with a structured description.

## Invocation

- **`/pull-request`** — Open a PR for the current branch against the default base branch
- **`/pull-request <base>`** — Open a PR against a specific base branch

## Goal

Open a well-structured pull request that gives reviewers everything they need: what changed, why, how to verify it, and links to the relevant context.

## Agent's Role

### Step 1: Verify Local State

Check for uncommitted changes:

```
git status
```

If there are uncommitted changes, invoke the `/commit` skill to commit them before proceeding.

### Step 2: Determine the Base Branch

Use the base branch specified by the user. If none is specified, use the repository's default branch:

```
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

Most often this will be `main`.

### Step 3: Push to Remote

Check if the branch has an upstream tracking reference. If not, push with `-u`:

```
git push -u origin HEAD
```

If already tracking, a simple push is sufficient:

```
git push
```

### Step 4: Gather Context for the Description

Collect the information needed to build the PR description:

1. **Issue links** — Check if the branch name references an issue (e.g., `issue/11-pull-request-skill` → `#11`). Check recent commits for `Closes #N` or `Resolves #N` trailers. If the tracking system is external (Linear, Jira, etc.), construct a link to the ticket.

2. **Artifact links** — Skill outputs are inline by default, so these usually don't exist as files. Only if the project persisted a `problem-statement.md` / `solution-statement.md` as a file, construct relative links to them; otherwise skip this.

3. **Change summary** — Use `git log` and `git diff` against the base branch to understand the full scope of changes:
   ```
   git log --oneline <base>..HEAD
   git diff --stat <base>..HEAD
   ```

4. **Test plan** — Infer verification steps from the changes. What should a reviewer check?

### Step 5: Create the Pull Request

**Prefer the GitHub MCP server** for PR creation. If MCP is not configured or fails, fall back to the `gh` CLI.

**Using MCP:**

Use the `mcp__github__create_pull_request` tool with the owner, repo, title, body, base, and head parameters.

**Falling back to CLI:**

Write the body to `/tmp/pr_body.txt` first using the Write tool, then use `--body-file` to avoid shell substitution:

```
gh pr create --title "<title>" --base <base> --body-file /tmp/pr_body.txt
```

**Title:** Keep it under 70 characters. Summarize the change, not the process.

**Body:** Follow the template defined in `ARTIFACT.md`.

### Step 6: Report Completion

Report the PR URL and a brief summary of what was opened.

## Artifact

The pull request itself is the artifact. `ARTIFACT.md` documents the description template. Generated when the PR is successfully created.

## Closure Criteria

The pull request is complete when:

- [ ] All local changes are committed
- [ ] The branch is pushed to the remote
- [ ] The PR is created with a structured description
- [ ] Issue links are included (if applicable)
- [ ] Artifact links are included (if they exist)
- [ ] The PR URL has been reported to the user

## Notes

- This skill marks the entry point to the **Deliver** stage in the RAPID workflow
- `/reply` is downstream — it addresses reviewer comments on a PR this skill opened
- When invoked by an orchestrator, the skill runs without user confirmation
- The description template is intentionally structured but not rigid — adapt the level of detail to the size of the change
