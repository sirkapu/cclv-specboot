---
name: contract-writer
description: Use when CC needs to define or update an API contract in `src/contracts/`. Triggers on "write a contract for", "define the API shape", "update the contract", or before writing any LV prompt that involves a new/changed endpoint.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# contract-writer

## When to use

Before writing any LV prompt that involves a new edge function OR a shape change to an existing one. The contract is the source of truth; everything else (LV prompt, frontend hook) references it.

## Procedure

### Step 1 — Decide the filename

`src/contracts/<edge-function-name>.ts`. The contract filename matches the edge function name (kebab-case).

### Step 2 — Decide if failure is user-visible

If the endpoint can fail in a way the user must see (insufficient credits, invalid input, third-party API error), use a **discriminated union**. Otherwise a simple `Response` type is fine.

### Step 3 — Write the file

#### Simple (always succeeds)
```typescript
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

#### Discriminated union (user-visible failures)
```typescript
export interface GenerateFooRequest {
  topic: string;
  count: number;
  idempotencyKey: string;
}

export type GenerateFooResponse =
  | GenerateFooSuccess
  | GenerateFooError;

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

### Step 4 — Add to the inventory

Append to `src/contracts/README.md`:

```markdown
| `generate-foo.ts` | `generate-foo` edge function | 2 credits | Active |
```

### Step 5 — Commit

Commit the contract file BEFORE writing the LV prompt. Commit message: `feat(contracts): add generate-foo contract` (or `chore(contracts): bump generate-foo response shape`).

### Step 6 — Use in the LV prompt

In your LV prompt (per the `lv-prompt-writer` skill), paste the contract verbatim under `## Contract Types`:

````markdown
## Contract Types
```typescript
// src/contracts/generate-foo.ts — paste FROM the committed file
export interface GenerateFooRequest { ... }
export type GenerateFooResponse = ...
```
````

## Checklist

- [ ] Filename matches the edge function name.
- [ ] Discriminated union if failure is user-visible.
- [ ] Type guards exported (`isFooSuccess`, `isFooError`).
- [ ] Credit cost constant exported.
- [ ] Timeout constant exported.
- [ ] Added to `src/contracts/README.md` inventory.
- [ ] Committed BEFORE the LV prompt.

## Common pitfalls

- **Inlining the type in the hook file** — never do this. Always import from `@/contracts/`.
- **Changing the contract after LV ships** — if LV's response report says they changed the shape, update the contract FIRST, then update any hooks that import it.
- **Forgetting the idempotency key** — every mutating endpoint needs one in the request type.
- **Skipping the README inventory** — future you won't remember what contracts exist. Keep it current.
