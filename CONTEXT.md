# CONTEXT — The Forge Lite glossary

Single source of truth for terms used by the pipeline. Living docs in this repo anchor-link to `CONTEXT.md#<term>` rather than re-defining.

## Ponder

The first phase. The operator runs `/ponder`, gets grilled on the idea by the `grill-me` sub-skill, then `/inscribe` writes a plan file to `.claude/plans/active/<slug>.md` with one or more queued slices.

## Forge

The second phase. The operator runs `/forge`. The orchestrator picks the most-recently-modified active plan (or an arg-named one), finds the first slice with `Status: queued` or `Status: friction`, creates a branch (`feat/<plan-slug>-s<N>-<desc>`), and dispatches a builder subagent (worktree-isolated) that writes the code and commits to the branch. The orchestrator then flips the slice to `Status: ready-for-temper`. **No merge** — that's `/seal`'s job.

## Temper

The third phase. The operator runs `/temper`. The orchestrator picks the first slice with `Status: ready-for-temper`, dispatches a reviewer subagent on `git diff main..<branch>`, runs an inline intent-match against the slice body, and applies the **strict friction rule**: any reviewer HIGH OR intent-match failure → `Status: friction` + a `### Friction` subsection appended under the slice. Otherwise → `Status: ready-for-seal`.

## Seal

The fourth phase. The operator runs `/seal`. The orchestrator picks the first slice with `Status: ready-for-seal`, squash-merges the branch into `main`, deletes the branch, flips the slice to `Status: shipped`, re-renders the progress bar at the top of the plan, and — if every slice in the plan is now shipped — moves the file from `.claude/plans/active/` to `.claude/plans/done/`.

## Slice

A single H2 section (`## Slice N: <title>`) inside a plan file. The atomic unit of work. Each slice carries a `Status:` line and a `Branch:` line right under the heading, then its body (acceptance criteria, implementation notes). Slices in a single plan can be related but each gets its own branch and its own forge/temper/seal cycle.

**Status values:** `queued` → `ready-for-temper` → (`ready-for-seal` | `friction`) → `shipped`. A `friction` slice goes back through `/forge` for rework; the `### Friction` subsection under it is the rework brief.

## Plan

A single markdown file at `.claude/plans/active/<slug>.md` (in-flight) or `.claude/plans/done/<slug>.md` (drained). Contains YAML frontmatter (`name`, `status`, `created`), a `## Progress` block with a 10-cell progress bar (█ for shipped, ░ for not), a `## Goal` section, optional `## Constraints / out of scope`, and 1..N `## Slice N: ...` sections.

## Friction

The first-class "stuck" signal. When `/temper` fails a slice (any reviewer HIGH or intent-mismatch), the slice's `Status:` becomes `friction` and a `### Friction` subsection is appended under the slice with the reviewer findings, intent-match notes, and a timestamp. The next `/forge` invocation on that slice reads the subsection as "here's what to fix".
