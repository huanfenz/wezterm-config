-- 颜色覆盖（仅对 catppuccin-frappe，调暗 ANSI yellow/bright yellow 以提升对比度）

local M = {}

function M.apply(config)
    if config.color_scheme ~= "catppuccin-frappe" then
        return
    end
    config.colors = config.colors or {}
    config.colors.ansi = {
        "#51576d", -- black
        "#e78284", -- red
        "#a6d189", -- green
        "#b8860b", -- yellow  (原 #e5c890，加深以提升背景对比度)
        "#8caaee", -- blue
        "#f4b8e4", -- magenta
        "#81c8be", -- cyan
        "#b5bfe2", -- white
    }
    config.colors.brights = {
        "#626880", -- bright black
        "#e78284", -- bright red
        "#a6d189", -- bright green
        "#d4a017", -- bright yellow  (原 #e5c890，加深)
        "#8caaee", -- bright blue
        "#f4b8e4", -- bright magenta
        "#81c8be", -- bright cyan
        "#a5adce", -- bright white
    }
end

return M
