# Retro: agent published a `--request-changes` review on Will's account

**Date:** 2026-05-01
**Trigger:** During a review of a client pull request, the agent posted via `gh pr review --request-changes` instead of comment-mode.
**Status:** Resolved (review dismissed by Will; harness updated).

## What happened

1. Will asked the agent to review the PR in plain English ("publish your review").
2. The agent ran `gh pr review <N> --request-changes --body-file /tmp/review.md`.
3. Will pointed out that the Publish Review skill is unambiguous — comment-mode only, never approve, never request-changes.
4. The agent attempted to dismiss-and-re-post; Will stopped it (already dismissed) and called a retro.

## Root cause

Two layers, both contributing:

**Layer 1 — Harness gap (primary).** The "comment-only" rule lived inside the Publish Review skill. Will didn't type `/publish-review`, so the skill never loaded and the rule never reached the agent's context. This is a class-of-action safety rule (applies every time `gh pr review` runs) gated behind opt-in skill invocation. Most users phrase the request as "publish my review" / "post that," which bypasses the skill entirely.

**Layer 2 — Agent failure.** In its own pre-execution reasoning, the agent wrote: *"a regular review (without approve/request changes — just COMMENT) is the most conservative. Let me do that."* It then composed the bash command with `--request-changes` anyway. Caution surfaced in chain-of-thought but didn't survive into the tool call. Contributing factor: the agent had been calling the bugs "blocking" earlier in chat, which primed `--request-changes` as the "matching" review state.

## What we kept

- The `🤖 Claude:` prefix and not-in-Will's-voice rules from global CLAUDE.md worked correctly — the body itself was attributed properly.
- The `--body-file /tmp/...` pattern (Write tool → single gh call) avoided permission prompts.
- Probe tests beat speculation. Two `*.test.tsx` probes against the PR branch turned "I think there's a bug" into verified failing assertions. Worth keeping for future PR reviews where logic-only reasoning would feel hand-wavy.

## What we fixed

1. **Added a `## GitHub Reviews: Comment-Mode Only (MANDATORY)` section to global CLAUDE.md** — peer to "GitHub Content: Identify as Claude". Now always loaded, skill-invocation-independent. Forbids `--approve`, `--request-changes`, and the `gh api ... event=APPROVE/REQUEST_CHANGES` path.
2. **Added a deterministic `PreToolUse` hook** at `~/.claude/hooks/block-pr-review-state.sh`, wired in `~/.claude/settings.json`. It parses the Bash tool input, matches `gh pr review` with a state-changing flag (or `gh api .../reviews` with `event=APPROVE/REQUEST_CHANGES`), and exits 2 with a clear stderr message. Belt-and-suspenders for when the LLM-level rule is overlooked.
3. **Skill stays as-is.** Will's preference: the skill is good where it is; the hard rule belongs in always-on instructions and a hook, not in opt-in skill text.

## Hook test cases (all passing)

| Input command | Expected | Got |
| --- | --- | --- |
| `gh pr review <N> --request-changes --body-file /tmp/r.md` | block (exit 2) | block ✓ |
| `gh pr review <N> --comment --body-file /tmp/r.md` | allow (exit 0) | allow ✓ |
| `gh pr view <N>` | allow (exit 0) | allow ✓ |
| `gh api -X POST /repos/o/r/pulls/1/reviews -f event=APPROVE -f body=lgtm` | block (exit 2) | block ✓ |

## Open / future improvements

- **Short flags (`-a`, `-r`)** intentionally not blocked in v1. Long flags are what the agent actually uses; short-flag handling adds false-positive risk (e.g., `-r` could be misread). Add if/when a real case shows up.
- **Web UI / GitHub MCP paths** aren't covered by the Bash hook. If a future agent tries to publish a review via an MCP tool, this hook won't catch it — the always-loaded CLAUDE.md rule is the only line of defense in that case. Worth revisiting if/when MCP-based review tooling enters the workflow.
- **`/retro` skill assumes `docs/workstreams/<slug>/`** for the artifact path. This retro is about the global agent harness, not a per-project workstream — so the artifact lives at `~/.claude/retros/` instead. The skill could spell out the non-workstream case explicitly.

## Skill observations

- **Publish Review skill**: the rule is correctly stated *inside* the skill, but the skill assumes it'll always be invoked. Reality: most invocations use plain English. Solved by lifting the rule to global CLAUDE.md + adding the hook; the skill itself can stay focused on phrasing/severity conventions.
- **/retro**: artifact-path assumption noted above. Otherwise worked well — categorizing observations + inviting human input produced a clean conversation that drove a real fix in one pass.
