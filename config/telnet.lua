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
    {
        label = "130.30.6.11",
        args = { "C:\\Program Files\\PuTTY\\plink.exe", "-telnet", "130.30.6.11" },
        domain = "DefaultDomain",
    },
}

function M.apply(config)
    -- 将 Telnet 目标注入 launch_menu，使其出现在 Ctrl+Shift+Space 启动器中
    config.launch_menu = config.launch_menu or {}
    for _, target in ipairs(M.TELNET_TARGETS) do
        table.insert(config.launch_menu, {
            label = "Telnet: " .. target.label,
            args = target.args,
            domain = target.domain,
        })
    end
end

return M
