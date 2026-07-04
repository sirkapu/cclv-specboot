# Spec: Production-readiness audit of cclv-specboot v0.3.0

**Date:** 2026-07-04
**Author:** Fable 5 (main session)
**Executors:** Opus 4.8 subagents via orchestrated workflow
**Status:** Commands the audit-and-fix workflow below

## Goal

cclv-specboot v0.3.0 (Lovable MCP integration) must be production-ready: a stranger can clone it, run either install path, and get a coherent, internally consistent kit with no broken references, no contradictions between MCP-primary and paste-fallback flows, and no hygiene issues. This spec defines what to audit, how to judge severity, and what the fixing agents may and may not do.

## Audit dimensions (one Opus 4.8 agent each)

### D1 — Install-path correctness
`bin/install.sh` (safe under `set -e`? `cp -rn` semantics, symlink loop, `.gitignore.append` merge, executable bits), INSTALL.md steps match actual script behavior, BOOTSTRAP-PROMPT.md steps reproduce the same result, cross-platform notes accurate. Every command shown in docs must be runnable as written.

### D2 — Cross-reference integrity
Every file path, skill name, section reference (e.g. "base.md §15"), and step-number reference ("step 4 below") mentioned anywhere must point at something that exists and says what the referrer claims. Version strings consistent (README status, CHANGELOG top entry, skill frontmatter versions). Internal markdown links resolve.

### D3 — Lovable MCP accuracy
Every Lovable MCP tool name used in the kit must be a real tool (`send_message`, `get_message`, `get_diff`, `list_files`, `read_file`, `get_project_knowledge`, `set_project_knowledge`, `query_database`, `enable_database`, `deploy_project`, `create_project`, analytics tools). Setup instructions (`claude mcp add --transport http lovable https://mcp.lovable.dev`) correct. Claims about behavior (credits on send_message/create_project, OAuth, get_diff taking message_id) must match `docs.lovable.dev/integrations/lovable-mcp-server`. No invented tools or parameters.

### D4 — Workflow coherence (MCP-primary + paste fallback)
The CC/LV/CW loop must be told the same way in: template/CLAUDE.md, template/AGENTS.md, docs/standards/base.md, control-center/workflow-guide.md, lovable-knowledge.md, agent personas, and the lv-prompt-writer / lv-response-reader / kb-sync / update-control-center skills, plus both control-center TEMPLATEs. Hunt contradictions: who writes lv-responses in each mode, blocker flow (chat-first vs file), guardrails (deploy/DDL/create_project need Sir; send_message free), verify-after-pull still mandatory. Fallback must be complete: a no-MCP user following only the docs must never hit a dead end.

### D5 — Template integrity & dogfooding
All `{{PLACEHOLDER}}` tokens enumerated by install docs (no orphan placeholders, none missing from the fill list). Skill SKILL.md frontmatter valid and descriptions match triggers. TEMPLATEs match what the skills instruct agents to produce. The kit dogfoods its own file-size rule (Tier ceilings) and its own engineering-discipline wording (base.md §1–§4 self-consistent with CLAUDE.md/AGENTS.md adaptations).

### D6 — Hygiene & safety
No real secrets, tokens, or personal emails anywhere in file contents (the repo owner's personal email addresses must not appear; the configured git identity is acceptable in commit metadata only). `.gitignore.append` covers `.env*` correctly. Guidance never asks an agent to print or commit secrets. License/attribution files intact. Nothing in the kit instructs agents to bypass the deploy/DDL confirmation guardrails.

## Severity rubric

- **blocker** — a fresh user following the docs fails or is materially misled (broken command, wrong tool name, contradiction that changes behavior, secret leak).
- **major** — internal contradiction or stale reference that will cause agent confusion or doc rot, but a human can route around it.
- **minor** — cosmetic: typos, inconsistent naming, formatting.

## Verification pass

Each finding is checked by an independent Opus 4.8 skeptic instructed to REFUTE it against the actual files (not the finder's claim). Only findings the skeptic confirms as real survive. Skeptics may downgrade/upgrade severity with justification.

## Fix policy (binding on fixing agents)

1. Fix all confirmed **blocker** and **major** findings, and **minor** ones that are mechanical (typo-class).
2. Obey base.md §3 (surgical): touch only lines the finding requires; match existing style; no adjacent "improvements"; no refactors.
3. Never weaken the guardrails (deploy/DDL/create_project confirmation) or remove the paste fallback.
4. No Claude attribution, no personal emails, no new dependencies, no new files unless a finding explicitly requires one.
5. A finding whose fix is debatable (multiple valid designs) is NOT fixed — it is reported for Sir's decision.
6. Fixing agents work on disjoint file sets (grouped by file) to avoid write conflicts.

## Success criteria

- Every confirmed blocker/major is either fixed or explicitly reported as needs-decision.
- `bash -n bin/install.sh template/scripts/*.sh` passes.
- A grep for the repo owner's personal email addresses over file contents (excluding `.git/`) returns nothing — the main session knows the addresses and runs this check without writing them into any file.
- Post-fix re-check: no fix introduced a new cross-reference break.
- Main session reviews the diff, verifies, and commits as `fix: production-readiness audit sweep (v0.3.x)`.
