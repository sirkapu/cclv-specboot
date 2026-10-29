# LV-[NAME]: [One-line title]

> Save this file as `control-center/lv-prompts/LV-[NAME].md` (replace `[NAME]` with a short kebab-case slug, e.g. `auth-credits-foundations`). Your standing rules and lane list are already in your Project Instructions and `OWNERSHIP.md`; this prompt only adds what's specific to this slice.

## Context

What exists today. What this builds on. Link to relevant files. 2-3 sentences max.

<!-- With Spec Kit: link the feature and list the LV task IDs this prompt covers.
Spec: specs/NNN-<feature>/spec.md · Plan: specs/NNN-<feature>/plan.md
Tasks: T003, T004, T005 (paste the task lines) -->

## Scope

Exact deliverables as a numbered list. No ambiguity.

1. New server function `<name>` in `src/lib/<name>.functions.ts` (TanStack Start) — or new edge function `<name>` (Vite + Edge Functions).
2. New table `public.<name>` with columns (...), explicit grants, RLS policies.
3. Realtime publication (if frontend subscribes).
4. Regenerated Supabase types.

## Contract Types

<!-- TanStack Start: keep this paragraph. -->
Import from `@/contracts/<name>` (file: `src/contracts/<name>.ts`, already pushed). This slice adds/changes:

```typescript
// Quote only the new or changed types. Don't redefine them in your code.
```

<!-- Vite + Edge Functions: replace the paragraph above with the full contract, verbatim.
```typescript
// PASTE FROM src/contracts/<name>.ts VERBATIM — do not summarize, do not paraphrase.
```
-->

## Implementation Details

- **Table schema:** column names + types + constraints.
- **Endpoint name:** server function `camelCaseVerbNoun` / edge function `kebab-case-verb-noun`.
- **Auth model:** session check + RLS policy details. Impersonation if applicable.
- **Idempotency:** key strategy + storage approach.
- **Credit cost:** value + when charged (check before, deduct after success).
- **Error codes + user-facing messages:** map each code to a message.
- **Secrets required:** name each one. Ask for them through Lovable's secure secret input; Sir enters the values.
- **Realtime:** which tables, which channels.

## Slice-specific rules

- (Only rules beyond your Project Instructions — e.g. "reuse `src/lib/credits.server.ts`", "don't touch the existing `orders` RLS".)

## Reply

<!-- MCP mode (default) — keep this line: -->
Cover every item of the "Reply checklist" in your Project Instructions; CC writes the response report from your reply and the diff.

<!-- Paste mode — use this line instead: -->
<!-- Cover the "Reply checklist" AND write it to `control-center/lv-responses/LV-[NAME]-response.md` (use the TEMPLATE.md there). -->

If anything is unclear, ask in your reply and stop before building.

## Testing Checklist

- [ ] Migration applies cleanly to a fresh DB.
- [ ] Endpoint returns the contract shape for valid input.
- [ ] Endpoint returns the contract's error variant for invalid input.
- [ ] Access rules deny other users' data (RLS + session check).
- [ ] Idempotency key collision returns the cached response.
- [ ] Credit deduction is logged in `credits_ledger`.
- [ ] Realtime subscription fires on INSERT (if applicable).
