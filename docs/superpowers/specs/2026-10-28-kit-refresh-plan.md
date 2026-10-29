# Kit refresh plan: Spec Kit, Lovable, Claude (2026-10-28)

**Status:** decided and implemented as v0.4.0. See §8 for the decisions taken and what was implemented, changed, deferred or dropped.
**Inputs:** research workflow `wf_ee639d3b-8be` (stopped early, see §7) plus direct checks run today against GitHub and the repo.

Evidence markers:
- ✅ means checked by an adversarial verifier, or checked directly today.
- ⚠️ means single-pass research that nobody verified. Confirm it before relying on it; most of these become pilot checks.

Finding IDs (`AM-`, `CC-`, `CM-`, `GAPn-m`) refer to the run's findings.

---

## 1. What changed since the kit was written

Ranked by how badly each breaks the kit today.

1. **Lovable now scaffolds TanStack Start, not React + Vite.** ✅
   - This is the default for new projects since 2026-05-13 (GAP3-1).
   - Direct check: 3 of 4 public Lovable repos with commits today were created between July and October. All three have `src/routes/`, `router.tsx`, `server.ts`, `start.ts`, `routeTree.gen.ts`, `styles.css` and `drizzle/`, and none has `src/pages/`. The fourth repo, created 2026-05-04, still uses `src/pages/`.
   - LV's server logic is now TanStack server functions inside `src/` (⚠️ GAP3-13, GAP4-11). Since 2026-10-07, Cloud DB schema changes are recorded under `drizzle/migrations/` (✅ GAP7-10).
   - **The kit's lane model (CC owns `src/**`, LV owns `supabase/**`) no longer matches where LV writes code.** `verify-after-pull.sh` `CC_PATHS` (`src/pages/`, `src/styles/`) also misses the new layout.

2. **Lovable has its own root `AGENTS.md`.** ✅ Direct check: all 4 repos have one.
   - The current template ships a `<!-- LOVABLE:BEGIN --> … <!-- LOVABLE:END -->` block.
   - Lovable's agent then **appends its own "architecture rules"** to that file over time.
   - `bin/install.sh` skips existing files, so **on a Lovable project the kit's `AGENTS.md` is silently never installed** (GAP3-11, GAP6-16).

3. **`AGENTS.md` is not read only by Lovable.** ✅
   - Codex, Cursor, Copilot, Antigravity, Devin, Jules, Zed, opencode and Cline all read the root `AGENTS.md` (AM-1). The kit's file opens with "You are Lovable (LV)", so those tools take on the LV role.
   - No tool reads `codex.md` (AM-3).
   - The format cannot target content at one agent (AM-28).
   - Claude Code does not load `AGENTS.md` when a `CLAUDE.md` exists, unless `CLAUDE.md` imports it (✅ GAP9-11).

4. **The lane-crossing gate never fires.** ✅ Direct check: Lovable agent commits are authored by `gpt-engineer-app[bot]` and carry an `X-Lovable-Edit-ID:` trailer. `template/scripts/verify-after-pull.sh:93-94` matches `%an` against "lovable", so it misses them.

5. **The CC→LV MCP loop is wrong in both directions.** ✅
   - **Answering:** a `send_message` sent during an approval pause rejects LV's pending tool (GAP7-4). The kit says to answer LV with `send_message`.
   - **Polling:** `get_message`'s top-level status never becomes terminal; read `response.status` instead (GAP7-5). The kit says to poll until done.
   - **Editor-only approvals:** secrets, Stripe keys and credit check-ins can only be approved in the Lovable editor (GAP7-3, GAP7-12).
   - **Plan to build:** a plan turns into a build only through the editor's Approve button or a separate build message (GAP7-1, GAP7-2).
   - **Cost:** plan-mode turns cost credits (GAP7-6).
   - **Normal pauses:** additive migrations and enabling Cloud don't pause by default (GAP7-9, GAP7-11). Credit check-ins pause every 20 credits by default (GAP7-14).

