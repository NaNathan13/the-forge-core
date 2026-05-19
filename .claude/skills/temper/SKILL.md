---
name: temper
description: The Temper phase — picks the most-recently-modified active plan (or the named one), finds the first ready-for-temper slice, dispatches a reviewer subagent on the diff, runs an inline intent-match vs the slice body, then applies the strict friction rule. Any reviewer HIGH or intent-mismatch → friction; else ready-for-seal. One slice per /temper invocation, then stop.
---

# /temper — review one slice

`/temper` is the **review-and-harden phase** of the four-phase pipeline. It picks one `ready-for-temper` slice, dispatches a reviewer subagent on the branch's diff, runs an inline intent-match against the slice body, and applies a strict friction rule. Then it stops. The operator runs `/seal` next (on pass) or `/forge` again (on friction).

```
/ponder  →  /forge  →  /temper  →  /seal
```

**One operator command per phase. One slice per /temper.** No auto-chain.

## Invocation

```
/temper                # most-recently-modified active plan
/temper <slug>         # explicit plan — .claude/plans/active/<slug>.md
```

## Step 1 — Pick the plan

Same selection rule as `/forge`. With an argument:

```bash
plan=".claude/plans/active/<arg>.md"
test -f "$plan" || { echo "no such plan"; exit 1; }
```

Without:

```bash
plan="$(ls -t .claude/plans/active/*.md 2>/dev/null | head -n1)"
test -n "$plan" || { echo "no active plans"; exit 1; }
```

Cache the slug.

## Step 2 — Pick the slice

The first slice with `Status: ready-for-temper`, in document order. If none exists, the plan has nothing for `/temper` to do:

```
Plan <slug>: nothing to review. Run /forge to build the next slice,
or /seal to ship anything ready-for-seal.
```

Read the slice's body (between its `## Slice <N>:` heading and the next `---`) and capture its `Branch:` value. That's the branch under review.

## Step 3 — Capture the diff

```bash
git fetch origin
diff="$(git diff origin/main...<branch>)"
```

If the diff is empty, that's a friction signal in itself — the builder claimed `ready-for-temper` but produced no changes. Apply friction (Step 6) with the note "empty diff against main" and stop.

## Step 4 — Dispatch the reviewer

Dispatch **one** reviewer subagent. It does not need a worktree — it operates on the captured diff text:

```
Agent({
  subagent_type: "reviewer",
  description: "review <slug> slice <N>",
  prompt: <see below>
})
```

The prompt contains, in order:

1. **The slice body verbatim** — the spec the diff is supposed to satisfy.
2. **The plan's `## Goal` and `## Constraints / out of scope`** — ambient context.
3. **The full `git diff` text** from step 3.
4. **The review contract** — "Review the diff. For every finding, label it `LOW`, `MEDIUM`, or `HIGH`. HIGH means the change is unsafe to ship as-is (correctness bug, security hole, breaks a documented constraint, missing test for a non-trivial new code path). Return a structured finding list."

The reviewer returns a list of findings, each with a severity label.

## Step 5 — Inline intent-match

`/temper` itself (not the reviewer) does the intent-match. Read the slice body's acceptance criteria. For each criterion, walk the diff and decide: **is this criterion satisfied by the changes?**

- **Pass:** every criterion has a clear corresponding change.
- **Fail:** at least one criterion has no matching change, OR a criterion's change contradicts the spec.

The intent-match is a single yes/no decision. Write a one-paragraph summary of the call either way; it goes into the plan on a friction outcome.

## Step 6 — Apply the strict friction rule

The rule is deterministic:

- **Any reviewer finding labeled `HIGH`** → friction.
- **Intent-match failed** → friction.
- **Otherwise** → `ready-for-seal`.

`MEDIUM` and `LOW` findings do NOT trigger friction on their own. They are noted in the plan but do not block the slice. (The reviewer can still call them out; `/seal` will surface them in the merge commit body if the slice ships.)

### Pass — `ready-for-seal`

Edit the plan in place to flip the slice:

```
Status: ready-for-temper  →  Status: ready-for-seal
```

Update the `## Progress` checklist:

```
- [ ] <N>. <Slice title>  (ready-for-seal)
```

Leave `Branch:` unchanged.

### Fail — `friction`

Edit the plan in place to flip the slice:

```
Status: ready-for-temper  →  Status: friction
```

Update the `## Progress` checklist:

```
- [ ] <N>. <Slice title>  (friction)
```

Then append a `### Friction` subsection inside the slice block (above the next `---`). Shape:

```markdown
### Friction
_Reviewed <YYYY-MM-DDTHH:MM:SSZ>_

**Reviewer HIGHs:**
- <one bullet per HIGH finding, verbatim from the reviewer>

**Intent-match:** <pass | fail — one-paragraph note from step 5>

**To fix:** <one-paragraph summary of what the next /forge run needs to address>
```

If a previous `### Friction` subsection already exists (this is a re-review after rework), **overwrite it** with the new one. Friction subsections are not history — they're the spec for the next rework attempt.

## Step 7 — Log tokens

Append one row to `.claude/token-usage.jsonl`:

```json
{"v":1,"ts":"<ISO8601>","phase":"temper","plan":"<slug>","slice":<N>,"tokens":<N>}
```

Use `npx ccusage@latest session --json` to read tokens. On unavailability, record `"tokens":null`.

## Step 8 — Hand off

On pass:

```
Reviewed slice <N> of <slug>: ready-for-seal.
Run /seal to ship it.
```

On friction:

```
Reviewed slice <N> of <slug>: friction.
See the ### Friction subsection in the plan for what to fix.
Run /forge to rework, or /seal to ship anything else marked ready-for-seal.
```

Then stop. Do not dispatch `/forge`. Do not dispatch `/seal`.

## What `/temper` does NOT do

- **Does not edit code.** Review only. If the reviewer wants a fix, that's friction → rework.
- **Does not run tests or check commands.** The builder already ran them; the reviewer reasons about the diff. If a check is suspicious, the reviewer raises it as a HIGH finding and `/temper` applies friction.
- **Does not auto-chain into `/seal` on pass.** Operator runs the next phase.
- **Does not auto-chain into `/forge` on friction.** Same rule.
- **Does not relax the friction rule.** Any HIGH or intent-mismatch is friction — no "the HIGH is probably fine" overrides. The deterministic rule is the whole point.
- **Does not re-review a `ready-for-seal` slice.** If the slice already passed, leave it alone; if the operator wants a second look, they manually flip it back to `ready-for-temper`.
- **Does not delete friction subsections.** Only overwrite them on re-review. `/seal` leaves them in place when the slice ultimately ships.

## Rules

- **One slice per `/temper`.** Pick → review → flip → stop.
- **Strict friction rule.** HIGH or intent-mismatch → friction. No exceptions.
- **Reviewer is a subagent.** `/temper` does not read every file in the diff inline; the reviewer does that and returns findings.
- **Intent-match is inline.** `/temper` itself owns the yes/no acceptance call against the slice body. Do not delegate it.
- **Token logging is `/temper`'s job.** One JSONL row per run.
- **Plan file is the source of truth.** Friction subsection is the spec for the next rework; `Status:` lines are the state machine.
