-- 高级设置

local M = {}

function M.apply(config)
    -- 滚动配置
    config.enable_scroll_bar = true
    config.scrollback_lines = 20000

    -- 自动重载配置
    config.automatically_reload_config = true

    -- 退出行为
    config.exit_behavior = "CloseOnCleanExit"
    config.exit_behavior_messaging = "Verbose"

    -- 状态更新间隔
    config.status_update_interval = 50000

    -- 启用 OSC 52 剪贴板支持（允许远程程序访问本地剪贴板）
    -- 这使得远程 Vim/Helix 可以使用系统剪贴板
    config.enable_wayland = false -- Windows 不需要

    -- 使用 Ssh2 后端，对密码认证支持更好
    config.ssh_backend = "Ssh2"
end

return M
