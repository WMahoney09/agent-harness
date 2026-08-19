---
name: elif
description: |
  Explain Like I'm Five: re-explain something in plain words for a capable reader who is outside their domain. Two modes: explain a topic on request, or re-explain the previous response. Translates jargon; keeps every fact, identifier, and caveat intact.
  TRIGGER when: the user sends `/elif` in response to an agent message (re-explain that message), sends `/elif <thing>` (explain that thing), or asks in natural language ("I don't understand", "what does that mean", "explain that", "ELI5", "in plain English", "pretend I don't know what X is", "you lost me").
---

# ELIF: Explain Like I'm Five

This skill makes an explanation followable by someone who does not already know the terms in it. `/terse` cuts words; `/elif` swaps vocabulary. The output can run longer than what it replaces.

The name is shorthand for "put it in plain terms," not a literal audience. See **Who This Is For** before calibrating anything.

## Goal

The user finishes reading and can restate what happens, why it matters to them, and what the unfamiliar term means — without looking anything up.

## Who This Is For

An experienced technologist and product person who is currently outside their depth on one subject. They ship software, run projects, and read code. What they lack is the vocabulary of *this particular* domain — a protocol, a framework, a financial concept, an infrastructure layer they've never operated.

Calibrate to that reader:

- **Assume general fluency.** APIs, databases, branches, deploys, tickets, environments, tokens, queues, caching, CI — these need no gloss. Explaining them wastes the user's time and reads as talking down.
- **Explain the unfamiliar layer.** The domain-specific term, the acronym from the vendor's docs, the concept that is load-bearing here and appears nowhere else in their work.
- **When unsure, gloss it in four words inside the sentence** rather than pausing to teach it. `the WAL (the write-ahead log Postgres appends to)` costs the user nothing if they already knew it.
- **Ask instead of guessing on a wide gap.** If half the answer sits in unfamiliar territory, one question — "how much of Kafka's consumer-group model do you already have?" — beats an explanation pitched at the wrong level.

The failure modes are symmetric: unexplained jargon leaves the user stuck, and re-explaining what they already know insults them and buries the part they needed.

## Invocation

| Input | Behavior |
|---|---|
| Bare `/elif` after an agent response | **Re-explain** the immediately preceding agent response. Same claims, plain vocabulary. Add no new conclusions. |
| `/elif <thing>` | Explain that thing directly, in plain form, from scratch. |
| Natural language ("I don't follow", "what's a mutex", "in plain English") | Same as the matching mode above: with a subject, explain it; without one, re-explain the previous response. |

Stay plain for the rest of the exchange until the user signals they're back on solid ground.

**Scope the target.** When the user points at a specific term or sentence, explain that and leave the rest alone. When the confusion is unscoped, pick the load-bearing unknown — the one term the rest of the answer rests on — and start there.

## The Ladder

Work in this order. Stop when the user has what they need; not every rung is needed every time.

1. **What happens, in everyday words.** One sentence, no terms of art. "Two parts of the program try to write the same file at the same moment, and one of them loses."
2. **Name the jargon once, attached to the plain wording.** `a mutex (a lock that lets one thing use a resource at a time)`. The real term stays so the user recognizes it next time and can search it.
3. **A concrete instance, with the real values.** Use the actual file, command, number, or error from the situation at hand. Invented examples are a last resort, for when no real one exists yet.
4. **An analogy only when the mechanism matches** — and say where it stops matching. "A queue is like a line at a counter, except items can be dropped from the middle."
5. **Why it matters here.** What changes for the user: what breaks, what it costs, what they now have to decide.

## Rules

- **Simplify the vocabulary, never the facts.** File names, commands, config keys, versions, and error text stay verbatim. Approximating `"source": "./"` into "the folder setting" is the failure mode this skill exists to prevent.
- **Spell out every acronym on first use, then use it freely.** `WAL (write-ahead log)`, `SLO (service level objective)`, `RAG (retrieval-augmented generation)`. Expansion happens once per response — a long thread doesn't need it re-expanded in every message, but a fresh response that leads with a bare acronym is a miss. Acronyms on the general-fluency list (API, URL, CI, PR, JSON, SQL) are ordinary words and need no expansion. When the expansion alone doesn't make it clear, add the four-word gloss too: `SLO (service level objective — the reliability target you promise)`.
- **One unknown at a time.** If explaining term A requires term B, either explain B first or find a path that doesn't need it. Never define jargon with more jargon.
- **Keep the caveats.** A qualifier that changes what the user should do survives the translation. Say it plainly: "this only works when the file is already committed."
- **Explain the thing, not the process.** No account of what was checked, read, or considered.
- **No condescension.** Cut "simply," "just," "obviously," "as you know," "it's easy." The five in the name sets the vocabulary level, and says nothing about the reader.
- **Don't re-teach the fundamentals.** Skip the paragraph on what a database or a pull request is. Spend the words on the layer that is actually new to the user, and cut the rest.
- **No cartoon analogies.** Lemonade stands, pizza slices, and toy boxes are barred unless the mechanism genuinely maps and no real example is available.
- **Plain is not long.** Short sentences, short paragraphs, prose over bullets. A wall of simple words is still a wall.
- **Admit the edge.** When the plain version leaves something out, say so in one sentence: "the full rule has more cases, but this covers what you hit."

## Closure Criteria

- [ ] Every term of art from the source is either defined in place or removed
- [ ] Nothing a working engineer or PM already knows got re-taught
- [ ] Every non-obvious acronym is spelled out at its first appearance in the response
- [ ] Every fact, identifier, and caveat from the source survives unchanged
- [ ] The opening sentence carries the answer in everyday words
- [ ] No new claims introduced beyond the source (re-explain mode)
- [ ] The user could restate it back in their own words

## Notes

- `/elif` and `/terse` compose. Terse-then-ELIF is the common pair: the short list, then the one term in it that didn't land.
- Re-explain mode leaves the original response in history. The plain version serves the moment; the precise version is still there to return to.
- The tell that this worked is the user asking a sharper follow-up question. The tell that it failed is the user asking the same question again.
- The name is a mood setting, picked because it's the phrase everyone recognizes for "drop the jargon." Read it as an instruction to the writer, never as an estimate of the reader.
