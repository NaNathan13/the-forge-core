---
name: forge-worker
description: Build a single slice end-to-end — read the slice from the plan file, implement it on the pre-created branch, run project checks, commit, and return a one-line FORGE_DONE result string. Does NOT update the plan file's Status line and does NOT merge — the orchestrator handles state transitions; /seal merges. Invoked as /forge-worker <plan-slug> <slice-N>.
---

# /forge-worker — Build a Slice (Lite)

Build one slice of a plan file end-to-end: implement, check, commit, return.

The Forge Lite has no GitHub issues and no PRs — the "slice" is an H2 section
inside `.claude/plans/active/<plan-slug>.md`, and the deliverable is a green
commit on the slice's pre-created branch. The orchestrator (`/forge`) created
the branch and dispatched you; your job is to fill it.

## Inputs

- **Plan slug** — first argument. Identifies `.claude/plans/active/<plan-slug>.md`.
- **Slice number** — second argument. Identifies the `## Slice <N>: <title>` H2
  inside that file.
- When dispatched as a subagent by `/forge`, the same two values arrive as
  prompt context.

## Workflow

### 1. Setup

- Read the plan file: `.claude/plans/active/<plan-slug>.md`.
- Locate the `## Slice <N>: <title>` H2. Read its body (everything between this
  H2 and the next H2 or EOF).
- Capture three things from the slice header lines:
  - `Status:` — should be `queued` (first build) or `friction` (rework). If
    anything else, return `FORGE_BLOCKED` with
    `reason="slice not ready: status=<x>"`.
  - `Branch:` — the slice's branch name. The orchestrator created this branch
    before dispatching you.
  - `### Friction` subsection — if present, this is rework. Read it. The HIGHs
    and intent-match notes listed there are the work for this run.
- Verify you are already on the slice's branch:

  ```bash
  current=$(git rev-parse --abbrev-ref HEAD)
  if [ "$current" != "<branch from slice header>" ]; then
    # FORGE_BLOCKED reason="not on slice branch: on=$current expected=<branch>"
    exit 1
  fi
  ```

  Do **not** create or switch branches. The orchestrator owns branch lifecycle.
- Do not bulk-load `MISSION-CONTROL.md`, plan-wide design notes, or other heavy
  context. Read reactively if needed.

### 2. Build

- Implement the slice per its body. If a `### Friction` subsection is present,
  treat its HIGHs + intent-match notes as the change list — fix those first,
  then re-verify the original acceptance criteria still hold.
- Write tests if the project has a test harness configured (look for
  `test/run-tests.sh`, `package.json` test script, `cargo test`, `pytest`,
  etc.). If no harness exists, smoke-check what you reasonably can (e.g.
  `bash -n` on shell scripts, a hand-written sanity invocation of the new
  code path).
- Keep edits scoped to the slice. Don't refactor surrounding code; don't add
  features beyond the slice body. The temper-worker will read this same body
  as the intent reference.

### 3. Run project checks

- For any shell scripts touched: `bash -n <file>` on each.
- Run the project's check command if one is defined (e.g. `test/run-tests.sh`,
  `npm test`, `pnpm check-all`, `cargo test`). Look in `CLAUDE.md` for the
  configured command.
- Fix any failures before committing. Treat the check command as a hard gate
  unless the project explicitly marks it advisory.
- If the failure is environmental (missing dep, network) and you cannot fix
  it, return `FORGE_BLOCKED` with a concise `reason`.

### 4. Commit

- Stage only the files the slice intended to touch. Prefer named paths over
  `git add -A`.
- Commit message format:

  ```
  feat(<plan-slug>-s<N>): <slice title>
  ```

  For non-feat work, swap the type: `fix`, `chore`, `docs`, `refactor`,
  `test`. The `<plan-slug>-s<N>` scope is required — it's how the commit
  links back to its slice.
- Multi-commit slices are fine. Each commit should be atomic and well-scoped.
  The result string reports the count so the orchestrator can sanity-check.
