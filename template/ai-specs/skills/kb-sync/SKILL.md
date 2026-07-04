---
name: kb-sync
description: Use when CC updates `control-center/lovable-knowledge.md` and needs it synced into Lovable's Knowledge (via the Lovable MCP `set_project_knowledge`, or Sir re-pastes as fallback). Triggers when CC says "update Knowledge", "LV's mental model needs to change", "sync Knowledge with Lovable", or after structural changes that LV needs to know about.
applies_to: [CC]
author: cclv-specboot
version: 0.2.0
---

# kb-sync

## When to use

Lovable reads its Project Settings → Knowledge field on every prompt (10K char limit). The repo file `control-center/lovable-knowledge.md` is the canonical version. They do NOT auto-sync — CC pushes it via the Lovable MCP (`set_project_knowledge`) when the canonical changes; without MCP, Sir re-pastes manually.

Use this skill when something Lovable should know about has shifted:

- New file/folder LV owns or shouldn't touch.
- New pattern LV needs to follow (e.g. new shared utility).
- Conflict resolution rule update.
- Stack change.

DO NOT use this skill for:

- Per-feature details (those go in the LV prompt).
- Project state ("we're in Phase 3" — goes in `build-state.md`).
- Rules already in `base.md` (Knowledge should point to base.md, not duplicate it).

## Procedure

### Step 1 — Edit `control-center/lovable-knowledge.md`

Make the change. Keep total file under 10,000 characters (Lovable's limit).

If you're approaching the limit, consider moving content to `docs/standards/` and replacing it with a pointer ("See `docs/standards/backend.md` §X for the full pattern").

### Step 2 — Diff to confirm the change is meaningful

```bash
git diff control-center/lovable-knowledge.md
```

If it's a typo fix or pure formatting, skip the sync — not worth a round-trip.

If it's a real semantic change (new rule, new pattern, new ownership), continue.

### Step 3 — Commit

```bash
git add control-center/lovable-knowledge.md
git commit -m "docs(knowledge): <one-line change summary>"
```

### Step 4 — Sync via the Lovable MCP

Push the full file content with `set_project_knowledge`, then read it back with `get_project_knowledge` and confirm it matches the repo file.

**No MCP connected?** Tell Sir in chat:

> **Knowledge updated.** Re-paste `control-center/lovable-knowledge.md` into Lovable → Settings → Knowledge. The change: <one-line>.

### Step 5 — Record in build-state.md

Add a line to the current session entry:

```markdown
**Lovable Knowledge:** updated `<file>` — synced via MCP (or: Sir to re-paste). Change: <summary>.
```

### Step 6 — Verify next LV prompt

When you write the next LV prompt, confirm the new pattern is reflected in LV's behavior. If LV still acts on the old context, re-run the sync (`get_project_knowledge` shows what LV actually sees) — or, in paste mode, ping Sir again.

## Character count check

```bash
wc -c control-center/lovable-knowledge.md
```

Keep under 9,500 to leave headroom.

## Anti-patterns

- ❌ Editing the repo file without syncing — LV keeps acting on stale Knowledge. Always sync (or announce, in paste mode).
- ❌ Editing Knowledge via `set_project_knowledge` without updating the repo file first. The repo file is canonical; the MCP push mirrors it, never the reverse.
- ❌ Dumping CLAUDE.md content into Knowledge. LV doesn't need CC's full architecture.
- ❌ Cramming per-feature details. Those go in the LV prompt.

## Checklist

- [ ] Change is semantically meaningful (not just formatting).
- [ ] Under 10K characters.
- [ ] Committed.
- [ ] Synced via `set_project_knowledge` + read back (or Sir told to re-paste).
- [ ] Recorded in `build-state.md`.
