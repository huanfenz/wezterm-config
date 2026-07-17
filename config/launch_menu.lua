local M = {}

function M.apply(config)
    config.launch_menu = {
        -- Shell（指定 DefaultDomain 则在本地打开）
        -- { label = "PowerShell",     args = { "powershell.exe", "-NoLogo" },     domain = "DefaultDomain" },

        -- 默认WSL
        -- { label = "WSL: Default",    args = { "wsl.exe" },       domain = "DefaultDomain" },
    }
end

return M