- Do not push. The orchestrator decides whether/when to push.
- Do not amend prior commits unless the prior commit was made in this same
  worker run.

### 5. Return the result string

End the run by printing **exactly one** plain-text result line. No JSON, no
sentinel prefix — just the line. The orchestrator parses it by leading token.

**On success:**

```
FORGE_DONE plan=<slug> slice=<N> branch=<branch> commits=<N>
```

`commits=<N>` is the count of new commits this worker added on top of the
branch's starting HEAD. Zero is legal only if the slice was a pure rework
that produced no net diff after fixes — flag that in your prose summary.

**On hard block** (anything you cannot resolve in this run — wrong branch,
missing dep, malformed slice, irrecoverable test failure):

```
FORGE_BLOCKED plan=<slug> slice=<N> reason="<short reason>"
```

Quote the reason. Keep it under ~80 chars — it ends up in the orchestrator's
log. Examples:

- `reason="not on slice branch: on=main expected=feat/foo-s2"`
- `reason="slice not ready: status=ready-for-temper"`
- `reason="check command failed: 3 tests red, no fix in scope"`
- `reason="branch has unrelated dirty state — refusing to commit"`

The orchestrator decides what to do with a block (retry, surface to operator,
skip to next slice). You just report.

Print a short prose summary above the result line for the human reading the
transcript — what you built, what you checked, anything notable. The
orchestrator does not parse the prose; only the `FORGE_DONE` / `FORGE_BLOCKED`
line matters.

## Worker boundaries — restated

- **The worker does NOT update the plan file's `Status:` line.** The
  orchestrator owns plan-file state transitions. After you return
  `FORGE_DONE`, `/forge` rewrites `Status: queued` (or `Status: friction`) →
  `Status: ready-for-temper`. If you edit the Status line yourself, you'll
  race the orchestrator and corrupt the plan file.
- **The worker does NOT merge.** There are no PRs in Lite, but the same rule
  applies: don't merge the slice branch into main. `/seal` handles batch
  closeout.
- **The worker does NOT touch other slices.** Read your slice's body, fix
  your slice's friction, commit on your slice's branch. Other slices in the
  plan are out of scope even if they look related.
- **The worker does NOT modify the `### Friction` subsection.** If friction
  was present at start, you read it and acted on it; you don't delete it.
  The orchestrator clears it (or rewrites it) on the next state transition.

## Rules

- One slice per invocation. If asked to build two, return `FORGE_BLOCKED`
  with `reason="multi-slice dispatch not supported"`.
- Commits stay on the slice branch only. No cherry-picks across slices.
- If the slice body conflicts with itself (acceptance criterion A demands X,
  criterion B forbids X), pick the simpler reading, commit it, and note the
  ambiguity in your prose summary — the temper-worker will catch it on
  intent-match if you guessed wrong.
- Keep context lean. Don't read the full plan file if you only need your
  slice's H2 — use `grep -n "^## Slice" <plan>` to find offsets, then `sed`
  or `Read` with `offset`/`limit` to pull just your section.
- If you dispatch a support subagent (e.g. for research on an unfamiliar
  API), keep it scoped and read-only. The worker is the implementer; the
  subagent is a reader.
- Match existing project conventions. Read `CLAUDE.md` and any auto-loaded
  rules under `.claude/rules/` before writing code.

## Result-line examples

Success, single commit:

```
FORGE_DONE plan=auth-flow slice=2 branch=feat/auth-flow-s2-wire-auth-api commits=1
```

Success, multi-commit (split into impl + tests):

```
FORGE_DONE plan=auth-flow slice=2 branch=feat/auth-flow-s2-wire-auth-api commits=3
```

Blocked — wrong branch:

```
FORGE_BLOCKED plan=auth-flow slice=2 reason="not on slice branch: on=main expected=feat/auth-flow-s2-wire-auth-api"
```

Blocked — check command failure outside fix scope:

```
FORGE_BLOCKED plan=auth-flow slice=2 reason="test/run-tests.sh fails on unrelated suite (db/migrations) — not in slice scope"
```
