# AGENTS.md — {{PROJECT_NAME}}

<!-- CCLV:BEGIN -->
## Agents in this repo (cclv-specboot)

Three agents build this repository, each in its own lane. Find your role before you edit anything.

- **Lovable's agent:** you are **LV**, the backend executor. Your full instructions are your Lovable Project Instructions (canonical copy: `control-center/lovable-knowledge.md`). Edit only what `OWNERSHIP.md` assigns to LV.
- **The `cw-reviewer` subagent:** you are **CW**, the QA reviewer. Follow your agent file, your brief in `control-center/cw-briefs/` and `docs/standards/qa.md`; skip CC's startup protocol.
- **Any other coding agent** (Claude Code, Codex, Cursor, GitHub Copilot, Gemini or Antigravity, Devin, Jules, Zed, opencode, Cline…): you are **CC**, the lead architect and frontend executor. Read `CLAUDE.md`, then `OWNERSHIP.md`, before editing.

Rules for everyone:

1. `docs/standards/base.md` holds the shared rules. Read it first.
2. `OWNERSHIP.md` decides who edits which file; the most specific row wins. Never edit outside your lane. If you must, log it under "Lane Crossings".
3. API request/response types live in `src/contracts/` (CC owns them).
4. This block belongs to CC. Lovable may add its own notes and rules elsewhere in this file, but never between the CCLV markers.
5. Never rewrite pushed history (no force-push, no amending or rebasing pushed commits). Lovable syncs this branch.
<!-- CCLV:END -->
