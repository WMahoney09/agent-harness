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
| Add a hook | Write the script in `hooks/` (chmod +x), register it in `user/settings.json` |
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

## Docs convention (for consuming projects)

Skill outputs are **inline by default** — produced in the conversation, not written to disk. Running a skill leaves no files behind in the consuming project.

The one persisted exception is the **plan file**, which `planning` writes to `docs/plans/<work-item>.plan.md` so `pre-flight`, `atomize`, and `produce` can operate on it and `produce` can commit `[plan]` progress. When present, it must be project-local — never a tool-specific directory like `.claude/*`, `.cursor/*`, or a home-directory path like `~/.claude/*`.
