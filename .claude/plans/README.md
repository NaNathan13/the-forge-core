# Plans

This directory is the pipeline's **ledger**. There is no Mission Control file in Lite — the contents of `active/` and `done/` are the ledger.

## Convention

- `active/<slug>.md` — a plan with at least one un-shipped slice.
- `done/<slug>.md` — every slice in this plan is `shipped`. Moved here by `/seal` when the last slice ships.
- Slugs are kebab-case derived from the feature name (e.g. `auth-flow`, `dark-mode`, `csv-export`).

## Plan-file shape

Each plan file:

```markdown
---
name: <slug>
status: active | done
created: <YYYY-MM-DD>
---

# <Title>

## Progress
░░░░░░░░░░ 0/N slices shipped
- [ ] 1. <slice-1-title>  (queued)
- [ ] 2. <slice-2-title>  (queued)
- [ ] 3. <slice-3-title>  (queued)

## Goal
<...>

## Constraints / out of scope
<...>

---

## Slice 1: <title>
Status: queued | ready-for-temper | ready-for-seal | friction | shipped
Branch: - | feat/<slug>-s1-<short-desc>

<acceptance criteria, implementation notes>

### Friction         ← only present if /temper marked this slice friction
<reviewer findings + intent-match notes + timestamp>
```

The progress bar is 10 cells wide: `floor(shipped * 10 / total)` filled with `█`, the rest `░`.

## Who writes what

- `/ponder` (via `/inscribe`) — creates `active/<slug>.md` with all slices `Status: queued`.
- `/forge` — flips a slice `queued | friction → ready-for-temper`, fills in `Branch:`.
- `/temper` — flips `ready-for-temper → ready-for-seal | friction`, may append `### Friction`.
- `/seal` — flips `ready-for-seal → shipped`, re-renders the progress bar, archives plan to `done/` if drained.

Workers (dispatched subagents) **never** edit plan-file `Status:` lines. Only the orchestrators do.

## This README is permanent

Don't delete it when populating the directory. It documents the contract.
