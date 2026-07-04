# Design: v0.3.0 — Lovable MCP integration

**Date:** 2026-07-04
**Status:** Approved by Sir (design review in chat)

## Problem

The kit's workflow assumes a human courier: CC writes `lv-prompts/*.md`, Sir pastes them into Lovable's chat, LV writes `lv-responses/*.md` into the repo, Sir re-pastes Knowledge changes into Lovable's UI. Lovable now ships an official MCP server (`https://mcp.lovable.dev`) that lets CC talk to the Lovable agent directly: `send_message`/`get_message`, `get_diff`/`list_files`/`read_file`, `get/set_project_knowledge`, `query_database`, `deploy_project`, analytics.

## Decisions (settled in design review)

1. **MCP primary, paste fallback.** MCP is the documented default channel. Each touched skill keeps a short "No MCP?" fallback preserving today's paste flow. File artifacts (`lv-prompts/`, `lv-responses/`) are kept as the audit trail in both modes.
2. **CC writes the response reports.** LV is no longer required to write `lv-responses/*.md`; CC reads `get_message` + `get_diff` and distills the report itself (same template, new author). Paste-fallback users keep the old LV-writes-it rule.
3. **Guardrails — confirm deploys only.** CC uses `send_message`, read/inspect tools, knowledge tools, and read-only `SELECT` via `query_database` freely. CC must get Sir's explicit go-ahead before `deploy_project`, `create_project`, or any DDL/DML via `query_database`. Lane rule preserved: schema changes go through LV prompts; CC running DDL directly is a lane crossing even with permission.
4. **UBC stays in `docs/standards/base.md` §1–§4.** No `context/ubc.md`. Only material gap to close: add "Strong success criteria let you loop independently. Weak criteria require constant clarification." to §4.

## The new loop

1. CC writes contract + LV prompt file exactly as today.
2. CC sends the prompt via `send_message`, polls with `get_message`.
3. CC reads LV's reply and diff directly (`get_message` + `get_diff`). LV questions are answered in-chat via another `send_message`; only unresolvable blockers are filed to `lv-blockers/`.
4. CC writes the `lv-responses/` report itself. The LV prompt template drops "Response Report (MANDATORY)" in MCP mode.
5. Sir pulls; `scripts/verify-after-pull.sh` runs unchanged — git remains the code channel; MCP inspection does not replace the local verify gate.
6. kb-sync: `control-center/lovable-knowledge.md` stays canonical; CC pushes it via `set_project_knowledge` and verifies with `get_project_knowledge` (fallback: Sir re-pastes).

## Files touched

Template:
- `template/CLAUDE.md` — workflow loop update + new "Lovable MCP channel" section (tools, guardrails, fallback).
- `template/AGENTS.md` — response-report rule becomes conditional (MCP mode: CC writes it).
- `template/docs/standards/base.md` — §4 UBC gap line; §10 knowledge sync via MCP; blocker-flow note in §1.
- `template/control-center/workflow-guide.md` — loop diagram + worked example.
- `template/ai-specs/skills/lv-prompt-writer/SKILL.md` — send via MCP, poll; fallback paste.
- `template/ai-specs/skills/lv-response-reader/SKILL.md` — source is `get_message`/`get_diff`; CC authors the report; fallback reads LV-written file.
- `template/ai-specs/skills/kb-sync/SKILL.md` — `set_project_knowledge` instead of re-paste; fallback.
- `template/control-center/lv-prompts/TEMPLATE.md`, `lv-responses/TEMPLATE.md` — author/instruction adjustments.
- `template/control-center/lovable-knowledge.md` — sync mechanism line.

Repo docs:
- `README.md` — workflow description + status.
- `INSTALL.md` — Lovable MCP setup step (`claude mcp add --transport http lovable https://mcp.lovable.dev` or official plugin), verify with `/mcp`.
- `BOOTSTRAP-PROMPT.md` — MCP connect in preflight; note `create_project` option for greenfield.
- `CHANGELOG.md` — v0.3.0 entry.
- Any other Lovable-paste references found by grep (OWNERSHIP.md, standards, other skills) — updated only where they describe the LV courier flow. The "paste-prompt" install path (Path 2) is unrelated and stays.

## Out of scope

npm variant; analytics-driven workflows; Lovable connector/MCP-catalog management; changes to the CW/QA flow.
