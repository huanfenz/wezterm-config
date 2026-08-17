-- 会话保存与恢复（基于 resurrect.wezterm 插件），纯手动模式：
--   Ctrl+Shift+S  输入名称，保存当前所有窗口/标签布局
--   Ctrl+Shift+R  选择已保存的工作区，恢复到当前窗口
--   Ctrl+Shift+D  选择已保存的工作区，删除其状态文件
-- SSH 域标签页恢复时会自动重新连接；本地标签恢复工作目录和屏幕输出
-- 注意：Telnet(plink) 标签恢复的是布局和输出文本，需手动重连（Ctrl+Shift+E）

local wezterm = require("wezterm")

-- 插件加载时会执行 3 条残缺的 mkdir 命令（os.execute），在 Windows 上每次
-- 都会闪一个 cmd 黑框且必然报"命令语法不正确"；require 期间临时屏蔽
-- os.execute 以消除黑框。目录改由下方 ensure_save_dir() 正确创建
local real_os_execute = os.execute
os.execute = function(_cmd)
    return true
end
local ok, resurrect = pcall(wezterm.plugin.require, "https://github.com/MLFlexer/resurrect.wezterm")
os.execute = real_os_execute
if not ok then
    wezterm.log_error("加载 resurrect.wezterm 插件失败: " .. tostring(resurrect))
end

local M = {}

-- 状态文件目录（放在用户数据目录，避免污染配置 git 仓库）
local SAVE_DIR = (os.getenv("USERPROFILE") or "") .. "\\.local\\share\\wezterm\\resurrect"

-- 插件的 change_state_save_dir 在 Windows 上有 mkdir 引号 bug，
-- 因此这里手动创建目录后直接赋值 save_state_dir
local function ensure_save_dir()
    local ok, entries = pcall(wezterm.read_dir, SAVE_DIR)
    if not ok or entries == nil then
        -- run_child_process 不会闪黑框（os.execute 会拉起 cmd 窗口）
        wezterm.run_child_process({
            "cmd", "/c", "md",
            SAVE_DIR .. "\\workspace", SAVE_DIR .. "\\window", SAVE_DIR .. "\\tab",
        })
    end
    resurrect.state_manager.save_state_dir = SAVE_DIR .. "\\"
end

-- 用 wezterm.read_dir 扫描 workspace 目录，返回已保存的工作区名列表
-- 不用插件自带 fuzzy_load：它在 Windows 上通过 wscript(VBS) 子进程扫描，
-- 被 Defender 实时拖慢（卡几秒）且每次闪黑框；read_dir 是纯内存操作，瞬间完成
local function list_workspaces()
    local names = {}
    local ok, files = pcall(wezterm.read_dir, SAVE_DIR .. "\\workspace")
    if ok and files then
        for _, path in ipairs(files) do
            local name = string.match(path, "([^\\/]+)%.json$")
            if name then
                table.insert(names, name)
            end
        end
        table.sort(names)
    end
    return names
end

-- 构建选择器选项；为空时返回 nil 并提示。prefix 用于区分恢复/删除界面
local function make_choices(window, prefix)
    local names = list_workspaces()
    if #names == 0 then
        window:toast_notification("resurrect", "暂无已保存的工作区", nil, 3000)
        return nil
    end
    local choices = {}
    for _, name in ipairs(names) do
        table.insert(choices, { id = name, label = prefix .. " " .. name })
    end
    return choices
end

function M.apply(config)
    if not ok or not resurrect then
        return
    end

    ensure_save_dir()

    config.keys = config.keys or {}

    -- Ctrl+Shift+S：输入名称，保存当前工作区布局
    table.insert(config.keys, {
        key = "S",
        mods = "CTRL|SHIFT",
        action = wezterm.action.PromptInputLine({
            description = "保存当前工作区，输入名称:",
            action = wezterm.action_callback(function(window, _pane, line)
                if not line or line == "" then
                    return
                end
                -- 清理 Windows 文件名非法字符
                local name = line:gsub('[\\/:*?"<>|]', "_")
                local state = resurrect.workspace_state.get_workspace_state()
                resurrect.state_manager.save_state(state, name)
                window:toast_notification("resurrect", "已保存工作区: " .. name, nil, 2000)
            end),
        }),
    })

    -- Ctrl+Shift+R：选择工作区并恢复到当前窗口
    table.insert(config.keys, {
        key = "R",
        mods = "CTRL|SHIFT",
        action = wezterm.action_callback(function(window, pane)
            local choices = make_choices(window, "恢复 ▶")
            if not choices then
                return
            end
            window:perform_action(wezterm.action.InputSelector({
                title = "恢复工作区",
                description = "【恢复】回车将所选工作区恢复到当前窗口（关闭已有标签），Esc 取消",
                fuzzy_description = "搜索工作区: ",
                fuzzy = true,
                choices = choices,
                action = wezterm.action_callback(function(_w, p, id, _label)
                    if not id then
                        return
                    end
                    local state = resurrect.state_manager.load_state(id, "workspace")
                    resurrect.workspace_state.restore_workspace(state, {
                        window = p:window(),
                        close_open_tabs = true,  -- 关闭当前窗口已有标签，只留恢复的
                        relative = true,
                        restore_text = true,
                        resize_window = false,   -- 保持当前窗口大小，避免跨显示器 DPI 问题
                        on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                    })
                end),
            }), pane)
        end),
    })

    -- Ctrl+Shift+D：选择工作区并删除其状态文件
    table.insert(config.keys, {
        key = "D",
        mods = "CTRL|SHIFT",
        action = wezterm.action_callback(function(window, pane)
            local choices = make_choices(window, "删除 ✖")
            if not choices then
                return
            end
            window:perform_action(wezterm.action.InputSelector({
                title = "删除已保存的工作区",
                description = "【删除】回车将永久删除所选存档文件（不可恢复），Esc 取消",
                fuzzy_description = "搜索工作区: ",
                fuzzy = true,
                choices = choices,
                action = wezterm.action_callback(function(w, _p, id, _label)
                    if not id then
                        return
                    end
                    local path = SAVE_DIR .. "\\workspace\\" .. id .. ".json"
                    local removed = pcall(os.remove, path)
                    if removed then
                        w:toast_notification("resurrect", "已删除: " .. id, nil, 2000)
                    else
                        w:toast_notification("resurrect", "删除失败: " .. id, nil, 3000)
                    end
                end),
            }), pane)
        end),
    })
end

return M
