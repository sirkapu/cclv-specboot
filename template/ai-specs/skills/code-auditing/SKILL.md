---
name: code-auditing
description: Use when CC needs a systematic code-quality audit — pre-release review, technical-debt sweep, dependency audit, security check. Triggers when CC says "audit the code", "review for technical debt", "find dead code", "security pass", or before a major release.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# code-auditing

## When to use

- **Pre-release review** — before merging a Phase to `prod`.
- **Technical-debt sweep** — quarterly or when velocity drops.
- **Dependency audit** — after major package upgrades.
- **Security check** — after touching auth, RLS, or payments.
- **Dead-code hunt** — after several refactors.

Don't use for routine per-feature reviews — those are CW's job.

## Six-phase audit

Run sequentially. Each phase produces a section in the report.

### Phase 1 — Security

```bash
npm audit
```

Plus manual checks:
- Are any secrets committed? `git log --all --full-history -- '*.env*'`.
- Does any client-side code embed Supabase service-role key? `grep -rn "service_role" src/`.
- Are RLS policies in place for every user-data table? Cross-check `OWNERSHIP.md` table list against `supabase/migrations/`.
- Are signed URLs used for storage? `grep -rn "createPublicUrl" src/` (should be empty unless explicit public buckets).
- Are auth pages free of inline scripts / dangerous URLs?

### Phase 2 — Performance

- Bundle size: `npm run build` + check `dist/` size.
- Largest components: `find src/components -name '*.tsx' -exec wc -l {} + | sort -nr | head -10`.
- Lazy-loading coverage: `grep -rn "React.lazy" src/pages/`.
- N+1 risk: `grep -rn "await Promise.all" src/` and audit each.
- Realtime subscription leaks: every `.subscribe()` should have a `.unsubscribe()` in cleanup.

### Phase 3 — Type safety

- `any` count: `grep -rn ": any" src/ | wc -l` (target: 0).
- `as` casts: `grep -rn " as " src/ | wc -l` (audit each).
- `@ts-ignore` / `@ts-expect-error`: `grep -rn "@ts-" src/`.
- Strict mode: `grep "strict" tsconfig.json` → must be `true`.

### Phase 4 — Dead code

- Unused exports: install + run `ts-prune` or `knip`.
- Unused dependencies: `npx depcheck`.
- Commented-out blocks: `grep -rn "^// " src/ | grep -E "(TODO|FIXME|XXX)" | wc -l`.
- Orphan files: components not imported anywhere.

For each finding, **mention it — don't delete unless explicitly asked.** Per `base.md` §3 Surgical Changes.

### Phase 5 — Standards compliance

For each Tier 2 component (≤ 300 lines):
- Over the line ceiling? Flag.
- Function > 50 lines? Flag.
- Direct API call instead of hook? Flag.
- Inline contract type instead of `@/contracts/`? Flag.

For each edge function:
- CORS on all responses? Check.
- Uses `_shared/` utilities? Check.
- Idempotency on mutations? Check.

### Phase 6 — Library best practices

For each top-level dependency:
- Major version behind? `npm outdated`.
- Deprecated? Check the GitHub repo.
- Has a known better alternative? (e.g. moment.js → date-fns).

## Report format

Save to `docs/reports/YYYY-MM-DD-audit.md`:

```markdown
# Code Audit — YYYY-MM-DD

## Summary
- Commit audited: <hash>
- Phases run: 6/6
- Findings: X critical, Y major, Z minor

## Phase 1 — Security
[Findings + evidence]

## Phase 2 — Performance
[Findings + evidence]

## Phase 3 — Type safety
[Findings + evidence]

## Phase 4 — Dead code
[Findings — mentioned, not deleted]

## Phase 5 — Standards compliance
[Findings + files in violation]

## Phase 6 — Library best practices
[Outdated/deprecated/recommended swaps]

## Prioritized action plan
1. [Critical] ...
2. [Critical] ...
3. [Major] ...
4. [Minor] ...

## Out of scope
[Things noticed but not investigated this pass]
```

## Decision authority

Audits PRODUCE findings; they don't apply fixes. After the report:

- **Critical:** CC fixes this session (or writes follow-up LV prompt for backend issues).
- **Major:** CC adds to `roadmap.md` for the next slice.
- **Minor:** CC adds to `roadmap.md`; batched with similar minors.

If a finding is in LV's lane, the action becomes a follow-up LV prompt.

## Anti-patterns

- ❌ Auto-fixing during the audit. Audits report; fixes are separate.
- ❌ Skipping a phase because "we already know it's fine". Run all six.
- ❌ Dumping the whole `npm audit` output as the report. Summarize + cite specific findings.
- ❌ Mass-deleting dead code without Sir's review. Per `base.md` §3.

## Checklist

- [ ] All 6 phases run.
- [ ] Report saved to `docs/reports/YYYY-MM-DD-audit.md`.
- [ ] Prioritized action plan at the bottom.
- [ ] Out-of-scope section honest about what wasn't checked.
- [ ] Critical findings escalated to Sir if security-related.
