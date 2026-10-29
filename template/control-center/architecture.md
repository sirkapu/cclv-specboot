# Architecture — {{PROJECT_NAME}}

Stable architecture reference. Update when routes, data models, contracts, or backend endpoints change.

**Last updated:** {{TODAY}}

---

## Routes

| Path | Component | Purpose |
|------|-----------|---------|
| `/` | `src/routes/index.tsx` (or `src/pages/Home.tsx` on Vite) | Landing |
| `/auth` | `src/routes/auth.tsx` (or `src/pages/Auth/Login.tsx` on Vite) (LV) | Login / signup |
| `/app` | `src/routes/app.tsx` (or `src/pages/App/index.tsx` on Vite) | Main app |

*(empty rows pending Phase 1 features)*

---

## Data models (Postgres tables)

| Table | Key columns | RLS | Owner |
|-------|-------------|-----|-------|
| `auth.users` | (Supabase managed) | n/a | LV |
| `public.profiles` | `id`, `user_id`, `created_at` | owner-only | LV |
| `public.credits_ledger` | `id`, `user_id`, `amount`, `type`, `feature` | owner-only | LV |

*(grows as LV ships migrations — LV adds rows in its response report; CC merges them here)*

---

## Backend endpoints

| Function | Credit cost | Status |
|----------|-------------|--------|
| (none yet) | — | — |

*(LV adds rows in response reports; CC merges them here)*

---

## Contracts

| Contract file | Endpoint (server function / edge function) | Status |
|---------------|---------------|--------|
| (none yet) | — | — |

*(CC adds rows when defining contracts via the `contract-writer` skill)*

---

## Design system

- Component count: (count files in `src/components/` excluding `ui/`)
- shadcn primitives in `ui/`: (count files in `src/components/ui/`)
- Token file: `src/styles/tokens.css`
- Utility CSS: `src/styles/components.css`

---

## State management

- **Server state:** TanStack React Query (`src/hooks/use<Resource>.ts`).
- **Cross-page UI state:** React Context, or route context/loaders on TanStack Start.
- **Component-local:** `useState` / `useReducer`.
- **Forms:** `react-hook-form` + `zod`.
- **Persisted:** `localStorage` via versioned schema.

---

## Realtime channels

| Channel | Table | Consumer hook |
|---------|-------|---------------|
| (none yet) | — | — |

---

## External integrations

| Integration | Purpose | Secret name |
|-------------|---------|-------------|
| Lovable Cloud (Supabase) | DB + Auth + Storage + Realtime (+ Edge Functions on the Vite stack) | (built-in) |
| (others as added) | — | — |

---

## Key file paths

The `src/` layout depends on the Lovable stack: see "Key paths" in `CLAUDE.md`, and `OWNERSHIP.md` for who owns each path.

```
control-center/           ← CC owns (LV writes only into lv-responses/, lv-blockers/)
docs/                     ← CC owns
ai-specs/                 ← CC owns
scripts/                  ← CC owns
```
