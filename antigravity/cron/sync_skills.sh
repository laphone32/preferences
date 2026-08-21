#!/usr/bin/env bash

# Sourcing this file inside preferences-cron-runner requires 'return' instead of 'exit'
# to prevent terminating the main cron runner process.

if [ -z "$PREFERENCES_DIR" ]; then
    export PREFERENCES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
fi

source "$PREFERENCES_DIR/util/bootstrap.sh"
source "$PREFERENCES_DIR/antigravity/common.sh"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Checking Antigravity Configuration & Skills Symlinks..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check AGENTS.md symlink
if [ -f "$PREFERENCES_ANTIGRAVITY/config/AGENTS.md" ]; then
    TARGET="$PREFERENCES_ANTIGRAVITY_GLOBAL_CONFIG/AGENTS.md"
    EXPECTED="$PREFERENCES_ANTIGRAVITY/config/AGENTS.md"
    if [ -L "$TARGET" ] && [ "$(readlink -f "$TARGET")" = "$(readlink -f "$EXPECTED")" ]; then
        echo "✓ AGENTS.md symlink is intact ($TARGET -> $EXPECTED)."
    else
        echo "⚠ AGENTS.md symlink is missing or crushed. Re-linking..."
        installPreferencesSymlink "$EXPECTED" "$TARGET"
        if [ -L "$TARGET" ] && [ "$(readlink -f "$TARGET")" = "$(readlink -f "$EXPECTED")" ]; then
            echo "✓ Successfully re-linked AGENTS.md."
        else
            echo "⚠ Failed to re-link AGENTS.md."
        fi
    fi
fi

# Ensure global skills target is a real directory (remove top-level symlink if present)
if [ -L "$PREFERENCES_ANTIGRAVITY_GLOBAL_SKILLS" ]; then
    rm -f "$PREFERENCES_ANTIGRAVITY_GLOBAL_SKILLS"
fi
installPreferencesDir "$PREFERENCES_ANTIGRAVITY_GLOBAL_SKILLS"

# Clean up broken skill symlinks
if [ -d "$PREFERENCES_ANTIGRAVITY_GLOBAL_SKILLS" ]; then
    for link in "$PREFERENCES_ANTIGRAVITY_GLOBAL_SKILLS"/*; do
        if [ -L "$link" ] && [ ! -e "$link" ]; then
            echo "🧹 Removing broken skill symlink: $(basename "$link")"
            rm -f "$link"
        fi
    done
fi

if [ -d "$PREFERENCES_ANTIGRAVITY/skills" ]; then
    for skill_path in "$PREFERENCES_ANTIGRAVITY/skills"/*; do
        if [ -d "$skill_path" ]; then
            skill_name="$(basename "$skill_path")"
            TARGET="$PREFERENCES_ANTIGRAVITY_GLOBAL_SKILLS/$skill_name"
            EXPECTED="$skill_path"
            
            # Check if target is a valid symlink pointing to expected directory
            if [ -L "$TARGET" ] && [ "$(readlink -f "$TARGET")" = "$(readlink -f "$EXPECTED")" ]; then
                echo "✓ Skill '$skill_name' symlink is intact ($TARGET -> $EXPECTED)."
            else
                echo "⚠ Skill '$skill_name' symlink is missing or crushed. Re-linking..."
                installPreferencesSymlink "$EXPECTED" "$TARGET"
                if [ -L "$TARGET" ] && [ "$(readlink -f "$TARGET")" = "$(readlink -f "$EXPECTED")" ]; then
                    echo "✓ Successfully re-linked skill '$skill_name'."
                else
                    echo "⚠ Failed to re-link skill '$skill_name'."
                fi
            fi
        fi
    done
fi

echo ""
