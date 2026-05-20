---
name: light-the-core
description: Bootstrap a project on The Forge Core — copy skills, plan scaffolding, settings, and templates into the target repo. Use when the user says "install core into this project", "light the core", "set up The Forge Core here", or "/light-the-core".
---

# Light the Core

The bootstrap skill for a fresh project adopting **The Forge Core** — the stripped-down variant where state lives in `.claude/plans/active/<slug>.md` files instead of GitHub issues + a Mission Control doc.

This skill is a thin wrapper around `light-the-core.sh`. The shell script does the file copying; this skill confirms the target, runs the script, and reports what landed.

**Audience matters.** The user has just decided they want Core in this project. Be warm and brief — no Q&A, no GitHub setup, no `/examine`. The Core install is one decision: "copy the kit here, yes/no".

## Preconditions

Before running the installer:

- We have a target directory. By default it's `$(pwd)`. If the user names a path, use it.
- The target does **not** already have `.claude/plans/` — Core refuses to overwrite an existing install. (Detected by the script; surface its message cleanly if it refuses.)

## Workflow

### 1. Confirm the target

Ask once via AskUserQuestion (skip if the user invoked with an explicit path):

> Install Core into `<current-dir>`? Options:
> - **Yes, install here** (Recommended)
> - **Different path** — freeform follow-up
> - **Cancel**

On `Cancel`, stop.

### 2. Find the installer

`light-the-core.sh` lives at the root of the Core repo. Resolve its absolute path. If the user is *inside* the Core repo right now, it's `./light-the-core.sh`. If they invoked the skill from elsewhere, you may need to clone the Core repo or ask the user where they have it checked out.

For the common case (the user has Core cloned and is invoking from inside it, *or* from a sibling project), assume the script is on their `PATH` or runnable via the absolute path they cloned to. If you can't find it, ask once:

> Where is `light-the-core.sh`? (path to the Core repo or to the script itself)

### 3. Run the installer

Execute the script against the target:

```bash
<path-to>/light-the-core.sh <target-dir>
```

(Or just `<path-to>/light-the-core.sh` if the target is the current working directory.)

Stream its output to the user. The script prints what it copied; don't duplicate that summary.

### 4. Report the outcome

If the script exited 0, print:

```
The Core is lit.

Target:        <target-dir>
Plans live in: <target-dir>/.claude/plans/active/
Templates:     CLAUDE.md, CONTEXT.md, README.md (copied only if missing)

Next: /ponder
```

If the script exited non-zero (target already has `.claude/plans/`, target doesn't exist, permission error), surface the script's stderr verbatim and stop.

## Anti-patterns

- **Don't inline the file-copy logic.** That's `light-the-core.sh`'s job. This skill orchestrates; it does not duplicate the script.
- **Don't run a Q&A like `/light-the-forge` does.** Core has no project name, no tech stack, no GitHub repo creation to ask about. One confirmation, that's it.
- **Don't overwrite the user's `CLAUDE.md` / `CONTEXT.md` / `README.md`.** The installer already declines to clobber existing root docs; never paper over that.
- **Don't `git init` or create a GitHub repo.** Core is plan-files-on-disk; remote setup is the user's call.
