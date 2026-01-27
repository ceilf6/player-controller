#!/bin/bash

# EVPlayer2 Screenshot Script
# Usage: ./screenshot.sh

# Get EVPlayer2 process ID
PID=$(pgrep -x "EVPlayer2")
if [ -z "$PID" ]; then
    echo "Error: EVPlayer2 is not running"
    exit 1
fi

# Get current playback time from EVPlayer2 window
PLAY_TIME=$(osascript -e '
tell application "System Events"
    tell process "EVPlayer2"
        tell window 1
            set allText to {}
            repeat with elem in (every static text)
                try
                    set end of allText to value of elem
                end try
            end repeat
            return item 1 of allText
        end tell
    end tell
end tell' 2>/dev/null)

if [ -z "$PLAY_TIME" ]; then
    echo "Error: Could not get playback time"
    exit 1
fi

# Extract current time (before the slash)
CURRENT_TIME=$(echo "$PLAY_TIME" | cut -d'/' -f1)
echo "Current playback time: $CURRENT_TIME"

# Find the currently playing .ts file
VIDEO_FILE=$(lsof -p "$PID" 2>/dev/null | grep '\.ts$' | awk '{print $NF}' | head -1)

if [ -z "$VIDEO_FILE" ]; then
    echo "Error: Could not find playing video file"
    exit 1
fi

echo "Video file: $VIDEO_FILE"

# Generate output filename with timestamp
OUTPUT_FILE="$HOME/Desktop/EVPlayer_$(date +%Y%m%d_%H%M%S).png"

# Use ffmpeg to extract frame at current time
echo "Taking screenshot..."
/opt/homebrew/bin/ffmpeg -ss "$CURRENT_TIME" -i "$VIDEO_FILE" -frames:v 1 -q:v 2 "$OUTPUT_FILE" -y 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Screenshot saved: $OUTPUT_FILE"
    # Show notification
    osascript -e "display notification \"Screenshot saved to Desktop\" with title \"EVPlayer2 Screenshot\""
else
    echo "✗ Failed to take screenshot"
    exit 1
fi
