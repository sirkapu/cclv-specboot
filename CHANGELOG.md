# Changelog

All notable changes to cclv-specboot. Follows [Keep a Changelog](https://keepachangelog.com).

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
