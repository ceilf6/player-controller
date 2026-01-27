tell application "System Events"
	tell process "EVPlayer2"
		if exists then
			click button ">>" of window 1
		end if
	end tell
end tell