6. **lidr-specboot is gone.** ✅ Direct check: `github.com/LIDR-academy/lidr-specboot` and its API both return 404. README.md:18 still recommends it to single-agent users.

7. **Spec Kit is the obvious replacement.** ✅ Direct check: `github/spec-kit` has 143,630 stars and 12,867 forks, is MIT-licensed, and v1.2.5 was published today. OpenSpec, for comparison, has 73,257 stars.

8. **Claude.** ✅
   - Opus 5.5 is Claude Code's default model, at medium effort (CM-8, CM-12).
   - Thinking cannot be turned off on the 5.5 models (CM-13).
   - `ultrathink` works only when typed into a prompt. On v2.1.311+ it raises that turn to `xhigh`. Written inside a standards file it does nothing, and Lovable has no use for it (CM-14, CC-3).
   - Sonnet 5.5 was released 2026-09-28. Haiku 5.5 was released 2026-10-07 and is positioned as a subagent model (CM-4, CM-5).
   - Sonnet 4.5 retires 2026-11-30 (CM-20).
   - `template/ai-specs/agents/*.md` are never installed into `.claude/agents/`, so their `model:` fields have no effect (CC-8).

9. **Cowork is now "just Claude" and cloud-only since 2026-10-06.** ✅ (GAP8-1, GAP8-2)
   - It cannot reach localhost (GAP8-3).
   - Anthropic routes test and fix work to Claude Code (GAP8-8).
   - **CW should become a Claude Code subagent** (GAP8-11).

10. **Skill frontmatter doesn't follow the spec.** ✅
    - The Agent Skills spec allows only `name`, `description`, `license`, `allowed-tools`, `metadata` and `compatibility` at the top level.
    - `metadata` values must be strings.
    - Flow-style YAML (`[CC, LV]`) breaks the reference validator.
    - So the kit's `applies_to`, `author` and `version` keys are invalid outside Claude Code (GAP10-1, GAP10-2, GAP10-4, GAP10-5).

11. **Supabase.** ⚠️ Unverified but time-critical:
    - From **2026-10-30**, new `public` tables no longer get automatic grants to `anon`, `authenticated` or `service_role`, so migrations need explicit `GRANT`s (GAP5-1).
    - Legacy JWT keys are deprecated by the end of 2026 (GAP5-2).
    - `backend.md`'s `std/http serve` and unpinned `esm.sh` idioms are deprecated (GAP5-4, GAP5-5).

12. **`.env`.**
    - Lovable commits `.env` with `VITE_SUPABASE_PUBLISHABLE_KEY`, and its docs say not to gitignore it (GAP4-1, GAP4-2 ✅).
    - BOOTSTRAP's `cp .env.example .env.local` can blank the committed Supabase URL (✅ GAP4-3).

## 2. Decisions needed

| # | Question | Recommendation |
|---|---|---|
| **D1** | How deep should the Spec Kit integration go? (options in §3) | **B, Spec Kit as the spec layer**, after a short pilot. |
| **D2** | What should the root `AGENTS.md` be, now that every agent reads it and Lovable writes to it? | **A role-neutral routing section, inside a marked `<!-- CCLV:BEGIN/END -->` block** that the installer appends to Lovable's existing file. LV's identity and lane rules move to Lovable Project Instructions: a deduplicated LV sheet fits in 6,351 of the 10,000 characters (GAP9-3). `CLAUDE.md` starts with `@AGENTS.md`. |
| **D3** | Where is the CC/LV lane boundary on TanStack Start projects? | **Detect the stack at install time and ship two lane maps.** The legacy map (Vite + Edge Functions) stays as it is. The TanStack map gives LV the server side (`*.functions.ts` / `*.server.ts`, `src/integrations/supabase/**`, `drizzle/**`, `supabase/**`) and CC the routes and UI. ⚠️ The server-file naming comes from observed repos, so confirm the globs on a scratch Lovable project first. |
| **D4** | The tier ladder is byte-pinned to `sirkapu/gadd`. How should it reflect effort levels? | Keep the three ratified lines verbatim, and add an "operational mapping" below them: Trivial = `/effort low`, Standard = default (medium), Major = `/effort high`/`xhigh` or typing `ultrathink`. For LV, Major means `plan_mode` first. Propose the Trivial-rung wording upstream separately. |
| **D5** | What runtime should CW use? | **A Claude Code subagent** (`.claude/agents/cw-reviewer.md`, `isolation: worktree`). Cowork can't reach localhost now. |

