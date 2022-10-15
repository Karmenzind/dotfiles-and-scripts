#!/usr/bin/env bash
scope_path=~/.config/ranger/scope.sh

if command -V pistol >/dev/null; then
    pistol "$@"
elif [[ -f $scope_path ]]; then
    bash $scope_path "$@"
else
    echo 'No preview tool found.'
fi
