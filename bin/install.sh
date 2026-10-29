#!/usr/bin/env bash
set -euo pipefail

# cclv-specboot installer
# Usage: bash bin/install.sh [--stack tanstack-start|vite-edge] /path/to/your/project

usage() {
    echo "Usage: bin/install.sh [--stack tanstack-start|vite-edge] /path/to/your/project"
    echo ""
    echo "Installs the cclv-specboot template into a target project directory."
    echo "Non-destructive: existing files are never overwritten. AGENTS.md gets a"
    echo "marked CCLV block added next to Lovable's own content."
}

STACK=""; TARGET=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --stack)
            [[ -n "${2:-}" ]] || { echo "Error: --stack needs a value"; usage; exit 1; }
            STACK="$2"
            shift 2
            ;;
        -h|--help) usage; exit 0 ;;
        -*) echo "Error: unknown option $1"; usage; exit 1 ;;
        *)
            [[ -z "$TARGET" ]] || { echo "Error: more than one target directory given"; usage; exit 1; }
            TARGET="$1"
            shift
            ;;
    esac
done

if [[ -z "$TARGET" ]]; then
    usage
    exit 1
fi

if [[ ! -d "$TARGET" ]]; then
    echo "Error: target directory does not exist: $TARGET"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$REPO_ROOT/template"
VERSION="$(cat "$REPO_ROOT/VERSION" 2>/dev/null || echo unknown)"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "Error: template directory not found at $TEMPLATE_DIR"
    echo "Run this script from a cclv-specboot clone, not from a copy of bin/."
    exit 1
fi

# Which Lovable scaffold is this? See stacks/README.md.
detect_stack() {
    local t="$1"
    if [[ -f "$t/package.json" ]] && grep -q '"@tanstack/react-start"' "$t/package.json"; then
        echo tanstack-start
    elif [[ -f "$t/src/routes/__root.tsx" ]]; then
        echo tanstack-start
    elif [[ -f "$t/.lovable/project.json" ]] && grep -qi 'tanstack' "$t/.lovable/project.json"; then
        echo tanstack-start
    elif ls "$t"/vite.config.* >/dev/null 2>&1 && [[ -d "$t/src/pages" || -f "$t/src/App.tsx" || -f "$t/index.html" ]]; then
        echo vite-edge
    fi
}

STACK_NOTE="(--stack)"
if [[ -z "$STACK" ]]; then
    STACK="$(detect_stack "$TARGET")"
    STACK_NOTE="(detected)"
    if [[ -z "$STACK" ]]; then
        STACK=tanstack-start
        STACK_NOTE="(no app found; Lovable's current default)"
    fi
fi
STACK_DIR="$REPO_ROOT/stacks/$STACK"
if [[ ! -d "$STACK_DIR" ]]; then
    echo "Error: unknown stack '$STACK'. Choose one of: $(ls "$REPO_ROOT/stacks" | grep -v README | tr '\n' ' ')"
    exit 1
fi

echo "==> Installing cclv-specboot v$VERSION into $TARGET..."
echo "  Stack: $STACK $STACK_NOTE"

# insert_stack FILE — replace each "<!-- cclv:stack NAME -->" line with stacks/$STACK/NAME.md.
insert_stack() {
    local f="$1" tmp
    grep -q '^<!-- cclv:stack [a-z-]* -->$' "$f" || return 0
    tmp="$(mktemp)"
    awk -v dir="$STACK_DIR" '
        /^<!-- cclv:stack [a-z-]+ -->$/ {
            name = $0
            sub(/^<!-- cclv:stack /, "", name)
            sub(/ -->$/, "", name)
            file = dir "/" name ".md"
            while ((getline line < file) > 0) print line
            close(file)
            next
        }
        { print }' "$f" > "$tmp"
    cat "$tmp" > "$f"
    rm -f "$tmp"
}

