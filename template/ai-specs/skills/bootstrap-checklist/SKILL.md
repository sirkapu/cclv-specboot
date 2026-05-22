---
name: bootstrap-checklist
description: Manage cross-session resume for any multi-step task using a checklist file in `control-center/checklists/`. Use for bootstrap, multi-step LV prompts, CW test passes, complex CC builds. Triggers when CC says "create a checklist for", "track this multi-step work", or starts work that has 5+ steps spanning potential pauses.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# bootstrap-checklist

## When to use

Any task with more than ~5 steps that might span a context-limit pause, network hiccup, or interrupted session. The most common case: project bootstrap (the `BOOTSTRAP.md` task list). Other cases: long LV prompt execution, CW test passes with 20+ cases, complex multi-feature CC builds.

This complements `TaskCreate` (in-session tracking). Checklist files persist across sessions; `TaskCreate` does not.

## Procedure

### Step 1 — Decide on the filename

Pattern: `control-center/checklists/<short-name>.md`

Examples:
- `control-center/checklists/bootstrap.md`
- `control-center/checklists/LV-image-pipeline-progress.md`
- `control-center/checklists/CW-onboarding-regression.md`

### Step 2 — Create the file with header + tasks

Template:

```markdown
# [Task name] — Progress

**Started:** YYYY-MM-DD
**Last updated:** YYYY-MM-DD HH:MM
**Status:** 0/N complete

## Tasks
- [ ] 1. [Step one]
- [ ] 2. [Step two]
- [ ] 3. [Step three]
- [ ] ...

## Resume notes
(empty — fill in when pausing)
```

### Step 3 — Tick boxes immediately

After EVERY step that succeeds, tick the box `[x]` BEFORE moving to the next step. Update the status counter.

If you batch multiple steps then tick all at once, you'll forget which actually finished. Drift is a regression.

### Step 4 — Write Resume notes before pausing

If you know you're about to pause (context filling, hit a blocker, user away), append a one-paragraph entry to the "Resume notes" section:

```markdown
## Resume notes

### YYYY-MM-DD HH:MM
Pausing at step 7. Halfway through writing `src/components/Foo.tsx` — finished the props + state setup, still need to wire the form handler and add the loading state. The `useFoo` hook is already wired. When resuming, open `Foo.tsx` first and check the TODO comment.
```

### Step 5 — Resume from the first unchecked task

When a new session opens (or a paused session resumes):

1. Check `control-center/checklists/` for active files.
2. Read the file: status counter + first `[ ]` box + most recent resume note.
3. Resume from that point.

### Step 6 — Archive when done

When the last box is ticked:

```bash
mkdir -p control-center/checklists/archive
mv control-center/checklists/<filename>.md control-center/checklists/archive/<filename>-YYYY-MM-DD.md
```

**Exception:** the `bootstrap.md` checklist stays flat at `control-center/checklists/bootstrap.md` as the project's day-0 milestone record.

## Status counter conventions

```markdown
**Status:** 7/21 complete (33%)
```

Update after every tick. Don't trust your memory — recount from `[x]` lines if needed.

## Anti-patterns

- ❌ Creating a checklist for a 2-step task. Overhead > value.
- ❌ Forgetting to tick boxes ("I'll catch up later"). Drift.
- ❌ Skipping Resume notes when pausing. Next session has no context.
- ❌ Using `TaskCreate` for cross-session work — it dies with the session.

## When NOT to use

- Tasks that fit in one short session (<30 min).
- Exploration / brainstorming work without a clear step list.
- Pure-code work where git log is enough of a trail.

## Checklist

Before declaring a checklist file ready to track work:

- [ ] Filename follows the convention.
- [ ] Header has start date + status counter.
- [ ] Tasks list mirrors the actual step list.
- [ ] Resume notes section exists (even if empty).
