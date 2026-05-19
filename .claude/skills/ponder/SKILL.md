---
name: ponder
description: Use when starting new work from a fuzzy idea. Grills the idea with grill-me, writes a single plan file under .claude/plans/active/<slug>.md with H2 slice sections each Status queued. First phase of the Ponder → Forge → Temper → Seal workflow. Ends with a plan file ready for /forge.
---

# Ponder — think, scope, write the plan

The planning phase of the four-phase pipeline. You leave Ponder with **one plan file** sitting in `.claude/plans/active/<slug>.md`, every slice marked `Status: queued`, ready for `/forge` to pick up.

**The pipeline shape:**

```
/ponder  →  /forge  →  /temper  →  /seal
```

One operator command per phase. No auto-chain. Each phase reads the plan file as its source of truth and updates the slice it touched.

## Invocation

```
/ponder              # blank slate
/ponder <hint>       # one-line hint about the idea
```

## Pre-step — survey state

Before grilling, list the active plans so you know what's already in flight:

```bash
ls -t .claude/plans/active/ 2>/dev/null
```

If there are active plans, glance at their `## Progress` sections. New work usually means a new plan file — but if the idea is a small extension of something in flight, ask the user once whether to append a slice to the existing plan instead of starting a new one. Default to **new plan** if ambiguous.

## Workflow

| Step | Action |
| --- | --- |
| 1 | Invoke `grill-me` |
| 2 | Decide slug + slice count |
| 3 | Confirm with operator |
| 4 | Write the plan file |

### 1. Grill (`grill-me`)

Invoke the upstream `grill-me` skill. One question at a time. Recommend an answer for each. Grill until:

- The **goal** is one paragraph (why this exists, what done looks like).
- The **slices** are listed — each one a shippable unit, branch-per-slice. Aim for 1–5 slices; if the grill produces more, push back and split into a follow-up plan.
- Each slice has a **clear acceptance bar** (what existing or new behavior proves it's done).
- **Constraints / out of scope** are written down so a builder doesn't drift.

If the operator gives a tiny one-liner ("fix the typo on the login page"), do not grill — write a one-slice plan directly. Grill exists for fuzzy ideas, not for known work.

### 2. Decide slug + slice count

The **slug** is `kebab-case`, short (2–4 words), filename-safe. Examples: `auth-flow`, `dark-mode`, `cache-invalidate`. It becomes the plan filename, every branch's middle segment (`feat/<slug>-s<N>-<desc>`), and the plan's `name:` frontmatter.

Check for collisions:

```bash
test -e ".claude/plans/active/<slug>.md" && echo COLLIDES
test -e ".claude/plans/done/<slug>.md"   && echo COLLIDES
```

On collision, append `-2`, `-3`, etc.

### 3. Confirm with operator

Render the slug, slice count, and one-line slice titles. Ask once:

> "Plan: **<slug>** — <N> slices. Ready to write it?"

If the user pushes back on scope, edit inline. Do not re-open the grill.

### 4. Write the plan file

Write `.claude/plans/active/<slug>.md` in this exact shape:

```markdown
---
name: <slug>
status: active
created: <YYYY-MM-DD>
---

# <Plan title — human-readable>

## Progress
░░░░░░░░░░ 0/<N> slices shipped
- [ ] 1. <Slice 1 title>  (queued)
- [ ] 2. <Slice 2 title>  (queued)
- [ ] 3. <Slice 3 title>  (queued)

## Goal
<one paragraph — why this exists, what done looks like>

## Constraints / out of scope
- <constraint>
- <constraint>

---

## Slice 1: <Slice 1 title>
Status: queued
Branch: -

<slice body — what to build, acceptance criteria, any concrete file paths
or function names the grill produced>

---

## Slice 2: <Slice 2 title>
Status: queued
Branch: -

<slice body>

---

## Slice 3: <Slice 3 title>
Status: queued
Branch: -

<slice body>
```

Rules for the plan file:

- **Progress bar is 10 cells wide.** `█` for shipped slices, `░` for everything else. `0/3 shipped` → `░░░░░░░░░░ 0/3 slices shipped`. At `2/3` → `██████░░░░ 2/3 slices shipped` (six cells filled for two-of-three, rounded down — `/seal` re-renders this exactly, see its SKILL).
- **Slice checklist mirrors slice status.** `- [ ]` for queued / ready-for-temper / friction, `- [x]` for shipped. The parenthetical at the end of each checklist line is the current status word.
- **Slices are H2 headings** (`## Slice <N>: <title>`). `/forge`, `/temper`, and `/seal` all grep on this shape — do not change it.
- **Each slice has two metadata lines under the heading**, in this order: `Status: <state>` then `Branch: <branch-or-dash>`. No blank line between them; one blank line after `Branch:` before the body.
- **Status states.** `queued` → `ready-for-temper` → `ready-for-seal` → `shipped`. The off-ramp is `friction` (set by `/temper`, cleared by re-running `/forge` on that slice).
- **Branch is `-`** until `/forge` fills it. `/seal` does not clear it on ship — the value stays for git-archaeology purposes.
- **Slices are separated by `---`** (an `<hr>` on its own line). This makes the file readable and lets greps anchor on it.

## Exit criteria

- `.claude/plans/active/<slug>.md` exists with every slice `Status: queued`.
- The plan file is the only artifact. No issues, no labels, no PRs.
- Print the handoff line:

  > "Run `/forge` to build slice 1 of `<slug>`."

- Session ends. Operator runs `/forge` next.

## When NOT to use `/ponder`

| Situation | Use instead |
| --- | --- |
| Plan file already exists with a queued slice | `/forge` directly |
| Trivial one-liner (typo, copy fix, obvious bug) | Branch + commit + manual merge — no plan needed |
| Unknown-cause bug (can't repro, don't know what's broken) | `/diagnose` first, then `/ponder` with its output |

## Anti-patterns

- **Don't grill a one-liner.** If the work fits in one sentence and one file, skip the grill and write a one-slice plan directly. The grill is for fuzzy ideas.
- **Don't write more than ~5 slices in one plan.** If the grill produces 8 slices, split into two plans. A plan is a coherent batch — not a roadmap.
- **Don't pre-fill `Status: ready-for-temper` or `Branch: feat/...`.** Every slice starts `queued` with `Branch: -`. `/forge` fills the branch.
- **Don't run `/forge` from inside Ponder.** Phases are session-scoped. End the session, hand off via the plan file.
- **Don't edit shipped slices.** A slice with `Status: shipped` is history. If something needs fixing, add a new slice (here, or in a follow-up plan).
