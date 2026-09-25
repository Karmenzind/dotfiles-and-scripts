#!/bin/bash
# Claude Code statusline converted from ~/.bashrc PS1:
#   PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
input=$(cat)

raw_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$raw_dir")

user=$(whoami)
host=$(hostname -s)

chroot=""
if [ -r /etc/debian_chroot ]; then
  chroot_name=$(cat /etc/debian_chroot)
  [ -n "$chroot_name" ] && chroot="(${chroot_name}) "
fi

model=$(echo "$input" | jq -r '.model.display_name // .model.id // "unknown"')

session_name=$(echo "$input" | jq -r '.session_name // empty')

# "Fast" reflects whether extended thinking is currently disabled (fast = no
# extended thinking). thinking.enabled is only present in some sessions.
thinking_enabled=$(echo "$input" | jq -r '.thinking.enabled // false')
if [ "$thinking_enabled" = "true" ]; then
  fast_state="off"
else
  fast_state="on"
fi

five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
usage=""
[ -n "$five_hour" ] && usage="5h:$(printf '%.0f' "$five_hour")%"
if [ -n "$seven_day" ]; then
  [ -n "$usage" ] && usage="${usage} "
  usage="${usage}7d:$(printf '%.0f' "$seven_day")%"
fi

GREEN='\033[01;32m'
BLUE='\033[01;34m'
YELLOW='\033[00;33m'
MAGENTA='\033[00;35m'
DIM='\033[02m'
RESET='\033[00m'

out=""
[ -n "$session_name" ] && out="${MAGENTA}${session_name}${RESET} ${DIM}|${RESET} "
out="${out}${BLUE}${dir}${RESET} ${DIM}|${RESET} ${YELLOW}${model}${RESET}"
[ "$fast_state" = "on" ] && out="${out} ${DIM}|${RESET} ${DIM}Fast${RESET}"
[ -n "$usage" ] && out="${out} ${DIM}|${RESET} ${DIM}${usage}${RESET}"

printf "%b" "$out"
