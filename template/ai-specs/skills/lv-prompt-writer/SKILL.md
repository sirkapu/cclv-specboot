---
name: lv-prompt-writer
description: Use when CC needs to write a Lovable (LV) prompt for backend work — new server function or edge function, new migration, RLS change, secrets setup, schema migration — or to hand Spec Kit's LV-lane tasks to Lovable. Triggers when CC says "write an LV prompt", "ship X to backend", "need a server function for", "need an edge function for", "Lovable needs to", "send the LV tasks", or detects that a planned slice requires a backend deliverable.
applies_to: [CC]
author: cclv-specboot
version: 0.3.0
---

# lv-prompt-writer

## When to use

CC needs to delegate backend work to Lovable. Use this skill BEFORE writing the prompt — it walks you through the prerequisites and enforces the correct template.

## Procedure

### Step 1 — Confirm the work is in LV's lane

`OWNERSHIP.md` decides; the most specific row wins. On TanStack Start that's server functions (`*.functions.ts`), server-only modules (`*.server.ts`), `src/routes/api/`, `drizzle/`, auth screens. On the Vite + Edge Functions stack it's `supabase/functions/`, `supabase/migrations/` and auth pages. Either way LV also owns `src/components/ui/`, `src/integrations/supabase/` and build config.

If the work touches CC-owned files, do it yourself. If hybrid (e.g. a new server function + a hook to call it), split it: LV ships the backend; you wire the hook.

**With Spec Kit:** run `bash scripts/spec-lanes.sh` (spec-lanes skill). The LV task IDs are this prompt's scope. MIXED tasks must be split first.

### Step 2 — Update the contract FIRST

If the endpoint returns or accepts user-facing data:

1. Open or create `src/contracts/<endpoint-name>.ts`.
2. Define `Request` and `Response` types.
3. If failure modes are user-visible, define a discriminated union with `success: true | false`.
4. Export type guards: `isFooSuccess(payload)`, `isFooError(payload)`.
5. Export constants: `FOO_CREDITS`, `FOO_TIMEOUT_MS`, etc.
6. Commit **and push** the contract before sending the prompt. Lovable reads the synced branch, so an unpushed contract doesn't exist for LV.

### Step 3 — Use the template

`control-center/lv-prompts/TEMPLATE.md` is the template. Key sections:

- **Contract Types.** Depends on the stack:
  - **TanStack Start:** name the file (`src/contracts/<name>.ts`) and tell LV to import from `@/contracts/<name>`. Quote only the types this slice adds or changes.
  - **Vite + Edge Functions:** paste the contract **verbatim**, since Deno can't import it.
- **Implementation Details.** Table names, column types; the server function or edge function name; auth model (RLS policy, impersonation if applicable); idempotency strategy; credit cost and when it's charged; error codes and user-facing messages; secrets required (LV asks for them through Lovable's secure input).
- **Spec Kit tasks** (if used). The LV task IDs and lines from `specs/NNN-*/tasks.md`, plus links to `specs/NNN-*/spec.md` and `plan.md`.
- **Slice-specific rules only.** LV's standing rules and lane list are already in its Project Instructions; don't repeat them.
- **Reply checklist.** Point at "Reply checklist" in LV's instructions. In paste mode, ask LV to write the response file too.

### Step 4 — Save, then send via the Lovable MCP

Save to `control-center/lv-prompts/LV-[NAME].md` (audit trail — always, even in MCP mode).

- **Major or ambiguous slice:** send it first with `plan_mode: true`. LV plans without editing code; settle open questions in that thread. Then send a short build message ("Build the agreed plan for LV-[NAME]"). Plan turns cost credits too, so skip planning for routine slices.
- **Otherwise:** send the prompt body with `send_message`.

**No MCP connected?** Tell Sir: "Paste this into Lovable when ready", and say in the prompt that LV must write its own response file.

### Step 5 — Handle the result

`send_message` blocks until LV finishes (up to 600 s). Act on the result as set out in CLAUDE.md "Lovable MCP channel":

- Timed out (`in_progress`): poll `get_message` with the returned `message_id` and `thread_id` until `response.status` is `completed`, `stopped`, `error` or `awaiting_input`.
- `completed`: hand off to `lv-response-reader`. If LV asked a question in its reply, answer it with a new `send_message`.
- `stopped` or `error`: read what LV did, then re-send a narrower prompt.
- `awaiting_input` with an `awaiting_input` object: show Sir the `tool_id` and `params`, then call `respond_to_approval` with Sir's decision. **Never** send a new message over a pause: that rejects LV's pending tool.
- `requires_secure_form` or a credit check-in: send Sir to `editor_url`.

While LV builds, you can work on your own lane against the pushed contract (send with `wait: false` if you want the turn back immediately). Don't merge frontend that depends on the new endpoint until `lv-response-reader` and `verify-after-pull` pass. If you mock the response meanwhile, flag it loudly in `build-state.md` so the mock is removed later.

## Checklist (tick before sending the prompt)

- [ ] Work is in LV's lane per `OWNERSHIP.md` (or hybrid is split; Spec Kit MIXED tasks split).
- [ ] Contract file in `src/contracts/` is updated, committed **and pushed**.
- [ ] Contract referenced by path (TanStack Start) or pasted verbatim (Edge Functions).
- [ ] Implementation Details lists every secret needed.
- [ ] Testing Checklist has concrete cases (not "test it works").
- [ ] Prompt saved to `control-center/lv-prompts/LV-[NAME].md`.
- [ ] Sent via `send_message` (`plan_mode` first if Major), or handed to Sir to paste.

## Common failure modes

| Symptom | Fix |
|---------|-----|
| LV ships an endpoint with a different shape than the contract | The contract wasn't pushed, or (Edge Functions) wasn't pasted verbatim. Push or re-paste, then send a follow-up prompt to align. |
| LV asks "what should the table name be?" | You skipped Implementation Details. Be explicit. |
| LV silently changed the shape mid-implementation | LV's reply should have flagged it. If not, treat it as a lane crossing and write a hotfix prompt. |
| LV's migration or tool call was rejected for no reason | A `send_message` went out while LV was paused. Answer pauses with `respond_to_approval`. |
| You discover mid-build that the contract is wrong | Update the contract file first, then write a follow-up LV prompt. Never just patch the frontend to match what LV shipped. |
