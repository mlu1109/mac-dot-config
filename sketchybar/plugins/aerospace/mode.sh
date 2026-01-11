#!/bin/bash

ICON="󰰣"

if [ "$MODE" = "SERVICE" ]; then
    COLOR="0xffff0000"  
else
    COLOR="0xff808080"
fi

sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$COLOR" \
    label="" \
    click_script="$CONFIG_DIR/plugins/aerospace/mode_click.sh $MODE"

