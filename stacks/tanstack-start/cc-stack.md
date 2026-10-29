## Tech stack — TanStack Start

Lovable's default for projects created since 2026-05-13.

- **App:** TanStack Start (React 19, SSR) + TypeScript strict + Vite + Tailwind CSS v4 + shadcn/ui primitives.
- **Routing:** file-based in `src/routes/`. `__root.tsx` is the app shell; `routeTree.gen.ts` is generated (never hand-edit). There is no `src/pages/`.
- **Styling:** theme and tokens live in `src/styles.css` (`@theme inline`); there is no `tailwind.config.ts`.
- **Backend (LV's lane):** TanStack server functions (`createServerFn`) in `*.functions.ts`, server-only modules in `*.server.ts`, server routes in `src/routes/api/`. Database is Lovable Cloud (powered by Supabase); schema changes land as Drizzle migrations in `drizzle/migrations/`.
- **Data / forms:** TanStack Query; react-hook-form + zod.
- **Package manager:** bun (`bun.lock`). Tests: vitest (`bun run test`).

TBD items (fill before Phase 1 features):
- Deploy target — TBD.
- AI provider (if applicable) — TBD.

## Key paths

```
src/
├── routes/            ← UI routes (CC), except api/ and auth screens (LV)
├── components/        ← Design system + product components (CC)
│   └── ui/            ← shadcn primitives (LV scaffolded)
├── hooks/             ← Client hooks (CC)
├── lib/               ← Client utils (CC); *.functions.ts / *.server.ts in here are LV's
├── contracts/         ← API boundary types (CC owns, LV imports)
├── integrations/supabase/ ← Supabase clients + auth middleware (LV)
└── styles.css         ← Tailwind v4 theme (CC)
drizzle/               ← Schema + migrations (LV)
```

## How LV consumes contracts

LV's server functions compile with the app and share the `@/` alias, so they **import** contract types directly: `import type { FooRequest, FooResponse } from "@/contracts/foo"`. In LV prompts, reference the contract by path and quote only the types that changed; don't paste whole files.
