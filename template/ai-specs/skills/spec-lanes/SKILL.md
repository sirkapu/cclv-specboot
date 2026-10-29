---
name: spec-lanes
description: Use when a Spec Kit tasks.md exists and CC is about to implement it — before running /speckit-implement, after /speckit-tasks, or when CC says "split the tasks", "which tasks are LV's", "implement the spec", "run speckit implement". Splits tasks into CC / LV lanes from OWNERSHIP.md so CC never builds Lovable's backend.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# spec-lanes

## Why

Stock `/speckit-implement` executes **every** task in `tasks.md`, phase by phase, including the backend tasks that belong to LV. Spec Kit has no lane concept and no Lovable integration. It does require every task to name its file paths, so a task's lane follows from `OWNERSHIP.md`.

## Procedure

### Step 1 — Generate the plan as usual

`/speckit-constitution` (once per project), then `/speckit-specify` → `/speckit-clarify` (optional) → `/speckit-plan` → `/speckit-tasks`. These write `.specify/memory/constitution.md` and `specs/NNN-<feature>/{spec,plan,tasks}.md`; all of them are CC-owned.

### Step 2 — Split the tasks

```bash
bash scripts/spec-lanes.sh                 # newest specs/*/tasks.md
bash scripts/spec-lanes.sh specs/003-cart/tasks.md
```

The output lists each open task with its lane:

| Lane | Meaning | What you do |
|------|---------|-------------|
| `CC` | Every mapped path is CC's (or shared) | You implement it |
| `LV` | Its paths are LV's (server functions, migrations, auth, …) | Send it to Lovable |
| `MIXED` | Touches both CC-only and LV-only paths | Edit `tasks.md`: split it into a CC task and an LV task, then re-run |
| `UNKNOWN` | No path matches an `OWNERSHIP.md` row | Decide, and add the missing rows to `OWNERSHIP.md` |
| `CW` | Only CW-owned paths | Belongs in a CW brief |

### Step 3 — Send LV's tasks first

Use `lv-prompt-writer` with the LV task IDs as scope. Link `spec.md` and `plan.md`; push contracts before sending. Foundational-phase LV tasks (schema, server functions) usually block CC's user-story tasks, so start them early.

### Step 4 — Implement CC's tasks only

Paste the line the script prints:

```
/speckit-implement Implement ONLY tasks T002, T006, T007 (CC lane). Do not implement, edit files for, or mark any other task: LV tasks are delivered by Lovable.
```

This scoping is a prompt instruction, not a hard block. After the run, check `git diff --name-only` against `OWNERSHIP.md`. If you touched an LV path, revert it or log it under "Lane Crossings".

### Step 5 — Close the loop

When Lovable has pushed, pull, run `verify-after-pull.sh`, process the reply (`lv-response-reader`), then tick the LV task IDs `[X]` yourself. Re-run `spec-lanes.sh` to see what's left.

## Notes

- `/speckit-analyze` doesn't know about lanes. If the constitution says "LV-owned paths per OWNERSHIP.md are implemented only by Lovable", analyze will flag conflicts with it.
- The script treats every path a task mentions as edited. "Wire Cart (src/components/Cart.tsx) to addToCart from src/lib/cart.functions.ts" comes out MIXED even though only the component changes; reword the task so it names only the files it edits, and re-run.
- Don't add `[CC]`/`[LV]` labels to task lines. Spec Kit's task grammar is strict, and the lane already follows from the paths.
- Keep Spec Kit's git extension off (it is opt-in). Lovable syncs one branch, and per-feature branches fight that.
