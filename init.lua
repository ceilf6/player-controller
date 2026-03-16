-- Smart Media Keys Support
-- Controls the last active media player (EVPlayer2 / NeteaseMusic / bilibili)

-- Track the last active media player
local lastActiveMediaPlayer = nil

local function normalizeMediaPlayerName(appName, bundleID)
    if appName == "EVPlayer2" or appName == "EV2Player" then
        return "EVPlayer2"
    end
    if appName == "网易云音乐" or appName == "NeteaseMusic" then
        return "网易云音乐"
    end
    if appName == "bilibili" or appName == "Bilibili" or bundleID == "tv.danmaku.bilianime" then
        return "bilibili"
    end
    return nil
end

local function getEVPlayerApp()
    return hs.application.get("EVPlayer2") or hs.application.get("EV2Player")
end

local function getBilibiliApp()
    local bilibili = hs.application.get("bilibili") or hs.application.get("Bilibili")
    if bilibili then
        return bilibili
    end

    local apps = hs.application.applicationsForBundleID("tv.danmaku.bilianime")
    if apps and #apps > 0 then
        return apps[1]
    end

    return nil
end

-- Application watcher to track media player activation
local appWatcher = hs.application.watcher.new(function(appName, eventType, app)
    if eventType ~= hs.application.watcher.activated then
        return
    end

    local bundleID = app and app:bundleID() or nil
    local normalized = normalizeMediaPlayerName(appName, bundleID)
    if normalized then
        lastActiveMediaPlayer = normalized
        print("Media player activated: " .. normalized)
    end
end)
appWatcher:start()

-- Control EVPlayer2
function controlEVPlayer(action)
    local evplayer = getEVPlayerApp()
    if not evplayer then
        print("  ✗ EVPlayer2 not running")
        return false
    end

    local processName = evplayer:name() or "EVPlayer2"
    if action == "PlayPause" then
        evplayer:activate()
        hs.timer.usleep(200000)
        hs.eventtap.keyStroke({}, "space")
        print("  ✓ EVPlayer2 PlayPause")
    elseif action == "Next" then
        local ok = hs.osascript.applescript(string.format([[
            tell application "System Events"
                tell process "%s"
                    click button ">>" of window 1
                end tell
            end tell
        ]], processName))
        if not ok then
            print("  ✗ EVPlayer2 Next failed")
            return false
        end
        print("  ✓ EVPlayer2 Next")
    elseif action == "Previous" then
        local ok = hs.osascript.applescript(string.format([[
            tell application "System Events"
                tell process "%s"
                    click button "<<" of window 1
                end tell
            end tell
        ]], processName))
        if not ok then
            print("  ✗ EVPlayer2 Previous failed")
            return false
        end
        print("  ✓ EVPlayer2 Previous")
    end

    lastActiveMediaPlayer = "EVPlayer2"
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
        local ok = hs.osascript.applescript([[
            tell application "System Events"
                tell process "NeteaseMusic"
                    set menuItem to menu item 1 of menu 1 of menu bar item "控制" of menu bar 1
                    click menuItem
                end tell
            end tell
        ]])
        if not ok then
            print("  ✗ 网易云音乐 PlayPause failed")
            return false
        end
        print("  ✓ 网易云音乐 PlayPause")
    elseif action == "Next" then
        local ok = hs.osascript.applescript([[
            tell application "System Events"
                tell process "NeteaseMusic"
                    click menu item "下一个" of menu 1 of menu bar item "控制" of menu bar 1
                end tell
            end tell
        ]])
        if not ok then
            print("  ✗ 网易云音乐 Next failed")
            return false
        end
        print("  ✓ 网易云音乐 Next")
    elseif action == "Previous" then
        local ok = hs.osascript.applescript([[
            tell application "System Events"
                tell process "NeteaseMusic"
                    click menu item "上一个" of menu 1 of menu bar item "控制" of menu bar 1
                end tell
            end tell
        ]])
        if not ok then
            print("  ✗ 网易云音乐 Previous failed")
            return false
        end
        print("  ✓ 网易云音乐 Previous")
    end

    lastActiveMediaPlayer = "网易云音乐"
    return true
end

-- Control bilibili (PlayPause: space, Next/Previous: right/left)
function controlBilibili(action)
    local bilibili = getBilibiliApp()
    if not bilibili then
        print("  ✗ bilibili not running")
        return false
    end

    bilibili:activate()
    hs.timer.usleep(200000)

    if action == "PlayPause" then
        hs.eventtap.keyStroke({}, "space")
        print("  ✓ bilibili PlayPause")
    elseif action == "Next" then
        hs.eventtap.keyStroke({}, "right")
        print("  ✓ bilibili Next (seek forward)")
    elseif action == "Previous" then
        hs.eventtap.keyStroke({}, "left")
        print("  ✓ bilibili Previous (seek backward)")
    end

    lastActiveMediaPlayer = "bilibili"
    return true
end

-- Control the last active media player
function controlMediaPlayer(action)
    print("Action: " .. action .. " | Last player: " .. (lastActiveMediaPlayer or "none"))

    -- 1) 优先控制最近一次激活/操作成功的播放器
    if lastActiveMediaPlayer == "EVPlayer2" and controlEVPlayer(action) then
        return true
    end
    if lastActiveMediaPlayer == "网易云音乐" and controlNeteaseMusic(action) then
        return true
    end
    if lastActiveMediaPlayer == "bilibili" and controlBilibili(action) then
        return true
    end

    -- 2) 若最近播放器不可用，则尝试当前前台播放器
    local frontmost = hs.application.frontmostApplication()
    if frontmost then
        local normalized = normalizeMediaPlayerName(frontmost:name(), frontmost:bundleID())
        if normalized == "EVPlayer2" and controlEVPlayer(action) then
            return true
        end
        if normalized == "网易云音乐" and controlNeteaseMusic(action) then
            return true
        end
        if normalized == "bilibili" and controlBilibili(action) then
            return true
        end
    end

    -- 3) 兜底顺序保持旧逻辑优先 EVPlayer2，再网易云，再 bilibili
    if controlEVPlayer(action) then
        return true
    end
    if controlNeteaseMusic(action) then
        return true
    end
    if controlBilibili(action) then
        return true
    end

    print("  ✗ No supported media player is running")
    return false
end

-- Media key event tap
local mediaKeyTap = nil

function createMediaKeyTap()
    return hs.eventtap.new({hs.eventtap.event.types.systemDefined}, function(event)
        local data = event:systemKey()

        -- data.down == false 表示松键，跳过；
        -- data.down == true 或 nil（内置键盘部分系统版本不设置此字段）均视为按下
        if not data or data.down == false then
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
