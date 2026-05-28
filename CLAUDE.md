# The Forge Core

A four-phase workflow for Claude Code: **Ponder → Forge → Temper → Seal**. Plans live as plain markdown files under `.claude/plans/` — `active/` for in-flight, `done/` for finished. The build runs inline on the current branch.

This repo is both the source of the workflow and something you can drop into any project via `light-the-core.sh`.

## The loop

```
Ponder ─┬ /ponder    grill the idea into shared understanding
        └ /inscribe  write the sliced plan to .claude/plans/active/<slug>.md
Forge ─── /forge     build the plan inline, ticking off slices
Temper ── /temper    review and harden; un-tick weak slices
Seal ──── /seal      confirm done and move the plan to .claude/plans/done/
```

State = `ls .claude/plans/active/`.

## Key terms

See [`CONTEXT.md`](./CONTEXT.md). Essentials:

- **Plan** — one markdown file in `.claude/plans/active/<slug>.md`, sliced into parts, with a progress block near the top.
- **Slice** — one coherent chunk of a plan; a checklist item plus a `## Slice N:` detail section.
- **The four phases** — Ponder, Forge, Temper, Seal. The Ponder phase runs two commands (`/ponder` then `/inscribe`); the rest run one.

## Rules

- **Work in place** on the current branch; phases commit at their natural end.
- **The plan file is the only state.** Keep the progress block current.
- **Stay in scope.** Build what the slices describe.

## Response style

- Aim for terse, not silent. Cut filler — no restating the request, no "I'll now..." preamble.
- Keep narrating what you're working on as you go; short status updates are welcome.
- Explain what you did and what's next, but a sentence or two is plenty — no paragraph-long recaps.
- A short plan before non-trivial work is good. Skip the plan for one-off edits.
- Code blocks only for code.

## Context loading

| Layer | Source | When |
|---|---|---|
| Always | this file | session start |
| Glossary | `CONTEXT.md` | reactively |
| Plans | `.claude/plans/active/*.md` | when a phase runs |
| Skill | `.claude/skills/<name>/SKILL.md` | when its `/command` is invoked |
