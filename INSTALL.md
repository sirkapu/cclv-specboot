# Installing cclv-specboot into a project

## Prerequisites

Before running install, your project must have:

1. **Lovable project** created and connected to a GitHub repo (Project settings → Git).
2. **A backend:** Lovable Cloud (the default; enabled automatically when a feature needs it) or your own Supabase project connected to Lovable.
3. **Local clone** of the GitHub repo, with dependencies installed (`bun install` on current Lovable projects, `npm install` on older ones).
4. **Claude Code v2.1.293+** (the `opus`/`sonnet`/`haiku` aliases resolve to the 5.5 models from there; v2.1.311+ for `ultrathink` raising a turn to `xhigh`). Check with `claude --version`.
5. **Lovable MCP** connected in Claude Code (recommended — step 4 below). Without it, you'll need access to **Lovable → Project settings → Instructions** to paste content manually.
6. Optional: **Python 3.11+ and [uv](https://docs.astral.sh/uv/)** if you want Spec Kit as the spec layer (step 6).

If any of the required items is missing, stop and fix it first.

## Install steps

### 1. Clone cclv-specboot

```bash
git clone https://github.com/sirkapu/cclv-specboot.git /tmp/cclv-specboot
```

### 2. Run the installer

```bash
bash /tmp/cclv-specboot/bin/install.sh /path/to/your/project
# or force a stack: bash /tmp/cclv-specboot/bin/install.sh --stack vite-edge /path/to/your/project
```

What it does:
- **Detects the Lovable stack** (see [stacks/README.md](./stacks/README.md)): `tanstack-start` (Lovable's default since 2026-05-13, and the fallback for an empty project) or `vite-edge` (older React + Vite projects with Supabase Edge Functions). The stack decides `OWNERSHIP.md` and the stack sections inserted into `CLAUDE.md` and `control-center/lovable-knowledge.md`.
- Copies `template/*` into your project with a per-file copy that **skips existing files** and reports counts. It names any key file it skipped (`CLAUDE.md`, `OWNERSHIP.md`, `lovable-knowledge.md`) so you can merge by hand.
- **Merges into `AGENTS.md`** instead of skipping it: Lovable projects ship their own `AGENTS.md`, so the installer inserts the `CCLV` routing block after Lovable's `LOVABLE:END` marker (or at the top) and keeps everything else. Re-running never adds a second block.
- Makes `scripts/*.sh` executable.
- Symlinks `.claude/skills/*` → `ai-specs/skills/*` and `.claude/agents/cw-reviewer.md` → `ai-specs/agents/cw-reviewer.md` (macOS/Linux only — see Cross-platform below).
- Merges `.gitignore.append` into the project's `.gitignore` (created if absent). `.env` stays tracked: Lovable Cloud commits public values there.
- Writes the kit version to `.cclv-specboot-version`.

### 3. Fill placeholders

Find every placeholder and replace it:

```bash
grep -rlE '\{\{[A-Z_]+\}\}' . --exclude-dir=node_modules --exclude-dir=.git
```

They live in `CLAUDE.md`, `AGENTS.md`, `OWNERSHIP.md`, `.env.example`, `control-center/` (`lovable-knowledge.md`, `build-state.md`, `architecture.md`, `roadmap.md`, `workflow-guide.md`, `cw-briefs/TEMPLATE.md`) and the `using-git-worktrees` skill. Review `OWNERSHIP.md` against your project's real layout; on TanStack Start, confirm the auth-screen row matches your route names.

### 4. Connect the Lovable MCP (recommended)

Gives CC a direct line to Lovable: send LV prompts (`send_message`, with `plan_mode` for planning), answer approval pauses with your decision (`respond_to_approval`), read diffs (`get_diff`, `list_edits`), sync LV's instructions (`set_project_knowledge`), and more.

```bash
claude mcp add --transport http lovable https://mcp.lovable.dev
```

Verify with `/mcp`; sign in when prompted (or `claude mcp login lovable`). Skipping this is fine: the kit falls back to the manual paste flow (see `control-center/workflow-guide.md`).

### 5. Set up LV's Project Instructions

`control-center/lovable-knowledge.md` is LV's identity and lane sheet. Lovable calls this field **Instructions** (formerly "Knowledge"), capped at 10,000 characters per project.

**With MCP:** ask CC to run the `kb-sync` skill. It pushes everything after the file's opening comment via `set_project_knowledge` and verifies the readback.

**Without MCP:**

1. Open Lovable → Project settings → Instructions.
2. Paste the content of `control-center/lovable-knowledge.md`, minus the opening HTML comment.
3. Save.

### 6. Optional: add Spec Kit as the spec layer

```bash
uv tool install specify-cli
cd /path/to/your/project
specify init --here --integration claude
```

Always pass `--integration claude`: a non-interactive `specify init` defaults to GitHub Copilot. A plain init writes `.specify/` (constitution at `.specify/memory/constitution.md`) and `/speckit-*` skills under `.claude/skills/speckit-*/`. It doesn't touch `CLAUDE.md` or `AGENTS.md` and doesn't create branches. Keep its opt-in git extension off, since Lovable syncs a single branch.

Then plan features with `/speckit-specify` → `/speckit-plan` → `/speckit-tasks`, and **split the tasks before implementing**: `bash scripts/spec-lanes.sh` (spec-lanes skill). Stock `/speckit-implement` would also build Lovable's backend tasks.

### 7. How Lovable reads your repo (nothing to pin)

Lovable has no "pin" or attach-file feature. Its docs guarantee that the root **`AGENTS.md` is "always read by the Lovable agent regardless of session length"**. `CLAUDE.md` is something Lovable "also looks at", with no such guarantee. Its Project Instructions and Workspace instructions (10,000 characters each) are included in every message.

So the kit puts:
- **Routing** in `AGENTS.md`: the CCLV block tells Lovable's agent it is LV, and every other agent that it is CC. Push it to the branch Lovable syncs.
- **LV's identity and rules** in Project Instructions (step 5).
- **File boundaries** in `OWNERSHIP.md`, referenced from all of them.

Optional: task-specific instructions can ship as **Lovable Skills**. Anything under `ai-specs/skills/` can be imported as a workspace skill (from a public GitHub URL containing a `SKILL.md`, or via the MCP `create_workspace_skill` tool, admins/owners only). A GitHub import is a one-time copy, and workspace skills apply to **every project in the workspace**, so use them sparingly.

### 8. Verify (after your first pull from Lovable)

Commit and push the install, send LV its first prompt, then pull what it ships and run:

```bash
cd /path/to/your/project
bash scripts/verify-after-pull.sh
```

It audits what that pull brought in (`ORIG_HEAD..HEAD`). Don't run it on a fresh clone before any pull: it would audit Lovable's last pre-kit commit against the new lanes and flag UI work that was legitimate at the time. If everything's wired correctly: no lane-crossing warnings, and lint + build pass. Run it after every pull that brings in Lovable commits.

## Cross-platform notes

- **macOS / Linux:** symlinks for `.claude/skills/` and `.claude/agents/` are created automatically. The scripts run on macOS's stock bash 3.2.
- **Windows:** symlinks require admin privileges or developer mode. The installer skips them. Either enable developer mode (`Settings → Privacy & Security → For developers`) or copy `ai-specs/skills/*` into `.claude/skills/*` and `ai-specs/agents/cw-reviewer.md` into `.claude/agents/` manually.

## Updating cclv-specboot in an existing project

Re-running `bin/install.sh` is safe — it never overwrites existing files, and adds the `CCLV` block to `AGENTS.md` only if it's missing. To pull updated templates:

1. **For a specific file:** delete it locally, then re-run install.
2. **For a broader refresh:** `diff` your project against the latest `template/` and `stacks/<stack>/`, and merge manually.

`.cclv-specboot-version` shows which version a project was installed with. See [CHANGELOG.md](./CHANGELOG.md) for breaking changes and migration notes between versions.

## Uninstall

There is no automated uninstall. Remove only what the kit added; don't `rm -rf .claude/skills`, which also holds Spec Kit's and your own skills.

```bash
# Kit symlinks only (they point into ai-specs/):
find .claude/skills .claude/agents -maxdepth 1 -type l -lname '../../ai-specs/*' -delete
rm -rf ai-specs control-center docs/standards src/contracts/README.md
rm -f CLAUDE.md OWNERSHIP.md GEMINI.md .cursor/rules/main.mdc .env.example .cclv-specboot-version
rm -f scripts/verify-after-pull.sh scripts/spec-lanes.sh scripts/sync-agent-symlinks.sh scripts/lib/lanes.sh
# AGENTS.md: delete the lines from <!-- CCLV:BEGIN --> to <!-- CCLV:END --> and keep Lovable's content.
```

Don't do this casually — these files contain accumulated project state (LV prompts, build-state, etc.).
