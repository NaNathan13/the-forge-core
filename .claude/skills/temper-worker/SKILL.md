---
name: temper-worker
description: Review and harden a built slice — reads the slice body from the plan file as intent, dispatches the reviewer agent on the slice-branch diff, runs an inline intent-match, and applies a strict friction rule (any reviewer HIGH OR intent-match failure → friction; else ready-for-seal). Returns a TEMPER_PASS or TEMPER_FRICTION result string. Does NOT modify the plan file — the orchestrator does that with the worker's returned friction body. Invoked as /temper-worker <plan-slug> <slice-N>.
---

# /temper-worker — Review and Harden a Built Slice (Lite)

`/temper-worker` is the per-slice worker of the Temper phase. It runs **after**
`/forge-worker` has committed code on the slice's branch and the orchestrator
has flipped the slice's `Status:` to `ready-for-temper`. Pipeline shape:

```
Ponder → Forge → Temper → Seal
```

`/forge-worker` shaped the part (implement → check → commit). `/temper-worker`
applies two LLM lenses to what was shipped — a reviewer-agent code-quality
pass and an inline intent-match against the slice body — then applies a
**strict friction rule** and returns a result string the orchestrator uses to
flip the slice's Status to `ready-for-seal` or `friction`.

## Strict friction rule — read this first

This is the gate. Compute the gate signal from the two lenses:

```
friction = (reviewer-HIGH-count > 0) OR (intent-match == fail)
```

No "should the build have caught it?" filtering. No natural-language verdict
mapping. No softening a fail because the diff looks well written. Same diff +
same slice body + same reviewer output + same intent-match verdict → same
result. The rule is mechanical so a retry is stable.

If the rule says friction, return `TEMPER_FRICTION`. Else return `TEMPER_PASS`.

## Inputs

- **Plan slug** — first argument. Identifies `.claude/plans/active/<plan-slug>.md`.
- **Slice number** — second argument. Identifies the `## Slice <N>: <title>` H2
  inside that file.
- When dispatched as a subagent by `/temper`, the same two values arrive as
  prompt context.

## Workflow

### 1. Setup

- **No new branch, no new commits.** `/temper-worker` reads existing state and
  judges it. It does not edit code, does not run the project's check command,
  does not amend commits.
- Read the plan file: `.claude/plans/active/<plan-slug>.md`.
- Locate the `## Slice <N>: <title>` H2. Read its body (the **intent**).
  Capture `Branch:` from the slice header — this is the diff target.
- Confirm `Status:` is `ready-for-temper`. If it's anything else, return
  `TEMPER_FRICTION` with `reason="slice not ready: status=<x>"`.

### 2. Pre-gate — cheap shape checks

Run these before any review work. Any failure short-circuits to friction.

1. **Branch exists locally.** `git rev-parse --verify <branch>`. If missing,
   return friction with `reason="slice branch not found"`.
2. **Branch has commits beyond main.** `git rev-list --count main..<branch>`.
   If zero, return friction with `reason="slice branch has no commits beyond main"`.
3. **No uncommitted state on the branch.** A worktree mid-flight on the slice
   branch means the forge-worker did not finish cleanly. If the branch is
   checked out and dirty, return friction with `reason="slice branch is dirty"`.

### 3. Read the diff

```bash
git diff main..<slice-branch>
```

Full diff, not just the file list. Both lenses below operate on it. If the
diff is enormous (>2000 lines), still review it — but in the reviewer
dispatch you may instruct the agent to focus on a named subset of files
flagged by the slice body. Document any such scoping in the prose summary so
the orchestrator can see the lens narrowed.

### 4. Dispatch the reviewer agent

Foreground dispatch. The reviewer agent reads the diff and returns
severity-tagged findings (HIGH / MEDIUM / LOW). Use the project's reviewer
agent definition under `.claude/agents/reviewer.md` if present; otherwise
dispatch a general-purpose subagent with reviewer instructions inline.

```
Agent({
  subagent_type: "reviewer",   // or general-purpose with .claude/agents/reviewer.md inlined
  description: "review slice <plan>-s<N>",
  prompt: "<reviewer instructions / agent def>\n\nReview this diff for slice <N> of plan <plan-slug>.\n\nIntent (slice body):\n<paste slice body here>\n\nDiff:\n<paste git diff main..<branch> here>\n\nReport HIGH-confidence findings only in the documented output format."
})
```

Parse the reviewer's output for:

- The **HIGH-findings list** under `### Findings` — count the `#### [HIGH]`
  blocks. That count is the gate signal for the reviewer lens.
- The **Verdict** line under `### Summary`. The verdict is human-readable
  context only — it is **NOT** the gate signal. The HIGH count is.

If the reviewer agent errors or returns no parseable findings block, treat
that as friction with `reason="reviewer dispatch failed"` and pass the
failure summary in the friction body. Do not re-dispatch — surface it.

### 5. Inline intent-match

`/temper-worker` itself runs this — no subagent dispatch. You already have the
slice body (intent) and the diff in context. Produce a one-line pass/fail
verdict.

