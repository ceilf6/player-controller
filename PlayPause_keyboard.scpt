tell application "System Events"
	tell process "EVPlayer2"
		if exists then
			set frontmost to true
			delay 0.1
			keystroke space
		end if
	end tell
end tell
