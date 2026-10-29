## Your lane (React + Vite with Supabase Edge Functions)

You own the Supabase backend and auth-coupled frontend:

- `supabase/functions/**` (edge functions, Deno/TypeScript) and `supabase/migrations/**` (SQL + RLS).
- `src/components/ui/**` (shadcn primitives), `src/pages/Auth/**`, `src/contexts/AuthContext.tsx`, `src/hooks/useAuth*`, `src/hooks/useSession*`, `src/integrations/supabase/**`.
- Build config: `vite.config.ts`, `tsconfig*.json`, `tailwind.config.ts`, `postcss.config.js`, `index.html`, `components.json`.

CC owns `src/components/**` (except `ui/`), `src/pages/**` (except `Auth/`), `src/contracts/**`, other hooks and contexts, `src/styles/**`, `src/lib/**`, `control-center/**` (except `lv-responses/` and `lv-blockers/`), `docs/`, `ai-specs/`, `scripts/`, `CLAUDE.md`, `OWNERSHIP.md`, and the `CCLV` block of `AGENTS.md`. `OWNERSHIP.md` is the full matrix; the most specific row wins.

## Contracts

API types live in `src/contracts/`. Edge functions can't import them (Deno isolation), so CC's prompt pastes them verbatim under `## Contract Types`. Honor them exactly: field names, optional flags, union shapes. If you need a different shape, say so loudly in your reply so CC changes the contract first.

## Backend rules

1. CORS on ALL responses (success, error, OPTIONS), via `supabase/functions/_shared/cors.ts`.
2. Credits via the `add_credits` RPC only (check before, deduct after success). Idempotency keys on every mutating endpoint.
3. RLS on every user-data table, default deny. New tables need explicit grants and RLS policies in the same migration.
4. Realtime tables: `REPLICA IDENTITY FULL` + add them to the realtime publication in the migration.
5. Edge functions stay focused: one responsibility, shared code in `_shared/`. Name them `kebab-case-verb-noun`.
6. Migrations are append-only, named `YYYYMMDDHHMMSS_descriptive_snake_case.sql` (UTC).
7. Secrets are read with `Deno.env.get()`; never hardcoded.
