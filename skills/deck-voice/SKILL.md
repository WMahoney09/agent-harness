---
name: deck-voice
description: |
  Voice and cadence rules for generated presentation content — slide bodies, speaker notes, card copy, section closers. Write the shortest sentence that carries the point and stop. Two modes: draft new content under the rules, or sweep an existing deck and produce a rewrite spec.
  TRIGGER when: the user asks for slides or a deck ("make me a deck", "build slides for X", "presentation on Y", "add a slide"), asks to revise or tighten deck copy ("tighten these slides", "the notes are too wordy", "sweep the deck"), or edits any existing slide body or speaker note. Also applies to long-form generated prose the user will read aloud or present.
---

# Deck Voice

Rules for the verbiage and cadence of generated presentation content. They apply to every line the author writes or edits — slide bodies and speaker notes both — not only to the lines called out in a review.

This file is self-contained. It repeats the rules from `user/CLAUDE.md` that matter most here, because the surfaces that generate decks (Cowork, claude.ai) do not load that file.

## Goal

Deck copy a reader absorbs at a glance and a presenter can say out loud without stumbling. Every sentence carries new information. Nothing restates, softens, or explains the sentence above it.

## Invocation

| Input | Behavior |
|---|---|
| A request for new slides or deck content | **Draft mode.** Write under the rules below from the first draft. Do not write loose copy and tighten later. |
| A request to tighten, sweep, or revise an existing deck | **Sweep mode.** Produce a rewrite spec: universal rules first, then per-slide `original → replacement` lines. See *Sweep mode* below. |
| Any edit to an existing slide or note | Rules apply to the edited line, whether or not the edit was about voice. |

## The Rules

### 1. No em dashes

Use periods, commas, semicolons, or parentheses. Slide text is scanned and read aloud; an em dash asks the reader to hold a clause in suspension, which is the one thing a slide cannot afford.

This rule is scoped to deck content. Em dashes remain house style in conversation, PRs, docs, and code comments.

### 2. Trust the reader

Cut sentences that restate what the previous sentence carried, spell out an obvious implication, or explain why the point matters. If the audience can get there from the line above, they will.

### 3. No aphoristic pairs

A second sentence that rewords the first is a wasted line.

> "The pilot showed the ideas work. The new platform lets them run."
> → "The pilot showed the ideas work."

### 4. No "That's why X" / "That's how Y" tails

Self-explanations tacked onto an observation. Cut the tail; the observation stands.

> "When the system can't validate, define, or hold the work, people fill in. That's why it's manual."
> → "When the system can't validate, define, or hold the work, people fill in."

### 5. No "and we'll [do the obvious thing]" tails

> "Tell us where and why, and we'll sharpen it."
> → "Tell us what's wrong."

### 6. No parallel-triplet constructions

Three clauses in the same shape ("When X, Y" / "When A, B" / "When C, D") read as rhythm, not as content. Use however many are true.

### 7. Cut empty intensifiers

`actually`, `precisely`, `finally`, `genuinely`, `real`, `truly`. They add emphasis, never information.

> "Orders finally relate to each other." → "Orders relate to each other."
> "Six weeks deep in how the platform actually works." → "Six weeks in how the platform works."

### 8. No metaphors for pace, scale, or altitude

"a beat every two or three," "same territory different altitude," "30,000 feet." Say the thing directly.

> "Same territory, different altitude." → "Different questions."

### 9. No framing prefixes

"The rhythm:", "The bill:", "The result:", "Close on:", "The bridge:". Delete the prefix and keep the sentence.

> "The bridge: the model's unfinished edges are precisely the six decisions on the next slide."
> → "The model's unfinished edges are the six decisions on the next slide."

### Also in force

Carried from the global prose rules, restated here because they break decks the same way:

- **No antithesis.** Never set up a wrong answer to knock down. "This isn't a refactor, it's a rewrite" → "This is a rewrite." Watch the softer forms too: "less about X, more about Y," "rather than X, this Y."
- **No rhetorical question then answer.** "The problem? Two callers share the mutex."
- **No participial tails.** "…ensuring alignment," "…allowing the team to move faster."
- **No punchline endings.** No closing aphorism on a slide, no zinger last line in a note.
- **Cut inflation:** robust, comprehensive, seamless, powerful, crucial, leverage, streamline, elevate, unlock, "deep dive," "under the hood," "at its core."
- **Verdict first.** The headline carries the answer. Support follows.

## Sweep Mode

When revising an existing deck, produce a rewrite spec rather than a silently edited file. The spec has two parts:

1. **Universal rules** — the rules above, stated once at the top, applying across the whole deck.
2. **Per-slide changes** — grouped by slide, each an `original → replacement` line. Say which rule each change serves when it is not self-evident. Name slides that need no changes explicitly ("Slide 7 — no changes").

Close the spec with the standing instruction: apply the universal rules to any line added or edited in future revisions, not only the lines listed.

## Closure Criteria

- [ ] No em dashes in any slide body or speaker note
- [ ] No sentence restates, softens, or explains the sentence above it
- [ ] No "That's why," "That's how," or "and we'll" tails
- [ ] No framing prefixes, pace/altitude metaphors, or parallel triplets
- [ ] Empty intensifiers cut
- [ ] Sweep mode: every changed line shown as `original → replacement`, unchanged slides named

## Notes

- The rules govern *added and edited* lines in every future revision, not just the ones flagged in a given pass.
- Cutting a line is a valid rewrite. When a sentence exists only to restate or justify the one above it, the replacement is nothing.
- Terse is not vague. Compression comes from cutting restatement and framing, never from dropping the fact the slide exists to deliver.
- For Cowork or claude.ai, this file has to be uploaded to that surface's own skill library. The symlink into `~/.claude/skills/` only reaches Claude Code.
