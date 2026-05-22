# Philosophy

## The problem

Multi-agent dev workflows have a coordination problem. If two AI agents share a repo, they tend to:

1. **Step on each other's files** — LV overwriting CC's component; CC editing LV's edge function.
2. **Drift in conventions** — one uses kebab-case, the other PascalCase.
3. **Lose context across sessions** — no persistent memory of what shipped, what's next.
4. **Block each other** — CC waits for LV; LV doesn't know what CC needs.

[lidr-specboot](https://github.com/LIDR-academy/lidr-specboot) solves part of this (shared standards via symlinked docs) but assumes **one agent**. Multi-agent multi-role needs more.

## The three-player model

This kit assumes three roles:

| Role | Tool | Owns |
|------|------|------|
| **CC** — Architect + frontend | Claude Code (local) | Frontend, contracts, docs, control-center |
| **LV** — Backend | Lovable (web UI) | Supabase edge functions, migrations, RLS, auth pages |
| **CW** — QA | Claude Cowork (or a 2nd Claude Code session) | Test plans, QA reports |

Each role has its own primary doc:
- **CC reads** `CLAUDE.md` first.
- **LV reads** `AGENTS.md` first.
- **CW reads** the CW brief CC writes for it, plus `OWNERSHIP.md`.

## Three sources of truth

| Source | Declares |
|--------|----------|
| `OWNERSHIP.md` | Who owns which files (lane boundaries). |
| `src/contracts/` | API shapes between CC and LV. |
| `docs/standards/base.md` | Cross-agent behavioral rules. |

Anything else is project-specific opinion that lives in `CLAUDE.md`, `AGENTS.md`, or per-role standards.

## Why not symlink CLAUDE.md = AGENTS.md (lidr's approach)?

lidr makes `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `codex.md` all point to the same source. Elegant for **single-developer-multi-tool**: one source, every tool finds it.

For **multi-role multi-agent**, it's wrong. CC and LV have different jobs. CC needs detailed frontend architecture; LV needs lane boundaries and Supabase patterns. Forcing them to read the same doc means each agent reads a lot of irrelevant content — which degrades attention on the relevant parts.

Our split:
- `CLAUDE.md` — long, CC-specific.
- `AGENTS.md` — short, LV-specific.
- Both **start with** "Read `docs/standards/base.md` first."

Shared standards in one file; role-specific docs layer on top. Two ~250-line agent docs beat one ~500-line doc both agents skim.

## Why control-center

The `control-center/` directory is the asynchronous communication channel between CC, LV, and CW:

- CC writes `lv-prompts/LV-[NAME].md` → LV reads, executes, writes `lv-responses/LV-[NAME]-response.md`.
- LV writes `lv-blockers/LV-[NAME]-blocker.md` when stuck → CC reads at the start of next session.
- CC writes `cw-briefs/CW-[NAME].md` → CW executes, writes `cw-reports/CW-[NAME]-report.md`.
- `build-state.md` is the running session log.
- `checklists/` is for cross-session resume on multi-step work.

Without this structure, "what's LV doing right now" and "did LV finish what I asked yesterday" require git archaeology. With it, the answer is in a markdown file.

## Why contracts

Lovable cannot import TypeScript types from `src/contracts/` (Deno isolation). But the type IS the canonical API shape. We solve this by:

1. CC defines/updates the contract file FIRST.
2. CC's LV prompt PASTES the contract type verbatim under `## Contract Types`.
3. LV implements the edge function to match.
4. If LV needs to change the shape, LV flags it in the response report — CC updates the contract; the cycle repeats.

This is more disciplined than ad-hoc "the docs say the response has X" — the type IS the source.

## Why engineering discipline as a doc, not training

Every agent's system prompt has SOME version of "simplicity first" / "don't refactor adjacent code". But:

- Different models interpret these differently.
- Lovable's system prompt has its own opinions that may conflict.
- A new agent joining the project (Cursor, Copilot) hasn't been trained on YOUR specific calibration.

So we write the discipline down in `docs/standards/base.md` — four explicit sections (ultrathink before coding, simplicity first, surgical changes, goal-driven execution) with per-agent adaptations. It survives model upgrades and tool swaps.

## Skills as runnable docs

Skills in `ai-specs/skills/` are not just docs — they're runbooks the agent loads automatically when a task description matches. Instead of "remember to update the contract before writing the LV prompt", there's a `lv-prompt-writer` skill that walks you through it.

The pattern was borrowed from [Superpowers](https://github.com/obra/superpowers) and adapted for our workflow.

## What this kit deliberately does NOT do

- **No OpenSpec dependency.** lidr-specboot integrates with OpenSpec's `/enrich-us`, `/ff`, `/apply` workflow. We adopt the spirit (spec before code) without the tool — our LV prompts + contracts + CW briefs already serve as the spec layer.
- **No Jira / Linear / external tooling baked in.** Skills can call MCPs if you have them, but the core workflow runs on plain markdown files.
- **No npm package for the workflow itself.** The kit is files-in-a-folder. Run `bin/install.sh` once and you have everything. (An npm package may come in Phase 2 for `npx cclv-specboot init`.)

## Acknowledgments

- [lidr-specboot](https://github.com/LIDR-academy/lidr-specboot) — origin of the multi-agent pattern + the `docs/standards/` shared-source-of-truth idea.
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) — spec-driven workflow philosophy.
- [Superpowers](https://github.com/obra/superpowers) — skill-writing conventions.
