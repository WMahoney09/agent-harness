#!/usr/bin/env bash
# PreToolUse hook for Bash — blocks `gh pr review` invocations that request
# changes. Per global CLAUDE.md ("GitHub Reviews: Comment-Mode, Approve on Full
# Disposition"), reviews via Will's account may be COMMENT or, once every
# Critical and Major finding carries a disposition, APPROVE — but never
# REQUEST_CHANGES, which blocks other people's work under his name and stays
# his call alone.
#
# Approve is deliberately NOT blocked here. Its gate is a reading of the review
# report (no Critical or Major left open) and lives in the review /
# publish-review skills, where the report is actually in context. A hook can
# only see a command string, so it cannot evaluate that gate — it enforces the
# one rule that is unconditional.
#
# Stdin: JSON with { tool_name, tool_input: { command, ... }, ... }
# Exit 2 + stderr message → Claude Code blocks the tool call and surfaces
# the message to the agent.

set -euo pipefail

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

deny() {
  cat >&2 <<MSG
Blocked: $1

Per global CLAUDE.md ("GitHub Reviews: Comment-Mode, Approve on Full
Disposition"), a review posted through Will's account is never REQUEST_CHANGES.
That one has no exception — it blocks other contributors' work under his name.

Post the same findings as a comment instead; severity belongs in the body text:
  gh pr review <N> --comment --body-file /tmp/review.md

Approve is allowed once every Critical and Major finding on the PR carries a
disposition — fixed, intentional, deferred, or declined. See the publish-review
skill, Step 4a. If changes genuinely need to be requested as a review state,
ask Will to do it himself.
MSG
  exit 2
}

# `gh pr review ... --request-changes`. The flag is checked separately from the
# subcommand so argument order doesn't matter.
if printf '%s' "$command" | grep -qE 'gh[[:space:]]+pr[[:space:]]+review\b' \
  && printf '%s' "$command" | grep -qE -- '--request-changes\b'; then
  deny '`gh pr review --request-changes`.'
fi

# The lower-level `gh api .../pulls/N/reviews` path with an inline
# event=REQUEST_CHANGES field.
if printf '%s' "$command" | grep -qE 'gh[[:space:]]+api\b.*pulls/.*/reviews' \
  && printf '%s' "$command" | grep -qiE 'event[ =]+REQUEST_CHANGES'; then
  deny '`gh api .../reviews` with event=REQUEST_CHANGES.'
fi

# Same path, but with the payload in a file (`--input payload.json`) — the
# canonical publish-review invocation, and invisible to a check that only reads
# the command string. Inspect the referenced file when it is readable.
if printf '%s' "$command" | grep -qE 'gh[[:space:]]+api\b.*pulls/.*/reviews' \
  && printf '%s' "$command" | grep -qE -- '--input[[:space:]=]'; then
  payload_path=$(printf '%s' "$command" \
    | sed -nE 's/.*--input[[:space:]=]+"?([^"[:space:]]+)"?.*/\1/p')
  if [ -n "$payload_path" ] && [ -r "$payload_path" ]; then
    payload_event=$(jq -r '.event // ""' "$payload_path" 2>/dev/null || printf '')
    if printf '%s' "$payload_event" | grep -qiE '^REQUEST_CHANGES$'; then
      deny "a review payload at $payload_path carrying event=REQUEST_CHANGES."
    fi
  fi
fi

exit 0
