#!/bin/sh
# vim:ts=4:sw=4:expandtab:ft=sh

export GLFW_IM_MODULE=ibus
export GTK_IM_MODULE=fcitx
export INPUT_METHOD=fcitx
export QT_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
	xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
	xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
	xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
	xmodmap "$usermodmap"
fi

# start some nice programs

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

[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap

log_dir=~/Logs
mkdir -p $log_dir
log_file=$log_dir/i3log-$(date -Id)

if grep '^set $mod ' ~/.config/i3/config; then 
    i3config=~/.config/i3/config
else
    i3config=~/.config/i3/config.working
    cat >$i3config <<EOF
# vim:set noet ft=i3config:
# Don't modify this file unless you know what you are doing

EOF
    if grep 'HHKB' /proc/bus/input/devices; then
        echo 'set $mod Mod1' >> $i3config
    else
        echo 'set $mod Mod4' >> $i3config
    fi
fi
echo 'include ~/.config/i3/config' >> $i3config
exec i3 -c $i3config -V >>$log_file 2>&1
