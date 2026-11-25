#!/usr/bin/env bash
# i3/Sway exec (not exec_always): leave services intact on WM restarts.
config_dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

start_once() {
    local name=$1
    shift
    command -v "$1" >/dev/null || return 0
    pgrep -u "$UID" -x "$name" >/dev/null || "$@" &
}

start_once dunst dunst
start_once fcitx5 fcitx5
# Keep removable-media and shared tray services available under Sway too.
start_once udiskie udiskie --tray
start_once pcmanfm pcmanfm -d
start_once pamac-tray pamac-tray
start_once volumeicon volumeicon
polkit_agent=${POLKIT_AGENT:-/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1}
if [[ -x "$polkit_agent" ]] && ! pgrep -u "$UID" -f "^$polkit_agent([[:space:]]|$)" >/dev/null; then
    "$polkit_agent" &
fi
if command -v gnome-keyring-daemon >/dev/null; then
    # The desktop session should export keyring environment variables.
    gnome-keyring-daemon --start --components=pkcs11,secrets,ssh >/dev/null
fi

# Do not launch X11 services merely because an unrelated i3 process exists.
if [[ -n ${SWAYSOCK:-} && -n ${WAYLAND_DISPLAY:-} ]]; then
    exit 0
fi

# Complete RandR changes before Polybar enumerates monitors.
layout=$HOME/.screenlayout/default.sh
if [[ -f "$layout" ]]; then
    bash "$layout" || printf 'i3: display layout failed: %s\n' "$layout" >&2
fi

if command -v feh >/dev/null; then
    shopt -s nullglob
    backgrounds=("$HOME"/Pictures/BACKGROUND.*)
    ((${#backgrounds[@]} == 0)) || feh --bg-max "${backgrounds[@]}"
fi

start_once flameshot flameshot
start_once xflux xflux -l 30.2443314184 -g 120.1665687561

if [[ ${USE_PICOM:-1} == 1 ]]; then
    start_once picom picom -b
fi
if [[ ${ENABLE_ONEKO:-0} == 1 ]]; then
    bash "$config_dir/run_oneko.sh"
fi

# Use the same fail-safe locker as the manual shortcut; no blurlock dependency.
start_once xautolock xautolock -time 45 \
    -notify 300 \
    -notifier "notify-send -u normal -t 15000 'Automatic screen lock' 'The screen will lock in 5 minutes. Move the mouse or press a key to reset the idle timer.'" \
    -locker "bash \"$config_dir/lock.sh\""

# A restart must not create another scratchpad terminal.
if command -v i3-msg >/dev/null && command -v python3 >/dev/null; then
    if i3-msg -t get_tree | python3 -c '
import json, sys
def contains(node):
    return node.get("window_properties", {}).get("title") == "my-init-terminal" or any(
        contains(child) for key in ("nodes", "floating_nodes") for child in node.get(key, []))
sys.exit(0 if contains(json.load(sys.stdin)) else 1)
'; then
        :
    else
        terminal=${TERMINAL:-i3-sensible-terminal}
        i3-msg "exec --no-startup-id $terminal --title 'my-init-terminal' -e tmux new -As t" >/dev/null
    fi
fi

if command -v polybar >/dev/null; then
    bash "$config_dir/../polybar/launch.sh"
fi
