#!/bin/bash

# 获取电池电量（以百分比为单位）
battery_level=$(acpi -b | grep -P -o '[0-9]+(?=%)')

# 如果电量低于 40%，发送高等级的通知
if [ "$battery_level" -lt 30 ]; then
    export DISPLAY=:0
    # eval $(dbus-launch --sh-syntax)
    #
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
    if ! [[ -f $DBUS_SESSION_BUS_ADDRESS ]]; then
        # XXX (qk): <2024-04-04 11:00> 
        export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME i3)/environ | cut -d= -f2-)
        # export DBUS_SESSION_BUS_ADDRESS=$(dbus-launch --exit-with-session --sh-syntax --config-file=/path/to/dunst.conf)
    fi
    notify-send -u critical "Battery Low" "$battery_level% left" >> /tmp/alert.log 2>&1
fi
