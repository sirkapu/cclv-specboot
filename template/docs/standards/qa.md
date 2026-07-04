---
name: qa-standards
description: CW-specific QA standards. CW reads this + their CW brief.
applies_to: [CW]
---

# QA Standards

CW's deep reference for testing and reporting. Read `base.md` first.

## 1. Your role

You're an independent reviewer with READ-ONLY access to production code. You exercise flows, find bugs, and file structured reports. You do NOT apply fixes.

Your output is always:
- A markdown report in `control-center/cw-reports/CW-[NAME]-report.md`.
- Evidence (screenshots, console logs, network captures).
- Optionally: a "Suggested Fix" section with a code diff snippet — CC applies it manually.

## 2. Branch model

You operate on a feature branch CC creates for you: `qa/CW-[NAME]`. Stay on that branch. Never push to `main` or `prod`.

If you discover during testing that you need to change code to enable the test (e.g. add a test fixture), do it ONLY in the `qa/` branch and commit it with a clear `chore(qa): add fixture for X` message. Note in your report which commits are test-only.

## 3. Test case format

Each test case has:

```markdown
### Case [number] — [title]

**Type:** golden path | edge case | regression
**Severity if failing:** critical | major | minor | cosmetic
**Pre-conditions:** [what state must exist before]
**Steps:**
1. [Action]
2. [Action]
3. [Action]

**Expected:** [what should happen]
**Actual:** [what happened — fill in during execution]
**Result:** ✅ Pass | ❌ Fail | ⚠️ Partial
**Evidence:** [link to screenshot / log / network capture]
**Notes:** [observations, race conditions, side effects]
```

## 4. Severity levels

| Level | Definition | Examples |
|-------|-----------|----------|
| **Critical** | Blocks core flow; data loss; security issue | Login broken; payments charge wrong amount; SQL injection |
| **Major** | Significant feature degraded; visible to most users | Wrong totals in a list; image upload fails for one filetype |
| **Minor** | Functionality works but is suboptimal | Slow load; awkward error message; missing loading state |
| **Cosmetic** | Visual only; doesn't affect function | Misaligned button; wrong font weight |

## 5. Evidence requirements

- **Screenshots:** annotate when needed. Crop to relevant area. Store in `control-center/cw-reports/evidence/CW-[NAME]/`.
- **Console logs:** copy-paste full error stack. English.
- **Network captures:** copy the full request + response (sanitize secrets). Note status code + timing.
- **Video:** for hard-to-screenshot bugs (race conditions, animations). Embed as link.

No evidence = not a verified bug.

## 6. Report structure (control-center/cw-reports/CW-[NAME]-report.md)

```markdown
# CW-[NAME] Report — [feature]

**Tested:** [branch / commit]
**Date:** YYYY-MM-DD
**Tester:** CW (session [id])

## Summary
- Cases run: X
- Pass: Y
- Fail: Z (Critical: a, Major: b, Minor: c, Cosmetic: d)

## Critical findings
[For each critical: case number, one-line description, link to detailed case below]

## Detailed results
[Each case formatted per §3]

## Suggested fixes
[For each fail, optionally include a diff snippet — CC applies manually]

### Suggested fix for Case [n]
File: `src/...`
\`\`\`diff
- ...
+ ...
\`\`\`
Reason: ...

## Questions for CC
[Anything unclear in the brief or scope; needs CC clarification before re-test]

## Lane Crossings
[Files you edited outside `control-center/cw-reports/` — should be limited to `qa/` test fixtures only]

## Test environment
- Browser: ...
- Device: ...
- Account: [test account email or "fresh signup"]
- Network: [throttled? real?]
```

## 7. When to escalate

| Situation | Escalate to |
|-----------|-------------|
| Bug is in frontend code | CC — note "frontend fix needed" |
| Bug is in edge function / DB / RLS | CC — CC writes a follow-up LV prompt |
| Bug spans both | CC — CC decides split |
| Test brief is ambiguous | CC — `Questions for CC` section |
| Bug requires action you can't take (e.g. resetting a database) | CC + Sir — flag in report top |
| Critical security issue (data leak, auth bypass) | CC + Sir IMMEDIATELY — don't wait for end-of-test |

## 8. Anti-patterns (don't do this)

- ❌ "It doesn't work" without evidence.
- ❌ Filing the same bug 5 times across 5 cases. Group them.
- ❌ Suggesting full implementations instead of focused diff snippets.
- ❌ Editing production code "to make the test pass."
- ❌ Skipping cases because the previous one failed (test ALL cases unless a critical blocker prevents others from running).

## 9. Regression suite

CC may ask you to maintain a regression suite (the list of cases worth re-running on every CW pass). It lives at:

`control-center/cw-reports/regression-suite.md`

Format:
- One case per line.
- Reference the original CW report.
- Severity classification.

CC adds to the suite when a bug is fixed. You run the suite during every CW pass and report regressions immediately.

## 10. Suggested-fix format

When you DO suggest a fix:

- Diff format (unified diff or GitHub-style `+/-` lines).
- Smallest viable change. Don't refactor.
- Cite the standard you're applying (e.g. "per `docs/standards/frontend.md` §9, loading states must show after 500ms").
- Mark "Suggested" — CC decides whether to apply.
