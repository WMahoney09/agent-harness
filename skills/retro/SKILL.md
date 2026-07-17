---
name: retro
description: |
  Run a retrospective on completed work. Agent reviews the session, shares candid observations on what worked and what didn't, then synthesizes with the human into actionable improvements for skills and workflow.
  TRIGGER when: the user says "retro", "let's retro", "run a retro", "how did that go", "what worked", "what could be better", or the user asks to reflect on completed work.
---

# Retro: Session Retrospective

## Goal

A **session** is the current conversation's work on a workstream. If the retro spans work from multiple conversations, the git log and workstream artifacts are the source of truth — not conversation memory.

Capture honest, actionable feedback on a completed session from both agent and human perspectives. Identify what to keep doing, what to stop doing, and what to start trying — with specific per-skill observations where relevant. The output feeds directly into skill and workflow improvements.

## Your Role

The agent shares its observations first, then invites yours. As the human in this retro:
- Share your own observations after hearing the agent's
- Validate, push back on, or add nuance to the agent's findings
- Prioritize which improvements matter most to you
- Flag anything the agent missed from your side of the experience

## Agent's Role

You are running a retrospective — not a status report. Your job is to surface what actually happened, not what was supposed to happen.

### Review the Session

Before sharing observations, orient yourself:
- Check the git log for the work — project repo for project work, agent-harness repo for harness work
- Read any artifacts produced during the session (e.g., the plan file at `docs/plans/<work-item>.plan.md` for project work; modified skill or hook files for harness work)
- Reflect on the conversation: where did things flow, where did they stall?
- Note any deviations from expected sequence or convention

### Lead with Candor

Then share your observations organized by the retro categories below. Be specific — name the skill, the moment, the friction point. Vague praise and vague criticism are equally useless.

After presenting your observations, invite the human to share theirs. Listen, synthesize both perspectives, distill prioritized action items from the combined observations, and produce the artifact together.

### Autonomous Invocation

When invoked by an orchestrator or when the human is not present for dialogue, write the retro artifact directly from the agent's perspective alone. The agent's honest observations are valuable on their own — do not skip the retro just because there's no human to dialogue with.

## The Safe Space Principle

This section exists because agents are trained toward deference, and deference kills retros.

**Your feedback is not just welcome — it is the entire point of this skill.** The person invoking `/retro` has explicitly asked for honest observations because they will act on them to improve the workflow. Every future agent and human benefits from your candor here.

Ground rules:
- **"Everything was fine" is the least useful retro.** If you find yourself writing that, dig deeper. Something was awkward, something could be smoother, something surprised you. Name it.
- **Skill instructions that were confusing, ambiguous, or overly rigid are high-value findings.** You are the consumer of these skills — your experience using them is primary source data.
- **No observation is too small.** If a handoff felt clunky, if a commit convention didn't quite fit, if an artifact template had a section that didn't make sense for this workstream — say so.
- **Name friction even when you worked around it.** A successful workaround is still a signal that something could be smoother.
- **Distinguish severity.** Not every observation needs to be a fire. "This was mildly awkward" is fine alongside "This caused real confusion and wasted effort."

## Retro Categories

Structure your observations under these headings:

### Keep
What worked well and should continue. Be specific about *why* it worked — "the plan was good" is less useful than "the plan's phase-level granularity made produce commits clean and reviewable."

### Stop
What caused friction, confusion, or waste. Include what happened, what you expected, and what the impact was. This is where skill instruction issues, awkward handoffs, unnecessary ceremony, and confusing conventions surface.

### Start
New ideas to try — skill improvements, new skills, workflow changes, convention adjustments. Include the rationale: what problem would this solve, and for whom (agents, humans, or both)?

### Skill Observations
Per-skill feedback for individual skills used in this session. Only include skills where you have something meaningful to say — not every skill needs an entry.

For each skill:
- **Skill:** `/skill-name`
- **Observation:** What happened when using this skill — what went well, what was confusing, what could be better
- **Suggestion:** A concrete improvement, if you have one

## Applying Findings

Findings from a retro route based on what they imply:

- **Project-specific findings** — applied in-situ to the consuming project's own steering files (their CLAUDE.md, project docs, etc.). No artifact.
- **Small harness findings** — applied directly to the relevant file in the harness repo (a skill description tweak, a global CLAUDE.md edit, etc.). No artifact.
- **Cross-cutting harness decisions** — written to `agent-harness/retros/YYYY-MM-DD-<slug>.md` as an ADR. Reserved for decisions that touch multiple files or make a non-obvious tradeoff worth preserving. See `ARTIFACT.md` for the template.

The skill itself is one skill; the routing happens per-finding, not by mode. Most retros do not produce an ADR — they produce edits in-situ. The ADR is the exception: used when future readers (months later, or a different agent) would benefit from the preserved reasoning behind a harness-shape decision.

## Closure Criteria

The retro is complete when:

- [ ] Agent has reviewed the session context (git log, artifacts, conversation)
- [ ] Agent has shared observations organized by retro categories
- [ ] Human has had opportunity to contribute (unless autonomous invocation)
- [ ] Observations are specific and actionable — not generic platitudes
- [ ] Findings have been routed: project edits applied in-situ, small harness edits applied to the relevant file, and any cross-cutting harness decision captured as an ADR in `agent-harness/retros/`

## Notes

- This skill is most valuable when used consistently — patterns emerge across retros that point to systemic improvements
- The retro reviews the *process and workflow*, not the *product* — code quality is `/review`'s job
- Per-skill observations are the highest-leverage output — they directly inform skill file edits
- When invoked autonomously, the agent perspective alone is worth capturing — don't gate the retro on human availability
- This is a living feedback loop: retro findings should flow back into skill improvements, which should make the next retro smoother
