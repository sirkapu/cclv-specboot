# CW-[NAME] Report — [feature]

> Save as `control-center/cw-reports/CW-[NAME]-report.md`. Evidence files in `evidence/CW-[NAME]/`.

## Tested

- **Branch:** `qa/CW-[NAME]`
- **Commit:** `<hash>`
- **Date:** YYYY-MM-DD
- **Tester:** CW (session [id])
- **Brief:** `control-center/cw-briefs/CW-[NAME].md`

## Summary

- Cases run: X
- Pass: Y
- Fail: Z (Critical: a, Major: b, Minor: c, Cosmetic: d)
- Regression failures: 0 (or list)

## Critical findings (read first)

[For each critical: case number, one-line description, link to detailed case below. If none: "No critical findings."]

## Detailed results

### Case 1 — [Golden path title]

**Type:** golden path
**Severity if failing:** critical
**Pre-conditions:** [from brief]

**Steps run:**
1. [What you did]
2. [What you did]

**Expected:** [from brief]
**Actual:** [what happened]
**Result:** ✅ Pass | ❌ Fail | ⚠️ Partial
**Evidence:** `evidence/CW-[NAME]/case-1-screenshot.png`, `evidence/CW-[NAME]/case-1-network.txt`
**Notes:** [observations, race conditions, side effects]

---

### Case 2 — [title]

(repeat structure)

---

## Suggested fixes

> Diff snippets, not full implementations. CC decides whether to apply.

### Suggested fix for Case 2

**File:** `src/components/Foo.tsx`
```diff
- toast.error('Algo salió mal');
+ toast.error(error.code === 'insufficient_credits' ? 'No tienes suficientes créditos' : 'Algo salió mal');
```
**Reason:** Per `docs/standards/frontend.md` §10, toast messages must reflect actual error context. The current code shows the generic message for all errors including the credit-specific one users hit in case 2.

---

## Questions for CC

- [ ] [Anything in the brief that was unclear]
- [ ] [Any case you couldn't run and why]

## Lane Crossings

[Files you edited outside `control-center/cw-reports/` — should be limited to `qa/` test fixtures only. List each with reason.]

- (none)

## Test environment

- Browser: [Chrome 134, Safari 17.4, etc.]
- Viewport: [1920x1080, mobile 375x667, etc.]
- Network: [no throttle / Slow 3G]
- Account: [test@example.com or "fresh signup"]
- Time: [YYYY-MM-DD HH:MM TZ]

## Regression suite results

[If the brief asked you to run the regression suite, list each case + result here. If you found NEW failures, surface them at the top of the report under "Critical findings".]

- Case [suite-1]: ✅ Pass
- Case [suite-2]: ✅ Pass
- Case [suite-3]: ❌ Fail (regression — see Critical findings)
