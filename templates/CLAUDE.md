# <placeholder: project-name>

<!--
  Starter CLAUDE.md for The Forge Lite.

  Lite is the stripped-down variant of The Forge — state lives in
  .claude/plans/active/<slug>.md (Markdown plan files), not in GitHub issues.
  The four-phase loop is unchanged: Ponder → Forge → Temper → Seal.

  Replace placeholders below with your project's specifics. Keep this file
  short — it loads at session start, so cost-per-turn scales with its length.
-->

One-line description of what this project is.

**Dev mode:** <placeholder: fast | balanced | tdd>

## Tech stack

- **Language / runtime:** <placeholder: e.g. TypeScript / Node 20, Rust, Go 1.22>
- **Framework:** <placeholder: e.g. Next.js 14, Django, none>
- **Test runner:** <placeholder: e.g. vitest, pytest, cargo test>
- **Check command:** `<placeholder: e.g. npm run check-all, pnpm test>`
- **Package manager:** <placeholder: npm | pnpm | yarn | uv | cargo>

## How work flows here

The Lite pipeline runs four phases in fixed order — `Ponder → Forge → Temper → Seal`. State lives in `.claude/plans/active/<slug>.md`. One plan per feature; each plan carries an ordered list of slices.

- `/ponder` — grill the idea, write the plan file (`.claude/plans/active/<slug>.md`).
- `/prototype` — fast-path, one-slice plan; skips the grill.
- `/forge` — pick the next `queued` slice and build it. Worker flips `Status:` and `Branch:` lines as it goes.
- `/temper` — review the latest shipped slice's diff against its acceptance criteria.
- `/seal` — mark the plan `done`, move the file from `active/` to `done/`.

No GitHub issues. No PRs. No Mission Control file. Just plan files on disk.

## Rules

- Branch per slice: `feat/<plan-slug>-slice-<N>-short-description` (or whatever the worker derives — the slice's `Branch:` line is the source of truth once set).
- Tests: logic functions get unit tests, user-facing surfaces get one happy-path test. No strict TDD unless `**Dev mode:**` says so.
- Plan file shape is load-bearing — every slice opens with `Status: <queued|in-progress|shipped>` and `Branch: <branch-name|->`. Workers read both lines.
- <placeholder: any project-specific hard rules — paid services, code-style enforcement, etc.>

## Docs

- [`CONTEXT.md`](./CONTEXT.md) — ubiquitous language and domain glossary. Read reactively when disambiguating terms.
- [`.claude/plans/active/`](./.claude/plans/active/) — in-flight plans. Each file is a slug-named Markdown doc.
- [`.claude/plans/done/`](./.claude/plans/done/) — shipped plans. Sealed by `/seal`.
- [`.claude/rules/`](./.claude/rules/) — auto-loaded path-scoped rules. Add as you find patterns worth enforcing.
