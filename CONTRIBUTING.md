# Contributing to cclv-specboot

Thanks for considering a contribution. The goal of this kit is to make CC + LV + CW workflows cleaner for everyone — your additions help.

## Project layout

- **`README.md`, `INSTALL.md`, `PHILOSOPHY.md`, `CHANGELOG.md`, `BOOTSTRAP-PROMPT.md`** — repo-level docs.
- **`CONTRIBUTING.md`** (this file).
- **`bin/install.sh`** — non-destructive installer.
- **`template/`** — everything that gets copied into user projects:
  - `CLAUDE.md`, `AGENTS.md`, `OWNERSHIP.md` — agent primary docs.
  - `docs/standards/` — shared + per-role standards.
  - `ai-specs/agents/` — agent persona definitions.
  - `ai-specs/skills/` — reusable workflow skills.
  - `control-center/` — workflow templates.
  - `src/contracts/`, `scripts/`, `.env.example`, etc.

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
- If you change `base.md`, double-check `CLAUDE.md` / `AGENTS.md` aren't restating the rule differently (drift risk).

## Adding multi-IDE support

To add a new IDE entry point (e.g. `aider.md`, `windsurf.md`):

1. Create a thin pointer file at `template/<filename>` pointing to `CLAUDE.md` as the primary doc.
2. Mirror the structure of existing entry files (`codex.md`, `GEMINI.md`, `.cursor/rules/main.mdc`).
3. The rule: any local-IDE agent plays the CC role and reads `CLAUDE.md`. Only Lovable reads `AGENTS.md`.

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

1. Run `bin/install.sh /tmp/test-project` against a fresh empty directory.
2. Confirm all files copied.
3. Confirm `.claude/skills/` symlinks created (macOS/Linux).
4. Confirm `.gitignore.append` merged into `.gitignore`.
5. Open `template/CLAUDE.md` in the test project and confirm `{{PLACEHOLDERS}}` still need filling.

For doc changes, also `grep -rn "<file-you-changed>"` to catch broken cross-references.

## Releases

After merging to `main`:

1. Confirm `CHANGELOG.md` reflects all changes since the last version.
2. Tag: `git tag v0.X.Y && git push origin v0.X.Y`.
3. Create a GitHub release with the CHANGELOG section pasted into the description.

## Code of conduct

Be respectful. The point of this kit is to reduce friction; let's not introduce social friction in the process.

## Questions

Open an issue. Tag with `question` if you're not sure whether your idea fits.
