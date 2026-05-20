# The Forge Lite

<!-- working title — project rename pending -->

A lightweight four-phase workflow for Claude Code projects. Think of it as the bones of a bigger pipeline with all the machinery stripped out: just five skills, plan files on disk, and your own session doing the work.

```
/ponder    → grill the idea into shared understanding
/inscribe  → write the plan to .claude/plans/active/<slug>.md, sliced into parts
/forge     → build the whole plan inline, ticking off slices
/temper    → review + harden what was built; send weak slices back
/seal      → confirm done, move the plan to .claude/plans/done/
```

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

- **ponder** · **inscribe** · **forge** · **temper** · **seal** — the workflow.
- **grill-me** — stress-test an idea (used by `/ponder`).
- **diagnose** — disciplined debugging loop (handy in `/temper`).

## Using it in another project

```
cd /path/to/your/project
/path/to/this-repo/light-the-lite.sh
```

Copies the skills, scaffolds `.claude/plans/{active,done}/`, and drops placeholder `CLAUDE.md` / `CONTEXT.md` / `README.md` (only if missing — never overwrites). Then run `/ponder`.

## How it differs from the full pipeline it came from

The parent ("The Forge") adds GitHub issues + PRs, labels, a Mission Control ledger, an orchestrator/worker split with subagent dispatch, worktree isolation, and token accounting. This version drops all of it. Reach for it when you're working solo, want the discipline of the four phases, and don't want any of the ceremony.
