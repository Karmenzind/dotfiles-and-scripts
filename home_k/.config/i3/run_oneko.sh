#!/usr/bin/env bash
[[ ${ENABLE_ONEKO:-0} == 1 ]] || exit 0
command -v oneko >/dev/null || exit 0
pgrep -u "$UID" -x oneko >/dev/null && exit 0
oneko -tofocus &
oneko -tomoyo -speed 10 -tofocus &
