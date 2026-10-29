# Workflow Guide — {{PROJECT_NAME}}

How CC, LV, and CW collaborate. Concrete worked example below.

---

## The loop

```
   ┌──────────────────────────────────────────────────────────────┐
   │                                                              │
   │  CC plans slice                                              │
   │      │                                                       │
   │      ▼                                                       │
   │  needs backend? ── no ──▶ CC builds frontend ──▶ commit ──┐  │
   │      │                                                    │  │
   │      yes                                                  │  │
   │      ▼                                                    │  │
   │  CC: contract-writer (commit + push) → lv-prompt-writer   │  │
   │      │                                                    │  │
   │      ▼                                                    │  │
   │  CC: send_message (plan_mode first if Major)              │  │
   │  (no MCP? Sir pastes it into Lovable)                     │  │
   │      │                                                    │  │
   │      ▼                                                    │  │
   │  LV executes; CC builds its own lane meanwhile            │  │
   │  paused? Sir decides → CC: respond_to_approval            │  │
   │      │                                                    │  │
   │      ▼                                                    │  │
   │  CC: git pull (--ff-only, or --rebase) → verify-after-pull│  │
   │      │                                                    │  │
   │      ▼                                                    │  │
   │  CC: lv-response-reader (reply + get_diff)                │  │
   │      → writes lv-responses/                               │  │
   │      │                                                    │  │
   │      ▼                                                    │  │
   │  CC wires frontend ─────────────────────────────────────▶ │  │
   │      │                                                       │
   │      ▼                                                       │
   │  user-facing? ── no ──▶ CC: update-control-center ──▶ done   │
   │      │                                                       │
   │      yes                                                     │
   │      ▼                                                       │
   │  CC: cw-brief-writer                                         │
   │      │                                                       │
   │      ▼                                                       │
   │  CC runs the cw-reviewer subagent on the brief               │
   │      │                                                       │
   │      ▼                                                       │
   │  CW executes brief → writes cw-reports/                      │
   │      │                                                       │
   │      ▼                                                       │
   │  CC: cw-report-triage → apply fixes (or write LV prompt)     │
   │      │                                                       │
   │      ▼                                                       │
   │  CC: update-control-center ──▶ done                          │
   │                                                              │
   └──────────────────────────────────────────────────────────────┘
```

---

## With Spec Kit (optional spec layer)

If the project ran `specify init --here --integration claude`, planning goes through Spec Kit and the loop above starts from its tasks:

1. `/speckit-specify` → `/speckit-clarify` (optional) → `/speckit-plan` → `/speckit-tasks`, writing `specs/NNN-<feature>/`.
2. `bash scripts/spec-lanes.sh` splits the open tasks into CC and LV lanes from `OWNERSHIP.md` (spec-lanes skill). Split MIXED tasks; add rows for UNKNOWN ones.
3. LV tasks → one LV prompt (lv-prompt-writer), sent early because they usually block the user stories.
4. CC tasks → `/speckit-implement Implement ONLY tasks … (CC lane) …`, using the exact line the script prints. Stock `/speckit-implement` would also build LV's tasks.
5. After LV's push passes verify-after-pull, CC ticks the LV tasks `[X]`.

---

## Paste mode (no Lovable MCP)

The courier fallback, when the MCP isn't connected:

1. CC writes the prompt as usual and tells Sir: "Paste `control-center/lv-prompts/LV-[NAME].md` into Lovable." The prompt's Reply section asks LV to write its own response file.
2. LV builds and writes `control-center/lv-responses/LV-[NAME]-response.md` (or `lv-blockers/` if stuck).
3. CC pulls, runs `verify-after-pull.sh`, and reads the response file (lv-response-reader, paste mode).
4. When `lovable-knowledge.md` changes, Sir re-pastes it (minus the opening comment) into Project settings → Instructions.

---

## Worked example — "Add product image generation"

