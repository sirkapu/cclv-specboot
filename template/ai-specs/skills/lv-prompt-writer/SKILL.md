---
name: lv-prompt-writer
description: Use when CC needs to write a Lovable (LV) prompt for backend work — new edge function, new migration, RLS change, secrets setup, schema migration. Triggers when CC says "write an LV prompt", "ship X to backend", "need an edge function for", "Lovable needs to", or detects that a planned slice requires a backend deliverable.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# lv-prompt-writer

## When to use

CC needs to delegate backend work to Lovable. Use this skill BEFORE writing the prompt — it walks you through the prerequisites and enforces the correct template.

## Procedure

### Step 1 — Confirm the work is in LV's lane

LV owns: edge functions, migrations, RLS, auth pages, Supabase client wiring, build config.
LV does NOT own: components (except `ui/`), contracts, hooks (except auth), styles, control-center.

If the work touches CC-owned files, do it yourself. If hybrid (e.g. new edge function + new hook to call it), split into two phases: LV ships backend; you wire the hook after.

### Step 2 — Update the contract FIRST

If the new edge function returns or accepts user-facing data:

1. Open or create `src/contracts/<edge-function-name>.ts`.
2. Define `Request` and `Response` types.
3. If failure modes are user-visible, define a discriminated union with `success: true | false`.
4. Export type guards: `isFooSuccess(payload)`, `isFooError(payload)`.
5. Export constants: `FOO_CREDITS`, `FOO_TIMEOUT_MS`, etc.
6. Commit the contract file BEFORE writing the prompt.

### Step 3 — Use the template

````markdown
# LV-[NAME]: [one-line title]

## Context
What exists today. What this builds on. Link to relevant files.

## Scope
Numbered list of exact deliverables.

## Contract Types
```typescript
// PASTE FROM src/contracts/[name].ts VERBATIM
```

## Implementation Details
- Table names, column types.
- Edge function name (kebab-case-verb-noun).
- Auth model (RLS policy, impersonation if applicable).
- Idempotency key strategy.
- Credit cost + when charged (check before, deduct after success).
- Error codes + user-facing messages.
- Secrets required (e.g. `OPENAI_API_KEY` — Sir sets in Supabase before deploy).

## Rules
- CORS on ALL responses.
- Use `_shared/` utilities.
- Credits via `add_credits` RPC only.
- Idempotency keys on mutations.
- `REPLICA IDENTITY FULL` + realtime publication on realtime tables.
- Migration filename: `YYYYMMDDHHMMSS_descriptive_snake_case.sql`.

## Do Not Modify (CC-owned)
Read `OWNERSHIP.md`. Specifically: `src/components/**` (except `ui/`), `src/pages/**` (except `Auth/`), `src/contracts/**`, `src/hooks/**` (except `useAuth`), `src/styles/**`, `CLAUDE.md`, `OWNERSHIP.md`, `AGENTS.md`, `control-center/**` (except writing into `lv-responses/` and `lv-blockers/`), `scripts/**`.

## Response Report (MANDATORY)
Write `control-center/lv-responses/LV-[NAME]-response.md` per AGENTS.md "Response report" section.

## Testing Checklist
- [ ] Specific test 1
- [ ] Specific test 2
````

### Step 4 — Save the prompt

Save to `control-center/lv-prompts/LV-[NAME].md`. Tell Sir: "Paste this into Lovable when ready."

### Step 5 — Wait

Do not start frontend work that depends on the new edge function until LV's response is in `control-center/lv-responses/`. If you need to start in parallel, mock the contract response — but flag it loudly in your `build-state.md` entry so the mock gets removed when the real endpoint is live.

## Checklist (tick before sending the prompt to Sir)

- [ ] Work is in LV's lane (or hybrid is split into phases).
- [ ] Contract file in `src/contracts/` is updated/created and committed.
- [ ] Contract types are pasted into the prompt verbatim.
- [ ] Implementation Details lists every secret needed.
- [ ] "Do Not Modify" section is explicit.
- [ ] Testing Checklist has concrete cases (not "test it works").
- [ ] Prompt saved to `control-center/lv-prompts/LV-[NAME].md`.

## Common failure modes

| Symptom | Fix |
|---------|-----|
| LV ships an endpoint with a different shape than the contract | The contract wasn't pasted verbatim. Re-paste, write a follow-up prompt to align. |
| LV asks "what should the table name be?" | You skipped Implementation Details. Be explicit. |
| LV silently changed the shape mid-implementation | LV's response report should have flagged. If not, treat as lane crossing — write a hotfix prompt. |
| You discover mid-build that the contract is wrong | Update the contract file first, then write a follow-up LV prompt. Never just patch the frontend to match what LV shipped. |
