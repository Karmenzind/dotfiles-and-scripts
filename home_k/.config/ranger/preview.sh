#!/usr/bin/env bash

log() {
	echo "$(datetime +"%F %T") $@" >>/tmp/range_preview.log
}

log "recieve params: $@"

scope_path=~/.config/ranger/scope.sh

filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

case $extension in
jpg | png | jpeg | webp | gif)
	bash $scope_path $@
	;;
# mobi | azw3 | epub)
#     bash $scope_path "$@"
#     ;;
*)
	if command -V pistol >/dev/null; then
		log "preview with pistol"
		pistol $*
	elif [[ -f $scope_path ]]; then
		bash $scope_path "$@"
	else
		echo 'No preview tool found.'
	fi
	;;
esac
