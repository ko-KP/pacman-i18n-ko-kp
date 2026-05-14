#!/bin/bash
# update-translations.sh
# Updates local .po files from upstream pacman .pot files.
# Usage: ./scripts/update-translations.sh [--upstream-dir <path>]
# Defaults to ../pacman if no --upstream-dir is provided.

set -euo pipefail

UPSTREAM_PACMAN_DIR="../pacman"
PO_DIR="$(cd "$(dirname "$0")/.." && pwd)/po"

while [[ $# -gt 0 ]]; do
    case $1 in
        --upstream-dir)
            UPSTREAM_PACMAN_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

if [ ! -d "$UPSTREAM_PACMAN_DIR" ]; then
    echo "Error: Upstream pacman directory not found at $UPSTREAM_PACMAN_DIR" >&2
    exit 1
fi

# Map local PO files to upstream POT files (relative to UPSTREAM_PACMAN_DIR)
declare -A POT_MAP
POT_MAP=(
    ["libalpm.ko_KP.po"]="lib/libalpm/po/libalpm.pot"
    ["pacman.ko_KP.po"]="src/pacman/po/pacman.pot"
    ["pacman-scripts.ko_KP.po"]="scripts/po/pacman-scripts.pot"
)

echo "Upstream dir: $UPSTREAM_PACMAN_DIR"
echo "Checking for upstream translation updates..."
echo "------------------------------------------"

HAS_CHANGES=0

for po_file in "${!POT_MAP[@]}"; do
    local_po="$PO_DIR/$po_file"
    upstream_pot="$UPSTREAM_PACMAN_DIR/${POT_MAP[$po_file]}"

    if [ ! -f "$upstream_pot" ]; then
        echo "Warning: Upstream POT file not found: $upstream_pot" >&2
        continue
    fi

    if [ ! -f "$local_po" ]; then
        echo "Warning: Local PO file not found: $local_po" >&2
        continue
    fi

    echo "Updating $po_file..."
    msgmerge --update --no-wrap --no-fuzzy-matching --backup=none "$local_po" "$upstream_pot"

    # Check for new untranslated strings (fuzzy or empty)
    STATS=$(msgfmt --statistics "$local_po" 2>&1)
    echo "Status: $STATS"

    # Detect if msgmerge made any changes
    if git diff --quiet "$local_po" 2>/dev/null; then
        echo "(no changes)"
    else
        echo "(changes detected)"
        HAS_CHANGES=1
    fi
    echo "------------------------------------------"
done

echo "Done."

# Exit with code 1 if changes were detected (useful in CI)
if [ "$HAS_CHANGES" -eq 1 ]; then
    echo "New or changed strings were found in upstream pacman."
    exit 1
fi

exit 0
