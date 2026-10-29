---
name: verify-after-pull
description: Use after every `git pull` that brings in Lovable's commits. Triggers when CC says "I just pulled", "Lovable shipped X", "review what LV did", "verify LV's work", after an LV turn completes, or after any merge from the LV branch.
applies_to: [CC]
author: cclv-specboot
version: 0.2.0
---

# verify-after-pull

## When to use

Right after `git pull --ff-only` brings in Lovable's commits (CC runs the pull itself). Before you start wiring frontend against the new backend.

## Procedure

### Step 1 — Run the verify script

```bash
bash scripts/verify-after-pull.sh
```

What it does:

- Audits exactly what the pull brought in (`ORIG_HEAD..HEAD`; override with `VERIFY_RANGE=a..b`).
- Recognises Lovable's commits by their real author, `gpt-engineer-app[bot]` (or `lovable-dev[bot]` / `Lovable`), or by the `X-Lovable-Edit-ID` trailer. Override with `LOVABLE_AUTHOR_REGEX`.
- Looks up every file Lovable touched in `OWNERSHIP.md` (most specific row wins) and flags each one outside LV's lane.
- Flags any Lovable edit inside the `CCLV` block of `AGENTS.md`. Lovable's own notes elsewhere in that file are fine.
- Lists Lovable-touched files with no `OWNERSHIP.md` row (add rows), LV-owned files changed by someone else, and any committed `.env.local`.
- Runs `lint` and `build` (bun when the project uses it, npm otherwise).

If the script reports lane crossings, READ THEM. Don't auto-accept.

### Step 2 — Read LV's response report

Process LV's reply with `lv-response-reader` (MCP mode), or open `control-center/lv-responses/LV-[NAME]-response.md` (paste mode).

Check for:

- **Lane Crossings** — confirm justification is real; if not, plan to revert.
- **Contract changes** — if LV changed the response shape, update `src/contracts/<name>.ts` and document in `build-state.md`.
- **Secrets required for deploy** — make sure Sir has set them (Lovable Secrets, or Supabase).
- **Known issues / flags for CC** — these are your follow-up todos.

### Step 3 — Check for blockers

```bash
ls control-center/lv-blockers/
```

If any files are there, read them. Resolve before continuing — either inline (write a clarifying LV prompt) or by adjusting your plan.

### Step 4 — Smoke-test the affected flow

If LV shipped a server function, server route or edge function:

1. Start dev server: `npm run dev` (or `bun run dev`).
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
| Endpoint returns 500 in smoke test | Read the logs: Lovable editor → Logs on Lovable Cloud, the Supabase dashboard on your own Supabase. Likely a secret issue or RLS misconfiguration. Write a fix prompt. |
| Realtime subscription doesn't fire | Check that the migration added the table to the realtime publication (and set `REPLICA IDENTITY FULL` if you need old rows). If not, write a fix migration prompt. |
| Lovable's work landed on a `lovable-sync` branch | Your push diverged from Lovable's while it was editing. Review that branch, run the same verify steps against it, then merge. Don't push to the synced branch while an LV turn is running. |
| The script missed a Lovable commit | Check `git log --format='%an %ae'` for its author and set `LOVABLE_AUTHOR_REGEX`. |

## Skip when

- You haven't pulled new commits from Lovable.
- You're working on pure-frontend work that doesn't touch the backend.
- You're resolving an in-progress checklist that already had verification done in a previous session.
