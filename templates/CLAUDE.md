# <placeholder: project-name>

One-line description of what this project is.

## Tech stack

- **Language / runtime:** <placeholder: e.g. TypeScript / Node 20, Rust, Go 1.22>
- **Framework:** <placeholder: e.g. Next.js 14, Django, none>
- **Test runner:** <placeholder: e.g. vitest, pytest, cargo test>
- **Check command:** `<placeholder: e.g. npm run check-all, pnpm test>`

## How work flows here

Four phases, run inline and in order: **`/ponder`** (think it through) → **`/inscribe`** (write the sliced plan) → **`/forge`** (build it slice by slice) → **`/temper`** (review and harden) → **`/seal`** (confirm done). State lives in `.claude/plans/` — `active/` for in-flight, `done/` for finished. `ls .claude/plans/active/` is the whole ledger.

## Rules

- **Work in place** on the current branch; phases commit at their natural end.
- **The plan file is the only state.** Keep the `## Progress` block current as slices get done.
- **Stay in scope.** Build what the slices describe.
- <placeholder: any project-specific hard rules — code style, paid services, etc.>

## Docs

- [`CONTEXT.md`](./CONTEXT.md) — glossary. Read reactively when a term is unclear.
- [`.claude/plans/active/`](./.claude/plans/active/) — in-flight plans.
- [`.claude/plans/done/`](./.claude/plans/done/) — finished plans.
