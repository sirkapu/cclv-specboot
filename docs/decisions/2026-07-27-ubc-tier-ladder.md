---
type: decision
date: 2026-07-27
status: APPLIED (specboot) · RATIFIED upstream in sirkapu/gadd 2026-07-16 (wave "UBC PORTABILITY")
supersedes: the unconditional `(ultrathink)` parenthetical in §1 of base standards
scope: template/docs/standards/base.md · template/CLAUDE.md · template/AGENTS.md · docs/examples/aura-style-bootstrap.md · PHILOSOPHY.md
---

# §1 thinks in proportion to the task's tier

## The decision

§1 of base standards no longer issues an unconditional maximum-effort order. It reads:

```
Think in proportion to the task's tier:
- Trivial — the standing rules below; no extended-thinking trigger.
- Standard — think before coding or writing.
- Major — ultrathink before coding.
```

This text is **not new here**. It is the operator-ratified wording from `sirkapu/gadd` (`context/ubc.md`, ratified 2026-07-16, byte-pinned). specboot adopts it verbatim so the three repos stop diverging. The word is **conditioned on tier, not deleted** — see "Why not delete it".

## Why this record exists at all

This is the actual point. The original defect was not the word — it was that **someone added `(ultrathink)` to the §1 heading with no recorded reason**, and six months later nobody could reconstruct it. The drift then compounded silently:

| # | Where | §1 heading |
|---|---|---|
| 0 | Origin — [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) (MIT) | `## 1. Think Before Coding` |
| 1 | specboot `template/docs/standards/base.md` | `### §1 — Think before coding (ultrathink)` |
| 2 | A downstream copy in circulation | `## 1. ultrathink Before Coding` |

At link 0 the word does not exist. At link 1 the parenthetical was injected. At link 2 **the parenthetical ate the verb** — `Think` vanished and the keyword became the imperative. `PHILOSOPHY.md:83` had already drifted the same way, misquoting specboot's own heading as "ultrathink before coding".

A doctrine line with no recorded why is a line that mutates. That is the failure this file is here to stop.

## Why tiered, and not unconditional

An instruction to think maximally on *every* task contradicts proportionality as a written order, regardless of what any keyword mechanically does. gadd's own governance defines Trivial tasks as deterministic-gate-only; an unconditional §1 directly contradicts that spec. That argument is **purely semantic** and stands on its own, which is why it was chosen as the floor.

**Deliberately NOT claimed here:** that this change saves money. gadd's speed audit (`audits/speed-audit-v1.md`, local-private) measured Director cost at 68% of weighted spend, adversaries at 14%, deterministic gates at 2.4%. **Extended-thinking cost was never isolated as a line item in that audit.** gadd's own `docs/rejection-ledger.md:14` records the rationale as *"instruction semantics, not a token-budget claim."* Any statement that this change reduces measured cost is unsupported. A stakeholder memo in gadd (`reports/ubc-portabilidad-decision.html`) does phrase it as "ceremony is the dominant cost of the system" — that phrasing overstates the audit and should not be reused.

## Why not delete the word

Deleting it (as `sicilian-home-experience` did before this convergence) is lossy in the dangerous direction: it removes the operator's ability to *ask for* maximum deliberation, and leaves a repo that has tiers with no cognitive gradient attached to them. The ladder keeps tier and thinking effort on the same axis. Retaining the word in the Major rung is truthful — it is still the Major form.

## Keyword status — verified 2026-07-27 against a primary source

Earlier write-ups asserted the keyword was "deprecated 2026-01-16 (Claude Code v2.1.11), replaced by effort levels", sourced from a blog quoting a GitHub issue comment secondhand. **That is wrong as a statement of current status.** Verified directly against the installed binary (`~/.local/share/claude/versions/2.1.220`, current release, 2026-07-24), which contains:

- `\bultrathink\b` — a live word-boundary detector
- `tengu_ultrathink`, `ultrathink_effort`, `ultrathink-active` — telemetry and effort-level plumbing
- the injected notice, verbatim: `The user included the keyword "ultrathink", requesting deeper reasoning on this turn.`

**Current status: alive as a per-turn keyword that maps onto an effort level.** `/effort` is the separate persistent dial. Not deprecated. The January-2026 deprecation history could not be verified either way — the public changelog only reaches back to 2.1.179 (2026-06-16) — so it is recorded here as unverified rather than repeated.

## Does the word trigger anything when it sits in a file? — one probe, not established

gadd reported this as **not measured** and built the decision on a floor that does not need it. That remains the right posture. One direct probe was run on 2026-07-27: a subagent, whose own prompt did not contain the keyword, read a file containing it and self-reported receiving **no** keyword notice — while the same harness injects the notice when the word appears in a user turn.

That is **one trial, in a subagent context**, consistent with "fires on user-turn text, not on file content". It is *not* sufficient to assert the strong form ("a standards file could never trigger it"). Treat as: supported by one probe, not replicated, not load-bearing for this decision.

## Known open gap — the default on ambiguity

The ladder is a function of tier, but **no rule defines the tier when the tier is unclear**, in any of the three repos. gadd's only pressure is one-directional ("downgrading to skip ceremony is a gate violation"; "tiers are a floor"), so a rational actor facing an ambiguous task declares upward every time — which collapses the ladder back to near-unconditional and would relabel ceremony rather than reduce it.

This is the strongest surviving objection to the ladder and it is **unresolved**. Closing it requires one ratified sentence naming the default. It is deliberately **not** patched here, because inventing that sentence locally is precisely the unratified-drift failure this record exists to prevent.

## Naming collision (specboot-specific)

`Tier 1/2/3` in `base.md §5` are **file-size ceilings**, a different axis. The ceremony rungs are named (Trivial/Standard/Major), not numbered, and §1 now states the distinction inline. `Major` is also SemVer scope in `CONTRIBUTING.md` and defect severity in `docs/standards/qa.md` — disambiguated by context, flagged here so it is not rediscovered as a surprise.

## Attribution

§1–§4 are adapted from [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) (MIT). `base.md` previously carried no attribution at all; it now does. Note that MIT requires reproducing the copyright **and** permission notice for substantial portions — a link plus "(MIT)" is credit, not compliance. Full notice handling is **open** across all three repos.
