local wezterm = require("wezterm")

local M = {}

-- Telnet 目标列表（可随时增减）
M.TELNET_TARGETS = {
    {
        label = "130.30.212.18",
        args = { "C:\\Program Files\\PuTTY\\plink.exe", "-telnet", "130.30.212.18" },
        domain = "DefaultDomain",
    },
    {
        label = "192.168.183.102",
        args = { "C:\\Program Files\\PuTTY\\plink.exe", "-telnet", "192.168.183.102" },
        domain = "DefaultDomain",
    },
}

function M.apply(config)
    local act = wezterm.action

    -- 构建选择器选项
    local telnet_choices = {}
    for _, target in ipairs(M.TELNET_TARGETS) do
        table.insert(telnet_choices, { label = target.label })
    end

    -- 快捷键 Ctrl+Shift+E：弹出 Telnet 目标选择器
    config.keys = config.keys or {}
    table.insert(config.keys, {
        key = "E",
        mods = "CTRL|SHIFT",
        action = act.InputSelector({
            title = "选择 Telnet 目标",
            choices = telnet_choices,
            fuzzy = true,
            action = wezterm.action_callback(function(window, pane, _id, label)
                if label then
                    for _, target in ipairs(M.TELNET_TARGETS) do
                        if target.label == label then
                            window:perform_action(
                                act.SpawnCommandInNewTab({
                                    args = target.args,
                                    domain = target.domain,
                                }),
                                pane
                            )
                            wezterm.time.call_after(0.1, function()
                                local tab = window:active_tab()
                                if tab then
                                    tab:set_title("telnet: " .. target.label)
                                end
                            end)
                            break
                        end
                    end
                end
            end),
        }),
    })
end

return M
