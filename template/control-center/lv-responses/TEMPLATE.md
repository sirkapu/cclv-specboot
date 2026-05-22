# LV-[NAME] Response Report

> Save as `control-center/lv-responses/LV-[NAME]-response.md` matching the prompt's NAME.

## Prompt Reference

- **Prompt:** `control-center/lv-prompts/LV-[NAME].md`
- **Date completed:** YYYY-MM-DD
- **Lovable session:** [session id if available]

## Files created

- `supabase/migrations/YYYYMMDDHHMMSS_<name>.sql`
- `supabase/functions/<name>/index.ts`
- `supabase/functions/_shared/<helper>.ts` (if added)
- `src/integrations/supabase/types.ts` (regenerated)

## Files modified

- (list each modified file with a one-line summary of the change)

## Files deleted

- (list any deletions with reason)

## Migration summary

For each migration:

```
20260522T140000_add_foos.sql
- Creates public.foos table with columns: id, user_id, name, created_at.
- Adds index idx_foos_user_id.
- RLS: enabled. Policies: foos_select_owner, foos_insert_owner.
- Realtime: REPLICA IDENTITY FULL; added to supabase_realtime publication.
- Verification: RAISE NOTICE 'PASSED' at end.
```

## Contract changes

- **No changes** — implemented exactly per the pasted contract.
- **OR** — describe the change, why it was necessary, and what CC needs to update in `src/contracts/<name>.ts`.

## Lane Crossings

- **None.**
- **OR** — list each file edited outside LV's lane, with: which file, what change, why it couldn't be done in-lane.

## Secrets required for deploy

- `<SECRET_NAME>` — purpose. Sir to set in Supabase → Edge Functions → Secrets.

## Known issues / flags for CC

- [Issue 1] — severity, suggested mitigation.
- [Issue 2] — ...

## Suggested CC follow-up tasks

- [ ] Wire `useFoo` hook.
- [ ] Add `<FooComponent>` to relevant page.
- [ ] Update `docs/standards/backend.md` if a new pattern was introduced.

## Tests run

| Test | Result | Notes |
|------|--------|-------|
| Migration applies cleanly | ✅ | |
| Edge function deploys | ✅ | |
| Endpoint returns expected shape | ✅ | |
| RLS denies unauthorized access | ✅ | |
| Idempotency key collision | ✅ | |
| Credit deduction logged | ✅ | |
| Realtime subscription fires | ✅ | (or N/A) |

## Logs / evidence (optional)

[Paste relevant log snippets or link to Supabase dashboard]
