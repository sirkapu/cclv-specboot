---
name: update-control-center
description: End-of-session discipline — sync `control-center/` after shipping code. Triggers when CC says "update control center", "end of session", "wrap up", or at any natural session boundary.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# update-control-center

## When to use

At the end of every CC session that shipped meaningful code. Skip if you only did exploration, planning, or doc-only edits.

## Procedure

### Step 1 — Audit counts

Run from project root:

```bash
echo "Components: $(ls src/components/*.tsx 2>/dev/null | wc -l)"
echo "Hooks: $(ls src/hooks/*.ts 2>/dev/null | wc -l)"
echo "Pages: $(find src/pages -name '*.tsx' 2>/dev/null | wc -l)"
echo "Contracts: $(ls src/contracts/*.ts 2>/dev/null | wc -l)"
echo "Edge functions: $(ls supabase/functions 2>/dev/null | grep -v _shared | wc -l)"
```

These are the numbers you'll need for `architecture.md` updates.

### Step 2 — Update `build-state.md`

Append (newest at top):

```markdown
## Session YYYY-MM-DD — [one-line title]

**Commits:** [list — `git log --oneline -10`]
**What shipped:**
- [bullet]

**Open follow-ups:**
- [ ] [item]

**Lane crossings:** [none | list]
**Lovable Knowledge:** [unchanged | updated, Sir to re-paste]
**Notes:** [free text]
```

### Step 3 — Update `architecture.md` (if structure changed)

Sections to keep current:

- **Routes** — every top-level route + one-line description.
- **Data models** — every table + key columns.
- **Edge functions inventory** — every function + one-line + credit cost.
- **Contracts inventory** — every contract file + status.
- **Design system** — component count, key primitives.

If none changed this session, skip.

### Step 4 — Update `roadmap.md` (if a phase/milestone shifted)

- Check off completed items.
- Flag new blockers.
- Add new milestones if the plan grew.

### Step 5 — Update `OWNERSHIP.md` (if new paths were added)

For any new top-level directory or path created this session, add a row to the matrix. If LV's response added paths, merge them in too.

### Step 6 — Update `CLAUDE.md` "Known issues" block

- Add new known issues from this session.
- Remove items that got resolved.

### Step 7 — Update `lovable-knowledge.md` (if LV's mental model needs to shift)

Use the `kb-sync` skill. Skip if no structural change LV needs to know about.

### Step 8 — Generate session reports (if 5+ commits of feature work)

- **Technical report** → `docs/reports/YYYY-MM-DD-session.md` (English, dev-facing).
  - Sections: Commits + files changed + LOC; What was built; Architecture decisions; Deferred items; Key file paths.
- **Team blueprint** → `docs/reports/YYYY-MM-DD-blueprint.md` (`PRIMARY_LANGUAGE`, non-technical).
  - Sections: What it does for users; How to test; Credit costs; What's next.

Skip session reports for bug fixes only, refactoring only, or doc-only sessions.

### Step 9 — Commit the control-center sync

```bash
git add control-center/ CLAUDE.md OWNERSHIP.md docs/
git commit -m "chore(control-center): sync after session YYYY-MM-DD"
```

If `lovable-knowledge.md` changed, tell Sir to re-paste.

## Doc rot check

Before declaring done, sanity-check:

- Counts in `CLAUDE.md` codebase paths match `ls` output.
- `lovable-knowledge.md` doesn't reference deleted files.
- `OWNERSHIP.md` doesn't have rows for deleted paths.

If any of those is true, fix it in the same sync.

## Checklist

- [ ] `build-state.md` entry appended.
- [ ] `architecture.md` updated (or N/A).
- [ ] `roadmap.md` updated (or N/A).
- [ ] `OWNERSHIP.md` updated (or N/A).
- [ ] `CLAUDE.md` known-issues updated.
- [ ] `lovable-knowledge.md` updated + Sir told (or N/A).
- [ ] Session reports generated (or skipped with reason).
- [ ] Control-center sync committed.
