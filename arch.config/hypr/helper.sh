#!/usr/bin/env bash
set -euo pipefail

show_launch_notification() {
    local app_name="$1"

    notify-send --app-name=ahk-rs --urgency=critical --expire-time=0 --print-id "Opening ${app_name}..." 2>/dev/null || true
}

dismiss_notification() {
    local notification_id="$1"

    [[ -n "$notification_id" ]] || return 0

    if command -v gdbus >/dev/null 2>&1; then
        gdbus call --session \
            --dest org.freedesktop.Notifications \
            --object-path /org/freedesktop/Notifications \
            --method org.freedesktop.Notifications.CloseNotification \
            "$notification_id" >/dev/null 2>&1 || true
    fi
}

focus_or_launch_single() {
    local class="$1"
    local selector="$2"
    local process_name="$3"
    local app_name="$4"
    shift 4

    local lock_file="/tmp/hypr-single-launch-${process_name}.lock"

    if hyprctl clients -j | jq -e --arg class "$class" '.[] | select(.class == $class)' >/dev/null; then
        hyprctl dispatch focuswindow "$selector" >/dev/null
        return 0
    fi

    # Hold a short lock while the first launch is turning into a window.
    exec 9>"$lock_file"
    flock -n 9 || return 0

    if hyprctl clients -j | jq -e --arg class "$class" '.[] | select(.class == $class)' >/dev/null; then
        hyprctl dispatch focuswindow "$selector" >/dev/null
        return 0
    fi

    local notification_id
    notification_id="$(show_launch_notification "$app_name")"

    "$@" >/dev/null 2>&1 &

    for ((i = 0; i < 100; i++)); do
        if hyprctl clients -j | jq -e --arg class "$class" '.[] | select(.class == $class)' >/dev/null; then
            dismiss_notification "$notification_id"
            hyprctl dispatch focuswindow "$selector" >/dev/null
            return 0
        fi
        sleep 0.2
    done
}

case "${1:-}" in
    brave)
        focus_or_launch_single "brave-browser" "class:^(brave-browser)$" "brave" "Brave" brave
        ;;
    google-chrome-stable)
        focus_or_launch_single "google-chrome" "class:^(google-chrome)$" "google-chrome-stable" "Google Chrome" google-chrome-stable
        ;;
    ghostty)
        focus_or_launch_single "com.mitchellh.ghostty" "class:^(com.mitchellh.ghostty)$" "ghostty" "Ghostty" ghostty --working-directory=home
        ;;
    *)
        echo "Usage: $0 {brave|google-chrome-stable|ghostty}" >&2
        exit 1
        ;;
esac
