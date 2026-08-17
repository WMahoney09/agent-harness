---
name: artifact-craft
description: |
  The build sequence for a published Artifact — treatment read, written design plan, then code, then a pre-publish check. Wraps the built-in `artifact-design` skill with the gates and house rules that keep output from drifting toward generic. Produces pages that read as considered work, not as generated pages.
  TRIGGER when: building anything that will be published with the Artifact tool — a report, map, dashboard, plan, memo, reference, or deliverable with an audience. Also when revising or redeploying an existing artifact, and when the user asks why an artifact "looks generated" or wants a previous artifact's quality repeated.
---

# Artifact Craft

The discipline around building a published Artifact. `artifact-design` (built-in, ships with the Artifact tool) supplies the fundamentals — theme tokens, CSP constraints, layout mechanics, the list of AI-default looks to avoid. This skill supplies the **sequence**, the **gates**, and the **house rules**, and it does not repeat what the built-in already covers.

One rule sits above all others: **derive the design from the subject.** Everything that makes a page feel considered comes from choices traceable to what the page is about. Everything that makes a page feel generated comes from choices inherited by default.

## Goal

A published page that answers its question at a glance, holds up in both themes, and could not be mistaken for a page about a different subject.

## Invocation

| Input | Behavior |
|---|---|
| A new artifact to build | Run the full sequence below, in order. Do not skip to code. |
| A revision to an existing artifact | Skip steps 1–2 if the plan still holds. Re-run step 5 before every redeploy. |
| "Make this look better" / "this looks generated" | Diagnose against step 2's avoid-list and step 3's derivation test first. The problem is almost always an inherited default, not a missing flourish. |

## The Sequence

Each step is a gate. Do not start the next one until the current one is done.

### 1. Load the built-in

Call `artifact-design` **before writing any file** — HTML and Markdown alike. The Artifact tool's own description mandates this; it is not optional and not a formality. It carries the current CSP rules, theme-state mechanics, and avoid-list, and those change independently of this skill.

If the page needs live data, shared state, file downloads, or self-updating, also load `artifact-capabilities` before writing. If it needs diagrams, load `artifact-diagramming`.

### 2. Read the request and calibrate the treatment

Decide, explicitly, which register the work calls for:

- **Utilitarian** — a plan, memo, report, reference, internal doc. Polished, real hierarchy, considered spacing and palette. **No oversized hero.** Most requests land here.
- **Editorial** — a landing page, a pitch, something kept or shared outward. Opinionated, one real aesthetic risk, motion where it serves the subject.
- **UI** — a dashboard or tool. Scanned and operated, not read. Information design over typography: summary before detail, state encoded in form as well as number.

Format is part of this decision, not a shortcut. Choose Markdown only when the user asked for it or the destination is Markdown-native — never to save time.

Getting this wrong is the most expensive error available. An editorial treatment on an internal reference reads as unserious; a utilitarian treatment on a pitch reads as unfinished.

### 3. Write the design plan before any code

Write it out. Not in your head — in the response, so the choices are inspectable and you can be held to them.

**Color** — 4–6 named hex values. Then apply the derivation test:

> Name the subject's world. Does this palette come from it, or would it work equally well on any other page?

Bias neutrals slightly toward the accent hue rather than using a pure grey. A pure mid-grey reads as unconsidered; a grey with a hue bias reads as chosen. Where color carries meaning (ownership, severity, state), assign it semantically and keep semantic color separate from the accent.

**Type** — faces for two or more roles.

The CSP blocks font CDNs, so a linked webfont fails silently to an arbitrary fallback. Either inline a face as a data URI or use system stacks deliberately. **A well-used system stack beats a broken webfont every time**, and the personality can live in the pairing rather than in the faces themselves.

Give every role a job. A useful default for technical subjects: monospace carries all identifiers — repo names, env vars, ticket prefixes, IDs, file paths — while the sans carries prose. That split is itself a design idea and it costs nothing.

**Layout** — one or two sentences naming the organizing concept.

The strongest layouts make position mean something. If the page answers "which of these is which," let an axis encode the answer. If it answers "what happens in what order," let the sequence be the structure.

### 4. Build from the plan

Follow the plan you wrote. If you find yourself deviating, revise the plan first and say why.

**Structure must encode something true.** This is the check most often skipped. Numbered markers (01 / 02 / 03), eyebrows, dividers, and tiers are information, not decoration:

- Number a list only when order carries meaning the reader needs — a real sequence, a ranked tier, a timeline.
- Do **not** number a set of peers. A people table, a set of open questions, and a feature list are unordered; numbering them asserts a rank that doesn't exist.

**Write the copy as content, not filler.** Verdict first — the opening sentence carries the answer, support follows. Real content throughout, never lorem. Name things the way a reader recognizes them, not the way the system is built.

**State uncertainty once, plainly, and in the artifact.** If a claim is inference rather than fact, say so on the page — a short note near the end naming what wasn't verified. A deliverable that distinguishes what it knows from what it inferred is more useful than one that flattens both into confident prose, and it protects whoever reads it next.

### 5. Self-check before publishing

Walk it. Every item, every time — including redeploys.

