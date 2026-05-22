# Architecture — {{PROJECT_NAME}}

Stable architecture reference. Update when routes, data models, contracts, or edge functions change.

**Last updated:** {{TODAY}}

---

## Routes

| Path | Component | Purpose |
|------|-----------|---------|
| `/` | `pages/Home.tsx` | Landing |
| `/auth/login` | `pages/Auth/Login.tsx` (LV) | Login |
| `/auth/signup` | `pages/Auth/Signup.tsx` (LV) | Signup |
| `/app` | `pages/App/index.tsx` | Main app |

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

## Edge functions

| Function | Credit cost | Status |
|----------|-------------|--------|
| (none yet) | — | — |

*(LV adds rows in response reports; CC merges them here)*

---

## Contracts

| Contract file | Edge function | Status |
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
- **Cross-page UI state:** React Context (`src/contexts/<Domain>Context.tsx`).
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
| Supabase | DB + Auth + Storage + Realtime + Edge Functions | (built-in) |
| (others as added) | — | — |

---

## Key file paths

```
src/
├── components/           ← CC owns
│   └── ui/               ← LV scaffolded (shadcn)
├── pages/                ← CC owns (except Auth/ → LV)
├── contracts/            ← CC owns (LV reads)
├── contexts/             ← CC owns (except AuthContext → LV)
├── hooks/                ← CC owns (except useAuth/useSession → LV)
├── lib/
├── styles/
└── integrations/supabase/ ← LV owns (generated types)

supabase/
├── functions/            ← LV owns
└── migrations/           ← LV owns

control-center/           ← CC owns (LV writes only into lv-responses/, lv-blockers/)
docs/                     ← CC owns
ai-specs/                 ← CC owns
scripts/                  ← CC owns
```
