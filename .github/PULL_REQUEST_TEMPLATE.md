# Pull Request

## What this PR does

[one-line summary]

## Why

[motivation — what problem this solves, what use case it unlocks]

## Type

- [ ] New skill (`template/ai-specs/skills/<name>/`)
- [ ] New standard / standard update (`template/docs/standards/`)
- [ ] New template (`template/control-center/...` or similar)
- [ ] Bug fix
- [ ] Documentation (repo-level or template-level)
- [ ] Multi-IDE support (new entry-point file)
- [ ] Tooling / installer (`bin/install.sh`, scripts)
- [ ] Chore (deps, config, repo housekeeping)

## Changes

Brief bulleted list of what's added/modified/removed.

- (file/area) — what changed

## Testing

- [ ] Ran `bin/install.sh /tmp/test-project` against a fresh empty dir and verified files copied.
- [ ] Verified cross-references in docs aren't broken (`grep -rn` for renamed files).
- [ ] (If new skill) Skill description triggers correctly when described to CC.
- [ ] (If new standard) Existing skills referencing the standard still work.

## Checklist

- [ ] Updated `CHANGELOG.md` under the next unreleased version.
- [ ] Followed style in `CONTRIBUTING.md` (file size limits, English-only, lists over paragraphs).
- [ ] Dogfooded the engineering discipline (`template/docs/standards/base.md` §1–4): minimum code, surgical changes, verifiable outcomes.
- [ ] Updated `README.md` if surface-level features changed.
- [ ] If touching `template/docs/standards/base.md`, double-checked `CLAUDE.md` / `AGENTS.md` for drift.

## Related

- Closes #
- Refs #
