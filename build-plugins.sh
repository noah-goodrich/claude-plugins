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
MARKETPLACE_JSON="$SCRIPT_DIR/.claude-plugin/marketplace.json"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
info() { echo -e "${GREEN}[build]${NC} $1"; }
err() { echo -e "${RED}[build]${NC} $1" >&2; }

# A plugin is only reachable if BOTH halves exist: the marketplace.json entry
# (how an installer finds it) and the on-disk .claude-plugin/plugin.json (what
# an installer installs). Either half alone is dead weight, and the packaging
# loop below skips manifest-less directories silently, so nothing else in this
# repo notices. Both directions are fatal.
verify_marketplace() {
    local entries listed_dirs plugin_dir name src dir manifest
    local failed=0

    if [ ! -f "$MARKETPLACE_JSON" ]; then
        err "marketplace manifest not found: .claude-plugin/marketplace.json"
        return 1
    fi

    if ! entries=$(jq -er '.plugins[] | [.name, .source] | @tsv' "$MARKETPLACE_JSON" 2>&1); then
        err "cannot read .plugins[] from .claude-plugin/marketplace.json:"
        err "    $entries"
        return 1
    fi

    listed_dirs=""
    while IFS=$'\t' read -r name src; do
        [ -n "$name" ] || continue
        dir="${src#./}"
        dir="${dir%/}"
        listed_dirs="$listed_dirs$dir"$'\n'
        manifest="$SCRIPT_DIR/$dir/.claude-plugin/plugin.json"
        if [ ! -f "$manifest" ]; then
            err "$name — listed in marketplace.json but has no plugin manifest"
            err "    expected: $dir/.claude-plugin/plugin.json"
            failed=1
        fi
    done <<< "$entries"

    for plugin_dir in "$SCRIPT_DIR"/*/; do
        [ -f "$plugin_dir.claude-plugin/plugin.json" ] || continue
        dir="${plugin_dir%/}"
        dir="${dir##*/}"
        if ! printf '%s' "$listed_dirs" | grep -qxF "$dir"; then
            err "$dir — has a plugin manifest but is not listed in marketplace.json"
            err "    no installer can discover it; add an entry with \"source\": \"./$dir\""
            failed=1
        fi
    done

    if [ "$failed" -ne 0 ]; then
        err "marketplace and plugin manifests are out of sync — nothing was built"
        return 1
    fi

    info "marketplace guard: every listed plugin has a manifest, and vice versa"
}

verify_marketplace

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
