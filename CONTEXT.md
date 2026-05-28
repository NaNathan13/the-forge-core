# CONTEXT — glossary

Every term the workflow uses, defined once. Add new terms as ambiguity comes up.

## Ponder

The thinking phase — first of the four. `/ponder` grills a fuzzy idea into shared understanding — scope, what "done" means, how the work splits into slices — without writing any code or plan file. When a question can't be settled from the codebase or known facts, it leans on `/research`. Ends by handing off to `/inscribe`.

## Inscribe

The plan-writing command that ends the Ponder phase. Records the understanding from `/ponder` as a single markdown file at `.claude/plans/active/<slug>.md`, sliced into parts, with a progress block near the top.

## Research

A sub-skill `/ponder` leans on (and usable on its own) when a question can't be settled from what's already known. Two depths: **light** — inline, in-session, read the code or do a quick lookup; **deep** — parallel subagent fan-out across sources for genuinely novel unknowns, which confirms before launching. Research only gathers and reports; `/inscribe` records what mattered in the plan's `## Research` section.

## Forge

The build phase. `/forge` reads the active plan and works through every unchecked slice inline — implementing each, ticking its box, re-rendering the progress bar — then commits.

## Temper

The review-and-harden phase. `/temper` checks the built work against the plan: does each slice meet its intent, is it correct and clean. Fixes small issues inline and sends weak slices back by un-ticking them and annotating what's missing. Commits any fixes.

## Seal

The closer phase. `/seal` confirms every slice is done, flips the plan's frontmatter to `status: done`, moves the file from `active/` to `done/`, and makes a final commit.

## Plan

A single markdown file at `.claude/plans/active/<slug>.md` (in-flight) or `.claude/plans/done/<slug>.md` (finished). Holds frontmatter (`name`, `created`, `status`), a `## Progress` block (a 10-cell bar + slice checklist), a `## Goal`, optional `## Constraints / out of scope` and `## Research` sections, and one `## Slice N:` section per slice.

## Slice

One coherent chunk of a plan — something describable in a sentence. Appears twice in the plan file: as a checklist item in the progress block (`- [ ]` / `- [x]`) and as a `## Slice N:` detail section. `/forge` builds slices and ticks them; `/temper` un-ticks any that need rework.

## Progress block

The bit near the top of every plan: a 10-cell bar (`█` done, `░` not — filled cells = `round(done / total × 10)`) plus the slice checklist. The single source of truth for what's done; kept current by `/forge` and `/temper`.
