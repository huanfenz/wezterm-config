-- 超链接

local M = {}

function M.apply(config)
    config.hyperlink_rules = {
        -- Windows 绝对路径: C:\Users\name\file.txt 或 C:/Users/name/file.txt
        { regex = "\\b([A-Za-z]:[\\\\/][^\\s<>\\\"']+)\\b", format = "file://$1", highlight = 1 },
        -- 括号包裹的 URL: (https://example.com)
        { regex = "\\((\\w+://\\S+)\\)", format = "$1", highlight = 1 },
        -- 方括号包裹的 URL: [https://example.com]
        { regex = "\\[(\\w+://\\S+)\\]", format = "$1", highlight = 1 },
        -- 花括号包裹的 URL: {https://example.com}
        { regex = "\\{(\\w+://\\S+)\\}", format = "$1", highlight = 1 },
        -- 尖括号包裹的 URL: <https://example.com>
        { regex = "<(\\w+://\\S+)>", format = "$1", highlight = 1 },
        -- 普通 URL
        { regex = "\\b\\w+://\\S+[)/a-zA-Z0-9-]+", format = "$0" },
        -- 邮箱地址
        { regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b", format = "mailto:$0" },
    }
end

return M
