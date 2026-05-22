# Changelog

All notable changes to cclv-specboot. Follows [Keep a Changelog](https://keepachangelog.com).

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
