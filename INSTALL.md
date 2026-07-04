# Installing cclv-specboot into a project

## Prerequisites

Before running install, your project must have:

1. **Lovable project** created and connected to a GitHub repo.
2. **Supabase project** wired to Lovable (project URL + anon key set in Lovable's env vars).
3. **Local clone** of the GitHub repo.
4. `npm install` runs cleanly inside the clone.
5. **Lovable MCP** connected in Claude Code (recommended — step 4 below). Without it, you'll need access to **Lovable → Project Settings → Knowledge** to paste content manually.

If any of these is missing, stop and fix it first. The install script assumes a working Lovable+Supabase+GitHub triangle.

## Install steps

### 1. Clone cclv-specboot

```bash
git clone https://github.com/YOUR_ORG/cclv-specboot.git /tmp/cclv-specboot
```

### 2. Run the installer

```bash
bash /tmp/cclv-specboot/bin/install.sh /path/to/your/project
```

What it does:
- Copies `template/*` into your project (non-destructive — `cp -rn`, won't overwrite existing files).
- Makes `scripts/*.sh` executable.
- Sets up `.claude/skills/` symlinks pointing to `ai-specs/skills/*` (macOS/Linux only — see Cross-platform below).
- Merges `.gitignore.append` into the project's `.gitignore` (created if absent).

### 3. Fill placeholders

Open these files and replace `{{...}}` placeholders:
- `CLAUDE.md`
- `AGENTS.md`
- `OWNERSHIP.md` (review the matrix; adjust if your project structure differs)
- `control-center/lovable-knowledge.md` (Phase 2 template)
- `control-center/build-state.md` (Phase 2 template)

Find every placeholder:
```bash
grep -rln '{{' . | grep -v node_modules | grep -v .git
```

### 4. Connect the Lovable MCP (recommended)

Gives CC a direct line to Lovable: send LV prompts (`send_message`), read diffs (`get_diff`), sync Knowledge (`set_project_knowledge`), and more.

```bash
claude mcp add --transport http lovable https://mcp.lovable.dev
```

Restart Claude Code, verify with `/mcp` — a browser OAuth window opens on first tool call. Skipping this is fine: the kit falls back to the manual paste flow everywhere.

### 5. Set up Lovable Knowledge

**With MCP:** ask CC to run the `kb-sync` skill — it pushes `control-center/lovable-knowledge.md` via `set_project_knowledge` and verifies the readback.

**Without MCP:**

1. Open Lovable → Project Settings → Knowledge.
2. Paste the full content of `control-center/lovable-knowledge.md`.
3. Save.

### 6. Pin canonical files in Lovable

In Lovable's project settings, pin these so LV reads them on every prompt:
- `OWNERSHIP.md`
- `AGENTS.md`

### 7. Verify

```bash
cd /path/to/your/project
bash scripts/verify-after-pull.sh
```

If everything's wired correctly: no lane-crossing warnings, `npm run build` passes.

## Cross-platform notes

- **macOS / Linux:** symlinks for `.claude/skills/` are created automatically.
- **Windows:** symlinks require admin privileges or developer mode. The installer skips them. Either enable developer mode (`Settings → Privacy & Security → For developers`) or copy `ai-specs/skills/*` into `.claude/skills/*` manually.

## Updating cclv-specboot in an existing project

Re-running `bin/install.sh` is safe — it never overwrites existing files. To pull updated templates:

1. **For a specific file:** delete it locally, then re-run install.
2. **For a broader refresh:** `diff` your project against the latest `template/` and merge manually.

See [CHANGELOG.md](./CHANGELOG.md) for breaking changes between versions.

## Uninstall

```bash
# There is no automated uninstall. To remove specboot from a project:
rm -rf .claude/skills ai-specs control-center docs/standards
rm CLAUDE.md AGENTS.md OWNERSHIP.md
# Then manually remove any other template-installed files.
```

Don't do this casually — these files contain accumulated project state (LV prompts, build-state, etc.).
