#!/usr/bin/env bash

arandr_conf=~/.screenlayout/default.sh
command -v arandr && [[ -e "$arandr_conf" ]] && bash $arandr_conf &

notify-send "Loaded post_start.sh"
echo "Executed at $(date)" >/tmp/post_start_log

