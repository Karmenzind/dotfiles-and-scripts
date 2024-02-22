#!/usr/bin/env bash
tmpbgfile=/tmp/__current_bg_filename
[[ -e $tmpbgfile ]] && curbg=$(cat $tmpbgfile)
# notify-send "Curbg: $curbg"
if ! command -v feh; then
    nodify-send "feh is not installed"
    exit 1
fi

wallpaper_dir=$(realpath ~/Pictures/LOCKSCREENS)
if ! [[ -d $wallpaper_dir ]]; then
	notify-send "Invalid wallpaper_dir: $wallpaper_dir"
	exit 1
fi

num=$(find -L $wallpaper_dir -type f | wc -l)

if (($num <= 1)); then
	notify-send "Canceled. Pic num <= 1."
	exit
fi

random_bg() {
	find $wallpaper_dir -type f | sort -R | head -1
}

if [[ -n $curbg ]]; then
	while true; do
		choosed=$(random_bg)
		# notify-send "Compare: $choosed \n $curbg"
		[[ $choosed != $curbg ]] && break
	done
else
	choosed=$(random_bg)
fi

echo $choosed >$tmpbgfile
notify-send "[background]" "Using $(basename $choosed)"
feh --bg-max $choosed

# feh --bg-max $([[ -d $wallpaper_dir ]] && (find $wallpaper_dir -type f | sort -R | head -1) || echo $wallpaper_png) &
