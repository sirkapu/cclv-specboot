# OWNERSHIP.md — {{PROJECT_NAME}}

**File-by-file ownership matrix. Every player (CC, LV, CW) must consult this before editing.**

## Ownership table

| Path | Owner | Notes |
|------|-------|-------|
| `src/components/**` | CC | Design system + product components |
| `src/components/ui/**` | LV | shadcn primitives (Lovable scaffolded) |
| `src/pages/**` | CC | Except auth pages — see below |
| `src/pages/Auth/**` | LV | Login, signup, password reset (touches Supabase auth) |
| `src/contexts/AuthContext.tsx` | LV | Session/JWT handling |
| `src/integrations/supabase/**` | LV | Generated types + client setup |
| `src/contracts/**` | CC | LV reads but never edits |
| `src/hooks/**` | CC | Except `useAuth`, `useSession` |
| `src/styles/**` | CC | Tokens, utility CSS |
| `src/lib/**` | CC | Sanitization, exporters, validators |
| `supabase/functions/**` | LV | All edge functions |
| `supabase/migrations/**` | LV | SQL migrations + RLS |
| `scripts/**` | CC | Build/verify scripts |
| `control-center/**` | CC | LV/CW read; LV may write into `lv-responses/` and `lv-blockers/` only; CW may write into `cw-reports/` only |
| `CLAUDE.md`, `OWNERSHIP.md` | CC | LV/CW read; never edit |
| `AGENTS.md` | CC | LV reads; only CC edits |
| `docs/standards/**` | CC | Shared standards; only CC edits |
| `docs/**` (rest) | CC | Product + architecture docs |
| `ai-specs/**` | CC | Skills + agent personas |
| `README.md` | CC | Public-facing |
| `package.json`, lockfiles | Shared (see Coordination below) | |
| `vite.config.ts`, `tsconfig.json`, `tailwind.config.ts`, `postcss.config.js`, `index.html` | LV | Build config — CC never touches |
| `.env.example` | CC | Documents required env vars |
| `.env*` (actual) | Sir's local only | Never committed |

## Lane-crossing protocol

If a player edits a file outside its lane:

1. The change MUST be logged in the response report (LV) or `build-state.md` (CC) or CW report (CW) under a **"Lane Crossings"** section.
2. The log includes: which file, what change, why it couldn't be done in-lane.
3. Silent cross-lane edits are a regression — surface them in the next CW review.

## Adding a new path to this matrix

Whoever first creates the path also adds the row in the same commit/prompt:

- CC commits → CC adds the row.
- LV ships a new edge function or table → LV adds the row in its response report; CC merges it into `OWNERSHIP.md` on the next sync.

## Coordination — shared files

`package.json` and the lockfile are edited by both CC (`npm install`) and LV (Lovable's dependency UI). Conflict resolution:

- Most recent commit wins on simple adds.
- If both add the same package at different versions, CC reconciles after the next pull and notes in `build-state.md`.
- Never commit a `package-lock.json` and `pnpm-lock.yaml` simultaneously. Pick one lockfile per project.

## Quick reference — "who edits this?"

- Edge function? **LV.**
- SQL migration? **LV.**
- shadcn component in `ui/`? **LV.**
- A NEW component in `src/components/`? **CC.**
- A contract type? **CC.**
- A hook (not auth)? **CC.**
- The Lovable Knowledge field content? **CC** writes the canonical copy to `control-center/lovable-knowledge.md` and syncs it via the Lovable MCP (no MCP? Sir pastes it into Lovable).
- A test report? **CW** (writes to `control-center/cw-reports/`).

## Standards layering

`docs/standards/` is CC-owned but read by all three agents:

- `base.md` — read by CC, LV, CW.
- `frontend.md` — read by CC.
- `backend.md` — read by LV.
- `qa.md` — read by CW.

If you propose a change to any standard, it goes through CC (and surfaces in the next `build-state.md` entry).
