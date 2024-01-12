#!/usr/bin/env bash

current_theme=Simple-and-Soft
substitution=Neutral

cur_dir="/usr/share/icons/$current_theme/cursors"
sub_dir="/usr/share/icons/$substitution/cursors"

default_dir=~/.icons/default/cursors
rm -rf ${default_dir:?}/*

for cursor in `ls $sub_dir`; do
    ls "$cur_dir/$cursor" || cp -v "$sub_dir/$cursor" $default_dir
done
