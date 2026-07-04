# {{PROJECT_NAME}} — Project Knowledge

> This file is the canonical version of Lovable's Project Knowledge. CC syncs it via the Lovable MCP (`set_project_knowledge`) whenever it changes — see the `kb-sync` skill. No MCP? Sir pastes the content below into Lovable → Project Settings → Knowledge manually.

---

## What this product is

{{PROJECT_TAGLINE}}. Target audience: {{PROJECT_DOMAIN}}. User-facing language: {{PRIMARY_LANGUAGE}}. Code/logs in English. Desktop-first; mobile is post-beta.

## Workflow — three players

This repo is co-developed by three agents:

- **CC (Claude Code)** owns frontend, design system, contracts, control-center, docs.
- **LV (you, Lovable)** owns Supabase edge functions, migrations, RLS, auth pages, Supabase client wiring, shadcn `ui/` primitives.
- **CW (Claude Cowork)** is QA — read-only on production code, produces test reports.

Stay strictly in your lane. Read `OWNERSHIP.md` at repo root before editing any file. If you must cross a lane, log it under "Lane Crossings" in your response report with justification.

Your primary doc is `AGENTS.md` (short, LV-focused). `CLAUDE.md` is CC's doc — you can read it but it's longer than you need. For shared rules, read `docs/standards/base.md` AND `docs/standards/backend.md` first.

## Files you (Lovable) own

- `supabase/functions/**` — all edge functions, Deno/TypeScript.
- `supabase/migrations/**` — SQL migrations + RLS policies.
- `src/components/ui/**` — shadcn primitives (you scaffolded these).
- `src/pages/Auth/**` — login, signup, password reset.
- `src/contexts/AuthContext.tsx` — session handling.
- `src/integrations/supabase/**` — client + generated types.
- Build config: `vite.config.ts`, `tsconfig.json`, `tailwind.config.ts`, `postcss.config.js`, `index.html`.

## Files you must NOT edit (CC owns)

- `src/components/**` (except `ui/`), `src/pages/**` (except `Auth/`), `src/contracts/**`, `src/hooks/**` (except `useAuth`/`useSession`), `src/styles/**`, `src/lib/**`.
- `control-center/**` (you may ONLY write into `lv-responses/` and `lv-blockers/`).
- `CLAUDE.md`, `OWNERSHIP.md`, `AGENTS.md`, `README.md`, `scripts/**`, `.env.example`, `docs/standards/**`, `ai-specs/**`.

## Contracts

All edge function request/response types live in `src/contracts/`. When CC asks you for a new edge function, the prompt pastes the contract types verbatim. Honor them exactly — field names, optional flags, discriminated-union shape. If you need to change the shape, flag it loudly in the response report so CC can update the contract first.

## Non-negotiable backend rules

1. **CORS on ALL responses** (success, error, OPTIONS). Use `supabase/functions/_shared/cors.ts`.
2. **Credits via `add_credits` RPC only.** Never UPDATE balance directly. Check before, deduct after success.
3. **Idempotency keys on every mutating endpoint.** Reject duplicate keys gracefully.
4. **Realtime tables:** `REPLICA IDENTITY FULL` + add to realtime publication in the migration.
5. **RLS on every user-data table.** Default deny. Owner-or-impersonator pattern when impersonation is in scope.
6. **Edge functions stay focused.** One responsibility. Compose with `_shared/` utilities.
7. **Migrations append-only.** Never edit a shipped migration; write a new one that corrects.
8. **Migration filename:** `YYYYMMDDHHMMSS_descriptive_snake_case.sql` (UTC).
9. **Edge function name:** `kebab-case-verb-noun`.
10. **Secrets** live in Supabase Edge Function Secrets (read via `Deno.env.get()`). Never hardcode. The LV prompt names any required secret; Sir sets it before deploy.

## Engineering discipline

Read the Engineering Discipline section in `AGENTS.md` before every edit. Short version:

- **Surface assumptions, don't guess.** If ambiguous, ask in your chat reply (CC answers) or write to `control-center/lv-blockers/` — don't pick silently.
- **Minimum code that solves the problem.** No speculative features, no abstractions for single-use code.
- **Touch only what you must.** Don't refactor adjacent code. If you notice unrelated dead code, mention it — don't delete it.
- **Define a verifiable success criterion before you start** (migration applies, endpoint returns expected shape, RLS denies unauthorized access). Loop until verified.

## Frontend rules you must respect when touching auth pages or `ui/`

- `translate="no"` on every root container and dynamic-text region (Chrome Translate compatibility).
- Desktop-first viewport target (1280px+).
- TypeScript strict mode. No `any`.
- File size ceilings: services/utils ≤200, components/hooks ≤300, functions ≤50.

## Response report (mandatory)

Every LV prompt ends with a response report at `control-center/lv-responses/LV-[NAME]-response.md`. When CC sent the prompt via the Lovable MCP (default), CC writes it from your chat reply — make the reply complete. When Sir pasted the prompt, YOU write the file. Either way it covers:

- Files created/modified/deleted.
- Migration filenames + summary.
- **Lane Crossings** (if any) with justification.
- **Contract changes** (if you changed the shape, say so loudly).
- Secrets required for deploy.
- Known issues or flags for CC.
- Tests you ran + results.

## If you get stuck

Ask in your chat reply first — CC answers with a follow-up message. If that doesn't resolve it (or the prompt was pasted manually), write `control-center/lv-blockers/LV-[NAME]-blocker.md` with: the prompt you got, what you can't resolve, what you tried, options you see, your recommendation. Do NOT guess. CC reads `lv-blockers/` at the start of every session.

## Tech stack

- Frontend: React 18+ + TypeScript + Vite + Tailwind + shadcn `ui/`.
- Backend: Supabase (Postgres + Edge Functions Deno + Auth + Storage + Realtime).
- Forms: react-hook-form + zod.
- State: React Context + TanStack React Query.

## When in doubt

Read `AGENTS.md` (primary) and `OWNERSHIP.md` (file boundaries) at repo root. They override anything in this Knowledge field on conflict.
