-- EVPlayer2 Media Keys Support
-- This script allows you to control EVPlayer2 with media keys

function controlEVPlayer(action)
    local scriptPath = os.getenv("HOME") .. "/Library/Scripts/EVPlayer2/" .. action .. ".scpt"
    hs.osascript.applescriptFromFile(scriptPath)
end

-- Bind media keys to EVPlayer2 controls
-- F7: Previous track
hs.hotkey.bind({}, "f7", function()
    controlEVPlayer("Previous")
end)

-- F8: Play/Pause
hs.hotkey.bind({}, "f8", function()
    controlEVPlayer("PlayPause")
end)

-- F9: Next track
hs.hotkey.bind({}, "f9", function()
    controlEVPlayer("Next")
end)

hs.alert.show("EVPlayer2 media keys loaded!")
