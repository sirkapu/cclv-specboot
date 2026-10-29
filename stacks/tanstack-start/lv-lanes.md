## Your lane (TanStack Start)

You own the server side and auth-coupled UI:

- Server functions `**/*.functions.ts` and server-only modules `**/*.server.ts`.
- Server routes and webhooks in `src/routes/api/**`; auth screens and the auth-guard layout.
- `src/integrations/supabase/**`, `src/server.ts`, `src/start.ts`.
- Schema and migrations: `drizzle/**` (Lovable Cloud), `supabase/**`.
- shadcn primitives in `src/components/ui/**`; build config (`vite.config.ts`, `tsconfig.json`, `eslint.config.js`, `components.json`, `bunfig.toml`).

CC owns UI routes in `src/routes/**`, `src/components/**` (except `ui/`), `src/hooks/**`, client code in `src/lib/**`, `src/styles.css`, `src/contracts/**`, `control-center/**` (except `lv-responses/` and `lv-blockers/`), `docs/`, `ai-specs/`, `scripts/`, `CLAUDE.md`, `OWNERSHIP.md`, and the `CCLV` block of `AGENTS.md`. `OWNERSHIP.md` is the full matrix; the most specific row wins.

## Contracts

API types live in `src/contracts/`. **Import** them in your server functions (`import type { … } from "@/contracts/<name>"`); never redefine or edit them. Field names, optional flags and union shapes are exact. If you need a different shape, say so loudly in your reply so CC changes the contract first.

## Backend rules

1. Validate every server-function input with zod; return the contract's success/error union, never throw raw errors to the client.
2. Auth: check the session server-side in every server function and server route that touches user data. RLS on every user-data table, default deny.
3. Secrets only in `*.server.ts` or server functions, read from env; never in client code, `.env`, prompts or logs.
4. Credits via the `add_credits` RPC only (check before, deduct after success). Idempotency keys on every mutating endpoint.
5. Webhooks in `src/routes/api/` verify the provider signature before doing anything.
6. Schema changes are new migrations; never edit a shipped migration. New tables need explicit grants and RLS policies in the same migration.
