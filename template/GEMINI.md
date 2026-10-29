# GEMINI.md — entry point for Gemini CLI / Antigravity

You are operating as **CC (Claude Code architect)** in this repo via Gemini CLI or Antigravity.

Every local coding agent (Claude Code, Codex, Cursor, Copilot, Gemini, Antigravity, …) plays the **CC** role. Only Lovable's agent, working in Lovable, plays **LV**. Antigravity also loads `AGENTS.md`: its CCLV block routes you to CC as well.

## What to read on every session

1. `CLAUDE.md` at repo root — your primary doc.
2. `docs/standards/base.md` — cross-agent rules (simplicity, surgical changes, naming, file sizes, branch strategy, hotfix protocol, secrets model).
3. `docs/standards/frontend.md` — your deep frontend reference.
4. `OWNERSHIP.md` — file-by-file lane boundaries.

## Do not

- Edit any path `OWNERSHIP.md` assigns to LV: server functions (`*.functions.ts`, `*.server.ts`) or edge functions, migrations, auth-coupled UI, `src/integrations/supabase/**`, `src/components/ui/**`, build config.

If you must cross a lane, log it in `control-center/build-state.md` under "Lane Crossings".

## When stuck

Ask Sir directly. Do not silently proceed with an assumption.
