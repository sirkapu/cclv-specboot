#!/usr/bin/env bash
# lanes.sh — read OWNERSHIP.md and answer "who owns this path?".
# Sourced by verify-after-pull.sh and spec-lanes.sh. Bash 3.2 compatible (macOS).
#
# OWNERSHIP.md rows look like:  | `glob`[, `glob` ...] | OWNERS | notes |
# OWNERS is a comma-separated list of CC, LV, CW, Shared (= CC and LV) or Human.
# The most specific matching glob wins: file-kind rows (`**/*.functions.ts`) beat
# folder rows (`src/lib/**`); otherwise the glob with the most literal characters
# wins, and on a tie the earlier row. `**` and `*` both match across directories.

LANE_GLOBS=()
LANE_PATTERNS=()
LANE_SCORES=()
LANE_OWNERS=()

# lanes_load [FILE] — parse the ownership table (default: ./OWNERSHIP.md).
lanes_load() {
    local file="${1:-OWNERSHIP.md}" glob owners pattern literal score token
    LANE_GLOBS=(); LANE_PATTERNS=(); LANE_SCORES=(); LANE_OWNERS=()
    if [[ ! -f "$file" ]]; then
        echo "lanes: $file not found" >&2
        return 1
    fi
    while IFS=$'\t' read -r glob owners; do
        pattern="${glob//\*\*\//*}"
        pattern="${pattern//\*\*/*}"
        literal="${glob//\*/}"
        score=${#literal}
        [[ "$glob" == '**/'* ]] && score=$((score + 1000))
        owners="${owners// /}"
        for token in ${owners//,/ }; do
            case "$token" in
                CC|LV|CW|Shared|Human) ;;
                *) echo "lanes: unknown owner '$token' for \`$glob\` in $file (use CC, LV, CW, Shared or Human)" >&2 ;;
            esac
        done
        LANE_GLOBS+=("$glob")
        LANE_PATTERNS+=("$pattern")
        LANE_SCORES+=("$score")
        LANE_OWNERS+=("$owners")
    done < <(awk -F'|' '
        /^\| *`/ {
            owners = $3
            gsub(/^[ \t]+|[ \t]+$/, "", owners)
            cell = $2
            while (match(cell, /`[^`]+`/)) {
                print substr(cell, RSTART + 1, RLENGTH - 2) "\t" owners
                cell = substr(cell, RSTART + RLENGTH)
            }
        }' "$file")
    if [[ ${#LANE_GLOBS[@]} -eq 0 ]]; then
        echo "lanes: no ownership rows found in $file" >&2
        return 1
    fi
}

# lane_owner PATH — print the owners of the best-matching row ("" if none).
lane_owner() {
    local path="$1" best=-1 owners="" i
    for ((i = 0; i < ${#LANE_PATTERNS[@]}; i++)); do
        # Unquoted on purpose: the pattern is a glob.
        if [[ "$path" == ${LANE_PATTERNS[$i]} ]] && (( LANE_SCORES[i] > best )); then
            best=${LANE_SCORES[$i]}
            owners="${LANE_OWNERS[$i]}"
        fi
    done
    printf '%s' "$owners"
}

# lane_allows OWNERS ROLE — succeed if ROLE (CC, LV, CW) may edit a path with OWNERS.
lane_allows() {
    local owners=",${1// /}," role="$2"
    [[ "$owners" == *",$role,"* ]] && return 0
    [[ "$owners" == *",Shared,"* && ( "$role" == CC || "$role" == LV ) ]] && return 0
    return 1
}
