#!/bin/bash

export DISPLAY=:0
# 获取电池电量（以百分比为单位）
battery_level=$(acpi -b | grep -P -o '[0-9]+(?=%)')

# 如果电量低于 40%，发送高等级的通知
if [ "$battery_level" -lt 40 ]; then
    notify-send -u critical "Battery Low" "$battery_level% left"
fi
