-- Smart Media Keys Support
-- Controls the last active media player (EVPlayer2 or NeteaseMusic)

-- Track the last active media player
local lastActiveMediaPlayer = nil

-- List of media player apps to track
local mediaPlayers = {
    "EVPlayer2",
    "网易云音乐",  -- NeteaseMusic
}

-- Application watcher to track media player activation
local appWatcher = hs.application.watcher.new(function(appName, eventType, app)
    if eventType == hs.application.watcher.activated then
        print("App activated: [" .. (appName or "nil") .. "]")
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
    local netease = hs.application.get("网易云音乐")
    if not netease then
        print("  ✗ 网易云音乐 not running")
        return false
    end

    if action == "PlayPause" then
        -- 菜单项名称会变化：播放中显示"暂停"，暂停时显示"播放"
        local ok, result = hs.osascript.applescript([[
            tell application "System Events"
                tell process "NeteaseMusic"
                    set menuItem to menu item 1 of menu 1 of menu bar item "控制" of menu bar 1
                    click menuItem
                end tell
            end tell
        ]])
        print("  ✓ 网易云音乐 PlayPause")
    elseif action == "Next" then
        hs.osascript.applescript([[
            tell application "System Events"
                tell process "NeteaseMusic"
                    click menu item "下一个" of menu 1 of menu bar item "控制" of menu bar 1
                end tell
            end tell
        ]])
        print("  ✓ 网易云音乐 Next")
    elseif action == "Previous" then
        hs.osascript.applescript([[
            tell application "System Events"
                tell process "NeteaseMusic"
                    click menu item "上一个" of menu 1 of menu bar item "控制" of menu bar 1
                end tell
            end tell
        ]])
        print("  ✓ 网易云音乐 Previous")
    end
    return true
end

-- Control the last active media player
-- 默认控制 EVPlayer2，只有网易云音乐最后激活且正在运行时才控制它
function controlMediaPlayer(action)
    print("Action: " .. action .. " | Last player: " .. (lastActiveMediaPlayer or "none"))

    -- 如果网易云音乐是最后激活的且正在运行，控制它
    if lastActiveMediaPlayer == "网易云音乐" and hs.application.get("网易云音乐") then
        return controlNeteaseMusic(action)
    end

    -- 否则默认控制 EVPlayer2
    return controlEVPlayer(action)
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
