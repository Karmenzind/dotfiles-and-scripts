#!/usr/bin/env bash
command -v feh >/dev/null || { notify-send 'feh is not installed'; exit 1; }
wallpaper_dir=${WALLPAPER_DIR:-$HOME/Pictures/LOCKSCREENS}
state_dir=${XDG_CACHE_HOME:-$HOME/.cache}/i3
mkdir -p "$state_dir"
state_file=$state_dir/current-background
curbg=
[[ ! -r "$state_file" ]] || IFS= read -r curbg < "$state_file"

# NUL-delimited paths support spaces; use the same symlink policy for all files.
mapfile -d '' -t pictures < <(find -L "$wallpaper_dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -readable -print0)
((${#pictures[@]})) || { notify-send 'No wallpapers found' "$wallpaper_dir"; exit 1; }
candidates=()
for picture in "${pictures[@]}"; do
    [[ "$picture" == "$curbg" && ${#pictures[@]} -gt 1 ]] || candidates+=("$picture")
done
IFS= read -r -d '' chosen < <(printf '%s\0' "${candidates[@]}" | shuf -z -n 1)
if feh --bg-max "$chosen"; then
    printf '%s\n' "$chosen" >"$state_file"
    notify-send '[background]' "Using $(basename "$chosen")"
fi
