#!/usr/bin/env bash
# TODO (k): <2024-02-01 08:31> 
# https://unix.stackexchange.com/questions/371793/how-to-duplicate-desktop-in-linux-with-xrandr

screen_num=$(xrandr --current  | grep ' connected' | wc -l)
if (($screen_num <= 1)); then
    echo "Screen num: $screen_num. Ignored."
    exit
fi


