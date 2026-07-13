-- 共享常量

local wezterm = require("wezterm")

local M = {}

M.CONFIG_DIR = wezterm.config_dir

M.COLOR_SCHEMES = {
    "Ayu Mirage",
    "Tokyo Night",
    "Catppuccin Mocha",
    "Catppuccin Latte",
    "One Dark (Gogh)",
    "Dracula",
    "Gruvbox Dark (Gogh)",
    "Nord",
    "Solarized Dark (Gogh)",
    "Rose Pine",
}

return M
