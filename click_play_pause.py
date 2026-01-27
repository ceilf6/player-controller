#!/usr/bin/env python3
import subprocess
import time

# Get checkbox position from AppleScript
script = '''
tell application "System Events"
    tell process "EVPlayer2"
        set checkboxPos to position of checkbox "播放" of window 1
        set checkboxSize to size of checkbox "播放" of window 1
        set centerX to (item 1 of checkboxPos) + ((item 1 of checkboxSize) / 2)
        set centerY to (item 2 of checkboxPos) + ((item 2 of checkboxSize) / 2)
        return centerX & "," & centerY
    end tell
end tell
'''

result = subprocess.run(['osascript', '-e', script], capture_output=True, text=True)
coords = result.stdout.strip().split(',')
x, y = float(coords[0]), float(coords[1])

# Use CoreGraphics to click
click_script = f'''
tell application "System Events"
    set frontmost of process "EVPlayer2" to true
end tell

do shell script "python3 -c 'import Quartz; Quartz.CGEventPost(0, Quartz.CGEventCreateMouseEvent(None, Quartz.kCGEventLeftMouseDown, ({x}, {y}), 0)); Quartz.CGEventPost(0, Quartz.CGEventCreateMouseEvent(None, Quartz.kCGEventLeftMouseUp, ({x}, {y}), 0))'"
'''

subprocess.run(['osascript', '-e', click_script])
