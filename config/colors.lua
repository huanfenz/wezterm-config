-- 颜色覆盖（搜索/选区高亮对所有主题生效，ANSI 调暗仅对 catppuccin-frappe）

local M = {}

function M.apply(config)
    -- 搜索高亮与选区颜色（不依赖主题）
    -- WezTerm 在线性空间做 alpha 混合（已用截图实测标定）：先画单元格底色，再把选区色按 alpha 叠其上。
    -- 同一个 selection_bg 在两处呈现不同颜色，实现划选与搜索高亮的解耦：
    --   · 划选：叠在深色背景 #303446 上 → 精确合成主题原划选色 #626880
    --   · 搜索当前项：叠在下方金黄垫底色上 → 精确合成 #f2d078
    config.colors = config.colors or {}
    config.colors.selection_bg = 'rgba(190, 201, 240, 0.19)'
    config.colors.selection_fg = 'none'    -- 划选文字保持原色
    -- 搜索当前项的垫底色（叠上 selection_bg 后恰好呈现 #f4da78，比 #f2d078 亮约 13%，文字 #3a3e50）；
    -- copy mode 未绑定按键，此值仅服务搜索
    config.colors.copy_mode_active_highlight_bg = { Color = '#ffde2e' }
    config.colors.copy_mode_active_highlight_fg = { Color = '#3a3e50' }

    if config.color_scheme ~= "catppuccin-frappe" then
        return
    end
    -- 调暗 ANSI yellow/bright yellow 以提升对比度（仅 catppuccin-frappe）
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
