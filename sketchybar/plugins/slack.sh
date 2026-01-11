#!/bin/bash

# Source colors
source "$CONFIG_DIR/colors.sh"
PLUGIN_DIR="$CONFIG_DIR/plugins"

# Set icon
ICON="󰒱"  # Slack icon from Nerd Fonts

# Check if Slack is running
IS_RUNNING=$(gtimeout 1 osascript "$PLUGIN_DIR/slack_query_open.applescript" 2>/dev/null)

if [ "$IS_RUNNING" != "true" ]; then
    # Slack is not running - grey it out
    COLOR="$COLOR_GREY"
    LABEL=""
    LABEL_DRAWING="off"
else
    # Get Slack notification count from dock badge
    BADGE=$(gtimeout 1 osascript "$PLUGIN_DIR/slack_query_open.applescript" 2>/dev/null)

    # Handle "missing value" case (no notifications)
    if [ "$BADGE" = "missing value" ] || [ -z "$BADGE" ]; then
        COUNT=0
    else
        COUNT=$BADGE
    fi

    # Set color based on notification count
    if [ "$BADGE" = "•" ]; then
        COLOR="$COLOR_ORANGE"
        LABEL=""
        LABEL_DRAWING="off"
    elif [ "$COUNT" -gt 0 ]; then
        COLOR="$COLOR_RED"
        LABEL="$COUNT"
        LABEL_DRAWING="on"
    else
        COLOR="$COLOR_WHITE"
        LABEL=""
        LABEL_DRAWING="off"
    fi
fi

# Update SketchyBar
sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$COLOR" \
    label="$LABEL" \
    label.color="$COLOR" \
    label.drawing="$LABEL_DRAWING"
