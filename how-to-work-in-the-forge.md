# How to work in The Forge Core

A guide for someone sitting down to actually build something with this workflow. If you've never used it, start here.

## The mental model: the workflow and your app share one repo

There is no separate "workflow repo" and "app repo." When you install The Forge Core into a project, the workflow moves *into* that project and lives at its root, right next to your code. Your app sits **under** the workflow — the workflow's files and docs are at the top, your source code lives below them in the same tree.

```
your-project/
├── CLAUDE.md          ← the workflow's notes about YOUR project (tech stack, rules)
├── CONTEXT.md         ← your project's glossary
├── .claude/
│   ├── skills/        ← the workflow itself: /ponder, /inscribe, /forge, /temper, /seal (+ utilities)
│   └── plans/
│       ├── active/    ← plans you're working on right now
│       └── done/      ← finished plans (the workflow's memory of what shipped)
│
├── src/               ← your app
├── package.json       ← your app
└── …                  ← the rest of your app
```

So: **the workflow lives alongside your app, and your documentation lives next to your code.** `CLAUDE.md`, `CONTEXT.md`, and the plan files under `.claude/plans/` are where the workflow keeps everything it knows about your project — and they sit at the root, above the app they describe. That co-location is the whole idea: the thing building the app and the app being built are in one place.

## One-time setup

From your project directory:

```bash
curl -fsSL https://raw.githubusercontent.com/NaNathan13/the-forge-core/main/light-the-core.sh | bash
```

That drops the workflow into `.claude/` and gives you starter `CLAUDE.md` / `CONTEXT.md`. Fill those in (or run the `/light-the-core` skill, which asks you three quick questions — project name, what it is, tech stack — and fills them for you). Then open the project in Claude Code.

## The loop: how you actually build

Building a feature is four phases, run as five commands, one at a time. You type the command; Claude does the phase; you move to the next when you're ready. **Nothing auto-chains** — you're always in control of when the next phase starts.

### 1. `/ponder` — think it through

Type `/ponder` and describe what you want ("add user login", "export reports as CSV"). Claude **grills you** — one question at a time, each with a recommended answer — to pin down scope, what "done" means, and how the work splits into slices. You just answer:

- Pick an option, or type your own.
- "go with your rec" is a perfectly good answer.
- Redirect freely — "no, simpler than that" steers it.

Ponder writes no code and no files. It ends when the shape is clear.

### 2. `/inscribe` — write the plan

Type `/inscribe`. Claude writes the plan to `.claude/plans/active/<slug>.md`: a goal, and the work sliced into parts, each a checklist item with a detail section, plus a progress bar at the top. **Open that file and read it.** It's plain markdown — tweak a slice, reorder, reword. This file is the source of truth for everything that follows.

### 3. `/forge` — build it

Type `/forge`. Claude works through every unchecked slice in the active plan, implementing each, ticking its box, and committing when done. You watch it build; you can interrupt and redirect at any point.

### 4. `/temper` — review and harden

Type `/temper`. Claude reviews what was built against the plan — is each slice actually done, correct, clean? It fixes small things inline and **un-ticks** any slice that needs real rework, with a note on what's wrong. If something got sent back, run `/forge` again to fix it, then `/temper` again.

### 5. `/seal` — finish

Type `/seal`. Claude confirms every slice is done, makes the final commit, and moves the plan from `active/` to `done/`. The feature is shipped; the plan becomes a record.

```
/ponder → /inscribe → /forge → /temper → /seal
   └ think      └ write     └ build   └ review   └ finish
```

## What you'll be doing at each step

- **Answering design questions** (during `/ponder`): short, one-at-a-time, each with a recommendation. This is where you make the calls so the build doesn't have to guess.
- **Reading and editing the plan** (after `/inscribe`): the plan file is yours — adjust it before forging.
- **Watching and steering the build** (during `/forge` / `/temper`): you don't have to sit silent; correct course whenever.
- **Deciding when to advance**: each phase stops and waits. You type the next command when you're satisfied.

## Utilities you can reach for anytime

- **`/grill-me`** — stress-test any idea or plan with relentless one-at-a-time questions. (`/ponder` uses this under the hood.)
- **`/diagnose`** — a disciplined debugging loop when something's broken and the cause isn't obvious.
- **`/scrub`** — tidy up: reconcile plan state, re-render a stale progress bar, sweep junk. Run it when things feel cluttered.
- **`/sharpen`** — turn a rough idea into a precise prompt. Write out what you want, run `/sharpen`, and get back a tightened prompt ready to paste into a new session, an agent, or `/ponder`.

## House rules

- **One plan at a time is simplest.** You *can* have several files in `active/`; the phase commands act on the most recently touched one (or pass a name: `/forge my-plan`).
- **The plan file is the truth.** When in doubt, open `.claude/plans/active/<slug>.md` and read it — that's the entire state of your work.
- **Git is local.** The phases commit for you at natural points; there's no GitHub, no PRs, no pushing unless you choose to.
- **Stay scoped.** Each slice builds what it describes. New idea mid-build? That's a new slice, or a new plan.

That's the whole system. Install it, `/ponder` your first idea, and follow the five commands.
