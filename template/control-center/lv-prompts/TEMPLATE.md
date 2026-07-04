# LV-[NAME]: [One-line title]

> Save this file as `control-center/lv-prompts/LV-[NAME].md` (replace `[NAME]` with a short kebab-case slug, e.g. `auth-credits-foundations`).

## Context

What exists today. What this builds on. Link to relevant files. 2-3 sentences max.

## Scope

Exact deliverables as a numbered list. No ambiguity.

1. New edge function `<name>`.
2. New table `public.<name>` with columns (...).
3. RLS policies: owner-only SELECT/INSERT/UPDATE/DELETE.
4. Realtime publication (if frontend subscribes).
5. Update Supabase generated types.

## Contract Types

```typescript
// PASTE FROM src/contracts/<name>.ts VERBATIM
// Do not summarize, do not paraphrase.
```

## Implementation Details

- **Table schema:** column names + types + constraints.
- **Edge function name:** `kebab-case-verb-noun`.
- **Auth model:** RLS policy details. Impersonation if applicable.
- **Idempotency:** key strategy + storage approach.
- **Credit cost:** value + when charged (check before, deduct after success).
- **Error codes + user-facing messages:** map each code to a message.
- **Secrets required:** name each Supabase secret. Sir will set them before deploy.
- **Realtime:** which tables, which channels.

## Rules (non-negotiable)

- CORS on ALL responses including errors and OPTIONS.
- Use `_shared/` utilities (cors, json-parser, credit-utils).
- Credits via `add_credits` RPC only — never UPDATE balance directly.
- Idempotency keys on all mutations.
- `REPLICA IDENTITY FULL` + realtime publication on realtime tables.
- Migration filename: `YYYYMMDDHHMMSS_descriptive_snake_case.sql`.
- One concern per migration.

## Do Not Modify (CC-owned files)

Read `OWNERSHIP.md`. Specifically:
- `src/components/**` (except `ui/`)
- `src/pages/**` (except `Auth/`)
- `src/contracts/**`
- `src/hooks/**` (except `useAuth`/`useSession`)
- `src/styles/**`, `src/lib/**`
- `CLAUDE.md`, `OWNERSHIP.md`, `AGENTS.md`, `docs/standards/**`, `ai-specs/**`
- `control-center/**` (you may ONLY write into `lv-responses/` and `lv-blockers/`)
- `scripts/**`

## Response Report (MANDATORY)

<!-- MCP mode (default) — keep this paragraph: -->
This prompt was sent via the Lovable MCP. In your chat reply, cover every item below — CC distills your reply + diff into `control-center/lv-responses/LV-[NAME]-response.md`.

<!-- Paste mode — use this paragraph instead: -->
<!-- After completing this work, create `control-center/lv-responses/LV-[NAME]-response.md` using the TEMPLATE.md in that directory. Include: -->

- Files created / modified / deleted.
- Migration filenames + summary.
- Lane Crossings (if any) with justification.
- Contract changes (if response shape evolved — say so loudly).
- Secrets required for deploy.
- Known issues or flags for CC.
- Suggested CC follow-up tasks.

## If You Get Stuck

Do NOT guess. Ask in your chat reply first — CC answers with a follow-up message. If that doesn't resolve it (or this prompt was pasted manually), write `control-center/lv-blockers/LV-[NAME]-blocker.md` with: what you can't resolve, what you tried, options you see, your recommendation.

## Testing Checklist

- [ ] Migration applies cleanly to a fresh DB.
- [ ] Edge function deploys without errors.
- [ ] Endpoint returns expected shape for valid input.
- [ ] Endpoint returns correct error code for invalid input.
- [ ] RLS denies access to other users' data.
- [ ] Idempotency key collision returns the cached response.
- [ ] Credit deduction is logged in `credits_ledger`.
- [ ] Realtime subscription fires on INSERT (if applicable).
