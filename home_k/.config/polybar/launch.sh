#!/usr/bin/env bash

ENV_TAG=${K_ENV_TAG}

noti_aggr=

battery_vals=($(ls -1 /sys/class/power_supply/))
if ((${#battery_vals[@]}>=2)) ; then
    export POLY_BATTERY_ADAPTER=${battery_vals[0]}
    export POLY_BATTERY=${battery_vals[1]}
fi
export POLY_ETH=$(ip -o link show | grep '^2' | awk -F': ' '{print $2}')
export POLY_IW=$(ip -o link show | grep '^3' | awk -F': ' '{print $2}')

if [[ -z "$1" ]]; then
	if [ "$(pgrep -f i3bar)" != "" ]; then
		notify-send "Detected i3bar is running. Polybar will not run."
		exit 0
	fi
fi

# Terminate already running bar instances
killall -q polybar
sleep 1
# If all your bars have ipc enabled, you can also use
# polybar-msg cmd quit

logfile=~/Logs/polybar.log

# $1: bar name
runbar() {
	echo "---" | tee -a $logfile
	polybar -l error -r $1 2>&1 | tee -a $logfile &
	disown
}

monitors=($(polybar --list-monitors | cut -d":" -f1))
case ${#monitors[@]} in
1)
	runbar single
	;;
2)
	MONITOR=${monitors[0]} runbar dualleft
	MONITOR=${monitors[1]} runbar dualright
	;;
3)
	MONITOR=${monitors[0]} runbar trileft
	MONITOR=${monitors[1]} runbar tricenter
	MONITOR=${monitors[3]} runbar triright
	;;
*)
	for m in "${monitors[@]}"; do
		MONITOR=$m runbar single &
	done
	;;
esac

# case ${ENV_TAG} in
# home)
# 	bars=('homeleft homeright')
# 	# bars=('homesingle')
# 	;;
# *)
# 	bars=('left main right')
# 	;;

# esac

# echo "bars are:" $bars

# for bar in ${bars[@]}; do
# 	echo ">>> running bar ${bar}"
# 	runbar $bar
# done

notify-send "[polybar]" "Bars launched..."
# Launch example bar
