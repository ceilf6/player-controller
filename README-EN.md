# Media Control Script Configuration

[中文文档](README.md)

## 1. Create control scripts

Location:

~/Library/Scripts/EVPlayer2/

List of scripts:
- PlayPause.scpt — Play / Pause
- Next.scpt — Next
- Previous.scpt — Previous

---

## 2. Create Hammerspoon configuration

Config file location:

~/.hammerspoon/init.lua

Hotkey mapping:

Key	Function
F7	Previous
F8	Play / Pause
F9	Next

---

Next steps

Install Hammerspoon (free and open source)

Method 1: Use Homebrew (recommended)

brew install --cask hammerspoon

Method 2: Manual download
1. Visit
https://github.com/Hammerspoon/hammerspoon/releases/latest
2. Download and drag Hammerspoon into /Applications/

---

Start Hammerspoon
1. Open the Hammerspoon app
2. Grant Accessibility permissions:
System Settings → Privacy & Security → Accessibility
3. Click the Hammerspoon menu bar icon → Reload Config

---

Alternatives

If you prefer using the actual media keys (instead of F7–F9), consider:
- BetterTouchTool (paid, powerful)
- Karabiner-Elements (free, more complex to configure)

# Screenshot bypass for protected players
Some video players render through hardware layers that prevent screenshot tools from capturing frames. However, some players cache content as local .ts files. This tool captures a screenshot by performing the following steps:

1. Use AppleScript to read from the player window:
   - Current playback time (e.g. 00:06:08)
   - Window title (to match the cached file)
2. Locate the corresponding .ts video file in the specified download/cache directory
3. Use ffmpeg to extract the frame at that timestamp
4. Bind a global hotkey via Hammerspoon to trigger the process with one key
