# Agent Harness — Project Instructions

This repository is the single source of truth for Will's Claude Code harness. It contains everything Claude Code reads at the user level:

| Component | What it is | Where it installs to |
|---|---|---|
| `skills/` | Slash-command skills | `~/.claude/skills/` (symlinked dir) |
| `agents/` | Role-based agent definitions | `~/.claude/agents/` (symlinked dir) |
| `hooks/` | Hook scripts referenced by `user/settings.json` | `~/.claude/hooks/` (symlinked dir) |
| `user/CLAUDE.md` | Always-loaded global instructions | `~/.claude/CLAUDE.md` |
| `user/settings.json` | Permissions, hooks config, statusline, etc. | `~/.claude/settings.json` |
| `user/statusline.sh` | Status line script | `~/.config/claude-code/statusline.sh` |
| `retros/` | ADR-style decision records for harness changes | not installed; read in place |
| `docs/` | Repo docs | not installed |

`setup.sh` performs the install (symlinks + MCP server registrations). Edit files in this repo; Claude Code sees changes immediately through the symlinks.

## Two distribution paths

The repo installs two ways, and both read the same directories:

| Path | Mechanism | Used by |
|---|---|---|
| Symlinks | `setup.sh` links `skills/`, `agents/`, `hooks/`, `user/*` into `~/.claude/` | Will's primary machine |
| Plugin | `.claude-plugin/marketplace.json` declares the repo root as the `agent-harness` plugin | Cowork, other machines |

Consequences for anything added here:

- A new skill or agent reaches both paths with no extra step. Directory scan is the definition.
- A new **hook** needs registering twice: in `user/settings.json` for the symlink path, and in `hooks/hooks.json` for the plugin path. Plugin hook commands must use `${CLAUDE_PLUGIN_ROOT}`, never `~/.claude/`.
- Skills must not assume `user/CLAUDE.md` is loaded implicitly. On the plugin path it arrives through a `SessionStart` hook, and on claude.ai it does not arrive at all. A skill with a hard dependency on a rule should restate it, as `deck-voice` does.
- Cowork has no shell, no `git`, and no `gh`. Skills that need them still install there and simply do not apply. Do not add tool assumptions to a skill that could be written without them.
- Run `claude plugin validate .` after touching `.claude-plugin/*`, `hooks/hooks.json`, or any frontmatter. Expect a clean report; any warning is a real problem.
- **Bump `version` in `.claude-plugin/plugin.json` in the same commit as any change that ships.** Installs pin to that number and stay there until it moves. While the major stays at `0`: new skill or agent → minor; edits inside an existing one → patch; a removal or rename that breaks a caller → minor. Docs-only edits (`README.md`, `docs/`, `retros/`) need no bump.

## Working in this repo

Always edit files in this project directory, not in `~/.claude/` directly. Changes propagate via the symlinks.

### Operations reference

| Task | What to do |
|---|---|
| Create a skill | `mkdir skills/<name>` → write `skills/<name>/SKILL.md` |
| Edit a skill | Edit `skills/<name>/SKILL.md` |
| Delete a skill | Remove `skills/<name>/` |
| Rename a skill | Rename the directory; update `name:` in frontmatter; update README |
| Create an agent | Write `agents/<name>.md` with YAML frontmatter |
| Edit an agent | Edit `agents/<name>.md` |
| Add a hook | Write the script in `hooks/` (chmod +x), register it in `user/settings.json` **and** in `hooks/hooks.json` |
| Edit global CLAUDE.md | Edit `user/CLAUDE.md` (this is what loads in every conversation) |
| Edit global settings | Edit `user/settings.json` |

Always follow the README sync rule below.

## Retros

Findings from `/retro` route based on scope:

- **Project-specific findings** — applied in-situ to the consuming project's own steering files (their `CLAUDE.md`, their docs). No artifact written.
- **Small harness findings** — applied directly to the relevant file in this repo (a skill description tweak, a global CLAUDE.md edit). No artifact.
- **Cross-cutting harness decisions** — written to `retros/YYYY-MM-DD-<slug>.md` as an ADR. Reserved for changes that touch multiple files or make a non-obvious decision worth preserving (e.g., the comment-mode-only rule that became a `CLAUDE.md` section *and* a hook).

The retros directory is a decision log explaining *why the harness looks the way it does today*. Future readers (human or agent) should be able to reconstruct the reasoning behind harness shape from these entries.

## README sync rule

When any skill, agent, or hook is added, updated, removed, or renamed in this repository, update `README.md` to reflect the change.

### Checklist

- [ ] Component file/directory exists (or has been removed)
- [ ] README listing updated

## No client names in shipped files (MANDATORY)

This repository is public. Every skill, agent, hook, README, and `user/CLAUDE.md` line in it is readable by anyone, and git history keeps whatever ships in it permanently.

Examples drawn from real work are the best examples — keep drawing them, and strip the identity before committing. Replace the client, project, and product name with a generic stand-in (`<project>`, "the platform", "the pilot", "the technical approach doc"). The lesson an example teaches never depends on whose engagement it came from.

Applies to: client and prospect names, project code names, client-domain email addresses, client repository and Bitbucket paths, and document titles that carry any of those. Also to real people outside Gnar. Not to Gnar's own name.

Two exemptions, both deliberate:

- **`retros/`** — a decision log where the real trigger is the record. A retro that genericizes its own cause stops explaining why the harness looks the way it does.
- **The GitHub Identity block in `user/CLAUDE.md`** — the org list is how an agent resolves `{owner}` for `gh` commands, so it is configuration rather than an example.

Before committing a skill or doc change, grep the diff for the names of current engagements. A name that ships cannot be recalled by editing the working tree.

## Docs convention (for consuming projects)

Skill outputs are **inline by default** — produced in the conversation, not written to disk. Running a skill leaves no files behind in the consuming project.

The one persisted exception is the **plan file**, which `planning` writes to `docs/plans/<work-item>.plan.md` so `pre-flight`, `atomize`, and `produce` can operate on it and `produce` can commit `[plan]` progress. When present, it must be project-local — never a tool-specific directory like `.claude/*`, `.cursor/*`, or a home-directory path like `~/.claude/*`.
