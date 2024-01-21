#!/usr/bin/env bash

header="[Post Start]"

arandr_conf=~/.screenlayout/default.sh
command -v arandr && [[ -e "$arandr_conf" ]] && bash $arandr_conf &

# transparency controller (Move to script)
# exec_always --no-startup-id killall picom; picom -b &
start_picom() {
    if command -v picom >/dev/null; then
        if ((${USE_PICOM:-1}==1)); then
            killall picom
            picom -b
            notify-send "$header" "started picom"
        else
            notify-send "$header" "picom is disabled"
        fi
    fi
}

start_picom &

wait

notify-send "$header" "loaded post_start.sh"
echo "Executed at $(date)" >/tmp/post_start_log
