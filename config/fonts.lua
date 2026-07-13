--字体

local wezterm = require("wezterm")

local constants = require("config.constants")

local M = {}

function M.apply(config)
    config.font_dirs = { constants.CONFIG_DIR .. "/fonts" }
    config.font = wezterm.font_with_fallback({
        "Maple Mono CN",
        "Maple Mono NF CN",
        "Segoe UI Symbol",
    })
    config.font_size = 12
end

return M
