# How to work in The Forge

Sitting down to build something with this workflow? Start here — it's a five-minute read and then you're off.

## The one idea to hold

The workflow lives *inside* your project, right next to your code. There's no separate "workflow repo." When you install The Forge Core, it drops into `.claude/` at your project root, and everything it knows about your work — your tech stack, your glossary, your plans — sits alongside the app it's helping you build:

```
your-project/
├── CLAUDE.md        ← notes about YOUR project (tech stack, rules)
├── CONTEXT.md       ← your project's glossary
├── .claude/
│   ├── skills/      ← the workflow: /ponder /inscribe /forge /temper /seal
│   └── plans/       ← active/ (in-flight) and done/ (shipped)
└── src/ …           ← your app
```

## One-time setup

From your project folder:

```bash
curl -fsSL https://raw.githubusercontent.com/NaNathan13/the-forge-core/main/light-the-core.sh | bash
```

That drops the workflow into `.claude/` and gives you starter docs to fill in (or run the `/light-the-core` skill and it'll ask three quick questions and fill them for you). Then open the project in Claude Code.

## The loop: how you actually build

Building anything is four phases, run as five commands — one at a time. You type the command, Claude does the phase, and you move on when you're ready. **Nothing auto-chains; you're always in control.**

1. **`/ponder` — think it through.** Describe what you want ("add user login", "export reports as CSV"). Claude asks you questions one at a time, each with a recommended answer, until the shape is clear. Pick an option, type your own, or just say "go with your rec." No code or files yet.

2. **`/inscribe` — write the plan.** Claude writes the plan to `.claude/plans/active/<slug>.md`: a goal, the work sliced into checklist items, and a progress bar. **Open it and read it** — it's plain markdown, so tweak, reorder, or reword anything before you build. This file is the source of truth from here on.

3. **`/forge` — build it.** Claude works through every unchecked slice, implementing each, ticking its box, and committing as it goes. Watch it build; interrupt and redirect anytime.

4. **`/temper` — review and harden.** Claude checks the work against the plan, fixes small things, and **un-ticks** any slice that needs real rework with a note on what's wrong. If something got sent back, run `/forge` again, then `/temper` again.

5. **`/seal` — finish.** Claude confirms every slice is done, makes the final commit, and moves the plan to `done/`. Shipped — and the plan becomes a record of what you built.

```
/ponder → /inscribe → /forge → /temper → /seal
  think      write      build    review    finish
```

## A few utilities

- **`/grill-me`** — stress-test any idea or plan with relentless one-at-a-time questions.
- **`/diagnose`** — a calm debugging loop for when something's broken and the cause isn't obvious.
- **`/scrub`** — tidy up: reconcile plan state, re-render a stale progress bar, sweep junk.
- **`/sharpen`** — turn a rough idea into a precise, paste-ready prompt for any session or tool.

## House rules

- **One plan at a time is simplest.** You can keep several in `active/`; the commands act on the most recent (or pass a name: `/forge my-plan`).
- **The plan file is the truth.** When in doubt, open `.claude/plans/active/<slug>.md` — that's the whole state of your work.
- **Git is local.** The phases commit for you at natural points; no GitHub, no pushing unless you choose to.
- **Stay scoped.** Each slice builds what it describes. New idea mid-build? That's a new slice, or a new plan.

That's the whole system. Install it, `/ponder` your first idea, and follow the five commands.
