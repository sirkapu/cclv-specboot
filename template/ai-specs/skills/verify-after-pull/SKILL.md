---
name: verify-after-pull
description: Use after every `git pull` from Lovable's branch. Triggers when CC says "I just pulled", "Lovable shipped X", "review what LV did", "verify LV's work", or after any merge from the LV branch.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# verify-after-pull

## When to use

After pulling commits from Lovable's branch. Before you start wiring frontend against the new backend.

## Procedure

### Step 1 — Run the verify script

```bash
bash scripts/verify-after-pull.sh
```

What it does:

- Lists files Lovable modified in the latest commit batch.
- Warns if any modified file is in a CC-owned path (per `OWNERSHIP.md`).
- Runs `npm run lint` (if available).
- Runs `npm run build` and reports failure clearly.

If the script reports lane crossings, READ THEM. Don't auto-accept.

### Step 2 — Read LV's response report

Open `control-center/lv-responses/LV-[NAME]-response.md` for the most recent prompt(s).

Check for:

- **Lane Crossings** — confirm justification is real; if not, plan to revert.
- **Contract changes** — if LV changed the response shape, update `src/contracts/<name>.ts` and document in `build-state.md`.
- **Secrets required for deploy** — make sure Sir has set them in Supabase.
- **Known issues / flags for CC** — these are your follow-up todos.

### Step 3 — Check for blockers

```bash
ls control-center/lv-blockers/
```

If any files are there, read them. Resolve before continuing — either inline (write a clarifying LV prompt) or by adjusting your plan.

### Step 4 — Smoke-test the affected flow

If LV shipped an edge function:

1. Start dev server: `npm run dev`.
2. Exercise the flow that hits the new endpoint.
3. Open browser DevTools → Network tab. Confirm 200 OK, expected shape, expected timing.
4. If credits are involved, confirm the credit ledger entry was created.

### Step 5 — Wire the frontend

ONLY after verify passes, the response report is read, and the smoke test succeeds.

### Step 6 — Update build-state.md

Append a session entry:

- Date.
- What LV shipped (commit refs).
- What you wired (commits to come).
- Any contract changes.
- Open follow-ups.

## Failure modes — what to do

| Symptom | Action |
|---------|--------|
| `verify-after-pull.sh` reports a lane crossing in a CC-owned file | Read the diff. If legitimate (real bug), re-implement cleanly in the CC layer; revert LV's edit. If accidental, revert. Log in `build-state.md`. |
| `npm run build` fails | Don't auto-fix LV's code. Read the error. If it's a CC-owned file, fix. If LV-owned, write a hotfix LV prompt. |
| Contract shape doesn't match what LV shipped | LV's response report should have flagged this — re-read it. If not, treat as a lane crossing — LV silently changed the shape. Write a follow-up LV prompt to align. |
| Edge function returns 500 in smoke test | Read edge function logs in Supabase dashboard. Likely a secret issue or RLS misconfiguration. Write a fix prompt. |
| Realtime subscription doesn't fire | Check that the migration set `REPLICA IDENTITY FULL` and added the table to the realtime publication. If not, write a fix migration prompt. |
| Lovable opened a PR instead of pushing to main | Read the PR, run the same verify steps against the PR branch, then approve. Don't auto-merge — review first. |

## Skip when

- You haven't pulled new commits from Lovable.
- You're working on pure-frontend work that doesn't touch the backend.
- You're resolving an in-progress checklist that already had verification done in a previous session.
