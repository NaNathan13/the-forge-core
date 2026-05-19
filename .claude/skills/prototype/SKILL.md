---
name: prototype
description: Fast-path planner — skip the grill, write a one-slice plan from a short description. For work the operator can scope in two minutes and just wants to start building. Triggered by /prototype, "spike but keep", "smoke-test X", "scope in two minutes", "skip the ceremony — write the plan".
---

# Prototype — fast-path planner

`/prototype` is the **lightweight planning path** for The Forge Lite. Where `/ponder` interviews the user exhaustively, `/prototype` asks at most one clarifying question and writes a one-slice plan file directly. It exists for the case where the user already knows what they want and just needs the plan written so `/forge` can run.

It is **not** a replacement for `/ponder`. If the work is genuinely complex — multiple unclear decisions, fuzzy requirements, anything that would benefit from grilling — redirect.

## Pipeline placement

```
/prototype ──→ /forge ──→ /temper ──→ /seal
```

Same downstream pipeline as `/ponder`. Only the planning phase differs: no grill, no PRD, one slice in `.claude/plans/active/<slug>.md`.

## Invocation

```
/prototype                        # blank — asks for the idea
/prototype <one-line idea>        # idea provided up front
```

## Workflow

### 1. Capture the idea

If no idea was passed in the invocation, ask once:

> What do you want to prototype? (One line is fine.)

Keep this short. If the user starts unloading a multi-paragraph spec or floats multiple design alternatives, that's a redirect signal — see [Anti-pattern guard](#anti-pattern-guard).

### 2. At most one clarifying question

If the description is genuinely ambiguous (e.g. "build a status thing" — for what? where?), ask **one** AskUserQuestion to resolve. Otherwise skip this step entirely.

Examples of ambiguity worth resolving:
- The output surface is unclear ("a script" vs "a CLI tool" vs "a function in the existing module").
- A load-bearing constraint is missing ("which file?", "which framework integration?").

Examples that do **not** justify a question:
- Stack choice when the repo already has a clear stack — just use it.
- Test framework — use whatever the repo already uses.

One question, max. If you find yourself wanting a second, redirect to `/ponder`.

### 3. Pick a slug

Derive a kebab-case slug from the idea:
- Lowercase, ASCII only.
- Spaces and underscores → `-`.
- Strip punctuation.
- Trim to ~40 chars.

If `.claude/plans/active/<slug>.md` already exists, append a `-2` suffix (or `-3`, etc.) until it doesn't.

### 4. Write the plan file

Write `.claude/plans/active/<slug>.md` using `Write`. Exactly one slice:

```markdown
---
name: <slug>
status: active
created: <YYYY-MM-DD>
---

# <Title from the idea>

## Progress
░░░░░░░░░░ 0/1 slices shipped
- [ ] 1. <slice-title>  (queued)

## Goal
<one-paragraph description of what shipping this means>

## Constraints / out of scope
None — single-slice prototype.

---

## Slice 1: <slice-title>
Status: queued
Branch: -

**What to build:**
<concise description>

**Acceptance criteria:**
- [ ] <testable criterion 1>
- [ ] <testable criterion 2>

**Out of scope:**
- <anything adjacent the slice should not touch, or "None">
```

Rules:

- **Progress bar.** Always `░░░░░░░░░░ 0/1 slices shipped` at write time.
- **Status / Branch lines.** Required on the slice — `/forge-worker` reads them.
- **Acceptance criteria.** At least one, max ~3. Testable phrasing.
- **Created date.** Today's date in UTC (`YYYY-MM-DD`).

### 5. Print the handoff

```
Wrote .claude/plans/active/<slug>.md (1 slice).

  1. <slice-title>

Next: /forge
```

End the session. The user runs `/forge` next.

## Anti-pattern guard

If the user's idea sounds complex, redirect **before** writing anything:

Signals that this is actually a `/ponder` job:
- More than one shippable slice implied.
- Multiple unclear architectural decisions ("should this use X or Y?").
- "I want to figure out…" / "I'm not sure how this should work" / "let's design…"
- Cross-cutting concerns (auth + payments + data model in one ask).
- The user is already describing competing approaches.

When you spot one of these, say:

> This sounds like a `/ponder` job — `/prototype` is for things you can sketch in
> 2 minutes. Want to switch to `/ponder` so we can grill it properly?

If the user insists, proceed — but note in the slice body that the scope was flagged as ponder-shaped.

## What `/prototype` deliberately skips

| Step | Why skipped |
|------|-------------|
| `/grill-me` | Trusts the user already knows the shape. |
| Multi-slice plan | Prototypes are scoped to one shippable step. |
| Constraints section | A one-slice prototype's constraints live in the slice's `Out of scope`. |

## When to use `/prototype` vs the alternatives

| Situation | Use |
|-----------|-----|
| "I want to build a todo app component" — clear scope, small | `/prototype` |
| Spike: "does this library work for our case?" | `/tinker` (throwaway, no plan) |
| Complex feature, fuzzy requirements, design decisions to make | `/ponder` |
| Bug you can repro and fix | `/prototype` single-slice (or `/diagnose` first) |
| You already have a plan file | `/forge` directly |

## Anti-patterns

- **Don't grill.** If you find yourself asking a second question, stop and redirect to `/ponder`.
- **Don't write multiple slices.** That's `/ponder` + `/inscribe`'s job. Prototype is exactly one slice.
- **Don't run `/forge` from inside `/prototype`.** End the session, hand off.
- **Don't overwrite an existing plan.** Suffix the slug instead.
