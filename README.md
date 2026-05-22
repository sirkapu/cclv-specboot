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

Two paths — pick whichever fits your workflow.

### Path 1 — Automated (recommended)

```bash
git clone https://github.com/sirkapu/cclv-specboot.git /tmp/cclv-specboot
bash /tmp/cclv-specboot/bin/install.sh /path/to/your/project
```

Then follow the placeholder-filling and Lovable setup steps in [INSTALL.md](./INSTALL.md).

### Path 2 — Paste-prompt (AI-driven)

Open [BOOTSTRAP-PROMPT.md](./BOOTSTRAP-PROMPT.md), copy the entire file, paste it into a fresh Claude Code session inside your project's local clone. CC walks through preflight, install, placeholders, Lovable setup, and drafts your first LV prompt.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) — covers project layout, how to add a skill or standard, multi-IDE support, file size limits (dogfooded), versioning, and the manual testing checklist.

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
