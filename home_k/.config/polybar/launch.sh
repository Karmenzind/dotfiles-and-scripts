#!/usr/bin/env bash

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

for bar in left main right; do
    runbar $bar
done

notify-send "Bars launched..."
# Launch example bar
