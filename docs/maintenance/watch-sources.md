# Watch sources

What the `kit-refresh` workflow (`.claude/workflows/kit-refresh.js`) checks on every run. Machine checks come first: they decide which areas get researched at all. Edit this file to add or drop sources; the workflow reads it each time.

## Machine checks (cheap, deterministic)

| Area | Check | Compare against `last-refresh.md` |
|------|-------|-----------------------------------|
| spec-kit | `curl -s "https://api.github.com/repos/github/spec-kit/releases?per_page=10"` | Latest tag; any release notes since |
| claude-code | `curl -s "https://api.github.com/repos/anthropics/claude-code/releases?per_page=30"`, and `claude --version` | Latest version; entries mentioning AGENTS.md, CLAUDE.md, skills, subagents, effort, ultrathink, hooks, MCP, worktrees |
| claude-models | `curl -s https://api.anthropic.com/v1/models -H "x-api-key: $ANTHROPIC_API_KEY" -H "anthropic-version: 2023-06-01"` (only if the key is set); otherwise the models overview page | Model IDs, deprecations, retirement dates |
| lovable | The Lovable MCP tool list (`ToolSearch` query `+lovable`, schemas only; never call the tools) and https://docs.lovable.dev/changelog | Tool names, `send_message` / `get_message` / `respond_to_approval` semantics, changelog entries since |
| lovable-scaffold | Newest public commits by `gpt-engineer-app[bot]`: `curl -s "https://api.github.com/search/commits?q=author-email:159125892%2Bgpt-engineer-app%5Bbot%5D%40users.noreply.github.com&sort=committer-date&per_page=5"`, then one repo's `.lovable/project.json`, root file list and `AGENTS.md` | Template revision, layout, commit identity, Lovable's `AGENTS.md` block |
| agents-md | https://agents.md and the tool docs below | Tools that read `AGENTS.md`; changes to precedence or per-agent overrides |

## Docs to read when an area changed

**Claude**
- https://platform.claude.com/docs/en/about-claude/models/overview — lineup, IDs, aliases
- https://platform.claude.com/docs/en/about-claude/model-deprecations — retirements
- https://platform.claude.com/docs/en/build-with-claude/effort — effort levels
- https://www.anthropic.com/news

**Claude Code**
- https://code.claude.com/docs/en/model-config — aliases, default model, effort, `ultrathink`
- https://code.claude.com/docs/en/memory — CLAUDE.md / AGENTS.md loading, imports
- https://code.claude.com/docs/en/sub-agents — subagent frontmatter
- https://code.claude.com/docs/en/skills — skill discovery and frontmatter
- https://code.claude.com/docs/en/mcp, https://code.claude.com/docs/en/worktrees, https://code.claude.com/docs/en/hooks
- https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/CHANGELOG.md

**Lovable**
- https://docs.lovable.dev/integrations/lovable-mcp-server.md — MCP tools and pause semantics
- https://docs.lovable.dev/features/knowledge.md — Instructions, which repo files are always read
- https://docs.lovable.dev/integrations/github.md — sync, branches, `lovable-sync`, commit attribution
- https://docs.lovable.dev/features/skills.md — workspace skills
- https://docs.lovable.dev/changelog

**Spec Kit**
- https://github.com/github/spec-kit — README, `templates/commands/implement.md`, `templates/commands/tasks.md`
- https://github.github.io/spec-kit/ — presets, extensions, integrations/claude

**AGENTS.md ecosystem**
- https://agents.md
- Codex: https://developers.openai.com/codex/guides/agents-md
- Cursor: https://cursor.com/docs/context/rules
- GitHub Copilot: https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
- Gemini CLI / Antigravity, Devin, Zed (`https://zed.dev/docs/ai/instructions`), opencode (`https://opencode.ai/docs/rules/`)

**Supabase** (backend.md)
- https://supabase.com/changelog — API keys, Edge Functions, default grants
