# CW-[NAME]: [Feature or flow under test]

> Save as `control-center/cw-briefs/CW-[NAME].md` (replace `[NAME]` with a short kebab-case slug).

## Build Reference

- **Branch:** `qa/CW-[NAME]` (CC creates this branch from the latest `main` for CW).
- **Commit under test:** `<hash>`
- **Related LV prompts:** `LV-...`
- **Related CC commits:** `<hashes>`

## Scope

[What flows to exercise. What "passing" means. 2-3 sentences.]

## Pre-conditions

- Fresh signup OR specific test account: [details]
- Specific data state: [details]
- Feature flags: [list]
- Env: [browser, viewport, network throttling]

## Test Cases

### Case 1 — [Golden path title]

**Type:** golden path
**Severity if failing:** critical
**Steps:**
1. [Action]
2. [Action]
3. [Action]

**Expected:** [What should happen]

### Case 2 — [Edge case title]

**Type:** edge case
**Severity if failing:** major
**Steps:**
1. ...

**Expected:** ...

### Case 3 — [Edge case: insufficient credits]

**Type:** edge case
**Severity if failing:** major
**Steps:**
1. Set account to 0 credits.
2. Attempt the action.

**Expected:** UI shows "Insufficient credits" toast in `{{PRIMARY_LANGUAGE}}`; no API call fires OR API returns 402.

### Case 4 — [Edge case: unauthorized]

**Type:** edge case
**Severity if failing:** critical (security)
**Steps:**
1. Log out.
2. Try to access the protected route directly via URL.

**Expected:** Redirect to login; no data leaks.

### Case 5 — [Regression check title]

**Type:** regression
**Severity if failing:** critical
**Steps:**
1. Run the case from `control-center/cw-reports/regression-suite.md` line N.

**Expected:** Behavior matches the suite's baseline.

## Out of Scope

[Things CW should NOT test in this pass — other features, performance benchmarks, etc.]

## Special instructions

- Test account: [email/password OR "fresh signup"]
- Feature flags to enable: [list]
- Network: [throttled? "Slow 3G"? real?]
- Browser(s): [Chrome / Safari / Firefox — default is latest Chrome]

## Report Location

`control-center/cw-reports/CW-[NAME]-report.md` per `docs/standards/qa.md` §6.

## Regression Suite

[Optional] Run the cases in `control-center/cw-reports/regression-suite.md` after the focused cases above. Report any new failures immediately in a section called "Regression failures" at the top of the report.
