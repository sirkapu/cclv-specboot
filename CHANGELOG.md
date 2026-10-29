# Changelog

All notable changes to cclv-specboot. Follows [Keep a Changelog](https://keepachangelog.com).

## [0.4.0] — 2026-10-28

Research and plan: `docs/superpowers/specs/2026-10-28-kit-refresh-plan.md`.

### Changed — Spec Kit replaces lidr-specboot as the reference point
- lidr-specboot's repository is gone (404). README and PHILOSOPHY now position the kit against [GitHub Spec Kit](https://github.com/github/spec-kit) (MIT) and point single-agent users there. lidr-specboot stays as an unlinked historical credit.
- Spec Kit is the optional spec layer: `uv tool install specify-cli` + `specify init --here --integration claude`. New `spec-lanes` skill + `scripts/spec-lanes.sh` split a Spec Kit `tasks.md` into CC and LV tasks from the file paths each task names, and print a scoped `/speckit-implement` call. Stock `/speckit-implement` runs every task, LV's included. `OWNERSHIP.md` gains `.specify/**` and `specs/**` rows.

### Changed — Lovable's TanStack Start scaffold gets its own lanes
- Lovable has scaffolded TanStack Start since 2026-05-13: server functions (`*.functions.ts`), server-only modules (`*.server.ts`), `src/routes/`, Drizzle migrations in `drizzle/migrations/` (since 2026-10-07). The old lane split (CC owns `src/**`, LV owns `supabase/**`) no longer matched where LV writes code.
- New `stacks/` directory with per-stack `OWNERSHIP.md`, `cc-stack.md` and `lv-lanes.md` for `tanstack-start` and `vite-edge`. `bin/install.sh` detects the stack (override `--stack`) and inserts the stack sections into `CLAUDE.md` and `lovable-knowledge.md`. `template/OWNERSHIP.md` moved into `stacks/`.
- On TanStack Start, LV's server functions import `@/contracts/*` directly; pasting contracts verbatim is only for Deno edge functions. `backend.md` §0.1 adds the server-function pattern Lovable's projects use. `frontend.md`, `base.md` naming, contract docs, the LV prompt and response templates, and the personas are stack-aware.

### Changed — `AGENTS.md` is a routing block, not LV's doc
- Nearly every coding agent reads the root `AGENTS.md` (Codex, Cursor, Copilot, Antigravity, Devin, Jules, Zed, opencode, Cline), so "You are Lovable (LV)" there turned them all into LV. And Lovable ships its own `AGENTS.md` and appends rules to it, so the installer's skip-existing rule meant the kit's file was never installed on Lovable projects.
- `template/AGENTS.md` is now a role-neutral `CCLV:BEGIN/END` block: Lovable's agent is LV, every other agent is CC, CW is a subagent. The installer inserts it after Lovable's `LOVABLE:END` marker (or at the top) and never adds it twice. `OWNERSHIP.md` marks `AGENTS.md` as CC+LV: Lovable owns everything outside the block.
- LV's identity, lanes and rules moved into `control-center/lovable-knowledge.md` (Lovable's Project Instructions, formerly "Knowledge"; about 5.6k of 10k characters). `CLAUDE.md` imports `@AGENTS.md`, since Claude Code doesn't load `AGENTS.md` when a `CLAUDE.md` exists.
- Removed `template/codex.md`: no tool reads it (Codex reads `AGENTS.md`). `GEMINI.md` and `.cursor/rules/main.mdc` no longer claim "only Lovable reads AGENTS.md" and point to `OWNERSHIP.md` instead of hardcoded paths.

### Fixed — Lovable MCP loop (checked against the live tool schemas)
- The kit said to "poll `get_message` until done" and answer LV with `send_message`. `get_message`'s top-level status never becomes terminal (read `response.status`), and a `send_message` during an approval pause rejects LV's pending tool. `CLAUDE.md`, `lv-prompt-writer`, `lv-response-reader`, `workflow-guide.md` and `base.md` now say: `send_message` blocks up to 600 s; `awaiting_input` with an `awaiting_input` object → Sir decides → `respond_to_approval`; secure-form secrets and credit check-ins → the Lovable editor. Major slices start with `plan_mode: true`.
- MCP guardrails classify more tools (`respond_to_approval`, `remix_project`, `enable_database`, `add_connector`, workspace knowledge/skills as ask-first; `list_edits`, `get_database_status` and others as free).
- CC pulls (`git pull --ff-only`) and runs `verify-after-pull.sh` itself; the response report is committed after the pull.

