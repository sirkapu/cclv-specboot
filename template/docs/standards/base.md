---
name: base-standards
description: Cross-agent core development standards. CC, LV, and CW all read this first before any other doc.
applies_to: [CC, LV, CW]
alwaysApply: true
---

# Base Standards

Shared rules for every AI agent touching this repo. Read this BEFORE your agent-specific doc (`CLAUDE.md`, `AGENTS.md`, or your CW brief).

## 1. The four engineering disciplines (non-negotiable)

### §1 — Think before coding (ultrathink)

Don't assume. Don't hide confusion. Surface tradeoffs.

- State assumptions explicitly.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so.
- If something is unclear: stop.
  - **CC** asks Sir directly.
  - **LV** writes to `control-center/lv-blockers/LV-[NAME]-blocker.md` and stops. Do NOT guess.
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

**Per-agent "verify" means:**
- **CC** — run lint, run build, exercise the flow in browser.
- **LV** — migration applies, edge function deploys, endpoint returns the expected shape, RLS allows expected access AND denies unauthorized access.
- **CW** — each test case in the brief passes or fails; report each with evidence (screenshot, console output, response payload).

## 2. Source of truth — the three pillars

| Source | Declares |
|--------|----------|
| `OWNERSHIP.md` | Who edits which files. |
| `src/contracts/` | API shapes at the CC↔LV boundary. |
| `docs/standards/base.md` (this file) | Cross-agent behavioral rules. |

Anything not in these three is project-specific opinion. Look it up in `CLAUDE.md` (CC) or `AGENTS.md` (LV).

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
| Migrations | `YYYYMMDDHHMMSS_descriptive_snake_case.sql` (UTC) |
| Edge functions | `kebab-case-verb-noun` |
| Contract files | `kebab-case.ts` matching edge function name |
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
- The Lovable Knowledge field is canonically stored at `control-center/lovable-knowledge.md` — when this file changes, ping Sir to re-paste into Lovable's Knowledge UI.

## 11. Skills are auto-loaded

Skills live in `ai-specs/skills/` (mirrored to `.claude/skills/` via symlink on macOS/Linux). When a request matches a skill's description, load and follow the corresponding `SKILL.md` BEFORE responding.

- **CC** discovers skills automatically via `.claude/skills/`.
- **LV** does not auto-load skills. CC includes relevant skill summaries inline in LV prompts when applicable.

## 12. Single-step commits, conventional style

- One concern per commit. If you need "and" in the commit message, split it.
- Conventional commits where possible: `feat(scope):`, `fix(scope):`, `chore(scope):`, `docs(scope):`, `refactor(scope):`, `test(scope):`.
- Commit messages in English even when UI is in another language.

## 13. Branch strategy & git flow

- **`main`** — Staging / active development. **Lovable pushes here.** CC also commits here unless a feature warrants isolation.
- **`prod`** — Production. Only fast-forward merges from `main` when ready to ship. Created on first deploy.
- **Feature branches** — Optional, CC's call. Use when an LV prompt is in flight and you don't want LV's push to overlap with your in-progress local work. Pattern: `feat/<short-name>` or `spike/<short-name>` for throwaway experiments.
- **QA branches** — CC creates `qa/CW-[NAME]` for each CW pass. CW stays on that branch.
- **Sir's role** — Always pull `origin/main` first before starting a CC session. Local can lag significantly behind LV's pushes.
- **PR review** — Lovable typically pushes directly to `main`. Sir can switch Lovable to "open PR" mode in its UI if review is desired. Default: direct push, CC reviews via `bash scripts/verify-after-pull.sh`.
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

## 15. Secrets — three places

Three locations store secrets. They do NOT auto-sync. Sir maintains them.

| Location | What goes there | Who sets it |
|----------|----------------|-------------|
| **Lovable Project → Env Variables** | Frontend-facing public values (`VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`). Available to LV during edits. | Sir |
| **Supabase Project → Edge Functions → Secrets** | Backend-only secrets (service-role key, third-party API keys like OpenAI / Stripe). Read by edge functions via `Deno.env.get()`. | Sir |
| **Local `.env.local`** | What Sir uses for `npm run dev`. Mirrors Lovable's env. Never committed. | Sir |

**Rules:**

1. `.env.example` is the canonical list of required env vars (no values). CC maintains it.
2. `.env`, `.env.local`, `.env.*.local` are gitignored. Always.
3. Secrets never appear in LV prompts, CC prompts, code, commit messages, or docs.
4. When CC needs a new secret for an edge function, the LV prompt says: *"requires secret `FOO_API_KEY` — Sir will set it in Supabase secrets before deploy."*
5. `package.json` / lockfile coordination: Lovable adds packages via its UI (updates `package.json`). CC adds via `npm install <pkg>`. Conflicts resolve in favor of the most recent commit; if both add the same package at different versions, CC reconciles after the next pull and notes in `build-state.md`.
