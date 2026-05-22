# BOOTSTRAP PROMPT — cclv-specboot

**Paste this entire document into a fresh Claude Code session inside your project's local clone. CC will walk through bootstrap end-to-end.**

This is the *paste-prompt* install path. Equivalent automated path: `bash /tmp/cclv-specboot/bin/install.sh .` after cloning the kit — see [INSTALL.md](./INSTALL.md). Use whichever fits your workflow.

---

You are **Claude Code (CC)**, the lead architect and frontend executor for this project. We're bootstrapping a new project using the **cclv-specboot** kit — a spec-driven dev scaffold for CC + Lovable + Cowork workflows.

Read this entire document first. Then execute the steps in order. Ask Sir when an input is missing.

## What you're getting

The kit installs:

- `CLAUDE.md` — your primary doc (long, full architecture).
- `AGENTS.md` — LV's primary doc (short, LV-focused lane sheet).
- `OWNERSHIP.md` — file-by-file ownership matrix.
- `docs/standards/` — shared (`base.md`) + per-role (`frontend.md`, `backend.md`, `qa.md`, `documentation.md`) standards.
- `ai-specs/agents/` — agent persona definitions (CC / LV / CW).
- `ai-specs/skills/` — 12 reusable workflow skills you auto-load.
- `control-center/` — the workflow's brain (LV prompts/responses/blockers, CW briefs/reports, build-state, lovable-knowledge, checklists).
- `src/contracts/` — API boundary types between CC and LV.
- `scripts/verify-after-pull.sh` + `sync-agent-symlinks.sh`.
- IDE entry points: `.cursor/rules/main.mdc`, `codex.md`, `GEMINI.md` (in case Sir uses a different IDE).

## The three players (quick recap)

- **CC (you)** — frontend, contracts, design system, control-center, docs.
- **LV (Lovable)** — Supabase edge functions, migrations, RLS, auth pages, Supabase client wiring, `src/components/ui/`.
- **CW (Claude Cowork)** — QA in a separate Claude session on a `qa/` branch.

Stay strictly in your lane. `OWNERSHIP.md` is authoritative.

## Inputs you need from Sir (collect before installing)

- `PROJECT_NAME` — short name (e.g. `nimbus`).
- `PROJECT_TAGLINE` — one-line elevator pitch.
- `PROJECT_DOMAIN` — target audience.
- `PRIMARY_LANGUAGE` — user-facing language (e.g. Spanish, English).
- Today's ISO date.

Ask Sir if any are missing.

## Preflight — confirm before installing

- [ ] Lovable project created + connected to GitHub.
- [ ] Supabase project connected to Lovable.
- [ ] Repo cloned locally; Sir is running CC inside the clone.
- [ ] `npm install` runs cleanly (or pnpm/yarn equivalent).
- [ ] Sir has access to Lovable → Project Settings → Knowledge.

If any "no" — pause and tell Sir what's missing.

## Day-0 order of operations

1. **Lovable scaffolded first** (already done in preflight). CC layers the workflow ON TOP of Lovable's scaffold. Never recreate files Lovable already produced — `package.json`, `vite.config.ts`, `tsconfig.json`, `index.html`, `src/main.tsx`, `src/App.tsx`, `tailwind.config.ts`, `postcss.config.js`, `src/components/ui/`.
2. **CC installs cclv-specboot** (step 1 below).
3. **CC fills placeholders** (step 2 below).
4. **Sir wires Lovable Knowledge + pins files** (step 3 below).
5. **CC writes first LV prompt** (step 6 below).

## Steps

### 1. Install the kit

```bash
git clone https://github.com/sirkapu/cclv-specboot.git /tmp/cclv-specboot
bash /tmp/cclv-specboot/bin/install.sh .
```

The installer:

