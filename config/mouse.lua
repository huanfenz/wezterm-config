local wezterm = require("wezterm")

local M = {}

function M.apply(config)
    local act = wezterm.action

    config.disable_default_mouse_bindings = false

    config.mouse_bindings = {
        -- 左键点击：复制选中文本到剪贴板
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "NONE",
            action = act.CompleteSelection("Clipboard"),
        },
        -- 右键点击：粘贴剪贴板内容
        {
            event = { Down = { streak = 1, button = "Right" } },
            mods = "NONE",
            action = act.PasteFrom("Clipboard"),
        },
        -- Ctrl+Alt+拖动：移动窗口
        {
            event = { Drag = { streak = 1, button = "Left" } },
            mods = "CTRL|ALT",
            action = act.StartWindowDrag,
        },
        -- Ctrl+点击：打开超链接
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "CTRL",
            action = act.OpenLinkAtMouseCursor,
        },
    }
end

return M
