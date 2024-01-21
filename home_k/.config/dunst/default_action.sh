#!/usr/bin/env bash

# TODO (k): <2024-01-26 01:05> exit if not i3

notify-send "$DUNST_APP_NAME"
case $DUNST_APP_NAME in
    electronic-wechat )
        i3-msg [class="$DUNST_APP_NAME"] focus
        ;;
esac
