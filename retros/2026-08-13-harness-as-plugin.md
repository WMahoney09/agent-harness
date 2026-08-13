# Retro: the harness only reached Claude Code, so Cowork got nothing

**Date:** 2026-08-13
**Trigger:** Will wanted the skills in this repo available in Cowork.
**Status:** Resolved (repo is now a plugin marketplace; both install paths read the same directories).

## What happened

The harness had exactly one distribution mechanism: `setup.sh` symlinking `skills/`, `agents/`, `hooks/`, and `user/*` into `~/.claude/`. That reaches Claude Code on one machine and nothing else.

The gap was already visible in the code. `deck-voice` carries a note explaining that it repeats the rules from `user/CLAUDE.md` "because the surfaces that generate decks (Cowork, claude.ai) do not load that file," and a second note saying the file has to be uploaded to Cowork's own skill library by hand. One skill had been individually adapted; the other eighteen had not.

## The decision

**The repo root is the plugin root, and the repo is its own marketplace.**

`.claude-plugin/marketplace.json` declares a marketplace `wmahoney` with one plugin, `agent-harness`, whose `source` is `"./"`. Plugin component discovery scans `skills/`, `agents/`, and `hooks/hooks.json` at the plugin root — the directories that already exist and that the symlinks already point at. Nothing moved.

The alternative considered was a `plugins/` subdirectory holding a restructured copy. Rejected: it duplicates every skill, and a duplicate drifts.

### Rejected: splitting into two plugins

The first proposal was two entries in the marketplace — the full harness for Claude Code, and a curated subset (understanding, clarify, reasoning, terse, deck-voice, uml, estimate, retro) for Cowork, where `git` and `gh` do not exist.

Rejected on two grounds. Cowork already lets a user disable individual skills inside an installed plugin, so the split buys a cleaner first-run list and nothing else. And the second entry needs a hand-maintained `skills` array in `marketplace.json`: every new skill has to be classified, and one that is forgotten silently never appears in Cowork. The directory scan is a definition that cannot drift. Some skills also straddle the line — `/review` and `/retro` do useful work with no shell at all — so the split was not clean to begin with.

### `version` is deliberately absent

`plugin.json` omits `version`, so the plugin resolves to the commit SHA and every install updates when `main` moves. A `version` field would pin installs until it is manually bumped, which for a repo whose skills are edited continuously means Cowork silently running a stale copy. `claude plugin validate` warns about the missing field; the warning is expected and the README says so.

## Global instructions were the real problem

Skills in this repo assume `user/CLAUDE.md` is loaded. `/publish-review` cites the `🤖 Claude:` rule twice; the review skills lean on the disposition gate; everything written anywhere assumes the prose rules. In Claude Code that file arrives through the `~/.claude/CLAUDE.md` symlink. Plugins have no equivalent — there is no manifest field that installs global instructions.

Three options were on the table:

| Option | Trade-off |
|---|---|
| `SessionStart` hook reads the file into context | Unconditional and closest to parity. Costs ~13KB per session. |
| Ship the rules as a `/house-rules` skill | Cheap, inspectable, model-invoked — so it can be missed on the turn where it mattered. |
| Leave it; follow the `deck-voice` pattern per skill | Zero cost, but restates the same rules in nineteen places. |

Chose the hook. The rules it carries are mandatory ones — never post `REQUEST_CHANGES`, always prefix GitHub content — and a mandatory rule that loads only when the model elects to load it is not mandatory. The context cost is the price of the guarantee.

This does mean the plugin must not be installed on a machine that ran `setup.sh`: the rules would load twice, once from `~/.claude/CLAUDE.md` and once from the hook.

## What changed

1. **`.claude-plugin/plugin.json`** — new. Name, display name, description, author, repository, keywords. No component paths, because every component sits in its default location. No `version`, per above.
2. **`.claude-plugin/marketplace.json`** — new. Marketplace `wmahoney`, one plugin entry with `source: "./"`.
3. **`hooks/hooks.json`** — new. Plugin hook wiring: the existing `PreToolUse` guard on `Bash`, plus the `SessionStart` hook that reads `user/CLAUDE.md`. Commands use `${CLAUDE_PLUGIN_ROOT}`, never `~/.claude/`.
4. **`README.md`** — new Plugin Distribution section covering Cowork install, Claude Code install, versioning, global instructions, and validation. Layout and hooks tables updated.
5. **`CLAUDE.md`** — new "Two distribution paths" section stating the consequences for future edits, and the hook row in the operations table now names both registration sites.

## Hooks now register in two places

This is the one maintenance burden the change introduces. A hook has to appear in `user/settings.json` for the symlink path and in `hooks/hooks.json` for the plugin path, with different path conventions in each. Nothing validates that the two agree.

The precedent is not encouraging: the `2026-08-05` retro found that `user/settings.json` had silently lost its entire `hooks` block for three weeks and nothing noticed. A second, equally unvalidated registration site doubles that exposure. `claude plugin validate .` catches a malformed `hooks.json` but cannot catch one that is merely out of date.

## Open / future improvements

- **No check that `hooks/hooks.json` and `user/settings.json` agree.** A hook added to one and forgotten in the other fails silently on that path. A `SessionStart` hook comparing the two is possible and was not built.
- **Nothing tells a skill which surface it is on.** `/produce`, `/pull-request`, and `/reply` install into Cowork and will fail there when they reach for `git` or `gh`. They fail with a shell error rather than an explanation.
- **The whole repo ships in the package**, including `retros/`, `docs/`, and `.claude/`. Harmless at this size — the package limit is 200MB and 5,000 files — and plugins have no ignore mechanism, so scoping would mean restructuring the repo around the plugin rather than the reverse.
- **The `SessionStart` hook's context cost is unmeasured** against whatever Cowork's budget actually is. If it proves expensive, the fallback is the `/house-rules` skill, with pointer lines added to the skills that depend on it.
