---
name: forge
description: Phase 2 of the workflow — build the active plan. Works through every unchecked slice inline, ticking them off and re-rendering the progress bar, then commits. Triggered by /forge after /inscribe has written a plan.
---

# /forge — build the plan

`/forge` is the **build phase**. It reads the active plan and works through its slices, implementing each one and ticking it off. It runs inline in this session — no subagents, no branches.

```
/ponder  →  /inscribe  →  /forge  →  /temper  →  /seal
```

## What it does

1. **Pick the plan.** No argument → the most-recently-modified file in `.claude/plans/active/`. With an argument → `.claude/plans/active/<arg>.md`.

   ```bash
   plan="$(ls -t .claude/plans/active/*.md 2>/dev/null | head -n1)"
   test -n "$plan" || { echo "no active plans — run /ponder then /inscribe first"; exit 1; }
   ```

   Read it top to bottom: goal, constraints, and every slice.

2. **Build each unchecked slice, in order.** For every `- [ ]` slice in the progress block:
   - Implement it per its `## Slice N:` section. Keep edits scoped to that slice.
   - When it's done, tick its box (`- [ ]` → `- [x]`) and re-render the progress bar: filled cells = `round(done / total × 10)`, `█` filled, `░` empty.
   - If a slice is genuinely blocked, leave it unchecked, add a one-line `> blocked: <why>` note under it, and move on (or stop if later slices depend on it).

3. **Commit.** Once you've worked through what you can, commit on the current branch:

   ```bash
   git add -A
   git commit -m "feat(<slug>): <plan title>"
   ```

   Work in place — no branch, no push. Git is just local history here.

4. **Hand off:**

   > Built <done>/<total> slices of `<slug>`. Run `/temper` to review.
   > (or, if blocked: which slices remain and why.)

## Rules

- **Whole plan in one pass.** `/forge` attempts every unchecked slice, not just the next one.
- **Tick as you go.** The progress block is the source of truth — keep it current so a re-run knows what's left.
- **Work in place.** No branches, no GitHub, no push. Commit at the end.
- **Stay in scope.** Build what the slices describe; don't add features or refactor beyond them.
- **No review here.** `/temper` checks the work. `/forge` just builds.
