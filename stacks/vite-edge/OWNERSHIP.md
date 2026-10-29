# OWNERSHIP.md — {{PROJECT_NAME}}

**File-by-file ownership matrix. Every player (CC, LV, CW) must consult this before editing.**

Stack: **React + Vite SPA with Supabase Edge Functions** (Lovable projects created before 2026-05-13). LV's backend lives in `supabase/`.

## How to read this table

- The **most specific** row wins. File-kind rows (`**/*.test.ts`, if you add any) beat folder rows; among the rest, the path with the most literal characters wins (`src/components/ui/**` beats `src/components/**`), and on a tie the earlier row.
- **Owner** is who may edit. `Shared` means CC and LV may both edit. `Human` means only the human, never an agent.
- `scripts/verify-after-pull.sh` and `scripts/spec-lanes.sh` parse this table. Keep each row on one line, with paths in backticks in the first column and owners, comma-separated, in the second.

## Ownership table

| Path | Owner | Notes |
|------|-------|-------|
| `src/components/**` | CC | Design system + product components |
| `src/components/ui/**` | LV | shadcn primitives (Lovable scaffolded) |
| `src/pages/**` | CC | Except auth pages — see below |
| `src/pages/Auth/**` | LV | Login, signup, password reset (touches Supabase auth) |
| `src/contexts/**` | CC | Except AuthContext — see below |
| `src/contexts/AuthContext.tsx` | LV | Session/JWT handling |
| `src/integrations/supabase/**` | LV | Generated types + client setup |
| `src/contracts/**` | CC | LV reads but never edits |
| `src/hooks/**` | CC | Except auth hooks — see below |
| `src/hooks/useAuth*`, `src/hooks/useSession*` | LV | Auth hooks |
| `src/styles/**`, `src/index.css` | CC | Tokens, utility CSS |
| `src/lib/**` | CC | Sanitization, exporters, validators |
| `supabase/functions/**` | LV | All edge functions (Deno) |
| `supabase/migrations/**` | LV | SQL migrations + RLS |
| `supabase/**` | LV | Supabase config |
| `vite.config.ts`, `tsconfig.json`, `tsconfig.app.json`, `tsconfig.node.json`, `tailwind.config.ts`, `postcss.config.js`, `index.html`, `components.json`, `eslint.config.js` | LV | Build config — CC never touches |
| `package.json`, `package-lock.json`, `bun.lockb`, `bun.lock` | Shared | See Coordination below |
| `.lovable/**` | LV | Lovable metadata and plans |
| `.env` | LV | Committed public values written by Lovable Cloud — never secrets |
| `.env.local` | Human | Personal values for `npm run dev` — never committed |
| `.env.example` | CC | Documents required env vars |
| `AGENTS.md` | CC, LV | CC owns the `CCLV:BEGIN/END` block; Lovable owns its own `LOVABLE` block and the rules it appends |
| `CLAUDE.md`, `OWNERSHIP.md` | CC | LV/CW read; never edit |
| `control-center/**` | CC | LV/CW read |
| `control-center/lv-responses/**`, `control-center/lv-blockers/**` | CC, LV | LV writes here only in paste mode or for blockers |
| `control-center/cw-reports/**` | CC, CW | CW's reports + evidence |
| `docs/**`, `ai-specs/**`, `scripts/**`, `README.md` | CC | Standards, skills, scripts, docs |
| `.claude/**`, `.specify/**`, `specs/**` | CC | Claude Code config; Spec Kit specs, plans, tasks (if installed) |
| `GEMINI.md`, `.cursor/**`, `.vscode/**` | CC | Entry files for other IDE agents |
| `src/App.tsx`, `src/main.tsx` | Shared | App shell + router; Lovable edits it when it adds pages |
| `public/**`, `.gitignore` | Shared | Static assets; ignore rules |

## Lane-crossing protocol

If a player edits a file outside its lane:

1. The change MUST be logged in the response report (LV) or `build-state.md` (CC) or CW report (CW) under a **"Lane Crossings"** section.
2. The log includes: which file, what change, why it couldn't be done in-lane.
3. Silent cross-lane edits are a regression — `verify-after-pull.sh` flags them, and they surface in the next CW review.

## Adding a new path to this matrix

Whoever first creates the path also adds the row in the same commit/prompt:

- CC commits → CC adds the row.
- LV ships a new edge function or table → LV names it in its response report; CC merges the row into `OWNERSHIP.md` on the next sync.

`verify-after-pull.sh` lists LV-touched files that match no row. Add a row for each.

## Coordination — shared files

`package.json` and the lockfile are edited by both CC (`npm install`) and LV (Lovable's dependency UI). Conflict resolution:

- Most recent commit wins on simple adds.
- If both add the same package at different versions, CC reconciles after the next pull and notes it in `build-state.md`.
- Never commit two lockfile formats at once. Pick one lockfile per project.

## Quick reference — "who edits this?"

- Edge function? **LV.**
- SQL migration? **LV.**
- shadcn component in `ui/`? **LV.**
- A NEW component in `src/components/`? **CC.**
- A contract type? **CC.**
- A hook (not auth)? **CC.**
- The Lovable Project Instructions? **CC** writes the canonical copy to `control-center/lovable-knowledge.md` and syncs it (kb-sync skill).
- A test report? **CW** (writes to `control-center/cw-reports/`).

## Standards layering

`docs/standards/` is CC-owned but read by all three agents:

- `base.md` — read by CC, LV, CW.
- `frontend.md` — read by CC.
- `backend.md` — read by LV.
- `qa.md` — read by CW.

If you propose a change to any standard, it goes through CC (and surfaces in the next `build-state.md` entry).
