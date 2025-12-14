#!/usr/bin/env bash
# update_foot_colors.sh
# Updates the [colors] section in foot.ini using Pywal's colors-foot.ini,
# appending it at the end, with alpha=0.75

FOOT_CONFIG="$HOME/.config/foot/foot.ini"
PYWAL_FOOT="$HOME/.cache/wal/colors-foot.ini"

# Check that both files exist
if [[ ! -f "$FOOT_CONFIG" ]]; then
    echo "Error: foot.ini not found at $FOOT_CONFIG"
    exit 1
fi

if [[ ! -f "$PYWAL_FOOT" ]]; then
    echo "Error: colors-foot.ini not found at $PYWAL_FOOT"
    exit 1
fi

# Backup original foot.ini
cp "$FOOT_CONFIG" "${FOOT_CONFIG}.bak"

# Extract the [colors] section from Pywal's file, drop last line (alpha)
colors_section=$(awk '
    /^\[colors\]/ {flag=1; print; next}
    /^\[.*\]/ {flag=0}
    flag {lines[++i]=$0}
    END {for (j=1;j<i;j++) print lines[j]}
' "$PYWAL_FOOT")

# Remove old [colors] section from foot.ini
awk '
  BEGIN {skip=0}
  /^\[colors\]/ {skip=1; next}
  /^\[.*\]/ {skip=0}
  skip==0 {print}
' "$FOOT_CONFIG" > "${FOOT_CONFIG}.tmp"

# Append Pywal's [colors] section at the end, with alpha=0.75
{
    cat "${FOOT_CONFIG}.tmp"
    echo
    echo "$colors_section"
    echo "alpha=0.75"
} > "$FOOT_CONFIG"

rm "${FOOT_CONFIG}.tmp"

echo "Foot color scheme updated from Pywal (alpha=0.75), appended at end of foot.ini."