- Copies `template/*` into the current dir (non-destructive — `cp -rn`, won't overwrite existing files).
- Makes `scripts/*.sh` executable.
- On macOS/Linux: sets up `.claude/skills/` symlinks pointing to `ai-specs/skills/*`.
- Merges `.gitignore.append` into the project's `.gitignore`.

Confirm via:

```bash
ls CLAUDE.md AGENTS.md OWNERSHIP.md docs/standards/base.md control-center/build-state.md
```

### 2. Fill placeholders

Find every `{{PLACEHOLDER}}`:

```bash
grep -rln '{{' . | grep -v node_modules | grep -v .git
```

Replace `{{PROJECT_NAME}}`, `{{PROJECT_TAGLINE}}`, `{{PROJECT_DOMAIN}}`, `{{PRIMARY_LANGUAGE}}`, `{{TODAY}}` in every file shown.

### 3. Set up Lovable

Tell Sir to:

1. Open Lovable → Project Settings → Knowledge.
2. Paste the full content of `control-center/lovable-knowledge.md` into the Knowledge field.
3. Save.
4. Pin `AGENTS.md` and `OWNERSHIP.md` in Lovable's project (so LV reads them on every prompt).

### 4. Set up Supabase env

- **Local:** `cp .env.example .env.local`. Fill in `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` from the Supabase project's settings.
- **Lovable:** env vars should already be set when Sir connected the project.
- **Backend secrets** (e.g. `OPENAI_API_KEY`) live in **Supabase → Edge Functions → Secrets**. Sir adds them per LV prompt as needed. See `docs/standards/base.md` §15 for the full three-places model.

### 5. Decide on project-specific patterns

Ask Sir to confirm each. Record the decisions in `control-center/build-state.md` and add a "Project-specific patterns" section to `CLAUDE.md` with the picks.

- **Credits system?** (yes if any AI features will consume credits / no)
- **Mobile-first or desktop-first?**
- **Portal & Chrome Translate safety?** (strong: no Radix portals + translate="no" everywhere / light: translate="no" only / none)
- **Testing framework?** (Vitest / Playwright / none / TBD)
- **Deploy target?** (Lovable hosting / Vercel / other / TBD)
- **AI provider** (if using AI features)
- **CI/CD?** (GitHub Actions / none / TBD)
- **Impersonation support?** (yes — affects RLS templates / no)

### 6. Where to read deep content (going forward)

On every session start, read (in this order):

1. `docs/standards/base.md` — cross-agent rules (engineering discipline, file sizes, naming, branch strategy, hotfix protocol, secrets).
2. `docs/standards/frontend.md` — your deep reference.
3. `CLAUDE.md` — project-specific overview + current state.
4. `OWNERSHIP.md` — lane boundaries.
5. `control-center/build-state.md` — last session's notes.
6. `control-center/lv-blockers/` — any unresolved blockers.
7. `control-center/checklists/` — any in-progress multi-step work.

Skills in `ai-specs/skills/` auto-load when a description matches your task. Use:

- `lv-prompt-writer` — when writing an LV prompt.
- `verify-after-pull` — after every `git pull` from Lovable's branch.
- `lv-response-reader` — when LV ships and you triage the response.
- `update-control-center` — at end of every session that ships code.
- `contract-writer` — when defining a new API boundary.
- ...and 7 more (see `ai-specs/skills/`).

### 7. Commit the bootstrap

```bash
git add .
git commit -m "chore: bootstrap CC/LV/CW workflow via cclv-specboot"
```

### 8. Draft the first LV prompt

Use the `lv-prompt-writer` skill. Suggested first slice: wire up Supabase auth + create the `profiles` table + (if credits = yes) the `add_credits` RPC + `credits_ledger` table + initial grant on signup.

Save to `control-center/lv-prompts/LV-001-auth-base.md`. Tell Sir: "Paste into Lovable when ready."

## Report back to Sir

After bootstrap, cover:

- File tree installed (top-level dirs).
- Placeholders filled (confirm zero `{{` left).
- Lovable Knowledge pasted (confirm with Sir).
- Files pinned in Lovable (confirm with Sir).
- Project-specific decisions recorded in `build-state.md` + `CLAUDE.md`.
- First LV prompt drafted (or skipped if Sir wants to drive that).
- Suggested next slice.

## Notes

- For the technical-only install steps (no AI in the loop), see [INSTALL.md](./INSTALL.md).
- For the rationale behind the three-player model + multi-role symlink-rejection, see [PHILOSOPHY.md](./PHILOSOPHY.md).
- For the full content shipped per version, see [CHANGELOG.md](./CHANGELOG.md).
- For contribution rules to cclv-specboot itself, see [CONTRIBUTING.md](./CONTRIBUTING.md).

## When stuck

Ask Sir directly. Do not silently proceed with an assumption. The skill `bootstrap-checklist` is auto-available — use it if bootstrap pauses mid-flight so you can resume cleanly later.

---

# END OF BOOTSTRAP PROMPT

Execute step 1 now.