# Copy template content, never overwriting existing files.
# NOTE: `cp -rn` exits 1 on macOS when it skips an existing file, which under
# `set -euo pipefail` kills the script right here. Use a per-file loop instead
# so an existing file is just skipped, not a failure.
# AGENTS.md is merged separately below; OWNERSHIP.md comes from the stack.
COPIED=0; SKIPPED=0; SKIPPED_KEY=""; STALE_SCRIPTS=""
copy_file() {
    local src="$1" rel="$2" dest="$TARGET/$2"
    if [[ -e "$dest" ]]; then
        SKIPPED=$((SKIPPED+1))
        case "$rel" in
            CLAUDE.md|OWNERSHIP.md|control-center/lovable-knowledge.md) SKIPPED_KEY+=" $rel" ;;
            scripts/*) cmp -s "$src" "$dest" || STALE_SCRIPTS+=" $rel" ;;
        esac
    else
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        insert_stack "$dest"
        COPIED=$((COPIED+1))
    fi
}
while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [[ "$rel" == "AGENTS.md" ]] && continue
    copy_file "$TEMPLATE_DIR/$rel" "$rel"
done < <(cd "$TEMPLATE_DIR" && find . -type f -print0)
copy_file "$STACK_DIR/OWNERSHIP.md" "OWNERSHIP.md"
echo "  ✓ Copied $COPIED files, skipped $SKIPPED existing"

# AGENTS.md: Lovable keeps its own root AGENTS.md (and appends rules to it), and
# nearly every coding agent reads it. Add the CCLV routing block instead of skipping.
BLOCK_FILE="$(mktemp)"
awk '/<!-- CCLV:BEGIN -->/ {f = 1} f {print} /<!-- CCLV:END -->/ {f = 0}' "$TEMPLATE_DIR/AGENTS.md" > "$BLOCK_FILE"
if [[ ! -e "$TARGET/AGENTS.md" ]]; then
    cp "$TEMPLATE_DIR/AGENTS.md" "$TARGET/AGENTS.md"
    echo "  ✓ Created AGENTS.md (CCLV routing block)"
elif grep -qF '<!-- CCLV:BEGIN -->' "$TARGET/AGENTS.md"; then
    echo "  ✓ AGENTS.md already has a CCLV block (left as is)"
else
    TMP="$(mktemp)"
    if grep -qF '<!-- LOVABLE:END -->' "$TARGET/AGENTS.md"; then
        awk -v bf="$BLOCK_FILE" '
            { print }
            /<!-- LOVABLE:END -->/ && !done {
                print ""
                while ((getline line < bf) > 0) print line
                close(bf)
                done = 1
            }' "$TARGET/AGENTS.md" > "$TMP"
    else
        { cat "$BLOCK_FILE"; echo ""; cat "$TARGET/AGENTS.md"; } > "$TMP"
    fi
    cat "$TMP" > "$TARGET/AGENTS.md"
    rm -f "$TMP"
    echo "  ✓ Added the CCLV routing block to your existing AGENTS.md (Lovable's content kept)"
fi
rm -f "$BLOCK_FILE"

if grep -qF 'You are Lovable (LV)' "$TARGET/AGENTS.md"; then
    echo "  ! AGENTS.md still contains the v0.3 lane sheet (\"You are Lovable (LV)\")."
    echo "    Every coding agent reads AGENTS.md, so they'd all take the LV role. Remove that"
    echo "    sheet and keep only the CCLV block + Lovable's own notes (CHANGELOG 0.4.0, migration step 2)."
fi
if [[ -n "$SKIPPED_KEY" ]]; then
    echo "  ! These files already existed and were NOT replaced:$SKIPPED_KEY"
    echo "    Compare them with the kit's versions (template/ and stacks/$STACK/) and merge by hand."
fi
if [[ -n "$STALE_SCRIPTS" ]]; then
    echo "  ! These scripts differ from this kit version and were NOT replaced:$STALE_SCRIPTS"
    echo "    Delete them and re-run the installer to get the current ones (keep local edits elsewhere)."
fi

# Make scripts executable
if [[ -d "$TARGET/scripts" ]]; then
    find "$TARGET/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
fi

# Merge .gitignore.append into the project's .gitignore (don't overwrite)
if [[ -f "$TARGET/.gitignore.append" ]]; then
    MARKER="# === Appended by cclv-specboot ==="
    if [[ -f "$TARGET/.gitignore" ]] && grep -qxF "$MARKER" "$TARGET/.gitignore" 2>/dev/null; then
        echo "  ✓ .gitignore already has cclv-specboot patterns (skipped)"
    else
        [[ -f "$TARGET/.gitignore" ]] && echo "" >> "$TARGET/.gitignore"
        echo "$MARKER" >> "$TARGET/.gitignore"
        while IFS= read -r line; do
            # Comments and blanks pass through; patterns only if not already present.
            [[ -z "$line" || "$line" == "#"* ]] && echo "$line" >> "$TARGET/.gitignore" && continue
            grep -qxF "$line" "$TARGET/.gitignore" 2>/dev/null || echo "$line" >> "$TARGET/.gitignore"
        done < "$TARGET/.gitignore.append"
        echo "  ✓ Merged cclv-specboot patterns into .gitignore"
    fi
    rm -f "$TARGET/.gitignore.append"
fi

# Set up .claude/skills/ and .claude/agents/ symlinks (macOS/Linux only)
if [[ "$OSTYPE" == "darwin"* || "$OSTYPE" == "linux"* ]]; then
    if [[ -d "$TARGET/ai-specs/skills" ]]; then
        mkdir -p "$TARGET/.claude/skills"
        for skill_dir in "$TARGET/ai-specs/skills"/*/; do
            [[ ! -d "$skill_dir" ]] && continue
            skill_name=$(basename "$skill_dir")
            link_path="$TARGET/.claude/skills/$skill_name"
            if [[ ! -e "$link_path" ]]; then
                ln -s "../../ai-specs/skills/$skill_name" "$link_path"
                echo "  ✓ symlink .claude/skills/$skill_name → ai-specs/skills/$skill_name"
            fi
        done
    fi
    # CW runs as a Claude Code subagent. (cc-architect duplicates the main
    # session and lv-backend is Lovable's persona, so neither is linked.)
    if [[ -f "$TARGET/ai-specs/agents/cw-reviewer.md" ]]; then
        mkdir -p "$TARGET/.claude/agents"
        if [[ ! -e "$TARGET/.claude/agents/cw-reviewer.md" ]]; then
            ln -s "../../ai-specs/agents/cw-reviewer.md" "$TARGET/.claude/agents/cw-reviewer.md"
            echo "  ✓ symlink .claude/agents/cw-reviewer.md → ai-specs/agents/cw-reviewer.md"
        fi
    fi
