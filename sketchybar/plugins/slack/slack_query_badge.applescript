tell application "System Events"
    tell process "Dock"
        get value of attribute "AXStatusLabel" of UI element "Slack" of list 1
    end tell
end tell