Smaller calls with defaults:
- Demote paste mode to one appendix: yes.
- Replace "Sir" with `{{OWNER_NAME}}`: your call.
- Keep the product name: yes.
- Ship a `VERSION` file and an upgrade note for v0.3.x installs: yes.

## 3. Spec Kit options

| Option | What it is | Effort | Verdict |
|---|---|---|---|
| **A. Attribution swap** | Docs only: Spec Kit replaces lidr-specboot as the reference and comparison, and lidr stays as an unlinked historical credit. | S | Needed under every option; not enough on its own. |
| **B. Spec Kit as the spec layer** | `specify init --here --integration claude`, then cclv. Flow per feature: constitution → specify → plan → tasks. `tasks.md` items get lane tags, the LV prompt is built from `[LV]` tasks, and `src/contracts/` stays the typed source of truth. | L | **Recommended** |
| **C. cclv as a Spec Kit preset + extension** | A preset overrides the tasks, plan and constitution templates and wraps `speckit.implement`. An extension adds `/speckit-cclv-lv-prompt`, `-lv-response` and `-cw-brief` plus `after_tasks` hooks. Distributed through Spec Kit catalogs; `bin/install.sh` still places the root docs. | L+ | Later: revisit after one or two projects run B. |
| **D. Full replacement** | Spec Kit artifacts replace `control-center/` and `docs/standards/`. | L | No: it loses lanes, the LV audit trail and the MCP channel, none of which Spec Kit has. |

**Answered by research (✅ GAP1), which removes most of B's risk:**
- In v1.2.x, a plain `specify init --here --integration claude` writes **no** agent-context file and leaves `CLAUDE.md` and `AGENTS.md` alone. The agent-context extension is opt-in (GAP1-2, GAP1-3).
- It creates **no git branches**. The git extension has been opt-in since v0.10.0, and `--no-git` was removed (GAP1-6, GAP1-7, GAP1-8).
- The constitution lives at `.specify/memory/constitution.md` (GAP1-10).
- The Claude commands install as `.claude/skills/speckit-<cmd>/SKILL.md` (`/speckit-specify`, …), next to cclv's skill symlinks (GAP1-11).
- Gotcha: a non-interactive `specify init` defaults to **Copilot**, so always pass `--integration claude` (GAP1-12).

**Still open (⚠️ GAP2, never verified), for the pilot:**
- `/speckit-implement` runs **every** task and has no lane field. Hooks cannot filter tasks (GAP2-1, GAP2-4).
- A preset that wraps or replaces `speckit.implement` is the documented, durable fix (GAP2-6).
- Until that exists, CC must **never run stock `/speckit-implement` on a mixed tasks.md**, or it will build LV's backend.
- Spec Kit has no Lovable integration, so `[LV]` tasks still go over the Lovable MCP (GAP2-13).

## 4. Change list (revised)

The draft had 39 changes (PC-01…PC-39). This list folds in today's direct checks, the critic's review and the gap findings.

### P0: wrong today
1. **Lane model for TanStack Start** (D3, new). Applies to:
   - `OWNERSHIP.md`, the `AGENTS.md` lanes, `verify-after-pull.sh` `CC_PATHS`/LV paths, `backend.md` and `frontend.md`;
   - `bin/install.sh`, which gets stack detection;
   - the contract rule: TanStack server functions can import `src/contracts/*` directly, so "paste the type verbatim" applies only to Deno edge functions (⚠️ GAP4-12).
