#!/usr/bin/env bash

pic_dir=$HOME/Pictures
# screenshot_dir=${pic_dir}/ScreenShots
screenshot_png=${pic_dir}/SCREENSHOT.png
flameshot_dir=${pic_dir}/FlameShots
# flameshot_png=${flameshot_dir}/screenshot.png

after() {
    xclip -selection clipboard -t image/png -i "$screenshot_png"
    prompt
}

flameshot_before() {
    if [[ -d $flameshot_dir ]]; then
        rm -vrf ${flameshot_dir:?}/*
    else 
        mkdir -vp $flameshot_dir
    fi
}

do_scrot() {
    scrot $1 $screenshot_png
}

flameshot_area() {
    flameshot_before 
    flameshot gui -p $flameshot_dir 
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
