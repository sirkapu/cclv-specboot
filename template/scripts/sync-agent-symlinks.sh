#!/usr/bin/env bash
# sync-agent-symlinks.sh — refresh .claude/skills/ symlinks after adding/removing skills.

set -euo pipefail

if [[ "$OSTYPE" != "darwin"* && "$OSTYPE" != "linux"* ]]; then
    echo "This script uses symlinks; requires macOS or Linux (current: $OSTYPE)."
    echo "On Windows, copy ai-specs/skills/* into .claude/skills/* manually."
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/ai-specs/skills"
SKILLS_DST="$REPO_ROOT/.claude/skills"

if [[ ! -d "$SKILLS_SRC" ]]; then
    echo "ai-specs/skills/ not found. Nothing to sync."
    exit 0
fi

mkdir -p "$SKILLS_DST"

# Remove broken symlinks
echo "==> Cleaning broken symlinks in .claude/skills/..."
find "$SKILLS_DST" -maxdepth 1 -type l ! -exec test -e {} \; -print -delete 2>/dev/null || true

# Add missing symlinks
echo "==> Adding missing symlinks..."
ADDED=0
for skill_dir in "$SKILLS_SRC"/*/; do
    [[ ! -d "$skill_dir" ]] && continue
    skill_name=$(basename "$skill_dir")
    link_path="$SKILLS_DST/$skill_name"
    if [[ ! -e "$link_path" ]]; then
        ln -s "../../ai-specs/skills/$skill_name" "$link_path"
        echo "  ✓ $skill_name"
        ADDED=$((ADDED+1))
    fi
done

if [[ $ADDED -eq 0 ]]; then
    echo "  All symlinks already in place."
fi

# Report
echo ""
echo "==> Current symlinks:"
ls -la "$SKILLS_DST" | grep -E '^l' || echo "  (none)"
