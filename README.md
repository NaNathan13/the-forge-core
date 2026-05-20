# The Forge Core

A lightweight four-phase workflow for Claude Code projects — **Ponder → Forge → Temper → Seal**. Think of it as the bones of a bigger pipeline with all the machinery stripped out: a few small skills, plan files on disk, and your own session doing the work.

```
Ponder ─┬ /ponder    grill the idea into shared understanding
        └ /inscribe  write the sliced plan to .claude/plans/active/<slug>.md
Forge ─── /forge     build the whole plan inline, ticking off slices
Temper ── /temper    review + harden what was built; send weak slices back
Seal ──── /seal      confirm done, move the plan to .claude/plans/done/
```

The four phases are Ponder, Forge, Temper, Seal. The Ponder phase runs two commands — `/ponder` to think, `/inscribe` to write the plan — so there are five skills in all.

No GitHub issues, no PRs, no orchestrators, no subagents, no token accounting. Git is just local version control. State lives entirely in `.claude/plans/` — `ls active/` is your whole ledger.

## Plan-file shape

```markdown
---
name: auth-flow
created: 2026-05-19
status: active
---

# Auth flow

## Progress
`███░░░░░░░` 1/3
- [x] 1. Add login form
- [ ] 2. Wire auth API
- [ ] 3. Session refresh

## Goal
What we're building and why.

---

## Slice 1: Add login form
Detail and acceptance notes.

## Slice 2: Wire auth API
...
```

## Skills

- **ponder** + **inscribe** — the Ponder phase: think it through, then write the sliced plan.
- **forge** · **temper** · **seal** — build, review/harden, finish.
- **grill-me** — stress-test an idea (used by `/ponder`).
- **diagnose** — disciplined debugging loop (handy in `/temper`).
- **scrub** — tidy up: reconcile plan-state drift, re-render stale progress bars, sweep junk.

## Using it in another project

```
cd /path/to/your/project
/path/to/this-repo/light-the-core.sh
```

Copies the skills, scaffolds `.claude/plans/{active,done}/`, and drops placeholder `CLAUDE.md` / `CONTEXT.md` / `README.md` (only if missing — never overwrites). Then run `/ponder`.

## How it differs from the full pipeline it came from

The parent ("The Forge") adds GitHub issues + PRs, labels, a Mission Control ledger, an orchestrator/worker split with subagent dispatch, worktree isolation, and token accounting. This version drops all of it. Reach for it when you're working solo, want the discipline of the four phases, and don't want any of the ceremony.
