((${ENABLE_ONEKO:-0==0})) && exit

command -V oneko || exit 1

killall oneko
oneko -tofocus &
oneko -tomoyo -speed 10 -tofocus &
