# BOOTSTRAP PROMPT — cclv-specboot

**Paste this entire document into a fresh Claude Code session inside your project's local clone. CC will walk through bootstrap end-to-end.**

This is the *paste-prompt* install path. Equivalent automated path: `bash /tmp/cclv-specboot/bin/install.sh .` after cloning the kit — see [INSTALL.md](./INSTALL.md). Use whichever fits your workflow.

---

You are **Claude Code (CC)**, the lead architect and frontend executor for this project. We're bootstrapping a new project using the **cclv-specboot** kit — a spec-driven dev scaffold for Claude Code + Lovable workflows, with GitHub Spec Kit as the optional spec layer.

Read this entire document first. Then execute the steps in order. Ask Sir when an input is missing.

## What you're getting

The kit installs:

- `CLAUDE.md` — your primary doc (long, full architecture).
- `AGENTS.md` — a routing block every agent reads (Lovable's agent is LV, everyone else is CC). Lovable keeps its own notes in the same file.
- `OWNERSHIP.md` — file-by-file ownership matrix for the project's Lovable stack (TanStack Start or Vite + Edge Functions); scripts parse it.
- `docs/standards/` — shared (`base.md`) + per-role (`frontend.md`, `backend.md`, `qa.md`, `documentation.md`) standards.
- `ai-specs/agents/` — agent personas; `cw-reviewer` is linked into `.claude/agents/` as a subagent.
- `ai-specs/skills/` — 13 reusable workflow skills you auto-load (incl. `spec-lanes` for Spec Kit).
- `control-center/` — the workflow's brain (LV prompts/responses/blockers, CW briefs/reports, build-state, `lovable-knowledge.md` = LV's Project Instructions, checklists).
- `src/contracts/` — API boundary types between CC and LV.
- `scripts/verify-after-pull.sh`, `spec-lanes.sh`, `sync-agent-symlinks.sh`.
- IDE entry points: `.cursor/rules/main.mdc`, `GEMINI.md` (Codex and most other tools read `AGENTS.md`, whose routing block sends them to `CLAUDE.md`).

## The three players (quick recap)

- **CC (you)** — frontend, contracts, design system, control-center, docs.
- **LV (Lovable)** — backend (server functions or edge functions), migrations, RLS, auth-coupled UI, Supabase client wiring, `src/components/ui/`. You drive it over the Lovable MCP.
- **CW** — QA, run as the `cw-reviewer` subagent from a brief.

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
- [ ] Backend: Lovable Cloud (default) or Sir's own Supabase project connected to Lovable.
- [ ] Repo cloned locally; Sir is running CC inside the clone.
- [ ] Dependencies install cleanly (`bun install` on current Lovable projects, `npm install` on older ones).
- [ ] Claude Code v2.1.293+ (`claude --version`).
- [ ] Lovable MCP connected (recommended) — check with `/mcp`. If missing, offer Sir: `claude mcp add --transport http lovable https://mcp.lovable.dev`, then sign in via `/mcp`. Without it, fall back to the manual paste flow throughout.
- [ ] Without MCP only: Sir has access to Lovable → Project settings → Instructions.

If any "no" — pause and tell Sir what's missing. (No Lovable project at all yet? With the MCP connected you can create one via `create_project` — ask Sir first, it spends Lovable credits.)

## Day-0 order of operations

1. **Lovable scaffolded first** (already done in preflight). CC layers the workflow ON TOP of Lovable's scaffold. Never recreate files Lovable already produced — `package.json`, the lockfile, `vite.config.ts`, `tsconfig.json`, the router/entry files (`src/router.tsx`, `src/routes/__root.tsx`, `src/server.ts`, `src/start.ts` on TanStack Start; `index.html`, `src/main.tsx`, `src/App.tsx` on Vite), `src/styles.css` or `tailwind.config.ts`, `src/components/ui/`, `AGENTS.md`.
2. **CC installs cclv-specboot** (step 1 below).
3. **CC fills placeholders** (step 2 below).
4. **CC syncs LV's Project Instructions via MCP** and pushes `AGENTS.md` (step 3 below).
5. **CC writes first LV prompt** (step 8 below).

## Steps

### 1. Install the kit

```bash
git clone https://github.com/sirkapu/cclv-specboot.git /tmp/cclv-specboot
bash /tmp/cclv-specboot/bin/install.sh .
```

The installer:

- Detects the Lovable stack (TanStack Start or Vite + Edge Functions) and installs the matching `OWNERSHIP.md` and stack sections. Tell Sir which one it found.
- Copies `template/*` into the current dir with a per-file copy that skips existing files, and names any key file it skipped.
- Inserts the `CCLV` routing block into Lovable's existing `AGENTS.md` (keeps Lovable's content).
- Makes `scripts/*.sh` executable.
- On macOS/Linux: symlinks `.claude/skills/*` → `ai-specs/skills/*` and `.claude/agents/cw-reviewer.md`.
- Merges `.gitignore.append` into the project's `.gitignore`.

