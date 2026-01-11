#!/bin/bash

aerospace=/opt/homebrew/bin/aerospace
sketchybar=/opt/homebrew/bin/sketchybar
MODE=$1

if [ "$MODE" = "SERVICE" ]; then
    $aerospace mode main
    $sketchybar --trigger aerospace_mode_change MODE=MAIN
else
    $aerospace mode service
    $sketchybar --trigger aerospace_mode_change MODE=SERVICE
fi
