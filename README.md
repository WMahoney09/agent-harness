# Agent Harness

Will's Claude Code harness — a single repository for everything Claude Code reads at the user level. Skills, agents, hooks, global instructions, settings, and statusline all live here. `setup.sh` symlinks each piece into the install location Claude Code expects.

---

## Layout

```
agent-harness/
  README.md
  CLAUDE.md          ← contributor guide (loaded when cwd is this repo)
  setup.sh           ← install script

  skills/            → ~/.claude/skills
  agents/            → ~/.claude/agents
  hooks/             → ~/.claude/hooks
  user/
    CLAUDE.md          → ~/.claude/CLAUDE.md (global instructions)
    settings.json      → ~/.claude/settings.json
    statusline.sh      → ~/.config/claude-code/statusline.sh

  retros/            ← harness decision records (not installed)
  docs/              ← repo docs (not installed)
```

---

## Three-Layer Architecture

| Layer | Role | Example |
|-------|------|---------|
| **Mission** (strategy) | Overall goal — from a human or a mission file | "Ship features from the issue backlog" |
| **Agent definitions** (sub-strategy) | Role-based templates with composed skill sets | `senior-dev`, `reviewer`, `planner` |
| **Skills** (tactics) | Individual tools encoding domain expertise | `/planning`, `/produce`, `/review` |

The mission provides the goal. Agent definitions provide the role and quality gate awareness. Skills provide the domain expertise. The model decides how to use them.

---

## Agent Definitions

Role-based agent templates that compose skills into areas of responsibility. Defined in `agents/` and symlinked from `~/.claude/agents/`.

| Agent | Role | Skills |
|-------|------|--------|
| **`senior-dev`** | Implementation and delivery. Plans, implements, reviews, ships. | planning, pre-flight, produce, commit, review, revise, pull-request, estimate |
| **`reviewer`** | Code review specialist. Reviews changes, publishes findings, responds to feedback. | review, publish-review, reply, triage, revise |
| **`planner`** | Technical architect. Breaks down goals into validated plans. Does not implement. | understanding, reasoning, planning, pre-flight, estimate |

Agent definitions are role templates, not personalities. When composing teams, personality and perspective can be layered on top at team creation time.

---

## Quality Gates

Logical constraints that agents respect. Not a prescribed sequence — agents decide when and how to use their tools, but these constraints hold:

1. **Plan before implement** — `/produce` requires a committed plan file
2. **Pre-flight before implement** — `/pre-flight` must report no Critical issues before `/produce` runs
3. **Review after implement** — `/review` must run after `/produce`, ideally via a fresh agent context
4. **Address before deliver** — Critical/Major findings from `/review` must be addressed via `/revise` before `/pull-request`

---

## Skills

### Discover

Tools for exploring problems and building clarity. Primarily for human-paired work.

- **`/understanding`** — Build shared understanding of a problem through discovery. Produces `problem-statement.md`.
- **`/clarify`** — Ask clarifying questions to sharpen understanding.
- **`/reasoning`** — Extract truths, conditionals, and a directional vector from complex problems.
- **`/terse`** — Respond in terse bullet form; bare `/terse` resynthesizes the previous response for quick scanning.

### Plan

Tools for defining and validating the work.

- **`/planning`** — Create a detailed implementation plan (Phase > Step > Task) with phase right-sizing. Produces `<work-item>.plan.md`.
- **`/pre-flight`** — Validate a plan for gaps, contradictions, and opportunities. The highest-value quality gate.
- **`/estimate`** — Produce an LOE score (1–5) by evaluating complexity and impact.

### Implement

Tools for building the work.

- **`/produce`** — Execute an implementation plan autonomously with semantically coherent atomic commits.
- **`/commit`** — Stage and commit with typed convention (`[plan]`, `[docs]`, `[code]`).

### Deliver

Tools for shipping and iterating on the work.

- **`/pull-request`** — Open a PR with structured description, issue links, and test plan.
- **`/review`** — Technical peer review covering security, architecture, correctness, tests, accessibility. Produces `review-issues.md`.
- **`/triage`** — Ingest feedback and group into unified, prioritized revisions. Produces `triage-report.md`.
- **`/revise`** — Address a discrete revision with alignment check and implementation.
- **`/reply`** — Close the feedback loop by replying to PR comments with addressing commits.
- **`/publish-review`** — Publish review findings as inline PR comments anchored to diff lines.

**Two paths to revision:**
- **Self-review:** `/review` → `/revise` — review output feeds directly into revise.
- **External feedback:** PR comments → `/triage` → `/revise` — triage normalizes unstructured feedback.

### Reflect

Tools for understanding and improving.

- **`/retro`** — Run a session retrospective. Findings either apply in-situ or produce an ADR in `retros/` for cross-cutting harness changes.
- **`/uml`** — Produce ASCII UML diagrams (sequence and component) to map code topology.

---

## Hooks

Deterministic pre/post-tool-use hooks live in `hooks/` and are wired in `user/settings.json`.

| Hook | When it fires | What it does |
|---|---|---|
| `block-pr-review-state.sh` | `PreToolUse` on `Bash` | Blocks `gh pr review --approve`/`--request-changes` and equivalent `gh api .../reviews -f event=APPROVE/REQUEST_CHANGES`. Comment-mode is the only allowed state for reviews posted under Will's account. |

---

## Retros (Decision Log)

`retros/` holds ADR-style records for harness-shaping decisions. Entries explain *why* the harness looks the way it does — useful when reading a hook, a rule in `user/CLAUDE.md`, or a skill change months after the fact.

Not every retro produces an entry here. Project-specific findings get applied in-situ to the consuming project. Small harness tweaks (e.g., a skill description edit) go straight into the file. Only cross-cutting decisions that need preserved reasoning live in `retros/`.

---

## Installation

```sh
./setup.sh
```

Idempotent. Creates symlinks from the expected Claude Code locations (`~/.claude/*`, `~/.config/claude-code/statusline.sh`) into this repo. Backs up existing files. Registers MCP servers (context7, render, vercel, figma) with the `claude` CLI.

---

## Conventions

### Skill file structure

Every skill directory contains a `SKILL.md` conforming to [`skills/SKILL.spec.md`](./skills/SKILL.spec.md). Skills that produce artifacts also contain an `ARTIFACT.md` conforming to [`skills/ARTIFACT.spec.md`](./skills/ARTIFACT.spec.md).

### Commit convention

`/commit` defines typed prefixes (`[plan]`, `[docs]`, `[code]`) determined mechanically by files changed. Referenced by `/produce` and other skills for consistent git history.

### LOE framework

`/estimate` defines the LOE scoring framework (Complexity × Impact → 1–5). Referenced by `/planning` for phase right-sizing.

---

## How skills work

Skills are stored in directories with a `SKILL.md` file inside. Each skill includes YAML frontmatter specifying `name` and `description`, which determines the `/slash-command` and invocation behavior.

## Where things live

| Type | Path | Scope |
|------|------|-------|
| Skills (personal) | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Skills (project) | `.claude/skills/<name>/SKILL.md` | One project |
| Agents (personal) | `~/.claude/agents/<name>.md` | All your projects |
| Agents (project) | `.claude/agents/<name>.md` | One project |

## Sources

- [Agent Skills](https://agentskills.io/home)
- [Extend Claude with skills](https://code.claude.com/docs/en/skills)
- [Sub-agents](https://code.claude.com/docs/en/sub-agents)
