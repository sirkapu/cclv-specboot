---
name: frontend-standards
description: CC-specific frontend development standards. Read after base.md.
applies_to: [CC]
---

# Frontend Standards

CC's deep reference for React + Vite + TypeScript + Tailwind + shadcn frontend work. Read `base.md` first.

## 1. React patterns

- **Functional components only.** No class components.
- **One component per file.** Component name matches filename (`Button.tsx` exports `Button`).
- **`forwardRef` + CVA + `cn()`** for design-system primitives. Look at `src/components/ui/` for the pattern.
- **`memo` sparingly.** Only when profiling shows a real win.
- **Always destructure props** in the function signature. No `props.foo`.

## 2. State management

| State type | Tool | Where it lives |
|------------|------|----------------|
| Server state (queries, mutations) | TanStack React Query | `src/hooks/use<Resource>.ts` |
| Cross-page UI state | React Context | `src/contexts/<Domain>Context.tsx` |
| Component-local state | `useState` / `useReducer` | Inline in the component |
| Form state | `react-hook-form` | Inline in the form component |
| Persisted state | `localStorage` via versioned schema | See `STORAGE_VERSION` pattern |

**Rule of thumb:** If two non-parent-child components need the same data, lift to Context. If it's server-derived, use React Query and let cache invalidation handle sharing.

## 3. TanStack React Query

- Query keys: `[resource, ...filters]`. Example: `['products', userId, status]`.
- Invalidate on mutation success: `queryClient.invalidateQueries({ queryKey: ['products'] })`.
- Use `staleTime: 30_000` minimum for anything that doesn't change instantly.
- Use Realtime subscriptions to trigger `invalidateQueries` — don't poll.

## 4. Tailwind

- Utility-first. No custom CSS unless adding a design token.
- Tokens live in `src/styles/tokens.css` (CSS custom properties).
- Use `@apply` only in `src/styles/components.css` for reusable component classes (e.g. `.btn-primary`).
- No inline `style={}` for color/spacing — use Tailwind. Inline `style` is only for computed values (dynamic positioning, etc.).

## 5. Forms

- `react-hook-form` + `zod` schema for validation.
- Schema lives next to the form: `EditProfileForm.tsx` + `editProfileSchema.ts`.
- Show inline field errors below each input. Never modals.
- Disable submit button when `formState.isSubmitting`.
- After mutation success: toast confirmation + redirect or close.

## 6. Routing

- React Router DOM v6.
- Top-level layout in `src/App.tsx`.
- Page components in `src/pages/<Domain>/<PageName>.tsx`.
- Lazy-load page components via `React.lazy` + `Suspense` for any page over ~200 lines.

## 7. Imports

- Path alias `@/` maps to `src/`. Use it for all in-app imports.
- Order: external packages → `@/...` modules → relative imports → CSS imports.
- One import line per package. Group named imports by length.

## 8. Error handling

- Wrap each route in an Error Boundary (`src/components/ErrorBoundary.tsx`).
- API calls in try/catch. On error: log to console (English), toast user-facing message (in `PRIMARY_LANGUAGE`).
- Never silently swallow errors. Either handle them or rethrow.

## 9. Loading states

- Three-tier loading:
  - **0–500ms:** no UI change (avoid flicker).
  - **500ms–2s:** skeleton.
  - **2s+:** progress indicator with messaging.
- Use `<Suspense fallback={<Skeleton />}>` for code-split pages.
- For long AI operations, show a real progress indicator (counter, animation), not a generic spinner.

## 10. Toasts

- Sonner (`sonner` package), NOT shadcn's `useToast`.
- One toast per user action max. Don't stack.
- Toast text in `PRIMARY_LANGUAGE`. Console logs in English.

## 11. Component file structure (≤ 300 lines)

```tsx
// 1. Imports
import { ... } from 'react';
import { ... } from '@/contracts/foo';

// 2. Types
interface Props { ... }

// 3. Component
export function ComponentName({ ... }: Props) {
  // 3a. Hooks (in stable order: useState, useEffect, custom hooks, queries)
  // 3b. Derived values
  // 3c. Event handlers
  // 3d. Early returns (loading, error, empty)
  // 3e. Main return
}

// 4. Sub-components (only if private to this file; otherwise split)
```

## 12. Portal & Chrome Translate safety

When the project declares portal safety needed (see CLAUDE.md `Non-negotiable architectural rules`):

- `translate="no"` on every root container and on any region that renders dynamic text.
- Apply on `<body>`, on the root `<App>` wrapper, and on any component rendering user data or AI output.
- If using Radix portal components (Dialog, Popover, etc.), set `translate="no"` on BOTH the trigger and the portal content.

## 13. Imports from contracts

```tsx
import type { FooRequest, FooResponse } from '@/contracts/foo';
import { isFooSuccess, FOO_CREDITS } from '@/contracts/foo';
```

Never inline an API shape. Never duplicate a contract type in a hook file.

## 14. Hooks layer

- One concern per hook. `useProducts` returns products; `useCreateProduct` returns the mutation.
- Custom hooks live in `src/hooks/` (except auth hooks which LV owns).
- Hooks ≤ 300 lines. Split if a hook is doing too much.

## 15. Styles tokens

CSS custom properties in `src/styles/tokens.css`:

```css
:root {
  --color-primary: ...;
  --color-bg: ...;
  --space-1: 4px;
  ...
}
```

Use via Tailwind's arbitrary-value syntax: `bg-[var(--color-primary)]` or via configured Tailwind theme tokens.
