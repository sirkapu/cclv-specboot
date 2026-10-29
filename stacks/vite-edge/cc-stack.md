## Tech stack — React + Vite with Supabase Edge Functions

Lovable projects created before 2026-05-13.

- **Frontend:** React 18+ + TypeScript strict + Vite + Tailwind CSS + shadcn/ui primitives.
- **Backend (LV's lane):** Supabase (Postgres + Edge Functions in Deno + Auth + Storage + Realtime), or Lovable Cloud on the same model.
- **State:** React Context + TanStack React Query.
- **Forms:** react-hook-form + zod.
- **Routing:** React Router DOM.

TBD items (fill before Phase 1 features):
- Testing framework — TBD.
- Deploy target — TBD.
- AI provider (if applicable) — TBD.

## Key paths

```
src/
├── components/        ← Design system + product components (CC owns)
│   └── ui/            ← shadcn primitives (LV scaffolded)
├── pages/             ← Routes (CC owns, except Auth/ which LV owns)
├── contracts/         ← API boundary types (CC owns)
├── contexts/          ← Except AuthContext which LV owns
├── hooks/             ← Except useAuth/useSession which LV owns
├── lib/               ← Sanitization, exporters, validators
└── styles/
supabase/              ← Edge functions + migrations (LV)
```

## How LV consumes contracts

Edge functions run in Deno and cannot import `src/contracts/`. When you write an LV prompt, **paste the contract types verbatim** under `## Contract Types`.
