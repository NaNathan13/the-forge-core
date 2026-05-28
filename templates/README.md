# <placeholder: project-name>

One-line description of what this project is.

<!--
  Starter README dropped in by the installer. Rewrite as your project grows.
  The workflow doesn't read this file at runtime.
-->

## How this project is built

This repo uses a four-phase Claude Code workflow — **Ponder → Forge → Temper → Seal**. Plans live as plain markdown under `.claude/plans/`.

To build or change something, open the project in Claude Code and type `/ponder`.

## Where things live

- [`CLAUDE.md`](./CLAUDE.md) — context loaded every session: tech stack, rules.
- [`CONTEXT.md`](./CONTEXT.md) — glossary.
- `.claude/plans/active/` — what's in flight.
- `.claude/plans/done/` — what's shipped.
- `.claude/skills/` — the workflow itself.
