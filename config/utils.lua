local wezterm = require("wezterm")

local M = {}

--- 检查 Windows 下命令是否存在
---@param cmd string 命令名称
---@return boolean
function M.windows_command_exists(cmd)
    local success, stdout = wezterm.run_child_process({ "where", cmd })
    return success and stdout and stdout ~= ""
end

--- 检查 Unix 下命令是否存在
---@param cmd string 命令名称
---@return boolean
function M.unix_command_exists(cmd)
    local success, stdout = wezterm.run_child_process({ "sh", "-c", "command -v " .. cmd })
    return success and stdout and stdout ~= ""
end

--- 判断当前是否为 Windows 系统
---@return boolean
function M.is_windows()
    return wezterm.target_triple:find("windows") ~= nil
end

return M
