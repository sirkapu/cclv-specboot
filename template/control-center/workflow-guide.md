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
   │  CC: contract-writer → lv-prompt-writer                   │  │
   │      │                                                    │  │
   │      ▼                                                    │  │
   │  CC sends prompt via Lovable MCP send_message             │  │
   │  (no MCP? Sir pastes it into Lovable)                     │  │
   │      │                                                    │  │
   │      ▼                                                    │  │
   │  LV executes → replies in chat; CC answers questions      │  │
   │      │                                                    │  │
   │      ▼                                                    │  │
   │  CC: lv-response-reader (get_message + get_diff)          │  │
   │      → writes lv-responses/                               │  │
   │      │                                                    │  │
   │      ▼                                                    │  │
   │  Sir pulls; CC: verify-after-pull                         │  │
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
   │  Sir opens second Claude session on qa/ branch               │
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

## Worked example — "Add product image generation"

### Step 1 — CC plans

Slice: users can request AI-generated product images. Needs:
- New edge function `generate-product-image`.
- New table `generated_images`.
- New hook `useGenerateProductImage`.
- New component `ProductImageGenerator`.
- Credit cost: 3.

### Step 2 — CC writes the contract

Uses `contract-writer` skill. Creates `src/contracts/generate-product-image.ts` with `Request`, `Response`, type guards, `GENERATE_PRODUCT_IMAGE_CREDITS = 3`. Commits.

### Step 3 — CC writes the LV prompt

Uses `lv-prompt-writer` skill. Creates `control-center/lv-prompts/LV-product-image-gen.md`. Includes:
- Context (where this fits).
- Scope: edge function + migration + RLS.
- Contract types (pasted verbatim).
- Implementation details (table schema, RLS, idempotency, credit flow).
- Required secret: `IMAGE_PROVIDER_API_KEY`.

Sends it to LV via the Lovable MCP (`send_message`).

### Step 4 — LV executes

CC polls `get_message`. LV asks one question mid-run ("charge credits before or after the provider call?") — CC answers in-chat. LV pushes to `main`:
- `supabase/migrations/20260522140000_add_generated_images.sql`.
- `supabase/functions/generate-product-image/index.ts`.
- `supabase/functions/_shared/...` (if extended).

### Step 5 — CC processes the reply

Uses `lv-response-reader` skill: reads the final `get_message` reply, pulls `get_diff`, cross-checks. Finds:
- Files created/modified — match scope ✓.
- No lane crossings ✓.
- Contract unchanged ✓.
- Secret `IMAGE_PROVIDER_API_KEY` required — Sir confirms set in Supabase.
- One known issue: timeout sometimes returns 504, LV suggests retry-on-client.

Distills all of it into `control-center/lv-responses/LV-product-image-gen-response.md` and commits.

### Step 6 — Sir pulls; CC runs verify-after-pull

```bash
bash scripts/verify-after-pull.sh
```

Reports: no lane crossings, lint clean, build passes.

### Step 7 — CC smoke-tests

`npm run dev`, hits the endpoint via DevTools, confirms 200 + expected shape.

### Step 8 — CC wires frontend

Creates:
- `src/hooks/useGenerateProductImage.ts`.
- `src/components/ProductImageGenerator.tsx`.
- Integrates into the relevant page.

Commits with `commit` skill.

### Step 9 — CC writes the CW brief

Uses `cw-brief-writer` skill. Creates `control-center/cw-briefs/CW-product-image-gen.md` with 5 cases (golden + edge cases for empty input, insufficient credits, timeout, unauthorized).

Tells Sir: "Open Cowork on `qa/CW-product-image-gen`."

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
- `architecture.md` — adds `generate-product-image` to edge function inventory + `generated_images` to data models.
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
