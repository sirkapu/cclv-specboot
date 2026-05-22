# Installing cclv-specboot into a project

## Prerequisites

Before running install, your project must have:

1. **Lovable project** created and connected to a GitHub repo.
2. **Supabase project** wired to Lovable (project URL + anon key set in Lovable's env vars).
3. **Local clone** of the GitHub repo.
4. `npm install` runs cleanly inside the clone.
5. Access to **Lovable → Project Settings → Knowledge** (to paste content into).

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

### 3. Fill placeholders

Open these files and replace `{{...}}` placeholders:
- `CLAUDE.md`
- `AGENTS.md`
- `OWNERSHIP.md` (review the matrix; adjust if your project structure differs)
- `control-center/lovable-knowledge.md` (Phase 2 template)
- `control-center/build-state.md` (Phase 2 template)

Find every placeholder:
```bash
grep -rn "{{" CLAUDE.md AGENTS.md OWNERSHIP.md docs/standards/
```

### 4. Set up Lovable Knowledge

1. Open Lovable → Project Settings → Knowledge.
2. Paste the full content of `control-center/lovable-knowledge.md`.
3. Save.

### 5. Pin canonical files in Lovable

In Lovable's project settings, pin these so LV reads them on every prompt:
- `OWNERSHIP.md`
- `AGENTS.md`

### 6. Verify

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
