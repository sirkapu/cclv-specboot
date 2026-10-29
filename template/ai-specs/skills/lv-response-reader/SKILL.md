---
name: lv-response-reader
description: Use when CC needs to triage what LV shipped — after an MCP `send_message` turn completes, or when a fresh `LV-[NAME]-response.md` lands after a pull (paste mode). Triggers when CC says "read LV's response", "process LV's report", or the LV turn's `response.status` is `completed`.
applies_to: [CC]
author: cclv-specboot
version: 0.3.0
---

# lv-response-reader

## When to use

After LV ships work. Use BEFORE you wire frontend against the new endpoint.

This skill is paired with `verify-after-pull` — that one verifies the code locally after you pull; this one processes LV's response.

## Procedure

### Step 1 — Gather LV's output

**MCP mode (default):**

1. Confirm the turn finished: `response.status` is `completed` (`stopped` or `error`: see CLAUDE.md "Lovable MCP channel"). `get_message`'s top-level status never becomes terminal; pass it the `thread_id` from `send_message`. If it's `awaiting_input`, handle the pause first (CLAUDE.md "Lovable MCP channel"). Don't send a new message over it.
2. Read LV's final reply (from the `send_message` result, or `get_message`).
3. Pull the code diff via `get_diff` (the `message_id` from `send_message`). `list_edits` gives each edit's commit SHA if you need a specific one.
4. Cross-check: every file LV claims in the reply should appear in the diff, and vice versa. If they don't match, ask LV with a new `send_message` before proceeding.
5. Bring the code local: `git pull --ff-only` (or `git pull --rebase` if you committed during LV's turn), then `bash scripts/verify-after-pull.sh` (verify-after-pull skill).
6. **You write the report:** distill reply + diff into `control-center/lv-responses/LV-[NAME]-response.md` (use the TEMPLATE; cover every item of the "Reply checklist" in LV's Project Instructions). Commit it **after** the pull, so your branch doesn't diverge from Lovable's.

**Paste mode:** open `control-center/lv-responses/LV-[NAME]-response.md` — LV wrote it.

### Step 2 — Read the response top-to-bottom; flag each section

| Section | What to do |
|---------|------------|
| Files created/modified/deleted | Cross-check against the LV prompt's scope. Anything unexpected is a yellow flag. |
| **Lane Crossings** | Open EACH file LV crossed into. Decide: legit (real bug LV noticed) or scope creep. Legit → re-implement cleanly in CC layer; revert LV's edit. Scope creep → revert. Log in `build-state.md`. |
| Migration filenames + summary | Open each migration and read it (`drizzle/migrations/` on Lovable Cloud TanStack projects; `supabase/migrations/YYYYMMDDHHMMSS_*.sql` otherwise). New tables need grants + RLS. |
| **Contract changes** | If LV changed the shape — update `src/contracts/<name>.ts` to match (or push back if shape is worse). Commit the contract update before doing anything else. |
| Secrets required for deploy | Ping Sir if any aren't set yet (Lovable editor → Secrets on Lovable Cloud; Supabase dashboard on your own Supabase). |
| Known issues / flags for CC | These are your follow-up todos. Move them into `roadmap.md` or your in-session task list. |
| Tests run + results | If LV ran tests, note any failures. If LV didn't run smoke tests, you must. |
| Suggested CC follow-up tasks | Triage — accept, defer, or reject. |

### Step 3 — Triage decision matrix

| What you found | What you do |
|----------------|-------------|
| Clean response, no surprises | Proceed to wiring (frontend hooks against the new contract). |
| Legitimate lane crossing | Revert LV's cross-lane edit. Re-implement cleanly. Note in `build-state.md`. |
| Scope creep | Revert. Write `LV-[NAME-V2].md` clarifying scope. |
| Contract shape change | Update contract. Re-check existing hooks for type errors. |
| Missing secret | Tell Sir what to set (Lovable editor → Secrets, or Supabase). Don't try the endpoint until set. |
| Known issue flagged | Open the issue in your task list. Decide if it blocks the current slice. |
| Tests failing | Block. Write `LV-[NAME]-fix.md`. |

### Step 4 — Smoke-test before wiring

Even if LV says "tests passed", run the flow yourself after the pull:

1. `npm run dev` (or `bun run dev`).
2. Exercise the user flow that hits the new endpoint.
3. DevTools → Network: confirm status code, response shape, timing.
4. DevTools → Console: no errors.

### Step 5 — Update build-state.md (and Spec Kit tasks)

Append session entry. Cover what LV shipped + what you wired (or will wire) + open follow-ups.

With Spec Kit: tick the LV task IDs `[X]` in `specs/NNN-*/tasks.md` once verify-after-pull passes. LV never edits `specs/`.

### Step 6 — Archive the prompt + response (optional)

If LV's prompt is fully shipped and verified, you can move `LV-[NAME].md` and `LV-[NAME]-response.md` to `control-center/lv-prompts/archive/` and `control-center/lv-responses/archive/`. Keeps the active directories scannable.

## Anti-patterns

- ❌ Assuming "tests passed" means the flow works end-to-end. Run it yourself.
- ❌ Wiring the frontend before reading the response in full.
- ❌ Silently accepting a contract shape change. Always document.
- ❌ Skipping the `Lane Crossings` audit. That's where lane drift gets cemented.

## Checklist

- [ ] MCP mode: turn `completed`, reply + diff cross-checked, pulled, verify-after-pull run, report written to `lv-responses/` and committed.
- [ ] Read every section of the response.
- [ ] Lane crossings audited (each diff reviewed).
- [ ] Contract changes reconciled in `src/contracts/`.
- [ ] Secrets confirmed set (Lovable Secrets or Supabase).
- [ ] Smoke test passed.
- [ ] `build-state.md` entry written.
