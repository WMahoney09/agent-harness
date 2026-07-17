# ARTIFACT.spec.md — Canonical Artifact Definition Specification

This file is the authoritative specification for every per-skill `ARTIFACT.md` in this library. It is not itself an artifact definition — it defines the structure that all `skills/*/ARTIFACT.md` files must follow.

## Meta-Instruction Block

Every `ARTIFACT.md` must begin with this block:

```
## Meta

- **Storage:** `Inline` by default — or a concrete target when the artifact is persisted (the plan file, a GitHub PR)
- **Filename:** <defined per skill>
- **Trigger:** <when to generate this artifact>
```

The meta block provides at-a-glance orientation: where the file goes, what it's called, and when it's produced.

## Canonical Sections

| Section | Required | Description |
|---|---|---|
| **Meta** | Yes | Storage location, filename, and trigger condition. |
| **Template** | Yes | Full section structure of the artifact. This is the authoritative template — agents use it verbatim when producing the artifact. |
| **Side Effects** | No | Actions beyond writing the artifact file (e.g., directory creation). Include only when applicable. |
| **Notes** | No | Supplementary guidance, caveats, or design rationale. |

## Inline-Only Pattern

Some skills produce output that is presented in-context but not saved to a file (e.g., `estimate`). For these skills:

- `ARTIFACT.md` still exists and defines the canonical output format
- The **Meta** block uses `Filename: Inline — output is produced in-context, not saved to a file`
- The **Template** section defines the format agents must follow when presenting the output
- No file is written; the artifact is the formatted output itself

## In-Place Update Pattern

Some skills modify an existing file rather than creating a new one (e.g., `atomize` updates the plan file). For these skills:

- The **Meta** block names the target file (e.g., `*.plan.md`)
- The **Template** section documents what changes are made to the target file
- A separate inline output (e.g., a decomposition log) may also be defined

See `atomize/ARTIFACT.md` as the canonical example of this pattern.

## Storage Convention

Skill outputs are **inline by default** — produced in-context in the conversation, not written to disk. Running a skill leaves no files behind.

The one persisted exception is the **plan file**: `planning` writes `docs/plans/<work-item>.plan.md` at the nearest project root, because `pre-flight`, `atomize`, and `produce` operate on it — and `produce` commits `[plan]` progress against it as work proceeds. The `<work-item>` slug is derived from the plan title.

Any persisted artifact must be project-local — never saved to tool-specific directories like `.claude/*`, `.cursor/*`, or home directory conventions like `~/.claude/*`.

## Next Step Block Convention

Artifact templates may include an optional `## Next Step` block as their **last section** (after all other content). This block provides a structured routing signal that an orchestrator (or human) can use to determine what should happen next.

```
## Next Step
Recommendation: <skill-slug or stage-name>
Confidence: high | medium | low
Rationale: <one sentence explaining why>
```

### Convention details

- **Optional.** Only skills participating in conditional routing include this block. Skills outside nudge-driven stages are not expected to adopt it.
- **Always last.** When present, `## Next Step` must be the final section in the artifact template, after all other content sections.
- **Recommendation values** use this convention:
  - **Skill slugs** (lowercase, e.g., `reasoning`, `tire-kicking`) for within-stage routing — dispatching another skill in the same RAPID stage.
  - **Stage names** (capitalized, e.g., `Plan`) for stage advancement — signaling that the current stage is complete and the next RAPID stage should begin.
- **Confidence** indicates how strongly the skill believes this is the right next step. When confidence is `low`, the orchestrator (or user) should consider alternatives before proceeding.
- **Backward routing.** A recommendation that points to an earlier RAPID stage (e.g., `understanding` from within Align) is a backward-routing nudge. These use the skill slug convention (lowercase) because they name a specific skill, but the orchestrator must treat them as abort conditions when it cannot run the target stage. In leeroyyyyy, `understanding` triggers a halt-and-alert-user pattern because Research requires user dialogue.
- **Dual-readable.** The block is both human-readable (for manual workflows) and machine-parseable (for orchestrators like leeroyyyyy).
