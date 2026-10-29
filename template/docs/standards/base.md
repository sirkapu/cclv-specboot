---
name: base-standards
description: Cross-agent core development standards. CC, LV, and CW all read this first before any other doc.
applies_to: [CC, LV, CW]
alwaysApply: true
---

# Base Standards

Shared rules for every AI agent touching this repo. Read this BEFORE your agent-specific doc (`CLAUDE.md` for CC, Project Instructions for LV, your brief for CW). The CCLV block in `AGENTS.md` tells each agent which role it plays.

Adapted from [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) (MIT), derived from [Karpathy's observations on LLM coding failures](https://x.com/karpathy/status/2015883857489522876).

## 1. The four engineering disciplines (non-negotiable)

### §1 — Think before coding

Think in proportion to the task's tier:
- Trivial — the standing rules below; no extended-thinking trigger.
- Standard — think before coding or writing.
- Major — ultrathink before coding.

These are **task-ceremony** tiers, unrelated to the file-size Tiers in §5. Why tiered rather than unconditional: [the UBC tier-ladder decision](https://github.com/sirkapu/cclv-specboot/blob/main/docs/decisions/2026-07-27-ubc-tier-ladder.md).

**Operational mapping** (Claude Code v2.1.311+; the three lines above stay verbatim):

| Tier | CC (Claude Code) | LV (Lovable) |
|------|------------------|--------------|
| Trivial | Default effort, or `/effort low` for renames and doc syncs | Normal build message |
| Standard | Default effort (medium on Opus 5.5) | Normal build message |
| Major | `/effort high` or `xhigh` for the session, or type `ultrathink` in the prompt for one turn | CC sends a `plan_mode` message first, then the build message |

On the Claude 5.5 models thinking is always on, and effort is the dial. `ultrathink` only acts when typed into a prompt; written in a file it does nothing. Lovable has no equivalent keyword; plan mode is its lever.

Don't assume. Don't hide confusion. Surface tradeoffs.

- State assumptions explicitly.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so.
- If something is unclear: stop.
  - **CC** asks Sir directly.
  - **LV** asks in its reply and stops; CC answers with a follow-up message once LV's turn has completed. If the exchange doesn't resolve it, or the prompt was pasted manually, LV writes `control-center/lv-blockers/LV-[NAME]-blocker.md` and stops. Do NOT guess.
  - **CW** notes "Questions for CC" in the report.

### §2 — Simplicity first

Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you wrote 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### §3 — Surgical changes

Touch only what you must. Clean up only your own mess.

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables YOUR changes made unused. Don't remove pre-existing dead code unless asked.

The test: every changed line should trace directly to the user's request.

**Per-agent emphasis:**
- **CC** — verbatim.
- **LV** — never edit a file outside your lane "while you're in there." If unavoidable, log under "Lane Crossings."
- **CW** — you NEVER apply fixes to production code. Suggested diffs go inside the report under "Suggested Fix."

### §4 — Goal-driven execution

Define success criteria. Loop until verified.

- "Add validation" → "Inputs X/Y/Z produce error E with status 400; valid input passes."
- "Fix the bug" → "Reproduce it, fix it, confirm the reproduction no longer fails."
- "Refactor X" → "Behavior before == behavior after."

For multi-step tasks, state a plan with verify-checks per step:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**Per-agent "verify" means:**
- **CC** — run lint, run build, exercise the flow in browser.
- **LV** — migration applies, the server function or edge function builds/deploys, endpoint returns the expected shape, access rules allow expected access AND deny unauthorized access.
- **CW** — each test case in the brief passes or fails; report each with evidence (screenshot, console output, response payload).

## 2. Source of truth — the three pillars

| Source | Declares |
|--------|----------|
| `OWNERSHIP.md` | Who edits which files. |
| `src/contracts/` | API shapes at the CC↔LV boundary. |
| `docs/standards/base.md` (this file) | Cross-agent behavioral rules. |

Anything not in these three is project-specific opinion. Look it up in `CLAUDE.md` (CC) or LV's Project Instructions (`control-center/lovable-knowledge.md`).

## 3. Language

- **Code, comments, commit messages, logs, error messages, test names, schema names, function names:** English. Always.
- **User-facing UI strings:** project's `PRIMARY_LANGUAGE` (declared in `CLAUDE.md`).
- **Translations:** centralized in `src/constants/` or `src/lib/i18n/` (CC owns).

## 4. Type safety

- TypeScript strict mode. Always.
- No `any`. Use `unknown` + narrowing, or a discriminated union.
- Generated Supabase types live in `src/integrations/supabase/types.ts` (LV regenerates after schema changes).
- API contract types live in `src/contracts/` (CC owns).

## 5. File size standards

| Tier | Ceiling | Applies to |
|------|---------|-----------|
| Tier 1 | 200 lines | Services, utils, config, types |
| Tier 2 | 300 lines | Components, page containers, hooks |
| Tier 3 | Exempt | Mock data, locale constants, pure type defs |

Max 50 lines per function across all tiers. If you're past either ceiling, split the file.

## 6. Naming conventions

| Artifact | Convention |
|----------|-----------|
| Migrations | `YYYYMMDDHHMMSS_descriptive_snake_case.sql` (UTC) for Supabase; Drizzle's own names under `drizzle/migrations/` |
| Server functions (TanStack Start) | `camelCaseVerbNoun` exported from `kebab-case.functions.ts` |
| Edge functions | `kebab-case-verb-noun` |
| Contract files | `kebab-case.ts` matching the endpoint (functions file or edge function) name |
| Database tables | `snake_case_plural` |
| RLS policies | `<table>_<action>_<role>` |
| React components | `PascalCase.tsx` |
| Hooks | `useCamelCase.ts` |
| Storage buckets | `kebab-case`, private by default |
| Realtime channels | `<table>:user:<user_id>` for owner-scoped streams |

## 7. Lane-crossing protocol

If you edit a file outside your lane, log it in your response/report under a **"Lane Crossings"** section with:

- Which file.
- What change.
- Why it couldn't be done in-lane.

Silent cross-lane edits are a regression.

## 8. Question assumptions, detect patterns

- Question every inferred behavior — verify by reading the actual code or asking.
- When you see the same pattern repeated 3+ times, flag it as a candidate for abstraction. Do NOT abstract unprompted; surface it and let Sir decide.

## 9. TDD where applicable

When the project has a testing framework configured (see `CLAUDE.md` tech stack), follow:

1. Write a failing test for the new behavior.
2. Make it pass with the minimum code.
3. Refactor (only what's broken, per §3).

When no test framework is configured: define a verifiable behavior in the LV prompt or CC plan, then verify by exercising the flow.

## 10. Documentation lives in the same PR

- New feature → update relevant `docs/` and `control-center/architecture.md` in the SAME PR.
- Stale docs are a regression.
- LV's Project Instructions (formerly "Knowledge") are canonically stored at `control-center/lovable-knowledge.md` — when this file changes, CC syncs it via the Lovable MCP (`set_project_knowledge`, kb-sync skill). No MCP? Ping Sir to re-paste into Lovable → Project settings → Instructions.

## 11. Skills are auto-loaded

Skills live in `ai-specs/skills/` (mirrored to `.claude/skills/` via symlink on macOS/Linux). When a request matches a skill's description, load and follow the corresponding `SKILL.md` BEFORE responding.

- **CC** discovers skills automatically via `.claude/skills/`. Spec Kit's `/speckit-*` skills live there too when Spec Kit is installed.
- **LV** doesn't see this repo's skills. Lovable has workspace skills, but they apply to every project in the workspace, so the kit doesn't use them by default. CC includes relevant skill summaries inline in LV prompts when applicable.

## 12. Single-step commits, conventional style

- One concern per commit. If you need "and" in the commit message, split it.
- Conventional commits where possible: `feat(scope):`, `fix(scope):`, `chore(scope):`, `docs(scope):`, `refactor(scope):`, `test(scope):`.
- Commit messages in English even when UI is in another language.

## 13. Branch strategy & git flow

- **`main`** — Staging / active development. **Lovable pushes here** (its synced branch), shortly after each edit. CC also commits here unless a feature warrants isolation.
- **`prod`** — Production. Only fast-forward merges from `main` when ready to ship. Created on first deploy.
- **Feature branches** — Optional, CC's call. Use when an LV prompt is in flight and you don't want LV's push to overlap with your in-progress local work. Pattern: `feat/<short-name>` or `spike/<short-name>` for throwaway experiments.
- **Spec Kit** — keep its git extension off (it is opt-in). Per-feature branches fight Lovable's single synced branch; specs live in `specs/NNN-*/` on `main`.
- **Pulling** — CC runs `git pull --ff-only` at session start and after every completed LV turn, then `verify-after-pull.sh`. Local lags behind LV's pushes. If you committed during LV's turn, `--ff-only` refuses: use `git pull --rebase` (your commits are still unpushed, so rebasing them is safe), then verify.
- **Don't push while LV is editing.** If the synced branch moves under an in-flight Lovable edit, Lovable pushes its work to a `lovable-sync` branch instead, and you have to merge it.
- **Never rewrite pushed history** (force-push, amend, rebase): Lovable rewrites its own copy to match and the project history can be lost.
- **PR review** — Lovable edits and pushes the branch selected in its branch picker (Project settings → Git). For PR-based review, create a branch there (Lovable switches to it; you can't switch while it's editing) and merge it into `main` through a pull request. Default: direct push to `main`, CC reviews via `bash scripts/verify-after-pull.sh`.
- **Hotfix flow** — see §14.

## 14. Hotfix & lane-violation recovery

### When Lovable rewrote a CC-owned file

1. **Don't immediately revert.** Read the diff first — sometimes LV's change is legitimate (a real bug it noticed) and just landed in the wrong lane.
2. **Quarantine:** `git restore --source=<previous-commit> -- <path>` to undo only that file.
3. **If LV's change was correct in spirit:** CC re-implements it cleanly in the CC layer. Note in `build-state.md` + sharpen `OWNERSHIP.md` to prevent recurrence.
4. **If recurring,** add a rule to `control-center/lovable-knowledge.md` (e.g. "never edit `src/components/X` even if you see a bug — flag it in your response report").

### When prod breaks

1. Roll back: `git revert <commit>` on the `prod` branch.
2. Push.
3. Open a `CW-HOTFIX-[NAME].md` brief for post-mortem.
4. Treat root-cause fix as a normal feature: contract → LV prompt → CC wire-up → CW verify → merge.

### When CC accidentally edits an LV-owned file

Same protocol in reverse. Log it in `build-state.md` under "Lane Crossings". Apologize in the next LV prompt and explain. Strengthen `OWNERSHIP.md` if the path was ambiguous.

## 15. Env values and secrets

Public values and secrets live in different places, and they do NOT auto-sync.

| Location | What goes there | Who sets it |
|----------|----------------|-------------|
| **`.env` (committed)** | Public, build-time values Lovable Cloud writes: `VITE_SUPABASE_URL`, `VITE_SUPABASE_PUBLISHABLE_KEY`, `VITE_SUPABASE_PROJECT_ID` (TanStack Start projects also get non-`VITE_` copies for the server). Lovable's docs say not to gitignore it: previews and published builds read it. | Lovable |
| **Lovable editor → Settings → Secrets** (Lovable Cloud) | Backend-only secrets: third-party API keys like OpenAI or Stripe. Write-only. LV asks for them through a secure input; over the MCP that pause is answered in the editor, never in chat. | Sir |
| **Supabase dashboard → Edge Functions → Secrets** | Same role, but only when the project uses **your own** Supabase project instead of Lovable Cloud. | Sir |
| **Local `.env.local`** | Personal overrides for `npm run dev`. Never committed. | Sir |

**Rules:**

1. `.env.example` lists every env var the code reads, with no values. CC maintains it.
2. `.env` holds public values only. `.env.local` and `.env.*.local` are gitignored. Always.
3. Never copy `.env.example` over your env: an empty `VITE_SUPABASE_URL=` in `.env.local` overrides the committed value and breaks the app. Put only the overrides you need in `.env.local`.
4. Secrets never appear in LV prompts, CC prompts, code, `.env`, commit messages, or docs.
5. When CC needs a new secret, the LV prompt says: *"requires secret `FOO_API_KEY` — ask for it through the secure secret input; Sir will enter it."*
6. `package.json` / lockfile coordination: Lovable adds packages itself (updates `package.json` and the lockfile; bun on current projects). CC adds with the project's package manager. Conflicts resolve in favor of the most recent commit; if both add the same package at different versions, CC reconciles after the next pull and notes in `build-state.md`.
