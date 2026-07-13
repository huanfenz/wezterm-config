--------------------------------------------------------------------------------
-- WezTerm Configuration
-- 模块化的 WezTerm 配置文件
-- Developer: gtiders
--------------------------------------------------------------------------------

-- WezTerm Configuration (modular)

local wezterm = require("wezterm")

local config = wezterm.config_builder()

local modules = {
    "config.fonts",
    "config.appearance",
    "config.window",
    "config.tab_bar",
    "config.cursor",
    "config.shell",
    "config.ssh_domains",
    "config.launch_menu",
    "config.events",
    "config.background",
    "config.quick_settings",
    "config.keybindings",
    "config.telnet",
    "config.mouse",
    "config.advanced",
    "config.hyperlink",
}

for _, name in ipairs(modules) do
    local module = require(name)
    if module and module.apply then
        module.apply(config)
    end
end

return config
