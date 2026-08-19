-- 分屏启动器：将常用连接和启动菜单项目打开到当前标签页的指定方向窗格

local wezterm = require("wezterm")

local M = {}

function M.apply(config)
    local act = wezterm.action

    config.keys = config.keys or {}

    local direction_names = {
        Top = "上方",
        Bottom = "下方",
        Left = "左侧",
        Right = "右侧",
    }

    local function split_launcher(direction)
        return wezterm.action_callback(function(window, pane)
            local choices = {
                { id = "1", label = "本地 Shell" },
            }
            local targets = {
                { kind = "local" },
            }

            -- 复用 launch_menu 中定义的串口、Telnet 等启动项。
            for _, item in ipairs(config.launch_menu or {}) do
                table.insert(targets, { kind = "launch", item = item })
                table.insert(choices, {
                    id = tostring(#targets),
                    label = item.label or "启动命令",
                })
            end

            -- SSH 域没有 launch_menu 条目，单独加入选择器。
            for _, domain in ipairs(config.ssh_domains or {}) do
                table.insert(targets, { kind = "ssh", name = domain.name })
                table.insert(choices, {
                    id = tostring(#targets),
                    label = "SSH: " .. domain.name,
                })
            end

            window:perform_action(act.InputSelector({
                title = "在" .. direction_names[direction] .. "分屏中启动",
                description = "选择目标后在当前标签页创建分屏，Esc 取消",
                fuzzy = true,
                choices = choices,
                action = wezterm.action_callback(function(inner_window, selected_pane, id, _label)
                    if not id then
                        return
                    end

                    local target = targets[tonumber(id)]
                    if not target then
                        return
                    end

                    local ok, err
                    if target.kind == "ssh" then
                        ok, err = pcall(selected_pane.split, selected_pane, {
                            direction = direction,
                            size = 0.5,
                            domain = { DomainName = target.name },
                        })
                    else
                        local item = target.item or {}
                        ok, err = pcall(selected_pane.split, selected_pane, {
                            direction = direction,
                            size = 0.5,
                            args = item.args,
                            cwd = item.cwd,
                            set_environment_variables = item.set_environment_variables,
                            domain = item.domain or "DefaultDomain",
                        })
                    end

                    if not ok then
                        inner_window:toast_notification("分屏启动失败", tostring(err), nil, 5000)
                    end
                end),
            }), pane)
        end)
    end

    for _, binding in ipairs({
        { key = "UpArrow", direction = "Top" },
        { key = "DownArrow", direction = "Bottom" },
        { key = "LeftArrow", direction = "Left" },
        { key = "RightArrow", direction = "Right" },
    }) do
        table.insert(config.keys, {
            key = binding.key,
            mods = "CTRL|ALT",
            action = split_launcher(binding.direction),
        })
    end
end

return M
