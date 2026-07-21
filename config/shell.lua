local utils = require("config.utils")

local M = {}

function M.apply(config)
    if utils.is_windows() then
        config.default_prog = { "powershell.exe", "-NoLogo", "-NoExit", "-Command", "[Console]::OutputEncoding = [Console]::InputEncoding = [Text.Encoding]::UTF8" }
    else
        -- Unix 系统：zsh → bash
        if utils.unix_command_exists("zsh") then
            config.default_prog = { "zsh", "-i" }
        else
            config.default_prog = { "bash", "-i" }
        end
    end
end

return M
