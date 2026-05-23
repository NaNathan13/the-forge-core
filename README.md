# The Forge Core

A calm, four-phase way to build things with Claude Code — **Ponder → Forge → Temper → Seal**. A few small skills, plans kept as plain markdown on disk, and your own session doing the work. No issues, no PRs, no orchestration — just the steadiness of the four phases.

It's also the brain behind [The Forge GUI](../the-forge-gui): the no-terminal app installs these skills into every project it builds.

## Get started

From your project folder, run the installer (it fetches and installs in one step):

```bash
curl -fsSL https://raw.githubusercontent.com/NaNathan13/the-forge-core/main/light-the-core.sh | bash
```

Then open the project in Claude Code and type `/ponder`. That's the whole start.

The installer adds the skills under `.claude/`, sets up `plans/{active,done}/`, and drops starter `CLAUDE.md` / `CONTEXT.md` / `README.md` — only if you don't already have them, so it never clobbers your docs. **New here?** [**How to work in The Forge**](how-to-work-in-the-forge.md) walks you through your first build.

> Prefer to set it up from inside Claude? Run the `/light-the-core` skill — same installer, and it asks three quick questions (project name, what it is, tech stack) to fill the starter docs in for you.

## The five commands

Four phases, run as five commands, one at a time — nothing auto-chains, so you're always in control of when the next step starts.

| Command | Phase | What it does |
|---|---|---|
| `/ponder` | Ponder | Asks a few plain questions to think the idea through — no code yet |
| `/inscribe` | Ponder | Writes the plan to `.claude/plans/active/<slug>.md` |
| `/forge` | Forge | Builds the plan slice by slice, ticking each off |
| `/temper` | Temper | Reviews and hardens it; sends weak slices back to forge |
| `/seal` | Seal | Confirms it's done and files the plan under `done/` |

Reach for these anytime: `/grill-me` (stress-test an idea), `/research` (go find out — light, or deep when it's worth it), `/diagnose` (a calm debugging loop), `/scrub` (tidy up plan state), `/sharpen` (turn a rough idea into a sharp prompt).

## Edit here when…

…you're changing how apps get **built** — the intake questions, how work is planned and sliced, how data is stored, or the rules generated apps follow. The look of the no-terminal app — its preview, gallery, and chrome — lives over in [The Forge GUI](../the-forge-gui).

State is just files: `ls .claude/plans/active/` is your whole ledger.