### Fixed — lane gate never fired
- `verify-after-pull.sh` matched the commit author against "lovable", but Lovable's commits are authored `gpt-engineer-app[bot]` in raw `git log` (`lovable-dev[bot]` on GitHub). It now recognises those identities or the `X-Lovable-Edit-ID` trailer (`LOVABLE_AUTHOR_REGEX` overrides), audits exactly what was pulled (`ORIG_HEAD..HEAD`), attributes merge commits only for what they resolved, looks every file up in `OWNERSHIP.md` via the new `scripts/lib/lanes.sh` (most specific row wins), flags Lovable edits inside the CCLV block, lists unmapped files, and refuses committed `.env.local`. Runs on macOS's bash 3.2; uses bun when the project does.

### Changed — Claude models and Claude Code
- Tier ladder: the three ratified lines stay verbatim; `base.md` §1 adds an operational mapping (Trivial/Standard = default or `/effort low`; Major = `/effort high`/`xhigh` or a typed `ultrathink`; for LV, Major = `plan_mode` first). On the 5.5 models thinking is always on, and `ultrathink` does nothing when it's only written in a file.
- INSTALL.md prerequisites: Claude Code v2.1.293+ (5.5 aliases), v2.1.311+ for `ultrathink` → `xhigh`.
- CW runs as a Claude Code subagent: the installer links `.claude/agents/cw-reviewer.md` (`model: sonnet`, `effort: high`). Cowork is cloud-only since 2026-10-06 and can't reach a local dev server.

### Changed — env and secrets
- `base.md` §15 rewritten for Lovable Cloud: `.env` is committed with public values (`VITE_SUPABASE_PUBLISHABLE_KEY` replaces `ANON_KEY` in `.env.example`); secrets live in the Lovable editor (or Supabase for your own project); never copy `.env.example` over your env (an empty `VITE_SUPABASE_URL=` in `.env.local` breaks the app). `code-auditing` checks what `.env` holds instead of flagging that it exists.

### Added
- `VERSION` file; the installer stamps `.cclv-specboot-version` into projects.
- `stacks/README.md`, `template/scripts/lib/lanes.sh`, `template/scripts/spec-lanes.sh`, `template/ai-specs/skills/spec-lanes/`.
- `workflow-guide.md`: "With Spec Kit" and "Paste mode" sections; the worked example now follows the TanStack Start loop.

### Also in this release (previously unreleased)
- `53d4398` — §1 thinking effort conditioned on task tier, with the decision record `docs/decisions/2026-07-27-ubc-tier-ladder.md`.

### Migrating a v0.3.x project
1. Re-run `bin/install.sh` (pass `--stack` if detection is wrong): it adds the CCLV block to `AGENTS.md`, the new scripts and the `spec-lanes` skill, and leaves your files alone.
2. Replace your old `AGENTS.md` content (the "You are Lovable (LV)" lane sheet) with the CCLV block, and move anything project-specific into `control-center/lovable-knowledge.md`. Then run kb-sync.
3. Diff your `OWNERSHIP.md`, `CLAUDE.md` and `scripts/verify-after-pull.sh` against `stacks/<stack>/` and `template/`. The new scripts need `OWNERSHIP.md` in the table format described at its top.
4. Delete `codex.md`.

## [0.3.1] — 2026-09-02

### Fixed
- `bin/install.sh` died on macOS right after the copy step: `cp -n` exits 1 when it skips existing files and the script runs under `set -e`, so chmod, `.gitignore` merge and `.claude/skills/` symlinks never ran. Replaced with a per-file copy loop that reports copied/skipped counts. Banner now says v0.3.1.
- `template/.gitignore.append` no longer ignores `.lovable/` (Lovable commits `project.json` and Plan-mode archives there) nor `.env` (Lovable Cloud commits it with the publishable key; secrets belong in `.env.local`).
- Re-running the installer no longer appends the cclv-specboot .gitignore section a second time.

### Changed — Lovable context model, verified against docs.lovable.dev
- Removed every instruction to "pin" `AGENTS.md`/`OWNERSHIP.md` in Lovable: that feature does not exist. Lovable reads root `AGENTS.md` (always) and `CLAUDE.md` automatically on every prompt, plus project/workspace Knowledge (10,000 chars each, project wins). `template/AGENTS.md` priority list, `template/CLAUDE.md` (new "If you are Lovable" callout), INSTALL.md §6, BOOTSTRAP-PROMPT.md, build-state/roadmap templates, installer next-steps.
- INSTALL.md §6 notes that `ai-specs/skills/` can be imported into Lovable as workspace skills (GitHub subdirectory URL or MCP `create_workspace_skill`).

