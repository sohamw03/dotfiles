#!/bin/bash
# Pick a screen region over frozen screen content.
# Trimmed port of omarchy-capture-region (quattro): keeps region pick,
# window/monitor snapping and frozen-screen capture, drops Omarchy's
# keyboard-driven window cycling (needs its keybind framework).
#
# Usage: capture-region.sh [smart|region|windows|fullscreen] [--keep-freeze]
# Prints the picked geometry in slurp's "X,Y WxH" format, exits 1 on cancel.
# With --keep-freeze the hyprpicker freeze PID is printed as the first line
# and the caller owns killing it.

MODE=smart
KEEP_FREEZE=false

for arg in "$@"; do
  case $arg in
  --keep-freeze) KEEP_FREEZE=true ;;
  *) MODE=$arg ;;
  esac
done

# accounting for portrait/transformed displays
JQ_MONITOR_GEO='
  def format_geo:
    .x as $x | .y as $y |
    (.width / .scale | floor) as $w |
    (.height / .scale | floor) as $h |
    .transform as $t |
    if $t == 1 or $t == 3 then
      "\($x),\($y) \($h)x\($w)"
    else
      "\($x),\($y) \($w)x\($h)"
    end;
'

active_workspace() {
  hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id'
}

# Hidden windows and stacked duplicates collapse to one rectangle: slurp
# cannot tell them apart and duplicates would stall its highlight cycle.
window_rects() {
  hyprctl clients -j | jq -r --arg ws "$(active_workspace)" \
    '[.[] | select(.workspace.id == ($ws | tonumber) and .hidden != true) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"] | unique[]'
}

monitor_rects() {
  hyprctl monitors -j | jq -r --arg ws "$(active_workspace)" "${JQ_MONITOR_GEO} .[] | select(.activeWorkspace.id == (\$ws | tonumber)) | format_geo"
}

get_rectangles() {
  monitor_rects
  window_rects
}

focused_monitor_geo() {
  hyprctl monitors -j | jq -r "${JQ_MONITOR_GEO} .[] | select(.focused == true) | format_geo"
}

pick() {
  local selection
  selection=$(slurp "$@" 2>/dev/null)
  printf '%s' "$selection"
}

FREEZE_PID=""
freeze_screen() {
  hyprpicker -r -z >/dev/null 2>&1 &
  FREEZE_PID=$!
  sleep .1
}

cleanup_freeze() {
  [[ $KEEP_FREEZE == true ]] && return
  [[ -n $FREEZE_PID ]] && kill $FREEZE_PID 2>/dev/null
}
trap cleanup_freeze EXIT

case "$MODE" in
region)
  freeze_screen
  SELECTION=$(pick)
  ;;
windows)
  freeze_screen
  SELECTION=$(get_rectangles | pick -r)
  ;;
fullscreen)
  SELECTION=$(focused_monitor_geo)
  ;;
smart | *)
  RECTS=$(get_rectangles)
  freeze_screen
  SELECTION=$(echo "$RECTS" | pick)

  # A bare click (area < 20px^2) snaps to whichever rectangle it landed in,
  # so users don't end up with accidental 2px captures. X and Y can be
  # negative (Hyprland monitor positions in multi-display layouts).
  if [[ $SELECTION =~ ^(-?[0-9]+),(-?[0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]] && ((BASH_REMATCH[3] * BASH_REMATCH[4] < 20)); then
    click_x=${BASH_REMATCH[1]}
    click_y=${BASH_REMATCH[2]}

    while IFS= read -r rect; do
      [[ $rect =~ ^(-?[0-9]+),(-?[0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]] || continue
      rect_x=${BASH_REMATCH[1]}
      rect_y=${BASH_REMATCH[2]}
      rect_width=${BASH_REMATCH[3]}
      rect_height=${BASH_REMATCH[4]}

      if ((click_x >= rect_x && click_x < rect_x + rect_width && click_y >= rect_y && click_y < rect_y + rect_height)); then
        SELECTION="${rect_x},${rect_y} ${rect_width}x${rect_height}"
        break
      fi
    done <<<"$RECTS"
  fi
  ;;
esac

[[ $KEEP_FREEZE == true ]] && echo "$FREEZE_PID"

[[ -n $SELECTION ]] || exit 1

echo "$SELECTION"
