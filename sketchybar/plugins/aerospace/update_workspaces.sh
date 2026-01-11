#!/bin/bash

aerospace=/opt/homebrew/bin/aerospace
sid=$1

if [ -n "$FOCUSED_WORKSPACE" ]; then
    if [ "$sid" = "$FOCUSED_WORKSPACE" ]; then
        sketchybar --set space.$sid background.drawing=on
    else
        sketchybar --set space.$sid background.drawing=off
    fi
fi

get_app_names_for_workspace() {
    local sid="$1"
    $aerospace list-windows --workspace "$sid" \
      | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}'
}

get_workspace_strip() {
    local sid="$1"
    local icon_strip=""
    local app
    app_names=$(get_app_names_for_workspace "$sid")
    while read -r app; do
        show_workspace="1"
        if [[ -n "$app" ]]; then
            icon=$($CONFIG_DIR/plugins/aerospace/update_workspaces_icons.sh "$app")
            if [[ -n "$icon" ]]; then
                icon_strip+="$icon"
            else
                icon_strip+="$app "
            fi
        fi
    done <<< "$app_names"
    echo "$icon_strip"
}

ws_strip=$(get_workspace_strip "$sid")
sketchybar \
    --set space.$sid \
    label="$ws_strip" \
    icon="$sid"
