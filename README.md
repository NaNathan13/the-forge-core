# The Forge Core

A four-phase workflow for Claude Code: **Ponder → Forge → Temper → Seal**. Plans live as plain markdown files under `.claude/plans/`.

## Install

From your project folder:

```bash
curl -fsSL https://raw.githubusercontent.com/NaNathan13/the-forge-core/main/light-the-core.sh | bash
```

This drops the skills under `.claude/`, scaffolds `.claude/plans/{active,done}/`, and seeds `CLAUDE.md`, `CONTEXT.md`, and `README.md` if they're missing. Open the project in Claude Code and run `/ponder` to start.

## Workflow

| Command | Phase | What it does |
|---|---|---|
| `/ponder` | Ponder | Questions the idea into shape — no code yet |
| `/inscribe` | Ponder | Writes the sliced plan to `.claude/plans/active/<slug>.md` |
| `/forge` | Forge | Builds the plan slice by slice, ticking each off |
| `/temper` | Temper | Reviews the build; un-ticks slices that need rework |
| `/seal` | Seal | Confirms done and moves the plan to `done/` |

One command at a time. You drive the loop.

## Example

```
> /ponder
  add CSV export to the reports page
  (Claude asks questions, settles scope, names the slices)

> /inscribe
  (writes .claude/plans/active/csv-export.md)

> /forge
  (builds each slice, ticks the boxes, commits)

> /temper
  (reviews; sends Slice 2 back for rework)

> /forge       # finish Slice 2
> /temper      # all clear
> /seal
  (plan moves to .claude/plans/done/)
```

## Skills

**Workflow** — `/ponder`, `/inscribe`, `/forge`, `/temper`, `/seal`

**Utilities**

- `/grill-me` — stress-test an idea with one-at-a-time questions
- `/research` — look something up; deep parallel fan-out when needed
- `/diagnose` — disciplined debugging loop
- `/sharpen` — turn a rough idea into a precise prompt
