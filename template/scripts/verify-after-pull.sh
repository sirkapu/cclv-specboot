#!/usr/bin/env bash
# verify-after-pull.sh — run right after `git pull` brings in Lovable's commits.
# Audits lane crossings in exactly what was pulled (per OWNERSHIP.md), then runs lint + build.
#
#   VERIFY_RANGE=<base>..<tip>   audit this range instead (default: ORIG_HEAD..HEAD)
#   LOVABLE_AUTHOR_REGEX=<ERE>   override how Lovable's commits are recognised

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lanes.sh
source "$SCRIPT_DIR/lib/lanes.sh"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RESET='\033[0m'

EXIT_CODE=0

# Lovable's commits are authored by its GitHub app: lovable-dev[bot], which raw git log
# shows as gpt-engineer-app[bot] (its earlier name); scaffold commits may read "Lovable".
# On GitHub Enterprise Server it's <your-app-name>[bot] — set LOVABLE_AUTHOR_REGEX.
# Edit commits also carry an X-Lovable-Edit-ID trailer.
LOVABLE_AUTHOR_REGEX="${LOVABLE_AUTHOR_REGEX:-gpt-engineer-app\[bot\]|lovable-dev\[bot\]|^Lovable$}"

cd "$(git rev-parse --show-toplevel)" || exit 1

echo "==> Verify-after-pull starting..."
echo ""

# 1. Determine the commit range to audit
if [[ -n "${VERIFY_RANGE:-}" ]]; then
    RANGE="$VERIFY_RANGE"
elif git rev-parse -q --verify ORIG_HEAD >/dev/null && [[ "$(git rev-parse ORIG_HEAD)" != "$(git rev-parse HEAD)" ]]; then
    RANGE="ORIG_HEAD..HEAD"
elif git rev-parse -q --verify HEAD~1 >/dev/null; then
    RANGE="HEAD~1..HEAD"
    echo -e "${YELLOW}No pull to audit (ORIG_HEAD missing or equal to HEAD); auditing the last commit only. Set VERIFY_RANGE to audit more.${RESET}"
else
    RANGE="HEAD"
fi
if ! git rev-list "$RANGE" >/dev/null 2>&1; then
    echo -e "${RED}Invalid commit range: $RANGE${RESET}"
    exit 1
fi
BASE=""
[[ "$RANGE" == *..* ]] && BASE="${RANGE%%..*}"
TIP="${RANGE##*..}"
echo "Auditing commit range: $RANGE"

# Judge the pulled commits by the lane map as it was before them, so a commit
# can't move its own lanes. Fall back to the working-tree copy.
OWNERSHIP_FILE=OWNERSHIP.md
if [[ -n "$BASE" ]] && git cat-file -e "$BASE:OWNERSHIP.md" 2>/dev/null; then
    OWNERSHIP_FILE="$(mktemp)"
    git show "$BASE:OWNERSHIP.md" > "$OWNERSHIP_FILE"
    trap 'rm -f "$OWNERSHIP_FILE"' EXIT
fi
if ! lanes_load "$OWNERSHIP_FILE"; then
    echo -e "${RED}Cannot audit lanes without OWNERSHIP.md.${RESET}"
    exit 1
fi

is_lovable_commit() {
    if git log -1 --format='%an' "$1" | grep -Eq "$LOVABLE_AUTHOR_REGEX"; then
        return 0
    fi
    git log -1 --format='%B' "$1" | grep -q '^X-Lovable-Edit-ID:'
}

# Files a commit itself changed. For merges, only what the merge resolved (--cc),
# so files merged in from the other side are not attributed to the merge's author.
commit_files() {
    if [[ -n "$(git rev-list --no-walk --min-parents=2 "$1")" ]]; then
        git -c core.quotePath=false diff-tree --no-commit-id --name-only -r --cc "$1"
    else
        git -c core.quotePath=false diff-tree --no-commit-id --name-only -r --root "$1"
    fi
}

# 2. Split changed files by who committed them
LV_FILES=""; OTHER_FILES=""; LV_COMMITS=0; ALL_COMMITS=0
for sha in $(git rev-list "$RANGE"); do
    ALL_COMMITS=$((ALL_COMMITS+1))
    if is_lovable_commit "$sha"; then
        LV_COMMITS=$((LV_COMMITS+1))
        LV_FILES+=$'\n'"$(commit_files "$sha")"
    else
        OTHER_FILES+=$'\n'"$(commit_files "$sha")"
    fi
