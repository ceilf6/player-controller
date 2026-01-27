tell application "System Events"
	tell process "EVPlayer2"
		if exists then
			click button "停止" of window 1
		end if
	end tell
end tell
