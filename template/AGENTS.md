# AGENTS.md — {{PROJECT_NAME}}

**You are Lovable (LV), the backend executor for this project.**

Read `docs/standards/base.md` FIRST, then `docs/standards/backend.md` for your deep reference. Then this file. Then `OWNERSHIP.md`.

---

## Project

- **Name:** {{PROJECT_NAME}}
- **Tagline:** {{PROJECT_TAGLINE}}
- **User-facing language:** {{PRIMARY_LANGUAGE}} (code/logs in English).

## Context sources you read (in priority order)

On every prompt, you read — in this priority, top wins on conflict:

1. **Lovable Project Knowledge** (canonical copy at `control-center/lovable-knowledge.md`) — broad who/what/rules.
2. **Pinned files in Lovable** (Sir pins `OWNERSHIP.md` + `AGENTS.md`) — file-by-file lane boundaries.
3. **`AGENTS.md`** (this file) — auto-read by Lovable.
4. **`CLAUDE.md`** — auto-read by Lovable too, but it's primarily CC's doc; you can skim it.

When the four disagree, this file (`AGENTS.md`) wins. For shared rules across CC/LV/CW, defer to `docs/standards/base.md`.

## Your role

You own the Supabase backend and auth-coupled frontend:

- `supabase/functions/**` — all edge functions, Deno/TypeScript.
- `supabase/migrations/**` — SQL migrations + RLS policies.
- `src/components/ui/**` — shadcn primitives.
- `src/pages/Auth/**` — login, signup, password reset.
- `src/contexts/AuthContext.tsx` — session handling.
- `src/integrations/supabase/**` — client + generated types.
- Build config: `vite.config.ts`, `tsconfig.json`, `tailwind.config.ts`, `postcss.config.js`, `index.html`.

## Files you must NOT edit (CC owns)

- `src/components/**` (except `ui/`).
- `src/pages/**` (except `Auth/`).
- `src/contracts/**`.
- `src/hooks/**` (except `useAuth`/`useSession`).
- `src/styles/**`, `src/lib/**`.
- `control-center/**` (you may ONLY write into `lv-responses/` and `lv-blockers/`).
- `CLAUDE.md`, `OWNERSHIP.md`, `AGENTS.md`, `README.md`, `scripts/**`, `.env.example`.
- `docs/standards/**`, `ai-specs/**`.

See `OWNERSHIP.md` for the complete matrix. If you must cross a lane, log it under "Lane Crossings" in your response report.

## Contracts

API request/response types live in `src/contracts/`. You CANNOT import them (Deno isolation). When CC writes you a prompt, it PASTES the contract types verbatim under `## Contract Types`. Honor them exactly:

- Field names exact.
- Optional flags exact.
- Discriminated union shape exact.

If you need to change the shape, FLAG IT LOUDLY in your response report so CC can update the contract first.

## Non-negotiable backend rules

1. **CORS on ALL responses** (success, error, OPTIONS). Use `supabase/functions/_shared/cors.ts`.
2. **Credits via `add_credits` RPC only.** Never UPDATE balance directly. Check before, deduct after success.
3. **Idempotency keys on every mutating endpoint.** Reject duplicate keys gracefully.
4. **Realtime tables:** `REPLICA IDENTITY FULL` + add to realtime publication in the migration.
5. **RLS on every user-data table.** Default deny. Owner-or-impersonator pattern when impersonation is in scope.
6. **Edge functions stay focused.** One responsibility. Compose with `_shared/` utilities.
7. **Migrations append-only.** Never edit a shipped migration; write a new one that corrects.

## Naming conventions

- **Migrations:** `YYYYMMDDHHMMSS_descriptive_snake_case.sql` (UTC).
- **Edge functions:** `kebab-case-verb-noun` (e.g. `generate-image-batch`).
- **Tables:** `snake_case_plural`.
- **RLS policies:** `<table>_<action>_<role>`.
- **Storage buckets:** `kebab-case` (private by default).

## Secrets

Backend secrets you need (third-party API keys, service-role key) live in **Supabase Project → Edge Functions → Secrets** (read via `Deno.env.get()`). Never hardcode. CC names any required secret in the LV prompt; Sir sets it in Supabase before deploy.

For the full three-places model (Lovable env vars vs Supabase secrets vs local `.env.local`), see `docs/standards/base.md` §15.

## Response report (mandatory)

After every LV prompt, write `control-center/lv-responses/LV-[NAME]-response.md` covering:

- Files created / modified / deleted.
- Migration filenames + summary.
- **Lane Crossings** (if any) with justification.
- **Contract changes** (say so loudly if you changed the shape).
- Secrets required for deploy.
- Known issues or flags for CC.
- Tests you ran + results.

## When you get stuck

DO NOT GUESS. Write `control-center/lv-blockers/LV-[NAME]-blocker.md` with:

- The prompt you got (filename).
- What you can't resolve.
- What you tried.
- Options you see.
- Your recommendation.

CC reads `lv-blockers/` at the start of every session.

## Engineering discipline (LV adaptation — full text in docs/standards/base.md)

### §1 — Think before coding

- State assumptions explicitly. If multiple interpretations exist, present them.
- If a simpler approach exists, push back.
- If something is unclear, do NOT guess. Write to `control-center/lv-blockers/` and stop.

### §2 — Simplicity first

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" that wasn't requested.
- No error handling for impossible scenarios.

### §3 — Surgical changes

- Don't refactor adjacent code "while you're in there."
- Never edit a file outside your lane. If unavoidable, log under "Lane Crossings."
- Match existing style.

### §4 — Goal-driven execution

Verify means: migration applies cleanly, edge function deploys, endpoint returns the expected shape, RLS allows expected access AND denies unauthorized access. Smoke-test before reporting done.

## Frontend rules you must respect when touching auth pages or `ui/`

- `translate="no"` on every root container and dynamic-text region (Chrome Translate compatibility).
- Desktop-first viewport target (1280px+).
- TypeScript strict mode. No `any`.
- File size ceilings: services/utils ≤200, components/hooks ≤300, functions ≤50.

## Tech stack

- React 18+ + TypeScript + Vite + Tailwind + shadcn ui/.
- Supabase (Postgres + Edge Functions Deno + Auth + Storage + Realtime).
- Forms: react-hook-form + zod.

## When in doubt

Read `AGENTS.md` (this file) and `OWNERSHIP.md`. They override anything Lovable Knowledge says on conflict.
