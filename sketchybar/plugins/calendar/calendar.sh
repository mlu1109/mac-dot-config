#!/bin/bash

# Source colors
source "$CONFIG_DIR/colors.sh"

# Set icon
ICON="󰃭"  # Calendar icon from Nerd Fonts

# Get current time in seconds since epoch
CURRENT_TIME=$(date +%s)

# Get next event from Work calendar using Swift script
SCRIPT_DIR="$(dirname "$0")"
EVENT_DATA=$(swift "$SCRIPT_DIR/get_next_event.swift" 2>/dev/null)

# Default values
COLOR="$COLOR_WHITE"
LABEL=""
LABEL_DRAWING="off"

if [ -n "$EVENT_DATA" ] && [ "$EVENT_DATA" != "No events today" ] && [ "$EVENT_DATA" != "Work calendar not found" ] && [ "$EVENT_DATA" != "Calendar access denied" ]; then
    # Parse event data: start_epoch|end_epoch|title
    IFS='|' read -r START_EPOCH END_EPOCH TITLE <<< "$EVENT_DATA"
    
    if [ -n "$START_EPOCH" ] && [ -n "$END_EPOCH" ]; then
        # Check if currently in this meeting
        if [ "$CURRENT_TIME" -ge "$START_EPOCH" ] && [ "$CURRENT_TIME" -lt "$END_EPOCH" ]; then
            # Currently in a meeting - show "busy"
            COLOR="$COLOR_RED"
            LABEL="busy"
            LABEL_DRAWING="on"
        else
            # Calculate time until next meeting
            TIME_DIFF=$((START_EPOCH - CURRENT_TIME))

            if [ "$TIME_DIFF" -lt 300 ]; then
                # Less than 5 minutes - show in orange with minutes
                MINUTES=$((TIME_DIFF / 60))
                COLOR="$COLOR_ORANGE"
                LABEL="${MINUTES}m"
                LABEL_DRAWING="on"
            elif [ "$TIME_DIFF" -lt 3600 ]; then
                # Less than 1 hour - show minutes
                MINUTES=$((TIME_DIFF / 60))
                COLOR="$COLOR_YELLOW"
                LABEL="${MINUTES}m"
                LABEL_DRAWING="on"
            else
                # 1 hour or more - show hours and minutes
                HOURS=$((TIME_DIFF / 3600))
                MINUTES=$(((TIME_DIFF % 3600) / 60))
                COLOR="$COLOR_WHITE"
                LABEL="${HOURS}h ${MINUTES}m"
                LABEL_DRAWING="on"
            fi
        fi
    fi
else
    # No events today or error
    COLOR="$COLOR_GREY"
    LABEL=""
    LABEL_DRAWING="off"
fi

# Update SketchyBar
sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$COLOR" \
    label="$LABEL" \
    label.color="$COLOR" \
    label.drawing="$LABEL_DRAWING"
