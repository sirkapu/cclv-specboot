---
name: documentation-standards
description: How CC keeps docs current. Covers Lovable Knowledge sync, control-center sync, KB conventions.
applies_to: [CC]
---

# Documentation Standards

Rules for keeping project documentation current. CC owns docs; LV/CW read them.

## 1. The four kinds of doc

| Kind | Where | Updates trigger |
|------|-------|-----------------|
| **Agent docs** | `CLAUDE.md`, `AGENTS.md` | Architecture, tech stack, ownership changes |
| **Standards** | `docs/standards/*.md` | Pattern changes; new conventions |
| **Project state** | `control-center/build-state.md`, `architecture.md`, `roadmap.md` | Every session that ships code |
| **Lovable Knowledge** | `control-center/lovable-knowledge.md` + Lovable UI | LV's mental model needs to shift |

## 2. Lovable Knowledge sync protocol

Lovable's Knowledge field (Project Settings → Knowledge, 10,000 char limit) is read on every LV prompt. The repo file `control-center/lovable-knowledge.md` is the canonical version.

**They do NOT auto-sync.** Lovable reads its own UI field. The repo file is the audit trail.

When you update `control-center/lovable-knowledge.md`:

1. Commit the change.
2. In the same session, push it via the Lovable MCP (`set_project_knowledge`) and confirm with `get_project_knowledge`. No MCP? Tell Sir: **"Re-paste `control-center/lovable-knowledge.md` into Lovable → Settings → Knowledge."**
3. Record in `build-state.md`: "Knowledge updated — synced via MCP" (or "— Sir to re-paste").

If the sync doesn't happen, LV operates on stale context. This is a quiet bug. Always surface.

### When to update Knowledge

- New pattern LV needs to know (e.g. "all AI endpoints now use the `_shared/llm-client.ts` utility").
- New file LV owns (e.g. "you now also own `src/lib/translations/`").
- Conflict resolution (e.g. "if AGENTS.md and CLAUDE.md disagree, AGENTS.md wins").
- Stack change (e.g. "we switched from Tailwind to UnoCSS").

### When NOT to update Knowledge

- Per-feature details (those go in the LV prompt itself).
- Project state ("we're in Phase 3" — that's `build-state.md`).
- Reminders about rules already in `base.md` (Knowledge points to base.md instead).

## 3. Control-center sync protocol

After any session that ships meaningful code, run this checklist:

1. **`build-state.md`** — append a session entry: date, what shipped, commits, next-up.
2. **`architecture.md`** — update if routes, data models, contracts, or edge function inventory changed.
3. **`roadmap.md`** — check off completed items; flag blockers.
4. **`lovable-knowledge.md`** — update if LV's mental model needs to shift (see §2).
5. **`OWNERSHIP.md`** — add rows for any new top-level paths created this session.
6. **`CLAUDE.md` "Known issues" block** — add new known issues; remove resolved ones.

If the session shipped 5+ commits of feature work, additionally generate:
- **Technical report** → `docs/reports/YYYY-MM-DD-session.md` (English).
- **Team blueprint** → `docs/reports/YYYY-MM-DD-blueprint.md` (`PRIMARY_LANGUAGE`, non-technical).

If any count, date, or status drifts in any control-center file, treat as a regression. Fix in the same sync.

## 4. KB / standards file conventions

Files in `docs/standards/` and any other reference docs:

- **Frontmatter (English):**
  ```yaml
  ---
  name: <kebab-case>
  description: <one-line summary>
  applies_to: [CC, LV, CW]   # who reads it
  version: <semver, optional>
  updated_at: YYYY-MM-DD
  ---
  ```
- **Body:** can be in `PRIMARY_LANGUAGE` if the doc is user-facing (e.g. team blueprints) or English if developer-facing (standards).
- **Length:** under 400 lines per file. Split if larger.
- **Cross-references:** relative links (`[base.md](./base.md)`).
- **Changelog block** at the bottom for live standards:
  ```markdown
  ## Changelog
  - **YYYY-MM-DD** — bumped credit cost for foo from 2 to 3
  - **YYYY-MM-DD** — initial draft
  ```

## 5. Versioning agent docs

`CLAUDE.md` and `AGENTS.md` carry a header:

```markdown
**version:** X.Y
**updated_at:** YYYY-MM-DD
```

Bump version on substantive changes (new section, behavioral rule change). Date always reflects the last edit.

## 6. Architecture.md update triggers

Update `control-center/architecture.md` when ANY of these happen:

- A new route is added.
- A new top-level state machine or context is added.
- A new edge function is added.
- A new database table is added.
- A new contract type is added.
- A pattern changes (e.g. "we now use TanStack Query for all server state").

Sections to keep current:
- Routes inventory (with one-line description each).
- Data models (tables + key columns).
- Edge functions inventory (with one-line description + credit cost).
- Contracts inventory (with one-line summary + status).
- Design system (component count, key primitives).

## 7. Build-state.md format

Append to `control-center/build-state.md`:

```markdown
## Session YYYY-MM-DD — [one-line title]

**Commits:** [list]
**What shipped:**
- [bullet]

**Open follow-ups:**
- [ ] [item]

**Lane crossings:** [none | list]
**Notes:** [free text]
```

Keep entries in reverse chronological order (newest at top).

## 8. README.md maintenance

Project README stays user-facing and short. It includes:

- Project name + one-line tagline.
- "How to run locally" (3 commands max).
- Link to `CLAUDE.md` for contributors.
- Link to `OWNERSHIP.md` for AI agents.

Don't dump architecture into README. Keep it inviting.

## 9. Session reports — when

Trigger: 5+ commits of feature work in a single session.

- **Technical report** → `docs/reports/YYYY-MM-DD-session.md`. Audience: developers. English. Cover: what shipped, architecture decisions, deferred items, key file paths.
- **Team blueprint** → `docs/reports/YYYY-MM-DD-blueprint.md`. Audience: non-technical team / stakeholders. `PRIMARY_LANGUAGE`. Cover: what users can do now, how to test, credit costs, what's next.

Skip session reports for: bug fixes only, refactoring-only, documentation-only.

## 10. Doc rot detection

If any of these are true, you have doc rot:

- Counts in `CLAUDE.md` codebase paths differ from `ls src/components/`.
- `lovable-knowledge.md` references a file that no longer exists.
- `OWNERSHIP.md` has rows for deleted paths.
- `architecture.md` is more than 30 days old AND code has shipped since.

Fix in the next sync.
