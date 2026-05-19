---
name: inscribe
description: Write up the plan file from resolved /ponder decisions. No GitHub issues, no PRs — just a single Markdown plan under .claude/plans/active/<slug>.md. Sub-skill of Ponder, auto-invoked after the grill. Also callable standalone when decisions are already resolved. Triggered by /inscribe, "write it up", "write the plan".
---

# Inscribe — write up the plan, hand off

The "writing" sub-skill of Ponder for The Forge Lite. Takes resolved design decisions and produces a single plan file under `.claude/plans/active/<slug>.md`. That file is the entire artifact — no PRDs, no GitHub issues, no kanban moves.

**Inscribe does NOT grill.** If decisions are unresolved, stop and tell the user to run `/ponder` first. Inscribe's job is mechanical: pick the slug → write the plan → hand off.

## Invocation

```
/inscribe                      # standalone — asks for the feature description
```

Or auto-invoked by `/ponder` after the grill, which passes resolved inputs (title, goal, constraints, slices).

## Inputs

Inscribe receives resolved design decisions from one of:
- A completed `/grill-me` or `/ponder` session in this conversation.
- A direct `/inscribe` invocation where the user describes decisions inline.

You need, at minimum:

- **Title** — short human title for the feature (e.g. "Auth & login").
- **Goal** — one paragraph describing what shipping this means.
- **Constraints / out of scope** — what this plan explicitly does not cover. Empty list is acceptable.
- **Slices** — an ordered list of shippable steps. Each slice carries a one-line title and a body (acceptance criteria, key interfaces, anything the worker needs).

If any of these are missing when invoked standalone, ask for them once via AskUserQuestion — but do not interview. If the user has more than one open question, stop and redirect to `/ponder`.

## Workflow

### 1. Pick a slug

Derive a kebab-case slug from the title:

- Lowercase, ASCII only.
- Spaces and underscores → `-`.
- Strip punctuation.
- Trim to ~40 chars.

Examples:
- "Auth & login" → `auth-login`
- "Status chip on list cards" → `status-chip-list-cards`

### 2. Refuse if the plan already exists

```bash
[[ -f ".claude/plans/active/<slug>.md" ]] && exit
```

If `.claude/plans/active/<slug>.md` already exists, **stop**. Print:

```
Plan already exists at .claude/plans/active/<slug>.md.

Either pick a different name, or `/rollback` / archive the existing plan first.
```

Do not overwrite. Do not append.

### 3. Render the plan file

Write `.claude/plans/active/<slug>.md` using `Write`. The shape is fixed:

```markdown
---
name: <slug>
status: active
created: <YYYY-MM-DD>
---

# <Title>

## Progress
░░░░░░░░░░ 0/<N> slices shipped
- [ ] 1. <slice-1-title>  (queued)
- [ ] 2. <slice-2-title>  (queued)
- [ ] 3. <slice-3-title>  (queued)

## Goal
<goal paragraph>

## Constraints / out of scope
<constraints>

---

## Slice 1: <slice-1-title>
Status: queued
Branch: -

<slice-1-body — acceptance criteria, key interfaces, anything the worker needs>

## Slice 2: <slice-2-title>
Status: queued
Branch: -

<slice-2-body>

## Slice 3: <slice-3-title>
Status: queued
Branch: -

<slice-3-body>
```

Rules:

- **Progress bar.** Always 10 cells. Shipped slices use `█`; not-yet-shipped use `░`. At inscribe time, the bar is always `░░░░░░░░░░ 0/N slices shipped` where `N` is the slice count.
- **Slice headers.** Numbered 1..N. Each slice opens with `Status: queued` and `Branch: -` on the two lines right under the heading. These two lines are load-bearing — `/forge-worker` flips them as it builds.
- **Created date.** Today's date in UTC (`YYYY-MM-DD`).
- **Status field.** Always `active` at inscribe time. `/seal` flips it to `done` and moves the file under `.claude/plans/done/`.
- **Empty constraints.** If there are no constraints, write `None — see slice bodies.`. Do not omit the section.

### 4. Print the handoff

After writing the file, print exactly:

```
Wrote .claude/plans/active/<slug>.md (<N> slices).

  1. <slice-1-title>
  2. <slice-2-title>
  ...

Next: /forge
```

End the session. The user runs `/forge` next.

## Anti-patterns

- **Don't grill.** Inscribe writes up resolved decisions. If you're tempted to ask a design question, hand back to `/ponder`.
- **Don't overwrite an existing plan.** Refuse the run instead. The plan file is the source of truth — clobbering it loses worker progress.
- **Don't file GitHub issues.** Lite has no issues. The plan file is the issue.
- **Don't run `/forge` from inside inscribe.** Phases are session-scoped per the Lite contract. End the session, hand off.
- **Don't omit `Status:` / `Branch:` lines on slices.** `/forge-worker` reads them; they are not decorative.
- **Don't change the progress-bar width.** 10 cells, always.
