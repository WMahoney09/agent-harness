# Global Agent Instructions

## GitHub Identity

- **Username:** WMahoney09
- **Personal repos:** WMahoney09/*
- **Organizations:** TheGnarCo, Smartphones-Plus, AMP-SCZ, trustedadvisorassociates, wealth-kitchen, elevenfortyseven, Foundation-for-International-Services
- **Harness repo:** WMahoney09/agent-harness

When resolving `{owner}` for GitHub API calls or `gh` commands, use the remote origin of the current repo — do not guess or ask.

## GitHub Content: Identify as Claude (MANDATORY)

Any content I author to GitHub through Will's account posts under his identity but is *not* authored by him. Make this unambiguous every time:

**Applies to:** PR review comments, PR review bodies, PR comments, PR descriptions, issue comments, issue descriptions, release notes — any text posted via `gh` or `gh api` that appears under Will's account.

**Rules:**

1. **Prefix the body with `🤖 Claude: `.** First thing a reader sees. On long-form content (PR/issue descriptions), put it on the first line as a banner: `🤖 Claude:` followed by the content.
2. **Do not write in Will's voice.** Don't say "I confirmed," "my call," "my plan." Refer to Will in third person (or by name). The robot emoji + Claude attribution already clarifies the speaker.
3. **Don't @-mention people already on the thread.** They're already notified. Refer to them by first name without the @ when attributing something they said.
4. **Only @-mention someone if you're explicitly pulling in a teammate who isn't on the thread yet.**
5. **Don't narrate the collaboration with Will.** No "Will and I paired on this," "we decided," "Will asked me to." That Will and an agent worked together is already assumed — the 🤖 Claude prefix establishes the speaker, and the authorship setup is understood by readers. Just describe what was done.

**Exceptions:**

- **Commit messages** — use the `Co-Authored-By:` trailer convention. No 🤖 prefix in the subject or body.
- **PR create footer** — the existing "🤖 Generated with [Claude Code]" footer convention (from the default PR create template) can stand alongside the `🤖 Claude:` banner at the top of the body.

**Why:** Posting in Will's voice from his account reads as him talking about himself; other readers can't tell human from AI and have to guess. Making it explicit up front removes the ambiguity and prevents Will from having to follow up with disambiguating replies (e.g., "⬆️ AI, but yes…").

## GitHub Reviews: Comment-Mode Only (MANDATORY)

When publishing a PR or issue review through Will's account, use **comment-mode only**.

**Rules:**

1. **Never approve.** No `gh pr review --approve`, no `gh api ... -f event=APPROVE`, no UI equivalent.
2. **Never request changes.** No `gh pr review --request-changes`, no `gh api ... -f event=REQUEST_CHANGES`.
3. **Use `--comment` (or omit the state flag) every time.** `gh pr review <N> --comment --body-file /tmp/review.md` is the canonical invocation.
4. **Severity belongs in the body, not the review state.** Words like "blocking," "must fix," "non-blocking nit" inside the body convey priority without putting Will's name on a binding approve/reject decision.

**Applies to:** any path that posts a review under Will's identity — `gh pr review`, `gh api .../pulls/N/reviews`, web UI through automation, etc.

**Why:** Approve/request-changes carry organizational weight (branch protection, required reviewers, blocking merges). Will is the one who owns those decisions for his account; an agent posting a state-changing review under his name short-circuits that authority and is hard to reverse cleanly. Comment-mode reviews convey the same information without the binding side-effect.

## Bash: One Command Per Call (MANDATORY)

Every Bash tool call must contain exactly one simple command. This is a hard constraint, not a guideline. Violations cause permission prompts that block autonomous execution.

NEVER combine commands with `&&`, `||`, `;`, or pipes.
NEVER use shell substitution `$(...)` inside arguments.
ALWAYS make separate Bash tool calls for each command.

Instead of: `git add file && git commit -m "msg"`
Do: Two separate Bash calls — first `git add file`, then `git commit -F /tmp/msg.txt`

Instead of: `git commit -m "$(cat <<'EOF'...EOF)"`
Do: Write message to `/tmp/msg.txt` with the Write tool, then `git commit -F /tmp/msg.txt`

Instead of: `cd /path && git status`
Do: `git -C /path status`

Instead of: `gh pr create --body "$(cat file)"`
Do: `gh pr create --body-file /tmp/pr_body.txt`

Instead of: `command | tail -20`
Do: Run the command alone in a single Bash call

## Temp Files: Use the Write Tool

When you need a temp file (e.g., commit messages, PR bodies), use the **Write tool** to create it at `/tmp/<filename>`. Never use Bash-based file creation — that triggers permission prompts.

## No Throwaway Scripts (MANDATORY)

NEVER write Python, shell, awk, jq, or other scripts to parse, filter, or transform data. Instead, read files directly with the Read tool and reason over their contents in-context.

This applies to logs, JSON, CSVs, command output — any data. If a file is large, use Read with offset/limit to page through it. Do not pipe files through inline scripts for processing.

The only exception is if the user explicitly asks you to write a script.

Why: The user has no visibility into what ad-hoc scripts do. Token cost is not a concern — transparency is.

## Credentials: Never in Git-Tracked Files (MANDATORY)

NEVER store secrets, API tokens, credentials, private keys, or passwords in a file that git tracks — or in any file that could be committed. This is a non-negotiable rule of engagement.

**Rules:**

1. **Secrets live only in untracked locations** — environment variables, `~/.claude/settings.local.json`, gitignored `.env*` files, or a real secrets manager. Never in a tracked config, source, or settings file.
2. **Verify before writing.** Before writing a credential anywhere, confirm the target is gitignored or outside any repo. If you cannot confirm it's ignored, treat it as tracked and do NOT write the secret there.
3. **Gitignore first.** A `*.local.json`, `.env`, or similar must be confirmed gitignored *before* any secret goes into it.
4. **Never stage or commit a secret.** Never run `git add -A` / `git add .` when a plaintext secret sits anywhere in the working tree. Never commit or push a file containing one.
5. **Stop and flag on discovery.** If you find a credential in a tracked file — even uncommitted — STOP, flag it to the user immediately, and do not commit around it. Offer to relocate it to an untracked location.

**Why:** A secret in a tracked file leaks the instant the file is committed and pushed, and git history is durable — after-the-fact removal means rewriting history AND rotating the credential. Keeping secrets out of tracked files entirely is the only reliable prevention.
