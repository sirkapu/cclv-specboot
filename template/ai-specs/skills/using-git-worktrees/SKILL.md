---
name: using-git-worktrees
description: Use when CC wants to work on a feature in isolation without disrupting the main workspace. Triggers when CC says "create a worktree", "start feature in isolation", "spike on Y without affecting current work", or before running a long experiment that might fail.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# using-git-worktrees

## When to use

You want to work on a feature/spike in isolation. Examples:

- Long experiment that may fail (don't pollute `main`).
- Multiple parallel features.
- Reviewing a PR while keeping your in-progress work.
- Comparing two implementations side-by-side.

For short, single-session work, just commit/branch directly. Worktrees pay off when work spans multiple sessions or you want to switch contexts.

## Procedure

### Step 1 — Create the worktree

```bash
# From the main repo directory:
git worktree add ../{{PROJECT_NAME}}-<branch> -b feat/<branch>
```

This creates:
- A new directory at `../{{PROJECT_NAME}}-<branch>/`.
- A new branch `feat/<branch>` starting from your current HEAD.

### Step 2 — Set up the worktree

```bash
cd ../{{PROJECT_NAME}}-<branch>
npm install   # node_modules don't share between worktrees
cp ../{{PROJECT_NAME}}/.env.local .env.local   # env doesn't sync either
```

If the worktree needs Claude Code settings:

```bash
cp -r ../{{PROJECT_NAME}}/.claude .
```

(`.claude/skills/` symlinks may break across worktrees — re-run `bash scripts/sync-agent-symlinks.sh` if so.)

### Step 3 — Open CC in the worktree

Either:
- Open a new terminal in the worktree dir + run `claude` there.
- Or in Claude Code: `/cwd ../{{PROJECT_NAME}}-<branch>`.

### Step 4 — Work normally

Same workflow loop (CC + LV + CW) — just in a different directory.

**Heads up:** Lovable cannot see worktrees. If you create a worktree branch, Lovable's UI doesn't know about it. For LV-touching work, push the branch to GitHub first, then in Lovable's UI switch to that branch.

### Step 5 — Cleanup when done

```bash
# Back in the main repo:
cd ../{{PROJECT_NAME}}

# Make sure the worktree branch is merged/abandoned:
git worktree list
git worktree remove ../{{PROJECT_NAME}}-<branch>

# Delete the branch if abandoned:
git branch -d feat/<branch>   # safe (only if merged)
# OR
git branch -D feat/<branch>   # force (if abandoned)
```

## Naming conventions

- **Worktree directory:** `../{{PROJECT_NAME}}-<short-name>` (sibling of main repo).
- **Branch:** `feat/<short-name>` or `spike/<short-name>` for throwaway experiments.
- **Avoid colons or slashes** in worktree directory names — they confuse some shells.

## Common gotchas

| Issue | Fix |
|-------|-----|
| `npm install` errors after creating worktree | Worktrees have isolated `node_modules`. Run `npm install` fresh. |
| Lovable doesn't see the branch | Push to GitHub first: `git push -u origin feat/<branch>`. |
| Env vars missing | Copy `.env.local` from main repo. |
| `.claude/skills/` symlinks broken | Re-run `bash scripts/sync-agent-symlinks.sh`. |
| Worktree won't remove (`error: branch is checked out`) | You're inside it — `cd` out first. |
| Storage explosion | Worktrees share `.git/` storage; only working trees are duplicated. Still, `du -sh` if you have many. |

## When NOT to use worktrees

- Single-session feature work — a branch in the main repo is fine.
- Tiny fixes — worktree overhead > benefit.
- When LV is mid-flight on the same area — worktrees can't run Lovable.

## Checklist

- [ ] Decided worktree pays off (multi-session OR parallel work).
- [ ] Worktree created with descriptive branch name.
- [ ] `npm install` ran cleanly in the worktree.
- [ ] `.env.local` copied.
- [ ] `.claude/skills/` symlinks verified (or skipped if CC settings not needed).
- [ ] Planned cleanup path (merge or abandon).
