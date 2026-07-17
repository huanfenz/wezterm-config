local wezterm = require("wezterm")
local bg = require("config.background")
local constants = require("config.constants")

local M = {}

-- 构建配色方案选择器选项
local color_scheme_choices = {}
for _, scheme in ipairs(constants.COLOR_SCHEMES) do
    table.insert(color_scheme_choices, { label = scheme })
end

local function notify(window, text)
    window:set_right_status(wezterm.format({ { Text = "  " .. text .. "  " } }))
    wezterm.time.call_after(2, function()
        window:set_right_status("")
    end)
end

local choices = {
    {
        id = "cursor_blink",
        label = "光标闪烁开关",
    },
    {
        id = "background",
        label = "背景图片显示开关",
    },
    {
        id = "background_select",
        label = "背景图片选择",
    },
    {
        id = "color_scheme_select",
        label = "配色方案选择",
    },
}

function M.get_choices()
    return choices
end

function M.toggle(window, id)
    local act = wezterm.action
    if id == "cursor_blink" then
        local overrides = window:get_config_overrides() or {}
        local new_state
        if overrides.default_cursor_style == "BlinkingBar" then
            overrides.default_cursor_style = "SteadyBar"
            overrides.cursor_blink_rate = 0
            new_state = "关闭"
        else
            overrides.default_cursor_style = "BlinkingBar"
            overrides.cursor_blink_rate = nil
            new_state = "开启"
        end
        window:set_config_overrides(overrides)
        notify(window, "光标闪烁：" .. new_state)
    elseif id == "color_scheme_select" then
        window:perform_action(
            act.InputSelector({
                title = "选择配色方案",
                choices = color_scheme_choices,
                action = wezterm.action_callback(function(win, _pane, _id, label)
                    if label then
                        win:set_config_overrides({ color_scheme = label })
                        notify(win, "配色方案：" .. label)
                    end
                end),
            }),
            window:active_pane()
        )
    elseif id == "background_select" then
        window:perform_action(
            act.InputSelector({
                title = "选择背景图片",
                choices = bg.get_image_choices(),
                action = wezterm.action_callback(function(win, _pane, _id, label)
                    if label then
                        bg.select_image(win, label)
                        notify(win, "背景图片：" .. label)
                    end
                end),
            }),
            window:active_pane()
        )
    elseif id == "background" then
        local overrides = window:get_config_overrides() or {}
        local is_enabled = overrides.window_background_image and overrides.window_background_image ~= ""
        bg.toggle(window)
        notify(window, "背景图片：" .. (is_enabled and "关闭" or "开启"))
    end
end

function M.apply()
end

return M
