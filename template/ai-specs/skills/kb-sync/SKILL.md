---
name: kb-sync
description: Use when CC updates `control-center/lovable-knowledge.md` and needs it synced into Lovable's Project Instructions (via the Lovable MCP `set_project_knowledge`, or Sir re-pastes as fallback). Triggers when CC says "update Knowledge", "update LV's instructions", "LV's mental model needs to change", "sync Knowledge with Lovable", or after structural changes that LV needs to know about.
applies_to: [CC]
author: cclv-specboot
version: 0.3.0
---

# kb-sync

## When to use

Lovable includes its **Project Instructions** (formerly "Knowledge"; max 10,000 characters) in every prompt. They are LV's identity and lane sheet: the root `AGENTS.md` only routes agents. The repo file `control-center/lovable-knowledge.md` is the canonical version. They do NOT auto-sync: CC pushes it via the Lovable MCP (`set_project_knowledge`) when the canonical changes; without MCP, Sir re-pastes manually.

Use this skill when something Lovable should know about has shifted:

- New file/folder LV owns or shouldn't touch.
- New pattern LV needs to follow (e.g. new shared utility).
- Conflict resolution rule update.
- Stack change.

DO NOT use this skill for:

- Per-feature details (those go in the LV prompt).
- Project state ("we're in Phase 3" — goes in `build-state.md`).
- Rules already in `base.md` (the instructions should point to base.md, not duplicate it).

## Procedure

### Step 1 — Edit `control-center/lovable-knowledge.md`

Make the change. The file opens with an HTML comment for maintainers; that comment is **not** synced. Everything after it is.

If you're approaching the limit, move content to `docs/standards/backend.md` and replace it with a pointer ("See `docs/standards/backend.md` §X").

### Step 2 — Diff to confirm the change is meaningful

```bash
git diff control-center/lovable-knowledge.md
```

If it's a typo fix or pure formatting, skip the sync — not worth a round-trip.

### Step 3 — Commit

```bash
git add control-center/lovable-knowledge.md
git commit -m "docs(knowledge): <one-line change summary>"
```

### Step 4 — Sync via the Lovable MCP

Build the body (the file minus its leading HTML comment) and check its size in **characters** (`wc -c` counts bytes, which overcounts non-ASCII text):

```bash
awk 'c == 0 && /-->/ {c = 1; next} c == 1' control-center/lovable-knowledge.md > /tmp/lv-instructions.md
wc -m < /tmp/lv-instructions.md   # must be ≤ 10000; keep under 9500, and never 0
```

If the count is 0 (someone removed the opening comment, so the awk printed nothing), stop and fix the file. `set_project_knowledge` with an empty string **clears** LV's instructions.

`set_project_knowledge` **replaces** the whole field. Push the body, then read it back with `get_project_knowledge` and confirm it matches the body exactly.

**No MCP connected?** Tell Sir in chat:

> **LV instructions updated.** Paste everything after the opening comment of `control-center/lovable-knowledge.md` into Lovable → Project settings → Instructions. The change: <one-line>.

### Step 5 — Record in build-state.md

Add a line to the current session entry:

```markdown
**Lovable Instructions:** updated — synced via MCP (or: Sir to re-paste). Change: <summary>.
```

### Step 6 — Verify next LV prompt

When you write the next LV prompt, confirm the new pattern is reflected in LV's behavior. If LV still acts on the old context, re-run the sync (`get_project_knowledge` shows what LV actually sees) — or, in paste mode, ping Sir again.

## Workspace-level instructions and skills

Lovable also has Workspace instructions and workspace skills. Both apply to **every project in the workspace**, need admin/owner rights, and are not synced by this skill. Only change them with Sir's go-ahead.

## Anti-patterns

- ❌ Editing the repo file without syncing — LV keeps acting on stale instructions. Always sync (or announce, in paste mode).
- ❌ Editing via `set_project_knowledge` without updating the repo file first. The repo file is canonical; the MCP push mirrors it, never the reverse.
- ❌ Moving LV's identity or lane rules back into `AGENTS.md`. Every coding agent reads that file.
- ❌ Dumping CLAUDE.md content into the instructions. LV doesn't need CC's full architecture.
- ❌ Cramming per-feature details. Those go in the LV prompt.

## Checklist

- [ ] Change is semantically meaningful (not just formatting).
- [ ] Body (without the leading comment) is ≤ 10,000 characters by `wc -m`.
- [ ] Committed.
- [ ] Synced via `set_project_knowledge` + read back (or Sir told to re-paste).
- [ ] Recorded in `build-state.md`.