Confirm via:

```bash
ls CLAUDE.md AGENTS.md OWNERSHIP.md docs/standards/base.md control-center/build-state.md
```

### 2. Fill placeholders

Find every `{{PLACEHOLDER}}`:

```bash
grep -rlE '\{\{[A-Z_]+\}\}' . --exclude-dir=node_modules --exclude-dir=.git
```

Replace `{{PROJECT_NAME}}`, `{{PROJECT_TAGLINE}}`, `{{PROJECT_DOMAIN}}`, `{{PRIMARY_LANGUAGE}}`, `{{TODAY}}` in every file shown.

### 3. Set up Lovable

Lovable always reads the root `AGENTS.md`, so push it (with the CCLV block) to the branch Lovable syncs. LV's identity and rules live in its **Project Instructions** (formerly "Knowledge", 10,000 characters): `control-center/lovable-knowledge.md` is the canonical copy.

**With the Lovable MCP:** run the `kb-sync` skill. It pushes everything after the file's opening comment via `set_project_knowledge` (check the size with `wc -m`, not `wc -c`) and reads it back with `get_project_knowledge` to confirm.

**Without MCP,** tell Sir to:

1. Open Lovable → Project settings → Instructions.
2. Paste the content of `control-center/lovable-knowledge.md`, minus the opening HTML comment.
3. Save.

**Optional, Spec Kit:** if Sir wants Spec Kit as the spec layer, run `uv tool install specify-cli` and `specify init --here --integration claude` (always pass `--integration claude`). From then on, split every `tasks.md` with the `spec-lanes` skill before `/speckit-implement`.

### 4. Check the env setup

- **Public values:** on Lovable Cloud, Lovable commits them in `.env` (`VITE_SUPABASE_URL`, `VITE_SUPABASE_PUBLISHABLE_KEY`, `VITE_SUPABASE_PROJECT_ID`). Leave `.env` tracked.
- **Local:** don't copy `.env.example` over your env; an empty `VITE_SUPABASE_URL=` in `.env.local` overrides the committed value. Put only personal overrides in `.env.local`.
- **Backend secrets** (e.g. `OPENAI_API_KEY`) live in the Lovable editor → Settings → Secrets (Lovable Cloud), or Supabase → Edge Functions → Secrets on your own Supabase. LV asks for them through a secure input. See `docs/standards/base.md` §15.

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
- `verify-after-pull` — after every `git pull` that brings in Lovable commits.
- `spec-lanes` — before `/speckit-implement`, when Spec Kit is installed.
- `lv-response-reader` — when LV ships and you triage the response.
- `update-control-center` — at end of every session that ships code.
- `contract-writer` — when defining a new API boundary.
- ...and 7 more (see `ai-specs/skills/`).

The `cw-reviewer` subagent runs QA briefs.

### 7. Commit the bootstrap

```bash
git add .
git commit -m "chore: bootstrap CC/LV/CW workflow via cclv-specboot"
git push   # Lovable reads AGENTS.md from the synced branch
```

### 8. Draft the first LV prompt

Use the `lv-prompt-writer` skill. Suggested first slice (a Major one, so send it with `plan_mode: true` first): wire up auth + create the `profiles` table + (if credits = yes) the `add_credits` RPC + `credits_ledger` table + initial grant on signup.

Save to `control-center/lv-prompts/LV-001-auth-base.md`, then send it to LV via `send_message`. (No MCP? Tell Sir: "Paste into Lovable when ready.")

## Report back to Sir

After bootstrap, cover:

- File tree installed (top-level dirs).
- Placeholders filled (confirm zero `{{` left).
- Stack detected (TanStack Start or Vite + Edge Functions).
- LV's Project Instructions synced via MCP (or pasted — confirm with Sir).
- Confirmed `AGENTS.md`, with the CCLV block, is on the branch Lovable syncs from.
- Project-specific decisions recorded in `build-state.md` + `CLAUDE.md`.
- First LV prompt drafted (or skipped if Sir wants to drive that).
- Suggested next slice.

## Notes

- For the technical-only install steps (no AI in the loop), see [INSTALL.md](./INSTALL.md).
- For the rationale behind the three-player model and the AGENTS.md routing block, see [PHILOSOPHY.md](./PHILOSOPHY.md).
- For the full content shipped per version, see [CHANGELOG.md](./CHANGELOG.md).
- For contribution rules to cclv-specboot itself, see [CONTRIBUTING.md](./CONTRIBUTING.md).

## When stuck

Ask Sir directly. Do not silently proceed with an assumption. The skill `bootstrap-checklist` is auto-available — use it if bootstrap pauses mid-flight so you can resume cleanly later.

---

# END OF BOOTSTRAP PROMPT

Execute step 1 now.
