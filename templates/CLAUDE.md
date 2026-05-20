# <placeholder: project-name>

<!--
  Starter CLAUDE.md for the lightweight four-phase workflow.
  State lives in .claude/plans/active/<slug>.md (markdown), not in GitHub.
  Replace placeholders below. Keep this file short — it loads every session.
-->

One-line description of what this project is.

## Tech stack

- **Language / runtime:** <placeholder: e.g. TypeScript / Node 20, Rust, Go 1.22>
- **Framework:** <placeholder: e.g. Next.js 14, Django, none>
- **Test runner:** <placeholder: e.g. vitest, pytest, cargo test>
- **Check command:** `<placeholder: e.g. npm run check-all, pnpm test>`

## How work flows here

Five skills, run inline, in order. State lives in `.claude/plans/` — `active/` for in-flight, `done/` for finished.

```
/ponder    → grill the idea into shared understanding
/inscribe  → write the plan to .claude/plans/active/<slug>.md, sliced into parts
/forge     → build the whole plan inline, ticking off slices
/temper    → review + harden what was built; send weak slices back
/seal      → confirm done, move the plan to .claude/plans/done/
```

No GitHub issues, no PRs, no subagents. `ls .claude/plans/active/` is the whole ledger.

## Rules

- **Work in place.** No branch-per-slice, no remote pushes. Phases commit at their natural end on the current branch.
- **The plan file is the only state.** Keep the `## Progress` block current as slices get done.
- **Stay in scope.** Build what the slices describe; don't add features or refactor beyond them.
- <placeholder: any project-specific hard rules — code style, paid services, etc.>

## Docs

- [`CONTEXT.md`](./CONTEXT.md) — glossary. Read reactively when a term is unclear.
- [`.claude/plans/active/`](./.claude/plans/active/) — in-flight plans.
- [`.claude/plans/done/`](./.claude/plans/done/) — finished plans.
