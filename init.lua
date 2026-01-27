-- EVPlayer2 Media Keys Support
-- This script allows you to control EVPlayer2 with media keys

function controlEVPlayer(action)
    -- Get EVPlayer2 app
    local evplayer = hs.application.get("EVPlayer2")
    if not evplayer then
        print("  ✗ EVPlayer2 not running")
        return
    end

    if action == "PlayPause" then
        -- Activate and send space key for play/pause
        evplayer:activate()
        hs.timer.usleep(200000)  -- 200ms
        hs.eventtap.keyStroke({}, "space")
        print("  ✓ PlayPause - space key sent")
    elseif action == "Next" then
        -- Click the >> button
        local script = [[
            tell application "System Events"
                tell process "EVPlayer2"
                    click button ">>" of window 1
                end tell
            end tell
        ]]
        hs.osascript.applescript(script)
        print("  ✓ Next - clicked >> button")
    elseif action == "Previous" then
        -- Click the << button
        local script = [[
            tell application "System Events"
                tell process "EVPlayer2"
                    click button "<<" of window 1
                end tell
            end tell
        ]]
        hs.osascript.applescript(script)
        print("  ✓ Previous - clicked << button")
    end
end

-- Media key event tap
local mediaKeyTap = nil

function createMediaKeyTap()
    return hs.eventtap.new({hs.eventtap.event.types.systemDefined}, function(event)
        local data = event:systemKey()

        if not data or not data.down then
            return false
        end

        local evplayer = hs.application.get("EVPlayer2")
        if not evplayer then
            return false
        end

        local key = data.key

        if key == "PLAY" or key == "PAUSE" or key == "PLAY_PAUSE" then
            print("Play/Pause")
            controlEVPlayer("PlayPause")
            return true
        elseif key == "NEXT" or key == "FAST" then
            print("Next")
            controlEVPlayer("Next")
            return true
        elseif key == "PREVIOUS" or key == "REWIND" then
            print("Previous")
            controlEVPlayer("Previous")
            return true
        end

        return false
    end)
end

function ensureMediaKeyTapRunning()
    if mediaKeyTap == nil or not mediaKeyTap:isEnabled() then
        print("⚠ Media key tap was stopped, restarting...")
        if mediaKeyTap then
            mediaKeyTap:stop()
        end
        mediaKeyTap = createMediaKeyTap()
        mediaKeyTap:start()
        print("✓ Media key tap restarted")
    end
end

-- Start the media key tap
mediaKeyTap = createMediaKeyTap()
mediaKeyTap:start()

-- Watchdog: check every 5 seconds
local watchdogTimer = hs.timer.doEvery(5, ensureMediaKeyTapRunning)

-- F-key bindings as backup
hs.hotkey.bind({}, "f7", function()
    print("F7 - Previous")
    controlEVPlayer("Previous")
end)

hs.hotkey.bind({}, "f8", function()
    print("F8 - Play/Pause")
    controlEVPlayer("PlayPause")
end)

hs.hotkey.bind({}, "f9", function()
    print("F9 - Next")
    controlEVPlayer("Next")
end)

hs.alert.show("EVPlayer2 media keys loaded!")