TanStack Start project (Lovable's default). On the Vite + Edge Functions stack the backend files differ (`supabase/functions/`, `supabase/migrations/`) and the contract is pasted instead of imported; the loop is the same.

### Step 1 — CC plans

Slice: users can request AI-generated product images. Needs:
- New server function `generateProductImage` in `src/lib/product-image.functions.ts` (LV).
- New table `generated_images` (LV).
- New hook `useGenerateProductImage` and component `ProductImageGenerator` (CC).
- Credit cost: 3.

### Step 2 — CC writes the contract

Uses `contract-writer` skill. Creates `src/contracts/product-image.ts` with `Request`, `Response`, type guards, `GENERATE_PRODUCT_IMAGE_CREDITS = 3`. Commits **and pushes**.

### Step 3 — CC writes the LV prompt

Uses `lv-prompt-writer` skill. Creates `control-center/lv-prompts/LV-product-image-gen.md`. Includes:
- Context (where this fits).
- Scope: server function + migration (grants + RLS).
- Contract: "import from `@/contracts/product-image`".
- Implementation details (table schema, RLS, idempotency, credit flow).
- Required secret: `IMAGE_PROVIDER_API_KEY`.

It's a Standard slice, so CC sends it straight away with `send_message` (a Major one would go with `plan_mode: true` first).

### Step 4 — LV executes

While LV works, CC builds `ProductImageGenerator` against the pushed contract. The turn comes back `awaiting_input`: LV is asking for `IMAGE_PROVIDER_API_KEY` through a secure form. CC sends Sir to the `editor_url`; Sir enters the key there, and LV finishes. Its reply asks one question ("charge credits before or after the provider call?"); CC answers with a new `send_message`, and LV completes the slice:
- `drizzle/migrations/…_add_generated_images.sql`.
- `src/lib/product-image.functions.ts`, `src/lib/image-provider.server.ts`.

### Step 5 — CC pulls and verifies

```bash
git pull --ff-only
bash scripts/verify-after-pull.sh
```

Reports: 3 Lovable commits, no lane crossings, lint clean, build passes.

### Step 6 — CC processes the reply

Uses `lv-response-reader` skill: reads the final reply, pulls `get_diff`, cross-checks. Finds:
- Files created/modified — match scope ✓.
- No lane crossings ✓.
- Contract unchanged ✓.
- Secret `IMAGE_PROVIDER_API_KEY` set ✓.
- One known issue: timeout sometimes returns 504, LV suggests retry-on-client.

Distills all of it into `control-center/lv-responses/LV-product-image-gen-response.md` and commits.

### Step 7 — CC smoke-tests

`bun run dev`, exercises the flow, confirms the server function returns the contract shape.

### Step 8 — CC wires frontend

Creates:
- `src/hooks/useGenerateProductImage.ts`.
- Wires `ProductImageGenerator` (built in Step 4) to the hook.
- Integrates it into the relevant route.

Commits with `commit` skill.

### Step 9 — CC writes the CW brief

Uses `cw-brief-writer` skill. Creates `control-center/cw-briefs/CW-product-image-gen.md` with 5 cases (golden + edge cases for empty input, insufficient credits, timeout, unauthorized).

Runs the `cw-reviewer` subagent: "Run CW on `control-center/cw-briefs/CW-product-image-gen.md`."

### Step 10 — CW executes

Files `control-center/cw-reports/CW-product-image-gen-report.md`:
- 5/5 cases run.
- 4 pass, 1 fail (timeout case: error message wrong language).
- Suggested fix: change error message in toast.

### Step 11 — CC triages

Uses `cw-report-triage` skill. Applies the toast fix. Commits.

### Step 12 — CC closes the session

Uses `update-control-center` skill:
- `build-state.md` entry.
- `architecture.md` — adds `generateProductImage` to the backend endpoint inventory + `generated_images` to data models.
- `roadmap.md` — checks off the milestone.
- `OWNERSHIP.md` — no new top-level paths, no change.
- `CLAUDE.md` known issues — adds "504 timeout occasional on image gen, client retries."
- `lovable-knowledge.md` — no shift in mental model, skip.

Commits `chore(control-center): sync after product-image-gen slice`.

---

## Anti-patterns

- ❌ CC starts wiring frontend before LV's response is in.
- ❌ LV adds a new field to the response without flagging in the report.
- ❌ CW applies fixes directly to `main`.
- ❌ CC skips the CW pass on user-facing flows.
- ❌ Anyone forgets to update `build-state.md` at the end of the session.