else
    echo "  ! Skipping .claude/ symlinks (non-UNIX OS detected: $OSTYPE)"
    echo "    Either enable developer mode (Windows) or copy ai-specs/skills/* and"
    echo "    ai-specs/agents/cw-reviewer.md into .claude/ manually."
fi

echo "$VERSION" > "$TARGET/.cclv-specboot-version"

echo ""
echo "✓ Template copied (existing files preserved)"
echo ""
echo "Next steps:"
echo "  1. Fill {{PLACEHOLDERS}} in CLAUDE.md, AGENTS.md, OWNERSHIP.md and control-center/:"
echo "       grep -rlE '\{\{[A-Z_]+\}\}' \"$TARGET\" --exclude-dir=node_modules --exclude-dir=.git"
echo "  2. Connect the Lovable MCP (recommended):"
echo "       claude mcp add --transport http lovable https://mcp.lovable.dev"
echo "  3. Sync LV's Project Instructions: with the MCP, ask CC to run the kb-sync skill;"
echo "     without it, paste control-center/lovable-knowledge.md into Lovable → Project settings → Instructions"
echo "  4. Push AGENTS.md to the branch Lovable syncs: it's the repo file Lovable always reads"
if [[ -d "$TARGET/.specify" ]]; then
    echo "  5. Spec Kit detected (.specify/): split each tasks.md with the spec-lanes skill before /speckit-implement"
else
    echo "  5. Optional, Spec Kit as the spec layer (see INSTALL.md):"
    echo "       uv tool install specify-cli && specify init --here --integration claude"
fi
echo "  6. After your first pull from Lovable: bash scripts/verify-after-pull.sh"
echo "  7. See INSTALL.md for full setup details"
