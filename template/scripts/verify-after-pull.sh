#!/usr/bin/env bash
# verify-after-pull.sh — run after `git pull` from Lovable's branch.
# Reports lane-crossing risks + runs lint + build.

set -uo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RESET='\033[0m'

EXIT_CODE=0

# CC-owned globs that LV should NOT touch (mirror OWNERSHIP.md)
CC_PATHS=(
  "src/components/"
  "src/pages/"
  "src/contracts/"
  "src/hooks/"
  "src/contexts/"
  "src/styles/"
  "src/lib/"
  "control-center/"
  "CLAUDE.md"
  "OWNERSHIP.md"
  "AGENTS.md"
  "docs/standards/"
  "ai-specs/"
  "scripts/"
  "README.md"
  ".env.example"
)

# Allowed exceptions (LV-owned despite being inside CC-owned globs)
ALLOWED=(
  "src/components/ui/"
  "src/pages/Auth/"
  "src/contexts/AuthContext.tsx"
  "src/hooks/useAuth"
  "src/hooks/useSession"
  "src/integrations/supabase/"
  "control-center/lv-responses/"
  "control-center/lv-blockers/"
  "control-center/cw-reports/"
)

echo "==> Verify-after-pull starting..."
echo ""

# 1. Determine commit range to audit
# Default: last 10 commits. Override with VERIFY_RANGE.
RANGE="${VERIFY_RANGE:-HEAD~10..HEAD}"
echo "Auditing commit range: $RANGE"
echo ""

# 2. List files changed in the range
CHANGED_FILES=$(git diff --name-only "$RANGE" 2>/dev/null || git diff --name-only HEAD~1..HEAD)

if [[ -z "$CHANGED_FILES" ]]; then
    echo "No files changed in $RANGE. Nothing to verify."
    exit 0
fi

# 3. Audit for lane crossings
echo "==> Auditing lane crossings..."
CROSSINGS=0
while IFS= read -r file; do
    [[ -z "$file" ]] && continue

    # Check if file is in a CC-owned path
    is_cc_owned=false
    for cc in "${CC_PATHS[@]}"; do
        if [[ "$file" == "$cc"* || "$file" == "$cc" ]]; then
            is_cc_owned=true
            break
        fi
    done

    [[ "$is_cc_owned" == false ]] && continue

    # Check allowed exceptions
    is_allowed=false
    for ok in "${ALLOWED[@]}"; do
        if [[ "$file" == "$ok"* || "$file" == "$ok" ]]; then
            is_allowed=true
            break
        fi
    done

    if [[ "$is_allowed" == false ]]; then
        # Check the author of the most recent commit touching this file
        AUTHOR=$(git log -1 --format='%an' -- "$file" 2>/dev/null)
        if [[ "$AUTHOR" == *"lovable"* || "$AUTHOR" == *"Lovable"* ]]; then
            echo -e "${RED}  ⚠ Lane crossing:${RESET} $file (last touched by $AUTHOR)"
            CROSSINGS=$((CROSSINGS+1))
            EXIT_CODE=1
        else
            echo -e "${YELLOW}  ~ CC-owned modified:${RESET} $file (by $AUTHOR — assumed intentional)"
        fi
    fi
done <<< "$CHANGED_FILES"

if [[ $CROSSINGS -eq 0 ]]; then
    echo -e "${GREEN}  ✓ No Lovable lane crossings detected.${RESET}"
fi
echo ""

# 4. Run lint (if configured)
if [[ -f package.json ]] && grep -q '"lint"' package.json; then
    echo "==> Running npm run lint..."
    if npm run lint --silent 2>&1 | tail -20; then
        echo -e "${GREEN}  ✓ Lint passed.${RESET}"
    else
        echo -e "${RED}  ✗ Lint failed.${RESET}"
        EXIT_CODE=1
    fi
    echo ""
fi

# 5. Run build
if [[ -f package.json ]] && grep -q '"build"' package.json; then
    echo "==> Running npm run build..."
    if npm run build --silent 2>&1 | tail -30; then
        echo -e "${GREEN}  ✓ Build passed.${RESET}"
    else
        echo -e "${RED}  ✗ Build failed.${RESET}"
        EXIT_CODE=1
    fi
    echo ""
fi

# 6. Summary
if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}==> Verify passed. Safe to wire frontend.${RESET}"
    echo "    Next: read control-center/lv-responses/<latest>.md (use lv-response-reader skill)."
else
    echo -e "${RED}==> Verify found issues. Address before wiring frontend.${RESET}"
    echo "    - Lane crossings: review each file's diff, decide revert vs accept."
    echo "    - Lint/build failures: fix root cause."
fi

exit $EXIT_CODE
