---
name: seal
description: The Seal phase — finds the first ready-for-seal slice in the chosen plan, squash-merges its branch into main, deletes the branch, marks the slice shipped, re-renders the progress bar, and moves the plan from active/ to done/ if it was the last slice. One slice per /seal invocation, then stop.
---

# /seal — ship one slice

`/seal` is the **closer phase** of the four-phase pipeline. It picks one `ready-for-seal` slice, squash-merges its branch into `main`, deletes the branch, marks the slice `shipped`, and re-renders the plan's progress bar. If the slice was the last one in the plan, `/seal` moves the file from `.claude/plans/active/` to `.claude/plans/done/`. Then it stops.

```
/ponder  →  /forge  →  /temper  →  /seal
```

**One operator command per phase. One slice per /seal.** No auto-chain back to `/forge` for the next slice — the operator runs the pipeline again.

Idempotent: running `/seal` on a plan with no `ready-for-seal` slices is a no-op.

## Invocation

```
/seal                  # most-recently-modified active plan
/seal <slug>           # explicit plan — .claude/plans/active/<slug>.md
```

`/seal` runs **inline** — no subagent. The work is small: one merge, one branch delete, an in-place plan edit, maybe a file move.

## Step 1 — Pick the plan

Same selection rule as `/forge` and `/temper`. With an argument:

```bash
plan=".claude/plans/active/<arg>.md"
test -f "$plan" || { echo "no such plan"; exit 1; }
```

Without:

```bash
plan="$(ls -t .claude/plans/active/*.md 2>/dev/null | head -n1)"
test -n "$plan" || { echo "no active plans"; exit 1; }
```

Cache the slug and the total slice count.

## Step 2 — Pick the slice

The first slice with `Status: ready-for-seal`, in document order. If none exists:

```
Plan <slug>: nothing to seal. Run /forge or /temper, or /ponder for new work.
```

Exit. Do not touch `main`.

Capture the slice's `Branch:` value. That's what gets merged.

## Step 3 — Sanity-check the branch

```bash
git fetch origin
git rev-parse --verify "origin/<branch>" >/dev/null 2>&1 || {
  echo "branch <branch> missing on origin — refusing to seal"
  exit 1
}
```

The branch must exist on the remote. If it doesn't, something has already cleaned it up out-of-band; surface the surprise to the operator instead of papering over it.

## Step 4 — Show the plan, get approval

Print one short summary before any merge:

```
About to seal slice <N> of <slug>: <slice title>
  branch: <branch>
  target: main (squash-merge)

Proceed? (yes / no)
```

Default `yes` on enter. On `no`, exit without changes.

## Step 5 — Squash-merge

```bash
git checkout main
git pull --ff-only origin main
git merge --squash <branch>
git commit -m "feat(<slug>): slice <N> — <slice title>

Squash-merged from <branch>.
"
git push origin main
```

The commit message can include the slice body's headline + any `MEDIUM` / `LOW` findings the temper review surfaced — surface them in the body so they don't disappear without a record. Do not block the merge on them.

If `git merge --squash` reports a conflict, **abort the seal**:

```bash
git merge --abort
git reset --hard origin/main
```

Print:

```
Conflict squash-merging <branch> into main. Resolve manually
(rebase the branch, push, re-run /seal) — refusing to resolve inline.
```

Exit non-zero. Lite does not dispatch a conflict-resolution subagent — conflicts are rare here (branches are short-lived, slices are scoped) and inline guesswork is worse than asking the operator.

## Step 6 — Delete the branch

```bash
git branch -D <branch> 2>/dev/null || true
git push origin --delete <branch>
```

If the remote delete fails (already gone), continue — the merge already happened.

## Step 7 — Update the plan

Edit the plan file in place:

1. **Flip the slice's status:**

   ```
   Status: ready-for-seal  →  Status: shipped
   ```

2. **Update the `## Progress` checklist line** for this slice:

   ```
   - [x] <N>. <Slice title>  (shipped)
   ```

3. **Re-render the progress bar.** Count slices with `Status: shipped` (`<shipped>`) out of total (`<total>`). Compute filled cells: `filled = floor(shipped * 10 / total)`. Empty cells: `10 - filled`. Build the bar with `filled` × `█` followed by `10 - filled` × `░`. Replace the existing bar line:

   ```
   <bar> <shipped>/<total> slices shipped
   ```

   Examples (10 cells wide):
   - `0/3` → `░░░░░░░░░░ 0/3 slices shipped`
   - `1/3` → `███░░░░░░░ 1/3 slices shipped`
   - `2/3` → `██████░░░░ 2/3 slices shipped`
   - `3/3` → `██████████ 3/3 slices shipped`

Leave the slice's `Branch:` value alone (git-archaeology breadcrumb). Leave any `### Friction` subsection alone — if a slice shipped after going through friction, the history stays in the plan.

## Step 8 — Move the plan if drained

If every slice in the plan now has `Status: shipped`, move the plan to the done folder and flip its frontmatter `status:`:

```bash
# Flip the frontmatter line first:
#   status: active   →   status: done
# Then:
mkdir -p .claude/plans/done
mv ".claude/plans/active/<slug>.md" ".claude/plans/done/<slug>.md"
```

If any slice is still `queued`, `ready-for-temper`, `ready-for-seal`, or `friction`, leave the file in `active/`.

## Step 9 — Log tokens

`/seal` doesn't dispatch a subagent, so token usage is whatever the seal session itself burned. Recording it is optional — the JSONL log is primarily for `/forge` and `/temper`, where the work is heavier. If you do log a row, use `"phase":"seal"`; otherwise skip.

## Step 10 — Print the run summary

```
Sealed slice <N> of <slug>: <slice title>
  merged: <branch> → main
  progress: <bar> <shipped>/<total>
  plan: <still active | moved to done/>

Next: <whatever's next — see below>
```

The `Next:` line picks one of:

- If the plan still has `friction` or `queued` slices: `run /forge to build the next slice of <slug>`.
- If the plan has `ready-for-temper` slices: `run /temper to review`.
- If the plan has `ready-for-seal` slices: `run /seal to ship the next one`.
- If the plan was just moved to `done/` and another active plan exists: `run /forge — next active plan is <other-slug>`.
- If no active plans remain: `run /ponder when you have new work`.

That line is the whole handoff. Print it and stop.

## What `/seal` does NOT do

- **Does not seal more than one slice per invocation.** Even if three slices are `ready-for-seal`, `/seal` ships exactly one. Operator runs `/seal` again for the next.
- **Does not resolve merge conflicts.** Aborts and surfaces to the operator.
- **Does not touch `main` if the slice isn't `ready-for-seal`.** No skipping `/temper`.
- **Does not auto-chain.** No "now run `/forge` for the next slice" — print the recommendation, let the operator decide.
- **Does not delete `### Friction` subsections.** If a slice shipped after rework, its friction history stays in the plan as a breadcrumb.
- **Does not edit other plans.** Only the one named (or most-recently-modified).

## Rules

- **One slice per `/seal`.** Pick → merge → flip → stop.
- **Branch must exist on origin** before merging — no merging a ghost.
- **Conflicts abort, not resolve.** Lite is small; conflicts are rare; manual is fine.
- **Progress bar is 10 cells, recomputed every seal.** `floor(shipped * 10 / total)` filled.
- **Drained plan moves to `done/`** and flips its frontmatter to `status: done`.
- **Plan file is the source of truth.** `Status: shipped` slices are immutable history.
