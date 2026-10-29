# Contributing to cclv-specboot

Thanks for considering a contribution. The goal of this kit is to make CC + LV + CW workflows cleaner for everyone — your additions help.

## Project layout

- **`README.md`, `INSTALL.md`, `PHILOSOPHY.md`, `CHANGELOG.md`, `BOOTSTRAP-PROMPT.md`** — repo-level docs.
- **`CONTRIBUTING.md`** (this file).
- **`bin/install.sh`** — non-destructive installer (stack detection, AGENTS.md merge). **`VERSION`** — the kit version it stamps.
- **`stacks/<stack>/`** — per-Lovable-stack files: `OWNERSHIP.md`, plus `cc-stack.md` and `lv-lanes.md`, which the installer inserts into `CLAUDE.md` and `lovable-knowledge.md` at their `<!-- cclv:stack NAME -->` markers.
- **`template/`** — everything that gets copied into user projects:
  - `CLAUDE.md` (CC's doc), `AGENTS.md` (the CCLV routing block), `control-center/lovable-knowledge.md` (LV's Project Instructions).
  - `docs/standards/` — shared + per-role standards.
  - `ai-specs/agents/` — agent persona definitions.
  - `ai-specs/skills/` — reusable workflow skills.
  - `control-center/` — workflow templates.
  - `src/contracts/`, `scripts/` (`verify-after-pull.sh` and `spec-lanes.sh` share `scripts/lib/lanes.sh`, which parses `OWNERSHIP.md`), `.env.example`, etc.

## How to propose a change

1. Fork the repo.
2. Create a branch: `feat/<short-name>`, `fix/<short-name>`, `docs/<short-name>`.
3. Make the change. Follow the engineering discipline in `template/docs/standards/base.md` — this repo dogfoods its own standards.
4. Update `CHANGELOG.md` under the next unreleased version.
5. Open a PR using the template (`.github/PULL_REQUEST_TEMPLATE.md` fills automatically).

## Adding a new skill

A skill lives at `template/ai-specs/skills/<skill-name>/SKILL.md`. Format:

```markdown
---
name: <kebab-case>
description: <one-line summary — used for auto-matching against user requests>
applies_to: [CC] | [LV] | [CW] | [CC, LV, CW]
author: <name>
version: 0.1.0
---

# <skill-name>

## When to use
[clear trigger conditions]

## Procedure
[numbered steps]

## Checklist
- [ ] Item 1
- [ ] Item 2
```

After adding:

- Bump `CHANGELOG.md` under the next version.
- If it changes how a workflow operates, mention in `README.md`.

## Adding a new standard

Standards live in `template/docs/standards/`. Edit the relevant file (`base.md`, `frontend.md`, `backend.md`, `qa.md`, `documentation.md`) or create a new one.

- Keep each under 400 lines; split if larger.
- Test against the existing skills — if a skill references the standard, make sure it still works after the change.
- If you change `base.md`, double-check `CLAUDE.md` and `lovable-knowledge.md` aren't restating the rule differently (drift risk).
- If you change an `OWNERSHIP.md` row format, run `scripts/spec-lanes.sh` and `verify-after-pull.sh` against a test repo: both parse the table.

## Adding multi-IDE support

Most coding agents (Codex, Cursor, Copilot, Antigravity, Devin, Jules, Zed, opencode, Cline) already read the root `AGENTS.md`, and its CCLV block routes every non-Lovable agent to `CLAUDE.md`. Usually that's enough.

Add a tool-specific entry file only when a tool doesn't read `AGENTS.md` at all, using a filename the tool really loads (check its docs: no tool reads `codex.md`, which is why it was removed):

1. Create a thin pointer file at `template/<filename>` pointing to `CLAUDE.md` as the primary doc.
2. Mirror the structure of the existing entry files (`GEMINI.md`, `.cursor/rules/main.mdc`).
3. The rule: Lovable's agent is LV; every other agent plays CC and reads `CLAUDE.md`. Never put a role identity in `AGENTS.md` outside the routing block.
4. Many tools merge every instruction file they find, so an entry file must agree with the routing block, never contradict it.

## Style

- All content in English.
- Markdown only; no HTML except in special cases.
- File size ceilings (dogfooded — these apply to this repo's own files):
  - Standards: under 400 lines.
  - Skills: under 200 lines.
  - Templates: under 200 lines.
  - Repo-level docs: pragmatic, but split if over 500.
- Tone: direct, no fluff, no marketing language.
- Lists over paragraphs where possible.

## Versioning

Semver. Bump in `CHANGELOG.md`:

- **PATCH** (`0.X.Y`): bug fixes, doc clarifications, small additions to existing files.
- **MINOR** (`0.X.0`): new skills, new standards, new templates, multi-IDE support additions.
- **MAJOR** (`X.0.0`): breaking changes to the workflow model (new player added, ownership matrix restructured).

## Testing (manual)

This kit doesn't have automated tests yet. Verify manually:

1. Run `bin/install.sh /tmp/test-project` against a fresh empty directory (expect stack `tanstack-start`), then against a directory with a Lovable-style `AGENTS.md` (expect the CCLV block inserted after `LOVABLE:END`) and a Vite project (expect `vite-edge`).
2. Confirm all files copied and no `<!-- cclv:stack` markers remain in `CLAUDE.md` or `control-center/lovable-knowledge.md`.
3. Confirm `.claude/skills/` and `.claude/agents/cw-reviewer.md` symlinks created (macOS/Linux).
4. Confirm `.gitignore.append` merged into `.gitignore`.
5. Re-run the installer on the same directory: no second CCLV block, nothing overwritten.
6. Check LV's Project Instructions stay under 10,000 characters: `awk 'c==0 && /-->/ {c=1; next} c==1' control-center/lovable-knowledge.md | wc -m`.
7. Run the scripts with macOS's `/bin/bash` (3.2): `bash -n` on each, plus `scripts/spec-lanes.sh` on a sample `tasks.md`.
8. Lane lookups: `source template/scripts/lib/lanes.sh; lanes_load stacks/tanstack-start/OWNERSHIP.md; lane_owner <path>` must give LV for `src/components/x/y.functions.ts` and `src/routes/a.server.ts` (file-kind rows beat folder rows), CC for `src/routes/authors.tsx`, LV for `src/routes/auth.callback.tsx`.

For doc changes, also `grep -rn "<file-you-changed>"` to catch broken cross-references.

## Releases

Before a release (and at least monthly), run the `kit-refresh` workflow (`.claude/workflows/kit-refresh.js`; ask Claude Code to "run the kit-refresh workflow"). It checks Spec Kit, Claude models, Claude Code, Lovable and the AGENTS.md ecosystem against `docs/maintenance/last-refresh.md`, researches only what changed, and writes `docs/maintenance/refresh-<date>.md` with proposed edits.

After merging to `main`:

1. Bump `VERSION` and confirm `CHANGELOG.md` reflects all changes since the last version.
2. Tag: `git tag v0.X.Y && git push origin v0.X.Y`.
3. Create a GitHub release with the CHANGELOG section pasted into the description.

## Code of conduct

Be respectful. The point of this kit is to reduce friction; let's not introduce social friction in the process.

## Questions

Open an issue. Tag with `question` if you're not sure whether your idea fits.