**Theme.** Scan the stylesheet for any color whose only definition sits inside a media query or a `[data-theme]` block. That is the classic unreadable-artifact bug: it renders one theme's text on the other theme's ground for every viewer on the default "system" setting. `body` must set an explicit background from a token.

**Overflow.** Tables, code blocks, and diagrams each scroll inside their own `overflow-x: auto` container. The page body never scrolls sideways.

**Cascade.** Check for selectors that cancel each other out — a type-based class fighting an element-based one over the same spacing.

**Title.** A short noun phrase, two to four words, specific enough to pick out of a gallery of many. Not a category label. Not a name with an explainer bolted on after a dash or colon. The explanation goes in the `description` parameter, which becomes the gallery subtitle.

**Favicon.** Required. One or two emoji, and **stable across redeploys** — users find the tab by its icon. Change it only on a hard pivot in subject.

**Derivation.** Re-run the test from step 3. Could this palette, this type pairing, and this layout sit unchanged on a page about something else? If yes, one of them is inherited and should be replaced.

**Prose.** Run the house rules below over every line.

## House Prose Rules

Repeated here deliberately. `user/CLAUDE.md` does not load on claude.ai or Cowork, and artifact copy is exactly where these rules get forgotten — headings and card text feel like design surface rather than writing, and drift first.

**The one that matters most: no antithesis.** Never set up a wrong answer to knock down. State what is true and stop.

> "This isn't a refactor, it's a rewrite." → "This is a rewrite."
> "Not a config problem — a timing problem." → "The cause is timing."

The pattern also hides in softer forms: "less about X, more about Y," "what this really is," "rather than X, this Y." Same rule.

Also banned:

1. **Rhetorical question then answer.** "The problem? Two callers share the mutex."
2. **Participial tails.** "…ensuring maintainability," "…allowing for cleaner separation."
3. **Punchline endings.** No closing aphorism, no one-line zinger paragraph.
4. **Aphoristic pairs.** A second sentence that rewords the first. Keep the first, cut the second.
5. **Self-explanation tails.** "That's why X," "That's how Y" bolted onto an observation.
6. **Framing prefixes.** "The rhythm:", "The bill:", "The result:", "The bridge:". Delete the prefix, keep the sentence.
7. **Parallel triplets.** Three items in the same shape read as rhythm, not content. Use however many are true.
8. **Pace, scale, and altitude metaphors.** "30,000 feet," "same territory different altitude."
9. **Emoji in prose.** Section-marker emoji are a generated-design tell. The favicon is the exception.

**Word level.** Cut inflation: robust, comprehensive, seamless, powerful, crucial, leverage, streamline, elevate, unlock, "deep dive," "under the hood." Cut empty intensifiers: actually, precisely, genuinely, truly, real. Prefer `is` over "serves as." Bold is for labels in lists and tables, not emphasis mid-sentence.

**Em dashes are house style.** Do not ration them and do not rewrite them out. The `deck-voice` ban is scoped to presentation content only and does not apply to artifacts.

## Artifact

An `.html` file (or `.md` when the treatment read calls for it), written to the session scratchpad unless the user names a location, then published with the Artifact tool.

No co-located `ARTIFACT.md` exists for this skill, deliberately. A fixed output template would produce exactly the templated sameness the skill is written to prevent — the structure must come from the subject each time.

## Closure Criteria

- [ ] `artifact-design` was loaded before any file was written
- [ ] Treatment named explicitly — utilitarian, editorial, or UI
- [ ] Design plan written down before code, with color, type, and layout each stated
- [ ] Derivation test passed: palette, type, and layout are traceable to the subject
- [ ] Structural devices encode real information; nothing is numbered that isn't a sequence or a rank
- [ ] Both themes verified; no color defined only inside a media or `[data-theme]` block
- [ ] Wide content scrolls in its own container; page body does not scroll sideways
- [ ] Title is a specific two-to-four-word name; `description` and `favicon` set
- [ ] House prose rules run over every line, headings and card copy included
- [ ] Inferences and unverified claims are marked as such on the page
- [ ] URL handed to the user, with a note that artifacts are private until shared

## Notes

**Why this wraps the built-in instead of replacing it.** `artifact-design` ships with the Artifact tool and is maintained upstream; its CSP rules and theme mechanics change without notice. Duplicating it here would guarantee drift. This skill adds only what the built-in cannot know: the sequence discipline, the gates, and house voice.

**No house palette is defined, on purpose.** Locking one set of brand colors would make every artifact a sibling in the wrong way — visually consistent and subject-blind. The consistency worth having is consistency of *method*. If a fixed Gnar identity is ever wanted for client-facing work, it belongs in a separate skill that loads after this one and narrows step 3, rather than replacing it.

**The most common failure is skipping step 3.** Writing CSS directly, with the plan implicit, is how pages drift toward the defaults — warm cream and a serif, or near-black with one acid accent, or a purple gradient hero. The plan takes two minutes and is the difference.

**On updating an existing artifact.** Republish the same file path from the same conversation to keep the URL. From a different conversation, pass the artifact's URL as `url` — publishing without it creates a separate artifact and strands the original link. Recover the URL with `action: "list"` or by asking, never by guessing.
