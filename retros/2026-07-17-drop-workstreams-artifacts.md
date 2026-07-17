# Retro: dropped the `docs/workstreams/` artifact convention — skills now inline by default

**Date:** 2026-07-17
**Trigger:** Will observed that running the skills left a trail of artifact files (`problem-statement.md`, `truth-and-vector.md`, `review-issues.md`, `triage-report.md`, …) accumulating under `docs/workstreams/<slug>/` and dirtying working directories, and asked whether that convention still earns its keep.
**Status:** Resolved — convention reversed. Skill outputs are inline by default; the plan file is the one persisted exception.

## What happened

The skills library was built around durable, file-based artifacts stored per workstream — originally at `.claude/work/<slug>/`, later migrated to `docs/workstreams/<slug>/` (see the `move-artifacts-to-docs` workstream). Each RAPID skill wrote its output to a file: understanding → `problem-statement.md`, reasoning → `truth-and-vector.md`, review → `review-issues.md`, triage → `triage-report.md`, planning → `<work-item>.plan.md`, and so on.

We decided to drop that convention. Going forward, skill outputs are produced **inline in the conversation** and nothing is written to disk — with a single deliberate exception, the plan file (see "What we kept").

## Root cause — why the convention existed, and why it no longer earns its keep

The artifacts existed to **export context into a fresh window.** In early practice this was a multi-agent relay: one agent built an understanding and wrote it to a file; a *new* solutioning agent picked that file up and produced solution candidates; a *new* planning agent consumed those and produced a plan; a *new* implementer agent executed against the plan. Each handoff crossed a context boundary, so the artifact on disk *was* the medium of transfer — the only way to carry state from one fresh, forgetful agent to the next.

That made sense **for the tools of the time.** Context windows were small and agents were, frankly, not that capable — you couldn't hold understanding → solutioning → planning → implementation in a single coherent session, so you decomposed the pipeline across agents and paid the cost of serializing state to files between them.

That premise no longer holds. With Sonnet 5, Opus 4.8 (1M context), and Fable 5 when we're lucky, a single agent holds the whole arc — discovery through implementation — in one window without breaking a sweat. The cross-window handoff the artifacts existed to enable is now unnecessary. What's left is pure cost: a trail of noise files that dirty the working directory, get committed or `.gitignore`'d, drift out of sync with the conversation, and help no one.

**The tools evolved; the process must evolve with them.** Keeping a file-export protocol designed for weak, small-context agents is cargo-culting an obsolete constraint.

## What we kept

- **The plan file.** `planning` still writes `docs/plans/<work-item>.plan.md`. This one is not a context-export artifact — it's a live working document that `pre-flight`, `atomize`, and `produce` operate on, and that `produce` commits `[plan]` progress against as phases complete. It earns its persistence functionally, independent of any multi-agent handoff. We moved it out of the per-workstream directory (`docs/workstreams/<slug>/`) to a flat `docs/plans/` so there's no leftover directory ceremony around it.
- **The `ARTIFACT.md` mechanism itself.** Each skill still declares its output format in a co-located `ARTIFACT.md`, governed by `ARTIFACT.spec.md`. What changed is the *storage* those specs mandate (inline vs. file), not the practice of specifying an output shape. The templates are still the authoritative format for the inline output.

## What we changed

- **`skills/ARTIFACT.spec.md`** — rewrote the Storage Convention and Meta block: inline by default, plan file the sole persisted exception.
- **`CLAUDE.md`** — replaced the "Docs convention" section to match.
- **Converted to inline** (`ARTIFACT.md` + `SKILL.md`): `understanding`, `reasoning`, `review`, `triage`. `understanding` no longer creates a workstream directory or emits a "Workstream Slug"; the plan slug is now derived from the plan title at planning time.
- **Fixed stale storage lines** on the already-inline `pre-flight` and `estimate` (they still named `docs/workstreams/`).
- **`planning`** — plan output relocated to `docs/plans/<work-item>.plan.md`.
- **`pull-request`, `retro`** — dropped the assumption that problem/solution statements exist as files in a workstream directory.

## Open / future improvements

- **Historical records left in place.** The harness's own `docs/workstreams/*` dev records (e.g., `move-artifacts-to-docs`, `uml-skill`) and `docs/reference/rapid-v1-readme.md` still reference the old convention. They're intentionally preserved as history — we don't rewrite past decisions. If they become confusing, sweep them in a separate pass.
- **Consuming projects with existing `docs/workstreams/` dirs.** Projects that ran the old skills (e.g., `cdd/agent-skills`) still carry those directories. No migration is forced; they'll simply stop accruing new files.
- **If a genuine cross-agent handoff returns** (e.g., a future workflow that deliberately fans out across isolated agents that can't share context), reach for an explicit, scoped artifact for *that* handoff — don't reinstate blanket file-writing across every skill.

## Skill observations

- The whole RAPID skill set assumed file-based handoffs as the default; that assumption was load-bearing in the specs but not in current practice. Making inline the default aligns the skills with how they're actually run today — one capable agent, one window.
