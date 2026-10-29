# Philosophy

## The problem

Multi-agent dev workflows have a coordination problem. If two AI agents share a repo, they tend to:

1. **Step on each other's files** — LV overwriting CC's component; CC editing LV's edge function.
2. **Drift in conventions** — one uses kebab-case, the other PascalCase.
3. **Lose context across sessions** — no persistent memory of what shipped, what's next.
4. **Block each other** — CC waits for LV; LV doesn't know what CC needs.

[GitHub Spec Kit](https://github.com/github/spec-kit) solves the spec part of this (spec → plan → tasks) but assumes **one agent builds everything**: `/speckit-implement` runs every task in `tasks.md`. Multi-agent multi-role needs more.

## The three-player model

This kit assumes three roles:

| Role | Tool | Owns |
|------|------|------|
| **CC** — Architect + frontend | Claude Code (local) | Frontend, contracts, docs, control-center |
| **LV** — Backend | Lovable (web UI, driven by CC over MCP) | Server functions or edge functions, migrations, RLS, auth |
| **CW** — QA | `cw-reviewer`, a Claude Code subagent | Test plans, QA reports |

Each role has its own primary doc:
- **CC reads** `CLAUDE.md` first.
- **LV reads** its Lovable Project Instructions (canonical copy: `control-center/lovable-knowledge.md`).
- **CW reads** the CW brief CC writes for it, plus `OWNERSHIP.md`.
- **Everyone** reads the routing block in `AGENTS.md`, which tells each agent which role it plays.

## Three sources of truth

| Source | Declares |
|--------|----------|
| `OWNERSHIP.md` | Who owns which files (lane boundaries). |
| `src/contracts/` | API shapes between CC and LV. |
| `docs/standards/base.md` | Cross-agent behavioral rules. |

Anything else is project-specific opinion that lives in `CLAUDE.md`, LV's Project Instructions, or per-role standards.

## Why AGENTS.md is a router, not anyone's doc

The single-agent answer is one doc that every tool reads: symlink `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` to the same file (lidr-specboot's approach), or let every tool read one `AGENTS.md`. Elegant for **single-developer-multi-tool**.

For **multi-role multi-agent**, it's wrong. CC and LV have different jobs. CC needs detailed frontend architecture; LV needs lane boundaries and backend patterns. Forcing them to read the same doc means each agent reads a lot of irrelevant content, which degrades attention on the relevant parts.

And `AGENTS.md` can't be one role's private doc either. Codex, Cursor, Copilot, Gemini/Antigravity, Devin, Jules, Zed, opencode and Cline all read the root `AGENTS.md`; the format has no way to address one agent; and Lovable ships its own `AGENTS.md` and appends project rules to it. An `AGENTS.md` that opens with "You are Lovable" turns every other tool into LV.

Our split:
- `AGENTS.md` — a short, role-neutral routing block (between `CCLV` markers) next to Lovable's own content: "Lovable's agent is LV; every other agent is CC; CW is a subagent."
- `CLAUDE.md` — long, CC-specific. It imports `AGENTS.md`, so CC also sees the rules Lovable recorded.
- LV's Project Instructions — LV's identity, lane and backend rules, inside Lovable's 10,000-character field.
- All of them point to `docs/standards/base.md` first.

Shared standards in one file; role-specific docs layer on top.

## Why control-center

The `control-center/` directory is the asynchronous communication channel between CC, LV, and CW:

- CC writes `lv-prompts/LV-[NAME].md` and sends it over the Lovable MCP → LV executes and replies → CC records the reply in `lv-responses/LV-[NAME]-response.md` (in paste mode, LV writes it).
- LV writes `lv-blockers/LV-[NAME]-blocker.md` when stuck → CC reads at the start of next session.
- CC writes `cw-briefs/CW-[NAME].md` → CW executes, writes `cw-reports/CW-[NAME]-report.md`.
- `build-state.md` is the running session log.
- `checklists/` is for cross-session resume on multi-step work.

Without this structure, "what's LV doing right now" and "did LV finish what I asked yesterday" require git archaeology. With it, the answer is in a markdown file.

## Why contracts

The type IS the canonical API shape, so it lives in one place, `src/contracts/`, owned by CC:

1. CC defines/updates the contract file FIRST, and pushes it.
2. LV implements the endpoint to match. On TanStack Start, LV's server functions **import** the contract (`@/contracts/<name>`). On the older Vite + Edge Functions stack, Deno can't import it, so CC's prompt **pastes** it verbatim.
3. If LV needs to change the shape, LV flags it in its reply — CC updates the contract; the cycle repeats.

This is more disciplined than ad-hoc "the docs say the response has X" — the type IS the source.

## Why engineering discipline as a doc, not training

Every agent's system prompt has SOME version of "simplicity first" / "don't refactor adjacent code". But:

- Different models interpret these differently.
- Lovable's system prompt has its own opinions that may conflict.
- A new agent joining the project (Cursor, Copilot) hasn't been trained on YOUR specific calibration.

So we write the discipline down in `docs/standards/base.md` — four explicit sections (think before coding — in proportion to the task's tier, simplicity first, surgical changes, goal-driven execution) with per-agent adaptations. It survives model upgrades and tool swaps.

## Skills as runnable docs

Skills in `ai-specs/skills/` are not just docs — they're runbooks the agent loads automatically when a task description matches. Instead of "remember to update the contract before writing the LV prompt", there's a `lv-prompt-writer` skill that walks you through it.

The pattern was borrowed from [Superpowers](https://github.com/obra/superpowers) and adapted for our workflow.

## What this kit deliberately does NOT do

- **No hard Spec Kit dependency.** Spec Kit is the recommended spec layer (`specify init --here --integration claude`), and the `spec-lanes` skill makes its tasks lane-aware. Without it, LV prompts + contracts + CW briefs still serve as the spec layer.
- **No Jira / Linear / external tooling baked in.** Skills can call MCPs if you have them, but the core workflow runs on plain markdown files.
- **No npm package for the workflow itself.** The kit is files-in-a-folder. Run `bin/install.sh` once and you have everything. (A packaged installer may come later.)

## Acknowledgments

- [GitHub Spec Kit](https://github.com/github/spec-kit) (MIT) — the spec → plan → tasks layer.
- lidr-specboot by LIDR academy — origin of the `docs/standards/` shared-source-of-truth idea (repository no longer public).
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) — spec-driven workflow philosophy.
- [Superpowers](https://github.com/obra/superpowers) — skill-writing conventions.