Procedure:

1. Read the slice body's acceptance criteria. Most slices use a checkbox list
   or a `### Acceptance criteria` subsection; use whatever shape the slice
   actually uses.
2. Walk the diff and decide whether each criterion is satisfied by code or
   doc changes in the diff.
3. Emit one verdict line, internal to `/temper-worker`:
   - `intent-match: pass — <one-sentence reason>` if every load-bearing
     criterion is covered.
   - `intent-match: fail — <one-sentence reason>` if any load-bearing
     criterion is unaddressed, the diff adds the wrong thing, or the diff
     regresses a criterion previously met.

**Calibration.** This is a context-aware judgment a generic linter cannot
make. It asks "did `/forge-worker` actually solve the slice, or just produce
green checks on a tangent?" Be honest. If a criterion is not addressed by
the diff, that is a fail regardless of how clean the code is. A criterion
explicitly marked optional or "out of scope for this slice" in the body does
not count as load-bearing.

### 6. Apply the strict friction rule

```
friction = (reviewer-HIGH-count > 0) OR (intent-match == fail)
```

Branch on `friction`:

- **No friction (false).** Return `TEMPER_PASS`. Done.
- **Friction (true).** Compose the friction body (multi-line markdown the
  orchestrator will paste under `### Friction` in the plan file). Use this
  shape:

  ```markdown
  - Reviewer HIGH findings: <count>
    - <short title 1>
    - <short title 2>
  - Intent-match: <pass | fail — one-sentence reason>
  - Notes: <anything else load-bearing for the rework>
  ```

  Then return `TEMPER_FRICTION` with this body appended after the result
  line (see "Return the result string" below).

### 7. Return the result string

End the run by printing a short prose summary for humans, then **exactly one**
plain-text result line — and for friction, the multi-line friction body on
the lines below.

**On pass:**

```
TEMPER_PASS plan=<slug> slice=<N>
```

One line. Nothing after it.

**On friction:**

```
TEMPER_FRICTION plan=<slug> slice=<N> highs=<N> intent_match=<pass|fail>
<friction body — multi-line markdown the orchestrator pastes under '### Friction'>
```

The first line is parsed for `highs=<N>` and `intent_match=<pass|fail>`;
everything after the newline is the friction body the orchestrator splices
into the plan file. Do not wrap the friction body in code fences — the
orchestrator pastes it raw.

Examples:

Pass — no HIGHs, intent-match passes:

```
TEMPER_PASS plan=auth-flow slice=2
```

Friction — reviewer flagged a HIGH:

```
TEMPER_FRICTION plan=auth-flow slice=2 highs=1 intent_match=pass
- Reviewer HIGH findings: 1
  - missing null-check on session refresh path
- Intent-match: pass — auth wiring covers all three acceptance criteria
- Notes: HIGH is contained to one file; fix is ~10 lines.
```

Friction — intent-match failed:

```
TEMPER_FRICTION plan=auth-flow slice=2 highs=0 intent_match=fail
- Reviewer HIGH findings: 0
- Intent-match: fail — diff adds caching but slice asked for invalidation API
- Notes: rework should drop the cache module and implement the invalidation endpoint per criterion 2.
```

## Worker boundaries — restated

- **The worker does NOT modify the plan file.** The orchestrator owns plan-file
  edits. After you return `TEMPER_PASS`, `/temper` rewrites
  `Status: ready-for-temper` → `Status: ready-for-seal`. After you return
  `TEMPER_FRICTION`, `/temper` rewrites Status → `friction` and pastes your
  returned friction body under `### Friction`. If you edit the plan file
  yourself, you'll race the orchestrator and corrupt state.
- **The worker does NOT commit, push, or merge.** No code edits at all. Read,
  judge, return.
- **The worker does NOT re-dispatch the reviewer.** One reviewer call per run.
  If it fails, that is friction — surface it for human review.
- **The worker does NOT skip the intent-match.** Even if reviewer HIGHs already
  guarantee friction, run intent-match anyway and report it. The orchestrator
  uses both signals for the friction body, and a future rework needs to know
  whether the intent was met or not.

## Rules

- **Strict friction rule.** `(reviewer-HIGH-count > 0) OR (intent-match == fail)`
  → friction. No softening. No "but the verdict said clean".
- **HIGH count is the gate signal, not the verdict prose.** The reviewer's
  natural-language verdict is human-readable context; the `#### [HIGH]` block
  count drives the gate.
- **LLM judgment only.** Deterministic checks (script syntax, lint, project
  test command) are forge-worker's job and live in CI. The temper-worker
  applies LLM lenses: code review + intent-match.
- **One result line.** Exactly one `TEMPER_PASS` or `TEMPER_FRICTION` line at
  the end of the run. For friction, the body follows on subsequent lines —
  but only one result-line token.
- **Read-only on the repo.** No commits, no pushes, no plan-file edits, no
  branch switches.
- **Match the slice body's shape for acceptance criteria.** Don't impose a
  schema the slice doesn't use; read whatever the slice author wrote.
