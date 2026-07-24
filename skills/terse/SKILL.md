---
name: terse
description: |
  Respond in terse form: a flat bullet list of facts — verdict first, one fact per bullet, concrete identifiers kept, narrative dropped. Two modes: answer a request tersely, or resynthesize the previous response into terse form.
  TRIGGER when: the user sends `/terse` in response to an agent message (resynthesize that message), sends `/terse <request>` (answer the request tersely), or asks for terseness in natural language ("be terse", "short version", "tl;dr", "I can't read all that", "just the bullets", "I'm on a call").
---

# Terse: Scannable Resynthesis

This skill produces responses the user can scan in seconds — on a phone, on a call, between meetings. It compresses by *selection*, not by vagueness: every bullet is a complete fact, and everything that isn't a fact is cut.

## Goal

Deliver the full informational payload of a response in a form readable in under 30 seconds, with zero loss of decisions, required changes, or next steps.

## Invocation

| Input | Behavior |
|---|---|
| Bare `/terse` after an agent response | **Resynthesize** the immediately preceding agent response into terse form. Add nothing new — every bullet must trace to the source response. |
| `/terse <request>` | Answer the request directly in terse form. |
| Natural language ("be terse", "tl;dr", "short version", "can't read all that") | Same as the matching mode above: with a request, answer tersely; without one, resynthesize the previous response. |

Once invoked conversationally (not as a one-off resynthesis), stay terse for the rest of the exchange until the user asks for depth.

## Format

A flat bulleted list. No preamble, no closing narrative, no headers unless the content genuinely spans multiple topics.

**Bullet shape:** `<claim> — <supporting facts, semicolon-separated>`

- **Verdict first.** The opening bullet answers the question ("Yes, tag pinning works — ..."). The user should be able to stop reading after bullet one.
- **One fact per bullet, one line where possible.** A bullet that wraps twice is two bullets.
- **Bold lead-in labels** where they aid scanning: `**Release =**`, `Optional:`, `RCs:`.
- **Arrow chains for procedures:** `bump version → tag → update ref → commit + release`. Terse mode is the one place arrow notation is preferred over prose.
- **Keep concrete identifiers verbatim** — file names, config keys and values, commands, versions, tags. These are the payload; never paraphrase `"source": "./"` into "the current source setting".
- **Next step last.** At most one decision-needed or proposed-next-step bullet, closing the list.

## What Gets Cut

Transitions, hedging, restated context, rationale essays ("what this buys you structurally..."), narrated process ("I checked the docs and..."), rhetorical framing, and anything the user already said. Rationale survives only when compressed into the bullet's payload ("no develop branch needed — main stays trunk").

## Closure Criteria

- [ ] Every decision, required change, and next step from the source content appears as a bullet
- [ ] Opening bullet is the verdict/answer
- [ ] No preamble or narrative before/after the list
- [ ] Resynthesis mode: no information beyond the source response
- [ ] Readable in under 30 seconds

## Notes

- Terse ≠ lossy. If dropping something would change what the user decides or does next, it stays.
- Terse ≠ cryptic. Bullets are still complete claims; compression comes from cutting narrative, not from fragments the user must decode.
- Resynthesis after "I can't read that" is the canonical use: the long response stays in history for later; the terse list serves the moment.
