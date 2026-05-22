---
name: temper
description: Phase 3 of the workflow — review and harden what /forge built. Checks each slice against the plan, fixes issues inline, and sends weak slices back by un-ticking them. Triggered by /temper after /forge.
---

# /temper — review and harden

`/temper` is the **review-and-harden phase**. It checks the built work against the plan, tightens it up, and flags anything that isn't really done. Inline — no subagents.

```
Ponder → Forge → Temper → Seal      (the Ponder phase = /ponder then /inscribe)
```

## What it does

1. **Pick the plan.** Same rule as `/forge`: most-recently-modified active plan, or the named one.

2. **Look at what changed.** Review the work `/forge` committed:

   ```bash
   git show --stat HEAD     # or git diff against the commit before the build
   ```

   Read the actual changes, not just the file list.

3. **Check each slice against its intent.** For every slice marked done, ask:
   - Does the change actually satisfy the slice's acceptance notes?
   - Is it correct, safe, and reasonably clean? Any obvious bug, missing edge case, or risky shortcut?
   - For a tricky bug, lean on the `diagnose` skill.

4. **Prove nothing gets lost.** If the app keeps records the user relies on, verify persistence before calling it done: start the app, add a record through it (or via its API), then fully stop and restart the process and confirm the record is still there. Data that does NOT survive a restart — or that lives in browser storage (`localStorage` etc.) for real records — is an automatic fail: un-tick the storage slice with a `> needs rework:` note. (See the build doctrine in `CLAUDE.md`.)

5. **Harden inline.** Fix what you find — small corrections, a missing check, a test worth adding. These are improvements to work that's basically sound.

6. **Send back what isn't done.** If a slice doesn't actually meet its intent, **un-tick it** (`- [x]` → `- [ ]`), re-render the progress bar, and add a short note under the slice:

   > needs rework: <what's wrong / what's missing>

   The operator re-runs `/forge` to address it.

7. **Commit any fixes:**

   ```bash
   git add -A
   git commit -m "fix(<slug>): temper review"
   ```

8. **Hand off:**

   > Reviewed `<slug>`: <N> slices solid<, M sent back for rework>.
   > Run `/seal` to finish (or `/forge` to rework).

## Rules

- **Check intent, not just diff cleanliness.** A slice that runs but doesn't do what the plan said is not done.
- **Fix the small stuff, send back the big stuff.** Inline-fix sound work; un-tick anything that needs real rework.
- **Work in place.** No branches, no push. Commit fixes on the current branch.
- **No new scope.** Harden what's there; don't bolt on features the plan didn't ask for.
- **Durable storage is non-negotiable for record apps.** A record-keeping app whose data doesn't survive a restart is not done, no matter how good it looks.