## [0.3.0] — 2026-07-04

### Changed — Lovable MCP integration (MCP primary, paste fallback)

Lovable now ships an official MCP server (`https://mcp.lovable.dev`). CC talks to LV directly — Sir stops being the courier. Every touched doc keeps a "No MCP?" fallback preserving the original paste flow. File artifacts (`lv-prompts/`, `lv-responses/`) remain the audit trail in both modes.

**The loop:**
- CC sends LV prompts itself via `send_message`, polls `get_message`, and answers LV's questions in-chat. Unresolvable blockers still go to `lv-blockers/`.
- CC writes the `lv-responses/` report itself, distilled from LV's chat reply + `get_diff` (paste mode: LV still writes it). Prompt template's "Response Report" section now has MCP/paste variants.
- kb-sync pushes `control-center/lovable-knowledge.md` via `set_project_knowledge` + readback verify (paste mode: Sir re-pastes).
- `verify-after-pull.sh` unchanged — git stays the code channel; MCP inspection doesn't replace the local gate.

**Guardrails** (`template/CLAUDE.md` "Lovable MCP channel"): free use of chat/read tools and SELECT-only `query_database`; Sir's explicit go-ahead required for `deploy_project`, `create_project`, and any DDL/DML — schema changes stay in LV's lane via prompts.

**Files:** `template/CLAUDE.md`, `template/AGENTS.md`, `template/docs/standards/base.md` (§1, §4, §10), `template/control-center/` (workflow-guide, lovable-knowledge, lv-prompts/lv-responses TEMPLATEs), skills `lv-prompt-writer` / `lv-response-reader` / `kb-sync` (all bumped to 0.2.0), `README.md`, `INSTALL.md` (new "Connect the Lovable MCP" step), `BOOTSTRAP-PROMPT.md` (MCP in preflight; `create_project` note for greenfield).

### Added

- `docs/superpowers/specs/2026-07-04-lovable-mcp-integration-design.md` — design doc for this release.
- `template/docs/standards/base.md` §4 — "Strong success criteria let you loop independently" (UBC parity).

## [0.2.3] — 2026-05-22

### Added — First reference example (Phase 3 starter)

- **`docs/examples/`** — directory for project-specific customization examples.
- **`docs/examples/README.md`** — index + how-to-use.
- **`docs/examples/aura-style-bootstrap.md`** — the AURA-flavored paste-prompt that originally produced cclv-specboot. Shows what a real project-specific bootstrap looks like with credits + desktop-first + light Portal safety opinions baked in. Header points readers to the generic `BOOTSTRAP-PROMPT.md` first.

## [0.2.2] — 2026-05-22

### Added — Community polish (Tier C)

- **`CONTRIBUTING.md`** at repo root — how to contribute, project layout, skill/standard authoring conventions, versioning policy, manual testing checklist, release process.
- **`.github/PULL_REQUEST_TEMPLATE.md`** — fills automatically on PR creation; covers type, testing, changelog discipline, dogfooded engineering rules.
- **`BOOTSTRAP-PROMPT.md`** at repo root — paste-into-CC install path, complementing `bin/install.sh` automated path. CC walks through preflight → install → placeholders → Lovable setup → first LV prompt.
- **`template/.vscode/settings.json`** — sensible VSCode defaults for new projects (TS workspace SDK, Prettier on save, ESLint autofix, Tailwind CVA/cn regex, file/search excludes).

## [0.2.1] — 2026-05-22

### Added — BOOTSTRAP.md parity gaps + multi-IDE support

Closing four content gaps found in a post-Phase-2 audit, and adding entry-point files for non-Claude-Code IDEs.

**`template/docs/standards/base.md`:**
- §13 **Branch strategy & git flow** — `main` / `prod` / `feat/*` / `qa/CW-*` model, who pushes where, Sir's pull-first rule.
- §14 **Hotfix & lane-violation recovery** — three protocols (LV rewrote CC file / prod broke / CC edited LV file).
- §15 **Secrets — three places** — full table of Lovable env vars vs Supabase Edge Function Secrets vs local `.env.local`, plus `package.json` / lockfile coordination rule.

