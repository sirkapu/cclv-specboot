# cclv-specboot

**Spec-driven dev kit for products built by Claude Code + Lovable, with GitHub Spec Kit as the spec layer.**

A bootable scaffold of development rules, standards, agent configs, and reusable skills for teams running multi-role AI workflows on a single repo: Claude Code (CC) doing frontend + architecture, Lovable (LV) doing the backend, and a QA reviewer (CW) running as a Claude Code subagent.

It builds on [GitHub Spec Kit](https://github.com/github/spec-kit) for spec → plan → tasks, and adds what Spec Kit doesn't cover when several agents share one codebase: file-level lanes, typed contracts at the CC↔LV boundary, a Lovable MCP channel, and a pull-time lane gate.

## Who this is for

You're building a React + Supabase product on Lovable and:

- **Lovable** scaffolds and owns the backend: TanStack Start server functions (or Supabase edge functions on older projects), migrations, RLS, auth.
- **Claude Code** in your local IDE owns the frontend, contracts, and project docs, and drives Lovable directly through the [Lovable MCP](https://docs.lovable.dev/integrations/lovable-mcp-server): it sends build prompts, answers approval pauses with your decision, reads diffs, syncs LV's instructions. A manual paste flow remains as fallback.
- **CW**, a Claude Code subagent, reviews and QAs from a brief.
- You want all three agents to stay in their lanes, share standards, and not step on each other.

If only ONE AI agent works on your repo, use [Spec Kit](https://github.com/github/spec-kit) on its own: simpler and a better fit.

## What you get

```
.
├── CLAUDE.md                     ← CC's primary doc (imports AGENTS.md)
├── AGENTS.md                     ← Routing block every agent reads (Lovable keeps its own notes here too)
├── OWNERSHIP.md                  ← File-by-file lanes, per stack; scripts parse it
├── docs/standards/               ← Shared + per-role standards
│   ├── base.md                   ← Cross-agent rules (read FIRST)
│   ├── frontend.md / backend.md / qa.md / documentation.md
├── ai-specs/
│   ├── agents/                   ← Personas; cw-reviewer is installed as a Claude Code subagent
│   └── skills/                   ← 13 workflow skills (auto-load in CC), incl. spec-lanes for Spec Kit
├── control-center/               ← LV prompts/responses/blockers, CW briefs/reports, LV's Project Instructions
├── src/contracts/                ← API boundary types (CC owns)
└── scripts/                      ← verify-after-pull.sh, spec-lanes.sh, sync-agent-symlinks.sh
```

## Install

Two paths — pick whichever fits your workflow.

### Path 1 — Automated (recommended)

```bash
git clone https://github.com/sirkapu/cclv-specboot.git /tmp/cclv-specboot
bash /tmp/cclv-specboot/bin/install.sh /path/to/your/project   # --stack tanstack-start|vite-edge to override detection
```

Optional, Spec Kit as the spec layer (run inside the project):

```bash
uv tool install specify-cli
specify init --here --integration claude
```

Then follow the placeholder-filling and Lovable setup steps in [INSTALL.md](./INSTALL.md).

### Path 2 — Paste-prompt (AI-driven)

Open [BOOTSTRAP-PROMPT.md](./BOOTSTRAP-PROMPT.md), copy the entire file, paste it into a fresh Claude Code session inside your project's local clone. CC walks through preflight, install, placeholders, Lovable setup, and drafts your first LV prompt.

## How this differs from Spec Kit

Spec Kit turns a feature description into `spec.md`, `plan.md` and `tasks.md`, then `/speckit-implement` executes **every** task with whichever agent you initialized it for. That works when one agent builds everything. Here, three agents own different files, and one of them (Lovable) can't run Spec Kit commands at all. So cclv adds:

- **Lanes.** `OWNERSHIP.md` assigns every path to CC, LV, CW or both, per Lovable stack. `scripts/spec-lanes.sh` splits a Spec Kit `tasks.md` into CC and LV tasks from the file paths each task names. CC implements its IDs; LV's go to Lovable as one prompt.
- **Routing.** Nearly every coding agent reads `AGENTS.md`, and Lovable writes its own notes there, so `AGENTS.md` carries a neutral routing block instead of one agent's identity. LV's real instructions live in Lovable's Project Instructions.
- **Contracts.** `src/contracts/` types are the CC↔LV boundary, imported by both sides on TanStack Start.
- **A Lovable MCP channel** with the approval-pause rules spelled out, and a **pull-time gate** (`verify-after-pull.sh`) that recognises Lovable's commits and flags lane crossings.

Spec Kit is optional: without it, CC plans in chat and the rest of the loop is the same. See [PHILOSOPHY.md](./PHILOSOPHY.md) for the full reasoning.

## Examples

See [`docs/examples/`](./docs/examples/) for project-specific customizations of the kit. First entry: [`aura-style-bootstrap.md`](./docs/examples/aura-style-bootstrap.md) — the AURA-flavored paste-prompt that originally produced cclv-specboot (pre-MCP, kept as history).

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) — covers project layout, how to add a skill or standard, multi-IDE support, file size limits (dogfooded), versioning, and the manual testing checklist.

## Status

**v0.4.0 — Spec Kit spec layer, TanStack Start lanes, AGENTS.md routing.** Lovable's current scaffold (TanStack Start) gets its own lane map, `AGENTS.md` becomes a routing block that coexists with Lovable's, the MCP loop handles approval pauses, and CW runs as a Claude Code subagent. Built on the v0.3.x Lovable MCP integration.

See [CHANGELOG.md](./CHANGELOG.md) for the full list.

## Acknowledgments

- [GitHub Spec Kit](https://github.com/github/spec-kit) (MIT) — the spec → plan → tasks layer this kit plugs into.
- lidr-specboot by LIDR academy — the original inspiration for the `docs/standards/` shared-standards idea (its repository is no longer public).
- [Superpowers](https://github.com/obra/superpowers) — skill-writing patterns.
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) — spec-driven workflow philosophy.
- [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) (MIT) — source of the four engineering disciplines in `base.md`.

## License

MIT — see [LICENSE](./LICENSE).
