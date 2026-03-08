#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
STATE_FILE="$WALLPAPER_DIR/.last_wallpaper"

# Gather image files (case-insensitive extensions)
mapfile -t FILES < <(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.svg' \) -print)

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "No wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
fi

CURRENT=""
if [ -f "$STATE_FILE" ]; then
  CURRENT="$(<"$STATE_FILE")"
fi

# Remove current from candidates (exact match)
CAND=()
for f in "${FILES[@]}"; do
  [ "$f" = "$CURRENT" ] && continue
  CAND+=("$f")
done

if [ "${#CAND[@]}" -eq 0 ]; then
  echo "No alternative wallpapers available" >&2
  exit 0
fi

# Pick a random wallpaper
RANDOM_WP="${CAND[RANDOM % ${#CAND[@]}]}"

# Try to set wallpaper. Some hyprctl/hyprpaper versions accept a quoted string inside commas:
#   ,"/path/to/img",
# older/newer versions may accept unquoted path inside commas: ,/path/to/img,
# try quoted form first, on failure fallback to unquoted and print hyprctl output for diagnosis.
if hyprctl_output=$(hyprctl hyprpaper wallpaper "eDP-1,$RANDOM_WP," 2>&1); then
    echo "hyprctl success"
else
    echo "hyprctl (quoted) failed: $hyprctl_output" >&2
    if hyprctl_output2=$(hyprctl hyprpaper wallpaper "eDP-1,${RANDOM_WP}," 2>&1); then
        echo "hyprctl success (fallback)"
    else
        echo "hyprctl (fallback) failed: $hyprctl_output2" >&2
        exit 1
    fi
fi

# Save state
mkdir -p "$WALLPAPER_DIR"
printf '%s' "$RANDOM_WP" > "$STATE_FILE"

echo "Set wallpaper to $RANDOM_WP"
