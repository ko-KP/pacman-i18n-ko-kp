#!/bin/bash
# translation-stats.sh
# Outputs translation progress for all .po files in the po/ directory.
# Optionally formats output as a Markdown table (--markdown flag).
#
# Usage:
#   ./scripts/translation-stats.sh
#   ./scripts/translation-stats.sh --markdown

set -euo pipefail

MARKDOWN=0
PO_DIR="$(cd "$(dirname "$0")/.." && pwd)/po"

for arg in "$@"; do
    case $arg in
        --markdown) MARKDOWN=1 ;;
    esac
done

# msgfmt --statistics outputs to stderr, LC_ALL=C ensures English output
parse_stats() {
    local po_file="$1"
    local stats
    stats=$(LC_ALL=C msgfmt --statistics -o /dev/null "$po_file" 2>&1)

    local translated=0 fuzzy=0 untranslated=0

    if [[ $stats =~ ([0-9]+)\ translated ]]; then
        translated="${BASH_REMATCH[1]}"
    fi
    if [[ $stats =~ ([0-9]+)\ fuzzy ]]; then
        fuzzy="${BASH_REMATCH[1]}"
    fi
    if [[ $stats =~ ([0-9]+)\ untranslated ]]; then
        untranslated="${BASH_REMATCH[1]}"
    fi

    local total=$(( translated + fuzzy + untranslated ))
    local pct=0
    if (( total > 0 )); then
        pct=$(( translated * 100 / total ))
    fi

    echo "$translated $fuzzy $untranslated $total $pct"
}

progress_bar() {
    local pct="$1"
    local filled=$(( pct / 10 ))
    local empty=$(( 10 - filled ))
    local bar=""
    local i
    for (( i = 0; i < filled; i++ )); do bar+="█"; done
    for (( i = 0; i < empty;  i++ )); do bar+="░"; done
    echo -n "$bar"
}

if (( MARKDOWN )); then
    echo "## 📊 Translation Progress (ko_KP)"
    echo ""
    echo "| Domain | Translated | Fuzzy | Untranslated | Total | Progress |"
    echo "|--------|-----------|-------|--------------|-------|----------|"
fi

TOTAL_TRANSLATED=0
TOTAL_FUZZY=0
TOTAL_UNTRANSLATED=0

for po_file in "$PO_DIR"/*.po; do
    domain=$(basename "$po_file" .po | sed 's/\.ko_KP$//')
    read -r translated fuzzy untranslated total pct <<< "$(parse_stats "$po_file")"

    TOTAL_TRANSLATED=$(( TOTAL_TRANSLATED + translated ))
    TOTAL_FUZZY=$(( TOTAL_FUZZY + fuzzy ))
    TOTAL_UNTRANSLATED=$(( TOTAL_UNTRANSLATED + untranslated ))

    if (( MARKDOWN )); then
        bar=$(progress_bar "$pct")
        echo "| \`$domain\` | $translated | $fuzzy | $untranslated | $total | ${bar} ${pct}% |"
    else
        echo "$domain: ${translated}/${total} (${pct}%) translated, ${fuzzy} fuzzy, ${untranslated} untranslated"
    fi
done

GRAND_TOTAL=$(( TOTAL_TRANSLATED + TOTAL_FUZZY + TOTAL_UNTRANSLATED ))
GRAND_PCT=0
if (( GRAND_TOTAL > 0 )); then
    GRAND_PCT=$(( TOTAL_TRANSLATED * 100 / GRAND_TOTAL ))
fi

if (( MARKDOWN )); then
    bar=$(progress_bar "$GRAND_PCT")
    echo "| **Total** | **$TOTAL_TRANSLATED** | **$TOTAL_FUZZY** | **$TOTAL_UNTRANSLATED** | **$GRAND_TOTAL** | **${bar} ${GRAND_PCT}%** |"
    echo ""
    echo "> Generated at $(date -u '+%Y-%m-%d %H:%M UTC')"
else
    echo "---"
    echo "Total: ${TOTAL_TRANSLATED}/${GRAND_TOTAL} (${GRAND_PCT}%) translated"
fi
