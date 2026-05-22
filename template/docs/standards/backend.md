---
name: backend-standards
description: LV-specific Supabase backend development standards. Read after base.md.
applies_to: [LV]
---

# Backend Standards

LV's deep reference for Supabase edge functions, migrations, RLS, and auth work. Read `base.md` first.

## 1. Edge function structure

Every edge function follows this skeleton:

```typescript
import { serve } from 'https://deno.land/std/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js';
import { corsHeaders, jsonResponse } from '../_shared/cors.ts';
import { checkCredits } from '../_shared/credit-utils.ts';

serve(async (req) => {
  // 1. OPTIONS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // 2. Auth
    const supabase = createClient(...);
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return jsonResponse({ success: false, error: 'unauthorized' }, 401);

    // 3. Parse + validate body
    const body = await req.json();
    // ...validate against contract...

    // 4. Credit check (if applicable)
    const credits = await checkCredits(supabase, user.id, COST);
    if (!credits.hasCredits) return jsonResponse({ success: false, error: 'insufficient_credits' }, 402);

    // 5. Do work
    // ...

    // 6. Deduct credits (if applicable)
    await supabase.rpc('add_credits', {
      _user_id: user.id,
      _amount: -COST,
      _type: 'deduction',
      _description: '...',
      _feature: '...',
    });

    // 7. Return success
    return jsonResponse({ success: true, ...data });
  } catch (err) {
    console.error(err);
    return jsonResponse({ success: false, error: 'internal_error' }, 500);
  }
});
```

## 2. `_shared/` utilities (must use these)

| Utility | Purpose |
|---------|---------|
| `cors.ts` | `corsHeaders` constant + `jsonResponse(body, status)` helper |
| `credit-utils.ts` | `checkCredits()` + `deductCreditsAtomic()` |
| `get-effective-user-id.ts` | Resolves impersonation if the project supports it |
| `json-parser.ts` | `parseJsonWithRecovery()` — handles truncated AI responses |
| `cost-tracker.ts` | `logAICost()` for AI-consuming endpoints |

Never reimplement these inline.

## 3. CORS — non-negotiable

`corsHeaders` is applied to EVERY response, including:
- Success.
- Error (4xx, 5xx).
- OPTIONS preflight.

Missing CORS = browser blocks the response = silent failure for the user.

## 4. SQL migrations

### Filename
`YYYYMMDDHHMMSS_descriptive_snake_case.sql` (UTC).

### Pattern
```sql
-- Migration: <one-line description>
-- Date: YYYY-MM-DD

-- 1. Table creation (idempotent)
CREATE TABLE IF NOT EXISTS public.foos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  -- ...
);

-- 2. Indexes
CREATE INDEX IF NOT EXISTS idx_foos_user_id ON public.foos(user_id);

-- 3. RLS
ALTER TABLE public.foos ENABLE ROW LEVEL SECURITY;

CREATE POLICY foos_select_owner
  ON public.foos
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY foos_insert_owner
  ON public.foos
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 4. Realtime (if subscribed by frontend)
ALTER TABLE public.foos REPLICA IDENTITY FULL;
ALTER PUBLICATION supabase_realtime ADD TABLE public.foos;
```

### Rules
- **Append-only.** Never edit a shipped migration; write a new one that corrects.
- **One concern per migration.** Don't bundle a schema change + a backfill + a trigger in one file.
- **Verify with `RAISE NOTICE 'PASSED'` blocks** at the end of multi-step migrations.

## 5. RLS policy patterns

### Owner-only
```sql
CREATE POLICY foos_select_owner ON public.foos FOR SELECT
  USING (auth.uid() = user_id);
```

### Owner-or-impersonator (when impersonation is supported)
```sql
CREATE POLICY foos_select_owner_or_impersonator ON public.foos FOR SELECT
  USING (
    auth.uid() = user_id
    OR auth.uid() IN (SELECT admin_user_id FROM public.impersonation_sessions WHERE target_user_id = foos.user_id AND active = true)
  );
```

### Public read, authenticated write
```sql
CREATE POLICY foos_public_read ON public.foos FOR SELECT USING (true);
CREATE POLICY foos_insert_auth ON public.foos FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
```

**Default deny.** If you don't write a policy for an action, that action is denied. Good.

## 6. Credits flow

```typescript
// 1. Check
const credits = await checkCredits(supabase, user.id, COST);
if (!credits.hasCredits) return jsonResponse({ success: false, error: 'insufficient_credits' }, 402);

// 2. Do work (atomic — if this fails, no deduction)
const result = await doWork();

// 3. Deduct via RPC (NEVER direct UPDATE)
await supabase.rpc('add_credits', {
  _user_id: user.id,
  _amount: -COST,
  _type: 'deduction',
  _description: 'Generated foo',
  _feature: 'foo_generation',
});
```

- `COST` is a constant from the contract file (e.g. `FOO_CREDITS = 3`).
- If work fails mid-flight, do NOT deduct.
- For multi-step ops (e.g. batch image generation), deduct per-success increment OR deduct upfront and refund on failure — choose per prompt.

## 7. Idempotency

Every mutating endpoint accepts an idempotency key in the request body (or `Idempotency-Key` header):

```typescript
const { idempotencyKey } = body;
const { data: existing } = await supabase
  .from('idempotency_keys')
  .select('response')
  .eq('key', idempotencyKey)
  .single();
if (existing) return new Response(existing.response, { headers: corsHeaders });
// ... do work ...
await supabase.from('idempotency_keys').insert({ key: idempotencyKey, response: JSON.stringify(result) });
```

Or use a unique constraint on `(user_id, operation_id)` in the target table.

## 8. Response shape — discriminated union

Always return:

```typescript
// Success
{ success: true, data: { ... } }

// Failure
{ success: false, code: 'specific_error_code', message: 'User-facing message' }
```

The frontend's contract file declares both shapes; the type guard checks `payload.success`.

Status codes:
- `200` — success.
- `400` — bad request (invalid input).
- `401` — unauthorized.
- `402` — payment required (insufficient credits).
- `404` — not found.
- `409` — conflict (idempotency collision with different params).
- `429` — rate limited.
- `500` — internal error.

## 9. Logging

- `console.log()` / `console.error()` for runtime logs (English).
- `logAICost()` after every AI provider call (cost tracking).
- Never log secrets, tokens, or PII to console.

## 10. Storage buckets

- Kebab-case names: `product-images`, `user-avatars`.
- Private by default. Public only with explicit reason.
- Generate signed URLs for serving (`createSignedUrl`).
- Set `cacheControl: '3600'` on uploads to enable CDN caching.

## 11. Realtime

To make a table reactive on the frontend:

```sql
ALTER TABLE public.foos REPLICA IDENTITY FULL;
ALTER PUBLICATION supabase_realtime ADD TABLE public.foos;
```

Both lines are required. `REPLICA IDENTITY FULL` ships the full row in the changeset (vs. just the primary key); the publication exposes the changeset to the realtime service.

## 12. Auth pages frontend

When editing `src/pages/Auth/`:

- Use `useNavigate()` for redirects, not `window.location`.
- Show inline form errors. No alerts.
- Use the project's design tokens (`bg-[var(--color-bg)]`) — don't introduce new colors.
- Match the rest of the app's component patterns (look at how CC built `src/components/`).
