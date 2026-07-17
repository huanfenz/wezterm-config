-- 按键绑定（常用）

local wezterm = require("wezterm")

local constants = require("config.constants")
local bg = require("config.background")
local quick_settings = require("config.quick_settings")

local M = {}

function M.apply(config)
    local act = wezterm.action

    -- 禁用默认快捷键
    config.disable_default_key_bindings = true

    -- 构建配色方案选择器的选项
    local color_scheme_choices = {}
    for _, scheme in ipairs(constants.COLOR_SCHEMES) do
        table.insert(color_scheme_choices, { label = scheme })
    end

    config.keys = {
        -- ========== [ok]窗口管理 ==========
        { key = "F11", mods = "NONE", action = act.ToggleFullScreen },

        -- ========== [ok]标签页管理 (Chrome 风格，除了W和T避免与bash冲突) ==========
        { key = "T", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
        { key = "W", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },
        { key = "F4", mods = "CTRL", action = act.CloseCurrentTab({ confirm = false }) },
        { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
        { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
        { key = "PageUp", mods = "CTRL", action = act.ActivateTabRelative(-1) },
        { key = "PageDown", mods = "CTRL", action = act.ActivateTabRelative(1) },
        { key = "PageUp", mods = "CTRL|SHIFT", action = act.MoveTabRelative(-1) },
        { key = "PageDown", mods = "CTRL|SHIFT", action = act.MoveTabRelative(1) },
        { key = "1", mods = "CTRL", action = act.ActivateTab(0) },
        { key = "2", mods = "CTRL", action = act.ActivateTab(1) },
        { key = "3", mods = "CTRL", action = act.ActivateTab(2) },
        { key = "4", mods = "CTRL", action = act.ActivateTab(3) },
        { key = "5", mods = "CTRL", action = act.ActivateTab(4) },
        { key = "6", mods = "CTRL", action = act.ActivateTab(5) },
        { key = "7", mods = "CTRL", action = act.ActivateTab(6) },
        { key = "8", mods = "CTRL", action = act.ActivateTab(7) },
        { key = "9", mods = "CTRL", action = act.ActivateLastTab },

        -- ========== [ok]定制功能：F2重命名当前标签页 ==========
        {
            key = "F2",
            mods = "NONE",
            action = act.PromptInputLine({
                description = "输入新标签名:",
                action = wezterm.action_callback(function(window, _pane, line)
                    if line then
                        window:active_tab():set_title(line)
                    end
                end),
            }),
        },

        -- ========== [ok]窗格分割 (Windows Terminal 风格) ==========
        { key = "-", mods = "ALT|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
        { key = "/", mods = "ALT|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

        -- ========== [ok]窗格导航 (Alt + 方向键) ==========
        { key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
        { key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },
        { key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
        { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },

        -- ========== [ok]窗格大小调整 (Alt+Shift + 方向键) ==========
        { key = "LeftArrow", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
        { key = "DownArrow", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
        { key = "UpArrow", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
        { key = "RightArrow", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

        -- ========== [ok]复制粘贴 ==========
        { key = "Insert", mods = "CTRL", action = act.CopyTo("Clipboard") },
        { key = "Insert", mods = "SHIFT", action = act.PasteFrom("Clipboard") },

        -- ========== [ok]搜索与滚动 ==========
        { key = "F", mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },
        { key = "K", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },
        { key = "Home", mods = "CTRL|SHIFT", action = act.ScrollToTop },
        { key = "End", mods = "CTRL|SHIFT", action = act.ScrollToBottom },

        -- ========== [ok]缩放 (Ctrl+/-/0) ==========
        { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
        { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
        { key = "0", mods = "CTRL", action = act.ResetFontSize },

        -- ========== [ok]复制模式 ==========
        -- { key = "X", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },

        -- ========== [ok]启动器 ==========
        {
            key = "Space",
            mods = "CTRL",
            action = act.ShowLauncherArgs({
                flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS",
            }),
        },
        {
            key = "P",
            mods = "CTRL|SHIFT",
            action = act.ShowLauncherArgs({
                flags = "FUZZY|KEY_ASSIGNMENTS",
            }),
        },

        -- ========== [ok]快捷设置 ==========
        {
            key = ",",
            mods = "CTRL",
            action = act.InputSelector({
                title = "快捷设置",
                choices = quick_settings.get_choices(),
                action = wezterm.action_callback(function(window, _pane, id, _label)
                    if id then
                        quick_settings.toggle(window, id)
                    end
                end),
            }),
        },
    }
end

return M
