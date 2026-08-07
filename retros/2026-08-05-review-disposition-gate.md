# Retro: reviews had no terminal state, so authors got endless rounds of blocking feedback

**Date:** 2026-08-05
**Trigger:** Bartosh reported being sent into never-ending loops of critical feedback across successive `/review` rounds on the same PR.
**Status:** Resolved (harness updated; hook re-registered).

## What happened

An engineer receiving agent reviews would fix everything raised, ask for another round, and get a fresh set of blocking findings — often on code they had never touched. Repeat. There was no state the PR could reach that produced a green check, and no action the author could take that permanently closed an item.

## Root cause

Three mechanisms, compounding:

**1. No terminal state.** The `2026-05-01` retro locked reviews to comment-mode only, forbidding approve alongside request-changes. Correct for request-changes, over-broad for approve: it removed the only signal that meant *done*. Every round, however clean, posted as one more comment.

**2. The reviewer re-derived its findings every round.** `/review` had no concept of a prior round. Step 1 fetched the full PR diff, Step 3 walked every dimension over every changed file, and nothing consulted what had already been reported. A fresh pass over settled code samples a different slice of findings each time, so round 3 produced new Criticals on lines the author never edited. That is the loop engine.

**3. The author had no way to close a finding.** Fixing it worked, sometimes. Explaining why the code was intentional did nothing — the next cold pass raised it again, verbatim. Declining did nothing. The reviewer held every finding open indefinitely, against an author who had already answered.

A secondary contributor: Will had been manually filtering reviews to Critical + Major before publishing, to keep engineers focused. That got encoded as a *reporting* filter in the skill, which read as withholding rather than prioritizing.

## The decision

**Gate the approval on disposition coverage, not on a clean finding count.**

A review approves when every Critical and Major finding on the PR carries a disposition. Four dispositions close a finding, and they are equal:

| Disposition | Meaning |
|---|---|
| **Fixed** | The code changed and the change addresses it |
| **Intentional** | Author explained why the code is the way it is |
| **Deferred** | Author pointed the work at another PR or fix |
| **Declined** | Author is not doing it |

A closed finding is closed permanently — it does not reappear, does not get re-worded, and does not gate the merge. A finding with no response stays open and carries forward at its original severity.

Three supporting rules make that gate reachable:

- **Each line of code is reviewed once.** A re-review anchors on the previous review's `commit_id`, scopes to `compare/{anchor}...{head}`, and does not re-scan settled code.
- **Report everything, graded.** Minor findings publish by default. Severity ranks the author's work queue rather than filtering what gets said. `full` now adds only Gaps and Opportunities.
- **Declined closes the gate the same as fixed.** The engineer accountable for the code owns the call; the review's job was to make sure the call was informed. Approvals name what was declined or deferred so the record shows what shipped knowingly.

## Why declined counts

This is the load-bearing and least obvious choice. Letting an author decline their way to a green check looks like it defeats the review.

It does not, because the alternative is worse and was already observed: a reviewer that can veto indefinitely produces a stalemate no amount of good-faith work resolves, and the author's only exits are to capitulate or to ignore the review entirely. Neither improves the code. Handing the author four equal ways to close an item keeps every finding visible on the PR — the decline and its stated reason live in the thread permanently — while putting the merge decision with the person accountable for it.

The reviewer's job is to surface and inform. It is not to hold the merge button.

## What we fixed

1. **`user/CLAUDE.md`** — replaced "Comment-Mode, Approve Only on a Clean Review" with "Comment-Mode, Approve on Full Disposition." Nine rules: never request changes, comment by default, approve on full disposition, the four dispositions, undispositioned findings carry forward, never re-litigate a closed finding, grade honestly, severity stays in the body, name the state when reporting.
2. **`skills/review/SKILL.md`** — new Step 2 (Check for Prior Rounds) doing anchor detection, delta scoping, and prior-finding reconciliation. Report scope defaults to Critical + Major + Minor. Review State section rewritten as the disposition gate. Steps renumbered 1–6.
3. **`skills/review/ARTIFACT.md`** — new **Previously Reported** table carrying each prior finding's disposition. This is the machine-readable handoff `/publish-review` consumes.
4. **`skills/publish-review/SKILL.md`** — Step 1 reads the Previously Reported table instead of inferring a re-review from prose. Step 3 resolves threads on any disposition, not just fixes. Step 4a is the one-condition gate. New edge cases for deleted threads and for disputed findings.
5. **`skills/publish-review/ARTIFACT.md`** — body template opens with Previously Reported on a re-review.
6. **`hooks/block-pr-review-state.sh`** — narrowed to `REQUEST_CHANGES` only; approve is no longer blocked. Added inspection of `--input` payload files, which the canonical `gh api .../reviews --input` invocation uses and which a command-string check cannot see.
7. **`user/settings.json`** — re-registered the hook under `hooks.PreToolUse`.

## The hook had been dead since July

`user/settings.json` lost its entire `hooks` block in `2e5c905` (2026-07-17), when the file was refreshed from local config while relocating a token. Nothing noticed, because the only hook it registered guards a rare action and the always-loaded `CLAUDE.md` rule covered the common path. From 2026-07-17 to 2026-08-05 the request-changes guard was prose only, and the README claimed otherwise.

Worth a standing check: `user/settings.json` is the one harness file that gets edited from the live side, and it is the one whose contents nothing else validates.

## Hook test cases (all passing)

| Input command | Expected | Got |
| --- | --- | --- |
| `gh pr review 12 --request-changes --body-file /tmp/r.md` | block (exit 2) | block ✓ |
| `gh pr review 12 --approve --body-file /tmp/r.md` | allow (exit 0) | allow ✓ |
| `gh api repos/o/r/pulls/12/reviews --input /tmp/payload.json` with `event=REQUEST_CHANGES` | block (exit 2) | block ✓ |

## Open / future improvements

- **Disposition classification is a judgment call on free-text replies.** The rule is deliberately generous — any substantive reply closes the finding — because the failure mode of being strict is the loop this retro exists to fix. If authors start closing findings with "k", revisit.
- **Body-only findings cannot be dispositioned.** They have no thread to reply to. `/review` now re-anchors them inline when the delta allows, but a finding that never anchors can only be closed by a code change.
- **Force-push erases the anchor.** The re-review falls back to a full-diff pass and says so in the report. That round can legitimately surface new blocking findings on old code — unavoidable, since the prior review's basis is gone.
- **The gate trusts the severities feeding it.** A Major graded down to Minor buys a green check. Both skills carry an explicit rule against it; nothing enforces it mechanically.
