---
name: forge
description: The Forge phase — picks the most-recently-modified active plan (or the named one), finds the first queued slice (or friction slice for rework), branches, dispatches a worktree-isolated builder subagent to implement + test + commit, then flips the slice to ready-for-temper. One slice per /forge invocation, then stop.
---

# /forge — build one slice

`/forge` is the **build phase** of the four-phase pipeline. It picks one slice from a plan file, branches, dispatches a builder subagent to write the code, and updates the slice to `Status: ready-for-temper`. Then it stops. The operator runs `/temper` next.

```
/ponder  →  /forge  →  /temper  →  /seal
```

**One operator command per phase. One slice per /forge.** No auto-chain into `/temper`, no auto-chain into `/seal`. If the queue has more work, the operator types `/forge` again.

## Invocation

```
/forge                 # most-recently-modified active plan
/forge <slug>          # explicit plan — .claude/plans/active/<slug>.md
```

## Step 1 — Pick the plan

If an argument was given:

```bash
plan=".claude/plans/active/<arg>.md"
test -f "$plan" || { echo "no such plan: $plan"; exit 1; }
```

Otherwise, pick the most-recently-modified active plan:

```bash
plan="$(ls -t .claude/plans/active/*.md 2>/dev/null | head -n1)"
test -n "$plan" || { echo "no active plans — run /ponder first"; exit 1; }
```

Read the plan top-to-bottom. Cache the slug (from `name:` in frontmatter) and the slice count.

## Step 2 — Pick the slice

Slice precedence is **friction first, then queued first**:

1. **First slice with `Status: friction`** (rework lane). The operator hit this branch by re-running `/forge` after `/temper` flagged a problem. Read the slice's `### Friction` subsection — that's the spec for what to fix this run.
2. **Otherwise, first slice with `Status: queued`** (normal build lane).

To find a slice by status, grep for the metadata line and walk back to the nearest `## Slice` heading:

```bash
# slice numbers with a given status, in document order:
awk '
  /^## Slice [0-9]+:/ { current = $0; sub(/^## Slice /, "", current); sub(/:.*/, "", current); slice = current }
  /^Status: friction/ { print slice; exit }
' "$plan"
```

If neither pattern matches, the plan is fully built (every slice is `ready-for-temper`, `ready-for-seal`, or `shipped`). Print:

> "Plan `<slug>`: nothing to build. Run `/temper` to review, or `/ponder` for new work."

Then exit. Do not dispatch.

## Step 3 — Branch

Name the branch `feat/<slug>-s<N>-<short-desc>`, where `<short-desc>` is a 2–4 word kebab-cased summary of the slice title.

```bash
git fetch origin
git checkout main
git pull --ff-only origin main
git checkout -b feat/<slug>-s<N>-<short-desc>
```

In the **rework lane** the branch already exists — `git checkout` it instead of creating it, then `git pull --ff-only origin <branch>` to ensure local matches remote. The builder will commit on top.

## Step 4 — Dispatch the builder

Dispatch **one** builder subagent, worktree-isolated:

```
Agent({
  subagent_type: "builder",
  isolation: "worktree",
  description: "build <slug> slice <N>",
  prompt: <see below>
})
```

The prompt is a single message containing, in order:

1. **The branch name** — already checked out in the subagent's worktree.
2. **The full slice body** — copy everything from the `## Slice <N>:` heading down to (but not including) the next `---` separator. Include the `Status:` and `Branch:` lines.
3. **The plan's `## Goal` and `## Constraints / out of scope` sections** — verbatim, as ambient context.
4. **(Rework lane only) The slice's `### Friction` subsection** — verbatim, framed as "this is what to fix; the previous attempt is already on this branch."
5. **The project's check command** — read it from `CLAUDE.md` `## Tech stack` table (the `Check command:` row). If absent, the builder runs no automated check.
6. **The exit contract** — "Implement the slice. Run the check command and confirm it passes. Commit with a conventional message. Return when done."

The builder writes code, runs the check, commits to the branch, and returns control. `/forge` waits.

## Step 5 — Update the plan

Once the builder returns, edit the plan file in place to flip the slice:

```bash
# Inside the slice (between its ## Slice heading and the next ---):
#   Status: queued       →  Status: ready-for-temper
#   Branch: -            →  Branch: feat/<slug>-s<N>-<short-desc>
```

Use a scoped `sed` — match within the slice block only. The safest approach is awk: walk the file, track which slice you're inside, rewrite the two metadata lines when inside slice `<N>`, write everything else through unchanged. Re-render the `## Progress` checklist line for this slice:

```
- [ ] <N>. <Slice title>  (ready-for-temper)
```

The progress bar itself does NOT advance — only `shipped` slices fill cells. `/seal` re-renders the bar.

**Rework lane note.** The slice was `Status: friction` going in. Coming out, set `Status: ready-for-temper` and leave the `### Friction` subsection where it is — `/temper` may overwrite it on the next review, or `/seal` will leave it untouched if the slice ships. Do not delete it inline.

## Step 6 — Log tokens

Append one row to `.claude/token-usage.jsonl`:

```json
{"v":1,"ts":"<ISO8601>","phase":"forge","plan":"<slug>","slice":<N>,"tokens":<N>}
```

Use `npx ccusage@latest session --json` to read the token count for this run. If ccusage is unavailable, record `"tokens":null` — the row still lands.

## Step 7 — Hand off

Print a three-line summary:

```
Built slice <N> of <slug>: <slice title>
Branch: feat/<slug>-s<N>-<short-desc>
Run /temper to review.
```

Then stop. Do not dispatch `/temper`. Do not dispatch `/seal`. The operator runs the next phase.

## What `/forge` does NOT do

- **Does not merge.** Branch stays open until `/seal` squash-merges it. `/forge` never touches `main`.
- **Does not review the diff.** `/temper` does that with a reviewer subagent.
- **Does not run a second slice.** Exactly one slice per invocation. If two slices need building, the operator runs `/forge` twice.
- **Does not auto-chain into `/temper`.** The whole pipeline is one-command-per-phase. Print the handoff and stop.
- **Does not resolve merge conflicts.** If the rework-lane `git pull --ff-only` fails because the branch was force-pushed elsewhere, abort the run and surface it to the operator — do not silently rebase.
- **Does not edit shipped slices.** A `Status: shipped` slice is immutable history.

## Rules

- **One slice per `/forge`.** Pick → build → flip → stop.
- **Branch per slice.** Never commit to `main`. `/seal` does the squash-merge.
- **Friction beats queued.** Always pick a `friction` slice before any `queued` slice in the same plan.
- **Builder is worktree-isolated.** The builder subagent runs in its own worktree; `/forge` does no inline code editing.
- **Token logging is `/forge`'s job.** One JSONL row per run.
- **Plan file is the source of truth.** No issues, no labels, no PRs. The plan's `Status:` lines are the state machine.
