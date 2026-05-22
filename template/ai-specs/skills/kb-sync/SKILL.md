---
name: kb-sync
description: Use when CC updates `control-center/lovable-knowledge.md` and needs Sir to re-paste it into Lovable's Knowledge UI. Triggers when CC says "update Knowledge", "LV's mental model needs to change", "sync Knowledge with Lovable", or after structural changes that LV needs to know about.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# kb-sync

## When to use

Lovable reads its Project Settings → Knowledge field on every prompt (10K char limit). The repo file `control-center/lovable-knowledge.md` is the canonical version. They do NOT auto-sync — Sir must manually re-paste when the canonical changes.

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

If it's a typo fix or pure formatting, skip the re-paste — not worth bothering Sir.

If it's a real semantic change (new rule, new pattern, new ownership), continue.

### Step 3 — Commit

```bash
git add control-center/lovable-knowledge.md
git commit -m "docs(knowledge): <one-line change summary>"
```

### Step 4 — Tell Sir

In the chat, surface clearly:

> **Knowledge updated.** Re-paste `control-center/lovable-knowledge.md` into Lovable → Settings → Knowledge. The change: <one-line>.

### Step 5 — Record in build-state.md

Add a line to the current session entry:

```markdown
**Lovable Knowledge:** updated `<file>` — Sir to re-paste. Change: <summary>.
```

### Step 6 — Verify next LV prompt

When you write the next LV prompt, confirm the new pattern is reflected in LV's behavior. If LV still acts on the old context, the re-paste didn't happen — ping Sir again.

## Character count check

```bash
wc -c control-center/lovable-knowledge.md
```

Keep under 9,500 to leave headroom.

## Anti-patterns

- ❌ Editing Knowledge silently — Sir won't know to re-paste. Always announce.
- ❌ Dumping CLAUDE.md content into Knowledge. LV doesn't need CC's full architecture.
- ❌ Cramming per-feature details. Those go in the LV prompt.

## Checklist

- [ ] Change is semantically meaningful (not just formatting).
- [ ] Under 10K characters.
- [ ] Committed.
- [ ] Sir told to re-paste.
- [ ] Recorded in `build-state.md`.