2. **The installer merges into an existing `AGENTS.md`** (new). It appends an idempotent `CCLV:BEGIN/END` block instead of skipping, and warns by name whenever `CLAUDE.md` or `OWNERSHIP.md` is skipped.
3. **Role-neutral `AGENTS.md` routing; LV sheet moves to Project Instructions** (PC-01 + PC-15). `CLAUDE.md` imports `@AGENTS.md`.
4. **Delete `codex.md`** (PC-02, simplified). With a routing `AGENTS.md`, Codex lands on CC without needing `AGENTS.override.md`. That override could also hijack Lovable if Lovable follows Codex semantics (GAP9-5), so drop it.
5. **Fix the MCP loop** (PC-03 + GAP7):
   - block on `send_message`;
   - read `response.status`;
   - answer `awaiting_input` with `respond_to_approval` after the human decides;
   - route secrets and check-ins to `editor_url`;
   - plan → build through a separate build message.
6. **Fix the lane-crossing gate** (PC-22, upgraded to P0):
   - match `gpt-engineer-app\[bot\]|lovable-dev\[bot\]` or the `X-Lovable-Edit-ID` trailer;
   - audit `ORIG_HEAD..HEAD`, not only the latest commit.
7. **Replace the dead lidr links with Spec Kit** (PC-06): README.md:7,18,69-79,89 and PHILOSOPHY.md:12,39-50,93,99.
8. **One `.env` model** (PC-20 + GAP4):
   - committed `.env` with public publishable values;
   - fix the `.env.local` step that blanks the Supabase URL;
   - backend secrets live in the Lovable editor;
   - one appendix for bring-your-own Supabase.

### P1
- **Spec Kit pilot, now short** (PC-07): only the GAP2 questions above are left. Then **option B** (PC-08), including a preset override so implement only runs `[CC]` tasks.
- **Tier-ladder operational mapping** (PC-10, D4).
- **CW as an installed Claude Code subagent** (PC-11, trimmed):
  - `model: sonnet`, `effort: high`, `isolation: worktree`;
  - drop `lv-backend.md` from `.claude/agents`.
  - The critic flagged two unsupported claims ("removes the qa merge", "restart required"), so both are dropped.
- **Minimum Claude Code version** (PC-12): v2.1.293+ for the 5.5 aliases; v2.1.311+ for `ultrathink` → `xhigh`.
- **Lovable naming and sync:** use "Instructions (formerly Knowledge)" (PC-13), and `kb-sync` counts characters with `wc -m` and strips the meta header (PC-14).
- **Spec-valid skill frontmatter** (PC-18 + GAP10): block-style YAML, with custom keys under `metadata` as strings.
- **Refresh `backend.md` for current Supabase** (new; verify GAP5 first). Includes the 2026-10-30 grants change, publishable/secret keys, `Deno.serve` and pinned `npm:` specifiers.
- **Remaining fixes:**
  - `plan_mode` for Major slices (PC-04);
  - MCP tool guardrails (PC-05);
  - installer doc drift (PC-19);
  - template contradictions (PC-21);
  - CC pulls and verifies itself (PC-23);
  - contracts by path (PC-24);
  - `VERSION` file and tags (PC-25);
  - third-party provider note (PC-27);
  - safe uninstall that keeps Spec Kit's skills (PC-28).

### P2
- Option C packaging (PC-09).
- GEMINI.md / Antigravity note (PC-17).
- Dated notes on historical docs instead of rewrites (PC-26).
- SessionStart digest and ownership-guard hooks (PC-29).
- Deduplicate `CLAUDE.md` against `base.md` (PC-30; the "200-line" rationale is dropped as unsupported).
- Native `claude --worktree` (PC-31).
- Project `.mcp.json` (PC-32).
- Reusable refresh workflow (PC-33, see §6).
- Small doc fixes (PC-34).
- CI smoke test (PC-35).
- Installer placeholder flags (PC-36).
- Opus 5.5 prompting aids (PC-37).
- Paste-mode appendix (PC-38).
- `{{OWNER_NAME}}` (PC-39).

### Dropped
- **PC-16 (per-tool CC routing files):** in Copilot CLI, Antigravity and Devin these files add an identity instead of overriding one (AM-11, AM-16, AM-17). A role-neutral `AGENTS.md` solves the same problem.

