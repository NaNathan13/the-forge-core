# The Forge Lite

A stripped-down markdown- and bash-driven pipeline for running Claude Code projects end-to-end: **Ponder → Forge → Temper → Seal**. All planning and state lives in markdown plan files at `.claude/plans/active/` (in-flight) and `.claude/plans/done/` (shipped). No GitHub issues, no PRs as work units, no labels, no concurrent worker dispatch.

The repo at this path is **both** a working dogfood project AND the source-of-truth for installs into other projects (via `light-the-lite.sh`).

**Dev mode:** balanced

## Tech stack

- **Language / runtime:** Markdown + Bash (no application runtime).
- **Framework:** Claude Code skills (`.claude/skills/`).
- **Check command:** `bash -n` on changed shell scripts.
- **Package manager:** none.
- **CI:** none in-repo. The pipeline is exercised by dogfooding (real `/forge` + `/temper` runs).

## Key terms

See [`CONTEXT.md`](./CONTEXT.md) for the full glossary. The seven load-bearing terms:

- **Ponder** — phase 1: grill the idea, write the plan file.
- **Forge** — phase 2: build one slice on its own branch.
- **Temper** — phase 3: review the diff + intent-match, mark ready-for-seal or friction.
- **Seal** — phase 4: squash-merge the branch into main, update progress bar, archive plan if drained.
- **Slice** — a single H2 section in a plan file; the atomic unit of work.
- **Plan** — a single markdown file in `.claude/plans/active/<slug>.md` containing 1..N slices.
- **Friction** — a slice that didn't pass temper; gets a `### Friction` subsection with reviewer findings.

## Rules

- **Branch per slice**: `feat/<plan-slug>-s<N>-<short-desc>`. Never commit to `main` directly. `/seal` does the squash-merge.
- **One operator command per phase**: `/forge`, `/temper`, `/seal` each act on exactly one slice, then stop. No auto-chain.
- **Strict friction rule**: any reviewer HIGH **or** intent-match failure → friction. No partial passes.
- **State lives in plan files only**: `ls .claude/plans/active/` is the in-flight ledger. There is no Mission Control file.
- **No GitHub coupling**: the pipeline never queries `gh`, never reads issues, never opens PRs. Git is used purely as a versioning substrate.

## Context loading

| Layer | Source | When it loads |
|---|---|---|
| Always | this file | every session start |
| Glossary | `CONTEXT.md` | reactively when a term is ambiguous |
| Plans | `.claude/plans/active/*.md` | reactively when a phase command runs |
| Skill | `.claude/skills/<name>/SKILL.md` | when the matching `/command` is invoked |
| Token ledger | `.claude/token-usage.jsonl` | append-only, never read except during audit |
