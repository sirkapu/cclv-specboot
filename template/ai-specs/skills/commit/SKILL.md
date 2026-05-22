---
name: commit
description: Use when CC is about to commit. Enforces conventional-commit style + single-concern commits. Triggers when CC says "commit this", "let's commit", or whenever staging changes for a commit.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# commit

## When to use

Right before running `git commit`. Use to enforce single-concern + conventional-style commits.

## Procedure

### Step 1 — Audit the staged diff

```bash
git diff --staged
```

Ask: "Does this diff have ONE concern?" Concerns are things like:
- A single feature.
- A single bug fix.
- A single refactor.
- A single doc update.

If the diff mixes concerns (e.g. a feature + an unrelated refactor + a doc update), STOP. Unstage and split:

```bash
git restore --staged <file>
# stage one concern at a time
```

### Step 2 — Pick a type

| Prefix | When |
|--------|------|
| `feat` | New user-visible feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring with no behavior change |
| `chore` | Tooling, deps, config |
| `docs` | Documentation only |
| `test` | Test additions/changes |
| `style` | Formatting / linting |
| `perf` | Performance improvement |

### Step 3 — Pick a scope

Scope is the area touched. Common scopes:

- `(app)` — `src/pages/App/`
- `(contracts)` — `src/contracts/`
- `(control-center)` — `control-center/`
- `(supabase)` — edge functions, migrations (LV's prefix mostly)
- `(deps)` — package.json changes
- `(qa)` — QA branch test fixtures (CW only)

Custom scopes are fine: `(intel)`, `(checkout)`, etc.

### Step 4 — Write the message

Format:

```
<type>(<scope>): <one-line summary, imperative mood, lowercase, no trailing period>

<optional body — why, not what>

<optional footer — Closes: CW-X, Refs: LV-Y>
```

Examples:

- `feat(contracts): add generate-foo contract`
- `fix(app): handle null response in useProducts`
- `chore(deps): bump react to 18.2.0`
- `docs(claude): clarify control-center sync trigger`
- `refactor(hooks): extract useDebouncedSearch from useSearchBar`

### Step 5 — One-line < 72 chars

If you can't summarize in 72 chars, you may have multiple concerns. Re-audit step 1.

### Step 6 — Body for the why

Use the body ONLY when "why" isn't obvious from the diff. Don't restate "what" — the diff already shows that.

```
feat(intel): wire competitor matching to entry screen

Users dropping a URL or topic now see matched competitors immediately
instead of an empty state. Drives engagement on the first action.

Refs: roadmap.md Phase 2 milestone 3
```

### Step 7 — Footer for cross-refs

```
Closes: CW-onboarding-regression case 4
Refs: LV-image-pipeline
```

### Step 8 — Commit + verify

```bash
git commit -m "<type>(<scope>): <summary>"
git log --oneline -3
```

If hooks reject (lint, pre-commit), fix the underlying issue, re-stage, commit again. **Never** `--no-verify` unless Sir explicitly asks.

## Anti-patterns

- ❌ `git commit -m "wip"` — meaningless. Either it's done or it's not.
- ❌ `git commit -m "fix"` — what was fixed?
- ❌ "Add feature X and fix bug Y and update docs" — three commits.
- ❌ `--amend` on a pushed commit (rewrites history; breaks collaborators).
- ❌ `--no-verify` to bypass failing hooks.

## When to use `--amend`

Only when:
- The commit is LOCAL (not pushed yet).
- Sir explicitly asks ("amend the last commit").
- You're fixing a typo in the commit message of the immediately previous commit.

Otherwise, create a new commit.

## Checklist

- [ ] Diff has one concern.
- [ ] Type + scope chosen.
- [ ] Summary under 72 chars, imperative mood.
- [ ] Body explains "why" if non-obvious.
- [ ] Cross-refs in footer.
- [ ] Hooks pass without `--no-verify`.
