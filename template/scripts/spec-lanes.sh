#!/usr/bin/env bash
# spec-lanes.sh — split a Spec Kit tasks.md into CC / LV lanes using OWNERSHIP.md.
#
# Stock /speckit-implement runs EVERY task in tasks.md, including LV's backend work.
# Spec Kit tasks always name their file paths, so each task's lane follows from
# OWNERSHIP.md. This prints the split and the scoped implement call for CC.
#
# Usage:
#   bash scripts/spec-lanes.sh [specs/NNN-feature/tasks.md]   # default: newest tasks.md
#   bash scripts/spec-lanes.sh --ids LV [tasks.md]             # just the IDs, comma-separated

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lanes.sh
source "$SCRIPT_DIR/lib/lanes.sh"

ONLY=""
if [[ "${1:-}" == "--ids" ]]; then
    ONLY="${2:-}"
    shift 2 || { echo "Usage: spec-lanes.sh --ids CC|LV|CW|MIXED|UNKNOWN [tasks.md]"; exit 1; }
fi

TASKS="${1:-}"
if [[ -n "$TASKS" && -f "$TASKS" ]]; then
    TASKS="$(cd "$(dirname "$TASKS")" && pwd)/$(basename "$TASKS")"
fi
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 1

if [[ -z "$TASKS" ]]; then
    TASKS=$(ls -t specs/*/tasks.md 2>/dev/null | head -1)
fi
if [[ -z "$TASKS" || ! -f "$TASKS" ]]; then
    echo "No tasks.md found. Run /speckit-tasks first, or pass the path."
    exit 1
fi
lanes_load OWNERSHIP.md || exit 1

# task_paths DESC — words that look like repo paths (contain "/" or end in a file extension).
task_paths() {
    local word words
    read -r -a words <<< "$(printf '%s' "$1" | tr -d '`"'"'"'()')"
    for word in "${words[@]+"${words[@]}"}"; do
        word="${word%[.,;:]}"
        [[ "$word" == http* ]] && continue
        if [[ "$word" == */* || "$word" =~ \.[A-Za-z]{1,6}$ ]]; then
            printf '%s\n' "$word"
        fi
    done
}

CC_IDS=""; LV_IDS=""; CW_IDS=""; MIXED_IDS=""; UNKNOWN_IDS=""; DONE=0; ROWS=""
TASK_RE='^[[:space:]]*- \[([ xX])\] (T[0-9]+) (.*)$'
while IFS= read -r line; do
    [[ "$line" =~ $TASK_RE ]] || continue
    state="${BASH_REMATCH[1]}"; id="${BASH_REMATCH[2]}"; desc="${BASH_REMATCH[3]}"
    if [[ "$state" != " " ]]; then
        DONE=$((DONE+1))
        continue
    fi
    # cc_only / lv_only: paths only that agent may edit; both: Shared or CC+LV paths.
    cc_only=0; lv_only=0; both=0; cw=0; mapped=""
    while IFS= read -r path; do
        [[ -z "$path" ]] && continue
        owners=$(lane_owner "$path")
        [[ -z "$owners" ]] && continue
        mapped+="$path "
        if lane_allows "$owners" CC && lane_allows "$owners" LV; then both=1
        elif lane_allows "$owners" CC; then cc_only=1
        elif lane_allows "$owners" LV; then lv_only=1
        elif lane_allows "$owners" CW; then cw=1
        fi
    done < <(task_paths "$desc")

    if [[ $lv_only -eq 1 && $cc_only -eq 1 ]]; then lane=MIXED; MIXED_IDS+="$id, "
    elif [[ $lv_only -eq 1 ]]; then lane=LV; LV_IDS+="$id, "
    elif [[ $cc_only -eq 1 || $both -eq 1 ]]; then lane=CC; CC_IDS+="$id, "
    elif [[ $cw -eq 1 ]]; then lane=CW; CW_IDS+="$id, "
    else lane=UNKNOWN; UNKNOWN_IDS+="$id, "
    fi
    ROWS+="$(printf '%-6s %-8s %s' "$id" "$lane" "${mapped:-(no mapped paths)}")"$'\n'
done < "$TASKS"

trim() { printf '%s' "${1%, }"; }

if [[ -n "$ONLY" ]]; then
    case "$ONLY" in
        CC) trim "$CC_IDS" ;; LV) trim "$LV_IDS" ;; CW) trim "$CW_IDS" ;;
        MIXED) trim "$MIXED_IDS" ;; UNKNOWN) trim "$UNKNOWN_IDS" ;;
        *) echo "Unknown lane: $ONLY" >&2; exit 1 ;;
    esac
    echo
    exit 0
fi

echo "==> Lanes for $TASKS (per OWNERSHIP.md)"
echo ""
printf '%s' "$ROWS"
echo ""
echo "CC:      $(trim "$CC_IDS")"
echo "LV:      $(trim "$LV_IDS")"
[[ -n "$CW_IDS" ]] && echo "CW:      $(trim "$CW_IDS")"
[[ -n "$MIXED_IDS" ]] && echo "MIXED:   $(trim "$MIXED_IDS")  ← split each into a CC task and an LV task before implementing"
[[ -n "$UNKNOWN_IDS" ]] && echo "UNKNOWN: $(trim "$UNKNOWN_IDS")  ← no OWNERSHIP.md row for their paths; CC decides, then add rows"
echo "Done:    $DONE"
echo ""
echo "Next:"
[[ -n "$LV_IDS" ]] && echo "  1. Send the LV tasks to Lovable with the lv-prompt-writer skill: $(trim "$LV_IDS")."
if [[ -n "$CC_IDS" ]]; then
    echo "  2. In Claude Code, run:"
    echo "     /speckit-implement Implement ONLY tasks $(trim "$CC_IDS") (CC lane). Do not implement, edit files for, or mark any other task: LV tasks are delivered by Lovable."
fi
echo "  3. After Lovable pushes and verify-after-pull passes, CC ticks the LV tasks [X]."