done
LV_FILES=$(printf '%s\n' "$LV_FILES" | sed '/^$/d' | sort -u)
OTHER_FILES=$(printf '%s\n' "$OTHER_FILES" | sed '/^$/d' | sort -u)
echo "Commits in range: $ALL_COMMITS ($LV_COMMITS by Lovable)"
echo ""

# The CC-owned part of AGENTS.md, between the CCLV markers.
cclv_block() {
    awk '/<!-- CCLV:BEGIN -->/ {f = 1} f {print} /<!-- CCLV:END -->/ {f = 0}'
}

# 3. Audit lane crossings
echo "==> Auditing lane crossings..."
CROSSINGS=0; UNMAPPED=0
while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    owners=$(lane_owner "$file")
    if [[ -z "$owners" ]]; then
        echo -e "${YELLOW}  ? No OWNERSHIP.md row:${RESET} $file (touched by Lovable) — add a row"
        UNMAPPED=$((UNMAPPED+1))
    elif [[ "$file" == "AGENTS.md" ]]; then
        if [[ -n "$BASE" ]] && [[ "$(git show "$BASE:AGENTS.md" 2>/dev/null | cclv_block)" != "$(git show "$TIP:AGENTS.md" 2>/dev/null | cclv_block)" ]]; then
            echo -e "${RED}  ⚠ Lane crossing:${RESET} AGENTS.md — Lovable edited the CCLV block (CC-owned)"
            CROSSINGS=$((CROSSINGS+1))
            EXIT_CODE=1
        else
            echo -e "${GREEN}  ✓ AGENTS.md:${RESET} Lovable updated its own part; the CCLV block is intact"
        fi
    elif ! lane_allows "$owners" LV; then
        echo -e "${RED}  ⚠ Lane crossing:${RESET} $file (owner: $owners) — touched by Lovable"
        CROSSINGS=$((CROSSINGS+1))
        EXIT_CODE=1
    fi
done <<< "$LV_FILES"

while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    owners=$(lane_owner "$file")
    if [[ "$owners" == "Human" ]]; then
        echo -e "${RED}  ⚠ Never commit:${RESET} $file (Human-only file)"
        EXIT_CODE=1
    elif [[ -n "$owners" ]] && ! lane_allows "$owners" CC; then
        echo -e "${YELLOW}  ~ LV-owned file changed outside Lovable:${RESET} $file (owner: $owners) — log it under Lane Crossings if it was CC"
    fi
done <<< "$OTHER_FILES"

if [[ $LV_COMMITS -eq 0 ]]; then
    echo "  (no Lovable commits in range — only non-Lovable changes were checked)"
elif [[ $CROSSINGS -eq 0 ]]; then
    echo -e "${GREEN}  ✓ No Lovable lane crossings detected.${RESET}"
fi
echo ""

# 4/5. Lint + build (bun when the project uses it, npm otherwise)
PM=npm
if [[ -f bun.lock || -f bun.lockb ]] && command -v bun >/dev/null 2>&1; then
    PM=bun
fi
for task in lint build; do
    if [[ -f package.json ]] && grep -q "\"$task\"" package.json; then
        echo "==> Running $PM run $task..."
        if $PM run "$task" 2>&1 | tail -30; then
            echo -e "${GREEN}  ✓ $task passed.${RESET}"
        else
            echo -e "${RED}  ✗ $task failed.${RESET}"
            EXIT_CODE=1
        fi
        echo ""
    fi
done

# 6. Summary
if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}==> Verify passed. Safe to wire frontend.${RESET}"
    echo "    Next: lv-response-reader (MCP reply + get_diff) if you haven't already."
else
    echo -e "${RED}==> Verify found issues. Address before wiring frontend.${RESET}"
    echo "    - Lane crossings: review each file's diff, decide revert vs accept (base.md §14)."
    echo "    - Lint/build failures: fix root cause."
fi
[[ $UNMAPPED -gt 0 ]] && echo "    - $UNMAPPED Lovable-touched file(s) have no OWNERSHIP.md row — add rows."

exit $EXIT_CODE
