#!/bin/sh
# vim:ts=4:sw=4:expandtab:ft=sh

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

xrdb -load ~/.Xresources
xsetroot -cursor_name left_ptr

xset s off
xset -dpms
xset s noblank

xset r rate 200 20

setxkbmap de
setxkbmap -option ctrl:nocaps
xmodmap -e 'clear lock'
xmodmap -e 'keycode 66 = Hyper_L'

log_dir=~/Logs
mkdir -p $log_dir
log_file=$log_dir/i3log-$(date -Id)
exec i3 -V >> $log_file 2>&1
