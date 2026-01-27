-- Force activate EVPlayer2
tell application "EVPlayer2" to activate

-- Wait for activation
delay 0.3

-- Send space key
tell application "System Events"
	keystroke space
end tell
