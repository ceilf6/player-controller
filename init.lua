-- EVPlayer2 Media Keys Support
-- This script allows you to control EVPlayer2 with media keys

function controlEVPlayer(action)
    local scriptPath = os.getenv("HOME") .. "/Library/Scripts/EVPlayer2/" .. action .. ".scpt"
    hs.osascript.applescriptFromFile(scriptPath)
end

-- Media key event tap using systemDefined events
local mediaKeyTap = hs.eventtap.new({hs.eventtap.event.types.systemDefined}, function(event)
    local data = event:systemKey()

    -- Debug: print what we receive (can be removed later)
    if data and data.down then
        print("Media key detected: " .. tostring(data.key))
    end

    if not data or not data.down then
        return false
    end

    -- Check if EVPlayer2 is running
    local evplayer = hs.application.get("EVPlayer2")
    if not evplayer then
        return false  -- Let other apps handle it
    end

    local key = data.key

    -- Handle different media key names
    if key == "PLAY" or key == "PAUSE" or key == "PLAY_PAUSE" then
        controlEVPlayer("PlayPause")
        return true  -- Block the event from other apps
    elseif key == "NEXT" or key == "FAST" then
        controlEVPlayer("Next")
        return true
    elseif key == "PREVIOUS" or key == "REWIND" then
        controlEVPlayer("Previous")
        return true
    end

    return false
end)

-- Start the media key tap
mediaKeyTap:start()

-- Also keep F-key bindings as backup
hs.hotkey.bind({}, "f7", function()
    controlEVPlayer("Previous")
end)

hs.hotkey.bind({}, "f8", function()
    controlEVPlayer("PlayPause")
end)

hs.hotkey.bind({}, "f9", function()
    controlEVPlayer("Next")
end)

hs.alert.show("EVPlayer2 media keys loaded!")