## 5. Speed playbook (practices for you, not repo edits)

- **Let `send_message` block** (up to 600 s by default) and act on `response.status`. Use `wait=false` only to wire the frontend against a pushed contract while LV builds.
- **Decide approval pauses yourself, then have CC call `respond_to_approval`.** Never type a new instruction over a pause.
- **Use `plan_mode=true` only for Major or ambiguous backend slices.** Plan turns cost credits. For questions, Lovable's Chat mode is cheaper (a temporary price through 2026-10-31, GAP7-7).
- **Raise the credit check-in level** (default 20) for long builds, or use `/goal` for runs of up to 10 hours (GAP7-14, GAP7-16).
- **Effort:** leave CC on Opus 5.5 at medium. Use `/effort high` for contracts, architecture and bug hunts, type `ultrathink` for a single hard turn, and use `/effort low` for renames and doc syncs.
- **Turn on `/fast` at the start of interactive debug sessions**, not mid-conversation. It's up to 2.5× faster output on Opus 5.5 (CM-16).
- **Use Haiku 5.5 subagents for read-heavy scouting**, such as diffing LV's edits against `OWNERSHIP.md` (CM-5).
- **Have CC run `git pull --ff-only` and `verify-after-pull.sh` itself** right after LV finishes. Lovable pushes about 4–6 s after an edit (⚠️ GAP6-5). Use `list_edits`/`get_diff` to see exactly which commits are LV's.
- **Push contracts before sending the LV prompt, and reference them by path** instead of pasting them.
- **Don't push to the synced branch while LV is mid-edit.** Diverged pushes send Lovable's work to `lovable-sync` (⚠️ GAP6-14).

## 6. Reusable refresh workflow (the research loop you asked for)

To be saved as `.claude/workflows/kit-refresh.js` once the plan is approved. Design lessons from this run:
- **Diff before researching.** Snapshot the Spec Kit and Claude Code releases APIs, `GET /v1/models`, and the Lovable MCP tool schemas, and research only what changed.
- **One track per topic, with an automatic retry.** Two of the five tracks died on API timeouts today.
- **Verify only findings that a proposed change depends on**, with one lens per finding and two for P0. Today's gap step produced 176 findings and queued 253 checks, which is what made the run take more than 5 hours.
- **Keep a claims register** (`file:line`, claim, source, last verified), so the next refresh starts from the stale-risk list rather than from zero.

**Sources to watch:**

| Area | Source |
|---|---|
| Claude | platform.claude.com: models overview, model deprecations, pricing, effort; `api.anthropic.com/v1/models`; anthropic.com/news |
| Claude Code | code.claude.com/docs: model-config, memory, sub-agents, skills, hooks, workflows, worktrees, mcp, fast-mode; the CHANGELOG; the releases API |
| Lovable | docs.lovable.dev: integrations/lovable-mcp-server, features/knowledge, features/skills, changelog |
| Spec Kit | github.com/github/spec-kit plus its releases API; github.github.com/spec-kit (presets, extensions, integrations/claude) |
| `AGENTS.md` ecosystem | agents.md; the Codex, Cursor, Copilot, VS Code, Antigravity, Devin, Zed and opencode instruction-file docs |
| Supabase | API keys, edge-function and grants changelogs |

## 7. Caveats

- **Coverage gaps from the run:**
  - The Spec Kit and Lovable research tracks failed on API timeouts ("No response from API", 3 min plus a 10 min retry). The critic's gap research covered both areas afterwards.
  - The run was stopped with 107 gap-finding checks still queued.
  - GAP2 (Spec Kit implement and lanes), most of GAP4/5/6 (backend, Supabase, git sync) and GAP9-12 are **unverified**.
- **Checked directly today:**
  - lidr-specboot returns 404;
  - Spec Kit and OpenSpec repo stats;
  - Lovable's bot author and edit trailer;
  - TanStack Start layout and Lovable-owned `AGENTS.md` in 4 public repos;
  - the kit's author check and installer skip logic.
