---
name: cw-brief-writer
description: Use when CC needs to hand off a feature to CW (QA). Triggers when CC says "write a CW brief", "QA this", "hand this to Cowork", or after shipping a user-facing flow that needs testing.
applies_to: [CC]
author: cclv-specboot
version: 0.1.0
---

# cw-brief-writer

## When to use

After you've shipped a user-facing flow (feature, fix, refactor with behavior changes) and want CW to verify it before declaring done. Skip for internal-only work (refactors with no behavior change, doc updates).

## Procedure

### Step 1 — Confirm CW is actually needed

CW is the right call when:
- A user-visible flow shipped and you want independent verification.
- A bug was reported and you want to confirm the fix.
- A regression suite needs to be run after multiple shipped slices.

CW is overkill when:
- You're still iterating (CW shouldn't test moving targets).
- The change is invisible (CSS token rename with no behavior change).
- It's a quick spot-check you can do yourself in 60s.

### Step 2 — Create the brief

`control-center/cw-briefs/CW-[NAME].md`

Template:

```markdown
# CW-[NAME]: [Feature or flow under test]

## Build Reference
- Branch: [branch name or commit hash]
- Related LV prompts: [LV-X, LV-Y]
- Related CC commits: [hashes]

## Scope
[What flows to exercise. What "passing" means.]

## Pre-conditions
[What state must exist before testing — fresh signup? specific data? feature flag on?]

## Test Cases

### Case 1 — [Golden path title]
**Type:** golden path
**Severity if failing:** critical | major
**Steps:**
1. ...
2. ...
3. ...

**Expected:** ...

### Case 2 — [Edge case title]
**Type:** edge case
**Severity if failing:** major | minor
**Steps:** ...
**Expected:** ...

### Case 3 — [Regression check title]
**Type:** regression
**Severity if failing:** critical
**Steps:** ...
**Expected:** ...

## Out of Scope
[Things CW should NOT test in this pass — other features, performance benchmarks, etc.]

## Report Location
`control-center/cw-reports/CW-[NAME]-report.md` per `docs/standards/qa.md` §6.

## Special instructions
[Test accounts, fixtures, env flags, etc.]
```

### Step 3 — Include a regression baseline

If a regression suite exists (`control-center/cw-reports/regression-suite.md`), reference it:

```markdown
## Regression Suite
Run the cases in `control-center/cw-reports/regression-suite.md`. Report any new failures immediately.
```

### Step 4 — Cover the unhappy paths

For each golden path, write at least one edge case. Examples:
- Empty input.
- Maximum input length.
- Network failure mid-flow.
- Insufficient credits.
- Unauthorized access (anonymous user, wrong-user access).
- Race condition (two tabs).

### Step 5 — Set severity expectations upfront

Don't let CW guess. Per case, declare the severity if it fails. This makes triage downstream much faster.

### Step 6 — Save + ping Sir

Save to `control-center/cw-briefs/CW-[NAME].md`. Tell Sir: "CW brief ready. Open a second Claude session on branch `qa/CW-[NAME]` and paste the brief."

### Step 7 — Wait for the report

CW writes to `control-center/cw-reports/CW-[NAME]-report.md`. Use the `cw-report-triage` skill to process it.

## Anti-patterns

- ❌ "Test everything in the app" — scope creep. One brief = one feature.
- ❌ Cases without severity labels — slows triage.
- ❌ Missing pre-conditions — CW wastes time setting up.
- ❌ No edge cases — golden paths alone miss most bugs.

## Checklist

- [ ] Brief is scoped to one feature/flow.
- [ ] At least 3 cases (golden + edge + regression).
- [ ] Each case has type + severity + steps + expected.
- [ ] Pre-conditions stated.
- [ ] Out-of-scope stated.
- [ ] Report location specified.
- [ ] Saved to `control-center/cw-briefs/`.
