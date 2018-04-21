export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

exec i3 -V >> /tmp/i3log-$(date -Id) 2>&1
