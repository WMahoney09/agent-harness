---
name: cold-start
description: |
  Set up a repo's project-management scaffolding: a label taxonomy (value streams + components), release-backed milestones, issue bucketing, and GitHub Project wiring. Works backwards from release promises. Applies greenfield or to an existing backlog.
  TRIGGER when: the user asks to cold-start a project ("cold-start this repo", "set up project management"), set up labels/milestones/roadmap ("build the roadmap", "create milestones", "organize the backlog", "bucket these issues"), or asks to replicate this setup from another project ("set this up like we did on kubesat").
---

# Cold-Start: Release-Backed Project Scaffolding

This skill turns a backlog and/or a planning conversation into a coherent tracking structure on GitHub: labels, milestones, filed issues, and Project wiring. It is doctrine-first — the taxonomy rules below are the payload; the `gh` mechanics just apply them.

## Invocation

- **`/cold-start`** — scaffold the current repo (resolve `{owner}/{repo}` from the origin remote)
- **`/cold-start owner/repo`** — scaffold another repo

## Goal

A repo where the three tracking levers each own exactly one dimension:

- **Labels** answer *what kind* — they cut horizontally across all time
- **Milestones** answer *when / what increment* — they end, and closing one means something
- **Releases** answer *why anyone cares* — human-facing outcome promises

...with every open issue labeled, near-term issues milestoned, missing issues filed, and everything flowing into one GitHub Project.

## Doctrine

These rules are the transferable knowledge. Apply them; when the user proposes a structure that violates one, name the rule and the failure mode it prevents, then defer to their call.

1. **Labels are for things that persist; milestones are for things that end.** Ask of any candidate: "will this ever be *done*?" Value streams (e.g. token-security) and components (e.g. comms-module) never finish — they're labels. An increment with a done-state ("tokenless triage actors") is a milestone.
2. **Two label families, kept lean.** *Value streams* — the whys of the backlog (security, DX, scale, operations). *Components* — the wheres (the nouns of the architecture). One color family per label family. 3–5 of each is typical; more than ~8 total is a smell.
3. **Milestones are named for the increment, not the component or motivation.** "0.2: Keychain fueling", never "Comms module" or "Security". A component evolving through versions is a label plus a *sequence* of milestones.
4. **Milestones cut across value streams.** A milestone takes whatever increments from each lane are needed to make its release promise true. Don't create one milestone per stream.
5. **Releases are outcome statements, defined first.** Work backwards: write the promise ("launching a satellite never puts a secret in an agent's context"), derive the milestones that make it true, then bucket and file issues. Release tags/publishes are human acts — the skill scaffolds toward them, never creates them.
6. **Only milestone the next one or two releases.** Far-future milestones rot into labels-with-due-dates. The far future lives as labeled, unmilestoned backlog — that is a healthy state, not a gap.
7. **Never encode the same dimension twice.** No version labels, no theme milestones, no status labels duplicating the Project board. The moment two systems encode one dimension, they drift and neither is trusted.
8. **Milestone prefix convention:** `<release>: <increment name>` (e.g. `0.3: Egress lockdown`) so milestones sort by release and the release lives in milestone metadata without a second tracking object.

## Your Role

- Supply or confirm the release promises — the skill can propose them from the backlog and conversation, but the promise is a scope decision only you can own.
- Sign off on the proposal (taxonomy + roadmap + bucket map) before anything is created on GitHub.
- Make the borderline bucketing calls the agent surfaces (pull-forward candidates, issues that straddle milestones).
- Run the UI-only steps the agent hands off (Projects auto-add workflow).

## Agent's Role

### Step 1: Survey

Establish current state before proposing anything:

```
git remote get-url origin
gh issue list --repo {owner}/{repo} --state open --limit 100 --json number,title,labels,milestone
gh label list --repo {owner}/{repo} --limit 50
gh api repos/{owner}/{repo}/milestones
gh project list --owner {owner} --format json
```

Read the repo's README / vision / roadmap docs. Harvest value streams and components from the backlog titles, the docs, and the current conversation — never ask for something already stated.

### Step 2: Propose and get sign-off

Draft the full plan per `ARTIFACT.md` — label taxonomy, next 1–2 releases with promises, milestones per release, bucket map for existing issues, and new issues to file (title + one-line scope each). Present it inline and iterate until the user signs off. **Nothing is created on GitHub before sign-off.**

Brownfield rules: reuse or re-describe existing labels that match a proposed one rather than creating near-duplicates; never delete or rename existing labels/milestones without asking; existing milestone assignments are respected unless the user agrees to move them.

### Step 3: Execute

Order matters — labels and milestones before anything references them:

1. **Labels:** `gh label create <name> --repo {owner}/{repo} --color <hex> --description "<family>: <meaning>"`
2. **Milestones** (no `gh` subcommand exists; use the API): `gh api repos/{owner}/{repo}/milestones -f title="..." -f description="<release promise this serves>"`
3. **Existing issues:** `gh issue edit N --add-label a,b` and, where scheduled, `--milestone "title"`
4. **New issues:** body via the Write tool to a temp file, then `gh issue create --title "..." --body-file <path> --label a,b --milestone "title"`. Bodies follow the global GitHub-identity rules (🤖 Claude banner) and carry a Problem / Proposal / Acceptance structure with checkboxed acceptance criteria.
5. **Project wiring:** `gh project link <num> --owner {owner} --repo {owner}/{repo}`, then `gh project item-add <num> --owner {owner} --url <issue-url>` for every open issue. If no project exists, ask before creating one (`gh project create`).

### Step 4: Hand off the UI-only step

The Projects v2 **auto-add workflow** (new issues default into the project) is not exposed via API or `gh`. Give the user the exact path — Project → **⋯** → **Workflows** → **Auto-add to project** → select the repo, filter `is:issue`, enable — and never claim it is done.

### Step 5: Verify and report

Re-list open issues with labels and milestones (`gh issue list ... --json number,labels,milestone`) and confirm the created state matches the signed-off proposal. Deliver the completion report per `ARTIFACT.md`, including anything deferred to the user.

## Artifact

Two inline outputs: the **setup proposal** (Step 2, pre-execution sign-off gate) and the **completion report** (Step 5). See `ARTIFACT.md` for both templates. Nothing is written to the target repo's files.

## Closure Criteria

Cold-start is complete when:

- [ ] Doctrine-conformant taxonomy proposed and signed off before any GitHub writes
- [ ] Labels created (or existing ones adopted) with family-consistent colors and descriptions
- [ ] Milestones exist for the next 1–2 releases only, `<release>: <increment>` titled, promise in the description
- [ ] Every open issue carries at least one stream or component label
- [ ] Every scheduled issue is in a milestone; unscheduled issues are deliberately milestone-less
- [ ] New issues identified in the proposal are filed with banner, labels, milestone, acceptance criteria
- [ ] Repo linked to the Project and all open issues added
- [ ] Auto-add workflow instructions handed to the user (explicitly marked not-automated)
- [ ] Verification pass ran; completion report delivered

## Notes

- The doctrine section is the durable payload; the `gh` invocations are current as of mid-2026 and may drift — prefer adapting mechanics over bending doctrine.
- This skill scaffolds tracking structure; it does not cut releases, create tags, or set due dates. Dates are the user's call, added later if wanted.
- Milestone descriptions carry the release promise so the release exists as words in metadata without becoming a second tracking object (see doctrine rule 7).
- When the conversation that triggered cold-start already generated a work list (a security review, an audit, a design discussion), those items become the "new issues to file" — each worded as the increment it ships, not the discussion that spawned it.
