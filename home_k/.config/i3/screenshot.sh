#!/usr/bin/env bash

pic_dir=$HOME/Pictures
mkdir -p $pic_dir

# screenshot_dir=${pic_dir}/ScreenShots
screenshot_png=${pic_dir}/SCREENSHOT.png
flameshot_dir=${pic_dir}/FlameShots
flameshot_png=${pic_dir}/SCREENSHOT_FLAME.png

after() {
    xclip -selection clipboard -t image/png -i "$screenshot_png"
    prompt
}

flameshot_before() {
    if [[ -e $flameshot_png ]]; then
        rm -vf "${flameshot_png}"
    fi
}

do_scrot() {
    scrot $1 $screenshot_png
}

flameshot_area() {
    flameshot_before 
    flameshot gui -p $pic_dir
}

prompt() {
    t=`date +%T`
    notify-send "Saved as $screenshot_png [${t}]"
}

case $1 in
    full    ) do_scrot && after    ;;
    area    ) do_scrot -s && after ;;
    area_fs ) flameshot_area       ;;
esac
