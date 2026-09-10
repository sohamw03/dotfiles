#!/bin/bash
# Color-accurate screenshots under night light.
# hyprshade's warm shader is dropped before the picker opens (so neither the
# selection overlay nor the pixels come out warm) and re-applied on EXIT via
# Noctalia — even on cancel. Hardware cursors are forced meanwhile so grim
# doesn't bake in the software cursor. Then: save, clipboard, and a preview
# notification whose Edit action opens the shot in Tensaku.
#
# Usage: screenshot.sh [smart|region|windows|fullscreen]

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUTPUT_DIR="$HOME/Pictures/Screenshots"
SHOT_EDITOR="${SCREENSHOT_EDITOR:-tensaku-edit}"
QS_IPC=(qs -p /home/soham/dotfiles/shell ipc call)
MODE="${1:-smart}"

mkdir -p "$OUTPUT_DIR"

# Re-pressing a bind while the picker is open cancels instead of stacking.
pkill -x slurp 2>/dev/null && exit 0

set_hw_cursors() {
  hyprctl eval "hl.config({ cursor = { no_hardware_cursors = $1 } })" &>/dev/null ||
    hyprctl keyword cursor:no_hardware_cursors "$1" &>/dev/null
}

FREEZE_PID=""
restore() {
  [[ -n $FREEZE_PID ]] && kill "$FREEZE_PID" 2>/dev/null
  set_hw_cursors "$NO_HW_CURSORS"
  "${QS_IPC[@]}" nightLight reapply &>/dev/null
}
trap restore EXIT

# Order matters: untint first, so the frozen frame the picker holds is cool.
hyprshade off &>/dev/null
NO_HW_CURSORS=$(hyprctl getoption cursor:no_hardware_cursors -j | jq '.int')
set_hw_cursors 0

{ read -r FREEZE_PID; read -r SELECTION; } < <("$SCRIPT_DIR/capture-region.sh" "$MODE" --keep-freeze)
[[ -n ${SELECTION:-} ]] || exit 0

FILEPATH="$OUTPUT_DIR/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
grim -g "$SELECTION" "$FILEPATH" || exit 1
wl-copy --type image/png <"$FILEPATH"

# Pixels are safe: bring the tint back before notifying.
trap - EXIT
restore

# Wait for a click without hanging the bind: the wait is capped, since a
# server that never closes action-notifications would block forever.
if ACTION=$(timeout 10 notify-send -a Screenshot -i "$FILEPATH" --action=edit="Edit in Tensaku" \
  --expire-time=8000 "Screenshot saved" "$(basename "$FILEPATH")" 2>/dev/null); then
  [[ $ACTION == "edit" ]] && exec "$SHOT_EDITOR" "$FILEPATH"
fi
exit 0
