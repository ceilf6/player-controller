tell application "System Events"
	tell process "EVPlayer2"
		if exists then
			click checkbox "播放" of window 1
		end if
	end tell
end tell
