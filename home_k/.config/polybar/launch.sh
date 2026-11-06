#!/usr/bin/env bash
# Serialize launches, including manual relaunches after monitor changes.
command -v polybar >/dev/null || exit 0
runtime_dir=${XDG_RUNTIME_DIR:-$HOME/.cache}
mkdir -p "$runtime_dir" "$HOME/Logs"
exec 9>"$runtime_dir/polybar-launch.lock"
flock -n 9 || exit 0

if [[ -z ${1:-} ]] && pgrep -u "$UID" -x i3bar >/dev/null; then
    exit 0
fi

# Identify power supplies by type, never by directory ordering.
unset POLY_BATTERY_ADAPTER POLY_BATTERY
for supply in "${POWER_SUPPLY_DIR:-/sys/class/power_supply}"/*; do
    [[ -r "$supply/type" ]] || continue
    IFS= read -r supply_type < "$supply/type"
    case "$supply_type" in
        Battery) [[ -n ${POLY_BATTERY:-} ]] || export POLY_BATTERY=${supply##*/} ;;
        Mains) [[ -n ${POLY_BATTERY_ADAPTER:-} ]] || export POLY_BATTERY_ADAPTER=${supply##*/} ;;
    esac
done
# Empty values let Polybar disable the battery module cleanly on desktops.
export POLY_BATTERY=${POLY_BATTERY:-}
export POLY_BATTERY_ADAPTER=${POLY_BATTERY_ADAPTER:-}

# Gracefully stop only this user's bars, and wait for their windows to disappear.
pkill -u "$UID" -x polybar || true
for ((attempt=0; attempt<30; attempt++)); do
    pgrep -u "$UID" -x polybar >/dev/null || break
    sleep 0.1
done
if pgrep -u "$UID" -x polybar >/dev/null; then
    printf 'Polybar did not stop; refusing to start duplicate bars.\n' >&2
    exit 1
fi

# RandR coordinates are nonnegative. Sort by x then y, rather than output name.
mapfile -t monitors < <(polybar --list-monitors | sort -t+ -k2,2n -k3,3n | cut -d: -f1)
((${#monitors[@]})) || exit 0
logfile=$HOME/Logs/polybar.log
config_file=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/config
runbar() {
    MONITOR=$1 polybar --config="$config_file" -l error -r "$2" >>"$logfile" 2>&1 9>&- &
}
case ${#monitors[@]} in
    1) runbar "${monitors[0]}" single ;;
    2) runbar "${monitors[0]}" dualleft
       runbar "${monitors[1]}" dualright ;;
    3) runbar "${monitors[0]}" trileft
       runbar "${monitors[1]}" tricenter
       runbar "${monitors[2]}" triright ;;
    *) for monitor in "${monitors[@]}"; do runbar "$monitor" single; done ;;
esac
