# LV Blockers

When LV (Lovable) cannot resolve ambiguity in a prompt, instead of guessing, LV writes a blocker file here.

CC reads `lv-blockers/` at the start of every session to resolve outstanding blockers before continuing.

## File naming

`LV-[NAME]-blocker.md` matching the originating prompt's NAME.

If LV files multiple blockers against the same prompt, suffix: `LV-[NAME]-blocker-2.md`.

## File format

```markdown
# LV-[NAME] BLOCKER

## The prompt
`control-center/lv-prompts/LV-[NAME].md`

## What I can't resolve
[One paragraph stating the ambiguity, conflict, or missing context.]

## What I tried
- [Attempt 1 — outcome]
- [Attempt 2 — outcome]

## Options I see

1. **Option A** — [description, tradeoffs]
2. **Option B** — [description, tradeoffs]

## My recommendation
[LV's pick + why. CC may agree or override.]
```

## CC's resolution

CC either:

1. **Resolves inline** — writes a clarification, LV re-runs.
2. **Writes a new prompt** — `LV-[NAME]-v2.md` with the clarified scope.
3. **Cancels the slice** — moves blocker to `archive/` with reasoning in `build-state.md`.

After resolution, move the blocker file to `control-center/lv-blockers/archive/`.

## Why this exists

LV operating without real-time chat will silently make assumptions if you don't give it an explicit "stop and ask" channel. Blockers ARE that channel. Use them aggressively — a 5-minute clarification beats a 2-hour rework.
