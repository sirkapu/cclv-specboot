---
name: cw-report-triage
description: Use when CC reads a fresh CW report and decides what to fix, what to ignore, what to escalate. Triggers when CC says "process CW's report", "triage the QA findings", or after CW files a new report in `control-center/cw-reports/`.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# cw-report-triage

## When to use

CW filed a report at `control-center/cw-reports/CW-[NAME]-report.md`. Use this skill to process it before reacting.

## Procedure

### Step 1 — Read top-to-bottom

Don't jump straight to the failures. Read:

1. **Summary** — pass/fail counts.
2. **Critical findings** — anything here halts other work.
3. **Detailed results** — each case + evidence.
4. **Suggested fixes** — CW's diff snippets.
5. **Questions for CC** — clarifications CW needs.
6. **Lane Crossings** — any production-code edits CW made (should be limited to `qa/` fixtures).

### Step 2 — Critical-first triage

For each **critical** finding:
- Stop other work.
- Confirm the bug reproduces (run CW's steps yourself, if possible).
- If confirmed, decide: frontend fix (CC), backend fix (write LV prompt), or hybrid.
- If it's a security issue (auth bypass, data leak), ping Sir IMMEDIATELY in chat — not just in the next session.

### Step 3 — Major-then-minor triage

Group remaining findings by severity:

| Severity | Default action |
|----------|----------------|
| Critical | Fix this session |
| Major | Fix this session unless explicitly deferred |
| Minor | Add to `roadmap.md` for the next slice |
| Cosmetic | Add to `roadmap.md`; batch with other cosmetic fixes |

### Step 4 — Apply suggested fixes (or don't)

CW's "Suggested Fix" sections are advisory. Decide per fix:

- **Apply as-is** — small, correct, matches standards. Commit with `fix(scope): <one-line>` + `Closes: CW-[NAME] case [n]`.
- **Apply with modification** — CW's direction is right but specifics are off. Implement the corrected version.
- **Reject** — CW's suggested fix violates a standard or misses context. Reply in `build-state.md` with reasoning so the trail exists.

### Step 5 — Answer CW's questions

If CW's "Questions for CC" section has items, either:

- Answer inline in the report (append a `## Answers from CC` section), then commit.
- Resolve in the next CW brief (clarify scope; CW reruns).

### Step 6 — Address Lane Crossings

CW shouldn't edit production code. If they did:

- If it's a `qa/` test fixture (in `qa/` branch only), accept — that's allowed.
- If it bled into `main`, revert. Note in `build-state.md`. Strengthen the brief next time.

### Step 7 — Update regression suite

For every fix that lands, consider adding the case to `control-center/cw-reports/regression-suite.md`. Re-runs on future CW passes prevent regressions.

### Step 8 — Close the loop

When all critical + major findings are fixed:

- Commit a `chore(qa): close CW-[NAME]` empty commit OR amend the last fix commit.
- Move the report to `control-center/cw-reports/archive/CW-[NAME]-YYYY-MM-DD-closed.md`.
- Note in `build-state.md`: "CW-[NAME] closed. X critical, Y major addressed; Z minor/cosmetic deferred to roadmap."

## Triage decision matrix

| Finding | Frontend? | Backend? | Action |
|---------|-----------|----------|--------|
| UI bug | ✅ | ❌ | Fix directly. |
| Wrong API response shape | ❌ | ✅ | Write follow-up LV prompt. |
| RLS denies legit access | ❌ | ✅ | Write follow-up LV prompt. |
| Missing edge function | ❌ | ✅ | New LV prompt. |
| Component crashes | ✅ | ❌ | Fix directly. |
| Hybrid (UI + backend) | ✅ | ✅ | Split: backend prompt first, frontend after. |

## Anti-patterns

- ❌ Cherry-picking — fixing only criticals and ignoring majors.
- ❌ Defending against valid findings ("works on my machine"). Run CW's steps.
- ❌ Applying CW's suggested fix without reviewing — they may violate standards.
- ❌ Forgetting to update the regression suite.

## Checklist

- [ ] All critical findings addressed (or escalated to Sir).
- [ ] All major findings addressed (or explicitly deferred).
- [ ] Suggested fixes applied/modified/rejected with reasoning.
- [ ] Questions for CC answered.
- [ ] Lane crossings handled.
- [ ] Regression suite updated.
- [ ] Report archived; `build-state.md` updated.
