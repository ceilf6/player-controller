# 媒体控制脚本配置说明

## 1. 创建控制脚本

**位置：**

```bash
~/Library/Scripts/EVPlayer2/

脚本列表：
- PlayPause.scpt — 播放 / 暂停
- Next.scpt — 下一个
- Previous.scpt — 上一个

⸻

## 2. 创建 Hammerspoon 配置

配置文件位置：

~/.hammerspoon/init.lua

快捷键映射：

快捷键	功能
F7	上一个
F8	播放 / 暂停
F9	下一个


⸻

下一步操作

安装 Hammerspoon（免费开源）

方法 1：使用 Homebrew（推荐）

brew install --cask hammerspoon

方法 2：手动下载
	1.	访问
https://github.com/Hammerspoon/hammerspoon/releases/latest
	2.	下载并将 Hammerspoon 拖入 /Applications/

⸻

启动 Hammerspoon
	1.	打开 Hammerspoon 应用
	2.	授予辅助功能权限：
系统设置 → 隐私与安全性 → 辅助功能
	3.	点击菜单栏 Hammerspoon 图标 → Reload Config

⸻

替代方案

如果希望使用真正的媒体键（而不是 F7–F9），可以考虑：
- BetterTouchTool（付费，功能强大）
- Karabiner-Elements（免费，但配置较复杂）

