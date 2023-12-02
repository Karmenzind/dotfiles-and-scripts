#!/usr/bin/env bash

ENV_TAG=${K_ENV_TAG}

noti_aggr=

if [ "$(pgrep -f i3bar)" != "" ]; then
    notify-send "Detected i3bar is running. Polybar will not run."
    exit 0
fi

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

logfile=~/Logs/polybar.log

# $1: bar name
runbar() {
    echo "---" | tee -a $logfile
    polybar -l error -r $1 2>&1 | tee -a $logfile & disown
}


case ${ENV_TAG} in
    home) 
        bars=('homeleft homeright')
        # bars=('homesingle')
        ;;
    *) 
        bars=('left main right')
        ;;

esac

echo "bars are:" $bars

for bar in ${bars[@]}; do
    echo ">>> running bar ${bar}"
    runbar $bar
done

notify-send "Bars launched..."
# Launch example bar
