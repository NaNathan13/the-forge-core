# <placeholder: project-name>

One-line description of what this project is.

<!--
  Starter README dropped in by the install script. Rewrite as the project
  matures. The workflow does not read this file at runtime — it's for humans.
-->

## How this project is built

This repo uses a lightweight four-phase Claude Code workflow. State lives as markdown plan files under `.claude/plans/` — no GitHub issues, no PR ceremony.

```
/ponder    → grill the idea into shared understanding
/inscribe  → write the plan to .claude/plans/active/<slug>.md, sliced into parts
/forge     → build the whole plan inline, ticking off slices
/temper    → review + harden what was built
/seal      → confirm done, move the plan to .claude/plans/done/
```

## Where things live

- [`CLAUDE.md`](./CLAUDE.md) — session-start context: tech stack, rules.
- [`CONTEXT.md`](./CONTEXT.md) — glossary.
- [`.claude/plans/active/`](./.claude/plans/active/) — in-flight plans.
- [`.claude/plans/done/`](./.claude/plans/done/) — finished plans.
- [`.claude/skills/`](./.claude/skills/) — the workflow skills.

## Getting started

Open a fresh Claude Code session and run `/ponder`.
