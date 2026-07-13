-- 事件

local wezterm = require("wezterm")

local M = {}

function M.apply(_config)
    -- 切换标签栏显示状态
    wezterm.on("toggle-tab-bar", function(window, _pane)
        local overrides = window:get_config_overrides() or {}
        overrides.enable_tab_bar = not (overrides.enable_tab_bar == nil and true or overrides.enable_tab_bar)
        window:set_config_overrides(overrides)
    end)

    -- 点击标签栏 + 按钮时，始终在本地域创建新标签（而非复制当前 SSH 域）
    wezterm.on("new-tab-button-click", function(window, pane, button, default_action)
        local act = wezterm.action
        if default_action then
            window:perform_action(act.SpawnTab("DefaultDomain"), pane)
        end
        return false
    end)

    wezterm.on("open-uri", function(_window, _pane, uri)
        if uri:lower():match("^file://") then
            local normalized = uri
            if normalized:match("^file://[A-Za-z]:") then
                normalized = normalized:gsub("^file://", "file:///")
            end
            normalized = normalized:gsub("\\\\", "/")

            wezterm.open_with(normalized)
            return true
        end

        wezterm.open_with(uri)
        return true
    end)
end

return M
