#!/usr/bin/env bash
set -euo pipefail

# cclv-specboot installer
# Usage: bash bin/install.sh /path/to/your/project

TARGET="${1:-}"

if [[ -z "$TARGET" ]]; then
    echo "Usage: bin/install.sh /path/to/your/project"
    echo ""
    echo "Installs the cclv-specboot template into a target project directory."
    echo "Non-destructive — existing files are never overwritten."
    exit 1
fi

if [[ ! -d "$TARGET" ]]; then
    echo "Error: target directory does not exist: $TARGET"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$REPO_ROOT/template"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "Error: template directory not found at $TEMPLATE_DIR"
    echo "Run this script from a cclv-specboot clone, not from a copy of bin/."
    exit 1
fi

echo "==> Installing cclv-specboot v0.2.0 into $TARGET..."

# Copy template content (cp -rn: never overwrite existing files)
cp -rn "$TEMPLATE_DIR/." "$TARGET/"

# Make scripts executable
if [[ -d "$TARGET/scripts" ]]; then
    find "$TARGET/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
fi

# Merge .gitignore.append into the project's .gitignore (don't overwrite)
if [[ -f "$TARGET/.gitignore.append" ]]; then
    if [[ -f "$TARGET/.gitignore" ]]; then
        # Only append patterns not already present
        echo "" >> "$TARGET/.gitignore"
        echo "# === Appended by cclv-specboot ===" >> "$TARGET/.gitignore"
        while IFS= read -r line; do
            [[ -z "$line" || "$line" == "#"* ]] && echo "$line" >> "$TARGET/.gitignore" && continue
            grep -qxF "$line" "$TARGET/.gitignore" 2>/dev/null || echo "$line" >> "$TARGET/.gitignore"
        done < "$TARGET/.gitignore.append"
        echo "  ✓ Appended new patterns to .gitignore"
    else
        mv "$TARGET/.gitignore.append" "$TARGET/.gitignore"
        echo "  ✓ Created .gitignore from .gitignore.append"
    fi
    rm -f "$TARGET/.gitignore.append"
fi

# Set up .claude/skills/ symlinks (macOS/Linux only)
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
else
    echo "  ! Skipping .claude/skills/ symlinks (non-UNIX OS detected: $OSTYPE)"
    echo "    Either enable developer mode (Windows) or copy ai-specs/skills/* manually."
fi

echo ""
echo "✓ Template copied (existing files preserved)"
echo ""
echo "Next steps:"
echo "  1. Open CLAUDE.md, AGENTS.md, OWNERSHIP.md — fill {{PLACEHOLDERS}}:"
echo "       grep -rln '{{' \"$TARGET\""
echo "  2. Paste control-center/lovable-knowledge.md into Lovable → Settings → Knowledge"
echo "  3. Pin AGENTS.md and OWNERSHIP.md in Lovable"
echo "  4. Run: bash scripts/verify-after-pull.sh"
echo "  5. See INSTALL.md for full setup details"
