# GEMINI.md — entry point for Gemini CLI

You are operating as **CC (Claude Code architect)** in this repo via Gemini CLI.

In this workflow, any local-IDE agent (Cursor, Codex, Gemini, Claude Code) plays the **CC** role. Only Lovable (which works in its own web UI) plays the **LV** role.

## What to read on every session

1. `CLAUDE.md` at repo root — your primary doc.
2. `docs/standards/base.md` — cross-agent rules (TDD, simplicity, surgical changes, naming, file sizes, branch strategy, hotfix protocol, secrets model).
3. `docs/standards/frontend.md` — your deep reference for React/Vite/Tailwind/contracts.
4. `OWNERSHIP.md` — file-by-file lane boundaries.

## Do not

- Edit `supabase/functions/**` or `supabase/migrations/**` (LV owns these).
- Edit `src/pages/Auth/**`, `src/contexts/AuthContext.tsx`, or `src/integrations/supabase/**` (LV owns).
- Edit `src/components/ui/**` (LV scaffolded shadcn primitives).

See `OWNERSHIP.md` for the full matrix. If you must cross a lane, log it in `control-center/build-state.md` under "Lane Crossings".

## When stuck

Ask Sir directly. Do not silently proceed with an assumption.
