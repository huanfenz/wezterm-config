local M = {}

function M.apply(config)
    config.launch_menu = {
        -- Shell
        { label = "Bash",           args = { "bash", "-l" } },
        { label = "Zsh",            args = { "zsh", "-l" } },
        { label = "Pwsh",           args = { "pwsh.exe", "-NoLogo" } },
        { label = "PowerShell",     args = { "powershell.exe", "-NoLogo" } },

        -- WSL 发行版
        { label = "WSL: fedora",    args = { "wsl.exe", "-d", "fedora" } },
    }
end

return M
