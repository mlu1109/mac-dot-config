#!/bin/bash

# Source colors
source "$CONFIG_DIR/colors.sh"

aerospace=/opt/homebrew/bin/aerospace

# Set icon
ICON="󰊫"  # Gmail icon from Nerd Fonts

# Get Gmail window info from aerospace
GMAIL_WINDOW=$($aerospace list-windows --all | ggrep "Gmail")

if [ -z "$GMAIL_WINDOW" ]; then
    # Gmail is not running - grey it out
    COLOR="$COLOR_GREY"
    LABEL=""
    LABEL_DRAWING="off"
else
    # Extract window title (third column after second |)
    TITLE=$(echo "$GMAIL_WINDOW" | awk -F'|' '{print $3}' | sed 's/^ *//')

    # Check if viewing Inbox
    if echo "$TITLE" | ggrep -q "Inbox"; then
        # Extract count from "Inbox (7) - ..." pattern
        COUNT=$(echo "$TITLE" | ggrep -oP 'Inbox \(\K\d+(?=\))' || echo "0")

        # Set color based on unread count
        if [ "$COUNT" -gt 0 ]; then
            COLOR="$COLOR_RED"
            LABEL="$COUNT"
            LABEL_DRAWING="on"
        else
            COLOR="$COLOR_WHITE"
            LABEL=""
            LABEL_DRAWING="off"
        fi
    else
        # Gmail is open but not on Inbox view - yellow indicator
        COLOR="$COLOR_YELLOW"
        LABEL="•"
        LABEL_DRAWING="on"
    fi
fi

# Update SketchyBar
sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$COLOR" \
    label="$LABEL" \
    label.color="$COLOR" \
    label.drawing="$LABEL_DRAWING"