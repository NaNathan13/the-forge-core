# CONTEXT — <placeholder: project-name>

> Ubiquitous-language doc. Add a term when you find yourself disambiguating it in conversation. Pick canonical names; list rejected synonyms in `_Avoid_:`.

<!--
  This file is the project's domain glossary. Skills read it reactively when they
  hit an ambiguous term. Keep entries short — one paragraph each. Use the format:

    **Term**: Definition. Mention the canonical name, where it lives, and what it
    is NOT. _Avoid_: "rejected synonym" (reason).

  The Forge Lite vocabulary is pre-seeded below — leave those entries alone unless
  you genuinely diverge from the pipeline. Add your project's own terms under
  ## Language.
-->

## Pipeline terms (The Forge Lite)

**Ponder**: The planning phase — first of four. Grill the idea, then write the plan file via `/inscribe`. Output: one `.claude/plans/active/<slug>.md` file with `status: active` and an ordered slice list.

**Forge**: The build phase — second of four. `/forge` reads the next plan with `queued` slices, picks the first one, and a worker (`/forge-worker`) implements it end-to-end: branch, code, tests, flip `Status:` from `queued` to `shipped`. No PRs.

**Temper**: The review-and-harden phase — third of four. `/temper` reviews the diff of the most recently shipped slice against its acceptance criteria in the plan. Friction lands as a follow-up note in the slice body.

**Seal**: The closer phase — fourth of four. `/seal` flips the plan's frontmatter `status:` to `done` and moves the file from `.claude/plans/active/` to `.claude/plans/done/`. The plan is shipped.

**Slice**: A single shippable step within a plan. Each slice carries a `Status:` line (`queued` / `in-progress` / `shipped`) and a `Branch:` line. The worker flips both as it builds.

**Plan**: A single `.claude/plans/active/<slug>.md` file. Frontmatter (`name`, `status`, `created`), a `# Title`, `## Progress` bar, `## Goal`, `## Constraints / out of scope`, and one or more `## Slice N:` blocks.

**Friction**: The first-class "stuck" signal. When `/forge-worker` or `/temper` can't proceed, it writes a friction note into the slice body (or appends a `## Friction` section to the plan) and stops. The operator unblocks before the next phase runs.

## Language

<!-- Add project-specific terms here as you find ambiguity. Example:

**Widget**: A user-owned thing the app tracks. Has a `name`, a `kind`, and zero or
more attached `Notes`. _Avoid_: "item" (generic), "object" (too low-level).
-->

(none yet — add as you find them)

## Relationships

<!-- Once 3+ terms exist, sketch their relationships here as ASCII or a brief list. -->

## Flagged ambiguities

<!-- Places where past docs or older code used inconsistent vocabulary. Flag them
     so future grills resolve, not relitigate. -->
