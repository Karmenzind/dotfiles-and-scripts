#!/usr/bin/env bash

download_dir=/home/qk/Downloads/aria2
gid=$1
filenum=$2
filepath=$3

notify-send "Aria2 Download Completed" "$(basename $filepath) (total $2)"
rm -vf "${filepath}.aria2"



# prompt() {
#     notify-send $@
#     echo $@ >> /tmp/_aria2c.log
# }


# prompt "[$event][Total: $filenum] $filepath"

# case $event in
#     complete )
#         rm -f ${filepath}.aria2
#         ;;
# esac
