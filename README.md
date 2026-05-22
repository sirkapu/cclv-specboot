# cclv-specboot

**Spec-driven dev kit for projects using Claude Code + Lovable + Claude Cowork.**

A bootable scaffold of development rules, standards, agent configs, and reusable skills for teams running multi-role AI workflows on a single repo: Claude Code (CC) doing frontend + architecture, Lovable (LV) doing backend (Supabase), and Claude Cowork (CW) doing QA.

Inspired by [lidr-specboot](https://github.com/LIDR-academy/lidr-specboot) — re-architected for the multi-role case where different AI agents own different parts of the codebase.

## Who this is for

You're building a React + Supabase product and:

- **Lovable** scaffolds + owns the backend (edge functions, migrations, RLS, auth).
- **Claude Code** in your local IDE owns the frontend, contracts, and project docs.
- A **second Claude session** (Cowork or a separate Claude Code) reviews + QAs.
- You want all three agents to stay in their lanes, share standards, and not step on each other.

If only ONE AI agent works on your repo, use [lidr-specboot](https://github.com/LIDR-academy/lidr-specboot) instead — simpler and a better fit.

## What you get

```
.
├── CLAUDE.md                          ← CC's primary doc
├── AGENTS.md                          ← LV's primary doc (different from CLAUDE.md — that's the point)
├── OWNERSHIP.md                       ← File-by-file lane assignments
├── docs/standards/                    ← Shared + per-role standards
│   ├── base.md                        ← Cross-agent rules (read FIRST)
│   ├── frontend.md                    ← CC-specific (Phase 2)
│   ├── backend.md                     ← LV-specific (Phase 2)
│   ├── qa.md                          ← CW-specific (Phase 2)
│   └── documentation.md               ← (Phase 2)
├── ai-specs/
│   ├── agents/                        ← Persona definitions (Phase 2)
│   └── skills/                        ← Reusable workflow skills (auto-load in CC)
│       ├── lv-prompt-writer/
│       ├── verify-after-pull/
│       └── ...more in Phase 2
├── control-center/                    ← LV prompts + responses + blockers + CW briefs + reports (Phase 2)
├── src/contracts/                     ← API boundary types (CC owns)
└── scripts/                           ← verify-after-pull, sync-symlinks (Phase 2)
```

## Install

```bash
# 1. Clone this repo
git clone https://github.com/YOUR_ORG/cclv-specboot.git /tmp/cclv-specboot

# 2. Run installer (non-destructive — won't overwrite existing files)
bash /tmp/cclv-specboot/bin/install.sh /path/to/your/project

# 3. Read INSTALL.md for placeholder-filling and Lovable setup steps
cat /path/to/your/project/INSTALL.md
```

## How this differs from lidr-specboot

lidr-specboot symlinks `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `codex.md` ALL to the same `docs/base-standards.md`. Elegant for one-developer-many-tools.

We don't do that. Our agents play different roles, so they need different docs:

- `CLAUDE.md` = CC's full architecture (long, detailed).
- `AGENTS.md` = LV's lane sheet (short, backend-focused).
- Both files **start with** "Read `docs/standards/base.md` FIRST."

Single source of truth for cross-cutting rules; per-agent docs layer on top. See [PHILOSOPHY.md](./PHILOSOPHY.md) for the full reasoning.

## Status

**v0.2.0 — Phase 2 complete.** Full workflow kit: agent docs, per-role standards (frontend/backend/qa/documentation), 12 reusable skills, agent personas, control-center templates, scripts. Ready for use on new projects.

See [CHANGELOG.md](./CHANGELOG.md) for the full list. Phase 3 (example projects, per-stack adaptations, npm-installable variant) on the roadmap.

## Acknowledgments

- [lidr-specboot](https://github.com/LIDR-academy/lidr-specboot) — origin of the spec-driven multi-agent pattern and the `docs/standards/` idea.
- [Superpowers](https://github.com/obra/superpowers) — skill-writing patterns.
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) — spec-driven workflow philosophy.

## License

MIT — see [LICENSE](./LICENSE).