**`template/AGENTS.md`:**
- New "Context sources you read (in priority order)" section near the top — explicit priority for Lovable Knowledge / pinned files / AGENTS.md / CLAUDE.md, with the "AGENTS.md wins on conflict" rule.
- "Secrets" section now points to `base.md` §15 for the full three-places model.

**Multi-IDE entry files** (each is a thin pointer to `CLAUDE.md`; only Lovable reads `AGENTS.md`):
- `template/.cursor/rules/main.mdc` — Cursor entry point.
- `template/codex.md` — Codex / GitHub Copilot CLI entry point.
- `template/GEMINI.md` — Gemini CLI entry point.

## [0.2.0] — 2026-05-22

### Added — Phase 2 (Standards + Skills + Control Center)

**Per-role standards** (`template/docs/standards/`):
- `frontend.md` — CC's deep ref (React, TanStack Query, Tailwind, forms, hooks, portal safety).
- `backend.md` — LV's deep ref (edge function skeleton, RLS patterns, credits flow, idempotency, realtime).
- `qa.md` — CW's deep ref (test brief format, severity calibration, evidence requirements, suggested-fix format).
- `documentation.md` — Lovable Knowledge sync, control-center sync, KB conventions, doc-rot detection.

**Agent personas** (`template/ai-specs/agents/`):
- `cc-architect.md` — CC identity sheet.
- `lv-backend.md` — LV identity sheet.
- `cw-reviewer.md` — CW identity sheet.

**Skills** (`template/ai-specs/skills/`):
- `contract-writer/` — define API contracts in `src/contracts/`.
- `lv-response-reader/` — triage LV response reports.
- `kb-sync/` — Lovable Knowledge field sync discipline.
- `update-control-center/` — end-of-session sync checklist.
- `bootstrap-checklist/` — cross-session resume for multi-step work.
- `cw-brief-writer/` — hand off to CW.
- `cw-report-triage/` — process CW reports.
- `commit/` — single-concern conventional commits.
- `using-git-worktrees/` — feature isolation.
- `code-auditing/` — 6-phase systematic audit.

**Control-center templates** (`template/control-center/`):
- `build-state.md` — session log starter.
- `architecture.md` — stable architecture reference.
- `roadmap.md` — phase + milestone tracking.
- `workflow-guide.md` — concrete worked example of CC/LV/CW loop.
- `lovable-knowledge.md` — canonical Knowledge field content.
- `lv-prompts/TEMPLATE.md`, `lv-responses/TEMPLATE.md`, `lv-blockers/README.md`.
- `cw-briefs/TEMPLATE.md`, `cw-reports/TEMPLATE.md`.

**Scripts** (`template/scripts/`):
- `verify-after-pull.sh` — lane-crossing audit + lint + build.
- `sync-agent-symlinks.sh` — refresh `.claude/skills/` symlinks.

**Misc**:
- `template/src/contracts/README.md` — contracts pattern reference.
- `template/.env.example` — documented frontend env vars (no secrets).
- `template/.gitignore.append` — patterns to append to project `.gitignore`.

### Changed
- `template/CLAUDE.md` — points to `docs/standards/frontend.md` for deep reference.
- `template/AGENTS.md` — points to `docs/standards/backend.md` for deep reference.

### Planned — Phase 3
- Reference example projects in `docs/examples/`.
- Per-stack adaptations (Next.js, SvelteKit, etc.).
- MCP integration recipes (Linear, Slack, etc.).
- npm-installable variant: `npx cclv-specboot init`.
- `bin/uninstall.sh`.

---

## [0.1.0] — 2026-05-22

### Added — Phase 1 scaffold
- Repo-level docs: `README.md`, `LICENSE`, `INSTALL.md`, `PHILOSOPHY.md`, `CHANGELOG.md`.
- `bin/install.sh` — non-destructive `cp -rn` installer with `.claude/skills/` symlinking.
- `template/CLAUDE.md` — CC's primary doc with `{{PLACEHOLDERS}}`.
- `template/AGENTS.md` — LV's primary doc with `{{PLACEHOLDERS}}`.
- `template/OWNERSHIP.md` — file-by-file ownership matrix.
- `template/docs/standards/base.md` — cross-agent shared standards.
- `template/ai-specs/skills/lv-prompt-writer/SKILL.md` — reference skill.
- `template/ai-specs/skills/verify-after-pull/SKILL.md` — reference skill.
