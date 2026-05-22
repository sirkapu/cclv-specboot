---
name: lv-response-reader
description: Use when CC opens a fresh `LV-[NAME]-response.md` to triage what LV shipped. Triggers when CC says "read LV's response", "process LV's report", or after `git pull` introduces new files in `control-center/lv-responses/`.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# lv-response-reader

## When to use

After LV ships work and you've pulled the new branch. Use BEFORE you wire frontend against the new endpoint.

This skill is paired with `verify-after-pull` — that one verifies the code; this one processes the report.

## Procedure

### Step 1 — Open the file

`control-center/lv-responses/LV-[NAME]-response.md`

### Step 2 — Read top-to-bottom; flag each section

| Section | What to do |
|---------|------------|
| Files created/modified/deleted | Cross-check against the LV prompt's scope. Anything unexpected is a yellow flag. |
| **Lane Crossings** | Open EACH file LV crossed into. Decide: legit (real bug LV noticed) or scope creep. Legit → re-implement cleanly in CC layer; revert LV's edit. Scope creep → revert. Log in `build-state.md`. |
| Migration filenames + summary | Confirm filenames match `YYYYMMDDHHMMSS_*.sql` pattern. Open each migration and read it. |
| **Contract changes** | If LV changed the shape — update `src/contracts/<name>.ts` to match (or push back if shape is worse). Commit the contract update before doing anything else. |
| Secrets required for deploy | Ping Sir if any aren't set in Supabase yet. |
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
| Missing secret | Tell Sir what to set in Supabase. Don't try the endpoint until set. |
| Known issue flagged | Open the issue in your task list. Decide if it blocks the current slice. |
| Tests failing | Block. Write `LV-[NAME]-fix.md`. |

### Step 4 — Smoke-test before wiring

Even if LV says "tests passed", run the flow yourself:

1. `npm run dev`.
2. Exercise the user flow that hits the new endpoint.
3. DevTools → Network: confirm status code, response shape, timing.
4. DevTools → Console: no errors.

### Step 5 — Update build-state.md

Append session entry. Cover what LV shipped + what you wired (or will wire) + open follow-ups.

### Step 6 — Archive the prompt + response (optional)

If LV's prompt is fully shipped and verified, you can move `LV-[NAME].md` and `LV-[NAME]-response.md` to `control-center/lv-prompts/archive/` and `control-center/lv-responses/archive/`. Keeps the active directories scannable.

## Anti-patterns

- ❌ Assuming "tests passed" means the flow works end-to-end. Run it yourself.
- ❌ Wiring the frontend before reading the response in full.
- ❌ Silently accepting a contract shape change. Always document.
- ❌ Skipping the `Lane Crossings` audit. That's where lane drift gets cemented.

## Checklist

- [ ] Read every section of the response.
- [ ] Lane crossings audited (each diff reviewed).
- [ ] Contract changes reconciled in `src/contracts/`.
- [ ] Secrets confirmed set in Supabase.
- [ ] Smoke test passed.
- [ ] `build-state.md` entry written.
