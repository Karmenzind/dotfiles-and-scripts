ISSWAY=false
lockbin=i3lock
msgbin=i3-msg
if pgrep -x "sway" >/dev/null; then
	ISSWAY=true
	lockbin=swaylock
    msgbin=swaymsg
fi

wallpaper_dir=~/Pictures/LOCKSCREENS
getapic() {
    if [ -d $wallpaper_dir ]; then
        find -L $wallpaper_dir -type f -name '*png' | shuf -n 1
    else
        echo $wallpaper_png
    fi
}
pic=$(getapic)
$lockbin -t -i $pic
# $lockbin
