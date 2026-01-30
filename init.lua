-- Smart Media Keys Support
-- Controls the last active media player (EVPlayer2 or NeteaseMusic)

-- Track the last active media player
local lastActiveMediaPlayer = nil

-- List of media player apps to track
local mediaPlayers = {
    "EVPlayer2",
    "NeteaseMusic",  -- 网易云音乐
}

-- Application watcher to track media player activation
local appWatcher = hs.application.watcher.new(function(appName, eventType, app)
    if eventType == hs.application.watcher.activated then
        for _, player in ipairs(mediaPlayers) do
            if appName == player then
                lastActiveMediaPlayer = appName
                print("Media player activated: " .. appName)
                break
            end
        end
    end
end)
appWatcher:start()

-- Control EVPlayer2
function controlEVPlayer(action)
    local evplayer = hs.application.get("EVPlayer2")
    if not evplayer then
        print("  ✗ EVPlayer2 not running")
        return false
    end

    if action == "PlayPause" then
        evplayer:activate()
        hs.timer.usleep(200000)
        hs.eventtap.keyStroke({}, "space")
        print("  ✓ EVPlayer2 PlayPause")
    elseif action == "Next" then
        hs.osascript.applescript([[
            tell application "System Events"
                tell process "EVPlayer2"
                    click button ">>" of window 1
                end tell
            end tell
        ]])
        print("  ✓ EVPlayer2 Next")
    elseif action == "Previous" then
        hs.osascript.applescript([[
            tell application "System Events"
                tell process "EVPlayer2"
                    click button "<<" of window 1
                end tell
            end tell
        ]])
        print("  ✓ EVPlayer2 Previous")
    end
    return true
end

-- Control NeteaseMusic
function controlNeteaseMusic(action)
    local netease = hs.application.get("NeteaseMusic")
    if not netease then
        print("  ✗ NeteaseMusic not running")
        return false
    end

    if action == "PlayPause" then
        netease:activate()
        hs.timer.usleep(100000)
        hs.eventtap.keyStroke({}, "space")
        print("  ✓ NeteaseMusic PlayPause")
    elseif action == "Next" then
        netease:activate()
        hs.timer.usleep(100000)
        hs.eventtap.keyStroke({"cmd"}, "right")
        print("  ✓ NeteaseMusic Next")
    elseif action == "Previous" then
        netease:activate()
        hs.timer.usleep(100000)
        hs.eventtap.keyStroke({"cmd"}, "left")
        print("  ✓ NeteaseMusic Previous")
    end
    return true
end

-- Control the last active media player
function controlMediaPlayer(action)
    print("Action: " .. action .. " | Last player: " .. (lastActiveMediaPlayer or "none"))

    if lastActiveMediaPlayer == "EVPlayer2" then
        return controlEVPlayer(action)
    elseif lastActiveMediaPlayer == "NeteaseMusic" then
        return controlNeteaseMusic(action)
    else
        print("  ✗ No media player was recently used")
        return false
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

        local key = data.key

        if key == "PLAY" or key == "PAUSE" or key == "PLAY_PAUSE" then
            controlMediaPlayer("PlayPause")
            return true
        elseif key == "NEXT" or key == "FAST" then
            controlMediaPlayer("Next")
            return true
        elseif key == "PREVIOUS" or key == "REWIND" then
            controlMediaPlayer("Previous")
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
hs.hotkey.bind({}, "f7", function() controlMediaPlayer("Previous") end)
hs.hotkey.bind({}, "f8", function() controlMediaPlayer("PlayPause") end)
hs.hotkey.bind({}, "f9", function() controlMediaPlayer("Next") end)

hs.alert.show("Smart media keys loaded!")
