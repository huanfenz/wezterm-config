local wezterm = require("wezterm")
local bg = require("config.background")

local M = {}

local choices = {
    {
        id = "cursor_blink",
        label = "光标闪烁切换",
    },
    {
        id = "background",
        label = "背景图片显示切换",
    },
}

function M.get_choices()
    return choices
end

function M.toggle(window, id)
    if id == "cursor_blink" then
        local overrides = window:get_config_overrides() or {}
        if overrides.cursor_blink_rate and overrides.cursor_blink_rate == 0 then
            overrides.cursor_blink_rate = nil
        else
            overrides.cursor_blink_rate = 0
        end
        window:set_config_overrides(overrides)
    elseif id == "background" then
        bg.toggle(window)
    end
end

function M.apply()
end

return M
