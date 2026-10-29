# src/contracts/

API boundary types between CC (frontend) and LV (server functions or Supabase edge functions).

## The rule

Every backend endpoint (server function, server route or edge function) exposes a request and a response type. Those types live here. They are the **only** source of truth for the shape.

- CC imports via `@/contracts/<name>` (path alias).
- **TanStack Start:** LV's server functions import them too (`import type { … } from "@/contracts/<name>"`). LV prompts reference the file and quote only changed types.
- **Vite + Edge Functions:** LV cannot import them (Deno isolation). When CC writes an LV prompt, the contract types are PASTED VERBATIM into the prompt under `## Contract Types`.
- If LV needs the shape to change, LV flags it in the response report — CC updates the contract FIRST, then updates dependent hooks.

## Filename convention

`kebab-case.ts` matching the endpoint name (the `*.functions.ts` file or the edge function).

| Edge function | Contract file |
|---------------|---------------|
| `generate-foo` | `generate-foo.ts` |
| `import-bar` | `import-bar.ts` |
| `analyze-baz` | `analyze-baz.ts` |

## What each contract file exports

1. **Request type** — `interface FooRequest`.
2. **Response type** — `interface FooResponse` OR `type FooResponse = FooSuccess | FooError` for user-visible failures.
3. **Type guards** when using a discriminated union — `isFooSuccess`, `isFooError`.
4. **Constants the frontend needs** — `FOO_CREDITS`, `FOO_TIMEOUT_MS`, etc.

## Example (simple)

```typescript
// generate-foo.ts
export interface GenerateFooRequest {
  topic: string;
  count: number;
}

export interface GenerateFooResponse {
  foos: Array<{ id: string; title: string }>;
}

export const GENERATE_FOO_CREDITS = 2;
export const GENERATE_FOO_TIMEOUT_MS = 30_000;
```

## Example (discriminated union for user-visible failures)

```typescript
// generate-foo.ts
export interface GenerateFooRequest {
  topic: string;
  count: number;
  idempotencyKey: string;
}

export type GenerateFooResponse = GenerateFooSuccess | GenerateFooError;

export interface GenerateFooSuccess {
  success: true;
  foos: Array<{ id: string; title: string }>;
  creditsRemaining: number;
}

export interface GenerateFooError {
  success: false;
  code:
    | 'insufficient_credits'
    | 'invalid_topic'
    | 'ai_timeout'
    | 'internal_error';
  message: string;
}

export const isGenerateFooSuccess = (
  r: GenerateFooResponse
): r is GenerateFooSuccess => r.success === true;

export const isGenerateFooError = (
  r: GenerateFooResponse
): r is GenerateFooError => r.success === false;

export const GENERATE_FOO_CREDITS = 2;
export const GENERATE_FOO_TIMEOUT_MS = 30_000;
```

## Inventory

Update this table when adding/removing contracts.

| Contract file | Edge function | Credit cost | Status |
|---------------|---------------|-------------|--------|
| (none yet) | — | — | — |

## Anti-patterns

- ❌ Inlining the type in a hook file (`src/hooks/useFoo.ts`). Always import from `@/contracts/`.
- ❌ Duplicating the same shape across two contract files. If two endpoints share a shape, extract to `src/contracts/shared/`.
- ❌ Leaving a contract file un-imported (orphan). Either wire a consumer or delete.
- ❌ Changing a contract after LV ships, without updating LV via a follow-up prompt.

## Workflow

1. CC uses the `contract-writer` skill to author/update a contract.
2. CC commits the contract before writing the LV prompt.
3. The contract is pushed; the LV prompt references it (TanStack Start) or pastes it verbatim (Edge Functions).
4. LV implements to match.
5. If LV needs the shape to change, LV flags in the response — CC updates the contract first.

## Skills that reference this directory

- `contract-writer` — author/update a contract.
- `lv-prompt-writer` — reference or paste the contract in the LV prompt.
- `lv-response-reader` — reconcile contract shape after LV ships.
