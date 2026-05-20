# The Forge Core

A lightweight four-phase workflow for Claude Code projects — **Ponder → Forge → Temper → Seal**. Think of it as the bones of a bigger pipeline with all the machinery stripped out: a few small skills, plan files on disk, and your own session doing the work.

```
Ponder ─┬ /ponder    grill the idea into shared understanding
        └ /inscribe  write the sliced plan to .claude/plans/active/<slug>.md
Forge ─── /forge     build the whole plan inline, ticking off slices
Temper ── /temper    review + harden what was built; send weak slices back
Seal ──── /seal      confirm done, move the plan to .claude/plans/done/
```

The four phases are Ponder, Forge, Temper, Seal. The Ponder phase runs two commands — `/ponder` to think, `/inscribe` to write the plan — so the four phases map to five commands.

No GitHub issues, no PRs, no orchestrators, no subagents, no token accounting. Git is just local version control. State lives entirely in `.claude/plans/` — `ls active/` is your whole ledger.

## How to get started

From your project directory, run the installer. It fetches The Forge Core and installs it in **one step** — no separate clone:

```bash
cd /path/to/your/project
curl -fsSL https://raw.githubusercontent.com/NaNathan13/the-forge-core/main/light-the-core.sh | bash
```

Then open the project in Claude Code and run `/ponder`.

The installer copies the skills into `.claude/skills/`, scaffolds `.claude/plans/{active,done}/`, and drops starter `CLAUDE.md` / `CONTEXT.md` / `README.md` — only if you don't already have them; it never overwrites your docs. It refuses to run if the project already has `.claude/plans/` (so you can't clobber an existing install).

> Already have the repo cloned? Run `./light-the-core.sh /path/to/your/project` instead — same result, no fetch.

**Prefer to set it up from inside Claude?** Run the `/light-the-core` skill instead of the one-liner. It runs the same installer, then asks three quick questions — project name, a one-line description, and your tech stack (including the check command `/forge` and `/temper` will run) — and fills the starter docs in for you.

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

## How it differs from the full pipeline it came from

The parent ("The Forge") adds GitHub issues + PRs, labels, a Mission Control ledger, an orchestrator/worker split with subagent dispatch, worktree isolation, and token accounting. This version drops all of it. Reach for it when you're working solo, want the discipline of the four phases, and don't want any of the ceremony.
