#!/usr/bin/env bash
scope_path=~/.config/ranger/scope.sh

filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

case $extension in
jpg | png | jpeg)
    bash $scope_path "$@"
    ;;
*)
    if command -V pistol >/dev/null; then
        pistol "$@"
    elif [[ -f $scope_path ]]; then
        bash $scope_path "$@"
    else
        echo 'No preview tool found.'
    fi
    ;;
esac