- **Raw evidence** (code maps, findings with verdicts, the draft plan) is in this session's scratchpad: `/private/tmp/claude-501/-Users-pipeillera-dev-cclv-specboot/c8c8e9dc-767f-4627-9e34-8148ad292eee/scratchpad/run1/` (`by_label.json`, `main_findings.json`, `gap_findings.json`). The deduplicated LV sheet draft is `…/scratchpad/lv-sheet-dedup.md`.

## 8. Decisions and implementation (v0.4.0)

**Decisions:**
- **D1:** B, Spec Kit as the spec layer.
- **D2:** neutral router.
- **D3:** detect the stack, two lane maps.
- **D4:** operational mapping under the verbatim tier lines.
- **D5:** CW as a Claude Code subagent.

**Checked during implementation:**
- **Lovable commit identity.** Lovable's GitHub docs state it: `lovable-dev[bot]`, shown as `gpt-engineer-app[bot]` in raw git log, or `<app>[bot]` on GitHub Enterprise Server.
- **`lovable-sync` fallback.** Confirmed in the same docs. There is no "open PR" mode; Lovable edits the branch picked in its branch picker.
- **TanStack Start lane globs.** Taken from 3 public Lovable repos created July–October: `*.functions.ts`, `*.server.ts`, `src/routes/api/`, `src/integrations/supabase/`, `drizzle/`. The `@/*` alias exists, so server functions can import `src/contracts`.
- **Server-function shape.** `createServerFn().middleware([requireSupabaseAuth]).inputValidator().handler()`, taken from those repos.
- **Spec Kit v1.2.5 templates.** `/speckit-implement` processes all tasks phase by phase, and its only filter is `$ARGUMENTS`. The task format is strict, and every task names its file paths. That's why lanes come from `OWNERSHIP.md` instead of task tags.
- **Spec Kit install command.** `uv tool install specify-cli` (PyPI 1.2.5).
- **Lovable MCP tool schemas.** Read live: pause semantics, `response.status`, `respond_to_approval` arguments.

**Implemented:**
- **P0 1–8:** the lanes, AGENTS.md merge and routing, `codex.md` removal, MCP loop, lane gate, Spec Kit links, and env model.
- **From P1:**
  - the Spec Kit layer: the `spec-lanes` script and skill, and the install and workflow docs;
  - the tier mapping;
  - CW as a subagent;
  - the minimum Claude Code version;
  - the Lovable "Instructions" naming and `wc -m` counting;
  - `plan_mode` for Major slices;
  - the MCP tool classification;
  - installer doc drift;
  - CC pulls and verifies itself;
  - contracts by path;
  - `VERSION` plus a version stamp;
  - an uninstall that keeps Spec Kit's skills.
- **From P2:** dated notes on the history docs, and the reusable refresh workflow (`.claude/workflows/kit-refresh.js` + `docs/maintenance/`).

**Changed from the plan:**
- **No `AGENTS.override.md`** for Codex. The routing block already sends Codex to CC, and an override might also hijack Lovable (GAP9-5).
- **`template/OWNERSHIP.md` moved** to `stacks/<stack>/OWNERSHIP.md`.
- **CW without worktree isolation by default.** It writes only reports; isolation is optional when fixtures are needed.

**Deferred:**
- **Supabase conventions in `backend.md`** (GAP5, never verified): the 2026-10-30 default-grants change, the publishable/secret keys migration, and the `Deno.serve` / `npm:` specifiers. `lv-lanes.md` already asks for explicit grants in new migrations.
- **Spec-compliant skill frontmatter** (PC-18, GAP10): custom keys move under `metadata`, in block style.
- **The rest of P1/P2:** PC-21 remaining contradictions, PC-27 provider note, PC-29 hooks, PC-30 slimmer `CLAUDE.md`, PC-31 native worktrees, PC-32 `.mcp.json`, PC-34 small fixes, PC-35 CI, PC-36 placeholder flags, PC-37, PC-38, PC-39. These are candidates for the first `kit-refresh` run.

**Dropped:** PC-16, per-tool CC routing files. In tools that merge instruction files, they add identities instead of overriding them.
