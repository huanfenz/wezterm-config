local M = {}

function M.apply(config)
    -- 窗口装饰样式
    config.window_decorations = "TITLE | RESIZE"

    -- 窗口行为
    config.adjust_window_size_when_changing_font_size = false
    config.window_close_confirmation = "NeverPrompt"
end

return M
