---
name: ponder
description: Phase 1 of the workflow — turn a fuzzy idea into shared understanding by grilling it, then hand off to /inscribe to write the plan. Use when starting new work from a rough idea. Triggered by /ponder.
---

# /ponder — think the work through

`/ponder` is the **planning phase**. Its job is to turn a fuzzy idea into a clear, agreed shape — *before* any plan file is written. It does not write code and does not write the plan; that's `/inscribe`.

```
Ponder → Forge → Temper → Seal      (the Ponder phase = /ponder then /inscribe)
```

## What it does

1. **Understand the idea.** Read what the user is asking for. If anything material is ambiguous — scope, the shape of "done", a fork in approach — resolve it now, not later.

2. **Grill it.** For anything non-trivial, lean on the `grill-me` skill to stress-test the idea: walk the decision tree, surface hidden assumptions, settle each open question one at a time. Skip the grilling only when the work is genuinely small and unambiguous.

3. **Settle the slices.** By the end you should know, roughly, how the work breaks into parts — the slices `/inscribe` will write down. A slice is one coherent chunk of work you could describe in a sentence. Aim for a handful, not twenty.

4. **Hand off.** Once the shape is clear, stop and recommend the next step:

   > Understanding reached. Run `/inscribe` to write the plan.

## Rules

- **No plan file here.** `/ponder` reaches understanding; `/inscribe` records it. Don't create anything under `.claude/plans/`.
- **No code.** Planning only.
- **Resolve forks before inscribing.** A plan written on top of an unresolved question just defers the problem into `/forge`.
- **One idea per ponder.** If the conversation reveals two unrelated efforts, that's two plans — ponder them separately.
