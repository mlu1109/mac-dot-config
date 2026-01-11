#!/bin/bash

# Source colors
source "$CONFIG_DIR/colors.sh"

# Set icon
ICON="󰓂"  # GitHub PR icon from Nerd Fonts

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    # gh CLI not found - grey it out
    COLOR="$COLOR_GREY"
    LABEL="?"
    LABEL_DRAWING="on"
else
    # Get PR count and newest PR details using GraphQL API
    # Sorted by created descending to get the most recent PR first
    #
    # The GraphQL API has rate limiting (https://docs.github.com/en/graphql/overview/rate-limits-and-query-limits-for-the-graphql-api)
    # The below query seems to consume one point which means that we should be able to query once per second (consuming 3600 points).
    #
    # Future improvements: 
    # - Control poll interval from this script and take rate limit into account
    # - Add some kind of "max tokens per hour" functionality
    RESULT=$(gh api graphql -f query='
      query {
        search(query: "is:pr is:open review-requested:@me sort:created-desc", type: ISSUE, first: 1) {
          issueCount
          edges {
            node {
              ... on PullRequest {
                title
                createdAt
              }
            }
          }
        }
      }
    ' 2>/dev/null)

    # Check if command succeeded
    if [ $? -ne 0 ] || [ -z "$RESULT" ]; then
        # Error (not authenticated or no network) - grey it out
        COLOR="$COLOR_GREY"
        LABEL=""
        LABEL_DRAWING="off"
    else
        COUNT=$(echo "$RESULT" | jq -r '.data.search.issueCount')

        # Set color based on PR count
        if [ "$COUNT" -gt 0 ]; then
            # Get the newest PR's details
            PR_TITLE=$(echo "$RESULT" | jq -r '.data.search.edges[0].node.title')
            CREATED_AT=$(echo "$RESULT" | jq -r '.data.search.edges[0].node.createdAt')

            # Replace EQF-(digits) with shark icon (case insensitive)
            PR_TITLE=$(echo "$PR_TITLE" | sed -E 's/[Ee][Qq][Ff]-[0-9]+/󱙳/g')

            # Remove conventional commit prefixes (feat, fix, chore, etc.)
            PR_TITLE=$(echo "$PR_TITLE" | sed -E 's/(feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert)(\([^)]*\))?:\s*//i')

            # Trim whitespace
            PR_TITLE=$(echo "$PR_TITLE" | xargs)

            # Truncate title
            MAX_TITLE_LENGTH=20
            if [ ${#PR_TITLE} -gt $MAX_TITLE_LENGTH ]; then
                PR_TITLE="${PR_TITLE:0:$MAX_TITLE_LENGTH}…"
            fi

            # Calculate age
            NOW=$(date +%s)
            # Parse ISO 8601 UTC timestamp - GitHub sends format like "2024-01-09T12:34:56Z"
            CREATED=$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$CREATED_AT" +%s 2>/dev/null)

            if [ -n "$CREATED" ]; then
                AGE_SECONDS=$((NOW - CREATED))
                AGE_MINUTES=$((AGE_SECONDS / 60))
                AGE_HOURS=$((AGE_MINUTES / 60))
                AGE_DAYS=$((AGE_HOURS / 24))

                # Format age: minutes if <1h, hours if >=1h, days if >=24h
                if [ "$AGE_DAYS" -gt 0 ]; then
                    AGE="${AGE_DAYS}d"
                elif [ "$AGE_HOURS" -gt 0 ]; then
                    AGE="${AGE_HOURS}h"
                else
                    AGE="${AGE_MINUTES}m"
                fi

                LABEL="$COUNT: $PR_TITLE ($AGE)"
            else
                LABEL="$COUNT $PR_TITLE"
            fi

            COLOR="$COLOR_GITHUB_PINK"
            LABEL_DRAWING="on"
        else
            COLOR="$COLOR_WHITE"
            LABEL=""
            LABEL_DRAWING="off"
        fi
    fi
fi

# Update SketchyBar
sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$COLOR" \
    label="$LABEL" \
    label.color="$COLOR" \
    label.drawing="$LABEL_DRAWING"