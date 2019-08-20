command -V oneko || exit 1

killall oneko
oneko -tofocus &
oneko -tomoyo -speed 10 -tofocus &
