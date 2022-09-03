#!/usr/bin/env bash

ENV_TAG=${K_ENV_TAG}

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

logfile=~/Logs/polybar.log

# $1: bar name
runbar() {
    echo "---" | tee -a $logfile
    polybar -r $1 2>&1 | tee -a $logfile & disown
}


case $ENV_TAG in
    home ) 
        bars=left main right
        ;;
    *) 
        bars=('homeleft homeright')
        ;;

esac

echo "bars are:" $bars

for bar in ${bars[@]}; do
    echo ">>> running bar ${bar}"
    runbar $bar
done

notify-send "Bars launched..."
# Launch example bar
