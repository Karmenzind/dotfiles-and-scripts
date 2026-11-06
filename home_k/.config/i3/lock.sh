#!/usr/bin/env bash
# Keep locking functional even when the wallpaper directory is missing or empty.
wallpaper_dir=${WALLPAPER_DIR:-$HOME/Pictures/LOCKSCREENS}
wallpaper_png=${WALLPAPER_PNG:-$HOME/Pictures/LOCKSCREEN.png}
pic=
if [[ -d "$wallpaper_dir" ]]; then
    IFS= read -r -d '' pic < <(find -L "$wallpaper_dir" -type f -iname '*.png' -readable -print0 | shuf -z -n 1)
fi
[[ -n "$pic" ]] || pic=$wallpaper_png

if [[ -n ${SWAYSOCK:-} && -n ${WAYLAND_DISPLAY:-} ]]; then
    command -v swaylock >/dev/null || exit 127
    if [[ -r "$pic" ]] && swaylock -s tile -i "$pic"; then
        exit 0
    fi
    exec swaylock -c 000000
else
    command -v i3lock >/dev/null || exit 127
    if [[ -r "$pic" ]] && i3lock -t -i "$pic"; then
        exit 0
    fi
    exec i3lock -c 000000
fi
