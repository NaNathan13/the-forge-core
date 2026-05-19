# The Forge Lite

A stripped-down workflow pipeline for Claude Code projects. Four phases — **Ponder → Forge → Temper → Seal** — driven by markdown plan files on disk. No GitHub issues, no PRs as work units, no Mission Control file, no concurrent workers. Just one operator command per phase, one slice at a time.

This repo is both the source-of-truth for the pipeline AND a working dogfood project. To use Lite in another project, run `./light-the-lite.sh /path/to/target`.

## The loop

```
/ponder   → grills the idea, writes .claude/plans/active/<slug>.md
/forge    → builds one slice on its own branch
/temper   → reviews the diff + intent-match, marks ready-for-seal or friction
/seal     → squash-merges into main, updates progress, archives drained plans
```

State lives entirely in `.claude/plans/active/*.md` (in-flight) and `.claude/plans/done/*.md` (shipped). `ls active/` is your in-flight ledger.

## Plan-file shape

```markdown
---
name: auth-flow
status: active
created: 2026-05-19
---

# Auth flow

## Progress
░░░░░░░░░░ 0/3 slices shipped
- [ ] 1. Add login form  (queued)
- [ ] 2. Wire auth API   (queued)
- [ ] 3. Session refresh (queued)

## Goal
<why this exists, what done looks like>

---

## Slice 1: Add login form
Status: queued
Branch: -

<acceptance criteria, implementation notes>
```

## Installing into another project

```
cd /path/to/your/project
/path/to/the-forge-lite/light-the-lite.sh
```

The installer copies `.claude/skills/`, scaffolds `.claude/plans/{active,done}/`, drops placeholder `CLAUDE.md` / `CONTEXT.md` / `README.md` (only if missing — never overwrites), and prints a "next: `/ponder`" recommendation.

## Comparison to The Forge

Full Forge adds: GitHub issue tracking, labels, PR-as-review-surface, Mission Control ledger, concurrent worker dispatch, multiple ADRs. Lite drops all of that. Choose Lite when:

- You don't want GitHub coupling.
- You're working solo and don't need parallel slices.
- You want the discipline of the four phases without the ceremony.

Choose full Forge when: you need PR review with reviewers other than yourself, you want GitHub Actions CI in the loop, or you want concurrent slice builds.
