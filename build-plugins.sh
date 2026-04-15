#!/usr/bin/env bash
# =============================================================================
# Build .plugin files from source directories
# Produces installable .plugin files in dist/
# Versions are managed manually in each plugin's plugin.json — bump before
# publishing a real change. Auto-bump was removed to prevent version drift
# across machines.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"

GREEN='\033[0;32m'
NC='\033[0m'
info() { echo -e "${GREEN}[build]${NC} $1"; }

mkdir -p "$DIST_DIR"

for plugin_dir in "$SCRIPT_DIR"/*/; do
    plugin_name=$(basename "$plugin_dir")
    plugin_json="$plugin_dir/.claude-plugin/plugin.json"

    # Verify it's a valid plugin
    if [ ! -f "$plugin_json" ]; then
        continue
    fi

    current_version=$(grep '"version"' "$plugin_json" | sed 's/.*"\([0-9]*\.[0-9]*\.[0-9]*\)".*/\1/')
    info "Packaging $plugin_name  ($current_version)..."

    # Build to /tmp first, then copy (avoids issues with some mounted filesystems).
    # COPYFILE_DISABLE=1 prevents macOS zip from adding __MACOSX/ resource fork
    # entries, which cause Cowork's plugin parser to reject the upload.
    (cd "$plugin_dir" && COPYFILE_DISABLE=1 zip -r "/tmp/$plugin_name.plugin" . \
        -x "*.DS_Store" -x "__MACOSX/*" -x "*/._*" > /dev/null)
    cp "/tmp/$plugin_name.plugin" "$DIST_DIR/$plugin_name.plugin"
    rm "/tmp/$plugin_name.plugin"
    info "  → dist/$plugin_name.plugin"
done

echo ""
info "Done. Install .plugin files via Cowork UI (drag or 'Copy to your skills')."
ls -lh "$DIST_DIR"/*.plugin 2>/dev/null
